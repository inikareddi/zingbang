<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	AttributesetsController.php 
* Module	:	Admin Module - Attribute's Management
* Owner		:	RAM's 
* Purpose	:	This class is used for Marchant management operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Admin_AttributesetsController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $attributesets;			// used for creating an instance of model, Access is with in the class
	private $attributesetsdb;		// used for creating an instance of model, Access is with in the class
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     * 			and creates an instance of the model class 'Application_Model_Users'
     * 			and creates an instance of the model class 'Application_Model_Userdb'
     * 			This will every time check whether user has logged in or not
     * 			If not, user will be redirected to login screen
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function init() {
           
		$this->session = new Zend_Session_Namespace('MyPortal');               
		//$this->error = new Zend_Session_Namespace('MyPortalerror');
		
		$this->attributesets = new Application_Model_Attributesets();
		$this->attributesetsdb = new Application_Model_Attributesetsdb();		
		
		$user = new Application_Model_Users();
		$user->check();
				
		if(!$this->session->loggedIn) {
			$this->_redirect('admin/');	
		}             
		
		$this->_helper->layout->setLayout($this->session->layout);
	}	
	
	
	
	
	/**
     * Purpose: user will be redirected to user addition page.
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{
			$this->_redirect('admin/attributesets/list');
		} catch (Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	

	/**
     * Purpose: User listing page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function listAction() { 
		try{			
			$params = $this->_getAllParams();			
			$this->view->title = 'Attributesets List';                       
			$this->attributesets->getAttributesetsSearch($params);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: User addition page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function registerAction() {
		try{

			$this->view->title = "Add Attributesets";			
			$this->view->ActiveAttributesList = $this->attributesetsdb->getActiveAttributesList();
			$this->view->ActiveAttributesGroupsList = $this->attributesetsdb->getActiveAttributesGroupsList();
			$params = $this->_getAllParams();			
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				if(!$this->attributesets->createAttributesets($params)) {
					//$this->_redirect('admin/attributesets/register');					
				} else {
					$this->_redirect('admin/attributesets/list');
				}
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Lock the attributesets
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function lockAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			
			$params = $this->_getAllParams();
			$this->attributesets->lock($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: To Unlock the locked attributesets
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function unlockAction() {
		try{
			
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			
				$params = $this->_getAllParams();
				$this->attributesets->unlock($params);
				$this->_redirect($_SERVER['HTTP_REFERER']);
				//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To delete the attributesets
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function deleteAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			$params = $this->_getAllParams();
			$this->attributesets->delete($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Attributesets edit page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function editAction() {
		try{			
			$this->view->title = "Edit Attributesets";
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();
			$this->view->ActiveAttributesGroupsList = $this->attributesetsdb->getActiveAttributesGroupsList();

			if ($request->isPost()) {
			
				$params = $this->_getAllParams();
				
				if(!$this->attributesets->updateAttributesetsDetails($params)) {
					
					$attributes_set_id = $this->_getParam('attributes_set_id','');
					$this->view->AttributesetsDetails = $this->attributesetsdb->getAttributesetsDetails($attributes_set_id);
					$this->view->ActiveAttributesList = $this->attributesetsdb->getActiveAttributesList();
					$this->view->AttributesetsMappingList = $this->attributesetsdb->getAttributesetsMappingList($attributes_set_id);					
					//$this->_redirect('admin/attributesets/edit/attributes_set_id/' . $this->session->tcalledId);
				} else {
					$this->_redirect('admin/attributesets/list');
				}				
			}else{
				$attributes_set_id = $this->_getParam('attributes_set_id','');
				$this->view->AttributesetsDetails = $this->attributesetsdb->getAttributesetsDetails($attributes_set_id);
				$this->view->ActiveAttributesList = $this->attributesetsdb->getActiveAttributesList();
				$this->view->AttributesetsMappingList = $this->attributesetsdb->getAttributesetsMappingList($attributes_set_id);				
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}


?>
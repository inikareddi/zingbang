<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	CategoryController.php 
* Module	:	Admin Module - Merchant's Management
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

class Admin_AttributesController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $attributes;			// used for creating an instance of model, Access is with in the class
	private $attributesdb;		// used for creating an instance of model, Access is with in the class
	
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
		
		$this->attributes = new Application_Model_Attributes();
		$this->attributesdb = new Application_Model_Attributesdb();		
		
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
			$this->_redirect('admin/attributes/list');
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
			$this->view->title = "Attribute's List";
			$params = $this->_getAllParams();			              
			$this->attributes->getAttributeSearch($params);
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
			$this->view->title = "Register Attribute";			
			
			$params = $this->_getAllParams();			
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				if(!$this->attributes->createAttribute($params)) {
					//$this->_redirect('admin/attributes/register');					
				} else {
					$this->_redirect('admin/attributes/list');
				}
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: To Lock the category
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
			$this->attributes->lock($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: To Unlock the locked user
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
				$this->attributes->unlock($params);
				$this->_redirect($_SERVER['HTTP_REFERER']);
				//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To delete the category
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
			$this->attributes->delete($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Attribute edit page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function editAction() {
		try{			
			$this->view->title = "Edit Attribute";
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				$params = $this->_getAllParams();
				
				if(!$this->attributes->updateAttributesDetails($params)) {					
					//$this->_redirect('admin/attributes/edit/attributeId/' . $this->session->tcalledId);
				} else {
					$this->_redirect('admin/attributes/list');
				}				
			}else{
				$attribute_id = $this->_getParam('attributeId','');
				$this->view->AttributeDetails = $this->attributesdb->getAttributeDetails($attribute_id);
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}


?>
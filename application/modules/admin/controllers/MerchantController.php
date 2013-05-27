<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	MerchantController.php 
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

class Admin_MerchantController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $merchant;			// used for creating an instance of model, Access is with in the class
	private $merchantdb;		// used for creating an instance of model, Access is with in the class
	
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
		
		$this->merchant = new Application_Model_Merchant();
		$this->merchantdb = new Application_Model_Merchantdb();		
		
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
			$this->_redirect('admin/merchant/list');
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
			
			$this->view->title = 'Merchant List';			
			
			//if(!$this->merchant->getUsersSearchValidation($params)) {
				//return false;
			//}          
			$this->merchant->getMerchantSearch($params);
			
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
			
			$this->view->title = "Create Merchant";
			$params = $this->_getAllParams();	
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();
			
			if ($request->isPost()) {
			
				if(!$this->merchant -> createMerchant($params)) {
					$this->view->countrieslist = $this->merchantdb->getCountriesList();
					//$this->_redirect('admin/merchant/register');
					
				} else {
					$this->_redirect('admin/merchant/list');
				}
			}else{			
				$this->view->countrieslist = $this->merchantdb->getCountriesList();
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
			$this->merchant->lock($params);
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
				$this->merchant->unlock($params);
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
			$this->merchant->delete($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Merchant edit page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function editAction() {
		try{
			$this->view->title = "Edit Merchant";
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				$params = $this->_getAllParams();
				
				if(!$this->merchant->updateMerchantDetails($params)) {
					$this->view->countrieslist = $this->merchantdb->getCountriesList();
					//$this->_redirect('admin/merchant/edit/marchantId/' . $this->session->tcalledId);
				} else {
					$this->_redirect('admin/merchant/list');
				}				
			}else{
				$merchant_id = $this->_getParam('merchantId','');
				$this->view->merchant_id = $merchant_id;
				$this->view->MerchantDetails = $this->merchantdb->getMerchatDetails($merchant_id);
				$this->view->countrieslist = $this->merchantdb->getCountriesList();
				$this->view->MerchantImages = $this->merchantdb->getMerchantImages($merchant_id);					
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: To delete merchant image
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function deleteimageAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			$params = $this->_getAllParams();
			$this->merchant->deleteimage($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}


?>
<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	UserController.php 
* Module	:	User Management Module
* Owner		:	RAM's 
* Purpose	:	This class is used for user management operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Usermanagement_UserController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $users;			// used for creating an instance of model, Access is with in the class
	private $userdb;		// used for creating an instance of model, Access is with in the class
	
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
		$this->users = new Application_Model_Users();
		$this->userdb = new Application_Model_Userdb();
				
		$this->users->check();	
		
		
		if(!$this->session->loggedIn) {
			$this->_redirect('admin/');	
		}
                
		
		// Checking whether javascript is enabled or not
		/*if(isset($_COOKIE['verify_cookie']) && $_COOKIE['verify_cookie']=='Y'){
			$this->session->isJavascriptEnabled = 1;
		} else {
			$this->session->isJavascriptEnabled = 0;
		}*/
                
		
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
			//$this->_redirect('usermanagement/user/list');
		} catch (Exception $e) {
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
			
			$this->userdb->getUsertypes();
			$this->view->ActiveMerchantsList = $this->userdb->getActiveMerchantsList();
			$this->view->title = Title_User_create;
			$params = $this->_getAllParams();
			/*print_r($params);
			exit;*/
			//if(isset($params['firstname']) && isset($params['signup'])) {
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				if(!$this->users -> createUser($params)) {
					//$this->_redirect('usermanagement/user/register');
					
				} else {
					$this->_redirect('usermanagement/user/list');
				}
			}
			/*} else{
				
				$this->_redirect('usermanagement/user/list');
			}*/
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
	
	/*public function createuserAction() {
		try{
			$params = $this->_getAllParams();
						
			if(!$this->users -> createUser($params)) {
				$this->_redirect('usermanagement/user/register');
				
			} else {
				$this->_redirect('usermanagement/user/list');
			}
					
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}	
	}
	*/
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
			//echo "Here"; //exit;
			$params = $this->_getAllParams();
			
			$this->view->title = Title_User_list;			
			$this->userdb->getUsertypes();
			if(!$this->users->getUsersSearchValidation($params)) {
				return false;
			}
                        
                        //echo "hi";exit;
			$this->users->getUsersSearch($params);
                        
                        //exit;
			/*if(!$this->users->getUsersSearch($params)) {
				$this->_redirect('usermanagement/user/list');
			} else {
				$this->_redirect('usermanagement/user/list');
			}*/
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: User edit page
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function usereditAction() {
		try{
			/*if($_SERVER['HTTP_REFERER'] ==''){
					$this->_redirect("/default/error/accessdenied");
			}*/
			$params = $this->_getAllParams();
			
			if(!isset($params['userId']) || $params['userId'] == '' || $params['userId'] == 0) {
				$this->_redirect('usermanagement/user/list');	
			}			
			$this->userdb->getUsertypes();
			$this->view->userid = $params['userId'];
			$this->view->title = Title_User_update;
			$this->users->getuserdetails($params['userId']);
			
			if(isset($params['firstname']) && isset($params['userEdit'])) {
			
			
				if(!$this->users->updateuserdetails($params)) {
					//$this->_redirect('usermanagement/user/useredit/userId/' . $this->session->tcalledId);
				} else {
					$this->_redirect('usermanagement/user/list');
				}
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: User edit page
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function updateuserdetailsAction() {
		try{
			$params = $this->_getAllParams();
			 
			if(!$this->users->updateuserdetails($params)) {
				$this->_redirect('usermanagement/user/useredit/userId/' . $this->session->tcalledId);
			} else {
				$this->_redirect('usermanagement/user/list');
			}
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	
	/**
     * Purpose: To Lock the user
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function lockuserAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			
			$params = $this->_getAllParams();
			$this->users->lockuser($params);
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
		
	public function unlockuserAction() {
		try{
			
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			
				$params = $this->_getAllParams();
				$this->users->unlockuser($params);
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
		
	public function deleteuserAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			$params = $this->_getAllParams();
			$this->users->deleteuser($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: To Reset security question for a user
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function resetsecurityAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
			$this->_redirect("/default/error/accessdenied");
			}else{*/
			$params = $this->_getAllParams();			
			$this->users->resetsecurity($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: To Reset password for a user
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function resetpasswordAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
			$this->_redirect("/default/error/accessdenied");
			}else{*/
			$params = $this->_getAllParams();
			$this->users->resetpassword($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}


?>
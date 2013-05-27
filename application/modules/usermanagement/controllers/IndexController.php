<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	IndexController.php 
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

class Usermanagement_IndexController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $users;			// used for creating an instance of model, Access is with in the class
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     * 			and creates an instance of the model class 'Application_Model_Users'
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
		
		$this->users->check();
		
		//Checking whether user logged in or not
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
     * Purpose: Redirects to the user list page in 'Usermanagement_UserController'
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{
			$this->_redirect('usermanagement/user/list');
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: First time after login screen. Need to change user password on first login
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function setpasswordAction() {
		try{
			
			$this->_helper->layout->setLayout($this->session->emptylayout);
			
			$config = Zend_Registry::get('config');
			
            $this->view->reusepassword = $config->user->reusepassword;
			$fields = $this->_getAllParams();
			
			if(isset($fields['signup']) && isset($fields['new_password'])) {
				if($this->users->savechangepassword($fields)){
					$this->_redirect('admin/index/logout');
				} else {
					//$this->_redirect('usermanagement/index/success');
				}
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves changed user password and if success, redirects to logout screen for first login
     * 											if fails, redirects to the same change password page and shows an error message
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function savesetAction() {
		try{
			
			$fields = $this->_getAllParams();
			
			if($this->users->savechangepassword($fields)){
				$this->_redirect('default/index/logout');
			} else {
				$this->_redirect('usermanagement/index/success');
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	
	/**
     * Purpose: First time after login screen. Need to change user password on first login
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function firstloginAction() {
		try{
			if(!$this->session->firstlogin) {
				$this->error = 'You have already logged in first time.';
				$this->_redirect('reportmanagement/index/index');	
			}
			$this->_helper->layout->setLayout($this->session->emptylayout);
			$config = Zend_Registry::get('config');
            $this->view->reusepassword = $config->user->reusepassword;
            $this->view->title = Title_Default_first;
            $fields = $this->_getAllParams();
            
            if(isset($fields['signup']) && isset($fields['newpwd'])) {
	            
				
				/*
				 * Passing to save changed password and save change quesiotn are remaining.
				 * 
				 * Do this first on monday.
				 */
				if($this->users->savefirstlogin($fields)){
					$this->_redirect('default/index/logout');
					//$this->_redirect('usermanagement/index/firstsecurity');
				} else {
					//$this->_redirect('usermanagement/index/firstlogin');
				}
            }
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves changed user password and if success, redirects to logout screen for first login
     * 											if fails, redirects to the same change password page and shows an error message
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function savefirstAction() {
		try{
			
			$fields = $this->_getAllParams();
			
			
			if($this->users->savefirstlogin($fields)){
				$this->_redirect('default/index/logout');
				//$this->_redirect('usermanagement/index/firstsecurity');
			} else {
				$this->_redirect('usermanagement/index/firstlogin');
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	*/

	/**
     * Purpose: Change security questions screen. Need to answer for 2 security questions for security measures
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function changesecurityAction() {
		try{
			$questions = $this->users->fetchsecurityquestions($this->session->userid);
			
			$this->view->securityquestions = $questions;
			$this->view->title = Title_Change_security_question;
			
			$fields = $this->_getAllParams();
			
			if(isset($fields['signup']) && isset($fields['retypeanswer'])) {
				if($this->users->savesecurityquestionanswer($fields)){
					//if($this->view->ischange == 1) {
						$this->_redirect('usermanagement/index/changesecurity');
					/*} else if($this->view->ischange == 0){
						$this->_redirect('usermanagement/index/success');
					}*/
				} else {
					//$this->_redirect($_SERVER['HTTP_REFERER']);
				}
			}
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves security questions and answers. On success, it will return to success page
     * 												  On fail, it will return to the same page with an error message
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function savechangesecurityAction() {
		try{
			
			$fields = $this->_getAllParams();
			
			if($this->users->savesecurityquestionanswer($fields)){
				if($this->session->ischange == 1) {
					$this->_redirect('usermanagement/index/changesecurity');
				} else if($this->session->ischange == 0){
					$this->_redirect('reportmanagement/index/index');
				}
			} else {
				$this->_redirect($_SERVER['HTTP_REFERER']);
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	/**
     * Purpose: First login security questions screen. Need to answer for 2 security questions for security measures
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function firstsecurityAction() {
		try{
			if($this->session->securityenabled == 1) {
				$this->_redirect('reportmanagement/index/index');
			}
			$this->_helper->layout->setLayout($this->session->emptylayout);
			$questions = $this->users->fetchsecurityquestions();
			//$this->view->securityquestions = $questions;
			
			$fields = $this->_getAllParams();
			
			if (isset($fields['signup']) && isset($fields['answer'])) {
				if($this->users->savesecurityquestionanswer($fields)){					
						$this->_redirect('reportmanagement/index/index');
				} else {
					//print_r($this->view);
					//$this->_redirect($_SERVER['HTTP_REFERER']);
				}
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves security questions and answers. On success, it will return to success page
     * 												  On fail, it will return to the same page with an error message
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function savefirstsecurityAction() {
		try{			
			$fields = $this->_getAllParams();
			
			if($this->users->savesecurity($fields)){
				$this->_redirect('reportmanagement/index/index');
			} else {
				$this->_redirect('usermanagement/index/firstsecurity');
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	*/
	/**
     * Purpose: On every login, user is asked to answer a single question from those he saved first time.
     * 			One question is displayed at a time
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function asksecurityAction() {
		try{
			$this->_helper->layout->setLayout($this->session->emptylayout);
			$questions = $this->users->fetchsecurityquestions($this->session->userid);
			$this->view->securityquestions = $questions;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	
	/**
     * Purpose: Verifies the security answer for the given question and checks for the max wrong security answers
     * 			If user reaches the max limit, user will be redirected to logout else user is stayed in the same page with an error message
     * 			If he enters correct answer, redirected to success page
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function checksecurityAction() {
		try{
			$params = $this->_getAllParams();
			
			$questions = $this->users->checksecurityquestion($params);
			if($questions) {
				$this->_redirect('reportmanagement/index/index');
			} else {
				if($this->error->redirectlogout == 1) {
					$this->_redirect('default/index/logout');
				} else {
					$this->_redirect('usermanagement/index/asksecurity');
				}
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	
	/**
     * Purpose: Success screen.
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function successAction() {
		try{
			$this->view->success = "You have successfully logged in";
			$this->error->error = '';
			$this->view->title = Title_Successful_login;
        	
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	
	/**
     * Purpose: Once the user reaches password expiration limit, user will be asked to reset his password.
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function resetpasswordrequiredAction() {
		try{
			$config = Zend_Registry::get('config');
            $this->view->reusepassword = $config->user->reusepassword;
            $this->view->title = Title_Forced_reset_password;
			$this->view->success = "You are in resetpasswordrequiredAction";
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: User change password screen
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function changepasswordAction() {
		try{			
			$config = Zend_Registry::get('config');
            $this->view->reusepassword = $config->user->reusepassword;
            $this->view->title = Title_Change_password;
            
			$fields = $this->_getAllParams();
			if(isset($fields['signup']) && isset($fields['new_password'])) {
			if($this->users->savechangepassword($fields)){
				$this->_redirect('admin/index/logout');
			} else {
				//$this->_redirect('usermanagement/index/changepassword');
			}
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves changed user password and if success, redirects to logout screen
     * 											if fails, redirects to the same change password page and shows an error message
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function savechangepasswordAction() {
		try{
			$fields = $this->_getAllParams();
			if($this->users->savechangepassword($fields)){
				$this->_redirect('default/index/logout');
			} else {
				$this->_redirect('usermanagement/index/changepassword');
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
*/
	
	/**
     * Purpose: PersonalInfo edit
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function personalinfoAction() {
		try{
			$this->view->userid = $this->session->userid;
			$this->view->title = Title_Change_personalinfo;
			
			$this->users->getuserdetails($this->session->userid);			
			$params = $this->_getAllParams();
			
			if(isset($params['updatePersonalInfo']) && isset($params['lastname'])) {
				if(!$this->users->updatepersonaldetails($params)) {
					
				} else {
					$this->_redirect('usermanagement/index/personalinfo');
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
	public function personalinfoupdateAction() {
		try{
			$params = $this->_getAllParams();
			 
			if(!$this->users->updatepersonaldetails($params)) {
				$this->_redirect('usermanagement/index/personalinfo');
			} else {
				$this->_redirect('usermanagement/index/personalinfo');
			}			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	*/

}
?>
<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	IndexController.php 
* Module	:	Admin Module
* Owner		:	RAM's 
* Purpose	:	This class is used for common user operations for all user types
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Admin_IndexController extends Zend_Controller_Action { 
	public $session;	// used for managing session with NAMESPACE portal
	public $error;		// used for managing session with NAMESPACE portalerror
	private $users;		// used for creating an instance of model, Access is with in the class
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     * 			and creates an instance of the model class 'Application_Model_Users'
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function init() {
            
		$this->session = new Zend_Session_Namespace('MyPortal');
		$this->error = new Zend_Session_Namespace('MyPortalerror');
		$this->users = new Application_Model_Users();
		/*if($this->appname == '') {
			$this->appname = 'default';
		} else {
			$this->appname = $this->session->app;
		}*/
		
		//Checking whether javascript is enabled or not
		if(isset($_COOKIE['verify_cookie']) && $_COOKIE['verify_cookie']=='Y'){
			$this->session->isJavascriptEnabled = 1;
		} else {
			$this->session->isJavascriptEnabled = 0;
		}
		$this->setLayoutAction('admin');               
	}
	
	/**
     * Purpose: Checks user existance and prints the boolean value
     *
     * Access is public
     *
     * @param	
     * 
     * @return  prints true if exists and false if doesn't exists
     */
	
    public function checkusersessionAction ()
    {        
    	try {
    		if(!$this->session->loggedIn && $this->session->userTempId != '') {
				print $this->users->checkusertempsessionexistance();
			} else if($this->session->loggedIn) {
				print $this->users->checkusersessionexistance();
			}
    		        
			exit;  
    	}
		catch (Exception $e) {		 
			Application_Model_Logging::lwrite($e->getMessage());    
			throw new Exception($e->getMessage());
		}      
    }
    
    /**
     * Purpose: Sets layout with the appname
     *
     * Access is private
     *
     * @param	
     * 
     * @return  prints true if exists and false if doesn't exists
     */
    private function setLayoutAction($appname) {
    	try {
    		if(isset($appname) && $appname != '') {
    			$this->session->app = $appname;
    			$this->session->emptylayout = $this->session->app . '/emptylayout';
				$this->session->layout = $this->session->app . '/layout';
    		} else {
    			
    			$this->session->app = 'default';
    			$this->session->emptylayout = $this->session->app . '/emptylayout';
				$this->session->layout = $this->session->app . '/layout';
    		}  
    	}
		catch (Exception $e) {		 
			Application_Model_Logging::lwrite($e->getMessage());    
			throw new Exception($e->getMessage());
		}
    }
    
	/**
     * Purpose: Index action shows user login screen
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{
			if(isset($this->session->loggedIn) && $this->session->loggedIn) {
				$this->_redirect('usermanagement/user/');
			}
                       
 			$this->_helper->layout->setLayout( $this->session->emptylayout);

			$this->view->title = Title_Default_login;
			$params = $this->_getAllParams();
			
			if(isset($params['signup']) && isset($params['username'])) {
				if(!$this->users->checkUsers($params)) {
					//print_r($this->error);exit;
					//$this->_redirect('admin/index');
				} else {
					/*if($this->session->resetpasswordrequired) {
						$this->_redirect('usermanagement/index/resetpasswordrequired');
					} else {*/                                   
                       $this->_redirect('usermanagement/user/');
					/*}*/
					
				}
			}
			
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Checks user login credentials and 
     * 			on success, it will return to success method and 
     * 			on failure, it will return to index method
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function loginAction() {
		try{
			$params = $this->_getAllParams();
			//echo $this->users->checkUsers($params);
                        //exit;
			if(!$this->users->checkUsers($params)) {
                                //echo "hi1";exit;
				$this->_redirect('admin/index');
			} else {echo "hi2";exit;
				/*if($this->session->resetpasswordrequired) {
					$this->_redirect('usermanagement/index/resetpasswordrequired');
				} else {*/
					$this->_redirect('admin/index/success');	
				/*}*/
				
			}
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Checks for the user first login, security questions enabled and security question check
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function successAction() {
		try{
			if(!$this->session->loggedIn) {
				$this->_redirect('admin/index/index');	
			}
			
			$this->_redirect('usermanagement/index/success');
			
			$this->view->success = "You have successfully logged in";
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Logs out the user from the application and redirects to login page
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function logoutAction() {
		try{
			Zend_Session:: namespaceUnset('MyPortal');
			Zend_Session:: namespaceUnset('MyPortalerror');
			//Zend_Session:: namespaceUnset('APMportalDeviceerror');
			//Zend_Session:: namespaceUnset('editmerchant');
			//Zend_Session:: namespaceUnset('editmerchanterror');
			//Zend_Session:: namespaceUnset('addmerchanterrors');
			
			//Zend_Session::destroy();
			$this->_redirect('admin/index/index');
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Allows user to request for his password(Forgot password)
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function forgotpasswordAction() {
		try{
			$this->_helper->layout->setLayout( $this->session->emptylayout);
			$this->view->title = "Forgot Password";
			$params = $this->_getAllParams();
			/*print_r($params);
			echo isset($params['signup']);
			echo isset($params['loginid']);
			exit;*/
			$request = $this->getRequest();
			/*$Request_Values = $request->getPost();*/
			$validation=new Application_Model_Validation();
			if ($request->isPost()) {
				$logins=strip_tags($params['loginid']);
				$iaction=trim(strip_tags($params['action']));
				$error=0;
				 if($logins == '') {				//Validation for firstname
            	$this->view->error_forgot_loginid = Error_forgot_user_loginid_empty;
            	$error=1;
            } 
            if(!$validation->validate_email_dot_underscore($logins)) {
            	
            	$this->view->error_forgot_loginid = Error_forgot_user_loginid;
            	$error=1;
            } 
            if(strlen($logins) >50) {
            	$this->view->error_forgot_loginid = Error_email_field;
            	$error = 1;
            }
            
            if($iaction == '') {			//Validation for action name
				$this->view->error = Invalid_URL_Found;
            	$error=1;
            } else if(!$validation->validate_alpha($iaction)) {
            	
            	$this->view->error = Invalid_URL_Found;
            	$error=1;
            }
           /* echo "<pre>".$error;
            print_r($this->view);
            exit;*/
            if($error==1){
            	return false;
            	$error=0;
            }else{
            	
            
            
			if(isset($logins)) {
				if($this->users->checkuserexistance($params)) {
					$this->_redirect('admin/index/forgotquestion');
				} else {
					//$this->_redirect('admin/index/forgotpassword');
				}
			
			}
            }
			}
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Checks login id provided by the user
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	/*
	public function checkforgotpasswordloginAction() {
		try{
			$this->_helper->layout->setLayout( $this->session->emptylayout);
			$params = $this->_getAllParams();
			if($this->users->checkuserexistance($params)) {
				$this->_redirect('admin/index/forgotquestion');
			} else {
				$this->_redirect('admin/index/forgotpassword');
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	
	/**
     * Purpose: Security question check for forgot password
     * 			If security question was not enabled, he will be displayed a message and will not move to next page
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function forgotquestionAction() {
		try{
			if($this->session->userTempId == '') {
				$this->_redirect('admin/index/index');
			}
			$this->_helper->layout->setLayout( $this->session->emptylayout);
			$questions = $this->users->fetchsecurityquestions($this->session->userTempId);
			$this->view->securityquestions = $questions;
			
			$params = $this->_getAllParams();

			if(isset($params['signup']) && isset($params['answer'])) {
				$questions = $this->users->checksecurityquestion($params);
				
				if($questions) {
					$password = $this->users->generaterandomforgotpassword();
							
					if($password) {
						$this->_redirect('admin/index/forgotsuccess');
					} else {
						//$this->_redirect('admin/index/forgotquestion');
					}
				} else {
					if($this->view->redirectlogout == 1) {
						$this->_redirect('admin/index/forgotfailure');
					} else {
						//$this->_redirect('admin/index/forgotquestion');
					}
				}
			}
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Checks whether the given answer is correct or wrong
     * 			If correct, generates a password and triggers a mail
     * 			If incorrect, distroys the temporary session and redirects to forgot failure page
     * 			If user enters wrong security question more than the given limit, user account will be locked.
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function checkforgotquestionAction() {
		try{
			if($this->session->userTempId == '') {
				$this->_redirect('admin/index/index');
			}
			$params = $this->_getAllParams();
			
			$questions = $this->users->checksecurityquestion($params);
			
			if($questions) {
				$password = $this->users->generaterandomforgotpassword();
						
				if($password) {
					$this->_redirect('admin/index/forgotsuccess');
				} else {
					$this->_redirect('admin/index/forgotquestion');
				}
			} else {
				if($this->error->redirectlogout == 1) {
					$this->_redirect('admin/index/forgotfailure');
				} else {
					$this->_redirect('admin/index/forgotquestion');
				}
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	/**
     * Purpose: Success message page for successful completion of the process
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function forgotsuccessAction() {
		try{
			if($this->session->userTempId == '') {
				$this->_redirect('admin/index/index');
			}
			$this->_helper->layout->setLayout( $this->session->emptylayout);
			$this->view->title = Title_forgot_user_success;
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: Failure message page for unsuccessful completion of the process
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function forgotfailureAction() {
		try{
			if($this->session->userTempId == '') {
				$this->_redirect('admin/index/index');
			}
			$this->_helper->layout->setLayout( $this->session->emptylayout);
			$this->view->title = Title_forgot_user_falure;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: Function to check user existance and user email MX validation
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function checkusernameexistanceAction() {
		try{			
			$params = $this->_getAllParams();	
			$params['loginid'] = $params['username'];	
			if(!$this->users->checkuserexistance($params)) {
				if(isset($this->error->error_forgot_loginid) && $this->error->error_forgot_loginid != '') {
					$this->error->error_forgot_loginid = '';
					echo 1;
				} else if(isset($this->error->error) && $this->error->error != '') {
					$this->error->error = '';
					echo 1;
				}
				echo 1;
			} else {
				echo 0;
			}
			exit;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	

	/**
     * Purpose: Function to check user email MX validation
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function checkemailvalidateAction() {
		try{	
			$params = $this->_getAllParams();	
			$params['loginid'] = $params['username'];	
			if(!$this->users->validateuseremailMX($params)) {
				echo 0;
			} else {
				echo 1;
			}
			exit;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
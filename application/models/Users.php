<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Users.php 
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



//class Application_Model_Users extends Application_Model_Validation {
class Application_Model_Users extends Application_Model_Userdb {
	
	public $session;
	private $error;
	private $config;
	private $redirector;
	private $requestHandler;
	public $viewobj;
	
	/**
     * Purpose: Constructor sets sessions for portal and portalerror and config and returns session objects
     *
     * Access is public
     *
     * @param	
     * @return  
     */
	
	public function __construct(){
		//Assigning session
		$this->session = new Zend_Session_Namespace('MyPortal');
                

		//Assigning a config registry
		$this->config = Zend_Registry::get('config');
		
		//Checking for security enabled or not
		if(!isset($this->session->securityqenabled)) {
			$this->choosesecurityquestiontype();
		}
		
		//Redirector handler
		$this->redirector = Zend_Controller_Action_HelperBroker::getStaticHelper('redirector');
		
		//Request Handler
		$this->requestHandler = Zend_Controller_Front::getInstance()->getRequest();
		
		//View Renderer
		$viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
		$viewRenderer->initView();
		//Assigning renderer to access in the class
		$this->error = $viewRenderer->view;
		$this->viewobj= $viewRenderer->view;
	}
	
	/**
     * Purpose: Selects security question asking type( custom question or drop down) depending on app
     * 			configured in application.ini
     *
     * Access is with in the class
     *
     * @param	
     * 
     * @return  
     */
	
	public function choosesecurityquestiontype() {
		try{
			$enabledapps = explode(', ',$this->config->user->security->enabled);
            $disabledapps = explode(', ',$this->config->user->security->disabled);
            
            if(in_array($this->session->app, $enabledapps)) {
            	$this->session->securityqenabled = 1;
            } else if(in_array($this->session->app, $disabledapps)) {
            	$this->session->securityqenabled = 0;
            }
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());			
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Checks user password status and security status
     *
     * Access is public
     *
     * @param	
     * 
     * @return  object	Returns an object of status.
     */
	public function check() {
		try{
			$actionname = Zend_Controller_Front::getInstance()->getRequest()->getActionName();
			$exception = array('firstlogin', 'setpassword', 'firstsecurity');
			if(in_array($actionname, $exception)) {
				return;	
			}
				/* View - Sessions */				
				$viewObject = $this->viewobj;				
				$viewObject->loggedIn 			= $this->session->loggedIn;
				$viewObject->usertype 			= $this->session->usertype;
				$viewObject->role 				= $this->session->role;
				$viewObject->username 			= $this->session->username;
				$viewObject->usertypeid 		= $this->session->usertypeid;
				$viewObject->roleid 			= $this->session->roleid;
				$viewObject->userid 			= $this->session->userid;
				$viewObject->useremail 			= $this->session->useremail;
				$viewObject->priority 			= $this->session->priority;
				$viewObject->userloginid 		= $this->session->userloginid;
				$viewObject->firstlogin 		= $this->session->firstlogin;
				$viewObject->securityenabled 	= $this->session->securityenabled;
				
				
			if($this->session->firstlogin && !$this->session->securityenabled) {
			/*	$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'index','action' =>'firstlogin'));*/
				$this->redirector->gotosimple('firstlogin','index','usermanagement',array());
			} else {
			
				if($this->session->firstlogin) {
					/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'index','action' =>'setpassword'));*/
					$this->redirector->gotosimple('setpassword','index','usermanagement',array());	
				}
				
				if(!$this->session->securityenabled) {
					/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'index','action' =>'firstsecurity'));*/
					$this->redirector->gotosimple('firstsecurity','index','usermanagement',array());
						
				}
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());			
			throw new Exception($e->getMessage());
		}
	
	}

	/**
     * Purpose: Checks users login, assigns user details and returns an a boolean value of status
     *
     * Access is public
     *
     * @param	Array	$params Login form parameters
     * 
     * @return  object	Returns an object of status.
     */
	
	public function checkUsers(Array $params) {
		try{
			// Fetching details from config settings
			
			//print_r($params);exit;

            $hostexpiry = $this->config->user->passwordexpiry->hostusers;
            $resellerexpiry = $this->config->user->passwordexpiry->resellerusers;
            $merchantexpiry = $this->config->user->passwordexpiry->merchantusers;
            
            $noofattempts = $this->config->user->noofattempts;
            $reusepassword = $this->config->user->reusepassword;           
			
             
            //Segrigatind data from the input array
         //  print_r($params);
         if($params['username']!=''){
            $iusername = trim($params['username']);
         }else{
         	$iusername=$params['username'];
         }
           //exit;
           if($params['password']!=''){
            $ipassword = trim($params['password']);
           }else{
           	$ipassword = $params['password'];
           }
            $action = trim($params['action']);
            $module = trim($params['module']);
            $controller = trim($params['controller']);
            
            
           			
            /*
             * Validations for login(Email), password(Alpha Numeric), Action(Alpha)
             */
            $error = 0;
          /*  echo $iusername."<br/>password:";
            echo "sadsdssds";
            echo $ipassword;*/
           // exit;
            if($iusername == '') {		//Validation for username 
            	$this->error->error_login_empty_username = Error_login_user_userid_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_email_dot_underscore($iusername)) {
            	$params['username'] = '';
            	$this->error->error_login_empty_username = Error_login_user_userid;
            	$error = 1;
            	//return false;
            } else if(strlen($iusername) >50) {
            	$this->error->error_login_empty_username = Error_email_field;
            	$error = 1;
            }
            
            if($ipassword == '') {		//Validation for password
            	$this->error->error_login_empty_password = Error_login_user_password_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alphanumeric($ipassword)) {
            	$params['password'] = '';
            	$this->error->error_login_empty_password = Error_login_user_password;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alphanumeric_password($ipassword)) {
            	$params['password'] = '';
            	$this->error->error_login_empty_password = Error_login_user_improper_password;
            	$error = 1;
            } else if(strlen($ipassword) >16) {
            	$this->error->error_login_empty_password = Error_password_field_max;
            	$error = 1;
            } else if(strlen($ipassword) <8) {
            	$this->error->error_login_empty_password = Error_password_field_min;
            	$error = 1;
            }
            
			if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            	//return false;
            }
            
            if($error == 1) {
            	$this->error->error_login_values = $params;			//Assigning values to session variable to show on screen
            	$error = 0;
            	return false;
            }
            
          
            /*
             * Validation ends here
             */
            $ipassword=hash('sha256',$ipassword);
			$check = $this->checkUser($iusername, $ipassword, $action, $controller, $module, $noofattempts);
			$check = $check[0];
			$expiry = $check['opassexpiry'];							// Fetching Date count of previous password change
			$messarray = explode('#',$check['omess']);					// Fetching message and userid
			//print_r($messarray);exit;
			$message = $messarray[1];
			//$messcheck = trim($messarray[0]);
			/*if($messcheck != 0) {							//For a Active user Status
				$userid = $messarray[0];
			} else*/
			if($messarray[0] == 2) { 						//For a Locked user Status
				$this->session->loggedIn = 0;
				//$this->sendmail($this->session->useremail, $message, $newpassword);
				//$this->sendmailtemplate(urlencode($iusername), $message, User_Mail_Locked);
				$this->error->error = Error_login_user_userlocked;
				return false;
			} elseif($messarray[0] == 4) { 					//For a Deleted user Status
				$this->session->loggedIn = 0;
				$this->error->error = Error_login_user_userdeleted;
				return false;
			} elseif($messarray[0] == 0) { 						//For a Invalid password
				$this->session->loggedIn = 0;
				$this->error->error = Error_login_user_password;
				return false;
			} elseif($messarray[0] == 3) { 						//For a Invalid username
				$this->session->loggedIn = 0;
				$this->error->error = Error_login_user_userid;
				return false;
			}
			
			
			$checkcnt = $check['cnt'];			
			
			 if($checkcnt == 0) {
				$this->session->loggedIn = 0;
				$this->error->error = Error_login_user_invalidcredentials;
				return false;
			} else {
				
				switch ($check['usertypeid']) {
					case 1 :
					default :
							$this->session->passwordExpired = $hostexpiry;
							break;
					case 2 :
							$this->session->passwordExpired = $resellerexpiry;
							break;
					case 3 :
							$this->session->passwordExpired = $merchantexpiry;
							break;
				}
				
				$this->session->loggedIn = 1;
				$this->session->usertype = urlencode($check['usertype']);
				$this->session->role = $check['role'];
				$this->session->username = urlencode($check['name']);
				$this->session->usertypeid = $check['usertypeid'];
				$this->session->roleid = $check['roleid'];
				$this->session->userid = $check['userid'];
				$this->session->useremail = urlencode($check['email']);
				$this->session->priority = $check['priority'];
				$this->session->userloginid = $iusername;
				$this->session->firstlogin = $check['isfirstpass'];
				$this->session->securityenabled = $check['issecured'];
				
                                //echo $this->session->username;
                                //print_r($this->session); exit;
				if($this->session->passwordExpired <= $expiry && $this->session->passwordExpired != 0) {
					$this->session->resetpasswordrequired = 1;
				} else {
					$this->session->resetpasswordrequired = 0;
				}
				return true;
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());			
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Creates user and also used for updation of his profile and returns an a boolean value of status
     *
     * Access is public
     *
     * @param	Array	$params Create user parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function createUser(Array $params) {
		try{
			/*echo "<pre>";
			print_r($params);
			exit;*/
			$firstname = trim($params['firstname']);
			$lastname = trim($params['lastname']);
			$useremail = trim($params['useremail']);
			$phonenumber = trim($params['phonenumber']);
			$username = trim($params['username']);
			$role = trim($params['role']);
			$merchant_id = trim($params['merchant_id']);
			$action = trim($params['action']);

			//echo $this->validate_alphanumeric_space($firstname);
			/*
			 * Validation for firstname(Alpha numeric), lastname(Alpha Numeric), useremail(Email), phonenumber (Numeric)
			 * 				  username(Email), role(Numeric), action(alpha)
			 */
			
			
			$error = 0;
			
			/*print_r($this->error->error_createuser_values);
			exit;*/
            if($firstname == '') {				//Validation for firstname
            	$this->error->error_createuser_firstname = Error_Create_users_firstname_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alphanumeric_space($firstname)) {
            	$params['firstname'] = '';
            	$this->error->error_createuser_firstname = Error_Create_users_firstname;
            	$error = 1;
            	//return false;
            } else if(strlen($firstname) >20) {
            	$this->error->error_createuser_firstname = Error_name_field;
            	$error = 1;
            } else if(strlen($firstname) < 3) {
            	$this->error->error_createuser_firstname = Error_name_field_min;
            	$error = 1;
            }
            
			if($lastname == '') {				//Validation for lastname
            	$this->error->error_createuser_lastname = Error_Create_users_lastname_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alphanumeric_space($lastname)) {
            	$params['lastname'] = '';
            	$this->error->error_createuser_lastname = Error_Create_users_lastname;
            	$error = 1;
            	//return false;
            } else if(strlen($lastname) >20) {
            	$this->error->error_createuser_firstname = Error_name_field;
            	$error = 1;
            }
            
			if($useremail == '') {				//Validation for user email
            	$this->error->error_createuser_email = Error_Create_users_email_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_email_dot_underscore($useremail)) {
            	$params['useremail'] = '';
            	$this->error->error_createuser_email = Error_Create_users_email;
            	$error = 1;
            	//return false;
            } else if(strlen($useremail) >50) {
            	$this->error->error_createuser_email = Error_email_field;
            	$error = 1;
            }
            
			if($phonenumber == '') {			//Validation for phone number
            	$this->error->error_createuser_phonenumber = Error_Create_users_phone_empty;
            	$error = 1;
            	//return false;
            } else if(!(int) $phonenumber || substr($phonenumber, 0, 1) == 0) {
            	$this->error->error_createuser_phonenumber = Error_Create_users_phone;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_numeric($phonenumber)) {
            	$params['phonenumber'] = '';
            	$this->error->error_createuser_phonenumber = Error_Create_users_phone;
            	$error = 1;
            	//return false;
            } else if(strlen($phonenumber) >10) {
            	$this->error->error_createuser_phonenumber = Error_phone_field_max;
            	$error = 1;
            } else if(strlen($phonenumber) <10) {
            	$this->error->error_createuser_phonenumber = Error_phone_field_min;
            	$error = 1;
            }
			
            
			if($username == '') {				//Validation for username
            	$this->error->error_createuser_username = Error_Create_users_username_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_email_dot_underscore($username)) {
            	$params['username'] = '';
            	$this->error->error_createuser_username = Error_Create_users_username;
            	$error = 1;
            	//return false;
            } else if(strlen($username) >50) {
            	$this->error->error_createuser_username = Error_email_field;
            	$error = 1;
            }
            
			if($role == '' || $role == 0 || $role == 'Select') {	//Validation for role
            	$this->error->error_createuser_role = Error_Create_users_role_empty;
            	$error = 1;
            	$params['role'] = '';
            	//echo "Here";
            	//return false;
            } else if(!$this->validate_numeric($role)) {
            	$params['role'] = ''; 
            	//echo $params['role'];
            	$this->error->error_createuser_role = Error_Create_users_role;
            	$error = 1;
            	//return false;
            }
            //exit;
			if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }
            
          
            
            if($error == 1) {
            	$this->error->error_createuser_values = $params;
            	$error = 0;
            	return false;
            }
          
            /*
             * Validation ends here
             */
          		
				$password = make_password(8);
				//$password1=hash('sha256',$password);
				
				$outpt = $this->saveUser($firstname, $lastname, $useremail,$phonenumber, $username, $role, $merchant_id, $password, $action, $this->session->userid);
				
				$outpt = $outpt[0];
				$result = explode('#', $outpt['toutput']);
				
				if($result[0] == 1) {
					
					$toname = urlencode($firstname) . ' ' . urlencode($lastname);
					$this->sendmail(urldecode($useremail), $firstname, $lastname, $result[1], NULL, $username);
					//$this->sendmailtemplate($useremail, $toname, User_Mail_Loginid, $username);				 	
				 	sleep(4);
				 	$this->sendmail(urldecode($useremail), $firstname, $lastname, $result[1], $password);					
					//$this->sendmailtemplate($useremail, $toname, User_Mail_Password, $password);
					$this->session->success = Success_user_creation . ' with Login ID ' . $username ;
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' with Login ID ' . $username ;
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetches all the users except the present loggedin user
     *
     * Access is public
     *
     * @param	Array	$params Create user parameters
     * 
     * @return  
     */
	
	public  function getUsers($iStart=NULL) {
		try{
			if(is_null($iStart)) {
				$iStart = 0;
			}
			
			$iLimit = $this->config->user->displaylimit;
			
			
			$cond = '0_0_0_0';
			$count = $this->getUsercount($this->session->usertypeid, $cond);
			
			$opt = $this->getUserList($this->session->userid, $iStart, $iLimit, $cond);
			
			
			
			$this->error->users_total_count = (int)$count-1;			
			$this->error->iStart = $iStart;
			$this->error->iLimit = $iLimit;
			$this->error->users= $opt;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetches all the user details for the supplied id and assigns some of the details to view
     *
     * Access is public
     *
     * @param	Int		$userid
     * 
     * @return  
     */
	
	public function getuserdetails($userid) {
		try{
			
			if($userid!='' && $userid!=0 && $this->validate_numeric($userid)) {
			$ress=$this->checkapmuserexists($userid);
			/*print_r($ress);
			exit;*/
			if($ress[0]['cnt']>0){
			$opt = $this->fetchUserDetails($userid);
			
			$opt = $opt[0];
			if($opt['stat'] == 3) {
			/*$this->redirector->gotoRoute(array('module'=>'default', 'controller'=> 'error',
   'action' =>'accessdenied'));*/
			$this->session->validateerror=Error_Invalid_user_Id;
				
				
				$this->redirector->gotosimple('list','user','usermanagement',array());
			} else {
			$this->error->update= $userid;
			$this->error->firstname= $opt['firstname'];
			$this->error->lastname= $opt['lastname'];
			$this->error->username= $opt['username'];
			$this->error->userloginid= $opt['userloginid'];
			//$this->error->usertype= $opt['usertypeid'];
			$this->error->phonenumber= $opt['phonenumber'];
			$this->error->userroleid= $opt['roleid'];
			$this->error->role= $opt['role'];
			}
			}else{
				
				$this->session->validateerror=Error_Invalid_user_Id;
				
				
				$this->redirector->gotosimple('list','user','usermanagement',array());
			}
			}else{
				$this->session->validateerror=Error_Invalid_user_Id;
				
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user',
   'action' =>'list'));*/
				$this->redirector->gotosimple('list','user','usermanagement',array());
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	/**
     * Purpose: Checks the user existance for logged in user and returns true or false
     *
     * Access is public
     *
     * @param	
     * 
     * @return  boolean	true if user exists, false if user doesnot exists
     */
	
	public  function checkuserexistance(Array $params) {
		try{
			 $iuserid = trim(strip_tags($params['loginid']));
			$iaction = trim(strip_tags($params['action']));
			
					
			
			/*
			 * Validation for userid(email), action(alpha)
			 */
			$this->error->error_forgot_values = $params;
           /* if($iuserid == '') {				//Validation for firstname
            	$this->error->error_forgot_loginid = Error_forgot_user_loginid_empty;
            	return false;
            } else if(!$this->validate_email_dot_underscore($iuserid)) {
            	$this->error->error_forgot_loginid = Error_forgot_user_loginid;
            	return false;
            } else if(strlen($iuserid) >50) {
            	$this->error->error_forgot_loginid = Error_email_field;
            	$error = 1;
            }
            
            if($iaction == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	return false;
            } else if(!$this->validate_alpha($iaction)) {
            	$this->error->error = Invalid_URL_Found;
            	return false;
            }
            */
            
            /*
             * Validation ends here
             */
            
            if($iaction == 'checkusernameexistance'){
            	$iaction = '';
            }
            
            $details = $this->userExistance($iuserid, $iaction);
			$details = $details[0];
			
			if($details['cnt'] == 0){
				$this->error->error = Error_forgot_user_loginid;
				if($iaction == ''){
	            	return true;
	            }
				return false;
			}
			else{
				 if($iaction == ''){
	            	return false;
	            }
				/*
				if($details['issecured'] == 0) {
					 $this->error->error = 'Sorry, ' . Error_forgot_user_nosecques . ' for ' . urldecode($details['firstname']) . ' ' . urldecode($details['lastname']) . '. Please contact administrator.';
					return false;
				} else {
					$this->session->success = urlencode($details['firstname']) . ' ' . urlencode($details['lastname']) . ' ' . Success_forgot_user_loginid;
					$this->session->userTempId = $details['userid'];
					$this->session->userTempName = urlencode($details['firstname']) . ' ' . urlencode($details['lastname']);
					$this->session->userTempFirstName = urlencode($details['firstname']);
					$this->session->userTempLastName = urlencode($details['lastname']);
					$this->session->userTempUsername = $details['emailid'];
					return true;
				}*/
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	

	
	/**
     * Purpose: Validates the user email(MX validation)
     *
     * Access is public
     *
     * @param	
     * 
     * @return  boolean	true if valid user email, false if invalid user email
     */
	
	public  function validateuseremailMX(Array $params) {
		try{
			$iuserid = trim($params['loginid']);
			$iaction = trim($params['action']);
			
			
			/*
			 * Validation for userid(email), action(alpha)
			 */
			
            if(!$this->validate_email_dot_underscore($iuserid)) {
            	return false;
            }
            
            if($iaction == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	return false;
            } else if(!$this->validate_alpha($iaction)) {
            	$this->error->error = Invalid_URL_Found;
            	return false;
            }
            return true;
            
            /*
             * Validation ends here
             */
           
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetches all available security questions and returns the question object
     *
     * Access is public
     *
     * @param	int		$userid user id, by default NULL,
     * 							If user id is NULL, all security questions are displayed
     * 							If user id is not NULL, security question for the specific user are displayed
     * 
     * @return  object	security question object is returned
     */
	
	public  function fetchsecurityquestions($userid=NULL) {
		try{
			
			if(!is_null($userid)) {
				
				$questions = $this->getsecurityquestions($userid);
				
				return @$questions[0];
			} else {
				return $this->getsecurityquestions();
			}
							
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves password for the logged in user and returns boolean value true or false
     *
     * Access is public
     *
     * @param	Array	$changepass Array of change password form details
     * 
     * @return  boolean	true if user successfully changes the password,
     * 					false if there is any error
     */
	
	public  function savechangepassword(Array $changepass) {
		try{            
            $reusepassword = $this->config->user->reusepassword;
			
			$action = trim($changepass['action']);
			$ioldpass = trim($changepass['old_password']);
			$inewpass = trim($changepass['new_password']);
			$iconfpass = trim($changepass['confirm_password']);
			$iuserid = $this->session->userid;
			
			
			
			/*
			 * Validation for firstname(Alpha numeric), lastname(Alpha Numeric), useremail(Email), phonenumber (Numeric)
			 * 				  username(Email), role(Numeric), action(alpha)
			 */
			$error = 0;
			            
            if($ioldpass == '') {				//Validation for old password
            	$this->error->error_changepassword_old = Error_login_user_password_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric($ioldpass)) {
            	$changepass['old_password'] = '';
            	if($action == 'setpassword') {
            		$this->error->error_changepassword_old = Error_user_temp_password;
            	} else {
            		$this->error->error_changepassword_old = Error_login_user_oldpassword;
            	}
            	$error = 1;
            } else if(strlen($ioldpass) > 16) {
            	$this->error->error_changepassword_old = Error_password_field_max;
            	$error = 1;
            } else if(strlen($ioldpass) < 8) {
            	$this->error->error_changepassword_old = Error_password_field_min;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_password($ioldpass)) {
            	$changepass['old_password'] = '';
            	if($action == 'setpassword') {
            		$this->error->error_changepassword_old = Error_user_temp_password;
            	} else {
            		$this->error->error_changepassword_old = Error_login_user_oldpassword;
            	}
            	$error = 1;
            }

			if($inewpass == '') {				//Validation for new password
            	$this->error->error_changepassword_new = Error_login_user_new_password_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric($inewpass)) {
            	$changepass['new_password'] = '';
            	$this->error->error_changepassword_new = Error_login_user_newpassword;
            	$error = 1;
            } else if(strlen($inewpass) > 16) {
            	$this->error->error_changepassword_new = Error_password_field_max;
            	$error = 1;
            } else if(strlen($inewpass) < 8) {
            	$this->error->error_changepassword_new = Error_password_field_min;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_password($inewpass)) {
            	$changepass['new_password'] = '';
            	$this->error->error_changepassword_new = Error_login_user_newpassword;
            	$error = 1;
            }
            
			if($iconfpass == '') {				//Validation for confirm password
            	$this->error->error_changepassword_conf = Error_login_user_confirmpassword_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric($iconfpass)) {
            	$changepass['confirm_password'] = '';            
            	$this->error->error_changepassword_conf = Error_login_user_renewpassword;
            	$error = 1;
            } else if($iconfpass != $inewpass) {
            	$this->error->error_changepassword_conf = Error_login_user_unmatchpass;
            	$error = 1;
            } else if(strlen($iconfpass) > 16) {
            	$this->error->error_changepassword_conf = Error_password_field_max;
            	$error = 1;
            } else if(strlen($iconfpass) < 8) {
            	$this->error->error_changepassword_conf = Error_password_field_min;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_password($iconfpass)) {
            	$changepass['confirm_password'] = '';
            	$this->error->error_changepassword_conf = Error_login_user_renewpassword;
            	$error = 1;
            }
            
			
            
            
			if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	$error = 1;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }else if(!$this->requestHandler->isPost()) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }
            
            
            if($error == 1) {
            	$error = 0;
            	return false;
            }
            
            /*
             * Validation ends here
             */
			if($this->session->firstlogin == 1) {
				$firstlogin = 2;
			} else {
				$firstlogin = 0;
			}
		
			$message = $this->savechangedpassword($iuserid, $ioldpass, $inewpass,$action, $firstlogin, $reusepassword);			
			$session=new Zend_Session_Namespace("addmerchant");
			$message = $message['@omess'];
			$var = explode('#', $message);
			$this->error->error = $var[1];
			if($var[0] == 3) {
				if($action == 'setpassword') {
            		$this->error->error = Error_user_temp_password;
            	} else {
            		$this->error->error = Error_user_old_password;
            	}				
				return false;
			}elseif($var[0] == 5) {
				if($action == 'setpassword') {
            		$this->error->error = Failure_updated_user_password;
            	} else {
            		$this->error->error = Failure_updated_user_password;
            	}				
				return false;
			} elseif($var[0] == 4) { 					//For a Deleted user Status
				//$this->session->loggedIn = 0;
				if($this->session->firstlogin == 1) {
					$this->error->error = Error_login_user_userchangedpassword;
				} else {
					$this->error->error = Error_login_user_userchangedpassword;
					
				}
				return false;
			} else if($var[0] == 2) {
				$this->error->error = Error_user_repeat_password;
				return false;
			} else if($var[0] == 0) {
				$this->error->error = Error_user_failed_password;
				return false;
			} else {
				if($this->session->firstlogin == 1) {
					$this->session->firstlogin = 0;
				}				
				
				$session->success = Success_firstlogin_user_password;				
				return true;
			}
							
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves security questions for the logged in user and returns boolean value true or false
     *
     * Access is public
     *
     * @param	Array	$securityqa Array of change security questions form details
     * 
     * @return  boolean	true if user successfully enters the questions and answers,
     * 					false if there is any error
     */
	/*
	public  function savesecurity(Array $securityqa) {
		try{
			$action = trim($securityqa['action']);
			$securityq1 = trim($securityqa['security1']);
			$securityq2 = trim($securityqa['security2']);
			$securityans1 = strtolower(trim($securityqa['answer1']));
			$securityans2 = strtolower(trim($securityqa['answer2']));
			$iuserid = $this->session->userid;
			if($this->session->securityenabled == 0) {
				$isupdate = 0;
			} else {
				$isupdate = 1;
			}
			
			$message = $this->savesecurityqa($securityq1,$securityq2, $securityans1, $securityans2, $iuserid, $action, $isupdate);
			
			$message = $message['@omess'];
			$var = explode('#', $message);
			$this->error->error = $var[1];
			
			if($var[0] == 0) {
				return false;
			} else {
				$this->session->securityenabled = 1;
				return true;
			}
							
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}*/
	
	/**
     * Purpose: Checks security question and answer and returns boolean true or false
     *
     * Access is public
     *
     * @param	Array	$changepass Array of check security question form details
     * 
     * @return  boolean	true if user successfully enters answer for the given question,
     * 					false if there is any error or maximum attempts crossed
     */
	
	public  function checksecurityquestion(Array $questiondetails) {
		try{
			
			$action = trim($questiondetails['action']);
			$secureid = trim($questiondetails['secureid']);
			$answer = strtolower(trim($questiondetails['answer']));
			$retypeanswer = strtolower(trim($questiondetails['retypeanswer']));
			
			if(!isset($questiondetails['secureid'])) {
				return false;
			}
			
						
			/*
			 * Validation for secureid(alpha numeric with spaces and apostope
			 */
			$error = 0;
            if($secureid == '') {				//Validation for secureid
            	$this->error->error_forgot_question_checkid = Error_forgot_secure_question;
            	$error = 1;
            } else if(!$this->validate_numeric($secureid)) {
            	$this->error->error_forgot_question_checkid = Error_forgot_secure_question;
            	$error = 1;
            }
            
			if($answer == '') {				//Validation for answer
            	$this->error->error_forgot_question_answer = Error_forgot_secure_answer_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($answer)) {
            	$this->error->error_forgot_question_answer = Error_forgot_secure_answer;
            	$error = 1;
            } else if(strlen($answer) >30) {
            	$this->error->error_forgot_question_answer = Error_answer_field_max;
            	$error = 1;
            } else if(strlen($answer) < 1) {
            	$this->error->error_forgot_question_answer = Error_answer_field_min;
            	$error = 1;
            }
            
			if($retypeanswer == '') {				//Validation for confirm answer
            	$this->error->error_forgot_question_answer_confirm = Error_forgot_secure_answer_confirm_empty;
            	$error = 1;
            } else if($retypeanswer != $answer) {
            	$this->error->error_forgot_question_answer_confirm = Error_forgot_secure_answer_confirm;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($retypeanswer)) {
            	$this->error->error_forgot_question_answer_confirm = Error_forgot_secure_reanswer;
            	$error = 1;
            } else if(strlen($retypeanswer) >30) {
            	$this->error->error_forgot_question_answer_confirm = Error_answer_field_max;
            	$error = 1;
            } else if(strlen($retypeanswer) < 1) {
            	$this->error->error_forgot_question_answer_confirm = Error_answer_field_min;
            	$error = 1;
            }
            
            if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
				$error = 1;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }
            if($error == 1) {            	
            	$error = 0;
            	return false;
            }
            
            /*
             * Validation ends here
             */
			
			
			if(isset($this->session->userid)) {
				$iuserid = $this->session->userid;
				$iforgot = 0;
			} else if(isset($this->session->userTempId)) {
				$iuserid = $this->session->userTempId;
				$iforgot = 1;
			}
            
			//Check for number of wrong security question attempts which is configured in config page
            $noofwrongsecurity = $this->config->user->noofwrongsecurity;			
			
			$message = $this->checksecurityqa($secureid, $answer, $iuserid, $action, $noofwrongsecurity, $iforgot);
			
			$message = $message['@omess'];
			$var = explode('#', $message);
			$this->error->error = $var[1];
			
			if($var[0] == 0) {
				$this->error->error = Error_forgot_secure_answer;
				return false;
			} else if($var[0] == 2) {
				//User will be locked and redirects to logout if he reaches maximum wrong attempts.
				$this->error->redirectlogout = 1;
				$this->error->error = Error_forgot_user_seclocked;
				return false;
			} else {
				return true;
			}
							
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: To generate random password for the user
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user successfully enters answer for the given question,
     * 					false if there is any error or maximum attempts crossed
     */
	
	public function generaterandomforgotpassword($userid=NULL, $action=NULL, $adminReset = 0, $firstname =NULL, $lastname =NULL, $toid = NULL){
		try{
			
			$reusepassword = $this->config->user->reusepassword;
			$password = make_password(8);
			if($adminReset != 0) {
				$ioldpass = '';
				$iuserid = $userid;
				$action = $action;
				$admin = $adminReset;
				
				$message = $this->savechangedpassword($iuserid, $ioldpass, $password,$action, 3, $reusepassword, $admin);
				
			} else {
				$ioldpass = '';
				$iuserid = $this->session->userTempId;
				$action = 'generateforgotpassword';
				$message = $this->savechangedpassword($iuserid, $ioldpass, $password,$action, 1, $reusepassword);
			}			
			
			$message = $message['@omess'];
			$var = explode('#', $message);
			$this->error->error = $var[1];			
			if($var[0] == 0) {
				return false;
			} else {
				if($adminReset != 0) {
					$this->sendmail(urldecode($toid), $firstname, $lastname, NULL, $password, NULL, 1);
					$this->error->error = Success_reset_user_password;
				} else {
					$this->sendmail(urldecode($this->session->userTempUsername), $this->session->userTempFirstName, $this->session->userTempLastName, NULL, $password, NULL, 1);
					$this->error->error = Success_forgot_user_emailsent;
				}
				
				return true;
			}	
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: To check logged in user idle action
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user performs action in the given idle time out,
     * 					false if user was idle
     */
	public function checkusersessionexistance() {
		try{
			if($this->session->userid != ''){
				return 1;
			}
			else{
				return 0;
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: To send password or username email
     *
     * Access is to class only
     *
     * @param	varchar	$to Email id of the reciever
     * @param	varchar	$toname Name of the reciever
     * @param	varchar	$password Password generated / changed
     * 							  Default is NULL
     * @param	varchar	$usernamesend Username of the User
     * 							  Default is NULL
     * 
     * @return  
     */
	private function sendmail($to, $firstname, $lastname, $rolename = NULL, $password = NULL, $usernamesend = NULL, $isTemp = NULL) {
		try{
			
			/*
			 * Generating password and making email template
			 */
						
			$templatefrom = '';
			$templatename = '';
			$templateid = '';
			$templatesubject = '';
			$templatecontent = '';
			$date = date('F d, Y');
			$copydate = date('Y');
			$toname = $firstname . ' ' . $lastname;
			$app=$this->session->app;
			$imgurl=ROOT_PUBLIC_PATH.'/'.$app.'/pent-portal-images';
							
			if(is_null($password) && is_null($isTemp) && $isTemp != 1 && !is_null($usernamesend)) {
				
				$templates = $this->htmlForPassword(User_Mail_Loginid, $this->session->reseller, $this->session->app);	
				$templates = $templates[0];
				$templatename = $templates['emailtemplatename'];
				$templateid = $templates['emailtemplateid'];
				$templatesubject = $templates['emailsubject'];
				$templatefrom = $templates['emailfrom'];
				$templatecontent = $templates['emailcontent'];
				
				$search= array("#date", "#firstname", "#lastname","#rolename","#username","#imageurl","#copydate");
				$replace   = array($date, $firstname,$lastname,$rolename, $usernamesend,$imgurl,$copydate);
				$ispassword=0;
				
				
			} else if(is_null($usernamesend) && is_null($isTemp) && $isTemp != 1 && !is_null($password)) {
				
				$templates = $this->htmlForPassword(User_Mail_Password, $this->session->reseller, $this->session->app);
				$templates = $templates[0];
				$templatename = $templates['emailtemplatename'];
				$templateid = $templates['emailtemplateid'];
				$templatesubject = $templates['emailsubject'];
				$templatefrom = $templates['emailfrom'];
				$templatecontent = $templates['emailcontent'];
				$ispassword=1;
				$search= array("#date", "#firstname", "#lastname","#rolename","#password", "#sitebaseurl","#imageurl","#copydate");
				$replace   = array($date, $firstname,$lastname,$rolename, $password, APPLICATION_HOST_PATH,$imgurl,$copydate);
				
			} else if(is_null($usernamesend) && !is_null($password) && !is_null($isTemp) && $isTemp == 1) {
				
				$templates = $this->htmlForPassword(User_Mail_Temp_Password, $this->session->reseller, $this->session->app);
				$templates = $templates[0];
				$templatename = $templates['emailtemplatename'];
				$templateid = $templates['emailtemplateid'];
				$templatesubject = $templates['emailsubject'];
				$templatefrom = $templates['emailfrom'];
				$templatecontent = $templates['emailcontent'];
				$ispassword=1;
				$search= array("#date", "#firstname", "#lastname","#password","#imageurl","#copydate");
				$replace   = array($date, $firstname,$lastname, $password,$imgurl,$copydate);
				//$content = sprintf($templatecontent, ROOT_PUBLIC_PATH, $toname, $password, ROOT_PUBLIC_PATH);
				
			}
			
			
			/*
			 * parsing email body
			 */
			
			$content=str_replace($search, $replace, $templatecontent);
			
			/*
			 * Send Email
			 */
			/*echo $content;
			exit;*/
			$this->mailsend($toname, $templatefrom, $to, $content, $templatesubject,$ispassword);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: To check user idle action for forgot password action process
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user performs action in the given idle time out,
     * 					false if user was idle
     */
	public function checkusertempsessionexistance() {
		try{
			if($this->session->userTempId != ''){
				return 1;
			}
			else{
				return 0;
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: To update user details
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user performs action in the given idle time out,
     * 					false if user was idle
     */
	public function updateuserdetails(Array $params) {
		try{
			
						
			$userid = trim($params['userId']);
			$action = trim($params['action']);
			$firstname = trim($params['firstname']);
			$lastname = trim($params['lastname']);
			$useremail = trim($params['useremail']);
			$phone = trim($params['phonenumber']);
			$role = trim($params['role']);
			$admin = $this->session->userid;
			
			//$this->session->tcalledId = $userid;
			
			/*
			 * Validation for firstname(Alpha numeric), lastname(Alpha Numeric), useremail(Email), phonenumber (Numeric)
			 * 				  username(Email), role(Numeric), action(alpha)
			 */
			$error = 0;
			
			if($userid!='' && $userid!=0 && $this->validate_numeric($userid)) {
				$ress=$this->checkapmuserexists($userid);
				//print_r($ress);exit;
				if($ress[0]['cnt']>0){ 
					
					
			//$refurl1=$_SERVER['HTTP_REFERER'];
			//$refurl=explode("/", $refurl1);
			/*echo $userid;
			print_r($refurl);
			exit;*/
			//if($refurl[8]==$userid){
					
			            
            if($firstname == '') {				//Validation for firstname
            	$this->error->error_updateuser_firstname = Error_Create_users_firstname_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($firstname)) {
            	$params['firstname'] = '';
            	$this->error->error_updateuser_firstname = Error_Create_users_firstname;
            	$error = 1;
            } else if(strlen($firstname) >20) {
            	$this->error->error_updateuser_firstname = Error_name_field;
            	$error = 1;
            }
            
			if($lastname == '') {				//Validation for lastname
            	$this->error->error_updateuser_lastname = Error_Create_users_lastname_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($lastname)) {
            	$params['lastname'] = '';
            	$this->error->error_updateuser_lastname = Error_Create_users_lastname;
            	$error = 1;
            } else if(strlen($lastname) >20) {
            	$this->error->error_updateuser_lastname = Error_name_field;
            	$error = 1;
            }
            
			if($useremail == '') {				//Validation for user email
            	$this->error->error_updateuser_email = Error_Create_users_email_empty;
            	$error = 1;
            } else if(!$this->validate_email_dot_underscore($useremail)) {
            	$params['useremail'] = '';
            	$this->error->error_updateuser_email = Error_Create_users_email;
            	$error = 1;
            } else if(strlen($useremail) >50) {
            	$this->error->error_updateuser_email = Error_email_field;
            	$error = 1;
            }
            
			if($phone == '') {			//Validation for phone number
            	$this->error->error_updateuser_phonenumber = Error_Create_users_phone_empty;
            	$error = 1;
            } else if(!$this->validate_numeric($phone)) {
            	$params['phonenumber'] = '';
            	$this->error->error_updateuser_phonenumber = Error_Create_users_phone;
            	$error = 1;
            } else if(strlen($phone) >10) {
            	$this->error->error_updateuser_phonenumber = Error_phone_field_max;
            	$error = 1;
            } else if(strlen($phone) <10) {
            	$this->error->error_updateuser_phonenumber = Error_phone_field_min;
            	$error = 1;
            }
            
            /*
			if($role == '' || $role == 0 || $role == 'Select') {	//Validation for role
            	$this->error->error_updateuser_role = Error_Create_users_role_empty;
            	$error = 1;
            	$params['role'] = '';
            } else if(!$this->validate_numeric($role)) {
            	$params['role'] = '';
            	$this->error->error_updateuser_role = Error_Create_users_role;
            	$error = 1;
            }
			*/
            
			if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	$error = 1;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }
            
            
            if($error == 1) {
            	$this->error->error_updateuser_values = $params;
            	$error = 0;
            	return false;
            }
            
            /*
             * Validation ends here
             */            
            
		
			$mess = $this->userDetailsupdate($userid, $action, $firstname, $lastname, $useremail, $phone, $role, $this->session->app, $this->session->userid);
			
			$messs = explode('#',$mess[0]['tmess']);
			
			if($messs[0] == 0) {
				$this->error->error = Status_failed_updated . $firstname . ' ' . $lastname ;
				return false; 
			} else {
				$this->session->success = $firstname . ' ' . $lastname . Status_updated;
				return true;
			}
				//}else{
				//$this->session->validateerror= Error_Invalid_user_Id;
				//$this->redirector->gotoSimple('list','user','usermanagement',array());
				//}
			}else{
				$this->session->validateerror= Error_Invalid_user_Id;
				$this->redirector->gotoSimple('list','user','usermanagement',array());	
			}
			
			}else{
				$this->session->validateerror= Error_Invalid_user_Id;
				$this->redirector->gotoSimple('list','user','usermanagement',array());		
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: To update user details
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user performs action in the given idle time out,
     * 					false if user was idle
     */
	public function updatepersonaldetails(Array $params) {
		try{
			
			$userid = $this->session->userid;
			$action = trim($params['action']);
			$firstname = trim($params['firstname']);
			$lastname = trim($params['lastname']);
			$useremail = trim($params['useremail']);
			$phone = trim($params['phonenumber']);
			$role = $this->session->roleid;			
			
						
			/*
			 * Validation for firstname(Alpha numeric), lastname(Alpha Numeric), useremail(Email), phonenumber (Numeric)
			 * 				  username(Email), role(Numeric), action(alpha)
			 */
			$error = 0;
			
			            
            if($firstname == '') {				//Validation for firstname
            	$this->error->error_personalinfo_firstname = Error_Create_users_firstname_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($firstname)) {
            	$params['firstname'] = '';
            	$this->error->error_personalinfo_firstname = Error_Create_users_firstname;
            	$error = 1;
            } else if(strlen($firstname) >20) {
            	$this->error->error_personalinfo_firstname = Error_name_field;
            	$error = 1;
            } else if(strlen($firstname) < 3) {
            	$this->error->error_personalinfo_firstname = Error_name_field_min;
            	$error = 1;
            }
            
			if($lastname == '') {				//Validation for lastname
            	$this->error->error_personalinfo_lastname = Error_Create_users_lastname_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($lastname)) {
            	$params['lastname'] = '';
            	$this->error->error_personalinfo_lastname = Error_Create_users_lastname;
            	$error = 1;
            } else if(strlen($lastname) >20) {
            	$this->error->error_personalinfo_lastname = Error_name_field;
            	$error = 1;
            }
            
			if($useremail == '') {				//Validation for user email
            	$this->error->error_personalinfo_email = Error_Create_users_email_empty;
            	$error = 1;
            } else if(!$this->validate_email_dot_underscore($useremail)) {
            	$params['useremail'] = '';
            	$this->error->error_personalinfo_email = Error_Create_users_email;
            	$error = 1;
            } else if(strlen($useremail) >50) {
            	$this->error->error_personalinfo_email = Error_email_field;
            	$error = 1;
            }
            
			if($phone == '') {			//Validation for phone number
            	$this->error->error_personalinfo_phonenumber = Error_Create_users_phone_empty;
            	$error = 1;
            } else if(!(int) $phone || substr($phone, 0, 1) == 0) {
            	$params['phonenumber'] = '';
            	$this->error->error_personalinfo_phonenumber = Error_Create_users_phone;
            	$error = 1;
            } else if(!$this->validate_numeric($phone)) {
            	$params['phonenumber'] = '';
            	$this->error->error_personalinfo_phonenumber = Error_Create_users_phone;
            	$error = 1;
            } else if(strlen($phone) >10) {
            	$this->error->error_personalinfo_phonenumber = Error_phone_field_max;
            	$error = 1;
            } else if(strlen($phone) <10) {
            	$this->error->error_personalinfo_phonenumber = Error_phone_field_min;
            	$error = 1;
            }
            
            
			if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	$error = 1;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }
            
            
            if($error == 1) {
            	$this->error->error_personalinfo_values = $params;
            	$error = 0;
            	return false;
            }
            
           
            
            /*
             * Validation ends here
             */
			
			$mess = $this->userDetailsupdate($userid, $action, $firstname, $lastname, $useremail, $phone, $role, $this->session->app);
			
			$mess = explode('#',$mess[0]['tmess']);
			if($mess[0] == 0) {
				$this->error->error = Status_failed_updated . $firstname . ' ' . $lastname ;
				return false; 
			} elseif($mess[0] == 2) {
				/*$this->redirector->gotoRoute(array('module'=>'default', 'controller'=> 'error',
   'action' =>'accessdenied'));*/
				$this->redirector->gotoSimple('accessdenied','error','default',array());	
				return false; 
			} else {
				$this->session->success = Status_updated_confirmed;
				return true;
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: To Lock the existing Active user
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function lockuser(Array $params) {
		try{
			$userid = trim($params['userId']);
			$action = trim($params['action']);
			$lock = 1;
			$unlock = 0;
			$delete = 0;
			if($userid!='' && $userid!=0 && $this->validate_numeric($userid)) {
				
				$ress=$this->checkapmuserexists($userid);
				
			if($ress[0]['cnt']>0){
			$mess = $this->changeUserStatus($userid, $action, $this->session->userid, $lock, $unlock, $delete);
			$mess = explode('#',$mess['@omess']);			
			if($mess[0] == 1) {
				$this->session->success = $mess[1] . ' ' . Status_locked; 
			}
				}else{
					$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user','action' =>'list'));*/	
					$this->redirector->gotosimple('list','user','usermanagement',array());
				
				}
			}else{
				$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user','action' =>'list'));*/
				$this->redirector->gotosimple('list','user','usermanagement',array());	
			}
			/*
			 * Commented mail triggering code for user Locked
			 */
			$this->sendmailtemplate($mess[2], $mess[1], User_Mail_Locked);
			
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	

	/**
     * Purpose: To Unlock the existing Locked user
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function unlockuser(Array $params) {
		try{
			$userid = trim($params['userId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 1;
			$delete = 0;
			if($userid!='' && $userid!=0 && $this->validate_numeric($userid)) {
				
				$ress=$this->checkapmuserexists($userid);
				
				if($ress[0]['cnt']>0){
			$mess = $this->changeUserStatus($userid, $action, $this->session->userid, $lock, $unlock, $delete);
			$mess = explode('#',$mess['@omess']);
			if($mess[0] == 1) {
				$this->session->success = $mess[1] . ' ' . Status_unlocked; 
			}
			/*
			 * Commented mail triggering code for user Activated
			 */
			//$this->sendmailtemplate($mess[2], $mess[1], User_Mail_Activated);
				}else{
					$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user',
   'action' =>'list'));	*/
					$this->redirector->gotosimple('list','user','usermanagement',array());
				}
			}else{
				$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user',
   'action' =>'list'));	*/
				$this->redirector->gotosimple('list','user','usermanagement',array());
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: To Delete the existing user
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function deleteuser(Array $params) {
		try{
			$userid = trim($params['userId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 0;
			$delete = 1;
			if($userid!='' && $userid!=0 && $this->validate_numeric($userid)) {
				
				$ress=$this->checkapmuserexists($userid);
				
				if($ress[0]['cnt']>0){
			$mess = $this->changeUserStatus($userid, $action, $this->session->userid, $lock, $unlock, $delete);
			$mess = explode('#',$mess['@omess']);
			if($mess[0] == 1) {
				$this->session->success = $mess[1] . ' ' . Status_deleted; 
			}
				}else{
					$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user','action' =>'list'));*/
					$this->redirector->gotosimple('list','user','usermanagement',array());	
				}
			}else{
				$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user','action' =>'list'));*/
				$this->redirector->gotosimple('list','user','usermanagement',array());	
			}
			/*
			 * Commented mail triggering code for user Deleted
			 */
			$this->sendmailtemplate($mess[2], $mess[1], User_Mail_Deleted);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	

	/**
     * Purpose: To send password or username email
     *
     * Access is to class only
     *
     * @param	varchar	$to Email id of the receiver
     * @param	varchar	$toname Name of the receiver
     * @param	varchar	$templatename Name of the template to be fetched from database
     * @param	varchar	$password Password of the receiver
     * 
     * @return  
     */
	private function sendmailtemplate($to, $toname, $templatename, $password=NULL) {
		try{
			
			/*
			 * Generating password and making email template
			 */
		
			$templates = $this->htmlForPassword($templatename, $this->session->reseller, $this->session->app);	
			$templates = $templates[0];
			$templatename = $templates['emailtemplatename'];
			$templateid = $templates['emailtemplateid'];
			$templatesubject = $templates['emailsubject'];
			$templatefrom = $templates['emailfrom'];
			$templatecontent = $templates['emailcontent'];
			
			$toname = urldecode($toname);
			
			/*
			 * parsing email body
			 */
			if($password != NULL) {
				$content = sprintf($templatecontent, ROOT_PUBLIC_PATH, $toname, $password, ROOT_PUBLIC_PATH);
			} else {
				$content = sprintf($templatecontent, ROOT_PUBLIC_PATH, $toname, ROOT_PUBLIC_PATH);
			}
			
			/*
			 * Send Email
			 * 
			 */
			//$MailEncryptObject=new Application_Model_EncryptDecrypt('',$this->config->mail->params->encryptkey);
			//$MailEncryptObject->Encrypt($apipasskey	);
		 	//$content =base64_encode($MailEncryptObject->EncryptionContent);
			//$content
			$this->mailsend($toname, $templatefrom, $to, $content, $templatesubject);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: To Reset the security question for the existing user
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function resetsecurity(Array $params) {
		try{
				$userid = trim($params['userId']);
				if($userid!='' && $userid!=0 && $this->validate_numeric($userid)) {
				
				$ress=$this->checkapmuserexists($userid);
				
				if($ress[0]['cnt']>0){		
			$userid = trim($params['userId']);
			$action = trim($params['action']);
			
			/*
			 * To reset security question, set $iisupdate = 2
			 */
			$mess = $this->savesecurityquestion('', '', $userid, $action, 2, $this->session->userid);
			
			$mess = explode('#',$mess['@omess']);
			$session=new Zend_Session_Namespace("addmerchant");
			if($mess[0] == 1) {
				$session->success = Success_reset_user_security . ' for ' . $mess[1]; 
			} else {
				$session->success = Failure_reset_user_security;
			}
		}else{
					$this->session->validateerror= Error_Invalid_user_Id;
			/*	$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user',
   'action' =>'list'));	*/
					$this->redirector->gotosimple('list','user','usermanagement',array());
				}
			}else{
				$this->session->validateerror= Error_Invalid_user_Id;
	/*			$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user',
   'action' =>'list'));*/
				$this->redirector->gotosimple('list','user','usermanagement',array());	
			}
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: To Reset password for the existing user
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function resetpassword(Array $params) {
		try{
				$userid = trim($params['userId']);
				if($userid!='' && $userid!=0 && $this->validate_numeric($userid)) {
				
				$ress=$this->checkapmuserexists($userid);
				
				if($ress[0]['cnt']>0){		
			$userid = trim($params['userId']);
			$action = trim($params['action']);
			$details = $this->fetchUserDetails($userid);
			$details = $details[0];
			
			$name = $details['firstname'] . ' ' . $details['lastname'];
			$result = $this->generaterandomforgotpassword($userid, $action,  $this->session->userid, $details['firstname'], $details['lastname'], $details['username']);
			$session=new Zend_Session_Namespace("addmerchant");
			if($result) {
				$session->success = $this->error->error . ' for ' . $name; 
			} else {
				$session->success = Failure_reset_user_password;
			}
			
			}else{
					$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user',
   'action' =>'list'));	*/
					$this->redirector->gotosimple('list','user','usermanagement',array());
				}
			}else{
				$this->session->validateerror= Error_Invalid_user_Id;
				/*$this->redirector->gotoRoute(array('module'=>'usermanagement', 'controller'=> 'user',
   'action' =>'list'));	*/
				$this->redirector->gotosimple('list','user','usermanagement',array());
			}
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: Saves security question and answer
     *
     * Access is public
     *
     * @param	Array	$changepass Array of change security questions form details
     * 
     * @return  boolean	true if user successfully enters the questions and answers,
     * 					false if there is any error
     */
	
	public  function savesecurityquestionanswer(Array $securityqa) {
		try{
			$action = trim($securityqa['action']);
			$securityq1 = trim($securityqa['security1']);
			$answer = strtolower(trim($securityqa['answer']));			
			$retypeanswer = strtolower(trim($securityqa['retypeanswer']));
			$iuserid = $this->session->userid;
			
						
			/*
			 * Validation for firstname(Alpha numeric), lastname(Alpha Numeric), useremail(Email), phonenumber (Numeric)
			 * 				  username(Email), role(Numeric), action(alpha)
			 */
			$error = 0;
			
			            
            if($securityq1 == '') {				//Validation for security question
            	$this->error->error_changesecurity_ques = Error_change_secure_question;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space_apostrophe($securityq1)) {
            	$securityqa['security1'] = '';
            	$this->error->error_changesecurity_ques = Error_change_secure_question_invalid;
            	$error = 1;
            } else if(strlen($securityq1) > 60) {
            	$this->error->error_changesecurity_ques = Error_secques_field;
            	$error = 1;
            } else if(strlen($securityq1) < 1) {
            	$this->error->error_changesecurity_ques = Error_answer_field_min;
            	$error = 1;
            }

			if($answer == '') {				//Validation for answer
            	$this->error->error_changesecurity_answer = Error_forgot_secure_answer_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($answer)) {
            	$securityqa['answer'] = '';
            	$this->error->error_changesecurity_answer = Error_forgot_secure_answer;
            	$error = 1;
            } else if(strlen($answer) > 30) {
            	$this->error->error_changesecurity_answer = Error_answer_field_max;
            	$error = 1;
            } else if(strlen($answer) < 1) {
            	$this->error->error_changesecurity_answer = Error_answer_field_min;
            	$error = 1;
            }
            
			if($retypeanswer == '') {				//Validation for confirm answer
            	$this->error->error_changesecurity_sec = Error_forgot_secure_answer_confirm_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($retypeanswer)) {
            	$securityqa['retypeanswer'] = '';
            	$this->error->error_changesecurity_sec = Error_forgot_secure_reanswer;
            	$error = 1;
            } else if($retypeanswer != $answer) {
            	$this->error->error_changesecurity_sec = Error_forgot_secure_answer_confirm;
            	$error = 1;
            } else if(strlen($retypeanswer) > 30) {
            	$this->error->error_changesecurity_sec = Error_answer_field_max;
            	$error = 1;
            } else if(strlen($retypeanswer) < 1) {
            	$this->error->error_changesecurity_sec = Error_answer_field_min;
            	$error = 1;
            }
            
            
			if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	$error = 1;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            } else if(!$this->requestHandler->isPost()) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }
            
           
            if($error == 1) {
            	$this->error->error_changesecurity_values = $securityqa;
            	$error = 0;
            	return false;
            }
            
            /*
             * Validation ends here
             */
           
			
			if($this->session->securityenabled == 0) {
				$isupdate = 0;
				$this->error->ischange = 0;
			} else {
				$isupdate = 1;
				$this->error->ischange = 1;
			}
			$answer= hash('sha256',$answer);
			$message = $this->savesecurityquestion($securityq1, $answer, $iuserid, $action, $isupdate);
			
			$message = $message['@omess'];
			$var = explode('#', $message);
			$this->error->error = $var[1];
			/*print_r($var);
			echo $this->session->securityenabled;
			exit;*/
			if($var[0] == 0) {
				if($this->session->securityenabled == 0) {
					$this->error->error = Failure_firstlogin1_user_security;
				} else {
					$this->error->error = Failure_updated_user_security;	
				}
				return false;
			} else {
				if($this->session->securityenabled == 0) {
					$this->session->success = Success_firstlogin_user_security;
				} else {
					$this->session->successQues = Success_updated_user_security_confirmed;					
				}
				
				$this->session->securityenabled = 1;
				$this->session->success='';
				return true;
			}
							
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	public function savefirstlogin(Array $params) {
		try{			
			$action 			= trim($params['action']);
			$oldpassword 		= trim($params['oldpwd']);
			$newpassword		= trim($params['newpwd']);
			$confirmpassword 	= trim($params['retypepwd']);
			$securityquestion	= trim($params['squestion']);
			$securityanswer		= trim($params['sanswer']);
			$confirmanswer		= trim($params['retypesans']);
			
			/*
			 * Validation for firstname(Alpha numeric), lastname(Alpha Numeric), useremail(Email), phonenumber (Numeric)
			 * 				  username(Email), role(Numeric), action(alpha)
			 */
			$error = 0;
			
			
			if($oldpassword == '') {				//Validation for old password
            	$this->error->error_firstlogin_old = Error_login_user_temppassword_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric($oldpassword)) {
            	$params['oldpwd'] = '';
            	$this->error->error_firstlogin_old = Error_user_temp_password;
            	$error = 1;
            } else if(strlen($oldpassword) > 16) {
            	$this->error->error_firstlogin_old = Error_password_field_max;
            	$error = 1;
            } else if(strlen($oldpassword) < 8) {
            	$this->error->error_firstlogin_old = Error_password_field_min;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_password($oldpassword)) {
            	$changepass['oldpwd'] = '';
            	$this->error->error_firstlogin_old = Error_user_temp_password;
            	$error = 1;
            }

			if($newpassword == '') {				//Validation for new password
            	$this->error->error_firstlogin_new = Error_login_user_newpassword_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric($newpassword)) {
            	$params['newpwd'] = '';
            	$this->error->error_firstlogin_new = Error_login_user_improper_newpassword;
            	$error = 1;
            } else if(strlen($newpassword) > 16) {
            	$this->error->error_firstlogin_new = Error_password_field_max;
            	$error = 1;
            } else if(strlen($newpassword) < 8) {
            	$this->error->error_firstlogin_new = Error_password_field_min;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_password($newpassword)) {
            	$changepass['newpwd'] = '';
            	$this->error->error_firstlogin_new = Error_login_user_improper_newpassword;
            	$error = 1;
            }
            
			if($confirmpassword == '') {				//Validation for confirm password
            	$this->error->error_firstlogin_conf = Error_login_user_confirmpassword_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric($confirmpassword)) {
            	
				$params['retypepwd'] = '';
            	$this->error->error_firstlogin_conf = Error_login_user_improper_renewpassword;
            	$error = 1;
            } else if($confirmpassword != $newpassword) {
            	$this->error->error_firstlogin_conf = Error_login_user_unmatchpass;
            	$error = 1;
            } else if(strlen($confirmpassword) > 16) {
            	$this->error->error_firstlogin_conf = Error_password_field_max;
            	$error = 1;
            } else if(strlen($confirmpassword) < 8) {
            	$this->error->error_firstlogin_conf = Error_password_field_min;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_password($confirmpassword)) {
            	$changepass['retypepwd'] = '';
            	$this->error->error_firstlogin_conf = Error_login_user_improper_renewpassword;
            	$error = 1;
            }
                        
            if($securityquestion == '') {				//Validation for security question
            	$this->error->error_firstlogin_ques = Error_change_secure_question;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space_apostrophe($securityquestion)) {
            	
				$params['squestion'] = '';			
            	$this->error->error_firstlogin_ques = Error_change_secure_question_invalid;
            	$error = 1;
            } else if(strlen($securityquestion) > 60) {
            	$this->error->error_firstlogin_ques = Error_secques_field;
            	$error = 1;
            } else if(strlen($securityquestion) < 1) {
            	$this->error->error_firstlogin_ques = Error_answer_field_min;
            	$error = 1;
            }

			if($securityanswer == '') {				//Validation for answer
            	$this->error->error_firstlogin_answer = Error_forgot_secure_answer_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($securityanswer)) {
            	$params['sanswer'] = '';			
            	$this->error->error_firstlogin_answer = Error_forgot_secure_answer;
            	$error = 1;
            } else if(strlen($securityanswer) > 30) {
            	$this->error->error_firstlogin_answer = Error_answer_field_max;
            	$error = 1;
            } else if(strlen($securityanswer) < 1) {
            	$this->error->error_firstlogin_answer = Error_answer_field_min;
            	$error = 1;
            }
            
			if($confirmanswer == '') {				//Validation for confirm answer
            	$this->error->error_firstlogin_sec = Error_forgot_secure_answer_confirm_empty;
            	$error = 1;
            } else if(!$this->validate_alphanumeric_space($confirmanswer)) {
            	$params['retypesans'] = '';
            	$this->error->error_firstlogin_sec = Error_forgot_secure_reanswer;
            	$error = 1;
            } else if($confirmanswer != $securityanswer) {
            	$this->error->error_firstlogin_sec = Error_forgot_secure_answer_confirm;
            	$error = 1;            	
            } else if(strlen($confirmanswer) > 30) {
            	$this->error->error_firstlogin_sec = Error_answer_field_max;
            	$error = 1;
            } else if(strlen($confirmanswer) < 1) {
            	$this->error->error_firstlogin_sec = Error_answer_field_min;
            	$error = 1;
            }
            
            
			if($action == '') {			//Validation for action name
				$this->error->error = Invalid_URL_Found;
            	$error = 1;
            } else if(!$this->validate_alpha($action)) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            } else if(!$this->requestHandler->isPost()) {
            	$this->error->error = Invalid_URL_Found;
            	$error = 1;
            }
            
           
            if($error == 1) {
            	$this->error->error_firstlogin_values = $params;
            	$error = 0;
            	return false;
            }
            
            /*
             * Validation ends here
             */
            
            
			$reusepassword = $this->config->user->reusepassword;
			$iuserid = $this->session->userid;
			
			if($this->session->firstlogin == 1) {
				$firstlogin = 2;
			} else {
				$firstlogin = 0;
			}
			$errorsession = new Zend_Session_Namespace("addmerchant");
			//$oldpassword=hash('sha256',$oldpassword);
			//$newpassword=hash('sha256',$newpassword);
			$message = $this->savechangedpassword($iuserid, $oldpassword, $newpassword,$action, $firstlogin, $reusepassword);
			
			$message = $message['@omess'];
			$var = explode('#', $message);
			$this->error->error = $var[1];
			if($var[0] == 0) {				
				$this->error->error = Failure_firstlogin_user_password;	
				return false;
			} else if($var[0] == 2) {				
				$this->error->error = Error_user_repeat_password;	
				return false;
			}  else if($var[0] == 3) {				
				$this->error->error = Error_user_temp_password;	
				return false;
			} else if($var[0] == 4) {				
				$this->error->error = Error_login_user_userchangedpassword;	
				return false;
			} else {
				if($this->session->firstlogin == 1) {
					$this->session->firstlogin = 0;
				}
				/*
				 * This is Working for 
				 * Forgot password and First login
				 * 
				 * If $firstlogin == 2 it is First Login
				 */				
				//$this->sendmail(urldecode($this->session->useremail), urldecode($this->session->username), $newpassword);
				
				/*$action = trim($securityqa['action']);
				$securityquestion	= trim($params['squestion']);
				$securityanswer		= trim($params['sanswer']);
				$confirmanswer		= trim($params['retypesans']);*/
			
				if($this->session->securityenabled == 0) {
					$isupdate = 0;
				} else {
					$isupdate = 1;
				}
				$answer=strtolower($securityanswer);
				$securityanswer=hash('sha256',$answer);
				$message = $this->savesecurityquestion($securityquestion, strtolower($securityanswer), $iuserid, $action, $isupdate);
				
				//$message = $this->savesecurityquestion($securityq1,$securityq2, $securityans1, $securityans2, $iuserid, $action, $isupdate);
				
				$message = $message['@omess'];
				$var = explode('#', $message);
				$this->error->error = $var[1];
				
				if($var[0] == 0) {
					$this->error->error = Success_firstlogin_user_password . ' and ' . Failure_firstlogin_user_security;					
					return false;
				} else {
					$this->session->securityenabled = 1;
					$errorsession->success = Success_firstlogin_user_password_question;					
					return true;
				}
				
			}
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetches all the users except the present loggedin user
     *
     * Access is public
     *
     * @param	Array	$params Create user parameters
     * 
     * @return  
     */
	
	public  function getUsersSearchValidation(Array $params) {
		try{
			$error = 0;
			$message = '';			
			
			//print_r($params);exit;
			if(isset($params['username']) && trim($params['username']) != '') {
				
				if(!$this->validate_email_dot_underscore(trim($params['username']))) {
					$error = 1;
					$message = 'Username ';
					$params['username'] = '';
				}
				$this->error->usermanagementsearchfields = $params;
			}
			
			if(isset($params['firstname']) && trim($params['firstname']) != '') {
				if(!$this->validate_alphanumeric_space(trim($params['firstname']))) {
					if($error == 1) {
					 	$message .= ', ';
					}
					$message .= 'First Name ';
					$error = 1;
					$params['firstname'] = '';
				}
				$this->error->usermanagementsearchfields = $params;
			} 
			
			if(isset($params['lastname']) && trim($params['lastname']) != '') {
				if(!$this->validate_alphanumeric_space(trim($params['lastname']))) {
					if($error == 1) {
					 	$message .= ', ';
					}
					$message .= 'Last Name ';
					$error = 1;
					$params['lastname'] = '';
				}
				$this->error->usermanagementsearchfields = $params;
			}
			
			if(isset($params['userType']) && trim($params['userType']) != '') {
				$usertypes=$this->getUsertypes();
				$all=array("usertype" => "ALL", "usertypeid" => '', "role" => "ALL", "priority" => "1", "roleid" => '');
				array_push($usertypes,$all);
				/*exit;*/
				//echo count(search($usertypes, 'roleid',$params['userType']));
				
				if(!$this->validate_digits(trim($params['userType']))) {
					if($error == 1) {
					 	$message .= ', ';
					}
					$message .= 'Role';
					$error = 1;
					$params['userType'] = '';
				}/*else if(count(search($usertypes, 'roleid',$params['roleid'])) == 0){
					if($error == 1) {
					 	$message .= ', ';
					}
					$message .= 'Role';
					$error = 1;
					$params['userType'] = '';
				}*/
				$this->error->usermanagementsearchfields = $params;
			}
			
			if($error == 1) {
				$this->error->error = 'Please fill proper data in ' . $message . ' Fields';
				$error = 0;
				//$this->error->users_total_count = 0;
				$this->error->usermanagementsearchfields = $params;
				return false; 
			}
			
			
			return true;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: Fetches all the users except the present loggedin user
     *
     * Access is public
     *
     * @param	Array	$params Create user parameters
     * 
     * @return  
     */
	
	public  function getUsersSearch(Array $params) {
		try{
			
			$cond = '';	
			$usersearch=array();
			$usersearch['start']=0;
			$this->error->searchcondition='';
			if(isset($params['start']) && $params['start'] != '') {
				$start = $params['start'];
				
			} else {
				$start = 0;
			}
			
			if(isset($params['username']) && trim($params['username']) != '') {
				$cond .= trim($params['username']) . '##';
				$this->error->searchcondition .= "username/".$params['username']."/";
				$usersearch['username']=$params['username'];
			} else {
				$cond .= '0##';
			}
			//echo "sdsadsfirstname".$params['firstname'];
			if(isset($params['firstname']) && trim($params['firstname']) != '') {
				$cond .= trim($params['firstname']) . '##';
				$this->error->searchcondition .= "firstname/".$params['firstname']."/";
					$usersearch['firstname']=$params['firstname'];
			} else {
				
				$cond .= '0##';
			}
			
			if(isset($params['lastname']) && trim($params['lastname']) != '') {
				$cond .= trim($params['lastname']) . '##';
				$this->error->searchcondition .= "lastname/".$params['lastname']."/";
				$usersearch['lastname']=$params['lastname'];
			} else {
				$cond .= '0##';
			}
			
			if(isset($params['userType']) && trim($params['userType']) != '') {
				$cond .= trim($params['userType']);
				$this->error->searchcondition .= "userType/".$params['userType']."/";
				$usersearch['userType']=$params['userType'];
			} else {
				$cond .= '0';
			}
			
			$controller = Zend_Controller_Front::getInstance();
			$request=$controller->getRequest();
			//if(!$request->getPost() && !isset($params['start'])) {
			//if(!isset($params['start'])) {
				$this->error->cond = $cond;
			//}
			
			
			$iLimit = $this->config->user->displaylimit;
			//$iLimit = 1;
			$iStart = $start;
			//exit;
	/*	echo 	$this->error->$cond=$cond;
		echo 	$cond = $this->error->cond;
		exit;*/ 
			if(isset($params['searchsubmit'])) {
				$this->error->cond = $cond;
				$cond = $this->error->cond; 
			} elseif($this->error->cond == '') {
				$this->error->cond = '0##0##0##0##0';
			}
			
			
				$count = $this->getUsercount($this->session->usertypeid, $this->error->cond, $this->session->userid);
				//echo $count;
				//exit;
		if(trim($iStart) != '') {
				if(!$this->validate_digits($iStart)) {
					$this->session->validateerror=Error_Invalid_pagestart;
					$this->redirector->gotoSimple('list','user','usermanagement',$usersearch);
					//$this->redirector->gotoSimple(array('module'=>'usermanagement', 'controller'=> 'user', 'action' =>'list'));	
				}else if(($iStart%$this->config->user->displaylimit) <> 0){
					$this->session->validateerror=Error_Invalid_pagestart;
					//exit;
					//unset($this->error);
					$this->redirector->gotoSimple('list','user','usermanagement',$usersearch);
				}else if($count!=0 && $iStart >= $count ){
					
					$this->session->validateerror=Error_Invalid_pagestart;
			
					//unset($this->error);
			 $this->redirector->gotoSimple('list','user','usermanagement',$usersearch);
				//	$this->redirector->gotoSimple(array('module'=>'usermanagement', 'controller'=> 'user', 'action' =>'list'));
				}else if($count==0 && $iStart != 0 ){
					
					$this->session->validateerror=Error_Invalid_pagestart;
			
					//unset($this->error);
			 $this->redirector->gotoSimple('list','user','usermanagement',$usersearch);
				//	$this->redirector->gotoSimple(array('module'=>'usermanagement', 'controller'=> 'user', 'action' =>'list'));
			}
			}	
			else{
					$this->session->validateerror=Error_Invalid_pagestart;
					$this->redirector->gotoSimple('list','user','usermanagement',$usersearch);
					//$this->redirector->gotoSimple(array('module'=>'usermanagement', 'controller'=> 'user', 'action' =>'list'));
			}
			/*echo $this->error->cond;
			exit;*/
			if($this->error->cond != '') {
			//echo "sadsad23";	
			//exit;	
			//$count = $this->getUsercount($this->session->usertypeid, $this->error->cond, $this->session->userid);
		//	echo $this->error->cond;
			
				$opt = $this->getUserList($this->session->userid, $iStart, $iLimit, $this->error->cond);
			/*	print_r($opt);
				exit;*/
			} else {
					$count = $this->getUsercount($this->session->usertypeid, $cond, $this->session->userid);
			
			
				$opt = $this->getUserList($this->session->userid, $iStart, $iLimit, $cond);
			}
			//print_r($opt);
				//exit;
			$this->error->users_total_count = (int)$count;			
			$this->error->iStart = $iStart;
			$this->error->iLimit = $iLimit;
			$this->error->users= $opt;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
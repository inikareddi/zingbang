<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Userdb.php 
* Module	:	User Management Module
* Owner		:	RAM's 
* Purpose	:	This class is used for user management related database operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Userdb extends Application_Model_DataBaseOperations {
	
	public $session;
	private $error;
	
	/**
     * Purpose: Constructor sets sessions for portal and portalerror
     *
     * Access is limited to class and extended classes
     *
     * @param   
     * @return  
     */
	
		
	public function __construct(){
		$this->session = new Zend_Session_Namespace('MyPortal');
		$this->error = new Zend_Session_Namespace('MyPortalerror');
	}
	
	
		/**
     * Purpose: Constructor sets sessions for portal and portalerror
     *
     * Access is limited to class and extended classes
     *
     * @param varchar	$iusername Username
     * @param varchar	$ipassword Password to login
     * @param varchar	$iaction Action name
     * @param varchar	$icontroller Controller name
     * @param varchar	$imodule Module name
     * @param int		$imaxattempts Maximum number of attempts  
     * 
     * @return  
     */
	
	
	protected function checkapmuserexists($userid){
		try {
			parent::SetDatabaseConnection();
			$query = "call SPcheckapmuserexists('" . $userid . "')";
			//exit;
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: Constructor sets sessions for portal and portalerror
     *
     * Access is limited to class and extended classes
     *
     * @param varchar	$iusername Username
     * @param varchar	$ipassword Password to login
     * @param varchar	$iaction Action name
     * @param varchar	$icontroller Controller name
     * @param varchar	$imodule Module name
     * @param int		$imaxattempts Maximum number of attempts  
     * 
     * @return  
     */
	
	
	protected function checkUser($iusername, $ipassword, $iaction, $icontroller, $imodule, $imaxattempts){
		try {
			parent::SetDatabaseConnection();
			//$ipassword = hash('sha256',$ipassword);
			$query = "call SPapmcheckuser('" . $iusername . "', '" . $ipassword . "', '" . $iaction . "', '" . $icontroller . "', '" . $imodule . "', " . $imaxattempts . ", NULL)";
			//exit;
			//print_r(Application_Model_Db::getResult($query));
			//exit;
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetches details of specific user and returns the result set
     *
     * Access is limited to class and extended classes
     *
     * @param   int $iuserid Userid of the registered user
     * @return  object reseult set
     */
	protected function fetchUserDetails($iuserid){
		try {
			parent::SetDatabaseConnection();
			$query = "call SPapmgetuserdetails(" . $iuserid . ")";
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Checks the user existance in the database and returns the result set
     *
     * Access is limited to class and extended classes
     *
     * @param   varchar $iusername Username of the user
     * @param	varchar $iuseraction Useraction name
     * @return  object reseult set
     */
	
	protected function userExistance($iusername, $iuseraction){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPapmcheckuserexistance('" . $iusername . "', '" . $iuseraction . "')";
			//exit;
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetches usertypes and roles and assigns those values to view 
     *
     * Access is public
     *
     * @param   
     * @return  
     */
	
	public function getUsertypes(){
		try {
			parent::SetDatabaseConnection();
			$query = "call SPapmgetusertypesroles()";//exit;
			$opt = Application_Model_Db::getResult($query);
			
			$viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
			$viewRenderer->initView();
			$viewObject = $viewRenderer->view;
			
			$viewObject->usertyperoles= $opt;
			return $opt;
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Creates user and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *
     * @param   varchar $ifirstname First name
     * @param   varchar $ilastname Last name
     * @param	int 	$iusertype User type id
     * @param	varchar	$iemailid Email id
     * @param	int 	$irole Role id
     * @param	int		$istatus Status Id
     * @param	int		$icreator User Creator Id
     * @param	varchar $icreatoraction User saving action
     * @param	boolean	$iupdate Flag for updation of user records
     * @return  object	Returns status message.	
     */
	protected function saveUser($firstname, $lastname, $useremail, $phonenumber, $username, $role, $merchant_id, $password, $action, $adminid){
		try {
			parent::SetDatabaseConnection();
			$password = hash('sha256',$password);
			$query = "call SPapmcreateuser('" . $firstname . "', '" . $lastname . "', '" . $useremail . "', '" . $password . "', '" . $username . "', " . $phonenumber . "," . $role . ", '".$merchant_id."', '" . $action . "', " . $adminid . ")";
			//exit;
			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetching user list except existing user name and returns array of list of users 
     *
     * Access is limited to class and extended classes
     *
     * @param   int		$iuserid User Id
     * @param	int		$istart Start value
     * @param	int		$ilimit Limit value for fetching result set
     * @param	varchar	$cond Search condition
     * @return  object	Returns status message.	
     */
	
	protected function getUserList($iuserid, $istart, $ilimit, $cond){
		try {
			parent::SetDatabaseConnection();
			$listCond = explode('##', $cond);
			//SPapmgetusers(userid,start,limit,username,firstname,lastname,roleid);
			$query = "call SPapmgetusers(" . $iuserid . ", " . $istart . ", " . $ilimit . ", '" . $listCond[0] . "', '" . $listCond[1] . "', '" . $listCond[2] . "', " . $listCond[3] . ")";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Get total count of registered users 
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$usertypeid User type id of the logged in user
     * @param	varchar	$cond Search condition
     * @param	int		$iuserid Present logged in userid
     * @return  object 	user details of supplied userid.	
     */
	
	protected function getUsercount($usertypeid, $cond, $iuserid){
		try {
			parent::SetDatabaseConnection();
			$listCond = explode('##', $cond);
			$query = "call SPapmcountofusers('" . $listCond[0] . "', '" . $listCond[1] . "', '" . $listCond[2] . "', " . $listCond[3] . ", " . $iuserid . ")";
			//exit;
			return Application_Model_Db::getValue($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetching user details of the given user id 
     *
     * Access is limited to class and extended classes
     *
     * @param   int		$iuserid User Id
     * @return  object 	user details of supplied userid.	
     */
	
	protected function getUserdetails($iuserid){
		try {
			parent::SetDatabaseConnection();
			
			$query = "call SPapmgetuserdetails(" . $iuserid . ")";
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: sending mail using zend mail feature 
     *
     * Access is limited to class and extended classes
     *
     * @param   varchar	$to Email id of the Recipient
     * @param	varchar	$name Name of the Recipient
     * @param	varchar	$from Email id of the sender
     * @param	varchar	$text Email body
     * @param	varchar	$subject Email Subject
     *
     * @return  boolean	Email sending status.	
     */
	
	public function mailsend($name, $from, $to, $text, $subject,$ispassowrd){
		try {
			
			//call SPapmaddemail (Appname,From, To, Subject,HTMLbody);
			parent::SetDatabaseConnection();
			
			//$query = "call SPapmaddemail('" . $from . "', '". $to . "', '". $subject . "', '". $text ."', '',$ispassowrd)";
			$query = "call SPapmaddemail('" . $from . "', '". $to . "', '". $subject . "', '". $text ."', '".$ispassowrd."')";
			//exit;
			
			return Application_Model_Db::getResult($query);
				
		}
		catch (Exception $e)
		{
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}

	}
	
	/**
     * Purpose: Replaces required data in the template and returns HTML text 
     *
     * Access is limited to class and extended classes
     *
     * @param	varchar	$templatetype Template name 
     * @return  varchar	HTML body of the email.	
     */
	
	protected function 	htmlForPassword($templatetype,$reseller, $appname) {
		try{
			return $this->fetchemailtemplate($templatetype,$reseller, $appname);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
		
	}
	
	/**
     * Purpose: Generates a random password for supplied length and returns password string 
     *
     * Access is limited to class
     *
     * @param	int		$length Length of the password
     * @return  varchar	Password.
     */
	
	private function generatePassword($length=9) {
		try{
			$vowels = 'aeuy';
			$consonants = 'bdghjmnpqrstvzasdfckfurldoesi';
			$caps = 'BHYEIODKJSULWQZPASJDHFURIOPEPKLFJEUFLKDJ';
			$numerics = '23456789123456879';
			$specialChars = '!*@_#$';//! @ # $ * _ 
		 
			$password = '';
			$alt = time() % 5;
			for ($i = 0; $i < $length; $i++) {
				if ($alt == 4) {
					$password .= $consonants[(rand() % strlen($consonants))];
					$alt = 2;
				} else if ($alt == 3)  {
					$password .= $caps[(rand() % strlen($caps))];
					$alt = 3;
				}else if ($alt == 2) {
					$password .= $numerics[(rand() % strlen($numerics))];
					$alt = 0;
				}else if ($alt == 1) {
					$password .= $specialChars[(rand() % strlen($specialChars))];
					$alt = 4;
				} else {
					$password .= $vowels[(rand() % strlen($vowels))];
					$alt = 1;
				}
			}
			return $password;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}		
	}
		
	/**
     * Purpose: Fetches security questions and returns an object of result set 
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$userid Default NULL
     * 							If userid is not NULL, fetches security questions of the specific user
     * 							If userid is NULL, fetches all the security questions
     * 				
     * @return  object	Returns result set object.
     */
	
	protected function getsecurityquestions($userid=NULL){
		try {
			parent::SetDatabaseConnection();
			if(!is_null($userid)) {
				$query = "call SPapmfetchsecurityquestions(" . $userid . ")";
			} else {
				$query = "call SPapmfetchsecurityquestions(NULL)";
			}
			
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}	
	}
	
	/**
     * Purpose: Saves changed password of the user and returns an object of status
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$iuserid User for whom the password need to change
     * @param	varchar	$ioldpass Present password of the user
     * @param	varchar	$inewpass Newpassword of the user
     * @param	varchar	$iaction Action name which changes the password
     * @param	int		$flagupdater Flag for change password or Forgot password or First Login or Admin reset
     * @return  object	Returns an object of status.
     */
	
	protected function savechangedpassword($iuserid, $ioldpass, $inewpass, $iaction, $flagupdater, $reusepasswordlimit, $adminsid=NULL) {
		try{
			parent::SetDatabaseConnection();
			if($flagupdater == 0) {
				//For Change Password
				$flag = 0;
				$adminreset = 0;
				$adminid = 0;
			} else if($flagupdater == 1) {
				//For set Forgot Password
				$flag = 1;
				$adminreset = 1;
				$adminid = 0;
			} else if($flagupdater == 2) {
				//For reset Forgot Password and First login
				$flag = 0;
				$adminreset = 1;
				$adminid = 0;
			} else if($flagupdater == 3) {
				//For Admin reset
				$flag = 1;
				$adminreset = 2;
				$adminid = $adminsid;
			}
			//$ioldpass = hash('sha256',$ioldpass);
			//$inewpass = hash('sha256',$inewpass);
			
			$query = "call SPapmchangepassword(" . $iuserid . ", '" . $ioldpass .  "', '" . $inewpass .  "', " . $flag . ", " . $adminreset . ", " . $reusepasswordlimit . ", '" . $iaction .  "'," . $adminid . ", @omess)";
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Saves security questions for a user and returns an object of status
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$ifquestionid First question Id
     * @param	int		$isquestionid Second question Id
     * @param	varchar	$ifqa First security question answer
     * @param	varchar	$isqa Second security question answer
     * @param	int		$iuserid User id 
     * @param	varchar	$iaction Action name
     * @param	int		$iisupdate Flag for security question insertion or updation
     * 
     * @return  object	Returns an object of status.
     */
	
	protected function savesecurityqa($ifquestionid,$isquestionid, $ifqa, $isqa, $iuserid, $iaction, $iisupdate) {
		try{
			parent::SetDatabaseConnection();
			$query = "call SPapmsavesecurityqa(" . $ifquestionid . ", " . $isquestionid .  ", '" . $ifqa  .  "', '" . $isqa . "', " . $iuserid . ", '" . $iaction . "', " . $iisupdate .  ", @omess)";
			
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Checks security for a user and returns an object of status
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$securityq1 Security question id
     * @param	varchar	$answer Answer for the security question
     * @param	int		$iuserid User id 
     * @param	varchar	$action Action name
     * @param	int		$noofwrongsecurity Number of wrong security question attempts
     * @param	int		$iforgot Forgot password flag
     * 
     * @return  object	Returns an object of status.
     */
	
	protected function checksecurityqa($securityq1, $answer, $iuserid, $action, $noofwrongsecurity, $iforgot) {
		try{
			parent::SetDatabaseConnection();
			$query = "call SPapmchecksecurityqa('". $action . "',". $iuserid . "," . $securityq1 . ",'". hash('sha256',$answer) . "'," . $noofwrongsecurity . ", " . $iforgot . ", @omess)";
			//exit;
			
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetches Email template from databsase and returns template details
     *
     * Access is limited to class
     *
     * @param	varchar	$templatename Name of the email template
     * 
     * @return  object	Returns an object of email template details.
     */
	
	public function fetchemailtemplate($templatename,$networkname,$appname) {
		try{
			parent::SetDatabaseConnection();
			$query = "call SPapmfetchemailtemplate('". $templatename . "','".$networkname."','".$appname."')";
			return Application_Model_Db::getResult($query);
		 	
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: Used to change the user status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	user details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	protected function changeUserStatus($iuserid, $iaction, $iadminuserid, $ilockstatus=0, $iunlockstatus=0, $ideletestatus=0){
		try {
			parent::SetDatabaseConnection();			
			
			/*
			 *  To Lock the user, $ilockstatus must be set to 1
			 *  
			 *  To Unlock the user, $iunlockstatus must be set to 1
			 *  
			 *  To Delete the user, $ideletestatus must be set to 1
			 */
			
			$query = "call SPapmchangeuserstatus(" . $iuserid . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
			
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	

	/**
     * Purpose: Saves security question for a user and returns an object of status
     *
     * Access is limited to class and extended classes
     *
     * @param	vracahr	$iquestion Security question     
     * @param	varchar	$ianswer Answer
     * @param	int		$iuserid User id 
     * @param	varchar	$iaction Action name
     * @param	int		$iisupdate Flag for security question insertion or updation or admin reset
     * 								0 - for insertion
     * 								1 - for updation
     * 								2 - Admin reset
     * @param	int		$iadminid Administrator id for admin reset
     * 
     * @return  object	Returns an object of status.
     */
	 
	protected function savesecurityquestion($iquestion, $ianswer, $iuserid, $iaction, $iisupdate, $iadminid=0) {
		try{
			parent::SetDatabaseConnection();
			$query = "call SPapmsavesecurityqueston('" . addslashes($iquestion) . "', '" . $ianswer .  "', " . $iuserid . ", '" . $iaction . "', " . $iisupdate .  ", " . $iadminid . ", @omess)";
			
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

	/**
     * Purpose: Update user details
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$userid userid     
     * @param	varchar	$action Action name
     * @param	varchar	$firstname First name of the user 
     * @param	varchar	$lastname Last name of the user
     * @param	varchar	$useremail Email of the user
     * @param	int		$phonenumber Phonenumber of the user
     * @param	int		$role Role id of the user
     * @param	varchar	$app App name of the user
     * @param	int		$admin Administrator id
     * 
     * @return  object	Returns an object of status.
     */
	 
	protected function userDetailsupdate($userid, $action, $firstname, $lastname, $useremail, $phonenumber, $role, $app, $admin=0) {
		try{
			
			parent::SetDatabaseConnection();
			$query = "call SPapmupdateuserdetails(" . $userid . ", '" . $firstname .  "', '" . $lastname . "', '" . $useremail . "'," . $phonenumber . ", '" . $role .  "', '" . $app . "', '" . $action . "', " . $admin . ")";
			//exit;
			
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetch all the roles listed in the database and returns result set
     *
     * Access is public
     *
     * @param   
     * @return  object Result set object 
     */
	
	public static function getDefinedRolePrivileges() {
		try {
			self::SetDatabaseConnection();		
			$query = "call SPapmgetrolprivileges()";
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetch all the controllers listed in the database based on module and returns result set
     *
     * Access is public
     *
     * @param   int		$moduleid ModuleId
     * @return  object Result set object 
     */
	
	public static function getDefinedControllers($moduleid) {
		try {
			self::SetDatabaseConnection();		
			$query = "call SPapmgetcontrollers(" . $moduleid . ")";
			return Application_Model_Db::getResult($query);                        
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	/**
     * Purpose: Fetch all the actions listed in the database based on controllers and returns result set
     *
     * Access is public
     *
     * @param   int		$controllerid Controller id
     * @return  object Result set object 
     */
	
	public static function getDefinedActions($controllerid) {
		try {
			self::SetDatabaseConnection();		
			$query = "call SPapmgetactions(" . $controllerid . ")";
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	

	/**
     * Purpose: Fetch all the roles listed in the database and returns result set
     *
     * Access is public
     *
     * @param   
     * @return  object Result set object 
     */
	
	public static function getDefinedRoles() {
		try {     
			self::SetDatabaseConnection();		
			$query = "call SPapmgetusertypesroles()";
			return Application_Model_Db::getResult($query);                        
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	

	/**
     * Purpose: Returns active role name
     *
     * Access is public
     *
     * @param   
     * @return  string	Active session name 
     */
	
	public static function getActiveSession() {
		try {
			$session = new Zend_Session_Namespace('MyPortal');
			
				if($session->loggedIn == 1) {
					
					$ret['role'] = $session->role; 
				} else {
					$config = Zend_Registry::get('config');
					$ret['role'] = $config->user->default->role;
                                }
			
			return $ret;
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Fetching active merchants list
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getActiveMerchantsList(){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPmerchantslistactive()";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
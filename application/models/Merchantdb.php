<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Merchantdb.php 
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

class Application_Model_Merchantdb extends Application_Model_DataBaseOperations {
	
	public $session;
	private $error;
	public $viewobj;
	
	
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
	
	public function getMerchantList($istart,$ilimit,$imerchant_title,$imerchant_email,$imerchant_mobile){
		try {
			parent::SetDatabaseConnection();			
			//SPapmgetusers(userid,start,limit,username,firstname,lastname,roleid);
			$query = "call SPmerchantslist(" . $istart . ", " . $ilimit . ", '', '', '')";
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
	
	public function getMerchantCount($imerchant_title,$imerchant_email,$imerchant_mobile){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPmerchantscount('','','')";
			//exit;
			return Application_Model_Db::getValue($query);
			
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
     * @return  object	Returns status message.	
     */
	public function saveMerchant($merchant_title,$merchant_email,$merchant_mobile,$merchant_phone,$merchant_fax,$merchant_city,$merchant_state,$merchant_country,$merchant_address1,$merchant_address2,$merchant_postcode,$merchant_description, $action, $adminid){
		try {
			parent::SetDatabaseConnection();
			
			$query = "call SPmerchantadd('" . $merchant_title . "', '" . $merchant_email . "', '" . $merchant_mobile . "', '" . $merchant_phone . "', '" . $merchant_fax . "', '" . $merchant_city . "', '" . $merchant_state . "', '" . $merchant_country . "', '" . $merchant_address1 . "', '" . $merchant_address2 . "', '" . $merchant_postcode . "', '" . $merchant_description . "', '" .  $action . "', '" .  $adminid . "')";
			//exit;
			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Returns all countries list 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Countries List.	
     */
	public function getCountriesList(){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPgetcountries()";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Used to change the merchant status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	merchant details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	public function changeStatus($merchantid, $iaction, $iadminuserid, $ilockstatus=0, $iunlockstatus=0, $ideletestatus=0){
		try {
			parent::SetDatabaseConnection();			
			
			/*
			 *  To Lock the user, $ilockstatus must be set to 1
			 *  
			 *  To Unlock the user, $iunlockstatus must be set to 1
			 *  
			 *  To Delete the user, $ideletestatus must be set to 1
			 */
			
			$query = "call SPmerchantchangestatus(" . $merchantid . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
			//exit;
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	/**
     * Purpose: Fetching merchant info
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getMerchatDetails($merchant_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPmerchantdetails('".$merchant_id."')";
			//exit;
			return Application_Model_Db::getRow($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Update merchant details
     *
     * Access is limited to class and extended classes
     *
     * @return  object	Returns an object of status.
     */
	 
	public function merchantDetailsUpdate($merchantId, $action, $merchant_title, $merchant_email, $merchant_mobile, $merchant_phone, $merchant_fax, $merchant_city, $merchant_state, $merchant_country, $merchant_address1, $merchant_address2, $merchant_postcode, $merchant_description, $adminid) {
		try{
			
			parent::SetDatabaseConnection();
			$query = "call SPmerchantedit(" . $merchantId . ", '" . $merchant_title .  "', '" . $merchant_email . "', '" . $merchant_mobile . "','" . $merchant_phone . "','" . $merchant_fax . "','" . $merchant_city . "','" . $merchant_state . "','" . $merchant_country . "','" . $merchant_address1 . "','" . $merchant_address2 . "','" . $merchant_postcode . "','" . $merchant_description . "', '" . $action .  "', " . $adminid . ")";
			//exit;
			
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates Category and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function updateLogoRecord($merchant_id, $filename, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPmerchantaddimage('" . $merchant_id . "', '" . $filename . "', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Fetching category images
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getMerchantImages($merchant_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPmerchantdetailsimages('".$merchant_id."')";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Used to change the merchant image status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	user details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	public function changeStatusToDelete($merchant_id, $merchant_image_id, $action, $iadminuserid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPmerchantdeleteimage(" . $merchant_id . ", " . $merchant_image_id . ", '" . $action . "', " . $iadminuserid . ")";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
}
?>
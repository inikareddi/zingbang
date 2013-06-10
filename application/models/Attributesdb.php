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

//class Application_Model_Attributesdb extends Application_Model_DataBaseOperations {
class Application_Model_Attributesdb extends Application_Model_Validation {
	
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
     * Purpose: Creates Attribute and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function saveAttribute($attribute_title, $attribute_field_type, $attribute_data_type, $attribute_values, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPattributeadd('" . $attribute_title . "', '" . $attribute_field_type . "', '" . $attribute_data_type . "', '" . $attribute_values . "', '" . $action . "', " . $adminid . ")";
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
     * @param	int		$istart Start value
     * @param	int		$ilimit Limit value for fetching result set
     * @param	varchar	$cond Search condition
     * @return  object	Returns status message.	
     */
	
	public function getAttributeList($iattribute_title, $istart, $ilimit){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributelist('" . $iattribute_title . "', " . $istart . ", " . $ilimit . ")";
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
     * @param	varchar	$cond Search condition
     * @param	int		$iuserid Present logged in userid
     * @return  object 	user details of supplied userid.	
     */
	
	public function getAttributeCount($iattribute_title){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPattributecount('" . $iattribute_title . "')";
			//exit;
			return Application_Model_Db::getValue($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}






	/**
     * Purpose: Used to change the attribute status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	user details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	public function changeStatus($attributeId, $iaction, $iadminuserid, $ilockstatus=0, $iunlockstatus=0, $ideletestatus=0){
		try {
			parent::SetDatabaseConnection();			
			
			/*
			 *  To Lock the user, $ilockstatus must be set to 1
			 *  
			 *  To Unlock the user, $iunlockstatus must be set to 1
			 *  
			 *  To Delete the user, $ideletestatus must be set to 1
			 */
			
			$query = "call SPattributechangestatus(" . $attributeId . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
			//exit;
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}







	/**
     * Purpose: Fetching attribute info
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getAttributeDetails($attribute_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributedetails('".$attribute_id."')";
			//exit;
			return Application_Model_Db::getRow($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}





	/**
     * Purpose: Update attribute details
     *
     * Access is limited to class and extended classes
     *
     * @return  object	Returns an object of status.
     */
	 
	public function attributeDetailsUpdate($attributeId, $action, $attribute_title, $attribute_field_type, $attribute_data_type, $attribute_field_values, $adminid) {
		try{
			
			parent::SetDatabaseConnection();
			$query = "call SPattributeedit(" . $attributeId . ", '" . $attribute_title .  "', '" . $attribute_field_type . "', '" . $attribute_data_type . "', '" . $attribute_field_values . "', '" . $action .  "', " . $adminid . ")";
			//exit;
			
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	
}
?>
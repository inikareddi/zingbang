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

class Application_Model_Attributesetsdb extends Application_Model_DataBaseOperations {
	
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
     * Purpose: Fetching Attributesets list except existing user name and returns array of list of users 
     *
     * Access is limited to class and extended classes
     *
     * @param   int		$iuserid User Id
     * @param	int		$istart Start value
     * @param	int		$ilimit Limit value for fetching result set
     * @param	varchar	$cond Search condition
     * @return  object	Returns status message.	
     */
	
	public function getAttributesetsList($iattributes_set_title, $istart, $ilimit){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributesetslist('" . $iattributes_set_title . "', " . $istart . ", " . $ilimit . ")";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Get total count of registered attributesets 
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$usertypeid User type id of the logged in user
     * @param	varchar	$cond Search condition
     * @param	int		$iuserid Present logged in userid
     * @return  object 	user details of supplied userid.	
     */
	
	public function getAttributesetsCount($iattributes_set_title){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPattributesetscount('" . $iattributes_set_title . "')";
			//exit;
			return Application_Model_Db::getValue($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	
	
	
	
	
	
	/**
     * Purpose: Creates Attributesets and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function saveAttributesets($attributes_group_id, $attributes_set_title, $attribute_ids_string, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			//$query = "call SPattributestesadd('" . $attributes_group_id . "', '" . $attributes_set_title . "', '" . $attribute_ids_string . "', '" . $action . "', " . $adminid . ")";
			$query = "call SPattributestesadd('" . $attributes_group_id . "', '" . $attributes_set_title . "', '', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Used to change the category status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	user details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	public function changeStatus($attributes_set_id, $iaction, $iadminuserid, $ilockstatus=0, $iunlockstatus=0, $ideletestatus=0){
		try {
			parent::SetDatabaseConnection();			
			
			/*
			 *  To Lock the user, $ilockstatus must be set to 1
			 *  
			 *  To Unlock the user, $iunlockstatus must be set to 1
			 *  
			 *  To Delete the user, $ideletestatus must be set to 1
			 */
			
			$query = "call SPattributesetschangestatus(" . $attributes_set_id . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
			//exit;
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}




	/**
     * Purpose: Fetching attributesets info
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getAttributesetsDetails($attributes_set_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributesetsdetails('".$attributes_set_id."')";
			//exit;
			return Application_Model_Db::getRow($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}





	
	
	/**
     * Purpose: Update attributesets details
     *
     * Access is limited to class and extended classes
     *
     * @return  object	Returns an object of status.
     */
	 
	public function attributesetsDetailsUpdate($attributes_set_id, $action, $attributes_group_id , $attributes_set_title, $attribute_ids_string, $adminid) {
		try{
			
			parent::SetDatabaseConnection();
			$query = "call SPattributesetsedit(" . $attributes_set_id . ", '" . $attributes_group_id .  "', '" . $attributes_set_title .  "', '" . $attribute_ids_string . "', '" . $action .  "', " . $adminid . ")";
			//exit;
			
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	/**
     * Purpose: Fetching parent active attribute sets list
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getActiveAttributesList(){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributesetslistactive()";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	/**
     * Purpose: Fetching parent active attribute sets list
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getActiveAttributesGroupsList(){
		try {
			parent::SetDatabaseConnection();		
			$query = "SELECT * FROM store_products_attributes_groups where statusid=1 ORDER BY attributes_group_title ASC;";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Fetching parent active attribute sets mapping list
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getAttributesetsMappingList($attributes_set_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributesetsmappingList('".$attributes_set_id."')";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
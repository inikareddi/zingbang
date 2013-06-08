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

//class Application_Model_Attributesgroupsdb extends Application_Model_DataBaseOperations {
class Application_Model_Attributesgroupsdb extends Application_Model_Validation {
	
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
	public function saveAttribute($attributes_group_title, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPattributegroupadd('" . $attributes_group_title . "', '" . $action . "', " . $adminid . ")";
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
			$query = "call SPattributegrouplist('" . $iattribute_title . "', " . $istart . ", " . $ilimit . ")";
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
			
			$query = "call SPattributegroupchangestatus(" . $attributeId . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
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
	
	public function getAttributeGroupDetails($attribute_group_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributegroupdetails('".$attribute_group_id."')";
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
	 
	public function attributeDetailsUpdate($attributes_group_id, $action, $attributes_group_title, $adminid) {
		try{
			
			parent::SetDatabaseConnection();
			$query = "call SPattributegroupedit(" . $attributes_group_id . ", '" . $attributes_group_title .  "', '" . $action .  "', " . $adminid . ")";
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
	
	public function getActiveAttributesList($attributes_group_id){
		try {
			parent::SetDatabaseConnection();		
			//$query = "call SPattributesetslistactive()";
			$query = "SELECT * FROM store_products_attributes pa where statusid=1 AND pa.attribute_id NOT IN (SELECT
						ps.attribute_id
						FROM
						store_products_attributes_groups pag,
						store_products_attributes_sets pas,
						store_products_attributes_sets_mapping asm,
						store_products_attributes ps
						where
						asm.attributes_set_id = pas.attributes_set_id
						AND asm.attribute_id = ps.attribute_id
						AND pag.attributes_group_id = pas.attributes_group_id
						AND pag.attributes_group_id=".$attributes_group_id."
						ORDER BY pas.attributes_set_title ASC);";
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
     * Purpose: Fetching parent active attribute sets list
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getActiveAttributesSetsList($attributes_group_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "SELECT * FROM store_products_attributes_sets where statusid=1 AND attributes_group_id=".$attributes_group_id." ORDER BY attributes_set_title ASC;";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: save attribute set map
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function saveAttributeGroupMap($gid,$str_one){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPattributegroupmapsave('".$gid."','".$str_one."',@omessage)";			
			Application_Model_Db::execute($query); 
			return Application_Model_Db::getRow('select @omessage');
			
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
	
	public function getActiveAttributesSetsMapList($attributes_group_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "SELECT
						pag.attributes_group_id, pag.attributes_group_title,
						pas.attributes_set_id, pas.attributes_set_title,
						ps.attribute_id, ps.attribute_title
						FROM
						store_products_attributes_groups pag,
						store_products_attributes_sets pas,
						store_products_attributes_sets_mapping asm,
						store_products_attributes ps
						where
						asm.attributes_set_id = pas.attributes_set_id
						AND asm.attribute_id = ps.attribute_id
						AND pag.attributes_group_id = pas.attributes_group_id
						AND pag.attributes_group_id=".$attributes_group_id."
						ORDER BY pas.attributes_set_title ASC;";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
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

//class Application_Model_Categorydb extends Application_Model_DataBaseOperations {
class Application_Model_Categorydb extends Application_Model_Validation {
	
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
     * Purpose: Fetching user list except existing user name and returns array of list of users 
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$istart Start value
     * @param	int		$ilimit Limit value for fetching result set
     * @param	varchar	$cond Search condition
     * @return  object	Returns status message.	
     */
	
	public function getCategoryList($icategory_name, $istart, $ilimit){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPcategorylist('" . $icategory_name . "', " . $istart . ", " . $ilimit . ")";
			//yexit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Get total count of categories
     *
     * Access is limited to class and extended classes
     *
     * @param	varchar	$cond Search condition
     * @param	int		$iuserid Present logged in userid
     * @return  object 	user details of supplied userid.	
     */
	
	public function getCategoryCount($icategory_name){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPcategorycount('" . $icategory_name . "')";
			//exit;
			return Application_Model_Db::getValue($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	
	
	
	
	
	
	/**
     * Purpose: Fetching parent category list
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getParentCategories(){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPcategorylistparent()";
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
	public function saveCategory($parent_category_id, $category_name, $category_meta_title,$category_meta_description, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPcategoryadd('" . $parent_category_id . "', '" . $category_name . "', '" . $category_meta_title . "', '" . $category_meta_description . "', '" . $action . "', " . $adminid . ")";
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
	public function updateLogoRecord($category_id, $filename, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPcategoryaddimage('" . $category_id . "', '" . $filename . "', '" . $action . "', " . $adminid . ")";
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
	
	public function changeStatus($categoryid, $iaction, $iadminuserid, $ilockstatus=0, $iunlockstatus=0, $ideletestatus=0){
		try {
			parent::SetDatabaseConnection();			
			
			/*
			 *  To Lock the user, $ilockstatus must be set to 1
			 *  
			 *  To Unlock the user, $iunlockstatus must be set to 1
			 *  
			 *  To Delete the user, $ideletestatus must be set to 1
			 */
			
			$query = "call SPcategorychangestatus(" . $categoryid . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
			//exit;
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}




	/**
     * Purpose: Fetching category info
     *
     * Access is limited to class and extended classes     *
     
     * @return  object	Returns status message.	
     */
	
	public function getCategoryDetails($category_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPcategorydetails('".$category_id."')";
			//exit;
			return Application_Model_Db::getRow($query);
			
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
	
	public function getCategoryImages($category_id){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPcategorydetailsimages('".$category_id."')";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Update category details
     *
     * Access is limited to class and extended classes
     *
     * @return  object	Returns an object of status.
     */
	 
	public function categoryDetailsUpdate($categoryId, $action, $category_name, $parent_category_id, $category_meta_title, $category_meta_description, $adminid) {
		try{
			
			parent::SetDatabaseConnection();
			$query = "call SPcategoryedit(" . $categoryId . ", '" . $parent_category_id .  "', '" . $category_name . "', '" . $category_meta_title . "','" . $category_meta_description . "', '" . $action .  "', " . $adminid . ")";
			//exit;
			
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Used to change the category image status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	user details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	public function changeStatusToDelete($category_id, $category_image_id, $action, $iadminuserid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPcategorydeleteimage(" . $category_id . ", " . $category_image_id . ", '" . $action . "', " . $iadminuserid . ")";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
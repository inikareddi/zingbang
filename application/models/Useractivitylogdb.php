<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Useractivitylogdb.php 
* Module	:	User Activity Log Management Module
* Owner		:	RAM's 
* Purpose	:	This class is used for User Activity Log related database operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Useractivitylogdb extends Application_Model_DataBaseOperations {
	
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
     * Purpose: Fetching user list except existing user name and returns array of list of User Activity Log 
     *
     * Access is limited to class and extended classes
     *    
     * @param	int		$istart Start value
     * @param	int		$ilimit Limit value for fetching result set
     * @param	varchar	$cond Search condition
     * @return  object	Returns status message.	
     */
	
	public function getUserActivityLogList($isearchtext, $istart, $ilimit){
		try {
			parent::SetDatabaseConnection();		
			$query = "select 
						u.userid, u.firstname, u.lastname, u.userloginid,
						mua.useraction, mua.useractiondesc,
						ual.actiondesc
						from
						apmusers u,
						apmmasteruseractions mua,
						apmuseractivitylog ual
						where
						u.userid = ual.userid
						AND mua.useractionid = ual.useractionid";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	
}
?>
<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Emailcorn.php 
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

class Application_Model_Emailcorn extends Application_Model_DataBaseOperations {
	
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
	
	
	public function getmailqueue(){
		try {
			parent::SetDatabaseConnection();
			$query = "call SPapmgetmailqueue()";			
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
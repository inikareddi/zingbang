<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	DataBaseOperations.php 
* Module	:	Admin Module
* Owner		:	RAM's 
* Purpose	:	This class is used for setup database connection and session operation functions
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/



class Application_Model_DataBaseOperations  {
	
	 /**
     * Purpose: sets up connection object and returns it
     *
     * Access is with in the class and extended classes only
     *
     * @param   
     * @return  object Database Connection string
     */
	protected static function SetDatabaseConnection() {
		try {
			$config=Zend_Registry::get('config');			
			$sDbName = $config->db->params->dbname;
			$sDbUser = $config->db->params->username;			
			$sDbPassword = $config->db->params->password;			
			$sDbHost = $config->db->params->host;			
				
			/** calls setConnectionInfo  method fromdb wrapper class **/
			
			Application_Model_Db::setConnectionInfo(
			$sDbName, $sDbUser, $sDbPassword, 'mysql', $sDbHost);
		}
		catch (Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	

	/***************************************************
	 *  Methods related to SESSION ends here
	 ***************************************************/
	
	/**
     * Purpose: Deletes expired sessions from database
     *
     * Access is public
     *
     * @param   int time difference
     * @return  NULL
     */
	public static function DeleteExpiredSessions($timeDiff)
	{
		try
		{
		  self::SetDatabaseConnection();
		  $query="select FNdeleteexpiredsessions('".$timeDiff."')";
		  return Application_Model_Db::execute($query);
		}
		 catch (Exception $e)
		 {
		 	Application_Model_Logging::lwrite($e->getMessage());
		 	throw new Exception($e->getMessage());
		 }

	}

	/**
     * Purpose: Destroy existing active sessions from the database
     *
     * Access is public
     *
     * @param   int Session Id
     * @return  boolean False
     */
    
	public static function DestroySessions($sessionId)
	{
		try
		{
		  self::SetDatabaseConnection();
		  $query="select FNdestroysession('".$sessionId."')";
	      return Application_Model_Db::getValue($query);
		}
		 catch (Exception $e)
		 {
		 	
		 	Application_Model_Logging::lwrite($e->getMessage());
		 	throw new Exception($e->getMessage());
		 }

	}
	
	
	
	
	/**
     * Purpose: Get active sessions from the database
     *
     * Access is public
     *
     * @param   
     * @return  varchar First column value
     */
	
	public static function GetActiveSessions()
	{
		try
		{
		    self::SetDatabaseConnection();
		    $query="select FNgetactivesessions()";
	    	return Application_Model_Db::getValue($query);
		}
		 catch (Exception $e)
		 {
		 	Application_Model_Logging::lwrite($e->getMessage());
		 	throw new Exception($e->getMessage());
		 }

	}
	
	
	
	
	
	/**
     * Purpose: Read data of a session from the database and returns first column
     *
     * Access is public
     *
     * @param   int Session Id
     * @param   int Time
     * @param   varchar Http agent
     * @return  varchar First column value
     */
	
	public static function ReadSessionData($sessionId,$time,$httpAgent)

	{
		try
		{
		  self::SetDatabaseConnection();
		  $query="select FNreadsessiondata('$sessionId','$time','$httpAgent')";
		  return Application_Model_Db::getValue($query);
		}
		 catch (Exception $e)
		 {
		 	Application_Model_Logging::lwrite($e->getMessage());
		 	throw new Exception($e->getMessage());
		 }
	}
	
	
	
	
	/**
     * Purpose: Write data related to a session into the database and returns result set
     *
     * Access is public
     *
     * @param   int Session Id
     * @param   int Time
     * @param   varchar Session Data
     * @param   varchar Http agent
     * @return  varchar First column value
     */
	
	public static function WriteSessionData($sessionId,$time,$SessionData,$httpAgent)
	{
		try
		{
			self::SetDatabaseConnection();
			//if(Zend_Controller_Front::getInstance()->getRequest()->getActionName()!='checkusersession')
			//{
			 	$query="select FNwritesessiondata('$sessionId','$time','$SessionData','$httpAgent')";
                //exit;
			  	return Application_Model_Db::getValue($query);
			//}
		}
		 catch (Exception $e)
		 {		
		 	Application_Model_Logging::lwrite($e->getMessage());
		 	throw new Exception($e->getMessage());
		 }

	}
	
	
	
	
	
	/***************************************************
	 *  Methods related to SESSION ends here
	 ***************************************************/
	
	/**
     * Purpose: Fetch all the modules listed in the database and returns result set
     *
     * Access is public
     *
     * @param   
     * @return  object Result set object 
     */
	
	public static function getModules() {
		try {
			self::SetDatabaseConnection();		
			$query = "call SPapmgetmodules()";
                        //exit;
			return Application_Model_Db::getResult($query);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	
	
}
?>
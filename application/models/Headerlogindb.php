<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Headerlogindb.php 
* Module	:	Header Login Module
* Owner		:	RAM's 
* Purpose	:	This class is used for Header Login related database operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Headerlogindb extends Application_Model_DataBaseOperations {
	
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
		$this->session = new Zend_Session_Namespace('MyClientPortal');
		$this->error = new Zend_Session_Namespace('MyClientPortalerror');
	}
	
}
?>
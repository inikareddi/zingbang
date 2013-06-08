<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Headermenudb.php 
* Module	:	Header Menu Module
* Owner		:	RAM's 
* Purpose	:	This class is used for Header Menu related database operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Headermenudb extends Application_Model_DataBaseOperations {
	
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
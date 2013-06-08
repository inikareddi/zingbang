<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Headerlogin.php 
* Module	:	Header Login Module
* Owner		:	RAM's 
* Purpose	:	This class is used for header login operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Headerlogin extends Application_Model_Headerlogindb {
	
	public $session;
	private $error;
	private $config;
	private $redirector;
	private $requestHandler;
	public $viewobj;
		
	/**
     * Purpose: Constructor sets sessions for portal and portalerror and config and returns session objects
     *
     * Access is public
     *
     * @param	
     * @return  
     */
	
	public function __construct(){
		//$this->merchantdb = new Application_Model_Merchantdb();
		
		//Assigning session
		$this->session = new Zend_Session_Namespace('MyPortal');
                

		//Assigning a config registry
		$this->config = Zend_Registry::get('config');
		
		//Checking for security enabled or not
		//if(!isset($this->session->securityqenabled)) {
			//$this->choosesecurityquestiontype();
		//}
		
		//Redirector handler
		$this->redirector = Zend_Controller_Action_HelperBroker::getStaticHelper('redirector');
		
		//Request Handler
		$this->requestHandler = Zend_Controller_Front::getInstance()->getRequest();
		
		//View Renderer
		$viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
		$viewRenderer->initView();
		//Assigning renderer to access in the class
		$this->error = $viewRenderer->view;
		
		$this->viewobj= $viewRenderer->view;
	}
	
}
?>
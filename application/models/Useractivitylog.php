<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Useractivitylog.php 
* Module	:	User Activity Log Management Module
* Owner		:	RAM's 
* Purpose	:	This class is used for User Activity Log management operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Useractivitylog extends Application_Model_Validation {
	
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
	
		$this->useractivitylogdb = new Application_Model_Useractivitylogdb();

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
	
	
	

	
	
	/**
     * Purpose: Fetches all the users except the present loggedin user
     *
     * Access is public
     *
     * @param	Array	$params Create user parameters
     * 
     * @return  
     */
	
	public  function getUserActivityLogSearch(Array $params) {
		try{

			$viewObject = $this->viewobj;		
			$cond = '';			
			if(isset($params['start']) && $params['start'] != '') {
				$start = $params['start'];
				
			} else {
				$start = 0;
			}						
			$iattribute_title = '';
			
			$controller = Zend_Controller_Front::getInstance();
			$request=$controller->getRequest();						
			
			$iLimit = $this->config->site->pagination->limit;			
			$iStart = $start;			
			
			$useractivitylog_list = $this->useractivitylogdb->getUserActivityLogList($isearchtext, $iStart, $iLimit);			
			$viewObject->useractivitylog_list = $useractivitylog_list;
			$viewObject->iStart = $iStart;
			$viewObject->iLimit = $iLimit;
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	

}
?>
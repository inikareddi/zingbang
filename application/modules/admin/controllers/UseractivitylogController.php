<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	UseractivitylogController.php 
* Module	:	Admin Module - User Activity Log Management
* Owner		:	RAM's 
* Purpose	:	This class is used forUser Activity Log operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Admin_UseractivitylogController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $useractivitylog;			// used for creating an instance of model, Access is with in the class
	private $useractivitylogdb;		// used for creating an instance of model, Access is with in the class
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     * 			and creates an instance of the model class 'Application_Model_Users'
     * 			and creates an instance of the model class 'Application_Model_Userdb'
     * 			This will every time check whether user has logged in or not
     * 			If not, user will be redirected to login screen
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function init() {
           
		$this->session = new Zend_Session_Namespace('MyPortal');               
		//$this->error = new Zend_Session_Namespace('MyPortalerror');
		
		$this->useractivitylog = new Application_Model_Useractivitylog();
		$this->useractivitylogdb = new Application_Model_Useractivitylogdb();		
		
		$user = new Application_Model_Users();
		$user->check();
				
		if(!$this->session->loggedIn) {
			$this->_redirect('admin/');	
		}             
		
		$this->_helper->layout->setLayout($this->session->layout);
	}	
	
	/**
     * Purpose: user will be redirected to user addition page.
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{
			$this->_redirect('admin/useractivitylog/list');
		} catch (Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	

	/**
     * Purpose: User listing page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function listAction() { 
		try{
			$this->view->title = "User Activity Log's List";
			$params = $this->_getAllParams();			              
			$this->useractivitylog->getUserActivityLogSearch($params);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	
}


?>
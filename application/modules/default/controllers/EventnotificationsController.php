<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	EventnotificationsController.php 
* Module	:	Default - Event Notifications Suggestion Module
* Owner		:	RAM's 
* Purpose	:	This class is used for common user operations for all user types
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class EventnotificationsController extends Zend_Controller_Action { 
	public $session;	// used for managing session with NAMESPACE portal
	public $error;		// used for managing session with NAMESPACE portalerror
	private $eventnotifications;		// used for creating an instance of model, Access is with in the class	
	private $eventnotificationsdb;
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function init() {			
		$this->Eventnotifications = new Application_Model_Eventnotifications();
		$this->Eventnotificationsdb = new Application_Model_Eventnotificationsdb();
        $this->_helper->layout->setLayout('default/layout');
		//$this->setLayoutAction('default/layout');		
	}
	
    
	/**
     * Purpose: Index action
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{			
			$this->_helper->layout->disableLayout();
			$EventNotificationsList = $this->Eventnotificationsdb->getEventNotificationsList();			
			$this->view->EventNotificationsList = $EventNotificationsList;					
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}
?>
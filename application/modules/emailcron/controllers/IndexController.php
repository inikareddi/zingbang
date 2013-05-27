<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	IndexController.php 
* Module	:	Email Corn
* Owner		:	RAM's 
* Purpose	:	This class is used for sending emails
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Emailcron_IndexController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $users;			// used for creating an instance of model, Access is with in the class
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     * 			and creates an instance of the model class 'Application_Model_Users'
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
		$this->error = new Zend_Session_Namespace('MyPortalerror');
		$this->emailcorn = new Application_Model_Emailcorn();
			
		//$this->_helper->layout->setLayout($this->session->layout);
	}	
	
	/**
     * Purpose: Redirects to the user list page in 'Usermanagement_UserController'
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{	
			
			$mailqueueArray = $this->emailcorn->getmailqueue();
			//print_r($mailqueueArray);
			$mail = new Zend_Mail();
			foreach($mailqueueArray as $each_mail_row){
			//echo $each_mail_row['emailsubject'].",";
			/*$mail->setBodyText('This is the text of the mail.')
				->setFrom('somebody@example.com', 'Some Sender')
				->addTo('somebody_else@example.com', 'Some Recipient')
				->setSubject('TestSubject')
				->send();*/
			}
			exit;
			$this->_helper->layout()->disableLayout();		
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}	
}
?>
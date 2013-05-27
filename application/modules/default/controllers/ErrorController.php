<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	ErrorController.php 
* Module	:	Default Module
* Owner		:	RAM's 
* Purpose	:	This class is used for displaying error messages occured throughout the application
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class ErrorController extends Zend_Controller_Action
{
	
	/**
     * Purpose: Error action will display the error from the log
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
    public function errorAction()
    {
    	$session = new Zend_Session_Namespace('MyPortal');
		$error = new Zend_Session_Namespace('MyPortalerror');
		
		
		$this->_helper->layout()->disableLayout();
		
        $errors = $this->_getParam('error_handler');
       
        if (!$errors) {
            $this->view->message = 'You have reached the error page';
            return;
        }
        
   
        switch ($errors->type) {
            case Zend_Controller_Plugin_ErrorHandler::EXCEPTION_NO_ROUTE:
            case Zend_Controller_Plugin_ErrorHandler::EXCEPTION_NO_CONTROLLER:
            case Zend_Controller_Plugin_ErrorHandler::EXCEPTION_NO_ACTION:
        
                // 404 error -- controller or action not found
                $this->getResponse()->setHttpResponseCode(404);
                $this->view->message = 'Page not found';
                break;
            default:
                // application error
                $this->getResponse()->setHttpResponseCode(500);
                $this->view->message = 'Application error';
                        $config=Zend_Registry::get('config');
			$logpath= $config->log->path;
			$time=date('m-d-Y');
			$path=$logpath."_".$time.'.log';
                $log = new Zend_Log(

                    new Zend_Log_Writer_Stream(

                       $path

                    )

                );
                break;
        }
        
         
        // Log exception, if logger available
        $log = $this->getLog();
        if ($log) {
        	
            $log->crit($this->view->message, $errors->exception);
        }
        
        // conditionally display exceptions
        if ($this->getInvokeArg('displayExceptions') == true) {
            $this->view->exception = $errors->exception;			
        }
        //$this->view->exception = $errors->exception;
        $this->view->request   = $errors->request;
    }
	
	/**
     * Purpose: returns the log from the log file
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
    public function getLog()
    {
        $bootstrap = $this->getInvokeArg('bootstrap');
        if (!$bootstrap->hasResource('Log')) {
            return false;
        }
        $log = $bootstrap->getResource('Log');
        return $log;
    }
    
 public function accessdeniedAction()
    {
    	
		$this->_helper->layout->setLayout('default/errorlayout');
		
		$this->view->title = "Access Denied";
		
       
    }


}


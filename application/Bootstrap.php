<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Bootstrap.php 
* Owner		:	RAM's 
* Purpose	:	This class is used for initializing modules, plugins and configuaration settings
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/


require('functions.php');
 ini_set("display_errors",true);
 error_reporting(E_ALL);
 //require_once __DIR__ . '/../Loader/StandardAutoloader.php';
 
class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{	
	/*
	 * Initializing Resources
	 */	
	public function _initResource() {		
        $config = new Zend_Config_Ini(__DIR__ . '/configs/application.ini', APPLICATION_ENV);
        Zend_Registry::set('config', $config);
		//self::getDbpassword();
    }
    
    
    
    
    
	/*
	 * Initializing session timeout
	 */
	public function _initSessionCheck() {           
		Zend_Session::setOptions(array('name'=>"MyPortal"));
		$config = Zend_Registry::get('config');
		$sessionTimeOut = $config->user->timeout->session * 60;
		$SessionHandler=new Zend_Session_SaveHandler_DbFunctions($sessionTimeOut);
	}
     
	
	
  
    
    
	/*
	 * Initializing plugins requiredsezsz
	 */   
    public function _initLoadFiles() {
        # All plugins added        
        $plugins = glob(__DIR__ . "/plugins/*.php");
        foreach ($plugins as $plugin) {
            require_once $plugin;
        }
    }
    
    
    
      
    
    /*
     * Initializing language file i.e, Constants
     */
    public function _initFuncName() {        
    	$langs = glob(__DIR__ . "/lang/*.php");
     	foreach ($langs as $lang) {
            require_once $lang;
        }
    }
    
    
    
    /*
     * Initializing modules
     */   
	public function _initModuleLayout() {   
           
        $front = Zend_Controller_Front::getInstance();
        
        //Fetching modules
        $modules = Application_Model_DataBaseOperations::getModules();
        
        $controllerDirectory = array();
        $dir = __DIR__;
        //echo $dir;exit;
        foreach($modules as $record) {
        	$controllerDirectory[$record['modulename']] =  $dir ."\modules\/".$record['modulename']."\controllers";                
        }
        
        //print_r($controllerDirectory);exit;
        $front->setControllerDirectory($controllerDirectory);       
        
        $router = $front->getRouter();
        $request = $front->getRequest();
        $front->registerPlugin(new Temp_Plugin_ModuleLayout()); 
		        
		$MySession = new Zend_Session_Namespace('MyPortal');
		if(isset($MySession->loggedIn) && $MySession->loggedIn) {
			//Initializing ACL Helper			
			/*$helper= new My_Controller_Helper_Acl();
			$helper->setRoles(); 
			$helper->setResources();
			$helper->setPrivilages();
			$helper->setAcl();
			$front->registerPlugin(new My_Controller_Plugin_Acl());*/
		}
        
	}	
}


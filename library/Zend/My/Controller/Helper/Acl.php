<?php

class My_Controller_Helper_Acl
{
	public $acl;
	public $roles;
	public $modules;
	
	//Constructor for initiating ACL
	public function __construct()
	{            
		$this->acl = new Zend_Acl();
		
		/*DB
		$this->roles = Application_Model_Userdb::getDefinedRoles();
		$this->modules = Application_Model_DataBaseOperations::getModules();
        $this->roleprivileges = Application_Model_Userdb::getDefinedRolePrivileges();*/
		$this->roleprivileges = Application_Model_Userdb::getDefinedRolePrivileges();
	}
	
	//Setting up User Roles
	public function setRoles()
	{		
		/*DB
		foreach($this->roles as $records) {
			$this->acl->addRole(new Zend_Acl_Role($records['role']));
		}*/
		
		$this->acl->addRole(new Zend_Acl_Role('Superadmin'));
		$this->acl->addRole(new Zend_Acl_Role('Admin'));
		$this->acl->addRole(new Zend_Acl_Role('Merchant Boarding User'));
		$this->acl->addRole(new Zend_Acl_Role('Merchant Customer Service User'));
	}
	
	//Setting up Resources i.e., Modules and Controllers
	public function setResources()
	{		
		//Setting up the Modules for resources
		/*DB
		$controllers = Application_Model_Userdb::getDefinedControllers('1');
		foreach($this->modules as $module) {
		 	$$module['modulename'] = new Zend_Acl_Resource($module['modulename']);
		 	//$controllers = Application_Model_Userdb::getDefinedControllers($module['moduleid']);
		 	$this->acl->addResource($$module['modulename']);
		 	//foreach ($controllers as $controller) {
		 		//$this->acl->addResource(new Zend_Acl_Resource($module['modulename'] . ':' . $controller['controllername']), $$module['modulename']);
		 			  
		 	//}                        
            foreach ($controllers as $privileges) {
                if($module['modulename']==$privileges['modulename']){
		 		$this->acl->addResource(new Zend_Acl_Resource($module['modulename'] . ':' . $privileges['controllername']), $$module['modulename']);
                }
		 	}	 	
		 }*/
		 
		
		//Setting up the Controllers for Modules assigned for resources     
		
		$defaultModuleResource = new Zend_Acl_Resource('default'); 
		$adminModuleResource = new Zend_Acl_Resource('admin'); 
		$usermanagementModuleResource = new Zend_Acl_Resource('usermanagement');            
        
		//default module resources
        $this->acl->addResource($defaultModuleResource)->addResource(new Zend_Acl_Resource('default:index'), $defaultModuleResource)
														->addResource(new Zend_Acl_Resource('default:error'), $defaultModuleResource);
														
		//admin module resources
        $this->acl->addResource($adminModuleResource)->addResource(new Zend_Acl_Resource('admin:index'), $adminModuleResource)
														->addResource(new Zend_Acl_Resource('admin:error'), $adminModuleResource);
        
        //customer module usermanagement
        $this->acl->addResource($usermanagementModuleResource)->addResource(new Zend_Acl_Resource('usermanagement:index'), $usermanagementModuleResource)
															->addResource(new Zend_Acl_Resource('usermanagement:user'), $usermanagementModuleResource);
               
	}
	
	//Setting up the privileges
	public function setPrivilages()
	{	
		//echo "<pre>";
		//print_r($this->roleprivileges);
		//exit;
		foreach($this->roleprivileges as $privileges) {
			$this->acl->allow($privileges['rolename'] , $privileges['modulename'] . ':' . $privileges['controllername'] , $privileges['actionname']);			
		}
		/*
		$this->acl->allow('admin','admin:example',array('index'));
		$this->acl->deny('admin','admin:example',array('sample'));
		$this->acl->allow('admin','default:error',array('error'));
		$this->acl->allow('admin','default:login',array('logout'));
		$this->acl->deny('admin','staff:staffactions',array('index'));
		$this->acl->allow('admin','staff:staffactions',array('test'));
		$this->acl->deny('admin','customer:firstview',array('index','trial'));
		
		
		
		$this->acl->allow('staff','staff:staffactions',array('index'));
		$this->acl->allow('staff','default:error',array('error'));
		$this->acl->allow('staff','default:login',array('logout'));
		$this->acl->allow('staff','customer:firstview',array('trial'));
		$this->acl->deny('staff','customer:firstview',array('index'));
		$this->acl->deny('staff','admin:example',array('index'));
		$this->acl->deny('staff','staff:staffactions',array('test'));
		$this->acl->allow('staff','admin:example',array('sample'));
		
		
		$this->acl->allow('customer','customer:firstview',array('index'));
		$this->acl->allow('customer','default:error',array('error'));
		$this->acl->allow('customer','default:login',array('logout', 'index'));
		$this->acl->allow('customer','admin:example',array('sample'));
		$this->acl->allow('customer','staff:staffactions',array('test'));
		$this->acl->deny('customer','customer:firstview',array('trial'));
		$this->acl->deny('customer','staff:staffactions',array('index'));
		$this->acl->deny('customer','admin:example',array('index'));*/
		
	}
	public function setAcl()
	{
		Zend_Registry::set('acl',$this->acl);
	}
}
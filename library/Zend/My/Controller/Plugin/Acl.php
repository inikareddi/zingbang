<?php
require_once 'Zend/Session.php';
Zend_Session::start(true);
//Zend_Loader_Autoloader::getInstance();
class My_Controller_Plugin_Acl extends Zend_Controller_Plugin_Abstract
{
	public function preDispatch(Zend_Controller_Request_Abstract $request)
	{
		$acl = Zend_Registry::get('acl');
		
		//echo "<pre>";
		//print_r($acl);
		//exit;
		
		
		//exit;
	//	if($privilageName!="login"){
		 $usersNs=Application_Model_Userdb::getActiveSession();
		 //print_r($usersNs);
		 //exit;
		//exit;
		
		
		 //print_obj($request);
		 $roleName=$usersNs['role'];//exit;
		//echo "role:".$roleName;exit;
		  $privilageName=$request->getActionName();
		
		 $controller = $request->getControllerName();
		 $module = $request->getModuleName();//exit;
		//echo "Role::" . $roleName . ", Module::" . $module . ", Controller::" . $controller . ", Action::" . $privilageName . "<br/><br/><br/>";
		/*$session = Zend_Session::setOptions(array('name'=>"MyPortal"));
		if(!isset($session->loggedIn) || $session->loggedIn != 1) {
			$redirector = Zend_Controller_Action_HelperBroker::getStaticHelper('redirector');
			$redirector->gotoRoute(array('module'=>'default', 'controller'=> 'index',
   'action' =>'index'));
		}*/
		//echo "Here"; exit;
		//echo $acl->isAllowed($roleName,$module.':'.$controller,$privilageName) . "  <br/><br/><br/>";
		//echo $roleName;
		//if($roleName=trim('Customer Service')){
			if(!$acl->isAllowed($roleName,$module . ':' . $controller,$privilageName)){
				$request->setModuleName("default");
				$request->setControllerName("Error");
				$request->setActionName("accessdenied");
			}
		//}
		
	//}
	}
}
<?php
require_once'Zend/Session.php';
class Zend_Session_SaveHandler_DbFunctions implements Zend_Session_SaveHandler_Interface
{

		function __construct($session_lifetime = '',$gc_probability = '', $gc_divisor = '',$security_code = 'sEcUr1tY_c0dE',$table_name = 'sessiondata')
			{
			ini_set('session.cookie_lifetime',0);
			
				if($session_lifetime != ''&& is_integer($session_lifetime)){
					ini_set('session.gc_maxlifetime',$session_lifetime);
				}
				
				if($gc_probability != ''&& is_integer($gc_probability)){
					ini_set('session.gc_probability',$gc_probability);
				}
				
				if($gc_divisor !=''&&is_integer($gc_divisor)){
					ini_set('session.gc_divisor',$gc_divisor);
				}
			$this->session_lifetime = ini_get('session.gc_maxlifetime');
			$this->securityCode = $security_code;
			$this->table_name = $table_name;
			session_set_save_handler(array(&$this,'open'),array(&$this,'close'),array(&$this,'read'),array(&$this,'write'),array(&$this,'destroy'),array(&$this,'gc'));
			Zend_Session::start();
		}
		
		
		function close()
		{
			return true;
		}
		
		
		function destroy($session_id)
		{
			$DestroyedSessions=Application_Model_DataBaseOperations::DestroySessions($session_id);
			if($DestroyedSessions !== -1) 
			{
				return true;
			}
			return false;
		}
		
		
		function gc($maxlifetime)
		{
			Aplication_Mode;_DataBaseOperations::DeleteExpiredSessions(time() - $maxlifetime);
		}
		
		
		
		function get_active_sessions()
		{
			$this->gc($this->session_lifetime);
			return Application_Model_DataBaseOperations::GetActiveSessions();
		}
		
		
		function get_settings()
		{
			$gc_maxlifetime = ini_get('session.gc_maxlifetime');
			$gc_probability = ini_get('session.gc_probability');
			$gc_divisor = ini_get('session.gc_divisor');
			return array('session.gc_maxlifetime' => $gc_maxlifetime . 'seconds('.round($gc_maxlifetime/60).'minutes)', 
						'session.gc_probability' => $gc_probability, 
						'session.gc_divisor' => $gc_divisor, 
						'probability' => $gc_probability/$gc_divisor*(100).'%',);
		}
		
		
		function open($save_path,$session_name)
		{
			return true;
		}
		
		
		function read($session_id)
		{
			$http_agent=md5((isset($_SERVER['HTTP_USER_AGENT'])? $_SERVER['HTTP_USER_AGENT']:'').$this->securityCode);
			$fields= Application_Model_DataBaseOperations::ReadSessionData($session_id,time(),$http_agent);
			return $fields;
		}
		
		
		function regenerate_id()
		{
			$oldSessionID = Zend_Session::getId();
			Zend_Session::regenerateId();
			$this->destroy($oldSessionID);
		}
		
		
		function stop()
		{
			$this->regenerate_id();
			session_unset();
			session_destroy();
		}
		
		
		function write($session_id,$session_data)
		{
			$time=time()+$this->session_lifetime;
			$http_agent=md5((isset($_SERVER['HTTP_USER_AGENT'])?$_SERVER['HTTP_USER_AGENT']:'').$this->securityCode);
			$inserted_rows=Application_Model_DataBaseOperations::WriteSessionData($session_id,$time,$session_data,$http_agent);
			if($inserted_rows>1){
			return true;
			} else {
			return'';
			}
			return false;
		}


}
?>
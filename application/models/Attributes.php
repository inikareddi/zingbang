<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Merchant.php 
* Module	:	User Management Module
* Owner		:	RAM's 
* Purpose	:	This class is used for user management operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

//class Application_Model_Attributes extends Application_Model_Validation {
class Application_Model_Attributes extends Application_Model_Attributesdb {
	
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
	
		$this->attributesdb = new Application_Model_Attributesdb();

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
     * Purpose: Creates category and also used for updation of his profile and returns an a boolean value of status
     *
     * Access is public
     *
     * @param	Array	$params Create category parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function createAttribute(Array $params) {
		try{
			/*echo "sadsadsa";
			print_r($params);
			exit;*/
			if(isset($params['attribute_title'])){ $attribute_title = trim($params['attribute_title']);}
			if(isset($params['attribute_field_type'])){ $attribute_field_type = trim($params['attribute_field_type']);}
			if(isset($params['attribute_data_type'])){ $attribute_data_type = trim($params['attribute_data_type']);}
			if(isset($params['attribute_values'])){ $attribute_values = trim($params['attribute_values']);}			
			if(isset($params['action'])){ $action = trim($params['action']);}

			
			/*
			 * Validation 
			 */		
			$error = 0;
			
			/*print_r($this->error->error_createuser_values);
			exit;*/
            if($attribute_title == '') {				//Validation for attribute_title
            	$this->error->error_create_attribute_title = Error_Create_attribute_title_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alphanumeric_space($attribute_title)) {
            	$params['attribute_title'] = '';
            	$this->error->error_create_attribute_title = Error_Create_attribute_title_invalid;
            	$error = 1;
            	//return false;
            } else if(strlen($attribute_title) >20) {
            	$this->error->error_create_attribute_title = Error_Create_attribute_title_min;
            	$error = 1;
            } else if(strlen($attribute_title) < 3) {
            	$this->error->error_create_attribute_title = Error_Create_attribute_title_max;
            	$error = 1;
            }
			
			if($attribute_field_type == '') {				//Validation for attribute_field_type
            	$this->error->error_create_attribute_field_type = Error_Create_attribute_field_type_empty;
            	$error = 1;
            	//return false;
            }

			/*
			if($attribute_data_type == '') {				//Validation for attribute_data_type
            	$this->error->error_create_attribute_data_type = Error_Create_attribute_data_type_empty;
            	$error = 1;
            	//return false;
            }
			*/			
            
			
            
            if($error == 1) {
            	$this->error->error_creatattribute_values = $params;
            	$error = 0;
            	return false;
            }
          
            /*
             * Validation ends here
             */

				$outpt = $this->attributesdb->saveAttribute($attribute_title, $attribute_field_type, $attribute_data_type, $attribute_values, $action, $this->session->userid);
				$outpt = $outpt[0];
				$result = explode('#', $outpt['toutput']);				
				
				if($result[0] == 1) {
					$this->session->success = Success_creation . ' attribute with Attribute Title ' . $attribute_title ;
					return true;
				} else {
					$this->error->error = Failure_creation . ' attribute with Attribute Title ' . $attribute_title ;
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
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
	
	public  function getAttributeSearch(Array $params) {
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
			
			//$attribute_count = $this->attributesdb->getAttributeCount($iattribute_title);
			$attribute_list = $this->attributesdb->getAttributeList($iattribute_title, $iStart, $iLimit);
			
			//$viewObject->attribute_count=$attribute_count;
			$viewObject->attribute_list = $attribute_list;
			$viewObject->iStart = $iStart;
			$viewObject->iLimit = $iLimit;
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: To Lock the existing Active Attribute
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function lock(Array $params) {
		try{
			$attributeId = trim($params['attributeId']);
			$action = trim($params['action']);
			$lock = 1;
			$unlock = 0;
			$delete = 0;
			if($attributeId!='' && $attributeId!=0 && $this->validate_numeric($attributeId)) {

				$mess = $this->attributesdb->changeStatus($attributeId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);			
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_locked; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Attribute_Id;				
				$this->redirector->gotosimple('list','attributes','admin',array());	
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: To Unlock the existing Locked Attribute
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function unlock(Array $params) {
		try{
			$attributeId = trim($params['attributeId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 1;
			$delete = 0;
			if($attributeId!='' && $attributeId!=0 && $this->validate_numeric($attributeId)) {				
				
				$mess = $this->attributesdb->changeStatus($attributeId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_unlocked; 
				}
			
			}else{
				$this->session->validateerror= Error_Invalid_Attribute_Id;				
				$this->redirector->gotosimple('list','attributes','admin',array());
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Delete the existing Attribute
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function delete(Array $params) {
		try{
			$attributeId = trim($params['attributeId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 0;
			$delete = 1;
			if($attributeId!='' && $attributeId!=0 && $this->validate_numeric($attributeId)) {				
				
				$mess = $this->attributesdb->changeStatus($attributeId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_deleted; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Attribute_Id;				
				$this->redirector->gotosimple('list','attributes','admin',array());	
			}			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	
	/**
     * Purpose: To update attribute details
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user performs action in the given idle time out,
     * 					false if user was idle
     */
	public function updateAttributesDetails(Array $params) {
		try{
			
			$attributeId 			= trim($params['attributeId']);
			$attribute_title 		= trim($params['attribute_title']);
			$action 				= trim($params['action']);			
			$attribute_field_type 	= trim($params['attribute_field_type']);
			$attribute_data_type 	= trim($params['attribute_data_type']);
			$attribute_field_values = trim($params['attribute_field_values']);			
			$admin = $this->session->userid;
			
			
			
			/*
			 * Validation for update attribute
			 * 				  
			 */
			$error = 0;
			
			if($attributeId!='' && $attributeId!=0 && $this->validate_numeric($attributeId)) {
				 
				if($attribute_title == '') {				//Validation for attribute_title
					$this->error->error_updateattribute_title = Error_update_attribute_title_empty;
					$error = 1;
				} else if(!$this->validate_alphanumeric_space($attribute_title)) {
					$params['attribute_title'] = '';
					$this->error->error_updateattribute_title = Error_update_attribute_title_invalid;
					$error = 1;
				} else if(strlen($attribute_title) >20) {
					$this->error->error_updateattribute_title = Error_update_attribute_title_max;
					$error = 1;
				}
				
				if($attribute_field_type == '') {				//Validation for attribute_field_type
					$this->error->error_updateattribute_field_type = Error_update_attribute_field_type_empty;
					$error = 1;
				}
				
				/*
				if($attribute_data_type == '') {				//Validation for attribute_data_type
					$this->error->error_updateattribute_data_type = Error_update_attribute_data_type_empty;
					$error = 1;
				}
				*/
            
			
            
				if($action == '') {			//Validation for action name
					$this->error->error = Invalid_URL_Found;
					$error = 1;
				} else if(!$this->validate_alpha($action)) {
					$this->error->error = Invalid_URL_Found;
					$error = 1;
				}
            
            
				if($error == 1) {
					$this->error->error_updateattribute_values = $params;
					$error = 0;
					return false;
				}
				
				/*
				 * Validation ends here
				 */            
				
			
				$mess = $this->attributesdb->attributeDetailsUpdate($attributeId, $action, $attribute_title, $attribute_field_type, $attribute_data_type, $attribute_field_values, $this->session->userid);
				
				$messs = explode('#',$mess[0]['tmess']);
				
				if($messs[0] == 0) {
					$this->error->error = Status_failed_updated . $attribute_title;
					return false; 
				} else {
					$this->session->success = $attribute_title . ' ' . Status_updated;
					return true;
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_attribute_Id;
				$this->redirector->gotoSimple('list','attirbutes','admin',array());	
			}
			
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}

}
?>
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

//class Application_Model_Attributesets extends Application_Model_Validation {
class Application_Model_Attributesets extends Application_Model_Attributesetsdb {
	
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
	
		$this->attributesetsdb = new Application_Model_Attributesetsdb();	
	
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
		
		//$viewRenderer = Zend_Controller_Action_HelperBroker::getStaticHelper('viewRenderer');
		//$viewRenderer->initView();
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
	
	public  function getAttributesetsSearch(Array $params) {
		try{

			$viewObject = $this->viewobj;		
			$cond = '';			
			if(isset($params['start']) && $params['start'] != '') {
				$start = $params['start'];
				
			} else {
				$start = 0;
			}						
			$iattributes_set_title = '';
			
			$controller = Zend_Controller_Front::getInstance();
			$request=$controller->getRequest();						
			
			$iLimit = $this->config->site->pagination->limit;			
			$iStart = $start;
			
			$attributesets_count = $this->attributesetsdb->getAttributesetsCount($iattributes_set_title);
			$attributesets_list = $this->attributesetsdb->getAttributesetsList($iattributes_set_title, $iStart, $iLimit);
			
			$viewObject->attributesets_count = $attributesets_count;
			$viewObject->attributesets_list = $attributesets_list;
			$viewObject->iStart = $iStart;
			$viewObject->iLimit = $iLimit;
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
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
	
	public  function createAttributesets(Array $params) {
		try{
			/*echo "sadsadsa";
			print_r($params);
			exit;*/
			if(isset($params['attributes_group_id'])){ $attributes_group_id = trim($params['attributes_group_id']);}
			if(isset($params['attributes_set_title'])){ $attributes_set_title = trim($params['attributes_set_title']);}			
			if(isset($params['action'])){ $action = trim($params['action']);}
			$attribute_ids = array();
			$getActiveAttributesList = $this->attributesetsdb->getActiveAttributesList();
			foreach($getActiveAttributesList as $each_ActiveAttributesList){
				if(isset($params["attribute_id_".$each_ActiveAttributesList['attribute_id']]) && trim($params["attribute_id_".$each_ActiveAttributesList['attribute_id']])!=''){
					$attribute_ids["attribute_id_".$each_ActiveAttributesList['attribute_id']] = $params["attribute_id_".$each_ActiveAttributesList['attribute_id']];
				}
			}
			//print_r($attribute_ids);exit;
			$attribute_ids_string = implode("#",$attribute_ids).'#';
			
			if(isset($params['attributes_group_id']) && trim($params['attributes_group_id'])!=''){
				$conditionAllreadyExists = " AND attributes_group_id='".$params['attributes_group_id']."'";
			}
			
			/*
			 * Validation 
			 */		
			$error = 0;
			
			/*print_r($this->error->error_createuser_values);
			exit;*/
            if($attributes_set_title == '') {				//Validation for attributes_set_title
            	$this->error->error_create_attributes_set_title = Error_Create_attributes_set_title_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alphanumeric_space($attributes_set_title)) {
            	$params['attributes_set_title'] = '';
            	$this->error->error_create_attributes_set_title = Error_Create_attributes_set_title_invalid;
            	$error = 1;
            	//return false;
            } else if(strlen($attributes_set_title) >20) {
            	$this->error->error_create_attributes_set_title = Error_Create_attributes_set_title_min;
            	$error = 1;
            } else if(strlen($attributes_set_title) < 3) {
            	$this->error->error_create_attributes_set_title = Error_Create_attributes_set_title_max;
            	$error = 1;
            } else if($this->checkAllreadyExists('store_products_attributes_sets','attributes_set_title',$attributes_set_title,'','',$conditionAllreadyExists)>=1) { 
				// Table, column, value, recordid
				$this->error->error_create_attributes_set_title = Error_Create_attribute_title_AllreadyExists;
				$error = 1;
			}
			
			
			if($attributes_group_id == '') {				//Validation for attributes_group_id
            	$this->error->error_create_attributes_group_id = Error_Create_attributes_group_id_empty;
            	$error = 1;
            	//return false;
            }            
			
            
            if($error == 1) {
            	$this->error->error_createattributes_set_values = $params;
            	$error = 0;
            	return false;
            }
          
            /*
             * Validation ends here
             */

				$outpt = $this->attributesetsdb->saveAttributesets($attributes_group_id, $attributes_set_title, $attribute_ids_string, $action, $this->session->userid);
				$outpt = $outpt[0];
				$result = explode('#', $outpt['toutput']);				
				
				if($result[0] == 1) {
					$this->session->success = Success_creation . ' attributesets with Attributesets Title ' . $attributes_set_title ;
					return true;
				} else {
					$this->error->error = Failure_creation . ' attributesets with Attributesets Title ' . $attributes_set_title ;
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	/**
     * Purpose: To Lock the existing Active Attributesets
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function lock(Array $params) {
		try{
			$attributes_set_id = trim($params['attributes_set_id']);
			$action = trim($params['action']);
			$lock = 1;
			$unlock = 0;
			$delete = 0;
			if($attributes_set_id!='' && $attributes_set_id!=0 && $this->validate_numeric($attributes_set_id)) {

				$mess = $this->attributesetsdb->changeStatus($attributes_set_id, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);			
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_locked; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Attributesets_Id;				
				$this->redirector->gotosimple('list','attributesets','admin',array());	
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: To Unlock the existing Locked attributesets
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function unlock(Array $params) {
		try{
			$attributes_set_id = trim($params['attributes_set_id']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 1;
			$delete = 0;
			if($attributes_set_id!='' && $attributes_set_id!=0 && $this->validate_numeric($attributes_set_id)) {				
				
				$mess = $this->attributesetsdb->changeStatus($attributes_set_id, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_unlocked; 
				}
			
			}else{
				$this->session->validateerror= Error_Invalid_Attributesets_Id;				
				$this->redirector->gotosimple('list','attributesets','admin',array());
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Delete the existing attributesets
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function delete(Array $params) {
		try{
			$attributes_set_id = trim($params['attributes_set_id']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 0;
			$delete = 1;
			if($attributes_set_id!='' && $attributes_set_id!=0 && $this->validate_numeric($attributes_set_id)) {				
				
				$mess = $this->attributesetsdb->changeStatus($attributes_set_id, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_deleted; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Attributesets_Id;				
				$this->redirector->gotosimple('list','attributesets','admin',array());	
			}			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To update attributesets details
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user performs action in the given idle time out,
     * 					false if user was idle
     */
	public function updateAttributesetsDetails(Array $params) {
		try{			
			$attributes_set_id 			= trim($params['attributes_set_id']);
			$attributes_group_id 			= trim($params['attributes_group_id']);
			$attributes_set_title 			= trim($params['attributes_set_title']);			
			$attribute_ids = array();
			$getActiveAttributesList = $this->attributesetsdb->getActiveAttributesList();
			foreach($getActiveAttributesList as $each_ActiveAttributesList){
				if(isset($params["attribute_id_".$each_ActiveAttributesList['attribute_id']]) && trim($params["attribute_id_".$each_ActiveAttributesList['attribute_id']])!=''){
					$attribute_ids["attribute_id_".$each_ActiveAttributesList['attribute_id']] = $params["attribute_id_".$each_ActiveAttributesList['attribute_id']];
				}
			}
			//print_r($attribute_ids);exit;
			$attribute_ids_string = implode("#",$attribute_ids).'#';			
			$action 				= trim($params['action']);					
			$admin = $this->session->userid;
			
			
			if(isset($params['attributes_group_id']) && trim($params['attributes_group_id'])!=''){
				$conditionAllreadyExists = " AND attributes_group_id='".$params['attributes_group_id']."'";
			}
			
			/*
			 * Validation for update category
			 * 				  
			 */
			$error = 0;
			
			if($attributes_set_id!='' && $attributes_set_id!=0 && $this->validate_numeric($attributes_set_id)) {
				 
				if($attributes_set_title == '') {				//Validation for attributes_set_title
					$this->error->error_updateattributes_set_title = Error_update_attributes_set_title_empty;
					$error = 1;
				} else if(!$this->validate_alphanumeric_space($attributes_set_title)) {
					$params['attributes_set_title'] = '';
					$this->error->error_updateattributes_set_title = Error_update_attributes_set_title_invalid;
					$error = 1;
				} else if(strlen($attributes_set_title) >20) {
					$this->error->error_updateattributes_set_title = Error_update_attributes_set_title_max;
					$error = 1;
				} else if($this->checkAllreadyExists('store_products_attributes_sets','attributes_set_title',$attributes_set_title,'attributes_set_id',$attributes_set_id,$conditionAllreadyExists)>=1) { 
					// Table, column, value, recordid
					$this->error->error_updateattributes_set_title = Error_update_attribute_title_AllreadyExists;
					$error = 1;
				}
				
				
			if($attributes_group_id == '') {				//Validation for attributes_group_id
            	$this->error->error_updateattributes_group_id = Error_update_attributes_group_id_empty;
            	$error = 1;
            	//return false;
            }
            
			
            
				if($action == '') {			//Validation for action name
					$this->error->error = Invalid_URL_Found;
					$error = 1;
				} else if(!$this->validate_alpha($action)) {
					$this->error->error = Invalid_URL_Found;
					$error = 1;
				}
            
            
				if($error == 1) {
					$this->error->error_updateattributesets_values = $params;
					$error = 0;
					return false;
				}
				
				/*
				 * Validation ends here
				 */            
				
			
				$mess = $this->attributesetsdb->attributesetsDetailsUpdate($attributes_set_id, $action, $attributes_group_id , $attributes_set_title, $attribute_ids_string, $this->session->userid);
				
				$messs = explode('#',$mess[0]['tmess']);
				
				if($messs[0] == 0) {
					$this->error->error = Status_failed_updated . $attributes_set_title;
					return false; 
				} else {
					$this->session->success = $attributes_set_title . ' ' . Status_updated;
					return true;
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_category_Id;
				$this->redirector->gotoSimple('list','attributesets','admin',array());	
			}
			
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}
?>
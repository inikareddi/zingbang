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

class Application_Model_Merchant extends Application_Model_Validation {
	
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
		$this->merchantdb = new Application_Model_Merchantdb();
		
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
     * Purpose: Fetches all the merchant except the present loggedin user    
     * Access is public      
     * @return  
     */
	
	public  function getMerchantSearch(Array $params) {
		try{

			$viewObject = $this->viewobj;		
			$cond = '';			
			if(isset($params['start']) && $params['start'] != '') {
				$start = $params['start'];
				
			} else {
				$start = 0;
			}						
			$imerchant_name = '';
			
			$controller = Zend_Controller_Front::getInstance();
			$request=$controller->getRequest();						
			
			$iLimit = $this->config->site->pagination->limit;			
			$iStart = $start;
			
			$merchant_count = $this->merchantdb->getMerchantCount('','','');			
			$merchant_list = $this->merchantdb->getMerchantList($iStart, $iLimit, '','','');
			//print_r($merchant_list);
			
			$viewObject->merchant_count=$merchant_count;
			$viewObject->merchant_list = $merchant_list;
			$viewObject->iStart = $iStart;
			$viewObject->iLimit = $iLimit;
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Creates user and also used for updation of his profile and returns an a boolean value of status
     *
     * Access is public
     *
     * @param	Array	$params Create user parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function createMerchant(Array $params) {
		try{
			/*
			print_r($params);
			exit;*/			
			$merchant_title		= trim($params['merchant_title']);			
			$merchant_email		= trim($params['merchant_email']);
			$merchant_mobile	= trim($params['merchant_mobile']);
			$merchant_phone		= trim($params['merchant_phone']);
			$merchant_fax		= trim($params['merchant_fax']);
			$merchant_city		= trim($params['merchant_city']);
			$merchant_state		= trim($params['merchant_state']);
			$merchant_country	= trim($params['merchant_country']);
			$merchant_address1	= trim($params['merchant_address1']);
			$merchant_address2	= trim($params['merchant_address2']);
			$merchant_postcode	= trim($params['merchant_postcode']);
			$merchant_description	= trim($params['merchant_description']);
			$action 				= trim($params['action']);
			

			
			/*
			 * Validation for firstname(Alpha numeric), lastname(Alpha Numeric), useremail(Email), phonenumber (Numeric)
			 * 				  username(Email), role(Numeric), action(alpha)
			 */		
			$error = 0;
			
			
            if($merchant_title == '') {				//Validation for firstname
				$this->error->error_createmerchant_merchant_title = Error_create_merchant_name_empty;
				$error = 1;
			} else if(!$this->validate_alphanumeric_space($merchant_title)) {
				$params['merchant_title'] = '';
				$this->error->error_createmerchant_merchant_title = Error_create_merchant_name_invalid;
				$error = 1;
			} else if(strlen($merchant_title) >20) {
				$this->error->error_createmerchant_merchant_title = Error_create_merchant_name_max;
				$error = 1;
			}
			
          
            
            if($error == 1) {
            	$this->error->error_createmerchant_values = $params;
            	$error = 0;
            	return false;
            }
          
            /*
             * Validation ends here
             */
	
				$outpt = $this->merchantdb->saveMerchant($merchant_title,$merchant_email,$merchant_mobile,$merchant_phone,$merchant_fax,$merchant_city,$merchant_state,$merchant_country,$merchant_address1,$merchant_address2,$merchant_postcode,$merchant_description, $action, $this->session->userid);
				$outpt = $outpt[0];
				$result = explode('#', $outpt['toutput']);
				
				
								$upload = new Zend_File_Transfer();                                    
								//$upload = new Zend_File_Transfer_Adapter_Http();                                
								$files = $upload->getFileInfo();
								foreach ($files as $file => $info) {
									if($upload->isValid($file)){
										$filename = time().$info['name'];
										$upload->addFilter('Rename', APPLICATION_PATH.'/../public/uploads/merchant_images/'.$filename, 1);
										$upload->receive($file);
										$LogoSet = $this->merchantdb->updateLogoRecord($result[1],$filename, $action, $this->session->userid);
									}
								}
				
				
				if($result[0] == 1) {					
					$this->session->success = Success_user_creation . ' with Merchant Title ' . $merchant_title ;
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' with Merchant Title ' . $merchant_title ;
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	
	/**
     * Purpose: To Lock the existing Active Merchant
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function lock(Array $params) {
		try{
			$merchantId = trim($params['merchantId']);
			$action = trim($params['action']);
			$lock = 1;
			$unlock = 0;
			$delete = 0;
			if($merchantId!='' && $merchantId!=0 && $this->validate_numeric($merchantId)) {

				$mess = $this->merchantdb->changeStatus($merchantId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);			
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_locked; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Merchant_Id;				
				$this->redirector->gotosimple('list','merchant','admin',array());	
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: To Unlock the existing Locked merchant
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function unlock(Array $params) {
		try{
			$merchantId = trim($params['merchantId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 1;
			$delete = 0;
			if($merchantId!='' && $merchantId!=0 && $this->validate_numeric($merchantId)) {				
				
				$mess = $this->merchantdb->changeStatus($merchantId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_unlocked; 
				}
			
			}else{
				$this->session->validateerror= Error_Invalid_Merchant_Id;				
				$this->redirector->gotosimple('list','merchant','admin',array());
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Delete the existing merchant
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function delete(Array $params) {
		try{
			$merchantId = trim($params['merchantId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 0;
			$delete = 1;
			if($merchantId!='' && $merchantId!=0 && $this->validate_numeric($merchantId)) {				
				
				$mess = $this->merchantdb->changeStatus($merchantId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_deleted; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Merchant_Id;				
				$this->redirector->gotosimple('list','merchant','admin',array());	
			}			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: To update category details
     *
     * Access is public
     *
     * @param
     * 
     * @return  boolean	true if user performs action in the given idle time out,
     * 					false if user was idle
     */
	public function updateMerchantDetails(Array $params) {
		try{
			
			$merchantId 			= trim($params['merchantId']);
			$merchant_title 		= trim($params['merchant_title']);
			$action 				= trim($params['action']);			
			$merchant_email 		= trim($params['merchant_email']);
			$merchant_mobile 		= trim($params['merchant_mobile']);
			$merchant_phone 		= trim($params['merchant_phone']);
			$merchant_fax 			= trim($params['merchant_fax']);
			$merchant_city 			= trim($params['merchant_city']);
			$merchant_state 		= trim($params['merchant_state']);
			$merchant_country 		= trim($params['merchant_country']);
			$merchant_address1 		= trim($params['merchant_address1']);
			$merchant_address2 		= trim($params['merchant_address2']);
			$merchant_postcode 		= trim($params['merchant_postcode']);
			$merchant_description 	= trim($params['merchant_description']);
		
			$admin = $this->session->userid;
			
			
			
			/*
			 * Validation for update category
			 * 				  
			 */
			$error = 0;
			
			if($merchantId!='' && $merchantId!=0 && $this->validate_numeric($merchantId)) {
				 
				if($merchant_title == '') {				//Validation for firstname
					$this->error->error_updatemerchant_merchant_name = Error_update_merchant_name_empty;
					$error = 1;
				} else if(!$this->validate_alphanumeric_space($merchant_title)) {
					$params['merchant_title'] = '';
					$this->error->error_updatemerchant_merchant_name = Error_update_merchant_name_invalid;
					$error = 1;
				} else if(strlen($merchant_title) >20) {
					$this->error->error_updatemerchant_merchant_name = Error_update_merchant_name_max;
					$error = 1;
				}
            
			
            
				if($action == '') {			//Validation for action name
					$this->error->error = Invalid_URL_Found;
					$error = 1;
				} else if(!$this->validate_alpha($action)) {
					$this->error->error = Invalid_URL_Found;
					$error = 1;
				}
            
            
				if($error == 1) {
					$this->error->error_updatemerchant_values = $params;
					$error = 0;
					return false;
				}
				
				/*
				 * Validation ends here
				 */            
				
			
				$mess = $this->merchantdb->merchantDetailsUpdate($merchantId, $action, $merchant_title, $merchant_email, $merchant_mobile, $merchant_phone, $merchant_fax, $merchant_city, $merchant_state, $merchant_country, $merchant_address1, $merchant_address2, $merchant_postcode, $merchant_description, $this->session->userid);
				$messs = explode('#',$mess[0]['tmess']);				
				
								//$upload = new Zend_File_Transfer();                                    
								$upload = new Zend_File_Transfer_Adapter_Http();                                
								$files = $upload->getFileInfo();
								foreach ($files as $file => $info) {
									if($upload->isValid($file)){
										$filename = time().$info['name'];
										$upload->addFilter('Rename', APPLICATION_PATH.'/../public/uploads/merchant_images/'.$filename, 1);
										$upload->receive($file);
										$LogoSet = $this->merchantdb->updateLogoRecord($merchantId,$filename, $action, $this->session->userid);
									}
								}
				
				if($messs[0] == 0) {
					$this->error->error = Status_failed_updated . $merchant_title;
					return false; 
				} else {
					$this->session->success = $merchant_title . ' ' . Status_updated;
					return true;
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_category_Id;
				$this->redirector->gotoSimple('list','merchant','admin',array());	
			}
			
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Delete the existing merchant image
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function deleteimage(Array $params) {
		try{
			//print_r($params);exit;
			$merchant_id = trim($params['merchant_id']);
			$merchant_image_id = trim($params['merchant_image_id']);
			$action = trim($params['action']);
			
			if($merchant_id!='' && $merchant_id!=0 && $this->validate_numeric($merchant_id)) {				
				
				$mess = $this->merchantdb->changeStatusToDelete($merchant_id, $merchant_image_id, $action, $this->session->userid);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_deleted; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Category_Id;				
				$this->redirector->gotosimple('edit','merchant','admin',array("merchant_id"=>$merchant_id));	
			}			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
}
?>
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

//class Application_Model_Category extends Application_Model_Validation {
class Application_Model_Category extends Application_Model_Categorydb {
	
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
	
		$this->categorydb = new Application_Model_Categorydb();	
	
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
     * Purpose: Fetches all the categories
     *
     * Access is public
     * 
     * @return  
     */
	
	public  function getCaregorySearch(Array $params) {
		try{

			$viewObject = $this->viewobj;		
			$cond = '';			
			if(isset($params['start']) && $params['start'] != '') {
				$start = $params['start'];
				
			} else {
				$start = 0;
			}						
			$icategory_name = '';
			
			$controller = Zend_Controller_Front::getInstance();
			$request=$controller->getRequest();						
			
			$iLimit = $this->config->site->pagination->limit;			
			$iStart = $start;
			
			$category_count = $this->categorydb->getCategoryCount($icategory_name);
			$category_list = $this->categorydb->getCategoryList($icategory_name, $iStart, $iLimit);
			
			$viewObject->category_count=$category_count;
			$viewObject->category_list = $category_list;
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
	
	public  function createCategory(Array $params) {
		try{
			/*echo "sadsadsa";
			print_r($params);
			exit;*/
			if(isset($params['category_name'])){ $category_name = trim($params['category_name']);}
			if(isset($params['category_image'])){ $category_image = trim($params['category_image']);}
			if(isset($params['parent_category_id'])){ $parent_category_id = trim($params['parent_category_id']);}
			if(isset($params['category_meta_title'])){ $category_meta_title = trim($params['category_meta_title']);}
			if(isset($params['category_meta_description'])){ $category_meta_description = trim($params['category_meta_description']);}
			if(isset($params['action'])){ $action = trim($params['action']);}

			if(isset($params['parent_category_id']) && trim($params['parent_category_id'])!=''){
				$conditionAllreadyExists = " AND parent_category_id='".$params['parent_category_id']."'";
			}else{
				$conditionAllreadyExists = " AND parent_category_id='0'";
			}
			/*
			 * Validation 
			 */		
			$error = 0;
			
			/*print_r($this->error->error_createuser_values);
			exit;*/
            if($category_name == '') {				//Validation for category_name
            	$this->error->error_create_category_name = Error_Create_category_name_empty;
            	$error = 1;
            	//return false;
            } else if(!$this->validate_alphanumeric_space($category_name)) {
            	$params['category_name'] = '';
            	$this->error->error_create_category_name = Error_Create_category_name_invalid;
            	$error = 1;
            	//return false;
            } else if(strlen($category_name) >20) {
            	$this->error->error_create_category_name = Error_Create_category_name_min;
            	$error = 1;
            } else if(strlen($category_name) < 3) {
            	$this->error->error_create_category_name = Error_Create_category_name_max;
            	$error = 1;
            } else if($this->checkAllreadyExists('store_categories','category_name',$category_name,'','',$conditionAllreadyExists)>=1) { 
				// Table, column, value, recordid
				$this->error->error_create_category_name = Error_Create_category_AllreadyExists;
				$error = 1;
			}
            
			
            
            if($error == 1) {
            	$this->error->error_createcategory_values = $params;
            	$error = 0;
            	return false;
            }
          
            /*
             * Validation ends here
             */

				$outpt = $this->categorydb->saveCategory($parent_category_id, $category_name, $category_meta_title,$category_meta_description, $action, $this->session->userid);
				$outpt = $outpt[0];
				$result = explode('#', $outpt['toutput']);
								/*
								$my_request_uri=explode("index.php",$_SERVER['SCRIPT_NAME']);		 		
								$MyProjectRoot = $my_request_uri['0'];
								$upload = new Zend_File_Transfer();
			    				$name = $upload->getFileName();
			    				
			    				if(!is_array($name)){
									$filename = time().'-'.basename($name);
			    					$upload->addFilter('Rename', 'http://'.$_SERVER['HTTP_HOST'].''.$MyProjectRoot.'public/uploads/category_images/'.$filename, 1);									
			    					$upload->receive();			    				
			    					$LogoSet = $this->categorydb->updateLogoRecord($result[1],$filename, $action, $this->session->userid);
			    				}
								*/
								
								$upload = new Zend_File_Transfer();                                    
								//$upload = new Zend_File_Transfer_Adapter_Http();                                
								$files = $upload->getFileInfo();
								foreach ($files as $file => $info) {
									if($upload->isValid($file)){
										$filename = time().$info['name'];
										$upload->addFilter('Rename', APPLICATION_PATH.'/../public/uploads/category_images/'.$filename, 1);
										$upload->receive($file);
										$LogoSet = $this->categorydb->updateLogoRecord($result[1],$filename, $action, $this->session->userid);
									}
								}
								
				
				
				if($result[0] == 1) {
					$this->session->success = Success_creation . ' category with Category Title ' . $category_name ;
					return true;
				} else {
					$this->error->error = Failure_creation . ' category with Category Title ' . $category_name ;
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	/**
     * Purpose: To Lock the existing Active Category
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function lock(Array $params) {
		try{
			$categoryId = trim($params['categoryId']);
			$action = trim($params['action']);
			$lock = 1;
			$unlock = 0;
			$delete = 0;
			if($categoryId!='' && $categoryId!=0 && $this->validate_numeric($categoryId)) {

				$mess = $this->categorydb->changeStatus($categoryId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);			
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_locked; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Category_Id;				
				$this->redirector->gotosimple('list','category','admin',array());	
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: To Unlock the existing Locked category
     *
     * Access is public
     *
     * @param
     * 
     * @return  
     */
	public function unlock(Array $params) {
		try{
			$categoryId = trim($params['categoryId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 1;
			$delete = 0;
			if($categoryId!='' && $categoryId!=0 && $this->validate_numeric($categoryId)) {				
				
				$mess = $this->categorydb->changeStatus($categoryId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_unlocked; 
				}
			
			}else{
				$this->session->validateerror= Error_Invalid_Category_Id;				
				$this->redirector->gotosimple('list','category','admin',array());
			}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Delete the existing category
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function delete(Array $params) {
		try{
			$categoryId = trim($params['categoryId']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 0;
			$delete = 1;
			if($categoryId!='' && $categoryId!=0 && $this->validate_numeric($categoryId)) {				
				
				$mess = $this->categorydb->changeStatus($categoryId, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_deleted; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Category_Id;				
				$this->redirector->gotosimple('list','category','admin',array());	
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
	public function updateCategoryDetails(Array $params) {
		try{
			
			$categoryId 			= trim($params['categoryId']);
			$category_name 			= trim($params['category_name']);
			$action 				= trim($params['action']);
			if(isset($params['category_image'])){$category_image 		= trim($params['category_image']);}
			$parent_category_id 	= trim($params['parent_category_id']);
			$category_meta_title 	= trim($params['category_meta_title']);
			$category_meta_description = trim($params['category_meta_description']);			
			$admin = $this->session->userid;
			
			if(isset($params['parent_category_id']) && trim($params['parent_category_id'])!=''){
				$conditionAllreadyExists = " AND parent_category_id='".$params['parent_category_id']."'";
			}else{
				$conditionAllreadyExists = " AND parent_category_id='0'";
			}
			
			/*
			 * Validation for update category
			 * 				  
			 */
			$error = 0;
			
			if($categoryId!='' && $categoryId!=0 && $this->validate_numeric($categoryId)) {
				 
				if($category_name == '') {				//Validation for firstname
					$this->error->error_updatecategory_name = Error_update_category_name_empty;
					$error = 1;
				} else if(!$this->validate_alphanumeric_space($category_name)) {
					$params['category_name'] = '';
					$this->error->error_updatecategory_name = Error_update_category_name_invalid;
					$error = 1;
				} else if(strlen($category_name) >20) {
					$this->error->error_updatecategory_name = Error_update_category_name_max;
					$error = 1;
				} else if($this->checkAllreadyExists('store_categories','category_name',$category_name,'category_id',$categoryId,$conditionAllreadyExists)>=1) { 
					// Table, column, value, recordid
					$this->error->error_updatecategory_name = Error_update_category_name_AllreadyExists;
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
					$this->error->error_updatecategory_values = $params;
					$error = 0;
					return false;
				}
				
				/*
				 * Validation ends here
				 */            
				
			
				$mess = $this->categorydb->categoryDetailsUpdate($categoryId, $action, $category_name, $parent_category_id, $category_meta_title, $category_meta_description, $this->session->userid);
				$messs = explode('#',$mess[0]['tmess']);
				
								//$upload = new Zend_File_Transfer();                                    
								$upload = new Zend_File_Transfer_Adapter_Http();                                
								$files = $upload->getFileInfo();
								foreach ($files as $file => $info) {
									if($upload->isValid($file)){
										$filename = time().$info['name'];
										$upload->addFilter('Rename', APPLICATION_PATH.'/../public/uploads/category_images/'.$filename, 1);
										$upload->receive($file);
										$LogoSet = $this->categorydb->updateLogoRecord($categoryId,$filename, $action, $this->session->userid);
									}
								}
								
				//print_r($messs);exit;
				if($messs[0] == 0) {
					$this->error->error = Status_failed_updated . $category_name;
					return false; 
				} else {
					$this->session->success = $category_name . ' ' . Status_updated;
					return true;
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_category_Id;
				$this->redirector->gotoSimple('list','category','admin',array());	
			}
			
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: To Delete the existing category image
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
			$category_id = trim($params['category_id']);
			$category_image_id = trim($params['category_image_id']);
			$action = trim($params['action']);
			
			if($category_id!='' && $category_id!=0 && $this->validate_numeric($category_id)) {				
				
				$mess = $this->categorydb->changeStatusToDelete($category_id, $category_image_id, $action, $this->session->userid);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' ' . Status_deleted; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Category_Id;				
				$this->redirector->gotosimple('edit','category','admin',array("category_id"=>$category_id));	
			}			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}
?>
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

class Application_Model_Products extends Application_Model_Validation {
	
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
	
		$this->productsdb = new Application_Model_Productsdb();
		
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
     * Purpose: Creates user and also used for updation of his profile and returns an a boolean value of status
     *
     * Access is public
     *
     * @param	Array	$params Create user parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function createProduct(Array $params) {
		try{
			/*
			print_r($params);
			exit;*/			
			$product_title				= trim($params['product_title']);			
			$product_sku				= trim($params['product_sku']);
			$product_meta_title			= trim($params['product_meta_title']);
			$product_meta_description	= trim($params['product_meta_description']);
			$product_small_description	= trim($params['product_small_description']);
			$product_description		= trim($params['product_description']);	
			$attributes_group_id		= trim($params['attributes_group_id']);
			$action 					= trim($params['action']);
			

			
			/*
			 * Validation
			 * 				 
			 */		
			$error = 0;
			
			
            if($product_title == '') {				//Validation for product_title
				$this->error->error_create_product_title = Error_create_product_title_empty;
				$error = 1;
			} else if(!$this->validate_alphanumeric_space($product_title)) {
				$params['product_title'] = '';
				$this->error->error_create_product_title = Error_create_product_title_invalid;
				$error = 1;
			} else if(strlen($product_title) >20) {
				$this->error->error_create_product_title = Error_create_product_title_max;
				$error = 1;
			}
			
          
            
            if($error == 1) {
            	$this->error->error_createproduct_values = $params;
            	$error = 0;
            	return false;
            }
          
            /*
             * Validation ends here
             */
	
				$outpt = $this->productsdb->saveProduct($product_title,$product_sku,$product_meta_title,$product_meta_description,$product_small_description,$product_description, $attributes_group_id, $action, $this->session->userid);
				$outpt = $outpt[0];
				$result = explode('#', $outpt['toutput']);
				
				
				if($result[0] == 1) {					
					$this->session->success = Success_user_creation . ' with Product Title ' . $product_title ;
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' with Product Title ' . $product_title ;
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Fetches all the products
     *
     * Access is public
     *
     * @return  
     */
	
	public  function getProductSearch(Array $params) {
		try{

			$viewObject = $this->viewobj;		
			$cond = '';			
			if(isset($params['start']) && $params['start'] != '') {
				$start = $params['start'];
				
			} else {
				$start = 0;
			}						
			$iproduct_title = '';
			
			$controller = Zend_Controller_Front::getInstance();
			$request=$controller->getRequest();						
			
			$iLimit = $this->config->site->pagination->limit;			
			$iStart = $start;
			
			$products_count = $this->productsdb->getProductsCount($iproduct_title);
			$products_list = $this->productsdb->getProductsList($iproduct_title, $iStart, $iLimit);
			
			$viewObject->products_count=$products_count;
			$viewObject->products_list = $products_list;
			$viewObject->iStart = $iStart;
			$viewObject->iLimit = $iLimit;
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	/**
     * Purpose: Creates product images
     *
     * Access is public
     *
     * @param	Array	$params Create product image parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function updateProductImages(Array $params) {
		try{
			
			//print_r($params);
			//exit;		
				$action 	= trim($params['action']);				
				$productId 	= trim($params['productId']);
				
								
								$upload = new Zend_File_Transfer();                                    
								//$upload = new Zend_File_Transfer_Adapter_Http();                                
								$files = $upload->getFileInfo();
								//print_r($files);exit;
								foreach ($files as $file => $info) {
									if($upload->isValid($file)){
										$filename = time().$info['name'];
										$upload->addFilter('Rename', APPLICATION_PATH.'/../public/uploads/product_images/'.$filename, 1);
										$upload->receive($file);
										//$LogoSet = $this->productsdb->updateProductImagesRecord($productId,$filename, $action, $this->session->userid);
										$filename_str .= $filename."#";
									}
								}
								
								
								
				$ProductImageSet = $this->productsdb->updateProductImagesRecord($productId,$filename_str, $action, $this->session->userid);
				//print_r($ProductImageSet);exit;
				
				if(trim($ProductImageSet['0']['toutput']) == '') {					
					$this->session->success = Success_user_creation . ' product images with Product Image Title ' . str_replace('#',', ',substr($filename_str,0,-1)) ;
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' product images with Product Image Title ' . str_replace('#',', ',substr($filename_str,0,-1)) ;
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: To Delete the existing product image
     *
     * Access is public
     *
     * @param
     * 
     * @return 
     */
	public function deleteimage(Array $params) {
		try{
			$productId = trim($params['productId']);
			$product_image_id = trim($params['product_image_id']);
			$action = trim($params['action']);
			$lock = 0;
			$unlock = 0;
			$delete = 1;
			if($product_image_id!='' && $product_image_id!=0 && $this->validate_numeric($product_image_id)) {				
				
				$mess = $this->productsdb->changeStatus($product_image_id, $action, $this->session->userid, $lock, $unlock, $delete);
				$mess = explode('#',$mess['@omess']);
				if($mess[0] == 1) {
					$this->session->success = $mess[1] . ' Image ' . Status_deleted; 
				}
				
			}else{
				$this->session->validateerror= Error_Invalid_Product_Id;				
				$this->redirector->gotosimple('list','products','admin',array());	
			}			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Creates product images
     *
     * Access is public
     *
     * @param	Array	$params Create product image parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function updateProductPrices($productId,$action,$product_price_id,$product_price_description,$product_price,$product_discount,$product_discount_type,$discount_start_date,$discount_end_date) {
		try{
			
			//print_r($params);
			//exit;		
				//$action 	= trim($params['action']);				
				//$productId 	= trim($params['productId']);
				
				$ProductImageSet = $this->productsdb->updateProductPriceRecord($productId, $product_price_id, $product_price_description, $product_price, $product_discount, $product_discount_type, $discount_start_date, $discount_end_date, $action, $this->session->userid);
				//print_r($ProductImageSet);exit;
				
				if(trim($ProductImageSet['0']['toutput']) == '') {					
					$this->session->success = Success_user_creation . ' product prices with New Product prices';
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' product prices with New Product prices';
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates product images
     *
     * Access is public
     *
     * @param	Array	$params Create product image parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function updateProductCategories($productId,$product_category_str,$action) {
		try{
			
			//print_r($params);
			//exit;		
				//$action 	= trim($params['action']);				
				//$productId 	= trim($params['productId']);
				
				$ProductImageSet = $this->productsdb->updateProductCategoriesRecord($productId,$product_category_str,$action, $this->session->userid);
				//print_r($ProductImageSet);exit;
				
				if(trim($ProductImageSet['0']['toutput']) == '') {					
					$this->session->success = Success_user_creation . ' product categories';
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' product categories';
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Creates product attribute values
     *
     * Access is public
     *
     * @param	Array	$params Create product image parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function updateProductAttributes($productId,$action,$attribute_key_str,$attribute_value_str,$attribute_value_id_str) {
		try{
			
			//print_r($params);
			//exit;		
				//$action 	= trim($params['action']);				
				//$productId 	= trim($params['productId']);
				
				$ProductImageSet = $this->productsdb->updateProductAttributesRecord($productId, $action, $attribute_key_str, $attribute_value_str, $attribute_value_id_str, $this->session->userid);
				//print_r($ProductImageSet);exit;
				
				if(trim($ProductImageSet['0']['toutput']) == '') {					
					$this->session->success = Success_user_creation . ' product categories';
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' product categories';
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates product images
     *
     * Access is public
     *
     * @param	Array	$params Create product image parameters
     * 
     * @return  object	Returns a boolean of status.
     */
	
	public  function updateProductGeneralInfo($params) {
		try{
			
			/*print_r($params);
			exit;*/	
				$action 	= trim($params['action']);				
				$productId 	= trim($params['productId']);
				$product_title = trim($params['product_title']);
				$product_sku = trim($params['product_sku']);
				$product_meta_title = trim($params['product_meta_title']);
				$product_meta_description = trim($params['product_meta_description']);
				$product_small_description = trim($params['product_small_description']);
				$product_large_description = trim($params['product_large_description']);
								
				$ProductImageSet = $this->productsdb->updateProductGeneralInfoRecord($productId, $product_title, $product_sku, $product_meta_title, $product_meta_description, $product_small_description, $product_large_description,$action, $this->session->userid);
				//print_r($ProductImageSet);exit;
				$result = explode('#',$ProductImageSet['0']['toutput']);
				
				if(trim($result['0']) == '1') {					
					$this->session->success = Success_user_creation . ' product information with New Product Information';
					return true;
				} else {
					$this->error->error = Failure_user_creation . ' product information with New Product Information';
					return false;
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	

	

}
?>
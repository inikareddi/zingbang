<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	ProductController.php 
* Module	:	Admin Module - Product's Management
* Owner		:	RAM's 
* Purpose	:	This class is used for product management operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Admin_ProductsController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $products;			// used for creating an instance of model, Access is with in the class
	private $productsdb;		// used for creating an instance of model, Access is with in the class
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     * 			and creates an instance of the model class 'Application_Model_Users'
     * 			and creates an instance of the model class 'Application_Model_Userdb'
     * 			This will every time check whether user has logged in or not
     * 			If not, user will be redirected to login screen
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function init() {
           
		$this->session = new Zend_Session_Namespace('MyPortal');               
		//$this->error = new Zend_Session_Namespace('MyPortalerror');
		
		$this->products = new Application_Model_Products();
		$this->productsdb = new Application_Model_Productsdb();		
		
		$user = new Application_Model_Users();
		$user->check();		
		//print_r($this->session);
				
		if(!$this->session->loggedIn) {
			$this->_redirect('admin/');	
		}             
		
		$this->_helper->layout->setLayout($this->session->layout);
	}	
	
	/**
     * Purpose: user will be redirected to user addition page.
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{
			$this->_redirect('admin/produst/list');
		} catch (Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	

	/**
     * Purpose: User listing page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function listAction() { 
		try{
			$params = $this->_getAllParams();			
			$this->view->title = 'Products List';                       
			$this->products->getProductSearch($params);
			$this->view->merchantlist = $this->productsdb->getMerchantList();			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: User addition page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function registerAction() {
		try{
		
			$this->view->title = "Create Product";
			$params = $this->_getAllParams();	
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();
			
			if ($request->isPost()) {
			
				if(!$this->products -> createProduct($params)) {					
					//$this->_redirect('admin/products/register');					
				} else {
					$this->_redirect('admin/products/list');
				}
			}		
			$this->view->attributegroupslist = $this->productsdb->getAttributeGroupsList();
			$this->view->merchantlist = $this->productsdb->getMerchantList();
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: User addition page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function editAction() {
		try{
			$request = $this->getRequest();			
			$Request_Values = $request->getPost();
			$productId = $request->getParam('productId');
			$this->view->productId = $productId;
			$params = $this->_getAllParams();	
			
			//print_r($Request_Values);exit;
			
			
			
			if ($request->isPost() && isset($Request_Values['product_general_submit']) && $Request_Values['product_general_submit']=='Save') {			
				if(!$this->products -> updateProductGeneralInfo($params)) {					
					//$this->_redirect('admin/products/edit/productId/'.$productId);					
				} else {
					$this->_redirect('admin/products/list');
				}
			}
			
			
			
			if ($request->isPost() && isset($Request_Values['product_image_submit']) && $Request_Values['product_image_submit']=='Save') {			
				if(!$this->products -> updateProductImages($params)) {					
					//$this->_redirect('admin/products/edit/productId/'.$productId);					
				} else {
					$this->_redirect('admin/products/list');
				}
			}
			
			
			
			if ($request->isPost() && isset($Request_Values['product_categories_submit']) && $Request_Values['product_categories_submit']=='Save') {			
				$action 	= trim($params['action']);				
				$productId 	= trim($params['productId']);
				$product_category_str = implode("#",$params['product_category'])."#"; 
				
				
				if(!$this->products -> updateProductCategories($productId,$product_category_str,$action)) {					
					//$this->_redirect('admin/products/edit/productId/'.$productId);					
				} else {
					$this->_redirect('admin/products/list');
				}
			}
			
			
			
			
			if ($request->isPost() && isset($Request_Values['product_prices_submit']) && $Request_Values['product_prices_submit']=='Save') {			
				/*echo "<pre>";
				print_r($params);exit;*/				
				$product_price_id 			= implode('#',$params['product_price_id'])."#";
				$product_price_description 	= implode('#',$params['product_price_description'])."#";
				$product_price 				= implode('#',$params['product_price'])."#";
				$product_discount 			= implode('#',$params['product_discount'])."#";
				$product_discount_type 		= implode('#',$params['product_discount_type'])."#";
				$product_stock 				= implode('#',$params['product_stock'])."#";
				
				//print_r($params['discount_start_date']);exit;
				foreach($params['discount_start_date'] as $key=>$value){
					if(trim($value)!=''){
					$discount_start_date_array[] = date('Y-m-d', strtotime($value));
					}else{
					$discount_start_date_array[] ='';
					}
				}				
				$discount_start_date 		= implode('#',$discount_start_date_array)."#";
				
				foreach($params['discount_end_date'] as $key=>$value){
					if(trim($value)!=''){
					$discount_end_date_array[] = date('Y-m-d', strtotime($value));
					}else{
					$discount_end_date_array[] ='';
					}
				}
				$discount_end_date 			= implode('#',$discount_end_date_array)."#";
				
				$action 	= trim($params['action']);				
				$productId 	= trim($params['productId']);
				
				if(!$this->products -> updateProductPrices($productId,$action,$product_price_id,$product_price_description,$product_price,$product_discount,$product_discount_type,$product_stock,$discount_start_date,$discount_end_date)) {					
					//$this->_redirect('admin/products/edit/productId/'.$productId);					
				} else {
					$this->_redirect('admin/products/list');
				}
			}
			
			
			
			
			if ($request->isPost() && isset($Request_Values['product_attributes_submit']) && $Request_Values['product_attributes_submit']=='Save') {			
				//echo "<pre>";
				//print_r($params);exit;
				
				$attribute_key_str = '';
				$attribute_value_str = '';
				
				$action 	= trim($params['action']);				
				$productId 	= trim($params['productId']);
				
				foreach($params['attribute_value'] as $key=>$value){
					$attribute_key_str .= $key.'@#@#@';
					$attribute_value_str .= $value.'@#@#@';
				}
				foreach($params['attribute_value_id'] as $key=>$value){					
					$attribute_value_id_str .= $value.'@#@#@';
				}
				
				
				if(!$this->products -> updateProductAttributes($productId,$action,$attribute_key_str,$attribute_value_str,$attribute_value_id_str)) {					
					//$this->_redirect('admin/products/edit/productId/'.$productId);					
				} else {
					$this->_redirect('admin/products/list');
				}
			}
			
			
			/* Dispaly Details */
			$ProductDetails = $this->productsdb->getProductDetails($productId);
			$ProductLargeDescription = $this->productsdb->getProductLargeDescription($productId);
			$this->view->ProductDetails = $ProductDetails;
			$this->view->ProductLargeDescription = $ProductLargeDescription;
			$this->view->CategoryList = $this->productsdb->getCategoryList();			
			$this->view->ProductImages = $this->productsdb->getProductImagesList($productId);
			$this->view->ProductPrices = $this->productsdb->getProductPrices($productId);
			$this->view->ProductCategories = $this->productsdb->getProductCategories($productId);
			$this->view->ProductAttributesTitles = $this->productsdb->getProductAttributesTitles($ProductDetails['attributes_group_id']);
			$this->view->AllAttributesSetsTitles = $this->productsdb->getAllAttributesSetsTitles();
			$this->view->ProductAttributesValues = $this->productsdb->getProductAttributesValues($productId);
			$this->view->merchantlist = $this->productsdb->getMerchantList();
			
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	
	/**
     * Purpose: To delete the product image
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function deleteimageAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			$params = $this->_getAllParams();
			$this->products->deleteimage($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Lock the product
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function lockAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			
			$params = $this->_getAllParams();
			$this->products->lock($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: To Unlock the locked product
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function unlockAction() {
		try{
			
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			
				$params = $this->_getAllParams();
				$this->products->unlock($params);
				$this->_redirect($_SERVER['HTTP_REFERER']);
				//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To delete the product
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
		
	public function deleteAction() {
		try{
			/*$refurl1=$_SERVER['HTTP_REFERER'];
			$refurl=explode("/", $refurl1);
			if($refurl[4]!='usermanagement' && $refurl[5]!='user' && $refurl[6]!='list' ){
					$this->_redirect("/default/error/accessdenied");
			}else{*/
			$params = $this->_getAllParams();
			$this->products->delete($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}


?>
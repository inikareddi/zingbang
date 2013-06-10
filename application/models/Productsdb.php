<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Productsdb.php 
* Module	:	User Management Module
* Owner		:	RAM's 
* Purpose	:	This class is used for user management related database operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

//class Application_Model_Productsdb extends Application_Model_DataBaseOperations {
class Application_Model_Productsdb extends Application_Model_Validation {
	
	public $session;
	private $error;
	
	/**
     * Purpose: Constructor sets sessions for portal and portalerror
     *
     * Access is limited to class and extended classes
     *
     * @param   
     * @return  
     */
	
		
	public function __construct(){
		$this->session = new Zend_Session_Namespace('MyPortal');
		$this->error = new Zend_Session_Namespace('MyPortalerror');
	}	
	
	
	
	/**
     * Purpose: Fetching Active categories name and returns array of list of categories 
     *
     * Access is limited to class and extended classes     *
    
     * @return  object	Returns status message.	
     */
	
	public function getCategoryList(){
		try {
			parent::SetDatabaseConnection();		
			$query = "SELECT * FROM store_categories where statusid=1 order by parent_category_id ASC ";
			//yexit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates product and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function saveProduct($product_title,$product_sku,$product_meta_title,$product_meta_description,$product_small_description,$product_description, $attributes_group_id, $merchant_id, $action, $adminid){
		try {
			parent::SetDatabaseConnection();
			
			$query = "call SPproductadd('" . $product_title . "', '" . $product_sku . "', '" . $product_meta_title . "', '" . $product_meta_description . "', '" . $product_small_description . "', '" . $product_description . "', '".$attributes_group_id."', '".$merchant_id."', '" .  $action . "', '" .  $adminid . "')";
			//exit;
			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	

	
	
	
	
	/**
     * Purpose: Returns all Attributes Groups 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getAttributeGroupsList(){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT * FROM store_products_attributes_groups pag where statusid=1";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Returns all Merchants 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getMerchantList(){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT merchant_id, merchant_title FROM `store_merchants` where statusid=1 ORDER BY merchant_title ASC";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	
	/**
     * Purpose: Fetching products 
     *
     * Access is limited to class and extended classes
     *
     * @param	int		$istart Start value
     * @param	int		$ilimit Limit value for fetching result set
     * @param	varchar	$cond Search condition
     * @return  object	Returns status message.	
     */
	
	public function getProductsList($iproduct_title, $istart, $ilimit){
		try {
			parent::SetDatabaseConnection();		
			$query = "call SPproductslist('" . $iproduct_title . "', " . $istart . ", " . $ilimit . ")";
			//exit;
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Get total count of products
     *
     * Access is limited to class and extended classes
     *
     * @param	varchar	$cond Search condition
     * @param	int		$iuserid Present logged in userid
     * @return  object 	user details of supplied userid.	
     */
	
	public function getProductsCount($iproduct_title){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPproductscount('" . $iproduct_title . "')";
			//exit;
			return Application_Model_Db::getValue($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}






	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getProductImagesList($productId){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT * FROM store_products_images where product_id=".$productId." AND statusid=1";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}






	/**
     * Purpose: Creates Category and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function updateProductImagesRecord($product_id, $filename, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPproductaddimages('" . $product_id . "', '" . $filename . "', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates Category and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function updateProductHomePageImagesRecord($product_id, $product_imagehome_radio, $product_imagethumbnail_radio, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPproducthomepageimage('" . $product_id . "', '" . $product_imagehome_radio . "', '" . $product_imagethumbnail_radio . "', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Used to change the product image status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	merchant details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	public function imageChangeStatus($productId, $iaction, $iadminuserid, $ilockstatus=0, $iunlockstatus=0, $ideletestatus=0){
		try {
			parent::SetDatabaseConnection();			
			
			/*
			 *  To Lock the user, $ilockstatus must be set to 1
			 *  
			 *  To Unlock the user, $iunlockstatus must be set to 1
			 *  
			 *  To Delete the user, $ideletestatus must be set to 1
			 */
			
			$query = "call SPproductimagechangestatus(" . $productId . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
			//exit;
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getProductPrices($productId){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT * FROM store_products_price where product_id=".$productId." AND statusid=1 ORDER BY product_price_id DESC";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates Category and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function updateProductPriceRecord($productId, $product_price_id, $product_price_description, $product_price, $product_discount, $product_discount_type, $product_stock, $discount_start_date, $discount_end_date, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPproductaddprices('" . $productId . "', '" . $product_price_id . "', '" . $product_price_description . "', '" . $product_price . "', '" . $product_discount . "', '" . $product_discount_type . "', '" . $product_stock . "', '" . $discount_start_date . "', '".$discount_end_date."', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates Category and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function updateProductCategoriesRecord($productId,$product_category_str,$action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPproductaddcategories('" . $productId . "', '" . $product_category_str . "', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getProductCategories($productId){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT * FROM store_products_categories where product_id=".$productId." AND statusid=1";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getProductDetails($productId){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT
						sp.product_id,
						sp.attributes_group_id,
						sp.merchant_id,
						sp.product_sku,
						sp.product_title,
						sp.product_small_description,
						sp.product_meta_title,
						sp.product_meta_description,
						spag.attributes_group_title
						FROM store_products sp, store_products_attributes_groups spag
						where
						sp.attributes_group_id = spag.attributes_group_id
						AND sp.product_id=".$productId."
						AND sp.statusid=1";	
			
			$opt = Application_Model_Db::getRow($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getProductLargeDescription($productId){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT * FROM store_products_description where product_id = ".$productId." AND statusid = 1;";	
			
			$opt = Application_Model_Db::getRow($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getProductAttributesTitles($attributes_group_id){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT
						pag.attributes_group_id, pag.attributes_group_title,
						pas.attributes_set_id, pas.attributes_set_title,
						pasm.attributes_sets_mapping_id,
						pa.attribute_id, pa.attribute_title, pa.attribute_field_type, pa.attribute_data_type
						FROM
						store_products_attributes_groups pag,
						store_products_attributes_sets pas,
						store_products_attributes_sets_mapping pasm,
						store_products_attributes pa
						where
						pag.attributes_group_id = pas.attributes_group_id
						AND pas.attributes_set_id = pasm.attributes_set_id
						AND pasm.attribute_id = pa.attribute_id
						AND pag.attributes_group_id = '".$attributes_group_id."'
						AND pag.statusid = 1
						AND pas.statusid = 1
						AND pasm.statusid = 1
						AND pa.statusid = 1
						ORDER BY pas.attributes_set_title,pa.attribute_title ASC";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getAllAttributesSetsTitles(){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT * FROM store_products_attributes_sets where statusid=1 ORDER BY attributes_set_title ASC";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Creates Product and returns status of the user creation process 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function updateProductAttributesRecord($productId, $action, $attribute_key_str, $attribute_value_str, $attribute_value_id_str, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPproductaddattributevalues('" . $productId . "', '" . $attribute_key_str . "', '" . $attribute_value_str . "', '" . $attribute_value_id_str . "', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Returns Product Images 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns All Attributes Groups List.	
     */
	public function getProductAttributesValues($productId){
		try {
			parent::SetDatabaseConnection();			
			$query = "SELECT * FROM store_products_attributes_values where product_id = ".$productId." AND statusid=1";			
			$opt = Application_Model_Db::getResult($query);
			return $opt;			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Product information update 
     *
     * Access is limited to class and extended classes
     *    
     * @return  object	Returns status message.	
     */
	public function updateProductGeneralInfoRecord($productId, $product_title, $product_sku, $product_meta_title, $product_meta_description, $product_small_description, $product_large_description, $merchant_id, $action, $adminid){
		try {
			parent::SetDatabaseConnection();			
			$query = "call SPproductupdate('" . $productId . "', '" . $product_title . "', '" . $product_sku . "', '" . $product_meta_title . "', '" . $product_meta_description . "', '" . $product_small_description . "', '" . $product_large_description . "', '" . $merchant_id . "', '" . $action . "', " . $adminid . ")";
			//exit;			
			return Application_Model_Db::getResult($query); 
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Used to change the merchant status like Active, Locked and Deleted 
     *
     * Access is limited to class and extended classes
     *
     * @param
     * @return  object 	merchant details of supplied userid.	
     * 
     * 
     * Under testing phase
     */
	
	public function changeStatus($productid, $iaction, $iadminuserid, $ilockstatus=0, $iunlockstatus=0, $ideletestatus=0){
		try {
			parent::SetDatabaseConnection();			
			
			/*
			 *  To Lock the user, $ilockstatus must be set to 1
			 *  
			 *  To Unlock the user, $iunlockstatus must be set to 1
			 *  
			 *  To Delete the user, $ideletestatus must be set to 1
			 */
			
			$query = "call SPproductchangestatus(" . $productid . ", " . $ilockstatus . ", " . $iunlockstatus . ", " . $ideletestatus . ", '" . $iaction . "', " . $iadminuserid . ", @omess)";
			//exit;
			Application_Model_Db::execute($query);
		 	return Application_Model_Db::getRow("select @omess");
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	

}
?>
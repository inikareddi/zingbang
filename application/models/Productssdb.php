<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Productssdb.php 
* Module	:	Product Management Module
* Owner		:	RAM's 
* Purpose	:	This class is used for product management related database operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Productssdb extends Application_Model_DataBaseOperations {
	
	public $session;
	private $error;
	public $viewobj;
	
	
	/**
     * Purpose: Constructor sets sessions for portal and portalerror
     *
     * Access is limited to class and extended classes
     *
     * @param   
     * @return  
     */
	
		
	public function __construct(){
		$this->session = new Zend_Session_Namespace('MyClientPortal');
		$this->error = new Zend_Session_Namespace('MyClientPortalerror');
	}
	
	

	
	/**
     * Purpose: Fetching product list
     *
     * Access is limited to class and extended classes
     *
     * @param   int		$iuserid User Id
     * @param	int		$istart Start value
     * @param	int		$ilimit Limit value for fetching result set
     * @param	varchar	$cond Search condition
     * @return  object	Returns status message.	
     */
	
	public function getProductsList($params){
		try {	
			parent::SetDatabaseConnection();
			$query = "select sp.*
						from
						store_products sp LEFT JOIN store_products_categories spc ON (sp.product_id=spc.product_id)
						where spc.category_id = ".$params['id']." AND sp.statusid=1;";
			//exit;			
			return Application_Model_Db::getResult($query);
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
}
?>
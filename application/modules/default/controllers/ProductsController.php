<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	ProductsController.php 
* Module	:	Default - Product Module
* Owner		:	RAM's 
* Purpose	:	This class is used for common user operations for all user types
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class ProductsController extends Zend_Controller_Action { 
	public $session;	// used for managing session with NAMESPACE portal
	public $error;		// used for managing session with NAMESPACE portalerror
	private $productss;		// used for creating an instance of model, Access is with in the class	
	private $productssdb;
	
	/**
     * Purpose: Initiates sessions with Namespace 'portal' and 'portalerror' 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function init() { 	
		$this->productss = new Application_Model_Productss();
		$this->productssdb = new Application_Model_Productssdb();
        $this->_helper->layout->setLayout('default/layout');
		//$this->setLayoutAction('default/layout');		
	}
	
    
	
	/**
     * Purpose: Index action
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function indexAction() {
		try{
			$this->_redirect('default/products/list');
			exit;			
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Index action
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function listAction() {
		try{
			$this->view->title = 'Products List';			
			
			$params = $this->_getAllParams();			
			/*
			$request = $this->getRequest();
			$Request_Values = $request->getGet();
			print_r($Request_Values);
			*/
			
			$ProductsList = $this->productssdb->getProductsList($params);			
			$this->view->ProductsList = $ProductsList;
			//exit;			
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
}
?>
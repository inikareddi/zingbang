<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	CategoriesController.php 
* Module	:	Default - Category Module
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

class CategoriesController extends Zend_Controller_Action { 
	public $session;	// used for managing session with NAMESPACE portal
	public $error;		// used for managing session with NAMESPACE portalerror
	private $categories;		// used for creating an instance of model, Access is with in the class	
	private $categoriesdb;
	
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
		/*echo "store/index/init";
		exit;  */		
		$this->categories = new Application_Model_Categories();
		$this->categoriesdb = new Application_Model_Categoriesdb();
        $this->_helper->layout->setLayout('default/layout');
		//$this->setLayoutAction('store/layout');		
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
			//$this->_helper->viewRenderer->setNoRender(true);
			$this->_helper->layout->disableLayout();
			$CategoriesList = $this->categoriesdb->getCategoriesList();
			//print_r($CategoriesList);exit;
			$this->view->CategoriesList = $CategoriesList;
			//exit;			
		}catch (Exception $e){
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}
?>
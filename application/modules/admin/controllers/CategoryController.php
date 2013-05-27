<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	CategoryController.php 
* Module	:	Admin Module - Merchant's Management
* Owner		:	RAM's 
* Purpose	:	This class is used for Marchant management operations
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Admin_CategoryController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $category;			// used for creating an instance of model, Access is with in the class
	private $categorydb;		// used for creating an instance of model, Access is with in the class
	
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
		
		$this->category = new Application_Model_Category();
		$this->categorydb = new Application_Model_Categorydb();		
		
		$user = new Application_Model_Users();
		$user->check();
				
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
			$this->_redirect('admin/category/list');
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
			$this->view->title = 'Category List';                       
			$this->category->getCaregorySearch($params);
			
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
			$this->view->title = "Add Category";
			
			$this->view->ParentCategories = $this->categorydb->getParentCategories();		
			$params = $this->_getAllParams();			
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				if(!$this->category->createCategory($params)) {
					//$this->_redirect('admin/category/register');					
				} else {
					$this->_redirect('admin/category/list');
				}
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To Lock the category
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
			$this->category->lock($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	/**
     * Purpose: To Unlock the locked user
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
				$this->category->unlock($params);
				$this->_redirect($_SERVER['HTTP_REFERER']);
				//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To delete the category
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
			$this->category->delete($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Category edit page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function editAction() {
		try{			
			$this->view->title = "Edit Category";
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				$params = $this->_getAllParams();
				
				if(!$this->category->updateCategoryDetails($params)) {
					$this->view->CategoryImages = $this->categorydb->getCategoryImages($params['categoryId']);
					$this->view->ParentCategories = $this->categorydb->getParentCategories();	
					//$this->_redirect('admin/category/edit/categoryId/' . $this->session->tcalledId);
				} else {
					$this->_redirect('admin/category/list');
				}				
			}else{
				$category_id = $this->_getParam('categoryId','');
				$this->view->category_id = $category_id;
				$this->view->CategoryDetails = $this->categorydb->getCategoryDetails($category_id);
				$this->view->CategoryImages = $this->categorydb->getCategoryImages($category_id);
				$this->view->ParentCategories = $this->categorydb->getParentCategories();				
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: To delete category image
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
			$this->category->deleteimage($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}


?>
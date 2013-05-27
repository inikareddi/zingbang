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

class Admin_AttributesgroupsController extends Zend_Controller_Action {
	public $session;		// used for managing session with NAMESPACE portal
	private $error;			// used for managing session with NAMESPACE portalerror
	private $attributesgroups;			// used for creating an instance of model, Access is with in the class
	private $attributesgroupsdb;		// used for creating an instance of model, Access is with in the class
	
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
		
		$this->attributesgroups = new Application_Model_Attributesgroups();
		$this->attributesgroupsdb = new Application_Model_Attributesgroupsdb();		
		
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
			$this->_redirect('admin/attributesgroups/list');
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
			$this->view->title = "Attribute Group's List";
			$params = $this->_getAllParams();			              
			$this->attributesgroups->getAttributeSearch($params);
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	/**
     * Purpose: Attribute Group addition page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function registerAction() {
		try{
			$this->view->title = "Register Attribute";			
			
			$params = $this->_getAllParams();			
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();
			if ($request->isPost()) {
			
				if(!$this->attributesgroups->createAttribute($params)) {
					//$this->_redirect('admin/attributesgroups/register');					
				} else {
					$this->_redirect('admin/attributesgroups/list');
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
			$this->attributesgroups->lock($params);
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
				$this->attributesgroups->unlock($params);
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
			$this->attributesgroups->delete($params);
			$this->_redirect($_SERVER['HTTP_REFERER']);
			//}
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	
	/**
     * Purpose: Attribute edit page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function editAction() {
		try{			
			$this->view->title = "Edit Attribute Group";
			
			$request = $this->getRequest();
			$Request_Values = $request->getPost();

			if ($request->isPost()) {
			
				$params = $this->_getAllParams();
				
				if(!$this->attributesgroups->updateAttributesDetails($params)) {					
					//$this->_redirect('admin/attributesgroups/edit/attributeId/' . $this->session->tcalledId);
				} else {
					$this->_redirect('admin/attributesgroups/list');
				}				
			}else{
				$attribute_group_id = $this->_getParam('attributeId','');
				$this->view->AttributeGroupDetails = $this->attributesgroupsdb->getAttributeGroupDetails($attribute_group_id);
			}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
	
	
	
	
	/**
     * Purpose: Attribute Config addition page 
     *
     * Access is public
     *
     * @param	
     * 
     * @return  
     */
	
	public function attributeconfigAction() {
		try{
			$this->view->title = "Attribute Group Config";
			$params = $this->_getAllParams();
			if(isset($params['attributeId']) && trim($params['attributeId'])!=''){$this->view->attributeId = $params['attributeId'];}
								
			$request = $this->getRequest();
			$Request_Values = $request->getPost();
			if ($request->isGet() && isset($params['gid']) && $params['gid']!='') {
				$this->_helper->viewRenderer->setNoRender(true);
				$this->_helper->layout->disableLayout();	
				
				
				//echo $params['table_content'];
				//echo "<br>";
				//echo $params['tp_values'];
				//exit;
				//$str1_replace = str_replace('p[]=','',$params['table_content']);
				$str1_explode = explode('@',$params['table_content']);
				foreach($str1_explode as $key=>$value){
					$str1_array = explode('_',$value);	
					$str1_array_org[$str1_array['0']] = $str1_array['1'];	
				}

				//echo "<pre>";
				//print_r($str1_array_org);


				$str2_explode = explode(',',substr($params['tp_values'],0,-1));
				foreach($str2_explode as $key=>$value){
					$str2_array = explode('_',$value);
					$str2_array_org[$str2_array['0']] = $str2_array['1'];
				}


				$str_one = '';
				foreach($str2_array_org as $key=>$value){
					$str_one .= $value."#";
					foreach($str1_array_org as $key1=>$value1){
						if($key==$value1){
							$str_one .= $key1.',';		
						}
					}
					$str_one .= "#-";
				}
				//echo $str_one;				
				$result = $this->attributesgroupsdb->saveAttributeGroupMap($params['gid'],$str_one);
				echo $result['@omessage'];				
			}else{			
				$this->view->AttributeGroupDetails = $this->attributesgroupsdb->getAttributeGroupDetails($params['attributeId']);
				$this->view->ActiveAttributesList = $this->attributesgroupsdb->getActiveAttributesList($params['attributeId']);
				//$this->view->ActiveAttributesGroupsList = $this->attributesgroupsdb->getActiveAttributesGroupsList();
				$this->view->ActiveAttributesSetsList = $this->attributesgroupsdb->getActiveAttributesSetsList($params['attributeId']);
				
				$this->view->ActiveAttributesSetsMapList = $this->attributesgroupsdb->getActiveAttributesSetsMapList($params['attributeId']);
				}
			
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
	}
	
}


?>
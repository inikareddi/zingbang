<?php
class Temp_Plugin_ModuleLayout extends Zend_Controller_Plugin_Abstract {

    public function preDispatch(Zend_Controller_Request_Abstract $request) {
        $config = Zend_Controller_Front::getInstance()
                        ->getParam('bootstrap')->getOptions();
                        
 if (isset($config['resources']['layout']['layout'])) {
            $layoutScript = $config['resources']['layout']['layout'];
            
            Zend_Layout::getMvcInstance()->setLayout($layoutScript);
        }

        if (isset($config['resources']['layout']['layoutPath'])) {
            $layoutPath = $config['resources']['layout']['layoutPath'];
            $moduleDir = Zend_Controller_Front::getInstance()->getModuleDirectory();
            /*$router = Zend_Controller_Front::getInstance()->getRouter();
                      $route = new Zend_Controller_Router_Route(
        ':module/:controller/:action/*',
        array('module' => 'default')
    );
    $router->addRoute('default', $route);*/
           // echo $moduleDir;
           /* Zend_Layout::getMvcInstance()->setLayoutPath(
                    $moduleDir . DIRECTORY_SEPARATOR . $layoutPath
            );*/
        }
    }

}
?>
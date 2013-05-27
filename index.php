<?php

// Define path to application directory
defined('APPLICATION_PATH')
    || define('APPLICATION_PATH', realpath(dirname(__FILE__) . '/application'));
//$fileurl=APPLICATION_PATH."/functions.php";
  //  require_once $fileurl;
$app_foldername="http://".$_SERVER['HTTP_HOST'].str_replace('index.php','',$_SERVER['PHP_SELF']);
    //echo $app_foldername;
defined('APPLICATION_HOST_PATH')
    || define('APPLICATION_HOST_PATH', $app_foldername);
    
    
// Define application environment
defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', (getenv('APPLICATION_ENV') ? getenv('APPLICATION_ENV') : 'production'));

// Ensure library/ is on include_path
set_include_path(implode(PATH_SEPARATOR, array(
    realpath(APPLICATION_PATH . '/../library'),
    get_include_path(),
)));

/** Zend_Application */
require_once 'Zend/Application.php';

// Create application, bootstrap, and run
$application = new Zend_Application(
    APPLICATION_ENV,
    APPLICATION_PATH . '/configs/application.ini'
);
$application->bootstrap()
            ->run();
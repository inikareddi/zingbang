<?php
/*
 * Function is used to return middle tier object
*/
function app_getSessionData($namespace) {
    return new Zend_Session_Namespace ( $namespace );
}

function app_setSessionData($namespace, $key, $value) {
    $session = new Zend_Session_Namespace ( $namespace );
    $session->__set($key, $value);
}
function app_setErrorMsg($errMsg) {
//$error = new Zend_Session_Namespace ( 'errorMsg' );
    $error = app_getSessionData('errorMsg');
    if(!empty($error->message)) {
        $error->__unset('message');
        $error->message = $errMsg;
        $error->setExpirationSeconds(3);
    }else {
        $error->message = $errMsg;
        $error->setExpirationSeconds(3);
    }
   //print_obj($error->message);
}
function app_getErrorMsg() {
//$error = new Zend_Session_Namespace ( 'errorMsg' );
    $error = app_getSessionData('errorMsg');
    return $error->message;
}
function print_obj($obj) {
    echo "<pre>";
    print_r($obj);
    echo "</pre>";
    exit;
}

function ellipsis($text, $max=100, $append='&hellip;') {
    if (strlen($text) <= $max) return $text;
    $out = substr($text,0,$max);
    if (strpos($text,' ') === FALSE) return $out.$append;
    return preg_replace('/\w+$/','',$out).$append;
}



/**
 * Funciton convert the object to array format
 *
 * @param unknown_type $objectValue
 * @return arrayvalue
 */

function app_convertObjectToArray($objectValue) {
    if(is_array($objectValue)) {
        $arrayValue = $objectValue;
    }
    else {
        $arrayValue = array();
        array_push($arrayValue,$objectValue);
    }
    return $arrayValue;
}
 function getRequestURL($type){
        $request = new Zend_Controller_Request_Http ( );
        $url = $request->getRequestUri ();
        $temp = explode('?',$url);
        $url = $temp[0];
        $uriComponents = explode ( '/', $url );
        $page = "";
        if (isset ( $uriComponents [1] ))
            $page = $uriComponents [1];
        if($type=='baseURL')
          return $page;
        else if($type=='fullURL')
          return $url;
        else
         return $uriComponents;
    }
/**
 * Function is used to validate email address
 *
 * @param unknown_type $emailId
 * @return boolean
 */

function app_emailValidation($emailId) {
    $check = false;
    $pattern = "/^[_a-z0-9-]+(/.[_a-z0-9-]+)*@[a-z0-9-]+(/.[a-z0-9-]+)*(/.[a-z]{2,3})$/i";
    if (preg_match($pattern,$emailId))
        $check = true;
    else
        $check = false;
    return $check;
}



function implode_assoc($varray) {
    $toString = "";
    if(!is_array($varray)) {
        return $toString;
    }
    if(empty ($varray)) {
        return $toString;
    }
    foreach($varray as $key =>$value) {
        $toString .=  $key.' = "'.$value.'"';
    }
    return $toString;
}


function getRealIpAddr() {
    if (!empty($_SERVER['HTTP_CLIENT_IP']))   //check ip from share internet
    {
        $ip=$_SERVER['HTTP_CLIENT_IP'];
    }
    elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))   //to check ip is pass from proxy
    {
        $ip=$_SERVER['HTTP_X_FORWARDED_FOR'];
    }
    else {
        $ip=$_SERVER['REMOTE_ADDR'];
    }
    return $ip;
}
function currencyConvert($amt) {
    $value = 0;
    //$amt = 124435356453.556;
    if ($amt != "" && ! is_object ( $amt )) {
		//echo "exist";
        //$value = sprintf ( "$%0.2f", $amt );
        $value = number_format($amt, 2, ".", ",");
    	//$value = money_format('%i', $amt);
    } else if (is_object ( $amt )) {
		//echo "object";
        $value = str_replace ( "$", "", $amt );
        //$value = sprintf ( "$%0.2f", $value );
        $value = number_format($amt, 2, ".", ",");
    } else {
		//echo "nothing";
        //$value = sprintf ( "$%0.2f", $amt );
        $value = number_format($amt, 2, ".", ",");
    }
    return "$".$value;
}
function getServerURL() {
    return  $url = (! empty ( $_SERVER ['HTTPS'] )) ? "https://" . $_SERVER ['SERVER_NAME'] : "http://" . $_SERVER ['SERVER_NAME'];
}

function record_sort($records, $field, $reverse=false)
{
    $hash = array();
$i=0;
    foreach($records as $record)
    {
       $record= app_convertObjectToArray($record);
      // echo $record[0]->$field;
       //print_obj($record);
       
        $hash[$record[0]->$field] = $record;
        $i++;
    }

    ($reverse)? krsort($hash) : ksort($hash);

    $records = array();

    foreach($hash as $record)
    {
        $records []= $record;
    }

    return $records;
}
function app_setErrorMsgTwo($errMsg) {
//$error = new Zend_Session_Namespace ( 'errorMsg' );
    $error = app_getSessionData('errorMsgTwo');
    if(!empty($error->message)) {
        $error->__unset('message');
        $error->message = $errMsg;
        $error->setExpirationSeconds(3);
    }else {
        $error->message = $errMsg;
        $error->setExpirationSeconds(3);
    }
}
function app_getErrorMsgTwo() {
//$error = new Zend_Session_Namespace ( 'errorMsg' );
    $error = app_getSessionData('errorMsgTwo');
    return $error->message;
}

// make the seed for the random generator 
function make_seed()
{
    list($usec, $sec) = explode(' ', microtime());
  return (float) $sec + ((float) $usec * 100000); 
} 

// make the password 
function make_password($pass_len) 
{ 
  //seed the random generator 
    mt_srand(make_seed()); 
  //create password 
    $password = ""; 
    $special = array(33,35, 36, 42, 95, 64); // ascii codes for specific special characters
    for ($loop = 0; $loop < $pass_len; $loop++) 
    { 
        //switch(mt_rand(0, 3))
        //switch(mt_rand(0, 2))		// This is generic for a numeric and a char
        $char = $loop % 3; 
        switch($char)
        { 
            case 0: $password .= mt_rand(0, 9);            break; // Number (0-9) 
            case 1: $password .= chr(mt_rand(97, 122));    break; // Alpha Lower (a-z) 
            case 2: $password .= chr(mt_rand(65, 90));    break; // Alpha Upper (A-Z) 
            //case 3: $password .= chr($special[array_rand($special, 1)]); break; // Special characters (!,#,$,*,_,@)
        }
    }
  return $password;
}


// make the authcode only numeric
function make_password_authcode($pass_len) 
{ 
	//echo "hell".$pass_len."<br>";
  //seed the random generator 
    mt_srand(make_seed()); 
  //create password 
    $password = ""; 
    $special = array(33,35, 36, 42, 95, 64); // ascii codes for specific special characters
    for ($loop = 0; $loop < $pass_len; $loop++) 
    { 
        //switch(mt_rand(0, 3))
        //switch(mt_rand(0, 2))		// This is generic for a numeric and a char
        $char = $loop % 1; 
        switch($char)
        { 
            case 0: $password .= mt_rand(0, 9);            break; // Number (0-9) 
           // case 1: $password .= chr(mt_rand(97, 122));    break; // Alpha Lower (a-z) 
           // case 2: $password .= chr(mt_rand(65, 90));    break; // Alpha Upper (A-Z) 
            //case 3: $password .= chr($special[array_rand($special, 1)]); break; // Special characters (!,#,$,*,_,@)
        }
    }
  return $password;
}

function get_rand_id($length = 4) {  
   if ($length>0){
	   $rand_id = "";
	   for($i=1; $i<=$length; $i++) {
		   do {
			   mt_srand((double)microtime() * 1000000);
			   $num = mt_rand(48,122);  
		   }while (($num > 57 && $num < 65) || ($num > 90 && $num < 97) );  
					$rand_id .= chr($num);  
	   }  
   }  
 return $rand_id;  
}
/*
* Pagination
*/
function pagination($start, $limit, $total, $otherParams='',$type) {	
	
	if ($otherParams!=''){
		$otherParams = $otherParams;
	}
	
	$allPages	 = ceil($total/$limit);
	$currentPage = floor($start/$limit) + 1;
	$pagination  = "";
	if ($allPages>10) {
		$maxPages = ($allPages>9) ? 9 : $allPages;

		if ($allPages>9) {
			if ($currentPage>=1&&$currentPage<=$allPages) {
				$pagination .= ($currentPage>4) ? "<td class='paging'> ... </td>" : " ";
				$minPages    = ($currentPage>4) ? $currentPage : 5;
				$maxPages    = ($currentPage<$allPages-4) ? $currentPage : $allPages - 4;

				for($i = $minPages-4; $i<$maxPages+5; $i++) {
					$pagination .= ($i == $currentPage) ? "<td class='paging'><span>".$i."</span></td>" : "<td class='paging'><a href=\"".PRO_ROOT_USER_PATH.$type.(($i-1)*$limit)."/".$otherParams."\">".$i."</a></td>";
				}
				$pagination .= ($currentPage<$allPages-4) ? "<td class='paging'> ...</td> " : " ";
			} else {
				$pagination .= "<td class='paging'>...</td> ";
			}
		}
	} else {
		for($i=1; $i<$allPages+1; $i++) {
			$pagination .= ($i==$currentPage) ? "<td class='paging'><span>".$i."</span></td>" : "<td class='paging'><a  href=\"" .PRO_ROOT_USER_PATH.$type.(($i-1)*$limit)."/". $otherParams."\" >" . $i . "</a></td>";
		}
	}

	if ($currentPage>1){ 
		$pagination = "<td class='paging' ><a   href=\"" .PRO_ROOT_USER_PATH.$type."0/". $otherParams . "\" ><strong>&laquo;</strong> First</a></td><td class='paging'><a  href=\"".PRO_ROOT_USER_PATH.$type.(($currentPage-2)*$limit)."/". $otherParams . "\"><strong >&laquo;</strong> Previous</a></td>" . $pagination;
	}
	if ($currentPage<$allPages){
		
		$pagination .= "<td class='paging'><a   href=\"".PRO_ROOT_USER_PATH.$type.($currentPage*$limit)."/".$otherParams . "\">Next <strong>&raquo;</strong></a></td><td class='paging'><a  href=\"".PRO_ROOT_USER_PATH.$type.(($allPages-1)*$limit)."/". $otherParams . "\">Last <strong>&raquo;</strong></a></td>";
	}

	echo "<table align=\"right\" class=\"boxPagination\"  ><tr>".$pagination."</tr></table>";
}
function pagination1($start, $limit, $total, $otherParams='',$type) {	
	
	if ($otherParams!=''){
		$otherParams = $otherParams;
	}
	$allPages	 = ceil($total/$limit);
	$currentPage = floor($start/$limit) + 1;
	$pagination  = "";
	if ($allPages>10) {
		$maxPages = ($allPages>9) ? 9 : $allPages;

		if ($allPages>9) {
			if ($currentPage>=1&&$currentPage<=$allPages) {
				$pagination .= ($currentPage>4) ? "<td class='paging'> ... </td>" : " ";
				$minPages    = ($currentPage>4) ? $currentPage : 5;
				$maxPages    = ($currentPage<$allPages-4) ? $currentPage : $allPages - 4;

				for($i = $minPages-4; $i<$maxPages+5; $i++) {
					$pagination .= ($i == $currentPage) ? "<td class='paging' style='color:#000;font-weight:bold;'>".$i."</td>" : "<td class='paging'><a href=\"".PRO_ROOT_USER_PATH.$type.(($i-1)*$limit)."/".$otherParams."\">".$i."</a></td>";
				}
				$pagination .= ($currentPage<$allPages-4) ? "<td class='paging'> ...</td> " : " ";
			} else {
				$pagination .= "<td class='paging'>...</td> ";
			}
		}
	} else {
		for($i=1; $i<$allPages+1; $i++) {
			$pagination .= ($i==$currentPage) ? "<td class='paging'>".$i."</td>" : "<td class='paging'><a  href='" .PRO_ROOT_USER_PATH.$type.(($i-1)*$limit)."/". $otherParams."' >" . $i . "</a></td>";
		}
	}

	if ($currentPage>1){ 
		$pagination = "<td class='paging' ><a   href='" .PRO_ROOT_USER_PATH.$type."0/". $otherParams."'><strong>&laquo;</strong> First</a></td><td class='paging'><a  href='".PRO_ROOT_USER_PATH.$type.(($currentPage-2)*$limit)."/". $otherParams ."'><strong >&laquo;</strong> Previous</a></td>" . $pagination;
	}
	if ($currentPage<$allPages){
		
		$pagination .= "<td class='paging'><a   href='".PRO_ROOT_USER_PATH.$type.($currentPage*$limit)."/".$otherParams ."'>Next <strong>&raquo;</strong></a></td><td class='paging'><a  href='".PRO_ROOT_USER_PATH.$type.(($allPages-1)*$limit)."/". $otherParams . "'>Last <strong>&raquo;</strong></a></td>";
	}
//'.$pagination."
	return "<table align='center' class='boxPagination'  ><tr>".$pagination ."</tr></table>";
}
/*
* Date Conversion
*/
function func_date_conversion($date_format_source, $date_format_destiny, $date_str){
/*
	To Convert Any Date Format to any other Date Format
	Use Like:
		$df_des = 'Y-m-d H:i';
		$df_src = 'd/m/Y H:i A';
		echo func_date_conversion( $df_src, $df_des, '10/11/2008 03:34 PM');
*/
	/*$base_format     = split('[:/.\ \-]', $date_format_source);
	$date_str_parts = split('[:/.\ \-]', $date_str );*/
	$base_format=preg_split('/[:\/.\ \-]+/', $date_format_source, -1, PREG_SPLIT_NO_EMPTY);
	$date_str_parts=preg_split('/[:\/.\ \-]+/', $date_str, -1, PREG_SPLIT_NO_EMPTY);  
	
	$date_elements = array();
	
	$p_keys = array_keys( $base_format );
	foreach ( $p_keys as $p_key )
	{
		if ( !empty( $date_str_parts[$p_key] ))
		{
			$date_elements[$base_format[$p_key]] = $date_str_parts[$p_key];
		}
		else
			return false;
	}
	//print_obj($date_elements);
	if (array_key_exists('M', $date_elements)) {
		$Mtom = array(
			"Jan" => "01",
			"Feb" => "02",
			"Mar" => "03",
			"Apr" => "04",
			"May" => "05",
			"Jun" => "06",
			"Jul" => "07",
			"Aug" => "08",
			"Sep" => "09",
			"Oct" => "10",
			"Nov" => "11",
			"Dec" => "12",
		);
		
		 $date_elements['m']=$Mtom[$date_elements['M']];
	}
	//echo $date_format_destiny;
	$sec=0;
	$hours=0;
	$min=0;
	if(array_key_exists("H", $date_elements)){
		$hours=$date_elements['H'];
	}
if(array_key_exists("i", $date_elements)){
		$min=$date_elements['i'];
	}
if(array_key_exists("s", $date_elements)){
		$sec=$date_elements['s'];
	}
	//echo $date_elements['m'];
	//if($date_elements['m']<=12 && $date_elements['d'] <=31){
	 $dummy_ts = mktime($hours, $min, $sec, $date_elements['m'], $date_elements['d'], $date_elements['Y'] );
	 return date( $date_format_destiny, $dummy_ts );
	/*}
	else{
		return 'Invalid';
	}*/
	
	//print_r($dummy_ts);
	//exit;
	
}
/*
* isSSL
*/
function isSSL(){
	//print_obj($_SERVER);
  /*if($_SERVER['https'] == 1) 
   *
   * Apache  {
     return 'https';
  } elseif ($_SERVER['https'] == 'on')  IIS  {
     return 'https';
  } else*/
  if ($_SERVER['SERVER_PORT'] == 443) /* others */ {
     return 'https';
  } else {
  return 'http'; /* just using http */
  }
}
function search($array, $key, $value)
{
    $results = array();

    if (is_array($array))
    {
        if (isset($array[$key]) && $array[$key] == $value)
            $results[] = $array;

        foreach ($array as $subarray)
            $results = array_merge($results, search($subarray, $key, $value));
    }

    return $results;
}
?>

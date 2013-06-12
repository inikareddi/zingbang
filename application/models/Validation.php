<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Validation.php 
* Owner		:	RAM's 
* Purpose	:	This class is used for validating field values at server side
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

//class Application_Model_Validation extends Application_Model_Userdb{
class Application_Model_Validation extends Application_Model_DataBaseOperations{
	
	/**
     * Purpose: To validate alphanumeric character with space
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate
     * @return  
     */
	public function validate_alphanumeric_space($str) 
	{
		/*if(preg_match('/^[a-zA-Z0-9 ]+$/',$str)) {
			echo "true";
			exit;
		} else {
			echo "False";
			exit;
		}*/
	    //return preg_match('/^[a-zA-Z0-9 ]+$/',$str);
	    $result = preg_match('/^[a-zA-Z0-9 ]+$/',$str);
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }
	}

	/**
     * Purpose: To validate alphanumeric character with space
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate
     * @return  
     */
	public function validate_alphanumeric_spacehypen($str) 
	{
		/*if(preg_match('/^[a-zA-Z0-9 ]+$/',$str)) {
			echo "true";
			exit;
		} else {
			echo "False";
			exit;
		}*/
	    //return preg_match('/^[a-zA-Z0-9 ]+$/',$str);
	    $result = preg_match('/^[a-zA-Z0-9_ ]+$/',$str);
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }
	}
/**
     * Purpose: To validate alphanumeric character
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate
     * @return  
     */
	public function validate_alphanumeric_address($str) 
	{
		/*if(preg_match('/^[a-zA-Z0-9 ]+$/',$str)) {
			echo "true";
			exit;
		} else {
			echo "False";
			exit;
		}*/
		
		$regexp = "/^[a-zA-Z0-9 #&\-\_\:\.\/\,]+$/";
		$notallowed="/[!@$%^*?~+<>|=\}\[\]\{\\\'\"\;\`]/";
		$result = preg_match($notallowed,$str);
		if($result || $result == 1){
	    	return false;
	    } else if(!$result || $result == 0){
	    	return true;
	    }
	    //return preg_match($regexp,$str);
	    /*$result = preg_match($regexp,$str);
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }*/
	}
	
	
	
	/**
     * Purpose: To validate alpha character
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate	
     * @return  
     */
	public function validate_alpha($str) 
	{
	    //return preg_match('/^[a-zA-Z]+$/',$str);
	    $result = preg_match('/^[a-zA-Z]+$/',$str);
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }
	}
	
	/**
     * Purpose: To validate numeric character
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate	
     * @return  
     */
	public function validate_numeric($str) 
	{
	    //return preg_match('/^[0-9]+$/',$str);
	    if( !preg_match('/^[1-9][0-9]*$/',$str) || preg_match('/^[1-9][0-9]*$/',$str) == 0){
	    	return false;
	    } else if(preg_match('/^[1-9][0-9]*$/',$str) || preg_match('/^[1-9][0-9]*$/',$str) != 0){
	    	return true;
	    }
	}
	

	/**
     * Purpose: To validate digits
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate	
     * @return  
     */
	public function validate_digits($str) 
	{
	    //return preg_match('/^[0-9]+$/',$str);
	    if( !preg_match('/^[0-9]+$/',$str) || preg_match('/^[0-9]+$/',$str) == 0){
	    	return false;
	    } else if(preg_match('/^[0-9]+$/',$str) || preg_match('/^[0-9]+$/',$str) != 0){
	    	return true;
	    }
	}
	
	/**
     * Purpose: To validate email
     *                    Allowed characters are .,_,@
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate	
     * @return  
     */
	public function validate_email_dot_underscore($str) 
	{
	    $regexp = "/^[^0-9_.][a-zA-Z0-9_]+([.][a-zA-Z0-9_]+)*[@][a-zA-Z0-9_]+([.][a-zA-Z0-9_]+)*[.][a-zA-Z]{2,4}$/";
	    if(preg_match($regexp,$str) || preg_match($regexp,$str) != 0){
	    	//list($username,$domain)=explode('@',$str);
			//if(!checkdnsrr($domain,'MX')) {
			   //return false;
			//}
		  	return true;
	    }
	    return false;
	}
	
	/**
     * Purpose: To validate alpha numeric value
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar $str String to validate
     * @return  
     */
	public function validate_alphanumeric($str) 
	{
	    $regexp = "/^[A-Za-z0-9]+$/";
	    //return preg_match($regexp,$str);
	    $result = preg_match($regexp,$str);
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }
	}
	
	/**
     * Purpose: To validate alpha numeric values with space, questionmark and apostrophe
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar $str String to validate
     * @return  
     */
	public function validate_alphanumeric_space_apostrophe($str) 
	{
		
	    $splexp="/^[A-Za-z0-9][A-Za-z0-9? \']*$/";
	   
      if(!preg_match($splexp, $str) || preg_match($splexp,$str) == 0) {
			return false;
		}
		
		return true;
		
		
	}

	/**
     * Purpose: To validate alpha numeric values with one Uppercase and one lowercase and a digit as mandatory
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar $str String to validate
     * @return  
     */
	public function validate_alphanumeric_upper_small_digit($str) 
	{
	    $regexp = "/[A-Z]+[a-z]+[\d]+$/";  // validates a Uppercae, a lower case and a number
	   /* $error = 0;
	    if(preg_match("/^[A-Z]+$/", $str)) {
	    	$error = 1;
	    }*/
	    $result = preg_match($regexp,$str);
	    
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }
	   // return preg_match($regexp,$str);
	}
	

	/**
     * Purpose: To validate alpha numeric values with one Uppercase and a digit as mandatory
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar $str String to validate
     * @return  
     */
	public function validate_alphanumeric_password($str) 
	{
	    $regexpUpper = "#[A-Z]+#";  // Validates a Uppercae
	    $regexpNumber = "#[0-9]+#"; // Validates a Number
	    $regexpLower = "#[a-z]+#";  // Validates a Lowercase
	    $regexpAllow = "#^[A-Za-z0-9]+#";  // Allowed characters
	    
	   
	   if(!preg_match($regexpUpper,$str) || preg_match($regexpUpper,$str) == 0){
	   		return false;
		} else if(!preg_match($regexpNumber, $str) || preg_match($regexpNumber,$str) == 0) {
			return false;
		} else if(!preg_match($regexpAllow, $str) || preg_match($regexpAllow,$str) == 0) {
			return false;
		}
		
		return true;
	}
	
public function validate_alphanumeric_special_password($str) 
	{   
		//return preg_match("/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@!#$\_\*\]).{8,16}$/",$str);
		$reuslt = preg_match("/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@!#$\_\*\]).{8,16}$/",$str);
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }
	}


	/**
     * Purpose: To validate alpha numeric values with one Character and one Number as mandatory
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar $str String to validate
     * @return  
     */
	public function validate_alphanumeric_digicharman($str) 
	{
	    $regexpUpper = "#[A-Z]+#";  // Validates a Uppercae
	    $regexpNumber = "#[1-9]+#"; // Validates a Number
	    $regexpLower = "#[a-z]+#";  // Validates a Lowercase	    
	    $regexpupperLower = "#[A-Za-z]+#";  // Validates a Lowercase or Uppercase
	    
	   if(!preg_match($regexpupperLower,$str) || preg_match($regexpupperLower,$str) == 0){
	   		return false;
		} else if(!preg_match($regexpNumber, $str) || preg_match($regexpNumber,$str) == 0) {
			return false;
		}		
		return true;
	}
	public function validate_alphanumeric_hash($str) 
	{
	    $regexp = "/^[a-zA-Z0-9#&-_:\.\/\( \)\,]+$/";
	    //return preg_match($regexp,$str);
	 	$result = preg_match($regexp,$str) == 0;
	    	
		if( !$result || $result == 0){
	    	return false;
	    } else if($result || $result != 0){
	    	return true;
	    }
	}
	
	public function validateUSAZip($zip_code)
	{
	  if(!preg_match("/^[0-9]{5}([-][0-9]{4})?$/",$zip_code) || preg_match("/^[0-9]{5}([-][0-9]{4})?$/",$zip_code) == 0)
	    return false;
	  else
	    return true;
	}
	
	public function validatenospecialcharacters($value){
		$notallowed="/[#&\-\_\:\.\/\,!@$%^*?~+<>|=\}\[\]\{\\\'\"\;\`]/";
		if(preg_match($notallowed, $value) || preg_match($notallowed, $value)==1 ){
			return false;
		}else{
			return true;
		}
	}
	
	/**
     * Purpose: To validate date
     *
     * Access is restricted to class and its child classes
     *
     * @param	varchar	$str String to validate	
     * @return  
     */
	public function validate_date($str, $delimiter)
	{	

		
		$fArray = explode($delimiter, $str);
        	if(count($fArray) != 3) {	        		
        		return false;
        	} else{
        		$month = $fArray[0];
        		$date = $fArray[1];
        		$year = $fArray[2];
        		if(!is_numeric($month)){
        			return false;	
        		} else {
        			if($month > 12 || $month < 01){
        				return false;		
        			} else {
	        			if(!is_numeric($date)){
		        			return false;
		        		} else {
		        			if($date > 31 || $date < 01){
		        				return false;		
		        			} else {
			        			if(!is_numeric($year)){
				        			return false;	
				        		} else {
				        			if($year > date('Y')){
				        				return false;		
				        			} else{
				        				$isDateValid = checkdate($month, $date, $year);
    									return $isDateValid;
				        			}
				        		}
		        			}
		        		}		
        			}
        		}
        	}	    
	}
	
	
	
	public function checkAllreadyExists($table,$column,$value,$recordcolumn,$recordid)
	{
	  try{			
			parent::SetDatabaseConnection();
			
			if(trim($recordid)!=''){
				$query = "select count(".$column.") as AllreadyExistsCount FROM ".$table." where ".$column."='".$value."' AND ".$recordcolumn."!='".$recordid."'";
			}else{
				$query = "select count(".$column.") as AllreadyExistsCount FROM ".$table." where ".$column."='".$value."' ";
			}
			//exit;			
			$AllreadyExistsCount = Application_Model_Db::getRow($query);
			//print_r($AllreadyExistsCount['AllreadyExistsCount']);
			//exit;
			return $AllreadyExistsCount['AllreadyExistsCount'];
		} catch(Exception $e) {
			Application_Model_Logging::lwrite($e->getMessage());
			throw new Exception($e->getMessage());
		}
		
	}
}
?>
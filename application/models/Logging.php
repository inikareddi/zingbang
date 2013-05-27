<?php
/*
*================AllySoft Internal Use only========================

*-----------------------------------------------------------------*
* Copy Right Header Information*
*-----------------------------------------------------------------*
* Project	:	GetLinc
* File		:	Logging.php
* Owner		:	RAM's 
* Purpose	:	This class contains lopen and lwrite methods, lwrite will write message to the log file
			  	first call of the lwrite will open log file implicitly,message is written with the following
 				format: hh:mm:ss (script name) message
* Date		:	08/05/2012


* Modification History
* ----------------------------------------------------------------------------------------------------------------
* Dated		Version		Who		Description
* -----------------------------------------------------------------------------------------------------------------
* %D%		%T%			%W%
* -----------------------------------------------------------------------------------------------------------------

*===================================================================================================================
*/

class Application_Model_Logging{
	
	// define file pointer
	private static $fp = null;
	private static $sTimeFormat='H:i:s';
	private static $sDateFormat='m-d-Y';
	public  $logpath;
	public  $smode;



	/**********************************************************************
	 * Function writes message to the log file
	 **********************************************************************/
	public static function lwrite($message){

		try
		{
			$config=Zend_Registry::get('config');
			$smode= $config->log->smode;
			if( $smode=='T' ||(is_object($message) && $smode=='P' ))
			{
				// if file pointer doesn't exist, then open log file
				if (!self::$fp) self::lopen();
				// define script name
				$script_name = pathinfo($_SERVER['PHP_SELF'], PATHINFO_FILENAME);
				// define current time
				$time = date(self::$sTimeFormat);
				// write current time, script name and message to the log file
				if(is_object($message))
				{
					$message=$message->getMessage();
				}
				fwrite(self::$fp, "$time ($script_name) $message\n");
				//openlog("Log", LOG_PID | LOG_PERROR, LOG_LOCAL0);


				$access = date("Y/m/d H:i:s");
				//	syslog(LOG_WARNING, "APILOG: $access".$message." {$_SERVER['REMOTE_ADDR']} ({$_SERVER['HTTP_USER_AGENT']})");


				//	closelog();
				// Send Email After Writing to file

				//WebMail::SendMail("ERROR LOG Alert",$message,$this->sConfig->sSiteAdmin,$this->sConfig->sSiteAdmin);
			}
		}
		catch(Exception $e)
		{
			throw new Exception("x_error_message=WebErrLog:Problem with Writing to a log file");
		}
	}


	/**********************************************************************
	 * Function is used to open log file
	 **********************************************************************/
	private static function lopen(){
		try
		{
			$config=Zend_Registry::get('config');
			$logpath= $config->log->path;
			// define log file path and name
			$lfile =  $logpath;
			// define the current date (it will be appended to the log file name)
			$today = date(self::$sDateFormat);
			// open log file for writing only; place the file pointer at the end of the file
			// if the file does not exist, attempt to create it
			self::$fp = fopen($lfile . '_' . $today.'.log', 'a') or exit("Can't open $lfile!");
		}
		catch(Exception $e)
		{
			throw new Exception("x_error_message=WebErrLog:Problem with Opening log file");
		}
	}
}
?>

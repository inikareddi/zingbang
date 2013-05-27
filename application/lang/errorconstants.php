<?php
/**
 * 
 * All error constants and success constants are declared here
 * @var unknown_type
 */
	define('welcomemessage', 'This is a sample constant');
	/*
	 * Root path to public folder 
	 */
	define('ROOT_PUBLIC_PATH',APPLICATION_HOST_PATH.'public');
	define('PRO_ROOT_USER_PATH',APPLICATION_HOST_PATH);
	
	
	/*
	 * User email template names
	 */
	define('User_Mail_Loginid','User Userid Mail');
	define('User_Mail_Password','User Password Mail');
	define('User_Mail_Temp_Password','User Temp Password Mail');
	define('User_Mail_Locked','User Locked');
	define('User_Mail_Activated','User Activated');
	define('User_Mail_Deleted','User Deleted');
	
	
	/*
	 * Device email template names
	 */
	define('Device_Add_Mail','Add Device');
	define('Device_First_Add_Mail','Add First Device');
	define('Device_Active_Mail','Device Active');
	define('Device_Inactive_Mail','Device Inactive');
	
	
	/*
	 * Error messages for login attempts 
	 */
	define('Error_login_user_userid_empty', 'Please Enter Username');
	define('Error_login_user1_password_empty', 'Please Enter Password');
	define('Error_login_user_password_empty', 'Please Enter Old Password');
	define('Error_login_user_new_password_empty', 'Please Enter New Password');
	define('Error_login_user_temppassword_empty', 'Please Enter Temporary Password');
	define('Error_login_user_newpassword_empty', 'Please Enter New Password');
	define('Error_login_user_oldpassword_empty', 'Please Enter Old Password');
	define('Error_login_user_confirmpassword_empty', 'Please Re-enter New Password');
	define('Error_login_user_userid', 'Invalid Username');
	define('Error_login_user_password', 'Invalid Password');
	define('Error_login_user_temppassword', 'Invalid Temporary Password');
	define('Error_login_user_oldpassword', 'Invalid Old Password');
	define('Error_login_user_newpassword', 'Invalid New Password');
	define('Error_login_user_improper_newpassword', 'New Password must contain a minimum of one number and one uppercase letter');
	define('Error_login_user_improper_renewpassword', 'Re-enter New Password must contain a minimum of one number and one uppercase letter');
	define('Error_login_user_renewpassword', 'Invalid Re-enter New Password');
	define('Error_login_user_improper_password', 'Password must contain a minimum of one number and one uppercase letter');
	define('Error_login_user_userdeleted', 'User No Longer exists');
	define('Error_login_user_userchangedpassword', 'User already changed his password');
	
	define('Error_login_user_invalidcredentials', 'User credentials are invalid');
	define('Error_login_user_userlocked', 'User has been locked. Contact administrator.');
	define('Error_login_user_unmatchpass','Enter the same as New Password');
	
	/*
	 * Success message for login
	 */
	define('Success_login_user', 'Successfully loggedin');
	
	/*
	 * Error messages for user security answers
	 */
	define('Error_login_user_secans', 'Invalid answer');
	define('Error_login_user_seclocked', 'User has been locked for entering wrong answer many times');
	define('Error_forgot_user_seclocked', 'User has been locked for entering wrong answer many times');
	
	/*
	 * Success message for user security answer
	 */
	define('Success_login_user_secans', 'Successfully answered challenge questions');
	
	/*
	 * Error message for user registration / user creation
	 */
	define('Error_registration_user_email', 'Invalid Email');
	//define('Error_registration_user_email', 'Invalid Email');
	
	/*
	 * Error message for forgotpassword
	 */
	define('Error_forgot_user_loginid', 'Invalid Username entered');
	define('Error_forgot_user_loginid_empty', 'Please Enter Username');
	define('Error_forgot_user_secques', 'Invalid answer for the given question');
	define('Error_forgot_user_nosecques', 'No challenge questions registered');
	
	define('Error_forgot_secure_question', 'You are not authenticated user');
	define('Error_change_secure_question', 'Please Enter Challenge Question');
	define('Error_change_secure_question_invalid', 'Invalid Challenge Question');
	define('Error_forgot_secure_answer', 'Invalid Secret Answer');
	
	define('Error_forgot_secure_reanswer', 'Invalid Re-enter Secret Answer');
	define('Error_forgot_secure_answer_empty', 'Please Enter Secret Answer');
	define('Error_forgot_secure_answer_confirm', 'Enter the same as Secret Answer');
	define('Error_forgot_secure_answer_confirm_empty', 'Please Re-enter Secret Answer');
	//define('Error_forgot_secure_answer_confirm_invalid', 'Invalid answer');
	
	
	/*
	 * Success messages for forgot password
	 */
	define('Success_forgot_user_loginid', 'Successfully entered Username');
	define('Success_forgot_user_emailsent', 'Password was sent to your Email id successfully. Please check and login.');
	
	
	/*
	 * Success messages for admin reset password and security question
	 */
	define('Success_reset_user_security', 'Challenge Question & Answer Reset Successfully');
	define('Success_reset_user_password', 'Password Reset Successfully');
	
	
	/*
	 * Failure messages for admin reset password and challenge question
	 */
	define('Failure_reset_user_security', 'Failed Reset challenge questions');
	define('Failure_reset_user_password', 'Failed Reset password');
	
	/*
	 * User change status messages
	 */
	define('Status_locked', 'was locked successfully');
	define('Status_unlocked', 'was unlocked successfully');
	define('Status_deleted', 'was deleted successfully');
	define('Status_updated', ' details were updated successfully');
	define('Status_updated_confirmed', 'Your Personal Information was updated successfully');
	
	define('Status_failed_updated', ' Failed to update details for ');
	
	/*
	 * Success and Failure messages for user creation by admin
	 */
	define('Success_user_creation', 'Successfully Created User');
	define('Failure_user_creation', 'Falied to create user');
	
	define('Success_creation', 'Successfully Created');
	define('Failure_creation', 'Falied to create');
	
	
	/*
	 * Success messages for chage password and security question
	 */
	define('Success_firstlogin_user_password', 'Password is Changed Successfully');
	define('Success_firstlogin_user_password_question', 'Successfully Changed Password and Created Challenge Question');
	define('Success_firstlogin_user_security', 'Challenge Question is Created Successfully');
	define('Success_updated_user_security', 'Challenge Question is Updated Successfully');
	define('Success_updated_user_security_confirmed', 'Your Challenge Question and Secret Answer were updated successfully');
	
	
	
	/*
	 * Error messages for chage password and security question
	 */
	define('Error_user_old_password', 'Invalid old Password.');
	define('Error_user_active_password', 'User already activated his account');
	define('Error_user_temp_password', 'Invalid Temporary Password.');
	define('Error_user_repeat_password', 'Password Already Used. Please Choose Another Password.');
	define('Error_user_failed_password', 'Failed to update password');
	
		
	/*
	 * Failure messages for admin reset password and security question
	 */
	define('Failure_firstlogin_user_security', 'Failed to create challenge questions');
	define('Failure_firstlogin1_user_security', 'Challenge Question is Already Registered, Please Logout and Login into Application');
	define('Failure_update_user_security', 'Failed to update challenge questions');
	define('Failure_firstlogin_user_password', 'Failed Change password');
	
	/*
	 * Error messages for create user action
	 */
	define('Error_Create_users_firstname', 'Invalid First Name');
	define('Error_Create_users_firstname_empty', 'Please Enter First Name');
	define('Error_Create_users_lastname', 'Invalid Last Name');
	define('Error_Create_users_lastname_empty', 'Please Enter Last Name');
	define('Error_Create_users_email', 'Invalid Email Address');
	define('Error_Create_users_email_empty', 'Please Enter Email Address');
	define('Error_Create_users_phone', 'Invalid Contact Number');
	define('Error_Create_users_phone_empty', 'Please Enter Contact Number');
	define('Error_Create_users_username', 'Invalid Username');
	define('Error_Create_users_username_empty', 'Please Enter Username');
	define('Error_Create_users_role', 'Invalid Role');
	define('Error_Create_users_role_empty', 'Please select a Role');
	
	
	/*
	 * Error messages for field lengths
	 */
	define('Error_name_field', 'Enter maximum 20 characters');
	define('Error_name_field_min', 'Enter minimum 3 characters');
	define('Error_email_field', 'Enter maximum 50 characters');
	define('Error_phone_field_max', 'Enter maximum 10 characters');
	define('Error_phone_field_min', 'Enter minimum 10 characters');
	define('Error_secques_field', 'Enter maximum 60 characters');
	define('Error_answer_field_max', 'Enter maximum 30 characters');
	define('Error_answer_field_min', 'Enter minimum 1 characters');
	define('Error_password_field_max', 'Enter maximum 16 characters');
	define('Error_password_field_min', 'Enter minimum 8 characters');
	
	/*
	 * Message for Un authenticated URL
	 */
	define('Invalid_URL_Found', 'You are not authenticated to login');
		
	
	/**
	 * Device Lost Status
	 */
	define('Device_Active','1');
	define('Device_InActive','2');
	define('Device_Lost','3');
	define('Merchant_Active','1');
	define('Merchant_InActive','2');
	
	/**
	 * Device Email Templates
	 */
	define('Device_Email_Active','Device Active');
	define('Device_Email_InActive','Device Inactive');
	define('Device_Email_Lost','Device Lost');
	//Merchant_Active
	
	/*
	 * Titles for pages
	 */
	define('Title_Change_security_question', 'Change challenge Question');
	define('Title_Change_password', 'Change Password');
	define('Title_Forced_reset_password', 'Mandatory Change password');
	define('Title_Successful_login', 'Successfully logged in');
	define('Title_Default_login', 'Log in');
	define('Title_User_list', 'List of users');
	define('Title_User_create', 'Create User');
	define('Title_User_update', 'Update User');
	define('Title_Default_first', 'Create challenge question and reset password');
	define('Title_forgot_user_falure', 'Oops!!!! Your account has been Locked');
	define('Title_forgot_user_success', 'Congratulations.Your password has been reset!!!');
	define('Title_Change_personalinfo', 'Edit Personalinformation');
	define('Title_devicemanagement_Add_Device', 'Add devices');
	define('Title_devicemanagement_Edit_Device', 'Edit device');
	define('Title_devicemanagement_View_Device', 'View device');
	define('Title_devicemanagement_List_Devices', 'Manage Devices');
	define('Title_reportmanagement_Dashboard', 'Dashboard');
	define('Title_merchantmanagement_list', 'List of Merchants');
	define('Title_merchantmanagement_addmerchant', 'Add Merchant');
	define('Title_merchantmanagement_editmerchant', 'Edit Merchant');
	define('Title_merchantmanagement_viewmerchant', 'View Merchant');
	
	/*
	 * Error messages for Merchant Enrollement 
	 */
	//Merchant Name
	define('Error_merchant_name_empty', 'Please Enter the Merchant Name');
	define('Error_merchant_name_alphanum', 'Please Enter Only Alpha Numeric Values with Spaces');
	define('Error_merchant_name_min', 'Please Enter Minimum 4 characters');
	define('Error_merchant_name_max', 'Please Enter Maximum 50 characters');
	//Address
	define('Error_merchant_address_empty', 'Please Enter the Address');
	//define('Error_merchant_address_alphanum', 'Please Enter Only Alpha Numeric Values with Spaces');
	define('Error_merchant_address_min', 'Please Enter Minimum 10 characters');
	define('Error_merchant_address_max', 'Please Enter Maximum 50 characters');
	define('Error_merchant_address_inavalid', 'Invalid Merchant Address');
	
	/*
	 * Error Messages for Device Registration
	 */
	
	define('Error_device_name_empty','Please Enter the Device Nick Name');
	define('Error_device_name_minlen','Device Nick Name should be minimum of 4 characters');
	define('Error_device_name_maxlen','Device Nick Name should be maximun of 12 characters');
	define('Error_device_name_invalid','Device Nick Name should be Alpha Numerics');
	define('Error_device_terminal_empty','Please Enter the Card Acceptor Terminal ID');
	define('Error_device_terminal_min_len','Card Acceptor Terminal ID should be Minimum of 6 Digits');
	define('Error_device_terminal_max_len','Card Acceptor Terminal ID should be Maximum of 8 Digits');
	define('Error_device_terminal_invalid','Please Enter the Valid Card Acceptor Terminal ID');
	define('Error_device_devicetype_empty','Please Select the Device Type');
	define('Error_device_deviceversion_empty','Please Select the Device O/S Version');
	define('Error_device_devicemodel_empty','Please Select the Device Model Number ');
	define('Error_device_devicetype_invalid','Invalid Device Type');
	define('Error_device_deviceversion_invalid','Invalid Device O/S Version');
	define('Error_device_devicemodel_invalid','Invalid Device Model Number ');
	define('Error_device_deviceid_empty','Device Id is not present');
	define('Error_device_deviceid_invalid','Invalid Device Id');
	
	//City
	define('Error_merchant_city_empty', 'Please Enter the City');
	define('Error_merchant_city_alphanum', 'Please Enter Only Alpha Numeric Values with Spaces');
	define('Error_merchant_city_min', 'Please Enter Minimum 4 characters');
	define('Error_merchant_city_max', 'Please Enter Maximum 13 characters');
		//State
	define('Error_merchant_state_empty', 'Please Enter the State');
	define('Error_merchant_state_invalid', 'Please Select the Valid State');
	//zip
	define('Error_merchant_zip_empty', 'Please Enter the Zip Code');
	define('Error_merchant_zip_alphanum', 'Please Enter a Valid Zip Code');
	define('Error_merchant_zip_us', 'Please Enter a Valid Zip Code');
	define('Error_merchant_zip_min', 'Please Enter Minimum 5 characters');
	define('Error_merchant_zip_max', 'Please Enter Maximum 5 characters');
	//Country
	define('Error_merchant_country_empty', 'Please Select the Country');
	define('Error_merchant_country_alphanum', 'Please Enter Only Alpha Numeric Values with Spaces');
	define('Error_merchant_country_min', 'Please Select Minimum 9 characters');
	define('Error_merchant_country_max', 'Please Enter Maximum 9 characters');
	define('Error_merchant_country_invalid', 'Please Select the Valid Country');
	
	//DBA Merchant Name
	define('Error_merchant_dbamerchantname_empty', 'Please Enter the DBA Merchant Name');
	define('Error_merchant_dbamerchantname_alphanum', 'Please Enter Only Alpha Numeric Values with Spaces');
	define('Error_merchant_dbamerchantname_min', 'Please Enter Minimum 4 characters');
	define('Error_merchant_dbamerchantname_max', 'Please Enter Maximum 25 characters');
	//DBA Merchant Name
	define('Error_merchant_dbamcity_empty', 'Please Enter the DBA Merchant City');
	define('Error_merchant_dbamcity_alphanum', 'Please Enter Only Alpha Numeric Values with Spaces');
	define('Error_merchant_dbamcity_min', 'Please Enter Minimum 4 characters');
	define('Error_merchant_dbamcity_max', 'Please Enter Maximum 13 characters');
	//State
	define('Error_merchant_dbamstate_empty', 'Please Enter the DBA Merchant State');
	define('Error_merchant_dbamstate_invalid', 'Please Select the Valid DBA Merchant State');
	
	//DBA Merchant Name
	define('Error_merchant_dbamzip_empty', 'Please Enter the DBA Merchant Zip');
	define('Error_merchant_dbamzip_num', 'Please Enter a Valid DBA Merchant Zip Code');
	define('Error_merchant_dbamzip_min', 'Please Enter Minimum 5 characters');
	define('Error_merchant_dbamzip_max', 'Please Enter Maximum 10 characters');
	define('Error_merchant_bdazip_us', 'Please Enter a Valid DBA Merchant Zip Code');
	
	//DBA Merchant Name
	define('Error_merchant_dbacustservphnum_empty', 'Please Enter the Customer Service Phone Number');
	define('Error_merchant_dbacustservphnum_num', 'Please Enter the Valid Customer Service Phone Number');
	define('Error_merchant_dbacustservphnum_min', 'Please Enter Minimum 10 characters');
	define('Error_merchant_dbacustservphnum_max', 'Please Enter Maximum 10 characters');
		//Time Zone
	define('Error_merchant_timezone_empty', 'Please Select the Time Zone');
	define('Error_merchant_timezone_invalid', 'Please Select the Valid Time Zone');
	//Merchant Mobile
	define('Error_merchant_mobNumber_empty', 'Please Enter the Mobile Number');
	define('Error_merchant_mobNumber_num', 'Please Enter the Valid Mobile Number');
	define('Error_merchant_mobNumber_min', 'Please Enter Minimum 10 characters');
	define('Error_merchant_mobNumber_max', 'Please Enter Maximum 10 characters');
	//emailId
	
	define('Error_merchant_emailid_empty', 'Please Enter the Email Id');
	define('Error_merchant_emailid_invalid', 'Please Enter a Valid Email Id');
	define('Error_merchant_emailid_min', 'Please Enter Minimum 10 characters');
	define('Error_merchant_emailid_max', 'Please Enter Maximum 45 characters');
	
	//Category Code
	define('Error_merchant_catcode_empty', 'Please Enter the Category Code');
	define('Error_merchant_catcode_num', 'Please Enter the Valid Category Code');
	define('Error_merchant_catcode_min', 'Please Enter Minimum 4 characters');
	define('Error_merchant_catcode_max', 'Please Enter Maximum 4 characters');
	//acqidcode
	
	define('Error_merchant_acqidcode_empty', 'Please Enter the Acquirer Identification Code');
	define('Error_merchant_acqidcode_num', 'Please Enter the Valid Acquirer Identification Code');
	define('Error_merchant_acqidcode_min', 'Please Enter Minimum 11 characters');
	define('Error_merchant_acqidcode_max', 'Please Enter Maximum 11 characters');
	
	
	//Card Acceptor Merchant Number
	define('Error_merchant_merchantnumber_zero', 'Please Enter the Valid Card Acceptor Merchant Number');
	define('Error_merchant_merchantnumber_empty', 'Please Enter the Card Acceptor Merchant Number');
	define('Error_merchant_merchantnumber_alphanum', 'Please Enter Only Alpha Numeric Values');
	define('Error_merchant_merchantnumber_min', 'Please Enter Minimum 15 characters');
	define('Error_merchant_merchantnumber_max', 'Please Enter Maximum 15 characters');
	
	/*
	 * Error messages for device management
	 */
	define('Error_device_adddevice_merchantId_empty', 'Please select a merchant');
	define('Error_device_adddevice_merchantId', 'Invalid merchantId');
	define('Error_Invalid_MerchantID','Invalid Merchant ID');
	define('Error_Nospecialchars','No Special characters are allowed');
	define('Error_reason','Please Select The Reason');
	define('Error_Invalid_device','Invalid Device ID');
	define('Error_Invalid_pagestart','Invalid Start Value Please Select From the Pagination');
	define('Error_invalid_status',"Invalid Status");
	define('Error_Invalid_device_user','Invalid Device User ID');
	define('Error_Invalid_user_Id','Invalid User ID');
	define('Error_Merchant_DOESNTEXIST',"Merchant Does Not Exists");
	
	/*
	 * Error Messages for Report Dashboard
	 */
	define('Error_Report_Dashboard_From_Empty','Please Select the Start Date');
	define('Error_Report_Dashboard_From_Invalid','Invalid Start Date');
	define('Error_Report_Dashboard_From_To','End Date Should not Exceed Start Date');
	define('Error_Report_Dashboard_From_Cur','Start Date Should not Exceed Current Date');
	define('Error_Report_Dashboard_To_Cur','End Date Should not Exceed Current Date');
	define('Error_Report_Dashboard_To_Empty','Please Select the End Date');
	define('Error_Report_Dashboard_To_Invalid','Invalid End Date');
	define('Error_Report_Dashboard_To_Exceed','Date Range Should not exceed 31 days');
	
	/**
	 * 
	 */
	
		define('Error_Report_Dashboard_Merchant_Empty','Please Select the Merchant Name');
	define('Error_Report_Dashboard_Merchant_Invalid','Invalid Merchant Name');
	define('Error_Invalid_Reader_status','Invalid Reader Status');
	define('Error_Invalid_Reader','Invalid Reader ID');
	define('Error_Invalid_Device_match_status','Invalid Device ID');
	/*
	 * Change challenge question
	 */
	define('Failure_updated_user_security','Challenge Question is Reset, Please Logout and Login into Application');
	define('Failure_updated_user_password','Password is Reset, Please Logout and Login into Application');
	/*
	 * Title for Merchantlog
	 */
	
	define('Title_Merchant_log', 'Merchant Log');
	
	
	define('Error_Invalid_Category_Id','Invalid Category ID');
?>
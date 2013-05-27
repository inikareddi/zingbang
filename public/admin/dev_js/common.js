jQuery.validator.addMethod("postalcode", function(postalcode, element) {
	return this.optional(element) || postalcode.match(/(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXYabceghjklmnpstvxy]{1}\d{1}[A-Za-z]{1} ?\d{1}[A-Za-z]{1}\d{1})$/);
}, "Please Enter The Valid Zip Code");

jQuery.validator.addMethod("postalcodezero", function(postalcodezero, element) {
	var flag;
	if(postalcodezero=="00000" || postalcodezero=="00000-0000"){
		flag=false;
	}else{
		flag=true;
	}
	return this.optional(element) || flag ;
}, "Please Enter The Valid Zip Code");

jQuery(function() {
	jQuery.validator.addMethod("loginRegex", function(value, element) {
	    return this.optional(element) || /^[a-z0-9]+$/i.test(value);
	}, "Username must contain only letters, numbers, or dashes.");
	});
jQuery(function() {
	jQuery.validator.addMethod("noSpace", function(value, element) { 
		  return value.indexOf(" ") < 0 && value != ""; 
		}, "No space Please and don't leave it empty");
	});
	jQuery(function() {
		jQuery.validator.addMethod('atLeastOneChecked', function(value, element) {
		  return ($('.cbgroup input:checked').length > 0);
		});
	});
	jQuery(function() {
		jQuery.validator.addMethod("alphanumericspecial", function(value, element) {
        return this.optional(element) || value == value.match(/^[-a-zA-Z0-9@!$%_ ]+$/);
        },"Only letters, Numbers & Space/underscore Allowed.");
	jQuery.validator.addClassRules('alphanumericspecial', {
		    'alphanumericspecial': true
		});
    });
	
	jQuery(function() {
		jQuery.validator.addMethod("alpha", function(value, element) {
return this.optional(element) || value == value.match(/^[a-zA-Z]+$/);
},"Only Characters Allowed.");
    jQuery.validator.addClassRules('alpha', {
	    'alpha': true
	});
    });
	jQuery(function() {
		jQuery.validator.addMethod("alphanumeric", function(value, element) {
return this.optional(element) || value == value.match(/^[a-z0-9A-Z#]+$/);
},"Only Characters, Numbers & Hash Allowed.");
		jQuery.validator.addClassRules('alphanumeric', {
	    'alphanumeric': true
	});
    }
    );
	jQuery(function() {
		jQuery.validator.addMethod("alphanumericzero", function(value, element) {
			var flag;
			if(value=="000000000000000"){
				flag=false;
			}else{
				flag=true;
			}
			return this.optional(element) || flag ;
		}, "Please specify a valid postal/zip code");
    }
    );
	jQuery(function() {
		jQuery.validator.addMethod("alphanumericwspace", function(value, element) {
return this.optional(element) || value == value.match(/^[a-z0-9A-Z]+$/);
},"Only Characters, Numbers & Hash Allowed.");
		
    }
    );
	
jQuery(function(){
		jQuery.validator.addMethod("passwd_policy", function( value, element, param ) {
        
		return this.optional(element)
            || (/*/.[!,@,#,$,%,^,&,*,?,_,~]/.test(value) 
                &&*/ /[0-9]/.test(value)
                && /[a-zA-Z]/.test(value)
               /* && /[]/.test(value)*/);
    },"Your Password should contain at least one digit and at least one uppercase"
      );
	jQuery.validator.addClassRules('passwd_policy', {
	    'passwd_policy': true
	});
});



jQuery(function(){
		jQuery.validator.addMethod("nospecialcharacter", function( value, element) {
			var spchar=/[!,@,#,$,%,^,&,*,?,_,~,+,\-,.,<,>,|,=,\},\[,\],\{,\(,\),\/,\\,\',\",\:,\;,\`]/;
			var spcharstart=/^[!,@,#,$,%,^,&,*,?,_,~,+,\-,.,<,>,|,=,\},\[,\],\{,\(,\),\/,\\,\',\",\:,\;,\`]/;
			
			return this.optional(element)
            || (!spchar.test(value));
    }," Enter Alpha numeric characters"
      );
		/*jQuery.validator.addClassRules('nospecialcharacter', {
		    'nospecialcharacter': true
		});*/
});

/*
 * jQuery method to validate password
 * 
 * Allowed characters are : a-z, A-Z and 0-9
 */
jQuery(function(){
	jQuery.validator.addMethod("pass", function( value, element) {
        var spchar=/.[!,@,#,$,%,^,&,*,?,_,~,+,\-,.,<,>,|,=,\},\[,\],\{,\(,\),\/,\\,\',\",\:,\;,\`]/;
		return this.optional(element)
            || (/[0-9]/.test(value)
               /* && /[a-z]/.test(value)*/
                && /[A-Z]/.test(value)
                /*&& !spchar.test(value)*/);
    }," Enter Alpha numeric characters"
      );
	jQuery.validator.addClassRules('pass', {
	    'pass': true
	});
});


/*
 * jQuery method to validate Address field
 * 
 * Allowed characters are : a-z, A-Z, 0-9 and splchars{(,),#,&,-,_,.,:,/}
 */
jQuery(function(){
	jQuery.validator.addMethod("address", function( value, element) {
        //var spchar=/.[!,@,$,%,^,*,?,~,+,<,>,|,=,\},\[,\],\{,\\,\',\",\;,\`]/;
		//var spchar=/[\'^$%&*()}{@~?><>!\"|=+_]/;
        //var alnums =/^[a-z0-9A-Z ]+$/;
       // var alnumscomma =/[a-z0-9A-Z ,]/;
        //var allowed=/.[#&_\\-.\(\)\/\:]/;
		//var allowed = /[\'^$%&*()}{@~?><>!\"|=+_]/
		var notallowed=/[!@$%^*?~+<>|=\}\[\]\{\\\'\"\;\`]/;
		var allowed=/^[a-zA-Z][a-zA-Z0-9.,#&-_\:\/\)\(\\]?$/;
		//alert(allowed.test(value));
		/*if(!value.match(allowed)){
			flag = false;	
		}*/
		//alert(allowed.test(value));
		//return this.optional(element) || allowed.test(value);
		return this.optional(element) || !notallowed.test(value);
    }," Enter Alpha numeric characters"
      );
	jQuery.validator.addClassRules('address', {
	    'address': true
	});
});


	
/*
 * jQuery method to validate names
 * 
 * Allowed characters are : a-z, A-Z, 0-9 and spaces
 */
jQuery(function() {
	jQuery.validator.addMethod("alphanumericspace", function(value, element) {
		return this.optional(element) || value == value.match(/^[a-z0-9A-Z ]+$/);
	},"Only Characters, Numbers & Space Allowed.");
	jQuery.validator.addClassRules('alphanumericspace', {
	    'alphanumericspace': true
	});
});

/*
 * jQuery method to validate alpha numeric values with spaces and apostrophe
 * 
 * Allowed characters are : a-z, A-Z, 0-9, apostrophe and spaces
 */
jQuery(function() {
	jQuery.validator.addMethod("alphanumericspaceapostrophe", function(value, element) {
		return this.optional(element) || value == value.match(/^[a-z0-9A-Z '?]+$/);
	},"Only Characters, Numbers & Space Allowed.");
	jQuery.validator.addClassRules('alphanumericspaceapostrophe', {
	    'alphanumericspaceapostrophe': true
	});
});

/*
 * jQuery method to validate email structure
 * 
 * Allowed characters are : a-z, A-Z,.,_ and @
 */
jQuery(function() {
	jQuery.validator.addMethod("emailparse", function(value, element) {
		value = jQuery.trim(value);
return this.optional(element) || value == value.match(/^[a-zA-Z0-9._@]+$/);
},"Only Characters Allowed.");
jQuery.validator.addClassRules('emailparse', {
    'emailparse': true
});
});

/*
 * jQuery method to validate only numbers 
 */
jQuery(function() {
	jQuery.validator.addMethod("numbersonly", function(value, element) {
//return this.optional(element) || value == value.match(/^[1-9]\d+$/);
return this.optional(element) || value == value.match(/^[1-9][0-9]*$/);
},"Only Characters Allowed.");
jQuery.validator.addClassRules('numbersonly', {
    'numbersonly': true
});
});



/*
 * 
 * This is for email domain checking with an ajax call
 */
	
	jQuery(function() {
		jQuery.validator.addMethod("//emailMX", function(value, element) {
		 var url = document.location.href.split("/");
		 var xmlurl = baseUrl+'/admin/index/checkemailvalidate';
		 var flag = false;
		  jQuery.post(xmlurl, {username:jQuery.trim(value)},
					 function(data) {
					       if(data == 0){
					           flag = false;
				       }else if(data == 1){
				    	   flag = true;
				       }    
				   } 
				);
	     return flag;
	}, "Invalid domain");
});


	/*
	 * 
	 * This is for userid checking with an ajax call
	 */
		
		jQuery(function() {
			jQuery.validator.addMethod("uniqueUsername", function(value, element) {
			 var url = document.location.href.split("/");
			 var xmlurl = baseUrl+'/admin/index/checkusernameexistance';
			 var flag = false;
			  jQuery.post(xmlurl, {username:jQuery.trim(value)},
						 function(data) {
						       if(data == 0){
						           flag = true;
					       }else if(data == 1){
					    	   flag = false;
					       }    
					   } 
			  
					);
		     return flag;
		}, "Username is Already Taken");
	});


		
		
		
		
		
		

/*
* Function to validate registration form
*/

function validateRegistration() {
	var form = jQuery("#signupform");
	jQuery.ajaxSetup({async:false});
	var validator = jQuery(form).validate({
		
		rules: {
			firstname:
			{
				required: true,
				minlength: 3,
				maxlength: 20,
				alphanumericspace: true
			},
			lastname:
			{
				required: true,
				minlength: 1,
				maxlength: 20,
				alphanumericspace: true
			},
			useremail:
			{
				required: true,
				maxlength: 50,
				email: true,
				emailparse: true,
				//emailMX: false
			},
			phonenumber:
			{
				required: true,
				minlength: 10,
				maxlength: 10,
				number: true,
				numbersonly: true
			},
			username:
			{
				required: true,
				maxlength: 50,
				email: true,
				emailparse: true,
				//emailMX: false,
				uniqueUsername: true
			},
			role:
			{
				required: true,
				number: true
			}
		},

		
			messages: {
				firstname: {
					required: "Please Enter First Name",					
					minlength: jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Please Enter only Alpha numeric values with spaces"
				},
				lastname: {
					required: "Please Enter Last Name",
					minlength: jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Please Enter only Alpha Numeric Values with Spaces"
				},
				useremail: {
					required: "Please Enter Email Address",
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					email: "Please Enter Valid Email Address",
					emailparse: "Only Alpha Numeric with .@_ are Allowed",
					////emailMX: "Please Enter valid Email Address"
				},
				phonenumber: {
					required: "Please Enter Contact Number",
					minlength:jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					number: "Contact Number Should be Numeric",
					numbersonly: "Contact Number Should not Start with 0"
				},
				username: {
					required: "Please Enter Username",
					maxlength: jQuery.format("Please Enter Maximum {0} Characters"),
					email: "Please Enter Valid Username",
					emailparse: "Only Alpha Numeric with .@_ are Allowed",
					////emailMX: "Please Enter Valid Username",
					//uniqueUsername: "Username Already Exists"
				},
				role: {
					required: "Please Select a Role",
					number: "Please Select a Role"
				}
			},
			
		// the errorPlacement has to take the table layout into account
		errorPlacement: function(error, element) {
			element.parent().next().html('');
				error.appendTo( element.parent().next() );
		},
		// specifying a submitHandler prevents the default submit, good for the demo
		submitHandler: function(form) {
			form.submit();
		},
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			// set &nbsp; as text for IE
			//alert(label);	
			label.html("&nbsp;").addClass("checked");
		},
		debug: true
	});
}

/*
* Function to validate registration form
*/

function validateEdit() {
	var form = jQuery("#signupform");
	jQuery.ajaxSetup({async:false});
	var validator = jQuery(form).validate({
		
		rules: {
			firstname:
			{
				required: true,
				minlength: 3,
				maxlength: 20,
				alphanumericspace: true
			},
			lastname:
			{
				required: true,
				minlength: 1,
				maxlength: 20,
				alphanumericspace: true
			},
			useremail:
			{
				required: true,
				maxlength: 50,
				email: true,
				emailparse: true,
				//emailMX: false
			},
			phonenumber:
			{
				required: true,
				minlength: 10,
				maxlength: 10,
				number: true,
				numbersonly: true
			},
			role:
			{
				required: true,
				number: true
			}
		},

		
			messages: {
				firstname: {
					required: "Please Enter First Name",
					minlength: jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Please Enter only Alpha numeric values with spaces"
				},
				lastname: {
					required: "Please Enter Last Name",
					minlength: jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Please Enter only Alpha numeric values with spaces"
				},
				useremail: {
					required: "Please Enter Email Address",
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					email: "Please Enter valid Email Address",
					emailparse: "Only Alpha numeric with .@_ are allowed",
					//emailMX: "Please Enter valid Email Address"
				},
				phonenumber: {
					required: "Please Enter Contact Number",
					minlength:jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					number: "Contact Number should be numeric",
					numbersonly: "Contact Number should not start with 0"
				},
				role: {
					required: "Please select a Role",
					number: "Please select a Role"
				}
			},
			
		// the errorPlacement has to take the table layout into account
		errorPlacement: function(error, element) {
			element.parent().next().html('');
				error.appendTo( element.parent().next() );
		},
		// specifying a submitHandler prevents the default submit, good for the demo
		submitHandler: function(form) {
			form.submit();
		},
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			// set &nbsp; as text for IE
			label.html("&nbsp;").addClass("checked");
		},
		debug: true
	});
}


/*
* Function to validate personal Info
*/

function validatePersonal() {
	var form = jQuery("#signupform");
	jQuery.ajaxSetup({async:false});
	var validator = jQuery(form).validate({
		
		rules: {
			firstname:
			{
				required: true,
				minlength: 3,
				maxlength: 20,
				alphanumericspace: true
			},
			lastname:
			{
				required: true,
				minlength: 1,
				maxlength: 20,
				alphanumericspace: true
			},
			useremail:
			{
				required: true,
				maxlength: 50,
				email: true,
				emailparse: true,
				//emailMX: false
			},
			phonenumber:
			{
				required: true,
				minlength: 10,
				maxlength: 10,
				number: true,
				numbersonly: true
			}
		},

		
			messages: {
				firstname: {
					required: "Please Enter First Name",
					minlength: jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Please Enter only Alpha numeric values with spaces"
				},
				lastname: {
					required: "Please Enter Last Name",
					minlength: jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Please Enter only Alphanumeric values with spaces"
				},
				useremail: {
					required: "Please Enter Email Address",
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					email: "Please Enter valid Email Address",
					emailparse: "Only Alpha numeric with .@_ are allowed",
					//emailMX: "Please Enter valid Email Address"
				},
				phonenumber: {
					required: "Please Enter Contact Number",
					minlength:jQuery.format("Please Enter minimum {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					number: "Contact Number should be numeric",
					numbersonly: "Contact Number should not start with 0"
				}
			},
			
		// the errorPlacement has to take the table layout into account
		errorPlacement: function(error, element) {
			element.parent().next().html('');
				error.appendTo( element.parent().next() );
		},
		// specifying a submitHandler prevents the default submit, good for the demo
		submitHandler: function(form) {
			form.submit();
		},
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			// set &nbsp; as text for IE
			label.html("&nbsp;").addClass("checked");
		},
		debug: true
	});
}

/*
 * Function to validate Password
 */
function validatePassword(){
	var form = jQuery("#signupform");
	var validator = jQuery("#signupform").validate({
		rules: {
			old_password:
			{
				required: true,
				minlength: 8,
				maxlength: 16,
				pass: true,
				nospecialcharacter: true
			},
			new_password:
			{
				required: true,
				minlength: 8,
				maxlength: 16,
				pass: true,
				nospecialcharacter: true
			},
			confirm_password:
			{
				required: true,
				minlength: 8,
				maxlength: 16,
				pass: true,
				nospecialcharacter: true,
				equalTo: "#new_password"
			}
		},

		messages: {
			old_password: {
				required: "Please Enter Old Password",
				minlength: jQuery.format("Please Enter at least {0} characters"),
				maxlength: jQuery.format("Please Enter maximum {0} characters"),
				pass: "Invalid Old Password",
				nospecialcharacter: "No Special characters are allowed"
			},
			new_password: {
				required: "Please Enter New Password",
				minlength: jQuery.format("Please Enter at least {0} characters"),
				maxlength: jQuery.format("Please Enter maximum {0} characters"),
				pass: "New Password must contain a minimum of one number and one uppercase letter",
				nospecialcharacter: "No Special characters are allowed"
			},
			confirm_password: {
				required: "Please Re-enter New Password",
				minlength: jQuery.format("Please Enter at least {0} characters"),
				maxlength: jQuery.format("Please Enter maximum {0} characters"),
				pass: "Re-enter NewPassword must contain a minimum of one number and one uppercase letter",
				nospecialcharacter: "No Special characters are allowed",
				equalTo: "Please Enter the same as New Password"
			}
		},
			
		// the errorPlacement has to take the table layout into account
		errorPlacement: function(error, element) {
			element.parent().next().html('');
			/*alert(error.html());*/
			var len = error.html();
			//if(len.length > 25) {
				error.css('line-height', '1em');
				error.css('display', 'block');
				error.css('padding-left', '3px');
			//}
			error.appendTo( element.parent().next() );
				
		},
		// specifying a submitHandler prevents the default submit, good for the demo
		submitHandler: function(form) {
			form.submit();
		},
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			// set &nbsp; as text for IE
			label.html("&nbsp;").addClass("checked");
		},
		debug: true
	});	
}

/*
 * Function to validate Password
 */
function validateTempPassword(){
	var form = jQuery("#signupform");
	var validator = jQuery("#signupform").validate({
		rules: {
			old_password:
			{
				required: true,
				minlength: 8,
				maxlength: 16,
				pass: true,
				nospecialcharacter: true
			},
			new_password:
			{
				required: true,
				minlength: 8,
				maxlength: 16,
				pass: true,
				nospecialcharacter: true
			},
			confirm_password:
			{
				required: true,
				minlength: 8,
				maxlength: 16,
				pass: true,
				nospecialcharacter: true,
				equalTo: "#new_password"
			}
		},

		messages: {
			old_password: {
				required: "Please Enter Temporary Password",
				minlength: jQuery.format("Please Enter at least {0} characters"),
				maxlength: jQuery.format("Please Enter maximum {0} characters"),
				pass: "Password must contain a minimum of one number and one uppercase letter",
				nospecialcharacter: "No Special characters are allowed"
			},
			new_password: {
				required: "Please Enter New Password",
				minlength: jQuery.format("Please Enter at least {0} characters"),
				maxlength: jQuery.format("Please Enter maximum {0} characters"),
				pass: "Password must contain a minimum of one number and one uppercase letter",
				nospecialcharacter: "No Special characters are allowed"
			},
			confirm_password: {
				required: "Please Re-enter New Password",
				minlength: jQuery.format("Please Enter at least {0} characters"),
				maxlength: jQuery.format("Please Enter maximum {0} characters"),
				pass: "Password must contain a minimum of one number and one uppercase letter",
				nospecialcharacter: "No Special characters are allowed",
				equalTo: "Please Enter the same as New Password"
			}
		},
			
		// the errorPlacement has to take the table layout into account
		errorPlacement: function(error, element) {
			element.parent().next().html('');
			jQuery('.rite_Error').css('width', '270px');
			var len = error.html();
			//if(len.length > 25) {
				error.css('line-height', '1em');
				error.css('display', 'block');
				//error.css('padding-left', '3px');
			//}
			error.appendTo( element.parent().next() );
				
		},
		// specifying a submitHandler prevents the default submit, good for the demo
		submitHandler: function(form) {
			form.submit();
		},
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			// set &nbsp; as text for IE
			label.html("&nbsp;").addClass("checked");
		},
		debug: true
	});	
}

/*
 * Function to validate security question
 */
function validatesecurityquestion() {
	 var form = jQuery("#signupform");
		// validate signup form on keyup and submit
		var validator = jQuery("#signupform").validate({
			rules: {
				security1:
				{
					required: true,
					minlength: 1,
					maxlength: 60,
					alphanumericspaceapostrophe: true
				},
				answer:
				{
					required: true,
					minlength: 1,
					maxlength: 30,
					alphanumericspace: true
				},
				retypeanswer:
				{
					required: true,
					minlength: 1,
					maxlength: 30,
					alphanumericspace: true,
					equalTo: "#answer"
				}
			},

			messages: {
				security1: {
					required: "Please Enter Challenge Question",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspaceapostrophe: "Only Alphanumeric, Spaces and (',?) are allowed"
				},
				answer: {
					required: "Please Enter Secret Answer",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Only Alphanumeric and Spaces are allowed"
				},
				retypeanswer: {
					required: "Please Re-enter Secret Answer",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Only Alphanumeric and Spaces are allowed",
					equalTo: "Please Enter the same as Secret Answer"
				}
			},
				
			// the errorPlacement has to take the table layout into account
			errorPlacement: function(error, element) {
				element.parent().next().html('');
				error.appendTo( element.parent().next() );
			},
			
			// specifying a submitHandler prevents the default submit, good for the demo
			submitHandler: function(form) {
				form.submit();
			},
			
			// set this class to error-labels to indicate valid fields
			success: function(label) {
				// set &nbsp; as text for IE
				label.html("&nbsp;").addClass("checked");
			},
			debug: true
		});
}

/*
 * Function to validate first login for a user
 */
function validatefirstlogin() {
	//alert("Here");
	 var form = jQuery("#signupform");
		// validate signup form on keyup and submit
		var validator = jQuery("#signupform").validate({
			rules: {
				oldpwd:
				{
					required: true,
					minlength: 8,
					maxlength: 16,
					pass: true,
					nospecialcharacter: true
				},
				newpwd:
				{
					required: true,
					minlength: 8,
					maxlength: 16,
					pass: true,
					nospecialcharacter: true
				},
				retypepwd:
				{
					required: true,
					minlength: 8,
					maxlength: 16,
					pass: true,
					nospecialcharacter: true,
					equalTo: "#newpwd"
				},
				squestion:
				{
					required: true,
					minlength: 1,
					maxlength: 60,
					alphanumericspaceapostrophe: true
				},
				sanswer:
				{
					required: true,
					minlength: 1,
					maxlength: 30,
					alphanumericspace: true
				},
				retypesans:
				{
					required: true,
					minlength: 1,
					maxlength: 30,
					alphanumericspace: true,
					equalTo: "#sanswer"
				}
			},

			messages: {
				oldpwd: {
					required: "Please Enter Temporary Password",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					pass: "Invalid Temporary Password",
					nospecialcharacter: "No Special characters are allowed"
				},
				newpwd: {
					required: "Please Enter New Password",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					pass: "New Password must contain a minimum of one number and one uppercase letter",
					nospecialcharacter: "No Special characters are allowed"
				},
				retypepwd: {
					required: "Please Re-enter New Password",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					pass: "Re-enter New Password must contain a minimum of one number and one uppercase letter",
					nospecialcharacter: "No Special characters are allowed",
					equalTo: "Please Enter the same as New Password"
				},
				squestion: {
					required: "Please Enter Challenge Question",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspaceapostrophe: "Only Alphanumeric, Spaces and (',?) are allowed"
				},
				sanswer: {
					required: "Please Enter Secret Answer",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Only Alphanumeric and Spaces are allowed"
				},
				retypesans: {
					required: "Please Re-enter Secret Answer",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Only Alphanumeric and Spaces are allowed",
					equalTo: "Please Enter the same as Secret Answer"
				}
			},
				
			// the errorPlacement has to take the table layout into account
			errorPlacement: function(error, element) {
				element.parent().next().html('');
				jQuery('.rite_Error').css('width', '270px');
				var len = error.html();
				if(len.length > 20) {
					//alert("Here");
					//jQuery('.rite_Error').css('width', '270px');
					error.css('line-height', '1.2em');
					error.css('display', 'block');
				}
				error.appendTo( element.parent().next() );
			},
			
			// specifying a submitHandler prevents the default submit, good for the demo
			submitHandler: function(form) {
				form.submit();
			},
			
			// set this class to error-labels to indicate valid fields
			success: function(label) {
				// set &nbsp; as text for IE
				label.html("&nbsp;").addClass("checked");
			},
			debug: true
		});
}


/*
 * Function to validate login
 */
function validateslogin() {
	
	 var form = jQuery("#signupform");
		// validate signup form on keyup and submit
	 jQuery.ajaxSetup({async:false});
	 
		var validator = jQuery("#signupform").validate({
			
			rules: {
				password:
				{
					required: true,
					minlength: 8,
					maxlength: 16,
					pass: true,
					nospecialcharacter: true
				},
				username:
				{
					required: true,
					maxlength: 50,
					email: true,
					emailparse: true,
					//emailMX:false
				}
				
			},
			
			messages: {
				password: {
					required: "Please Enter Password",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					pass: "Password must contain a minimum of one number and one uppercase letter",
					nospecialcharacter: "No Special characters are allowed"
				},
				username: {
					required: "Please Enter Username",
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					email: "Please Enter valid Username",
					emailparse: "Only Alpha numeric with .@_ are allowed",
					//emailMX: "Please Enter valid Username"
				}
			},
				
			// the errorPlacement has to take the table layout into account
			errorPlacement: function(error, element) {
				  // alert(jQuery(element).val());
					$('div.empty-10').css('display', 'none');
					element.parent().next().html('');
					error.css('margin-left','3px');
					error.css('line-height','1.5em');
					error.css('padding-left','0px');					
					error.appendTo(  element.parent().next() );
			},
			
			// specifying a submitHandler prevents the default submit, good for the demo
			submitHandler: function(form) {
				
				form.submit();
			},
			
			// set this class to error-labels to indicate valid fields
			success: function(label) {
				// set &nbsp; as text for IE
				
				if(label.hasClass('error')){
					label.parent().html('');
					$('div.empty-10').css('display', '');
				}
			},
			debug: true
		});
		
}



/*
 * Function to validate forgotpassword
 */
function validatesforgotpassword() {
	 var form = jQuery("#signupform");
	 jQuery.ajaxSetup({async:false});
		// validate signup form on keyup and submit
		var validator = jQuery("#signupform").validate({
			rules: {
				loginid:
				{
					required: true,
					maxlength: 50,
					email: true,
					emailparse: true,
					//emailMX: true
				}
				
			},

			messages: {
				loginid: {
					required: "Please Enter Username",
					maxlength: jQuery.format("Enter maximum {0} characters"),
					email: "Please Enter valid Username",
					emailparse: "Only Alpha numeric with .@_ are allowed",
					//emailMX: "Please Enter valid Username"
				}
			},
				
			// the errorPlacement has to take the table layout into account
			errorPlacement: function(error, element) {
				element.parent().next().html('');
					error.appendTo(  element.parent().next() );
			},
			
			// specifying a submitHandler prevents the default submit, good for the demo
			submitHandler: function(form) {
				form.submit();
			},
			
			// set this class to error-labels to indicate valid fields
			success: function(label) {
				// set &nbsp; as text for IE
				label.html("&nbsp;").addClass("checked");
			},
			debug: true
		});
}

/*
 * Function to validate forgotsecurity question
 */
function validatesforgotsecurity() {
	 var form = jQuery("#signupform");
		// validate signup form on keyup and submit
		var validator = jQuery("#signupform").validate({
			rules: {
				answer:
				{
					required: true,
					minlength: 1,
					maxlength: 30,
					alphanumericspace: true
				},
				retypeanswer:
				{
					required: true,
					minlength: 1,
					maxlength: 30,
					alphanumericspace: true,
					equalTo: "#answer"
				}
			},

			messages: {
				answer: {
					required: "Please Enter Secret Answer",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Only Characters, Numbers and Spaces are allowed"
				},
				retypeanswer: {
					required: "Please Re-enter Secret Answer",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericspace: "Only Characters, Numbers and Spaces are allowed",
					equalTo: "Enter the same as Secret Answer"
				}
			},
				
			// the errorPlacement has to take the table layout into account
			errorPlacement: function(error, element) {
				element.parent().next().html('');
					error.appendTo(  element.parent().next() );
			},
			
			// specifying a submitHandler prevents the default submit, good for the demo
			submitHandler: function(form) {
				form.submit();
			},
			
			// set this class to error-labels to indicate valid fields
			success: function(label) {
				// set &nbsp; as text for IE
				label.html("&nbsp;").addClass("checked");
			},
			debug: true
		});
}


// Add Merchant and Edit Merchant Validation


function merchantsearch(){
	
	 jQuery("#merchantname").focus();     /*for autofocus on first field*/
	 jQuery.ajaxSetup({async:false});
	 var form = jQuery('#signupform');
	// validate signup form on keyup and submit
		
	var validator = jQuery("#signupform").validate({
		rules: {
			merchantname:
				{
					required: true,
					minlength: 4,
					maxlength: 50,
					alphanumericspace: true
				},
			address:
				{
					required: true,
					minlength: 10,
					maxlength: 50,
					address: true
				},
			city :
				{
					required: true,
					minlength: 4,
					maxlength: 13,
					alphanumericspace: true
				},
			State:
				{
					required:true
					
				},  
			zip :
				{        
					required:true,
					minlength:5,
					maxlength:10,
					postalcode:true,
					postalcodezero:true
				},
			country:
				{
					required:true
					
				},
			dbamerchantname:
				{
					required:true,
					minlength:4,
					maxlength:25,
					alphanumericspace:true
				},
			dbamcity:
				{
					required: true,
					minlength: 4,
					maxlength: 13,
					alphanumericspace: true
				},
			dbamstate:
				{
					required:true
					
				},
			dbamzip:
				{
					required:true,
					minlength:5,
					maxlength:10,
					postalcode:true,
					postalcodezero:true
				},
			dbacustservphnum:
				{
					required:true,
					minlength:10,
					maxlength:10,
					numbersonly:true
				},
			timZone:
				{
					required:true
				},
			mobNumber:
				{
					required:true,
					minlength:10,
					maxlength:10,
					numbersonly:true

				},
			emailId:
				{
				required: true,
				maxlength: 45,
				email: true,
				emailparse: true,
				//emailMX: true
					
				},
			catcode:
				{
					required: true,
					minlength: 4,
					maxlength: 4,
					numbersonly:true
				},
			acqidcode:
				{
					required: true,
					minlength: 11,
					maxlength: 11,
					numbersonly:true	
				},
				merchantnumber:
				{
					required: true,
					minlength: 15,
					maxlength: 15,
					alphanumericzero:true,
					alphanumericwspace: true
					
				}
				
				
					},

		messages: {

			merchantname: {
				required: "Please Enter Your Merchant Name",
				minlength: jQuery.format("Please Enter Minimum {0} characters"),
				maxlength: jQuery.format("Please Enter Maximum {0} characters"),
				alphanumericspace: "Please Enter Only Alpha Numeric Values with Spaces"
			},
			address:
				{
					required: "Please Enter Your Address",
					minlength: jQuery.format("Please Enter Minimum {0} characters"),
					maxlength: jQuery.format("Please Enter Maximum {0} characters"),
					address: "Only Alphanumeric with &,#,-,_,.,:,/,(,)"
				},
			city :
				{
					required: "Please Enter Your City",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength: jQuery.format("Please Enter Maximum {0} characters"),
					alphanumericspace: "Please Enter Only Alpha Numeric Values with Spaces"
				},
			State:
				{
					required:"Please Select Your State"
					
				},  
			zip :
				{        
					required:"Please Enter Your Zip Code",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					postalcode:"Please Enter The Valid Zip Code",
					postalcodezero:"Please Enter The Valid Zip Code"
				},
			country:
				{
					required:"Please Enter Your Country"
					
				},
			dbamerchantname:
				{
					required:"Please Enter Your DBA Merchant Name",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					alphanumericspace:"Please Enter Only Alpha Numeric Values with Spaces"
				},
			dbamcity:
				{
					required:"Please Enter Your DBA Merchant City",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					alphanumericspace:"Please Enter Only Alpha Numeric Values with Spaces"
				},
			dbamstate:
				{
					required:"Please Select Your DBA Merchant State"
					
				},
			dbamzip:
				{
					required:"Please Enter Your DBA Merchant Zip",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					postalcode:"Please Enter the Valid Zip Code",
					postalcodezero:"Please Enter The Valid Zip Code"
				},
			dbacustservphnum:
				{
					required:"Please Enter Your Customer Service Phone Number",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					numbersonly:"Please Enter the Valid Customer Service Phone Number"
				},
			timZone:
				{
					required:"Please Select Your Time Zone"
				},
			mobNumber:
				{
				required:"Please Enter Your Mobile Number",
				minlength:jQuery.format("Please Enter Minimum {0} characters"),
				maxlength:jQuery.format("Please Enter Maximum {0} characters"),
				numbersonly:"Please Enter a Valid Mobile Number"

				},
			emailId:
				{
				required: "Please Enter Your Email Address",
				maxlength:jQuery.format("Please Enter Maximum {0} characters"),
				email: "Please Enter a Valid Email Address",
				emailparse: "Please Enter a Valid Email Address",
				//emailMX: "Please Enter a Valid Email Address"
					
				},
			catcode:
				{
					required: "Please Enter Your Merchant Category Code",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					numbersonly:"Please Enter the Valid Merchant Category Code"
				},
			acqidcode:
				{
					required: "Please Enter Your Acquirer Identification Code",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					numbersonly:"Please Enter the Valid Acquirer Identification Code"
				},
				merchantnumber:
				{
					required:"Please Enter Your Card Acceptor Merchant Number",
					minlength:jQuery.format("Please Enter Minimum {0} characters"),
					maxlength:jQuery.format("Please Enter Maximum {0} characters"),
					alphanumericzero:"Please Enter the Valid Card Acceptor Merchant Number",
					alphanumericwspace:"Please Enter Only Alpha Numeric Values"
					
				}
			
					},
		// the errorPlacement has to take the table layout into account
		errorPlacement: function(error, element) {
			/*if ( element.is(":radio") )
				error.appendTo( element.parent().next().next() );
			else*/ if ( element.is(":checkbox") ){
				element.parent().next().html('');
				error.appendTo ( element.next() );
			}else{
				element.parent().next().html('');
				error.appendTo( element.parent().next() );
			}
		},
		// specifying a submitHandler prevents the default submit, good for the demo
		submitHandler: function(form) {
		
			
			

			form.submit();
				
		},
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			// set &nbsp; as text for IE
			label.html("&nbsp;").addClass("checked");
		},
		debug: true
	});
	}


jQuery(document).ready(function(){
	jQuery("#devicetype").change(function(){
	
	var device=jQuery("#devicetype").val();
	url=jQuery(location).attr('href');
	urlarray=url.split("/");
	
	var siteurl = urlarray[0]+'//'+urlarray[2]+'/'+urlarray[3]+'/'+urlarray[4]+'/'+urlarray[5];
	jQuery.post(siteurl+"/getdeviceversion", { deviceid : device },function(data) {
		//alert(data);
		var result = data.split('@@##@@##');
		/*alert(result[0]);
		alert(result[1]);*/
jQuery("#ostype").html(result[0]);
jQuery("#modelnum").html(result[1]);
			 } 
	      );
	/*jQuery.post(siteurl+"/getdevicemodel", { versionid : device },function(data) {
		
		jQuery("#modelnum").html(data);
	});*/
});
	
/*jQuery("#ostype").change(function(){
		
		var version=jQuery("#ostype").val();
		
		url=jQuery(location).attr('href');
		urlarray=url.split("/");
		var siteurl = urlarray[0]+'//'+urlarray[2]+'/'+urlarray[3]+'/'+urlarray[4]+'/'+urlarray[5];
		jQuery.post(siteurl+"/getdevicemodel", { versionid : version },function(data) {
			
			jQuery("#modelnum").html(data);
		});
	});*/
	
	


/*jQuery("#reason").change(function(){
	var reason=jQuery("#reason").val();
	if(reason!=""){
		jQuery("#reason").parent().next().html('');
		jQuery("#reasontext").parent().next().html('');
	}
	
	if (reason=="others"){
		jQuery("#reasonothers").css("display","");
	}else{
		jQuery("#reasontext").val("");
		jQuery("#reasonothers").css("display","none");
	}
	
});*/


});


/*
 * Function to validate forgotsecurity question
 */
function validatesaddevice() {
	 var form = jQuery("#signupform");
	 //alert("sdfsdsad");
		// validate signup form on keyup and submit
		var validator = jQuery("#signupform").validate({
			rules: {
				nickname:
				{
					required: true,
					minlength: 4,
					maxlength: 12,
					alphanumericwspace: true
				},
				tid:{
					required: true,
					minlength: 6,
					maxlength: 8,
					numbersonly: true
				},
				devicetype:{
					required: true,
					number: true,
					numbersonly: true
				},
				ostype:{
					required: true,
					number: true,
					numbersonly: true
				},
				modelnum:
				{
					required: true,
					number: true,
					numbersonly: true
				}
			},

			messages: {
				nickname:
				{
					required: "Please Enter your Nickname",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					alphanumericwspace: "Only Alphanumerics without spaces are allowed"
				},
				tid:{
					required: "Please Enter your Card Acceptor Terminal-ID",
					minlength: jQuery.format("Please Enter at least {0} characters"),
					maxlength: jQuery.format("Please Enter maximum {0} characters"),
					numbersonly: "Please Enter the Valid Card Acceptor Terminal-ID"
				},
				devicetype:{
					required: "Please Select a Device type",					
					number: "Please Select a valid Device type",
					numbersonly: "Invalid Device type selected"
				},
				ostype:{
					required: "Please Select a OS Version",					
					number: "Please Select a valid OS Version",
					numbersonly: "Invalid OS Version selected"
				},
				modelnum:
				{
					required: "Please Select a Model Number",					
					number: "Please Select a valid Model Number",
					numbersonly: "Invalid Model Number selected"
				}
			},
				
			// the errorPlacement has to take the table layout into account
			errorPlacement: function(error, element) {
				element.parent().next().html('');
				//alert(error);
					error.appendTo(  element.parent().next() );
			},
			
			// specifying a submitHandler prevents the default submit, good for the demo
			submitHandler: function(form) {
				form.submit();
			},
			
			// set this class to error-labels to indicate valid fields
			success: function(label) {
				// set &nbsp; as text for IE
				label.html("&nbsp;").addClass("checked");
			},
			debug: true
		});
}


function setCursor(node,pos){
	var node = (typeof node == "string" || 
    node instanceof String) ? document.getElementById(node) : node;
    
        if(!node){
            return false;
        }else if(node.createTextRange){
        	
        	  // Firefox
        	    node.scrollLeft = 0;
            return true;
        }else if(node.setSelectionRange){
        	if(jQuery.browser.opera){
        		node.setSelectionRange(pos,pos);
        	}else{
        	node.value = node.value;
        	}
            return true;
        }
        return false;
    }

function validatesreason() {
	 
		// validate signup form on keyup and submit
	var reason=jQuery("#reason").val();
	var spchar=/.[!,@,#,$,%,^,&,*,?,_,~,+,\-,.,<,>,|,=,\},\[,\],\{,\(,\),\/,\\,\',\",\:,\;,\`]/;
	var textval = jQuery.trim(jQuery('#reasontext').val());
	/*if(reason=="others"){
		
		jQuery("#reason").parent().next().html('');
		if(textval == '') {
			var emess = '<label class="error" id="error">Reason Should not be empty</label>';
			jQuery("#reasontext").parent().next().html('');
			jQuery(emess).appendTo(jQuery("#reasontext").parent().next());
			return false;
		} else if(spchar.test(textval)) {
			var emess = '<label class="error" id="error">No Special characters are allowed</label>';
			jQuery("#reasontext").parent().next().html('');
			jQuery(emess).appendTo(jQuery("#reasontext").parent().next());
			return false;
		}
	//	return true;
	//}*///else 
	if (reason==""){
		var emess = '<label class="error" id="error">Please Select The Reason</label>';
		jQuery("#reason").parent().next().html('');
		jQuery("#reasontext").parent().next().html('');
		jQuery(emess).appendTo(jQuery("#reason").parent().next());
		return false;
	}else{
	//	jQuery()
		jQuery("#reason").parent().next().html('');
	
	//else{
		
	//}
	//else{
		//var textval = jQuery.trim(jQuery('#reasontext').val());
	if(textval!=''){
		if(spchar.test(textval)) {
			var emess = '<label class="error" id="error">No Special characters are allowed</label>';
			jQuery("#reasontext").parent().next().html('');
			jQuery(emess).appendTo(jQuery("#reasontext").parent().next());
			return false;
		}
		
	}
	}	
		//return true;
	//}
	return true;
}
jQuery(function() {
	
	jQuery.validator.addMethod("daterange",function (value,element){
		  var frdttme1 = Date.parse(jQuery("#startdate").val());
		     var totme1 = Date.parse(jQuery("#enddate").val());
		     var one_day=1000*60*60*24;
		     var Diff=Math.ceil((totme1-frdttme1)/(one_day));
		     if(Diff>31){
		    	 return false;
		     }else{
		    	 return true;
		     }
		     
	});
	jQuery.validator.addMethod("endrange",function (value,element){
		  var frdttme1 = Date.parse(jQuery("#startdate").val());
		     var totme1 = Date.parse(jQuery("#enddate").val());
		     if(frdttme1<=totme1){
		    	 return true;
		     }else{
		    	 return false;
		     }
		     
	});
	
	
	jQuery.validator.addMethod("dateformat", function(value, element) {
		var objDate,  // date object initialized from the ExpiryDate string
        mSeconds, // ExpiryDate in milliseconds
        day,      // day
        month,    // month
        year;     // year
    // date length should be 10 characters (no more no less)
    if (value.length !== 10) {
        return false;
    }
    // third and sixth character should be '/'
    if (value.substring(2, 3) !== '/' || value.substring(5, 6) !== '/') {
        return false;
    }
    // extract month, day and year from the ExpiryDate (expected format is mm/dd/yyyy)
    // subtraction will cast variables to integer implicitly (needed
    // for !== comparing)
    month = value.substring(0, 2) - 1; // because months in JS start from 0
    day = value.substring(3, 5) - 0;
    year = value.substring(6, 10) - 0;
    // test year range
    if (year < 1000 || year > 3000) {
        return false;
    }
    // convert ExpiryDate to milliseconds
    mSeconds = (new Date(year, month, day)).getTime();
    // initialize Date() object from calculated milliseconds
    objDate = new Date();
    objDate.setTime(mSeconds);
    // compare input date and parts from Date() object
    // if difference exists then date isn't valid
    if (objDate.getFullYear() !== year ||
        objDate.getMonth() !== month ||
        objDate.getDate() !== day) {
        return false;
    }
    // otherwise return true
    return true;
		
	});
	
});
    


function validatedashboard(){
	//alert("sdsds");
	var validator = jQuery("#signupform").validate({
		
		rules: {
			startdate:{
				required: true,
				dateformat:true,
				daterange:true		
			},
	enddate:{
		required: true,
		dateformat:true,
		endrange:true		
	},
	merchant:{
				required: true,
				//number:true,
				numbersonly:true	
			}
			
		},

		messages: {
			startdate:{
			required:"Please Select the Start Date",
			dateformat:"Invalid Start Date",
			daterange:"Date Range Should not Exceed 31 Days"
				
			},
			enddate:{
				required: "Please Select the End Date",
				dateformat:"Invalid End Date",
				endrange:"End Date Should Not be Less Than Start Date"		
			},
			merchant:{
				required: "Please Select the Merchant Name",
				//number: "Select a valid Merchant",
				numbersonly: "Invalid Merchant Name"

					/*,
				daterange:"Date Range Should not Exceed 31 Days"	*/	
			}
		},
		
		
		// the errorPlacement has to take the table layout into account
		errorPlacement: function(error, element) {
			//alert(element.attr('id'));
			//jQuery('#errordisplaydashborad').html('');
		
			//error.appendTo(jQuery('#errordisplaydashborad'));
			//alert(element.parent().ID);
			element.parent().next().html('');
			//alert(error.attr('for',''));
			error.attr('for','');
			
			
				error.appendTo(  element.parent().next() );
		},
		
		// specifying a submitHandler prevents the default submit, good for the demo
		submitHandler: function(form) {
			form.submit();
		},
		
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			// set &nbsp; as text for IE
			label.html("&nbsp;").addClass("checked");
		},
		debug: true
	});
}

				

//function 
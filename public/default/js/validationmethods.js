/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


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


/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * Function to validate login
 */
function validatelogin() {
	
	 var form = jQuery("#login");
		// validate signup form on keyup and submit
	 jQuery.ajaxSetup({async:false});
	 
		var validator = jQuery("#login").validate({
			
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
				  // alert(jQuery(element).attr("name"));
				//element.addClass("validation-error");
                                
				//error.appendTo(  element.parent().next() );
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
					}
			},
			debug: true
		});
		
}


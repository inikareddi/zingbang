/**
 * session checker
 */
function checksession(){ 
	var url = document.location.href.split("/");
	  var xmlurl = baseUrl+'/admin/index/checkusersession';
	  jQuery.ajaxSetup({async:false});
	  jQuery.post(xmlurl, {},
		 function(data) {
		 // alert(data);
		       if(data == 0){
		    	   var url = document.location.href.split("/");
		    	   window.location = baseUrl+'/admin/index';
	       }
	   } 
	);
	
	//setTimeout('checksession()',900000);
	  var sec = 1 * 1000;
	  var min = 60 * sec;
	  //var sessTimeOut = 15 * min;
	var sessTimeOut = 2 * min;
	  sessTimeOut=sessTimeOut;
	setTimeout('checksession()',sessTimeOut);
}

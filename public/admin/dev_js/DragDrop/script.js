/*jslint white: true, browser: true, undef: true, nomen: true, eqeqeq: true, plusplus: false, bitwise: true, regexp: true, strict: true, newcap: true, immed: true, maxerr: 14 */
/*global window: false, REDIPS: true */

/* enable strict mode */
"use strict";

// define redips_init variable
var redips_init;


// redips initialization
redips_init = function () {
	// reference to the REDIPS.drag library and message line
	var	rd = REDIPS.drag,
		msg = document.getElementById('message');
	// how to display disabled elements
	rd.border_disabled = 'solid';	// border style for disabled element will not be changed (default is dotted)
	rd.opacity_disabled = 60;		// disabled elements will have opacity effect
	// initialization
	rd.init();
	// only "smile" can be placed to the marked cell
	rd.mark.exception.d8 = 'smile';
	// prepare handlers
	rd.myhandler_clicked = function () {
		msg.innerHTML = 'Clicked';
	};
	rd.myhandler_dblclicked = function () {
		msg.innerHTML = 'Dblclicked';
	};
	rd.myhandler_moved  = function () {
		msg.innerHTML = 'Moved';
	};
	rd.myhandler_notmoved = function () {
		msg.innerHTML = 'Not moved';
	};
	rd.myhandler_dropped = function () {
		msg.innerHTML = 'Dropped';
	};
	rd.myhandler_switched = function () {
		msg.innerHTML = 'Switched';
	};
	rd.myhandler_clonedend1 = function () {
		msg.innerHTML = 'Cloned end1';
	};
	rd.myhandler_clonedend2 = function () {
		msg.innerHTML = 'Cloned end2';
	};
	rd.myhandler_notcloned = function () {
		msg.innerHTML = 'Not cloned';
	};
	rd.myhandler_deleted = function (cloned) {
		// if cloned element is directly moved to the trash
		if (cloned) {
			// set id of original element (read from redips property)
			// var id_original = rd.obj.redips.id_original;
			msg.innerHTML = 'Deleted (c)';
		}
		else {
			msg.innerHTML = 'Deleted';
		}
	};
	rd.myhandler_undeleted = function () {
		msg.innerHTML = 'Undeleted';
	};
	rd.myhandler_cloned = function () {
		// display message
		msg.innerHTML = 'Cloned';
		// append 'd' to the element text (Clone -> Cloned)
		rd.obj.innerHTML += 'd';
	};
	rd.myhandler_changed = function () {
		// get target and source position (method returns positions as array)
		var pos = rd.get_position();
		// display current row and current cell
		msg.innerHTML = 'Changed: ' + pos[1] + ' ' + pos[2];
	};
};


// toggles trash_ask parameter defined at the top
function toggle_confirm(chk) {
	REDIPS.drag.trash_ask = chk.checked;
}


// toggles delete_cloned parameter defined at the top
function toggle_delete_cloned(chk) {
	REDIPS.drag.delete_cloned = chk.checked;
}


// enables / disables dragging
function toggle_dragging(chk) {
	REDIPS.drag.enable_drag(chk.checked);
}


// function sets drop_option parameter defined at the top
function set_drop_option(radio_button) {
	REDIPS.drag.drop_option = radio_button.value;
}


// show prepared content for saving
function saveAttributeGroup(type,gid,url,tp_values,allready) { 
	// define table_content variable
	var table_content;
	// prepare table content of first table in JSON format or as plain query string (depends on value of "type" variable)
	table_content = REDIPS.drag.save_content('table1', type);
	// if content doesn't exist
	if (!table_content) {
		alert('Please select at least one attribute.');
	}
	// display query string
	else if (type === 'json') {
		//window.open('/my/multiple-parameters-json.php?p=' + table_content, 'Mypop', 'width=350,height=260,scrollbars=yes');
		window.open('multiple-parameters-json.php?p=' + table_content, 'Mypop', 'width=350,height=260,scrollbars=yes');
	}
	else {
		//window.open('/my/multiple-parameters.php?' + table_content, 'Mypop', 'width=350,height=160,scrollbars=yes');
		//window.open('multiple-parameters.php?' + table_content, 'Mypop', 'width=350,height=260,scrollbars=yes');		
		//alert(table_content);
		/*var table_content1 = table_content.replace("&", '@');
		var table_content2 = table_content1.replace("&", '@');
		var table_content3 = table_content2.replace("&", '@');
		var table_content4 = table_content3.replace("&", '@');
		var table_content5 = table_content4.replace("&", '@');
		var table_content14 = table_content5.replace("&", '@');
		alert(table_content14);*/		
		//alert(table_content);
		//alert(tp_values);
		//alert(table_content);
		//alert(allready);
		
		document.getElementById('ajaxDisplay').style.display = "none";
		document.getElementById('ajax-loader-7').style.display = "block";
		
		var total_str = '';
		if(allready!=''){
			total_str = allready+'@'+table_content;
		}else{
			total_str = table_content;
		}
		//alert(table_content);
		//alert(allready);
		//alert(total_str);
		//return false;
		saveAttributeGroupMap(total_str,gid,url,tp_values);
	}
}


// add onload event listener
if (window.addEventListener) {
	window.addEventListener('load', redips_init, false);
}
else if (window.attachEvent) {
	window.attachEvent('onload', redips_init);
}


		
function saveAttributeGroupMap(table_content,gid,url,tp_values){

	var ajaxRequest14;  // The variable that makes Ajax possible!
	try{
		// Opera 8.0+, Firefox, Safari
		ajaxRequest14 = new XMLHttpRequest();
	} catch (e){
		// Internet Explorer Browsers
		try{
			ajaxRequest14 = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try{
				ajaxRequest14 = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e){
				// Something went wrong
				alert("Your browser broke!");
				return false;
			}
		}
	}


		//var url14="ReadingQuestion14.php?action=action&val=1";
		var url14= url +"?gid="+gid+"&table_content="+table_content+"&tp_values="+tp_values;		
		url14=url14+"&sid="+Math.random();
		ajaxRequest14.open("GET", url14, true);
		ajaxRequest14.send(null);
		
		
		ajaxRequest14.onreadystatechange = function  testing(){
			if(ajaxRequest14.readyState == 4){				
				var ajaxDisplay = ajaxRequest14.responseText;	
				//alert(ajaxDisplay);
				document.getElementById('ajaxDisplay').style.display = "block";
				document.getElementById('ajaxDisplay').innerHTML = ajaxDisplay;	
				document.getElementById('ajax-loader-7').style.display = "none";
			}
		}
}
			
			
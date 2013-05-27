<?php
$str1 = "p[]=9_0_1&p[]=11_1_0&p[]=5_1_0&p[]=6_2_0&p[]=7_2_0&p[]=1_2_0&p[]=2_3_0&p[]=3_3_0&p[]=10_3_0";
$str2 = "1_2,2_4,3_3,";

$str1_replace = str_replace('p[]=','',$str1);
$str1_explode = explode('&',$str1_replace);
foreach($str1_explode as $key=>$value){
	$str1_array = explode('_',$value);	
	$str1_array_org[$str1_array['0']] = $str1_array['1'];	
}

echo "<pre>";
print_r($str1_array_org);


$str2_explode = explode(',',substr($str2,0,-1));
foreach($str2_explode as $key=>$value){
	$str2_array = explode('_',$value);
	$str2_array_org[$str2_array['0']] = $str2_array['1'];
}


$str_one = '';
foreach($str2_array_org as $key=>$value){
	$str_one .= $value."#";
	foreach($str1_array_org as $key1=>$value1){
		if($key==$value1){
			$str_one .= $key1.',';		
		}
	}
	$str_one .= "#-";
}
echo $str_one;
?>
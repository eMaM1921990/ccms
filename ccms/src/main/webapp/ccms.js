var activeList=false;
var bOverList=false;

function newCombo(name, id, input_width, value,rw, list_width,list_height,src){
	var dd_html="";
	var dd_container_id=id+"_container";
	var dd_container_name=name+"_containter";
	var dd_image_id=id+"_image";
	var dd_image_name=name+"_image";
	var dd_list_panel_id=id+"_list_panel";
    var dd_list_panel_name=name+"_list_panel";
 	
	dd_html+="<div id='"+dd_container_id+"' name='"+dd_container_name+"' style='white-space:nowrap; position:absolute'>";
	dd_html+="<input type='text' class='listInput' style='width:"+input_width+";' name='"+name+"' id='"+id+"' value ='"+value+"' "+rw+">";
	dd_html+="<img id='"+dd_image_id+"' name='"+dd_image_name+"' class='listImage' src='./images/dropdownlist.jpg' onclick=\"handle_dd_image_click(this,'"+name+"','"+id+"');\"><br/>";
	//dd_html+="<div id='"+dd_list_panel_id+"' name='"+dd_list_panel_name+"' class='listPanel' style='width:"+list_width+";height:"+list_height+";position:absolute;z-index:9999' onmouseout=\"closeDDL(this);\">";
	dd_html+="<div id='"+dd_list_panel_id+"' name='"+dd_list_panel_name+"' class='listPanel' style='display:none' border:0px' onmouseover=\"bOverList='"+id+"'\"; onmouseout=\"bOverList=false;\">";
    document.write(dd_html);
	/*if (src)
	{
		var i;
		var list_html="";
		for (i=0;i<src.length; i++)
	     document.write("<div  id='"+id+"_option_"+i+"' class='listItem' onmouseover=\"handle_dd_item_mouseover(this);\" onmouseout=\"handle_dd_item_mouseout(this);\" onclick=\"handle_dd_select(this,'"+name+"','"+id+"');\">"+src[i]+"</div>");
	
	}
	else
		alert("no src");
*/
   if (src)
   {
	   var list_html="<select id='comboList_"+id+"' name='comboList_"+name+"' size='10' style='width:"+list_width+"' onclick=\"handle_dd_select2(this,'"+id+"');\">";
	   var i;
	   for (i=0;i<src.length ;i++ )
	   {
		   list_html+="<option value='"+src[i]+"'>"+src[i]+"</option>";
	   }
	   list_html+="</select>";
       document.write(list_html);
   }
    dd_html=""; 
    dd_html+="</div>";
	dd_html+="</div>";
//	alert(dd_html);
	document.write(dd_html);
}

function getElementX(obj){
	
	var curleft =0;
	if (obj.offsetParent) {
    	do {
			curleft += obj.offsetLeft;
		   } while (obj = obj.offsetParent);
	}
 return curleft;
}

function getElementY(obj){
	
	var curtop =0;
	if (obj.offsetParent) {
    	do {
			curtop += obj.offsetTop;
		   } while (obj = obj.offsetParent);
	}
 return curtop;
}
function closeDDL(obj){
    var mouseX=event.clientX;
	var mouseY=event.clientY;
	var elm_l_x = getElementX(obj);
	var elm_r_x = elm_l_x+obj.offsetWidth;
	var elm_l_y = getElementY(obj);
	var elm_r_y = elm_l_y+obj.offsetHeight;
	//alert(mouseX+":"+mouseY+"   "+elm_l_x+":"+elm_l_y+ "  "+elm_r_x+":"+elm_r_y);
	if (mouseX<=elm_l_x || mouseX>=elm_r_x || mouseY<=elm_l_y || mouseY>=elm_r_y)
		obj.style.visibility="hidden";
}
function closeDDL2(){
	 
	if (activeList){
		if (bOverList==false){
		    document.getElementById(activeList+"_list_panel").style.display="none";
		    activeList=false;
			return true;
		}
		return false;
	}
   return true;
}
function handle_dd_image_click(imgObj,name,id){
	var oldList=false;
	if (activeList)	{
		oldList=activeList;
		closeDDL2();
	}
	if (oldList!=id){
     document.getElementById(id+"_list_panel").style.display="block";
     document.getElementById("comboList_"+id).focus();
     activeList=id;
     event.cancelBubble=true;//don't trigger document.click
	}
   return false;
}

function handle_dd_select(divObj, name,id){
	 
      document.getElementById(id).value=divObj.innerHTML;
      document.getElementById(id+"_list_panel").style.visibility= "hidden";
	  event.cancelBubble=true;
}

function handle_dd_select2(obj,inputBoxId){
      document.getElementById(inputBoxId).value=obj.options[obj.selectedIndex].value;
	  bOverList = false;
	  closeDDL2();
	  document.getElementById(inputBoxId).focus();

//      document.getElementById(inputBoxId+"_list_panel").style.visibility= "hidden";
//	  event.cancelBubble=true;
}

function handle_dd_item_mouseover(divObj){
	divObj.style.backgroundColor="#0000ff";
	divObj.style.color="#ffffff";
	  event.cancelBubble=true;
}
function handle_dd_item_mouseout(divObj){
	divObj.style.backgroundColor="#ffffff";
	divObj.style.color="#000000";
	  event.cancelBubble=true;
}

function getApprovalByDepartment(){
	var dept_id=$('#department').val();
	var request_type=$('#typeOfRequest').val();
	$.get('getapproval.jsp',{dept_id:dept_id,request_type:request_type},function (response){
		//alert(response);
		//$('#approval').val('');
		$('#approval').empty();
		$('#approval').append(response);
	});
}

function saveApprovalGroups(){
	var selected_approval=$('#approval').val();
	var selected_request=$('#typeOfRequest').val();
	var selected_department=$('#department').val();
	
	$.get('saveapprovalgroup.jsp',{approval:selected_approval.toString(),selected_request:selected_request,selected_department:selected_department},function(response){
		
		if(response.indexOf("Saved")>-1){
			$('#response').html('<div style=\"color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa\"><img src=\"./images/accept16.png\" width=\"16px\" height=\"16px\"> Your Changes have been saved successfully.</div>');
		
			loadApproval();	
		}else{
			$('#response').html('<div style=\"color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa\"><img src=\"./images/alert.jpg\" width=\"16px\" height=\"16px\"> Error during save.</div>');
		}
		
	});
}

function resetDep(){
	$('#department select').val('0');
	$('#department').change();
}

function loadApproval(){
	
	
	var dept_id=$('#department').val();
	var request_type=$('#typeOfRequest').val();
	
	if(dept_id!="0" && request_type!=0){
		
		$.get('getCurrentApproval.jsp',{dept_id:dept_id,request_type:request_type},function (response){
			//alert(response);
			//$('#approval').val('');
			//$('#approval').empty();
			$('#approvaldata tr:last').after(response);
			
		});
	}
	
}

function removeApproval(id){
		
	   $("#approvaldata").find("tr:gt(0)").remove();
	 //
	var selected_request=$('#typeOfRequest').val();
	var selected_department=$('#department').val();
$.get('deleteapproval.jsp',{id:id,selected_request:selected_request,selected_department:selected_department},function(response){
		
		if(response.indexOf("delete")>-1){
			$('#response').html('<div style=\"color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa\"><img src=\"./images/accept16.png\" width=\"16px\" height=\"16px\"> Your Changes have been deleted successfully.</div>');
		
			loadApproval();	
		}else{
			$('#response').html('<div style=\"color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa\"><img src=\"./images/alert.jpg\" width=\"16px\" height=\"16px\"> Error during delete.</div>');
		}
		
	});
}

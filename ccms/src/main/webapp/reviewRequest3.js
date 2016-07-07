var mousePosX=-1;
var mousePosY=-1;
var bAjaxError=false;
var ajaxResponse;
var ajaxDone=true;

function getMouseX(){
	var IE = document.all ? true : false;
	if (!IE)
		document.captureEvents(Event.MOUSEMOVE);
		
	var tempX = 0;
	if (IE) { 
		tempX = event.clientX + document.body.scrollLeft;
	}
	else {   
		document.onmousemove = function(e) {
			tempX = e.pageX;
		};
	}  
	if (tempX < 0) {
		tempX = 0;
	}
    return tempX;
}

function getMouseY(){
	var IE = document.all ? true : false;
	if (!IE)
		document.captureEvents(Event.MOUSEMOVE);

	var tempY = 0;
	if (IE) { // grab the x-y pos.s if browser is IE
		tempY = event.clientY + document.body.scrollTop;
	}
	else {  // grab the x-y pos.s if browser is NS
		document.onmousemove = function(e) {
			tempY = e.pageY;
		};
	}  
	if (tempY < 0) {
		tempY = 0;
	}
	return tempY;
 }

function mySleep(naptime){
      naptime = naptime * 1000;
      var sleeping = true;
      var now = new Date();
      var alarm;
      var startingMSeconds = now.getTime();
      while(sleeping){
         alarm = new Date();
         alarmMSeconds = alarm.getTime();
         if(alarmMSeconds - startingMSeconds > naptime){ sleeping = false; }
      }      
}

function handleAjaxResponse(responseMsg, x, y){
	/*
	var ajaxWinObj=document.getElementById("ajaxWindow");
	var ajaxRespObj=document.getElementById("ajaxResponse");
	var xPos, yPos;
	ajaxRespObj.innerHTML=responseMsg;
    ajaxWinObj.style.visibility='visible';
	
	ajaxWinObj.style.left=mousePosX;
	ajaxWinObj.style.top=mousePosY;
	*/
   ajaxResponse=responseMsg;
   if (responseMsg.toUpperCase().indexOf('SUCCESS')>-1)
	   bAjaxError=false;
   else
	   bAjaxError=true;

   ajaxDone=true;
}

function notifyApprovers(btnObj){
	var warnmsg="An email notification will be sent to all approvers who have not yet signed off.\n Note: this step may take a few moments, proceed?";
	btnObj.disabled=true; 
	
	if (confirm(warnmsg)){
	  var sqlstr="update tblChangeControlLog set approvalStatusID="+3 +",approvedby='"+curLogin+"', approvedDate=getDate() where logID="+llogID+" and approvalStatusID=0";
	 // alert(escape(sqlstr));
      makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);

     if (bAjaxError) {
			  alert(ajaxResponse);
			  return;
	 }

	  sqlstr="update tblChangeControlLog set notified=notified\+1 where logID="+llogID;
	///  alert(encodeURIComponent(sqlstr));
	  makePOSTRequest("updateDB.jsp","sql="+encodeURIComponent(sqlstr),handleAjaxResponse);
     if (bAjaxError) {
			  alert(ajaxResponse);
			  return;
	 }

	  makePOSTRequest2("notifyApprover.jsp","n="+llogID);
	  //which updates number of notifications and change log status to In Progress if it is pending
   	  //document.getElementById("waitwindow").style.visibility="hidden";
     //obsolete, now it is in notifyApprover.jsp
	  
	  setTimeout("window.location.href=window.location.href;",100);
	}
}
var approvalListSelIndex=-1;

/*  obsolete
function handle_onclick(ctrlID){
 var obj=document.getElementById(ctrlID);
 var selIndex= obj.selectedIndex;
 approvalListSelIndex=selIndex;
}
*/

function getStatusOldSelectIndex(ctrlID){
  var obj=document.getElementById(ctrlID);
  approvalListSelIndex = parseInt(obj.value);
  return approvalListSelIndex;
}
function processStatusChange(approvalStatusList) {
	 var objList=document.getElementById(approvalStatusList);
     
	 if(bIsLoginLogOwner && objList.options[objList.selectedIndex].text == "Cancelled") {
		 alert("As the department owner, You are not allowed to select 'Cancelled'.");
		  objList.options[getStatusOldSelectIndex("selIndex")].selected = true;
		  document.body.focus();
		 return;
	 }
	 
	 if(!bIsCreator && objList.options[objList.selectedIndex].text == "Implemented") {
		 alert("Only originator is allowed to change the status to 'Implemented'");
		 objList.options[getStatusOldSelectIndex("selIndex")].selected = true;
		 document.body.focus();
		 return;
	 }
	 
	 if(bIsCreator && !bIsLoginLogOwner &&
			 (objList.options[objList.selectedIndex].text != "Complete" && 
					 objList.options[objList.selectedIndex].text != "Cancelled" &&
					 objList.options[objList.selectedIndex].text != "Implemented") ) {
		 //alert("As the originator, you are only allowed to select 'Complete' if the request is 100% complete(i.e. the change is completed and followups are completed).");
		 alert("As the originator, you are only allowed to select 'Complete', 'Cancelled', or 'Implemented'.");
		  objList.options[getStatusOldSelectIndex("selIndex")].selected = true;
		  document.body.focus();
		 return;
	 }
 	 var warnmsg="You are going to update the request status, proceed?";
	if (checkStatusValid(approvalStatusList))
	{

    // if (confirm(warnmsg))
//        showFollowupWindow('ASWin',true);
//        document.getElementById("statusSelectContainer").style.display="none";
		document.getElementById("logStatcommentContainter").style.display="inline-block";
		window.scrollBy(0,100);
		document.getElementById("finalComment").focus();
	// else
     //  objList.options[getStatusOldSelectIndex("selIndex")].selected=true;
	}
	else{
	    alert("Can not proceed. Some items (including followups) are not approved or signed off yet");
        objList.options[getStatusOldSelectIndex("selIndex")].selected=true;
	}
    document.body.focus();
}


function checkStatusValid(approvalStatusList){
 var objList=document.getElementById(approvalStatusList);

  var theID = objList.options[objList.selectedIndex].value;
  var theStatus = objList.options[objList.selectedIndex].text;
  var bAllSigned = true;
 
  if (theStatus=='Approved') {
//	 for (var i = 0 ; i < signatureArray.length ; i++ )	  {
//		  bAllSigned = bAllSigned && document.getElementById(signatureArray[i]).checked;
//	  }
//	 for (var i = 0 ; i < teamSignatureArray.length ; i++ ) {
//		  bAllSigned = bAllSigned && document.getElementById(teamSignatureArray[i]).checked;
//	 }
//	 //added by wenhu for line team review Jul. 27 2010
//	 if(lineTeamSignatureArray != undefined && lineTeamSignatureArray.length > 0){
//		 for (var i = 0 ; i < lineTeamSignatureArray.length ; i++ ) {
//			  bAllSigned = bAllSigned && document.getElementById(lineTeamSignatureArray[i]).checked;
//		 }
//	 }
	  bAllSigned = isAllSigned();
	  
//     if (bAllSigned){
//    	   return true;
//	 }
//	 else{
//		 return false;
//	 }
	  return bAllSigned;
  }
  else if (theStatus == "Complete") {
//	   for (var i = 0 ; i < signatureArray.length ; i++ ) {
//		  bAllSigned = bAllSigned && document.getElementById(signatureArray[i]).checked;
//	   }
//	   for (var i = 0 ; i < teamSignatureArray.length ; i++ ) {
//		  bAllSigned = bAllSigned && document.getElementById(teamSignatureArray[i]).checked;
//	   }
//	   if(lineTeamSignatureArray != undefined && lineTeamSignatureArray.length > 0) {
//		 for (var i = 0 ; i < lineTeamSignatureArray.length ; i++ ) {
//			  bAllSigned=bAllSigned && document.getElementById(lineTeamSignatureArray[i]).checked;
//		 }
//	   }
	  bAllSigned = isAllSigned();
	  
       if (!bAllSigned) {
		   return false;
       } 

       for (var i=0 ; i < hasFollowupArray.length ; i++ ) {
         var hasFollowupVal = document.getElementById(hasFollowupArray[i]).value.toUpperCase();

		 if (hasFollowupVal == "TRUE" || hasFollowupVal == "Y" || hasFollowupVal == "T")
		    bAllSigned = bAllSigned && document.getElementById(followupSignatureArray[i]).checked;
	  }

//     if (bAllSigned) {
//       return true;
//	 }
//	 else {
//		 return false;
//	 }
     
     return bAllSigned;
  }
  else if (theStatus == "Implemented") {
	  return isAllSigned();
  }
  else
	  return true;
}

function isAllSigned() {
	var bAllSigned = true;
	
	for (var i = 0 ; i < signatureArray.length ; i++ ) {
		bAllSigned = bAllSigned && document.getElementById(signatureArray[i]).checked;
	}
	for (var i = 0 ; i < teamSignatureArray.length ; i++ ) {
		bAllSigned = bAllSigned && document.getElementById(teamSignatureArray[i]).checked;
	}
	if(lineTeamSignatureArray != undefined && lineTeamSignatureArray.length > 0) {
		for (var i = 0 ; i < lineTeamSignatureArray.length ; i++ ) {
			bAllSigned=bAllSigned && document.getElementById(lineTeamSignatureArray[i]).checked;
		}
	}
	   
	return bAllSigned;
}

function isAllFollowupDone() {
	var bAllSigned = true;
	for (var i=0 ; i < hasFollowupArray.length ; i++ ) {
        var hasFollowupVal = document.getElementById(hasFollowupArray[i]).value.toUpperCase();

		 if (hasFollowupVal == "TRUE" || hasFollowupVal == "Y" || hasFollowupVal == "T")
		    bAllSigned = bAllSigned && document.getElementById(followupSignatureArray[i]).checked;
	  }
	return bAllSigned;
}

function handleApprovalStatusCancel(approvalStatusList){
  var objList=document.getElementById(approvalStatusList);
   objList.options[getStatusOldSelectIndex("selIndex")].selected=true;
   //document.getElementById('ASWin').style.visibility='hidden';
   document.getElementById("logStatcommentContainter").style.display="none";

}
function handleApprovalStatusOk(approvalStatusList){
  var objList = document.getElementById(approvalStatusList);

  var theID = objList.options[objList.selectedIndex].value;
  var theStatus = objList.options[objList.selectedIndex].text;

   var s = document.getElementById("finalComment");

	var comm = s.value;
	comm = comm.replace(/'/g,"''");

	//var sqlstr = "update tblChangeControlLog set statusComment='" + comm + "',approvalStatusID=" + theID + ",approvedby='" + curLogin + "', approvedDate=getDate() where logID=" + llogID;

	//var ret = makePOSTRequest("updateDB.jsp", "sql=" + escape(sqlstr), handleAjaxResponse);
    //if (bAjaxError) {
    //	alert(ajaxResponse);
    //	return;
    //}
	
	var sqlstr = "update tblChangeControlLog set statusComment=?,approvalStatusID=" + theID + ",approvedby='" + curLogin + "', approvedDate=getDate() where logID=" + llogID;
	$.ajax({
    	  url: "updateDB3.jsp",
    	  type: "POST",
    	  data: "sql=" + sqlstr + "&paramsNo=1&param1=" + comm,
    	  contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    	  context: document.body,
    	  success: function(){
    		  makePOSTRequest('sendFollowup.jsp', 'n=' + llogID, handleAjaxResponse);
    		  if(theStatus == "In Progress")
    			  makePOSTRequest2("notifyApprover.jsp", "n=" + llogID);
    		  if(theStatus == "Implemented") {
    			  makePOSTRequest2("notifyApproverFollowup.jsp", "n=" + llogID);
    			  if(isAllFollowupDone()) {
    				  makePOSTRequest2("notifyDirector.jsp", "n=" + llogID);
				 }
			 }
    		 alert("Email notification has successfully been sent to the originator.");
    	        
    	         
    	  },
    	  error: function(jqXHR, textStatus, errorThrown) {
    		  alert(textStatus + " " + errorThrown);
    	  }
    	});
    
	 //else {}

	   document.getElementById("selIndex").value=objList.selectedIndex;
	   document.getElementById("logStatcommentContainter").style.display = "none";
       document.getElementById("requestStatCommentPanel").innerHTML = comm;
}

function changeStatusToApproved() {
		
	var approvalStatusList = document.getElementById("approvalStatus");
	var approvedOption = null;
    for(var i = 0 ; i < approvalStatusList.options.length ; i++) {
   	 if(approvalStatusList.options[i].text == "Approved") {
   		approvedOption = approvalStatusList.options[i];
   	 }
   		 
    }
	var sqlstr = "update tblChangeControlLog set approvalStatusID=" + approvedOption.value + " ,approvedby='" + curLogin + "', approvedDate=getDate() where logID=" + llogID;

	var ret = makePOSTRequest("updateDB.jsp", "sql=" + escape(sqlstr), handleAjaxResponse);
	ret = makePOSTRequest('sendFollowup.jsp', 'n=' + llogID); 
	     
	approvedOption.selected = true;
}

function changeStatusToComplete() {
	
	var approvalStatusList = document.getElementById("approvalStatus");
	var completeOption = null;
    for(var i = 0 ; i < approvalStatusList.options.length ; i++) {
   	 if(approvalStatusList.options[i].text == "Complete") {
   		completeOption = approvalStatusList.options[i];
   	 }
   		 
    }
	var sqlstr = "update tblChangeControlLog set approvalStatusID=" + completeOption.value + " ,approvedby='" + curLogin + "', approvedDate=getDate() where logID=" + llogID;

	var ret = makePOSTRequest("updateDB.jsp", "sql=" + escape(sqlstr), handleAjaxResponse);
	ret = makePOSTRequest('sendFollowup.jsp', 'n=' + llogID, handleAjaxResponse); 
	     
	completeOption.selected = true;
}

function changeStatusToRejected() {
	
	var approvalStatusList = document.getElementById("approvalStatus");
	var completeOption = null;
    for(var i = 0 ; i < approvalStatusList.options.length ; i++) {
   	 if(approvalStatusList.options[i].text == "Rejected") {
   		completeOption = approvalStatusList.options[i];
   	 }
   		 
    }
	var sqlstr = "update tblChangeControlLog set approvalStatusID=" + completeOption.value + " ,approvedby='" + curLogin + "', approvedDate=getDate() where logID=" + llogID;

	var ret = makePOSTRequest("updateDB.jsp", "sql=" + escape(sqlstr), handleAjaxResponse);
	ret = makePOSTRequest('sendFollowup.jsp', 'n=' + llogID, handleAjaxResponse); 
	     
	completeOption.selected = true;
}

function  updateSiteControl2(ctrlObj, isSiteControl){
	var warnmsg="You are going to change the request's level, proceed?";
	 
if (bIsSiteControl == isSiteControl)
{
	return;
}
if (!confirm(warnmsg))
{
	//window.location.reload();
	ctrlObj.checked=false;
	if (isSiteControl==1)
		document.getElementById("siteControlNo").checked=true;
	else
		document.getElementById("siteControlYes").checked=true;
	return;
}

// var varAreaID=document.getElementById("areaID").value;
  var sqlstr="update tblChangeControlLog set take2Site="+isSiteControl +" where logID="+llogID + " and take2Site<>"+isSiteControl;
  var sqlstr2="";
  var sqlstr3="";
  var sqlstr4="";

    // alert(sqlstr);
 //    var ret=makePOSTRequest("updateDB.jsp","sql="+encodeURI(sqlstr));
     
	 if (isSiteControl){
	  sqlstr2="insert into tblApprovalSignature(logID, approverID,approverType,approverName,approverAccout,approverEmail,isChecked,rejected, byWho, checkDate, hasFollowup,followup,isFollowupChecked,followupByWho,followupCheckDate) ";
      sqlstr2+="select "+llogID+", appr.ApproverID, appr.approverType,appr.approverName, approverAccout,approverEmail, 0,0, '', null,0,'',0,'',null from tblApprovers appr where (appr.hidden<>'Y' or appr.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
      sqlstr2+="and (not exists (select logID, ApproverID from tblApprovalSignature where logID= "+llogID+" and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site')))) order by appr.sortorder";
	  
	  sqlstr3="insert into tblLogSiteList(logID,approverID,listID, requiredString,isrequired, byWho,checkDate,comment,issubcat) ";
      sqlstr3+="select "+llogID+",sitelist.approverID,sitelist.ID,sitelist.requiredString,0,'',null,'', sitelist.isSubCat from tblSiteList sitelist, tblApprovers appr where sitelist.approverID=appr.ApproverID and (sitelist.hidden<>'Y' or sitelist.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
      sqlstr3+="and sitelist.approverID not in (select approverID from tblLogSiteList where logID="+llogID+") order by sitelist.approverID, sitelist.sortorder";
       
	  sqlstr4="insert into tblOwnerSignature(logID,areaID,approverName,approverAccount,approverEmail,isChecked,byWho,checkdate) ";
      sqlstr4+="select "+llogID+",areaid,ChangeOwnerName,ChangeOwnerAccount,ChangeOwnerEmail,0,'',null from tblAreaOwners a where a.areaID=(select areaid from tblArea where areaname='Site')";

     }
	 else{
		 sqlstr2="delete from tblApprovalSignature where logID="+llogID +" and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site'))";
 		 sqlstr3="delete from tblLogSiteList where logID="+llogID+" and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site'))";
 		 sqlstr4="delete from tblOwnerSignature where logID="+llogID + " and areaID=(select areaid from tblArea where areaname='Site')";
	 }
	 
//	 alert(sqlstr);
	  makePOSTRequest("updateDB2.jsp","sql="+escape(sqlstr)+"&sql2="+escape(sqlstr2)+"&sql3="+escape(sqlstr3)+"&sql4="+escape(sqlstr4),handleAjaxResponse);
      if (bAjaxError)
	  {
			  alert(ajaxResponse);
			  ctrlObj.checked=false;
              if (isSiteControl==1)
          		document.getElementById("siteControlNo").checked=true;
              else
        		document.getElementById("siteControlYes").checked=true;
			  return;
		  }

 	 window.location.reload();
}
//deprecated
function  updateSiteControl(ctrlObj, isSiteControl){
	var warnmsg="You are going to change the request's level, proceed?";
if (bIsSiteControl==isSiteControl)
{
	return;
}
if (!confirm(warnmsg))
{
	//window.location.reload();
	ctrlObj.checked=false;
	if (isSiteControl==1)
		document.getElementById("siteControlNo").checked=true;
	else
		document.getElementById("siteControlYes").checked=true;
	return;
}
 //var llogID=document.getElementById("logID").value;
 var varAreaID=document.getElementById("areaID").value;
  var sqlstr="update tblChangeControlLog set take2Site="+isSiteControl +" where logID="+llogID + " and take2Site<>"+isSiteControl;
    // alert(sqlstr);
     var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr));
     
	 if (isSiteControl){
	  sqlstr="insert into tblApprovalSignature(logID, approverID,approverType,approverName,approverAccout,approverEmail,isChecked,rejected, byWho, checkDate, hasFollowup,followup,isFollowupChecked,followupByWho,followupCheckDate) ";
      sqlstr+="select "+llogID+", appr.ApproverID, appr.approverType,appr.approverName, approverAccout,approverEmail, 0,0, '', null,0,'',0,'',null from tblApprovers appr where (appr.hidden<>'Y' or appr.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
      sqlstr+="and (not exists (select logID, ApproverID from tblApprovalSignature where logID= "+llogID+" and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site')))) order by appr.sortorder";
      alert(sqlstr);
     }
	 else{
		 sqlstr="delete from tblApprovalSignature where logID="+llogID +" and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site'))";
	 }
	 
//	 alert(sqlstr);
	  makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr));
      

	 if (isSiteControl){
	  sqlstr="insert into tblLogSiteList(logID,approverID,listID, requiredString,isrequired, byWho,checkDate,comment,issubcat) ";
      sqlstr+="select "+llogID+",sitelist.approverID,sitelist.ID,sitelist.requiredString,0,'',null,'', sitelist.isSubCat from tblSiteList sitelist, tblApprovers appr where sitelist.approverID=appr.ApproverID and (sitelist.hidden<>'Y' or sitelist.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
      sqlstr+="and "+llogID+" not in (select logID from tblLogSiteList) order by sitelist.sortorder";
	 }
	 else{
		 sqlstr="delete from tblLogSiteList where logID="+llogID;
	 }
	// alert(sqlstr);
     ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr));
 	 
    if (isSiteControl){
	  sqlstr="insert into tblOwnerSignature(logID,areaID,approverName,approverAccount,isChecked,byWho,checkdate) ";
      sqlstr+="select "+llogID+",11,ChangeOwnerName,ChangeOwnerAccount,0,'',null from tblAreaOwners a where a.areaID=11";
	 }
	 else{
		 sqlstr="delete from tblOwnerSignature where logID="+llogID + " and areaID=11";
	 }
	// alert(sqlstr);
     ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr));
 	 setTimeout("window.location.reload()",1000);

}
//deprecated
function addFollowup(ctrl,key){

	var s = document.getElementById(ctrl).value;
	if (s.length > 1000)
		 s = s.substring(0,499);//500
    s = s.replace(/'/g,"''");

    var sqlstr = "update tblApprovalSignature set followup=? where id=" + key;
    
    $.ajax({
    	  url: "updateDB3.jsp",
    	  type: "POST",
    	  data: "sql=" + sqlstr + "&paramsNo=1&param1="+s,
    	  contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    	  context: document.body,
    	  success: function(){
    	    //$(this).addClass("done");
    		//  alert('success');
    	  }
    	});
    
    return;
    
    //alert(sqlstr);
//     var ret = makePOSTRequest("updateDB.jsp", "sql=" + (sqlstr), handleAjaxResponse);
//	 if (bAjaxError)
//	 {
//		 alert(ajaxResponse);
//		 return;
//	 }

}
var curFollowupWin=false;
function showFollowupWindow(commentWinCtrl, bShow){
	var  obj=document.getElementById(commentWinCtrl);
	if (bShow){
		 if (curFollowupWin)
    		 document.getElementById(curFollowupWin).style.display="none";
		 obj.style.display='';
		 curFollowupWin=commentWinCtrl;
	}
	else{
         obj.style.display='none';
		 curFollowupWin=false;
	}
}
function handleFollowup(ctrlId, followupWinCtrl, followupKey){
 var checkboxObj=document.getElementById(ctrlId);
 var bChecked=checkboxObj.checked?1:0;

	 //followupWindow.style.visibility="visible";
	 var sqlstr="";
	 if (bChecked)
        sqlstr="update tblApprovalSignature set hasFollowup="+bChecked+" where id="+followupKey;
	 else
        sqlstr="update tblApprovalSignature set hasFollowup="+bChecked+",isFollowupChecked=0,followupByWho='"+curLogin+"',followupCheckDate=getDate() where id="+followupKey;

    // alert(sqlstr);
     var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	 if (bAjaxError)
	 {
		 alert(ajaxResponse);
		 checkObj.checked=!bChecked;
		 return;
	 }
     showFollowupWindow(followupWinCtrl,bChecked==1);
	 if (bChecked){
		 document.getElementById("followupMarkPanel"+followupKey).innerHTML="<img align='top' onclick=\"showFollowupWindow('followupwindow"+followupKey+"',true);\" id='followupMark"+followupKey+"' name='followupMark"+followupKey+"' src='./images/comment.gif'>";
		 document.getElementById("followupSignatureBox"+followupKey).disabled=false;
		 document.getElementById("hasFollowupHidden"+followupKey).value="true";
	 }
	 else{
		  document.getElementById("followupMarkPanel"+followupKey).innerHTML="";
  		  document.getElementById("followupSignatureBox"+followupKey).checked=false;
		  document.getElementById("followupSignatureBox"+followupKey).disabled=true;
          document.getElementById("followupSignaturePanel"+followupKey).innerHTML="";
 		  document.getElementById("hasFollowupHidden"+followupKey).value="false";
	 }
}
function handle_lsl(ctrlId,keyId,approverID, parentListID,seq){
	
 var checkboxObj=document.getElementById(ctrlId);
 var bChecked=checkboxObj.checked?1:0;
	 //followupWindow.style.visibility="visible";
    var sqlstr="update tblLogSiteList set isRequired="+bChecked+", byWho='"+curLogin+"', checkDate=getDate() where id="+keyId;
//     alert(sqlstr);
//     var ret=makePOSTRequest("updateDB.jsp","sql="+encodeURI(sqlstr));
	var sqlstr2="update tblApprovalSignature set hasFollowup=(select case when count(*)>0 then 1 else 0 end  from tblLogSiteList lsl where lsl.logid="+llogID+" and lsl.approverid="+approverID+" and lsl.isRequired>0) where logid="+llogID+" and approverID="+approverID;
	//alert(sqlstr);
	makePOSTRequest("updateDB2.jsp","sql="+escape(sqlstr)+"&sql2="+escape(sqlstr2),handleAjaxResponse);
	if (bAjaxError)
	{
		alert(AjaxResponse);
		checkObj.checked=!bChecked;
		return;
	}
  	 document.getElementById("SiteListComment_"+parentListID+"_"+seq).style.visibility=bChecked?"visible":"hidden";

	 var listLenObj=document.getElementById("subItemCnt_"+parentListID);
	 var bHasAnyChecked=false;
	 if (listLenObj)
	 {
		 var listLen=parseInt(listLenObj.value);
	 	 for (var i=1;i<=listLen ;i++ ) {
			 var obj=document.getElementById("SiteControlLslBox_"+parentListID+"_"+i);
			 if (obj)
			     bHasAnyChecked=bHasAnyChecked || obj.checked;
			 if (bHasAnyChecked) break;
	    }
		if (bHasAnyChecked){
		  document.getElementById("followupCheckBoxImg"+parentListID).src="./images/checkbox_y.jpg";
   		  document.getElementById("hasFollowupHidden"+parentListID).value="true";
		}
		else{
		  document.getElementById("followupCheckBoxImg"+parentListID).src="./images/checkbox_n.jpg";
   		  document.getElementById("hasFollowupHidden"+parentListID).value="false";
		}
	 }

}

function handle_lsl_comment(ctrlId, keyID,approverID, parentListID,seq){
 var ctrlObj=document.getElementById(ctrlId);
 var aComm = ctrlObj.value;
 aComm = aComm.replace(/'/g,"''");
 var sqlstr = "";
 
 if (aComm.length > 0) {
     //sqlstr = "update tblLogSiteList set comment='" + aComm + "', byWho='" + curLogin + "',checkDate=getDate() where id=" + keyID;
	 sqlstr = "update tblLogSiteList set comment=?, byWho='" + curLogin + "',checkDate=getDate() where id=" + keyID;
     
 	 //document.getElementById("SiteControlLslBox_"+parentListID+"_"+seq).checked=true;
 }
 else{
     //sqlstr="update tblLogSiteList set comment='"+aComm+"', byWho='"+curLogin+"',checkDate=getDate() where id="+keyID;
	 sqlstr = "update tblLogSiteList set comment='?, byWho='" + curLogin + "',checkDate=getDate() where id=" + keyID;
  	// document.getElementById("SiteControlLslBox_"+parentListID+"_"+seq).checked=false;
 }
 
//  var sqlstr2="update tblApprovalSignature set hasFollowup=(select case when count(*)>0 then 1 else 0 end  from tblLogSiteList lsl where lsl.logid="+llogID+" and lsl.approverid="+approverID+" and lsl.isRequired>0) where logid="+llogID+" and approverID="+approverID;
   //  makePOSTRequest("updateDB2.jsp","sql="+encodeURI(sqlstr)+"&sql2="+encodeURI(sqlstr2),handleAjaxResponse);
    /*
 	makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
     if (bAjaxError)
     {
	     alert(ajaxResponse);
     	 return;
     }
     */
     $.ajax({
      	  url: "updateDB3.jsp",
      	  type: "POST",
      	  data: "sql=" + sqlstr + "&paramsNo=1&param1=" + aComm,
      	  contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      	  context: document.body,
      	  success: function(){
      	    //$(this).addClass("done");
      		//  alert('success');
      	  }
      	});
 
  /*{
     sqlstr="update tblLogSiteList set comment='"+aComm+"' where id="+keyID;
     var ret=makePOSTRequest("updateDB.jsp","sql="+encodeURI(sqlstr),handleAjaxResponse);
     if (bAjaxError)
     {
	 alert(ajaxResponse);
 	 return;
     }
}
*/

}
function sign(ctrlId, panelId, signKey){
 var checkboxObj = document.getElementById(ctrlId);
 var panelObj = document.getElementById(panelId);
 var bSign = checkboxObj.checked ? 1 : 0;

	var warnmsg="";
	if (bSign){
		warnmsg="You are going to approve this request. Ok to save and proceed?";
	}
	else{
		warnmsg="You are going to Un-sign this. Proceed?";
	}
	if (confirm(warnmsg) == false)
	{
		checkboxObj.checked = !bSign;
		return;
	}

mousePosX = getMouseX();
mousePosY = getMouseY();


          var  sqlstr = "update tblApprovalSignature set isChecked=" 
        	  + bSign + ",rejected=0,byWho='" 
        	  + curLogin + "',checkDate=getDate() where id=" + signKey;
          
          var ret = makePOSTRequest("updateDB.jsp", "sql=" + escape(sqlstr), handleAjaxResponse);
		  if (bAjaxError)
		  {
			  alert(ajaxResponse);
//	          checkboxObj.checked=!bSign;
			  return;
		  }

	      if (bSign > 0) {
             panelObj.innerHTML = curLoginSignature;
			 checkboxObj.disabled = true;
              document.getElementById("rejectBox" + signKey).checked = false;
			  document.getElementById("rejectBox" + signKey).disabled = true;
			  makePOSTRequest2("notifyOwnerAllApproved.jsp", "n=" + llogID);
			  if(isAllSigned()) {
				  changeStatusToApproved();
			  }
				  
		  }
	     else
             panelObj.innerHTML="";
	      
//	      alert('Done');
//	  	alert(bIsLogInProgress);
//	  	if(bSign && bIsLogInProgress) {
//	  		alert('here');
//	  		alert('isAllSigned ' + isAllSigned());
//	  		if(isAllSigned()) {
//	  			alert('change status to approved');
//	  		}
//	  	}
}

function reject(ctrlId, panelId, signKey){
 var checkboxObj=document.getElementById(ctrlId);
 var panelObj=document.getElementById(panelId);
 var bSign=checkboxObj.checked?1:0;

var warnmsg="";
if (bSign){
	warnmsg="You are going to reject this request. Ok to save and proceed?";
}
else{
	warnmsg="You are going to Un-sign this. Proceed?";
}
if (confirm(warnmsg)==false)
{
	checkboxObj.checked=!bSign;
	return;
}

          var sqlstr="update tblApprovalSignature set isChecked=0, rejected="+bSign+",byWho='"+curLogin+"',checkDate=getDate() where id="+signKey;
          var ret = makePOSTRequest("updateDB.jsp","sql=" + escape(sqlstr),handleAjaxResponse );
		  if (bAjaxError)
		  {
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
		  }
		  
		  changeStatusToRejected();
//	  	  var log = document.getElementById("logID").value;
         if (bSign>0)
         {
           makePOSTRequest('notifyOwner.jsp','n='+llogID,handleAjaxResponse);
		   if (bAjaxError)
		   {
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
		   }
		 }
      //    makePOSTRequest("notifyOwner.jsp","n="+log); //send owner an email
	      if (bSign>0){
             panelObj.innerHTML=curLoginSignature;
			 checkboxObj.disabled=true;
			 document.getElementById("signatureBox"+signKey).checked=false;
			 document.getElementById("signatureBox"+signKey).disabled=true;
		  }
	     else
             panelObj.innerHTML="";
// }
}

function signFollowup(ctrlId, panelId, signKey){
 var checkboxObj=document.getElementById(ctrlId);
 var panelObj=document.getElementById(panelId);
   var bSign=checkboxObj.checked?1:0;

	var warnmsg="";
	if (bSign) {
		warnmsg = "You are going to sign this followup. Ok to save and proceed?";
	}
	else{
		warnmsg = "You are going to Un-sign this followup. Proceed?";
	}
	if (confirm(warnmsg) == false)
	{
		checkboxObj.checked =! bSign;
		return;
	}
    
	var sqlstr="update tblApprovalSignature set isFollowupChecked="+bSign+",followupByWho='"+curLogin+"',followupCheckDate=getDate() where id="+signKey;
	var ret = makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	if (bAjaxError) {
		alert(ajaxResponse);
		checkboxObj.checked = !bSign;
		return;
	}
	
	if (bSign > 0) {
		panelObj.innerHTML=curLoginSignature;
		checkboxObj.disabled=true;
	}
	else
		panelObj.innerHTML=" ";
	
	if(bSign && isAllFollowupDone()) {
		makePOSTRequest2("notifyDirector.jsp", "n=" + llogID);
	}
}

function ownerSign(control,signaturePanel){
	var checkboxObj=document.getElementById(control);
	var panelObj=document.getElementById(signaturePanel);
	var keyID=checkboxObj.value;
	var bSign=checkboxObj.checked?1:0;
    var warnmsg="";
    
	if (bSign){
	  warnmsg="You are going to sign this request. Ok to save and proceed?";
    }
    else{
    	warnmsg="You are going to Un-sign this. Proceed?";
     }
if (confirm(warnmsg)==false)
{
	checkboxObj.checked=!bSign;
	return;
}
	 

    var sqlstr="update tblOwnerSignature set isChecked="+bSign+",byWho='"+curLogin+"',checkDate=getDate() where id="+keyID;
//	alert(sqlstr);
    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	 if (bAjaxError)
		  {
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
		  }
	if (bSign>0){
             panelObj.innerHTML=curLoginSignature;
			 checkboxObj.disabled=true;
		  }
	     else
             panelObj.innerHTML=" ";
}
function ownerAllSign(control,signaturePanel){

	var checkboxObj = document.getElementById(control);
	var panelObj = document.getElementById(signaturePanel);
	var keyID = checkboxObj.value;
	
	var statusList = document.getElementById("approvalStatus");
	
	var statusID = statusList.options[statusList.selectedIndex].value;
	var statusStr = statusList.options[statusList.selectedIndex].text;

	var bSign=checkboxObj.checked ? 1 : 0;
    var warnmsg="";
    var bAllSigned=true;

    if (bSign)   {
    	for (var i=0;i<signatureArray.length;i++ )	  {
		  bAllSigned=bAllSigned && document.getElementById(signatureArray[i]).checked;
	    }
	    for (var i=0;i<teamSignatureArray.length;i++ ) {
		  bAllSigned=bAllSigned && document.getElementById(teamSignatureArray[i]).checked;
	    }
        if (!bAllSigned){
		 alert("Cannot proceed because there are some items not approved/signed off yet.");
		 checkboxObj.checked = false;
		 return;
	    }
        
        if(statusStr != "Implemented") {
        	alert("Cannot proceed because this request status is not yet 'Implemented'.");
        	checkboxObj.checked = false;
        	return;
        }
	}


	if (bSign){
	  warnmsg = "You are going to sign this. Ok to save and proceed?";
    }
    else{
    	warnmsg="You are going to Un-sign this. Proceed?";
     }
   if (confirm(warnmsg) == false){
	checkboxObj.checked=!bSign;
	return;
   }

    var sqlstr="update tblOwnerAllSignature set isChecked=" + bSign + ",byWho='" + curLogin + "',checkDate=getDate() where id=" + keyID;
//	alert(sqlstr);
    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	if (bAjaxError)
	{
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
	 }
	if (bSign > 0) {
		panelObj.innerHTML=curLoginSignature;
		checkboxObj.disabled=true;
	}
	else
             panelObj.innerHTML=" ";
	
	if(bSign)
		changeStatusToComplete();
}

function safetySign(control,signaturePanel){

	var obj=document.getElementById(control);
	var panelObj=document.getElementById(signaturePanel);
	var keyID=obj.value;
	var bChecked=0;
	if (obj.checked){
		bChecked=1;
	}
	else{
		bChecked=0;
	}

    var sqlstr="update tblSafetyApproverSignature set isChecked="+bChecked+",byWho='"+curLogin+"',checkDate=getDate() where id="+keyID;
//	alert(sqlstr);
    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr));
	if (bChecked>0){
             panelObj.innerHTML=curLoginSignature;
		  }
	     else
             panelObj.innerHTML=" ";
}
function teamReview(control, reviewID){

	var checkboxObj=document.getElementById(control);
	var bSign=checkboxObj.checked?1:0;

	if (bSign){
	  warnmsg="You are going to approve this request. Ok to save and proceed?";
    }
    else{
    	warnmsg="You are going to Un-check this. Proceed?";
     }
   if (confirm(warnmsg)==false){
	checkboxObj.checked=!bSign;
	return;
   }
    var sqlstr="update tblTeamReview set checked="+bSign+",byWho='"+curLogin+"',checkDate=getDate() where id="+reviewID;
	if (bSign)
       sqlstr="update tblTeamReview set checked="+bSign+",rejected=0, byWho='"+curLogin+"',checkDate=getDate() where id="+reviewID;
	
    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	if (bAjaxError)
	{
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
	 }
	if (bSign){
	   checkboxObj.disabled=true;
	   document.getElementById("teamReject"+reviewID).checked=false;
	   document.getElementById("teamReject"+reviewID).disabled=true;
	}
}


function teamReject(control, reviewID){

	var checkboxObj=document.getElementById(control);
	var bSign=checkboxObj.checked?1:0;

	if (bSign){
	  warnmsg="You are going to reject this request. Ok to save and proceed?";
    }
    else{
    	warnmsg="You are going to Un-check this. Proceed?";
     }
   if (confirm(warnmsg)==false){
	checkboxObj.checked=false;
	return;
   }
    var sqlstr="update tblTeamReview set rejected="+bSign+",byWho='"+curLogin+"',checkDate=getDate() where id="+reviewID;
    if (bSign)
        sqlstr="update tblTeamReview set checked=0,rejected="+bSign+",byWho='"+curLogin+"',checkDate=getDate() where id="+reviewID;
    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
    if (bAjaxError)
	{
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
	 }
	makePOSTRequest("notifyOwner.jsp","n="+llogID,handleAjaxResponse );
	if (bAjaxError)
	{
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
	 }
	if (bSign){
	   checkboxObj.disabled=true;
   	   document.getElementById("teamCheck"+reviewID).checked=false;
   	   document.getElementById("teamCheck"+reviewID).disabled=true;
	}
}

function addComment(){

	var s =document.getElementById("txtComment");
	var d =document.getElementById("commentpanel");
	var log = document.getElementById("logID").value;
	var comm=s.value;
	comm=comm.replace(/'/g,"''");
	comm=comm.substring(0,1000);
    var sqlstr="insert into tblcomments (logID, byWho,comment,commentDate,deleted) values("+log+",'"+curLogin+"','"+comm+"',getDate(),0)";
 
    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	if (bAjaxError)
	{
			  alert(ajaxResponse);
			  return;
	 }
	d.innerHTML=d.innerHTML+comm+"<br/>";
}
 
function addStatusComment(){
	
	var s =document.getElementById("txtStatComment");
	var log = document.getElementById("logID").value;
	var comm=s.value;

	comm=comm.replace(/'/g,"''");
    var sqlstr="update tblChangeControlLog set statusComment='"+comm+"' where logid="+log;
//	alert(sqlstr);
    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	 if (bAjaxError)
	{
			  alert(ajaxResponse);
			  return;
	 }
}
function handle_edit_icon(ctrlID){
	if (!bAllowEdit)
	  return;

	var editColor="#FF0000";
	var saveColor="#000000";
   var obj=document.getElementById(ctrlID);
   if (obj.readOnly) {
      obj.readOnly=false;
      obj.style.color=editColor
      obj.focus();
   }
}
function handle_save_icon(ctrlID){
	if (!bAllowEdit)
	  return;

	var editColor="#FF0000";
	var saveColor="#000000";
   var obj=document.getElementById(ctrlID);
   if (!obj.readOnly)  {
      obj.readOnly=true;
      obj.style.color=saveColor;
   }
}
function save(ctrlID){
	if (!bAllowEdit)
	  return;

 var obj=document.getElementById(ctrlID);
 var sqlstr="";
 var content="";
 content=obj.value;
 content=content.replace(/'/g,"''");  //regular express replace
 
 if (ctrlID=="desc"){
	 if (content.length>1000) content=content.substring(0,1000);
     sqlstr="update tblChangeControlLog set changeDesc='"+content +"' where logID="+llogID;
 }
 else if (ctrlID=="reason"){
  	  if (content.length>1000) content=content.substring(0,1000);
	  sqlstr="update tblChangeControlLog set changeReason='"+content +"' where logID="+llogID;
 }
 else if (ctrlID="startTime"){
 	  sqlstr="update tblChangeControlLog set startTiming=convert(datetime,'"+content +"',101) where logID="+llogID;
 }
 else if (ctrlID="endTime"){
 	  sqlstr="update tblChangeControlLog set endTiming=convert(datetime,'"+content +"',101) where logID="+llogID;
 }
 else if (ctrlID="cost"){
	  if (isValidNumber(content))
    	  sqlstr="update tblChangeControlLog set cost="+content+", cost2='"+content +"' where logID="+llogID;
	  else {
		    alert("Invalid number");
		    return;
		   }
 }
 else if (ctrlID="costType"){
 	  sqlstr="update tblChangeControlLog set costType='"+content +"' where logID="+llogID;
 }

 var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
}
var bInEdit=false;

function handle_edit_all_gui(){
	if (!bAllowEdit || bInEdit)
	  return;
 handle_edit_icon("startTime");
 handle_edit_icon("endTime");
 handle_edit_icon("cost");
 handle_edit_icon("costType");
 handle_edit_icon("desc");
 handle_edit_icon("reason");

 document.getElementById("startTimePicker").style.visibility="visible";
 document.getElementById("endTimePicker").style.visibility="visible";

  document.getElementById("isSafetyPanel").style.color="#ff0000";
  document.getElementById("isEmergencyPanel").style.color="#ff0000";

  document.getElementById("ddl_safety_panel").style.display="inline-block";
  document.getElementById("ddl_emergency_panel").style.display="inline-block";

	
 bInEdit=true;
}
function handle_save_all_gui(){
	if (!bAllowEdit ||!bInEdit)
	  return;
 handle_save_icon("startTime");
 handle_save_icon("endTime");
 handle_save_icon("cost");
 handle_save_icon("costType");
 handle_save_icon("desc");
 handle_save_icon("reason");
 document.getElementById("startTimePicker").style.visibility="hidden";
 document.getElementById("endTimePicker").style.visibility="hidden";


 document.getElementById("isSafetyPanel").style.color="#000000";
 document.getElementById("isEmergencyPanel").style.color="#000000";

  document.getElementById("ddl_safety_panel").style.display="none";
  document.getElementById("ddl_emergency_panel").style.display="none";
 bInEdit=false;
}


function resetFields(){
  document.getElementById("startTime").value=document.getElementById("oldStartTime").value;
  document.getElementById("endTime").value=document.getElementById("oldEndTime").value;
  document.getElementById("cost").value=document.getElementById("oldCost").value;
  document.getElementById("costType").value=document.getElementById("oldCostType").value;
  document.getElementById("desc").value=document.getElementById("oldDesc").value;
  document.getElementById("reason").value=document.getElementById("oldReason").value;
  document.getElementById("isSafetyPanel").innerHTML=document.getElementById("oldIsSafety").value=="0"?"No":"Yes";
  document.getElementById("isEmergencyPanel").innerHTML=document.getElementById("oldIsEmergency").value=="0"?"No":"Yes";
}
function save_all(){
	if (!bAllowEdit||!bInEdit)
	  return true;
 var bOk=true;
 var warnmsg="You are going to save the changes. Ok to save and proceed?";
 var sql="";
 var bChanged=false;
 var oldValue="";
 var newValue="";


 var startTime_v=document.getElementById("startTime").value;
 var  oldStartTime_v=document.getElementById("oldStartTime").value;
 if(dateDiff("startTime","endTime")<=0){
	 alert("Check starttiming and endtiming plz.");
	 return false;
 }else if (dateDiff("startTime","endTime")>720)
 {
	 alert("Endtiming is way out.");
	 return false;
 }

 if (startTime_v!=oldStartTime_v) {
	 bChanged=true;
	 sql+="startTiming=convert(datetime,'"+startTime_v +"',101),";
	 oldValue+="startTime="+oldStartTime_v+",";
     newValue+="startTime="+startTime_v+",";
 }

 var endTime_v=document.getElementById("endTime").value;
 var oldEndTime_v=document.getElementById("oldEndTime").value;
 if (endTime_v!=oldEndTime_v) {
	 bChanged=true;
	 sql+="endTiming=convert(datetime,'"+endTime_v +"',101),";
 	 oldValue+="endTime="+oldEndTime_v+",";
 	 newValue+="endTime="+endTime_v+",";
 }


 var cost_v=document.getElementById("cost").value;
 if (!isValidNumber(cost_v)){
	 alert("Invalid number");
	 bOk=false;
 }
 var oldCost_v=document.getElementById("oldCost").value;
 if (cost_v!=oldCost_v){
	 bChanged=true;
	 sql+="cost="+cost_v+", cost2='"+cost_v+"',";
 	 oldValue+="cost="+oldCost_v+",";
 	 newValue+="cost="+cost_v+",";
 }

 var costType_v=document.getElementById("costType").value;
 var oldCostType_v=document.getElementById("oldCostType").value;
 if (costType_v!=oldCostType_v){
	 bChanged=true;
	 sql+="costType='"+costType_v +"',";
     oldValue+="costType="+oldCostType_v+",";
     newValue+="costType="+costType_v+",";
 }

 var desc_v=document.getElementById("desc").value;
 var oldDesc_v=document.getElementById("oldDesc").value;
 if (desc_v!=oldDesc_v){
	 desc_v=desc_v.replace(/'/g,"''");  //regular express replace
	 bChanged=true;
	 sql+="changeDesc='"+desc_v +"',";
	 oldValue+="desc="+oldDesc_v+",";
	 newValue+="desc="+desc_v+",";
 }

 var reason_v=document.getElementById("reason").value;
 var oldReason_v=document.getElementById("oldReason").value;
 if (reason_v!=oldReason_v){
     reason_v=reason_v.replace(/'/g,"''");  //regular express replace
	 bChanged=true;
	 sql+="changeReason='"+reason_v +"',";
 	 oldValue+="reason="+oldDesc_v+",";
 	 newValue+="reason="+reason_v+",";
 }

 var ddl_obj=document.getElementById("ddl_safety");
 var bSafety=ddl_obj.options[ddl_obj.selectedIndex].value=='1'?'1':'0';
 var oldbSafety=document.getElementById("oldIsSafety").value;
 if (bSafety!=oldbSafety){
	 bChanged=true;
	 sql+="IsSafety="+bSafety +",";
 	 oldValue+="IsSafety="+oldbSafety+",";
 	 newValue+="IsSafety="+bSafety+",";
 }

 ddl_obj=document.getElementById("ddl_emergency");
 var bEmergency=ddl_obj.options[ddl_obj.selectedIndex].value=='1'?'1':'0';
 var oldbEmergency=document.getElementById("oldIsEmergency").value;
 if (bEmergency!=oldbEmergency){
	 bChanged=true;
	 sql+="IsEmergency="+bEmergency +",";
  	 oldValue+="IsEmergency="+oldbEmergency+",";
  	 newValue+="IsEmergency="+bEmergency+",";
 }

 var sqlstr="";

 if (bChanged && bOk) {
	 sql=sql.substring(0,sql.length-1);
	 oldValue=oldValue.substring(0,oldValue.length-1);

	 sqlstr="update tblChangeControlLog set "+sql+" where logID="+llogID;

     if (confirm(warnmsg)){
        makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
        if (bAjaxError){
			  alert(ajaxResponse);
			  bOk=false;
	    }
		else{
			makePOSTRequest("notifyOwnerUpdateLog.jsp","n="+llogID+"&oldValue="+escape(oldValue)+"&newValue="+escape(newValue),handleAjaxResponse);
			if (bAjaxError){
			  alert(ajaxResponse);
	        }
		}
		window.location.reload();
	 }
	 else {
		 resetFields();
		 //this is no need because of resetFields()
        // alert("Refresh the page to recover the orignal values if any changes have been made."); 
	 }
 }
 return bOk;
}


function save_all_old(){
	if (!bAllowEdit||!bInEdit)
	  return true;
 var bOk=true;
 var warnmsg="You are going to save the changes. Ok to save and proceed?";

 var startTime_v=document.getElementById("startTime").value;
 var  oldStartTime_v=document.getElementById("oldStartTime").value;

 var endTime_v=document.getElementById("endTime").value;
 var oldEndTime_v=document.getElementById("oldEndTime").value;

 var cost_v=document.getElementById("cost").value;
 if (!isValidNumber(cost_v)){
	 alert("Invalid number");
	 bOk=false;
 }
 var oldCost_v=document.getElementById("oldCost").value;

 var costType_v=document.getElementById("costType").value;
 var oldCostType_v=document.getElementById("oldCostType").value;

 var desc_v=document.getElementById("desc").value;
 var oldDesc_v=document.getElementById("oldDesc").value;

 desc_v=desc_v.replace(/'/g,"''");  //regular express replace

 var reason_v=document.getElementById("reason").value;
 var oldReason_v=document.getElementById("oldReason").value;
 reason_v=reason_v.replace(/'/g,"''");  //regular express replace

 var ddl_obj=document.getElementById("ddl_safety");
 var bSafety=ddl_obj.options[ddl_obj.selectedIndex].value=='1'?1:0;
 var oldbSafety=document.getElementById("oldIsSafety");

 ddl_obj=document.getElementById("ddl_emergency");
 var bEmergency=ddl_obj.options[ddl_obj.selectedIndex].value=='1'?1:0;
 var oldbEmergency=document.getElementById("oldbEmergency");

 var sqlstr="";
 var sqlstr="update tblChangeControlLog set startTiming=convert(datetime,'"+startTime_v +"',101),";
 sqlstr+="endTiming=convert(datetime,'"+endTime_v +"',101),";
 sqlstr+="cost2='"+cost_v+"',costType='"+costType_v +"',";
 sqlstr+="changeDesc='"+desc_v+"', changeReason='"+reason_v+"',";
 sqlstr+="IsSafety="+bSafety+",IsEmergency="+bEmergency;
 sqlstr+=" where logID="+llogID;


 if (bOk){
    if (confirm(warnmsg))
        makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
	else 
		alert("Refresh the page to recover the orignal values if any changes have been made.");

 }
 if (bAjaxError)
	{
			  alert(ajaxResponse);
			  bOk=false;
	 }
 return bOk;
}

function isValidNumber(x) {
 var theNumber=x;

if (theNumber=="") theNumber="0";
return /^[-+]?\d+(\.\d+)?$/.test(theNumber);
}

function handle_unload(){
	 if (bInEdit)
	 {
		 var warnMsg="Save your changes?";
		 if ( confirm(warnMsg)){
			 save_all();
             handle_save_all_gui();
		 }
	 }

}
function deleteAttachment(attID,attPanel){
	var warnmsg="You are going to delete this attachment, proceed?";
	if (bAllowEdit){
        if (confirm(warnmsg)){
			var sqlstr= "update tblAttachments set hidden='Y' where id="+attID;
            makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
            if (bAjaxError){
			  alert(ajaxResponse);
			}
	        else{
             alert("deleted!");
	      	 document.getElementById(attPanel).style.display="none";
			}
		}
	}
}
function updateTeamComment(cnt){
	var newComment=document.getElementById("teamComment"+cnt).value;
	newComment=newComment.replace(/'/g,"''");
	newComment=newComment.substring(0,1000);
	var commentID=document.getElementById("commentID"+cnt).value;
	var sqlstr="update tblComments set comment='"+newComment+"' where id="+commentID;
    makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
        if (bAjaxError){
			  alert(ajaxResponse);
			  return;
		}
		else
           document.getElementById("teamComment"+cnt).style.border="0";
}
function deleteTeamComment(cnt){
	var warnmsg="You are going delete this follow-up, proceed?";
	if (confirm(warnmsg))
	{
		var commentID=document.getElementById("commentID"+cnt).value;
		var sqlstr="update tblComments set deleted=1 where id="+commentID;
        makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
        if (bAjaxError){
			  alert(ajaxResponse);
			  return;
		}
		else
		  document.getElementById("commRow"+cnt).style.display="none";
	}
}
function LTR_approve(seq){
	var checkboxObj=document.getElementById("LTRApprove"+seq);
	var LTRKey=document.getElementById("LTRId"+seq).value;
	var bSign=checkboxObj.checked;

	var warnmsg=bSign?"You are going to approve this request, proceed?":"You are going to Un-check this, proceed?";
     
    if(confirm(warnmsg)){
		var sqlstr="update tblLineTeamReview set approved='"+(bSign?"Y":"N")+"',rejected='N',byWho='"+curLogin+"',approvalTime=getDate() where id="+LTRKey;
		var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
		if (bAjaxError){
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
		 }else{
			if (bSign){
			  	  document.getElementById("LTRReject"+seq).checked=false;
				  checkboxObj.disabled=true;
				  document.getElementById("LTRReject"+seq).disabled=true;
				  makePOSTRequest2("notifyOwnerAllApproved.jsp","n="+llogID);
			}

		 }
	}
	else{
		checkboxObj.checked=!bSign;
	}

}
function LTR_reject(seq){
	var checkboxObj=document.getElementById("LTRReject"+seq);
	var LTRKey=document.getElementById("LTRId"+seq).value;
	var bSign=checkboxObj.checked;

	var warnmsg=bSign?"You are going to reject this request, proceed?":"You are going to Un-check this, proceed?";
     
    if(confirm(warnmsg)){
		var sqlstr="update tblLineTeamReview set rejected='"+(bSign?"Y":"N")+"',approved='N',byWho='"+curLogin+"',approvalTime=getDate() where id="+LTRKey;
		var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
		if (bAjaxError){
			  alert(ajaxResponse);
	          checkboxObj.checked=!bSign;
			  return;
		 }else{
			if (bSign){
				  document.getElementById("LTRApprove"+seq).checked=false;
				  checkboxObj.disabled=true;
 				  document.getElementById("LTRApprove"+seq).disabled=true;
				//  makePOSTRequest2("notifyOwnerAllApproved.jsp","n="+llogID);
		           makePOSTRequest2('notifyOwner.jsp','n='+llogID);

			}

		 }
	}
	else{
		checkboxObj.checked=!bSign;
	}

}

function saveLTComment(seq){
	
	var LTCommentKey = document.getElementById("LTCommentId" + seq).value;
	var txtComment = document.getElementById("LTComment" + seq).value;
	var log = document.getElementById("logID").value;
	txtComment = txtComment.replace(/'/g, "''");
	txtComment = txtComment.substring(0, 1000);

	var sqlstr="";
	if(txtComment.length>0){
		if(LTCommentKey.length<=0)
			sqlstr="insert into tblcomments (logID, byWho,comment,commentDate,deleted) values("+log+",'"+curLogin+"','"+txtComment+"',getDate(),0)";
		else
			sqlstr="update tblcomments set comment='"+txtComment+"',commentDate=getDate() where id="+LTCommentKey;

 
	    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
		if (bAjaxError)	{
			  alert(ajaxResponse);
			  return;
		 }
	}
		document.getElementById("yposition").value=document.body.scrollTop;
		document.the_form.submit();
}
function saveLTResponse(seq){
	var LTCommentKey =document.getElementById("LTCommentId"+seq).value;
	var txtComment=document.getElementById("LTResponse"+seq).value;
	var log = document.getElementById("logID").value;
	
	txtComment=txtComment.replace(/'/g,"''");
	txtComment=txtComment.substring(0,1000);


	var sqlstr="";
	if(txtComment.length>0){
		sqlstr="update tblcomments set response='"+txtComment+"',responseDate=getDate() where id="+LTCommentKey;
	    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
		if (bAjaxError)	{
			  alert(ajaxResponse);
			  return;
		 }
	}
		document.getElementById("yposition").value=document.body.scrollTop;
		document.the_form.submit();
}

function deleteLTComment(seq){
	var LTCommentKey =document.getElementById("LTCommentId"+seq).value;
	var warnMsg ="This comment will be deleted, proceed?";
	if(confirm(warnMsg)){
		var sqlstr="update tblcomments set deleted=1 where id="+LTCommentKey;
	    var ret=makePOSTRequest("updateDB.jsp","sql="+escape(sqlstr),handleAjaxResponse);
		if (bAjaxError){
			  alert(ajaxResponse);
			  return;
		 }
	// 	document.the_form.submit();
	    document.getElementById("TLCommentRow"+seq).style.display="none";
	}

}
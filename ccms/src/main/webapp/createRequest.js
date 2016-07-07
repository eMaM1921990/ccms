function init() {

	var listObj = document.getElementById("areaList");
	var listHidden = document.getElementById("area");
	var hiddenValue = "," + listHidden.value + ",";

	var i = 0;

	for (i = 0; i < areaArray.length; i++) { // populate the area list
		var newOption = document.createElement("option");
		newOption.value = areaArray[i].id;
		newOption.text = areaArray[i].name;
		if (areaArray[i].name == "Site")
			continue;
		listObj.options.add(newOption);
		if (hiddenValue.indexOf("," + newOption.value + ",") > -1)
			listObj.options[listObj.options.length - 1].selected = true;
	}
	doChange('areaList', 'lineList', areaArray, lineArray); // populate the line
	// list
	// added Dec 1. 2008 to reduce the equipment list

	doChange('areaList', 'equipmentList', areaArray, equipmentArray);

	listObj = document.getElementById("lineList");
	listHidden = document.getElementById("line");
	hiddenValue = "," + listHidden.value + ",";

	for (i = 0; i < listObj.options.length; i++)
		if (hiddenValue.indexOf("," + listObj.options[i].value + ",") > -1)
			listObj.options[i].selected = true;

	listObj = document.getElementById("equipmentList");
	listHidden = document.getElementById("equipment");
	hiddenValue = listHidden.value;
	/*
	 * for (i=0;i<equipmentArray.length;i++){ //populate the equipment list var
	 * newOption = document.createElement("option");
	 * newOption.value=equipmentArray[i].id;
	 * newOption.text=equipmentArray[i].name; listObj.options.add(newOption); if
	 * (hiddenValue==newOption.value)
	 * listObj.options[listObj.options.length-1].selected=true; }
	 */

	for (i = 0; i < listObj.options.length; i++) { // populate the equipment
		// list
		if (hiddenValue == listObj.options[i].value)
			listObj.options[i].selected = true;
	}

	checkEquipment();

}
function inList(aListObj, id) {
	var retVal = false;
	for (var i = 0; i < aListObj.options.length; i++) {
		if (aListObj.options[i].value == id) {
			retVal = true;
			break;
		}
	}
	return retVal;
}
// updated due to modifyRequest.jsp
//
function doChange_old(curList, dependentList, curArray, dependentArray) {
	// alert("doChange"+curList+" "+dependentList);
	var curObj = document.getElementById(curList);
	var dObj = document.getElementById(dependentList);
	var i;

	for (i = dObj.options.length; i >= 0; i--) {
		dObj.options[i] = null;
	}
	var cnt = 0;

	for (i = 0; i < curObj.options.length; i++) {
		if (curObj.options[i].selected == true) {
			var key = curObj.options[i].value;
			var j;
			for (j = 0; j < dependentArray.length; j++) {
				// if (dependentArray[j].parentID==key){
				var strParentIDs = "," + dependentArray[j].parentID + ",";
				var strKey = "," + key + ",";
				if (strParentIDs.indexOf(strKey) > -1
						&& !inList(dObj, dependentArray[j].id)) {
					var newOption = document.createElement('option');
					newOption.value = dependentArray[j].id;
					newOption.text = dependentArray[j].name;
					dObj.options.add(newOption);
				}
			}
		}

	}

}
//
function doChange(curList, dependentList, curArray, dependentArray, hiddenCtrl) {
	// alert("doChange"+curList+" "+dependentList);
	var curObj = document.getElementById(curList);
	var dObj = document.getElementById(dependentList);

	var i;

	for (i = dObj.options.length; i >= 0; i--) {
		dObj.options[i] = null;
	}
	var cnt = 0;

	for (i = 0; i < curObj.options.length; i++) {
		if (curObj.options[i].selected == true) {
			var key = curObj.options[i].value;
			var j;
			for (j = 0; j < dependentArray.length; j++) {
				// if (dependentArray[j].parentID==key){
				var strParentIDs = "," + dependentArray[j].parentID + ",";
				var strKey = "," + key + ",";
				if (strParentIDs.indexOf(strKey) > -1
						&& !inList(dObj, dependentArray[j].id)) {
					var newOption = document.createElement('option');
					newOption.value = dependentArray[j].id;
					newOption.text = dependentArray[j].name;
					dObj.options.add(newOption);
				}
			}
		}

	}
	if (hiddenCtrl) // added for modifyRequest.jsp
	{
		var hiddenObj = document.getElementById(hiddenCtrl);

		for (i = 0; i < dObj.options.length; i++) {
			var val = dObj.options[i].value;
			if (("," + hiddenObj.value + ",").indexOf("," + val + ",") > -1) {
				dObj.options[i].selected = true;
			}
		}
	}

}
//

function isValidNumber(ctl) {
	var obj = document.getElementById(ctl);
	var theNumber = obj.value;

	if (theNumber == "")
		theNumber = "0";
	return /^[-+]?\d+(\.\d+)?$/.test(theNumber);
}
function handle_list_multiple(objId) {
	var obj = document.getElementById(objId);
	if (obj) {
		var listSize = obj.options.length;
		var choosed = false;
		if (listSize > 0) {
			for (var i = 0; i < listSize; i++) {
				if (obj.options[i].selected) {
					choosed = true;
					break;
				}
			}

			if (choosed)
				return true;
			else
				return false;
		}
	}
	return false;
}
function handle_list_single(objId) {
	var obj = document.getElementById(objId);
	if (obj) {
		var listSize = obj.options.length;
		if (listSize > 0) {
			var sel = obj.selectedIndex;
			if (sel > 0)
				return true;
			else
				return false;
		}
	}
	return false;
}
function handle_radio(objName) {
	var objs = document.getElementsByName(objName);
	var ret = false;
	if (objs) {
		for (var i = 0; i < objs.length; i++) {
			if (objs[i].checked) {
				ret = true;
				break;
			}
		}
	} else
		ret = true;
	return ret;
}

function handle_radio_val(objName) {

	var objs = document.getElementsByName(objName);
	var ret = false;
	if (objs) {
		for (var i = 0; i < objs.length; i++) {
			if (objs[i].checked) {
				ret = objs[i].value;
				break;
			}
		}
	} 

	return ret;

}
function handle_text(objId) {
	var obj = document.getElementById(objId);
	if (obj.value == "") {
		return false;
	}
	return true;
}
function doSubmit(btn) {
	if (!handle_list_single("typeOfRequest")) {
		alert("Select the type of request please.");
		return false;
	}

	if (!handle_radio("q1")) {
		alert("Please answer Q1");
		
		return false;
	}

	
	

	if (!handle_radio("q2")) {
		alert("Please answer Q2");
		return false;
	}



	if (!handle_radio("q3")) {
		alert("Please answer Q3");
		return false;
	}

	

	if (!handle_radio("q4")) {
		alert("Please answer Q4");
		return false;
	}

	

	if (!handle_radio("q5")) {
		alert("Please answer Q5");
		return false;
	}

	

	if (!handle_radio("q6")) {
		alert("Please answer Q6");
		return false;
	}

	
	if (!handle_radio("q7")) {
		alert("Please answer Q7");
		return false;
	}

	

	if (!handle_radio("q8")) {
		alert("Please answer Q8");
		return false;
	}

	

	if (!handle_radio("q9")) {
		alert("Please answer Q9");
		return false;
	}

	

	if (!handle_radio("q10")) {
		alert("Please answer Q10");
		return false;
	}

	

	if (!handle_radio("q11")) {
		alert("Please answer Q11");
		return false;
	}

	
	if (!handle_radio("q12")) {
		alert("Please answer Q12");
		return false;
	}

	

	if (!handle_radio("q13")) {
		alert("Please answer Q13");
		return false;
	}
	
	if (!handle_radio("q14")) {
		alert("Please answer Q14");
		return false;
	}



	if (!handle_text("phone")) {
		alert("Enter phone number please.");
		return false;
	}
	if (!handle_list_multiple("areaList")) {
		alert("Select the department(s) please.");
		return false;
	}
	if (!handle_list_multiple("lineList")) {
		alert("Select the line(s) please.");
		return false;
	}
	if (!handle_list_single("equipmentList")) {
		alert("Select the equipment please.");
		return false;
	}
	if (!handle_radio("reappGrp")) {
		alert("Re-App is not selected.");
		return false;
	}
	if (!handle_text("sdate")) {
		alert("Select the start timing please.");
		return false;
	}
	if (!handle_text("edate")) {
		alert("Select the end timing please.");
		return false;
	}
	if (dateDiff("sdate", "edate") > 720) {
		alert("the endtiming is way out.");
		return false;
	}
	if (dateDiff("sdate", "edate") <= 0) {
		alert("check starttiming and endtiming plz.");
		return false;
	}
	// if ( ! handle_list_single("type")) {
	// alert("Select the cost type please.");
	// return false;
	// }
	if (!handle_text("description")) {
		alert("Enter the description please.");
		return false;
	}
	if (!handle_text("reason")) {
		alert("Enter the reason please.");
		return false;
	}

	populateHidden();

	btn.value = "submitting...";
	document.getElementById("pageAction").value = "submit";
	btn.disabled = true;
	document.the_form.submit();

	return true;

}

function updateSiteControl(isSiteControl) {
	var sqlstr = "update tblChangeControlLog set take2Site=" + isSiteControl
			+ " where logID=" + llogID + " and take2Site<>" + isSiteControl;
	var sqlstr2 = "";
	var sqlstr3 = "";
	var sqlstr4 = "";

	// alert(sqlstr);
	// var ret=makePOSTRequest("updateDB.jsp","sql="+encodeURI(sqlstr));

	if (isSiteControl) {
		sqlstr2 = "insert into tblApprovalSignature(logID, approverID,approverType,approverName,approverAccout,approverEmail,isChecked,rejected, byWho, checkDate, hasFollowup,followup,isFollowupChecked,followupByWho,followupCheckDate) ";
		sqlstr2 += "select "
				+ llogID
				+ ", appr.ApproverID, appr.approverType,appr.approverName, approverAccout,approverEmail, 0,0, '', null,0,'',0,'',null from tblApprovers appr where (appr.hidden<>'Y' or appr.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
		sqlstr2 += "and (not exists (select logID, ApproverID from tblApprovalSignature where logID= "
				+ llogID
				+ " and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site')))) order by appr.sortorder";

		sqlstr3 = "insert into tblLogSiteList(logID,approverID,listID, requiredString,isrequired, byWho,checkDate,comment,issubcat) ";
		sqlstr3 += "select "
				+ llogID
				+ ",sitelist.approverID,sitelist.ID,sitelist.requiredString,0,'',null,'', sitelist.isSubCat from tblSiteList sitelist, tblApprovers appr where sitelist.approverID=appr.ApproverID and (sitelist.hidden<>'Y' or sitelist.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
		sqlstr3 += "and sitelist.approverID not in (select approverID from tblLogSiteList where logID="
				+ llogID + ") order by sitelist.approverID, sitelist.sortorder";

		sqlstr4 = "insert into tblOwnerSignature(logID,areaID,approverName,approverAccount,approverEmail,isChecked,byWho,checkdate) ";
		sqlstr4 += "select "
				+ llogID
				+ ",areaid,ChangeOwnerName,ChangeOwnerAccount,ChangeOwnerEmail,0,'',null from tblAreaOwners a where a.areaID=(select areaid from tblArea where areaname='Site')";

	} else {
		sqlstr2 = "delete from tblApprovalSignature where logID="
				+ llogID
				+ " and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site'))";
		sqlstr3 = "delete from tblLogSiteList where logID="
				+ llogID
				+ " and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site'))";
		sqlstr4 = "delete from tblOwnerSignature where logID="
				+ llogID
				+ " and areaID=(select areaid from tblArea where areaname='Site')";
	}

	// alert(sqlstr);
	makePOSTRequest("updateDB2.jsp", "sql=" + escape(sqlstr) + "&sql2="
			+ escape(sqlstr2) + "&sql3=" + escape(sqlstr3) + "&sql4="
			+ escape(sqlstr4), handleAjaxResponse);
	// if (bAjaxError)
	// {
	// alert(ajaxResponse);
	// ctrlObj.checked=false;
	// if (isSiteControl==1)
	// document.getElementById("siteControlNo").checked=true;
	// else
	// document.getElementById("siteControlYes").checked=true;
	// return;
	// }
}

function populateHidden() {
	var objList = document.getElementById("areaList");
	var objHidden = document.getElementById("area");
	var objHiddenName = document.getElementById("areaName");

	var i;
	objHidden.value = "";
	objHiddenName.value = "";

	for (i = 0; i < objList.options.length; i++)
		if (objList.options[i].selected == true) {
			objHidden.value += "," + objList.options[i].value;
			objHiddenName.value += "," + objList.options[i].text;
		}
	objHidden.value = objHidden.value.substring(1);
	objHiddenName.value = objHiddenName.value.substring(1);

	objList = document.getElementById("lineList");
	objHidden = document.getElementById("line");
	objHiddenName = document.getElementById("lineName");
	objHidden.value = "";
	objHiddenName.value = "";

	for (i = 0; i < objList.options.length; i++)
		if (objList.options[i].selected == true) {
			objHidden.value += "," + objList.options[i].value;
			objHiddenName.value += "," + objList.options[i].text;
		}
	objHidden.value = objHidden.value.substring(1);
	objHiddenName.value = objHiddenName.value.substring(1);

	objList = document.getElementById("equipmentList");
	objHidden = document.getElementById("equipment");
	for (i = 0; i < objList.options.length; i++) {
		if (objList.options[i].selected == true) {
			objHidden.value = objList.options[i].value;
			break;
		}
	}
	return true;

}

function checkEquipment() {

	var obj = document.getElementById("equipmentList");
	var listSize = obj.options.length;
	if (listSize > 0) {
		var selIndex = obj.selectedIndex;
		if (selIndex > -1) {
			var sel = obj.options[obj.selectedIndex].text;
			if (sel == 'Others')
				document.getElementById("id1").style.visibility = "visible";
			else
				document.getElementById("id1").style.visibility = "hidden";
		}
	}
}
function checkReapp() {

	var obj = document.getElementsByName("reappGrp");

	for (var i = 0; i < obj.length; i++) {
		if (obj[i].checked)
			document.getElementById("reapp").value = obj[i].value
	}

	if (document.getElementById("reapp").value == 'Y')
		document.getElementById("id2").style.visibility = "visible";
	else
		document.getElementById("id2").style.visibility = "hidden";
}

function handle_keyup(ctrl, size, warning) {

	var v = ctrl.value;
	var len = v.length;

	if (len > size) {
		alert(warning);
		ctrl.value = v.substring(0, size);
		return false;
	}

	return true;
}

function handleQuestionAns(id, val) {

	if (val === "Y") {

		document.getElementById(id + "_ans").removeAttribute("style");
	} else {
		document.getElementById(id + "_ans").setAttribute("style",
				"display:none");

	}

}

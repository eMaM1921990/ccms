<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page import="com.pg.ccms.utils.DelegateHelper"%>
<%@page contentType="text/html; charset=ISO-8859-6"%>
<%@ page pageEncoding="ISO-8859-6"%>
<%@page import="java.util.Vector"%>
<%@ include file="inc.jsp"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.io.*"%>

<%
	Connection c = null;
	Statement st = null;
	ResultSet rs = null;
	Statement st2 = null;
	ResultSet rs2 = null;
	Statement st3 = null;
	ResultSet rs3 = null;
	String sql = "";

	String strArea = "";
	String[] strAreaArray = null;
	String strAreaID = "";
	String[] strAreaIDArray = null;
	String strLine = "";
	String[] strLineArray = null;
	String strLineID = "";
	String[] strLineIDArray = null;
	String strCreator = "";
	String strCreatorEmail = "";
	String strCreatorPhone = "";

	String strEquipment = "";
	String strOtherEquipment = "";
	String strOriginator = "";
	String strCreatorTeam = "";
	boolean bIsSafety = false;
	boolean bIsEmergency = false;
	boolean bIsReApp = false;
	String strReApp = "";
	String strStartDate = "";
	String strEndDate = "";
	String strCostType = "";
	String strCost = "";
	String strDesc = "";
	String strReason = "";
	String strComment = "";
	String strOwnerName = "";
	String strOwnerAcct = "";
	String[] strOwnerAcctArray = null;
	String strApprovalStatus = "";
	int iApprovalStatusID = -1;
	String strStatusComment = "";
	int notified = 0;
	String strApprovedBy = "";
	String strApprovedDate = "";
	String strCreationDate = "";

	String q1_selection = "";
	String q1_answer = "";

	String q2_selection = "";
	String q2_answer = "";

	String q3_selection = "";
	String q3_answer = "";

	String q4_selection = "";
	String q4_answer = "";

	String q5_selection = "";
	String q5_answer = "";

	String q6_selection = "";
	String q6_answer = "";

	String q7_selection = "";
	String q7_answer = "";

	String q8_selection = "";
	String q8_answer = "";

	String q9_selection = "";
	String q9_answer = "";

	String q10_selection = "";
	String q10_answer = "";

	String q11_selection = "";
	String q11_answer = "";

	String q12_selection = "";
	String q12_answer = "";

	String q13_selection = "";
	String q13_answer = "";
	
	//  Changes by emam 01000292810
	String q14_selection = "";
	String q14_answer = "";

	String tor_selection = "";

	String strIsSafety = "";
	String strIsEmergency = "";

	boolean bIsSiteControl = false;
	boolean bIsSiteOnly = false;
	boolean bLogContainSite = false;

	String strApproverTeamIds = "";

	boolean bIsLoginLogOwner = false;//not incorporated yet
	boolean bIsLoginLogApprover = false;

	boolean bIsCreator = false;
	boolean bAllowEdit = false;

	Vector signatureArray = new Vector();
	Vector hasFollowupArray = new Vector();
	Vector followupSignatureArray = new Vector();
	Vector teamSignatureArray = new Vector();
	//added for lineteam review jul 27 2010
	Vector lineTeamSignatureArray = new Vector();

	String strImagePath = application.getRealPath("/") + "images\\";

	String strCollapse = request.getParameter("collapse") == null
			? "default"
			: request.getParameter("collapse");
	String yPosition = request.getParameter("yposition") == null
			? "0"
			: request.getParameter("yposition");

	String strCurLoginSignatureImagePath = strImagePath
			+ "Signatures\\" + strCurLogin + ".jpg";
	File f = new File(strCurLoginSignatureImagePath);
	boolean bFileExist = f.exists();
	String strSignatureImg = bFileExist
			? "<img class='signature' src='./images/Signatures/"
					+ strCurLogin + ".jpg' alt='" + strCurLogin + "'>"
			: strCurLogin;
	boolean bIsLogHidden = false;

	String strLog = "";
	String strAction = "";
	boolean bShowNextButton = false;
	boolean bShowPrevButton = false;
	String strNextButtonEnabled = "disabled";
	String strPrevButtonEnabled = "disabled";
	boolean bShowLabel = true;

	try {
		c = DBHelper.getConnection();
		st = c.createStatement();
		SimpleDateFormat dateFmt = new SimpleDateFormat("MM/dd/yyyy");
		SimpleDateFormat datetimeFmt = new SimpleDateFormat(
				"MM/dd/yyyy HH:mm:ss");
		strAction = request.getParameter("pageAction") == null
				? strAction
				: request.getParameter("pageAction");
		strAction = request.getParameter("pageAction") == null
				? strAction
				: request.getParameter("pageAction");

		if (strAction.equals("next") || strAction.equals("prev")) {
			String strRefID = request.getParameter("logID") == null
					? ""
					: request.getParameter("logID");
			if (strRefID.equals(""))
				throw new Exception("Reference ID can not be null");

			if (strAction.equals("next")) {
				sql = "select logID  from tblApprovalSignature where CHARINDEX(';"
						+ strCurLogin
						+ ";' , ';'+approverAccout+';')>0 and logID>"
						+ strRefID
						+ " and isChecked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

				sql += " union select logID from tblLineTeamReview where CHARINDEX(';"
						+ strCurLogin
						+ ";' , ';'+acct+';')>0 and logID>"
						+ strRefID
						+ " and (approved is null or approved<>'Y') and (rejected is null or rejected<>'Y') and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

				sql += " union select logID from tblTeamReview TR where CHARINDEX(';"
						+ strCurLogin
						+ ";' , ';'+reviewer+';')>0 and logID>"
						+ strRefID
						+ " and   checked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

				sql = "select min(logID) newLogID from (" + sql + ") X";
			}

			else {
				sql = "select logID from tblApprovalSignature where CHARINDEX(';"
						+ strCurLogin
						+ ";' , ';'+approverAccout+';')>0 and logID<"
						+ strRefID
						+ " and isChecked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

				sql += " union select logID from tblLineTeamReview where CHARINDEX(';"
						+ strCurLogin
						+ ";' , ';'+acct+';')>0 and logID<"
						+ strRefID
						+ " and (approved is null or approved<>'Y') and (rejected is null or rejected<>'Y') and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";
				sql += " union select logID from tblTeamReview TR where CHARINDEX(';"
						+ strCurLogin
						+ ";' , ';'+reviewer+';')>0 and logID<"
						+ strRefID
						+ " and   checked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

				sql = "select max(logID) newLogID from (" + sql + ") X";
			}

			rs = st.executeQuery(sql);
			if (rs.next()) {
				strLog = rs.getString("newLogID") == null ? "" : rs
						.getInt("newLogID") + "";
			}
		} else
			strLog = request.getParameter("n") == null ? "" : request
					.getParameter("n"); //the logId is required. which is n 

		if (strLog.equals("")) {
			out.println("The requested log #" + strLog
					+ " is not available.");
			return;
		}

		strLog = strLog.trim();

		try {
			int intLogNum = Integer.parseInt(strLog);
		} catch (Exception ie) {
			out.println("Wrong format of parameter.");
			return;
		}
		//test if the curLogin is a team reviewer
		sql = "select * from tblTeams where CHARINDEX(';" + strCurLogin
				+ ";', ';'+reviewer+';')>0";
		rs = st.executeQuery(sql);
		while (rs.next()) {
			int tId = rs.getInt("teamid");
			strApproverTeamIds += tId + ",";
		}
		strApproverTeamIds = strApproverTeamIds.length() > 0
				? strApproverTeamIds.substring(0,
						strApproverTeamIds.length() - 1)
				: strApproverTeamIds;

		sql = "select logID from tblApprovalSignature where CHARINDEX(';"
				+ strCurLogin
				+ ";', ';'+approverAccout+';')>0 and logID=" + strLog;
		sql += " union select logId from tblLineTeamReview where CHARINDEX(';"
				+ strCurLogin
				+ ";' , ';'+acct+';')>0 and logId="
				+ strLog;
		sql += " union select logId from tblteamReview where CHARINDEX(';"
				+ strCurLogin
				+ ";' , ';'+reviewer+';')>0 and logId="
				+ strLog;

		rs = st.executeQuery(sql);
		if (rs.next())
			bIsLoginLogApprover = true;
		bIsLoginLogApprover = true;//overwrite the  bIsLoginLogApprover value

		if (bIsLoginLogApprover) {
			sql = "select logID  from tblApprovalSignature where CHARINDEX(';"
					+ strCurLogin
					+ ";' , ';'+approverAccout+';')>0 and logID>"
					+ strLog
					+ " and isChecked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

			sql += " union select logID from tblLineTeamreview LTR where CHARINDEX(';"
					+ strCurLogin
					+ ";' , ';'+acct+';')>0 and logID>"
					+ strLog
					+ " and (approved is null or approved<>'Y') and (rejected is null or rejected<>'Y') and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

			sql += " union select logID from tblTeamReview TR where CHARINDEX(';"
					+ strCurLogin
					+ ";' , ';'+reviewer+';')>0 and logID>"
					+ strLog
					+ " and   checked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";
			// out.println(sql);
			rs = st.executeQuery(sql);
			if (rs.next()) {
				bShowNextButton = true;
				strNextButtonEnabled = "";
			}

			sql = "select logID  from tblApprovalSignature where CHARINDEX(';"
					+ strCurLogin
					+ ";' , ';'+approverAccout+';')>0 and logID<"
					+ strLog
					+ " and isChecked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

			sql += " union select logID from tblLineTeamreview LTR where CHARINDEX(';"
					+ strCurLogin
					+ ";' , ';'+acct+';')>0 and logID<"
					+ strLog
					+ " and (approved is null or approved<>'Y') and (rejected is null or rejected<>'Y') and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";

			sql += " union select logID from tblTeamReview TR where CHARINDEX(';"
					+ strCurLogin
					+ ";' , ';'+reviewer+';')>0 and logID<"
					+ strLog
					+ " and   checked=0 and rejected=0 and logID not in (select l.logID from tblChangeControlLog l, tblApprovalStatus s where l.ApprovalStatusID=s.ApprovalStatusID and (s.approvalStatus in ('Rejected','Cancelled','On Hold') or l.hidden='Y'))";
			//System.out.println(sql);

			rs = st.executeQuery(sql);
			if (rs.next()) {
				bShowPrevButton = true;
				strPrevButtonEnabled = "";
			}
		}
		sql = "select * from tblCMSUserPreference where account='"
				+ strCurLogin + "' and preferenceType=1001";
		rs = st.executeQuery(sql);
		if (rs.next()) {
			String strPrefValue = rs.getString("preferenceValue") == null
					? "Y"
					: rs.getString("preferenceValue");
			bShowLabel = strPrefValue.equals("Y");
		}

		sql = "select l.*, isnull(CONVERT(VARCHAR(10), l.approvedDate, 101),'') approvedDateStr, CONVERT(VARCHAR(10), startTiming, 101) startDate, CONVERT(VARCHAR(10), endTiming, 101) endDate,equipmentName,approvalStatus,convert(varchar(10),requestDate,101) requestDateStr  from tblEquipment e,tblChangeControlLog l,tblapprovalStatus a where l.equipmentID=e.equipmentID and l.approvalstatusid=a.approvalstatusid and  l.logID="
				+ strLog;
		rs = st.executeQuery(sql);
		if (rs.next()) {

			strAreaID = rs.getString("areaID");
			strLineID = rs.getString("lineID");
			strCreator = rs.getString("creator");
			strCreatorTeam = rs.getString("creatorteam") == null
					? ""
					: rs.getString("creatorteam");
			strCreatorEmail = rs.getString("creatorEmail") == null
					? ""
					: rs.getString("creatorEmail");
			strCreatorPhone = rs.getString("creatorPhone") == null
					? ""
					: rs.getString("creatorPhone");
			notified = rs.getInt("notified");
			bIsLogHidden = rs.getString("hidden") == null ? false : rs
					.getString("hidden").toUpperCase().equals("Y");

			strEquipment = rs.getString("equipmentName");
			strOriginator = rs.getString("originator");
			bIsReApp = rs.getBoolean("IsReApplication");
			strReApp = rs.getString("ReApp");
			strStartDate = rs.getString("startDate");
			strEndDate = rs.getString("endDate");
			strCostType = rs.getString("CostType");
			strCost = rs.getString("Cost2");
			strDesc = rs.getString("ChangeDesc");
			strDesc = strDesc.replace("\"", "&quot;");

			strReason = rs.getString("ChangeReason");
			strReason = strReason.replace("\"", "&quot;");
			bIsSafety = rs.getBoolean("isSafety");
			bIsEmergency = rs.getBoolean("isEmergency");
			bIsSiteControl = rs.getBoolean("take2Site");
			iApprovalStatusID = rs.getInt("ApprovalStatusID");
			strApprovalStatus = rs.getString("approvalstatus");
			strApprovedBy = rs.getString("approvedBy");
			strApprovedDate = rs.getString("approvedDateStr");
			strStatusComment = rs.getString("StatusComment");
			strOtherEquipment = rs.getString("OtherEquipment") == null
					? ""
					: rs.getString("OtherEquipment");
			strCreationDate = rs.getString("requestDateStr") == null
					? ""
					: rs.getString("requestDateStr");
			strArea = rs.getString("areaNames") == null ? "" : rs
					.getString("areaNames");
			strLine = rs.getString("lineNames") == null ? "" : rs
					.getString("lineNames");

			q1_selection = rs.getString("Q1_SELECTION");
			q1_answer = rs.getString("Q1_ANS");

			q2_selection = rs.getString("Q2_SELECTION");
			q2_answer = rs.getString("Q2_ANS");

			q3_selection = rs.getString("Q3_SELECTION");
			q3_answer = rs.getString("Q3_ANS");

			q4_selection = rs.getString("Q4_SELECTION");
			q4_answer = rs.getString("Q4_ANS");

			q5_selection = rs.getString("Q5_SELECTION");
			q5_answer = rs.getString("Q5_ANS");

			q6_selection = rs.getString("Q6_SELECTION");
			q6_answer = rs.getString("Q6_ANS");

			q7_selection = rs.getString("Q7_SELECTION");
			q7_answer = rs.getString("Q7_ANS");

			q8_selection = rs.getString("Q8_SELECTION");
			q8_answer = rs.getString("Q8_ANS");

			q9_selection = rs.getString("Q9_SELECTION");
			q9_answer = rs.getString("Q9_ANS");

			q10_selection = rs.getString("Q10_SELECTION");
			q10_answer = rs.getString("Q10_ANS");

			q11_selection = rs.getString("Q11_SELECTION");
			q11_answer = rs.getString("Q11_ANS");

			q12_selection = rs.getString("Q12_SELECTION");
			q12_answer = rs.getString("Q12_ANS");

			q13_selection = rs.getString("Q13_SELECTION");
			q13_answer = rs.getString("Q13_ANS");
			
			q14_selection = rs.getString("Q14_SELECTION");
			q14_answer = rs.getString("Q14_ANS");

			tor_selection = rs.getString("TOR_SELECTION");
		} else {
%>
<div>
	<img src="images/alert.jpg;" align="top" alt="Alert">This change
	request(<%=strLog%>) is not available!
</div>
<%
	return;
		}
		if (bIsLogHidden) {
%>
<div>
	<img src="images/alert.jpg;" align="top" alt="Alert">The change
	request(<%=strLog%>) is deleted!
</div>
<%
	return;
		}
		strIsSafety = bIsSafety ? "Yes" : "No";
		strIsEmergency = bIsEmergency ? "Yes" : "No";

		bIsCreator = strCreator.equals(strCurLogin);
		strAreaIDArray = strAreaID.split(",");
		strLineIDArray = strLineID.split(",");

		if (bIsLoginOwner) {
			for (int i = 0; i < strAreaIDArray.length; i++) {
				if (("," + strLoginAreaOwnerIDs + ",").indexOf(","
						+ strAreaIDArray[i] + ",") > -1) {
					bIsLoginLogOwner = true;
					break;
				}

			}
		}
		/* sql = "select areaName from tblArea where areaID in ("+strAreaID+")";
		 rs = st.executeQuery(sql);
		 while(rs.next()){
		   strArea+=rs.getString(1)+";";
		 }
		 if (strArea.lastIndexOf(";")>-1){
		  strArea=strArea.substring(0,strArea.lastIndexOf(";"));
		 }*/
		strAreaArray = strArea.split(",");

		if (strAreaArray.length == 1 && strAreaArray[0].equals("Site"))
			bIsSiteOnly = true;

		/*sql = "select lineName from tblLine where  lineID in ("+strLineID+")";
		rs = st.executeQuery(sql);
		while(rs.next()){
		  strLine+=rs.getString(1)+";";
		}
		if (strLine.lastIndexOf(";")>-1){
		  strLine=strLine.substring(0,strLine.lastIndexOf(";"));
		}*/
		strLineArray = strLine.split(",");

		sql = "select * from tblOwnerSignature where logID =" + strLog;
		rs = st.executeQuery(sql);
		while (rs.next()) {
			strOwnerAcct += rs.getString("approverAccount") + ";";
			strOwnerName += rs.getString("approverName") + ";";
		}
		if (strOwnerName.lastIndexOf(";") > -1) {
			strOwnerName = strOwnerName.substring(0,
					strOwnerName.lastIndexOf(";"));
		}

		if (strOwnerAcct.lastIndexOf(";") > -1) {
			strOwnerAcct = strOwnerAcct.substring(0,
					strOwnerAcct.lastIndexOf(";"));
		}

		/*	  strOwnerAcctArray=strOwnerAcct.split(";");*/

		if (bIsSiteControl == false) {
			for (int n = 0; n < strAreaIDArray.length; n++) {
				if (strAreaIDArray[n].equals("11")) {
					bIsSiteControl = true;
					bLogContainSite = true;
					break;
				}
			}
		}
		boolean bCanApprove = false;
		bCanApprove = bIsLoginLogOwner;

		if (bIsSiteControl) {
			//		 bCanApprove=bIsLoginSiteOwner;
			bIsLoginLogOwner = bIsLoginLogOwner || bIsLoginSiteOwner;
		}
		bCanApprove = bCanApprove || bIsSysadmin;

		boolean bIsLogPending = strApprovalStatus.toUpperCase().equals(
				"PENDING");
		boolean bIsLogInProgress = strApprovalStatus.toUpperCase()
				.equals("IN PROGRESS");
		boolean bIsLogRejected = strApprovalStatus.toUpperCase()
				.equals("REJECTED");
		boolean bIsLogApproved = strApprovalStatus.toUpperCase()
				.equals("APPROVED");
		boolean bIsLogCancelled = strApprovalStatus.toUpperCase()
				.equals("CANCELLED");
		boolean bIsLogImplemented = strApprovalStatus.toUpperCase()
				.equals("IMPLEMENTED");
		boolean bIsLogComplete = strApprovalStatus.toUpperCase()
				.equals("COMPLETE");

		bAllowEdit = (bIsCreator && (bIsLogPending || bIsLogInProgress))
				|| bIsLoginLogOwner || bIsSysadmin; //be able to edit some field.
		String strRejectedStampImage = "./images/rejected.gif";
		String strCancelledStampImage = "./images/cancelled.gif";

		String strBodyClass = "normalBody";
		if (bIsLogRejected)
			strBodyClass = "rejectBody";
		else if (bIsLogCancelled)
			strBodyClass = "cancelBody";
		else if (bIsLogComplete)
			strBodyClass = "completeBody";
		else
			strBodyClass = "normalBody";
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<script language="javascript" type="text/javascript"
	src="jquery-1.7.1.min.js"></script>
<script type="text/javascript">
 var curLogin="<%=strCurLogin%>";  // this line is required for .js file
 var curUserName="<%=strCurUserName%>";
 var curLoginSignature="<%=strSignatureImg%>";
 var llogID=<%=strLog%>; //this line is required for .js file
 var bIsCreator=<%=bIsCreator%>;
 var bAllowEdit=<%=bAllowEdit%>;
 var bIsLoginLogOwner=<%=bIsLoginLogOwner%>;
 var bLogContainSite=<%=bLogContainSite%>;
 var bIsSiteControl=<%=bIsSiteControl%>;
 var bShowLabel=<%=bShowLabel%>;
 var rejectedStampImage="<%=strRejectedStampImage%>";
 var cancelledStampImage="<%=strCancelledStampImage%>";
 var bIsLogInProgress = <%=bIsLogInProgress%>;

  function handleMouseOver(ctrl){
	  var new_img=ctrl.src.substring(0,ctrl.src.length-5)+"r.gif";
	  ctrl.style.cursor="hand";
      ctrl.src=new_img;
	 }
function handleMouseOut(ctrl){
	 var new_img=ctrl.src.substring(0,ctrl.src.length-5)+"b.gif";
	  ctrl.style.cursor="default";
      ctrl.src=new_img;
}
function handleMouseClick(ctrlid,id){

	if (document.getElementById('list'+id).style.display!='none'){
         document.getElementById('list'+id).style.display='none';
		 document.getElementById(ctrlid).src="./images/icon_close_b.gif";
    }
    else{
	    try{document.getElementById('list'+id).style.display='table-row-group';}
	    catch(e){document.getElementById('list'+id).style.display='block';}
        document.getElementById(ctrlid).src="./images/icon_open_b.gif";
	}
}
function handle_ddl(ddlId,targetPanelID){
 var ddlObj=document.getElementById(ddlId);
 var targetObj=document.getElementById(targetPanelID);
 targetObj.innerHTML=ddlObj.options[ddlObj.selectedIndex].text;
}
function showStatComment(targetCtrlId){
	var obj = document.getElementById(targetCtrlId);
	if (obj.style.display=="none")
		obj.style.display="inline-block";
	else if (obj.style.display=="inline-block")
		obj.style.display="none";
}
function initMe(){
  if (top.frames["toc"]){
	  document.getElementById("win_max_min_image").src="./images/maxwin.gif";
	  if (bShowLabel)
	    document.getElementById("win_max_min_label").innerHTML="<br/>Maximize";
	  else
        document.getElementById("win_max_min_label").innerHTML="";

  	  document.getElementById("win_max_min").title="Maximize";
  }
  else{
      document.getElementById("win_max_min_image").src="./images/minwin.gif";
	  if (bShowLabel)
	     document.getElementById("win_max_min_label").innerHTML="<br/>Restore";
	  else
	     document.getElementById("win_max_min_label").innerHTML="";
      document.getElementById("win_max_min").title="Restore";
   var yPosition=document.getElementById("yposition").value;
   window.scrollTo(0, yPosition);
  }
}
 function showTOC(){
	if (top.frames["toc"]){
		window.top.location="./reviewRequest3.jsp?n="+llogID;
	}
	else{
		window.top.location="./ccms.jsp?url="+escape("./reviewRequest3.jsp?n="+llogID);

	}
}
</script>

<script language="javascript" type="text/javascript" src="ajax2.js?v=33"></script>
<script language="javascript" type="text/javascript" src="jsHelper.js"></script>

<script language="javascript" type="text/javascript"
	src="reviewRequest3.js?v=33"></script>
<script language="javascript" type="text/javascript"
	src="datetimepicker.js"></script>
<link rel="stylesheet" type="text/css" href="ccms.css?v=30" />



</head>
<body class="<%=strBodyClass%>" style="" onload="initMe();"
	onunload="handle_unload();">
	<%
		if (bIsLogRejected || bIsLogCancelled) {
				String strImage = bIsLogRejected
						? strRejectedStampImage
						: strCancelledStampImage;
	%>
	<div
		style="position: absolute; left: 300px; top: 100px; background-color: transparent"
		id="stamp" name="stamp">
		<img src="<%=strImage%>" style="width: 250px; height: 200px">
	</div>
	<%
		}
	%>


	<div name="ajaxWindow" id="ajaxWindow"
		style="visibility: hidden; border: 3px double #808080; color: #008000; position: absolute; left: 200; top: 300; z-index: 1">
		<table border='0'
			style="border-collapse: collapse; background-color: #C0C0C0"
			bordercolor="#111111">
			<tr>
				<td align='center' style="color: #FFFFFF; background-color: #000080">Confirmation
					Window</td>
			</tr>
			<tr>
				<td><span name='ajaxResponse' id='ajaxResponse'></span></td>
			</tr>
			<tr>
				<td align='center'><input type="button"
					name="btnCloseAjaxWindow" id="btnCloseAjaxWindow" value="Close"
					onclick="document.getElementById('ajaxWindow').style.visibility='hidden';"></td>
			</tr>
		</table>
	</div>

	<%
		String strOkBtnDisabled = bCanApprove ? "" : "disabled";
	%>

	<div name="ASWin" id="ASWin"
		style="background-color: #000000; visibility: hidden; border: 3px solid #808080; color: #008000; position: absolute; left: 200; top: 300; z-index: 300">
		<table cellpadding="2px" border='0'
			style="border-collapse: collapse; background-color: #C0C0C0"
			bordercolor="#111111">
			<tr>
				<td align='center' style="color: #FFFFFF; background-color: #000080">Status
					Comments</td>
			</tr>
			<tr>
				<td><span style="font-size: 8pt;">Addtional message to
						Originator:</span><br /> <textarea name='txtStatComment'
						id='txtStatComment' style="width: 300; height: 100" rows='5'
						cols='40'><%=strStatusComment%></textarea></td>
			</tr>
			<tr>
				<td align='center'><input type="button" name="okBtn" id="okBtn"
					value="Ok" <%=strOkBtnDisabled%>
					onclick="handleApprovalStatusOk('approvalStatus');">&nbsp;&nbsp;
					<input type="button" name="btnCloseASWin" id="btnCloseASWin"
					value="Cancel"
					onclick="handleApprovalStatusCancel('approvalStatus');"></td>
			</tr>
		</table>
	</div>

	<div name="waitwindow" id="waitwindow"
		style="visibility: hidden; border: 3px double #808080; color: #008000; position: absolute; left: 300; top: 200; z-index: 2">
		<table border='0'
			style="border-collapse: collapse; background-color: #ffffff"
			bordercolor="#111111">
			<tr>
				<td align='center' style="color: #FFFFFF; background-color: #000080">System
					Information</td>
			</tr>
			<tr>
				<td><div>
						<img src="./images/clock.gif" align="left"
							style="width: 100px; height: 100px;"><span id="waitMessage"
							name="waitMessage"><br />System is sending the emails...</span>
					</div></td>
			</tr>
		</table>
	</div>

	<form name="the_form" id="the_form" action="" method="post">
		<input type="hidden" name="logID" id="logID" value="<%=strLog%>">
		<input type="hidden" name="areaID" id="areaID" value="<%=strAreaID%>">
		<input type="hidden" name="pageAction" id="pageAction" value="">
		<input type="hidden" name="yposition" id="yposition"
			value="<%=yPosition%>">
		<div id="title">
			<table border="0" width="95%">
				<tr>
					<td style="font-size: 12pt; font-weight: bold;"><span
						style="background-color: #ffff00;"><%=strArea%></span> Change
						Management Form</td>
					<td nowrap style="text-align: right"><span
						class="toolbarContainer"> <span class="buttonContainer">
								<button class="formButton" onclick="showTOC();" title=""
									id="win_max_min" name="win_max_min">
									<img class="buttonImage" src="" id="win_max_min_image"
										name="win_max_min_image" /> <span id="win_max_min_label"
										name="win_max_min_label" class="buttonLabel"></span>
								</button>
						</span> <%
 	if (bIsLoginLogOwner || bIsSysadmin) {
 %> <span class="buttonContainer">
								<button class="formButton" id="btnNotify" name="btnNotify"
									title="Notify Approvers" onclick="notifyApprovers(this);">
									<img src="./images/notifyApprover.gif" class="buttonImage">(<%=notified%>)
									<span class="buttonLabel"> <%
 	if (bShowLabel) {
 %><br />Notify Approver<%
 	}
 %>
									</span>
								</button>
						</span> <%
 	}
 %> <%
 	if (bIsLoginLogApprover) {
 			if (bShowPrevButton) {
 %> <span class="buttonContainer">
								<button class="formButton" <%=strPrevButtonEnabled%>
									id="btnPrev" name="btnPrev" title="Previous Request"
									onclick=" document.getElementById('pageAction').value='prev'; document.getElementById('the_form').submit();">
									<img src="./images/arrow_left_blue.gif" class="buttonImage"><span
										class="buttonLabel"> <%
 	if (bShowLabel) {
 %><br />Prev<%
 	}
 %>
									</span>
								</button>
						</span> <%
 	}
 			if (bShowNextButton) {
 %> <span class="buttonContainer">
								<button class="formButton" <%=strNextButtonEnabled%>
									id="btnNext" name="btnNext" title="Next Request"
									onclick=" document.getElementById('pageAction').value='next'; document.getElementById('the_form').submit();">
									<img src="./images/arrow_right_blue.gif" class="buttonImage"><span
										class="buttonLabel"> <%
 	if (bShowLabel) {
 %><br>Next<%
 	}
 %>
									</span>
								</button>
						</span> <%
 	}
 		}
 %>

					</span></td>
					<td style="font-size: 12pt; font-weight: bold; text-align: right">LOG#<u><%=strLog%></u></td>
				</tr>
			</table>
		</div>
		<div id="section1" style="margin-top: 10px">
			<table border="0" width="95%" style="font-size: 10pt;">
				<tr>
					<td><b>Originator: </b><u><span
							title="<%=strCreatorEmail%>"><%=strOriginator%></span></u> &nbsp;(<%=strCreator%>)
						<b>&nbsp;&nbsp;Originator Phone: </b><u><%=strCreatorPhone%></u></td>
				</tr>
				<tr>
					<td><b>Department(s): </b><u><%=strArea%></u> <b>&nbsp;&nbsp;Line(s):
					</b><u><%=strLine%></u> <b>&nbsp;&nbsp;Request Date: </b><u><%=strCreationDate%></u>
					</td>
				</tr>
				<tr>
					<td>
						<%--
		     <% if(!strCreatorTeam.equals("")){%>
   		       <b>Team:</b><u><%=strCreatorTeam%></u>&nbsp;&nbsp;
			 <%}%>
			 --%> <b>Equipment: </b><u><%=strEquipment%> <%
 	if (strEquipment.trim().toUpperCase().equals("OTHERS"))
 			out.print(": " + strOtherEquipment);
 %></u> <b>&nbsp;&nbsp;Re-Application: </b><u> <%
 	if (bIsReApp)
 			out.print("Yes");
 		else
 			out.print("No");
 %>
					</u> <%
 	if (bIsReApp)
 			out.print("<b>&nbsp;&nbsp;Reapp From:</b><u>" + strReApp
 					+ "</u>");
 %> <b>&nbsp;&nbsp;Is EO/Chemical Clearance: </b> <input type="hidden"
						name="oldIsSafety" id="oldIsSafety" value="<%=bIsSafety ? 1 : 0%>">
						<span
						style="display: inline-block; border-bottom: #111111 1px solid;"
						id="isSafetyPanel" name="isSafetyPanel"><%=strIsSafety%></span> <span
						id="ddl_safety_panel" name="dll_safety_panel"
						style="display: none"> <select id="ddl_safety"
							name="ddl_safety"
							onchange="handle_ddl('ddl_safety','isSafetyPanel');">
								<option value="0" <%=bIsSafety ? "" : "selected"%>>No</option>
								<option value="1" <%=bIsSafety ? "selected" : ""%>>Yes</option>
						</select>
					</span> <b>&nbsp;&nbsp;Is Emergency: </b> <input type="hidden"
						name="oldIsEmergency" id="oldIsEmergency"
						value="<%=bIsEmergency ? 1 : 0%>"> <span
						style="display: inline-block; border-bottom: #111111 1px solid;"
						id="isEmergencyPanel" name="isEmergencyPanel"><%=strIsEmergency%></span>
						<span id="ddl_emergency_panel" name="ddl_emergency_panel"
						style="display: none"> <select id="ddl_emergency"
							name="ddl_emergency"
							onchange="handle_ddl('ddl_emergency','isEmergencyPanel');">
								<option value="0" <%=bIsEmergency ? "" : "selected"%>>No</option>
								<option value="1" <%=bIsEmergency ? "selected" : ""%>>Yes</option>
						</select>
					</span>
					</td>
				</tr>
			</table>
		</div>

		<%
			//wenhu add Jan 26 2009, pending requests can not be viewed until owner sees it.
				if (bIsLogPending && !bIsCreator && !bIsLoginLogOwner
						&& !bIsSysadmin) {
		%>
		<div id="section_ignore" style="margin-top: 10px; padding-top: 50px;">
			<img src="./images/alert.jpg" valign="top"> <span
				style="color: #ff0000; font-size: 16pt; font-weight: bold">This
				request has not been reviewed by the Department Owner (<%=strOwnerAcct%>)
				yet.<br /> Please contact <font color="#0000ff"><%=strOwnerName%></font>
				for details.
			</span>
		</div>
		<%
			} else {
		%>

		<div id="detail" style="margin-top: 10px">
			<span
				style="font-size: 12pt; background-color: #ffff00; font-weight: bold">CHANGE
				DETAIL</span>
			<%
				if (bAllowEdit) {
			%>
			<img title="Edit Detail"
				style="vertical-align: bottom; cursor: pointer; width: 52px; height: 16px"
				src="images/editBtn.jpg" onclick="handle_edit_all_gui();">
			&nbsp;&nbsp;<img title="Save Detail"
				style="vertical-align: bottom; cursor: pointer; width: 52px; height: 16px"
				src="images/saveBtn.jpg"
				onclick="if (save_all()) handle_save_all_gui();">
			<%
				}
			%>

			<br />
			<div
				style="width: 95%; border: black 2px solid; font-size: 10pt; padding-bottom: 5px;">
				<div style="margin-top: 5px; margin-bottom: 5px">
					<h5>Change Request :</h5>
					<b style="color: green;"><%=tor_selection%></b>
					<table>
						<tr>
							<td>1.  Is this change in the building ?</td>
							<td><%=q1_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q1_selection.equals("Y")?q1_answer:"" %></td>
						</tr>
						<tr>
							<td>2.  Is this change in mechanical part.   Line- pump -  fan -  feeder ?</td>
							<td><%=q2_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q2_selection.equals("Y")?q2_answer:"" %></td>
						</tr>
						
						<tr>
							<td>3.  Is this change in dust control system. Enzyme -  agm?</td>
							<td><%=q3_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q3_selection.equals("Y")?q3_answer:"" %></td>
						</tr>
						
						<tr>
							<td>4.  Is this change in the existing chemicals? </td>
							<td><%=q4_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q4_selection.equals("Y")?q4_answer:"" %></td>
						</tr>
						
						<tr>
							<td>5.  Is this new chemical?</td>
							<td><%=q5_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q5_selection.equals("Y")?q5_answer:"" %></td>
						</tr>
						
						<tr>
							<td>6.  Is this change in building structures?</td>
							<td><%=q6_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q6_selection.equals("Y")?q6_answer:"" %></td>
						</tr>
						
						<tr>
							<td>7.  Is this new building ? </td>
							<td><%=q7_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q7_selection.equals("Y")?q7_answer:"" %></td>
						</tr>
						
						<tr>
							<td>8.  Is this change in sop ? </td>
							<td><%=q8_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q8_selection.equals("Y")?q8_answer:"" %></td>
						</tr>
						
						<tr>
							<td>9. Is this change in the existing traffic system ?</td>
							<td><%=q9_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q9_selection.equals("Y")?q9_answer:"" %></td>
						</tr>
						
						<tr>
							<td>10.  Is this change in material handling equipment ? </td>
							<td><%=q10_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q10_selection.equals("Y")?q10_answer:"" %></td>
						</tr>
						
						<tr>
							<td>11.  Is this new electrical panel ? </td>
							<td><%=q11_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q11_selection.equals("Y")?q11_answer:"" %></td>
						</tr>
						
						<tr>
							<td>12.  Is this change in existing electrical equipment -  panels ?</td>
							<td><%=q12_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q12_selection.equals("Y")?q12_answer:"" %></td>
						</tr>
						
						<tr>
							<td>13.  Is this change in medium volt system ? </td>
							<td><%=q13_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q13_selection.equals("Y")?q13_answer:"" %></td>
						</tr>
						
						<!-- Changes -->
						
						<tr>
							<td>14.Is the software purchased from a standard P&G supplier or a local supplier? (Please provide the name) ? </td>
							<td><%=q14_selection.equals("Y")?"Yes":"No" %></td>
							<td style="color: blue;"><%=q14_selection.equals("Y")?q14_answer:"" %></td>
						</tr>
						
					</table>
					<h5>Proposed Timing</h5>
					<span style="font-weight: bold">Start of construction:</span> <input
						type="hidden" id="oldStartTime" name="oldStartTime"
						value="<%=strStartDate%>"> <input type="text" readonly
						id="startTime" name="startTime"
						style="width: 60px; font-size: 8pt; border-width: 0;"
						value="<%=strStartDate%>"> <a style="visibility: hidden;"
						name="startTimePicker" id="startTimePicker"
						href="javascript:NewCal('startTime','mm/dd/yyyy' )"> <img
						src="./images/cal.gif" width="12" height="12" border="0"
						alt="Pick a date">
					</a> <span style="font-weight: bold">Project startup:</span> <input
						type="hidden" id="oldEndTime" name="oldEndTime"
						value="<%=strEndDate%>"> <input type="text" readonly
						id="endTime" name="endTime"
						style="width: 60px; font-size: 8pt; border-width: 0;"
						value="<%=strEndDate%>"> <a style="visibility: hidden;"
						name="endTimePicker" id="endTimePicker"
						href="javascript:NewCal('endTime','mm/dd/yyyy' )"> <img
						src="./images/cal.gif" width="12" height="12" border="0"
						alt="Pick a date">
					</a> <span style="font-weight: bold; visibility: hidden;">Cost:
						$</span> <input type="hidden" id="oldCost" name="oldCost"
						value="<%=strCost%>"> <input type="hidden" readonly
						id="cost" name="cost"
						style="text-align: left; width: 50px; font-size: 8pt; border-width: 0;"
						value="<%=strCost%>"> <span
						style="font-weight: bold; visibility: hidden;">Type:</span> <input
						type="hidden" id="oldCostType" name="oldCostType"
						value="<%=strCostType%>"> <input type="hidden" readonly
						id="costType" name="costType"
						style="width: 50px; font-size: 8pt; border-width: 0;"
						value="<%=strCostType%>">
				</div>

				<div>
					<span style="font-weight: bold"
						onclick="alert(document.getElementById('oldDesc').value);">Description
						of Change</span>
					<%
						if (bAllowEdit) {
					%>
					<span style="margin-left: 30px"><a
						href="addAttachment.jsp?n=<%=strLog%>"><img
							src="./images/attachBtn.jpg" border='0'
							style="vertical-align: bottom" title="Add Attachments"></a></span>
					<%
						}
					%>
					<%
						sql = "select * from tblAttachments where (hidden<>'Y' or hidden is null) and logID="
										+ strLog;
								st = c.createStatement();
								rs = st.executeQuery(sql);
								int k = 0;
								boolean bHasAttachments = false;
								if (rs.next()) {
									bHasAttachments = true;
					%>
					<span
						style="margin-left: 10px; font-weight: bold; background-color: #ffff00">View
						Attachments:</span>

					<%
						do {
										k++;
										int attID = rs.getInt("ID");
										String strSuffix = rs.getString("docSuffix");
										String strContentType = rs.getString("docType");
										String url = strLog + "_" + attID + strSuffix;
					%>
					<span id="attachmentPanel<%=k%>"
						style="margin-left: 20px; background-color: transparent"> <!--a style="vertical-align: bottom;" href="./Attachments/<%=url%>" target="_blank"-->
						<a style="vertical-align: bottom;"
						href="DownloadFile?fileName=<%=url%>" target="_blank"> <img
							style="width: 18px; height: 16px;" title='Attachment<%=k%>'
							border='0' src='./images/down_arrow_animation.gif'></a> <%
 	if (bAllowEdit) {
 %> (<img title="Delete Attachment<%=k%>"
						style="width: 12px; height: 12px; cursor: pointer; border: 0;"
						src="./images/deleteIcon.gif" name="deleteAttach<%=k%>"
						id="deleteAttach<%=k%>"
						onclick="deleteAttachment(<%=attID%>,'attachmentPanel<%=k%>');">)
						<%
 	}
 %>
					</span>
					<%
						} while (rs.next());
								} else {
					%>
					<!--<span style="margin-left:10px;font-weight:bold;background-color:#ffff00">No Attachments</span>-->
					<%
						}
					%>
				</div>
				<div>
					<table cellpadding="0" cellspacing="0" width="100%">
						<tr>
							<td></td>
						</tr>
					</table>
					<input type="hidden" id="oldDesc" name="oldDesc"
						value="<%=strDesc%>" />
					<div id="descShadow" name="descShadow"
						style="width: 95%; z-index: 1000; visibility: hidden; position: absolute;"><%=strDesc%></div>
					<textarea id="desc" name="desc" readonly
						style="height: 40px; width: 95%; margin-left: 5px;"><%=strDesc%></textarea>
				</div>
				<div>
					<span style="font-weight: bold"
						onclick="alert(document.getElementById('descShadow').offsetHeight);">Reason
						for Change</span>
				</div>
				<input type="hidden" id="oldReason" name="oldReason"
					value="<%=strReason%>">
				<div id="reasonShadow" name="reasonShadow"
					style="width: 95%; z-index: 1000; visibility: hidden; position: absolute;"><%=strReason%></div>
				<textarea id="reason" name="reason" readonly
					style="height: 40px; width: 95%; margin-left: 5px;"><%=strReason%></textarea>

			</div>
		</div>


		<div id="impact">
			<span
				style="font-size: 12pt; background-color: #ffff00; font-weight: bold; visibility: hidden;">IMPACTS</span><br />
			<div style="width: 95%; border: black 2px solid; padding: 2px;">
				<div>

					<%
						for (int i = 0; i < strAreaIDArray.length; i++) {
									sql = "select R.*, isnull(CONVERT(VARCHAR(10), R.checkDate, 101),'') checkDate from tblTeamReview R,tblTeams t where R.logID="
											+ strLog
											+ " and r.teamID=t.teamID and t.areaID="
											+ strAreaIDArray[i];
									rs = st.executeQuery(sql);
									if (rs.next()) {
					%>
					<span
						style="display: inline-block; vertical-align: top; margin-bottom: 5px; margin-right: 5px;">
						<table border="1" cellspacing="0"
							style="font-size: 8pt; border-collapse: collapse; border: 1px solid #000000;">
							<tr>
								<th colspan="3" style="text-align: center;"><%=strAreaArray[i]%></th>
							</tr>
							<tr style="background-color: #c0c0c0">
								<th>Team</th>
								<th><img src="./images/icon_thumb_up.gif" title="Approve" /></th>
								<th><img src="./images/icon_thumb_down.gif" title="Reject" /></th>
							</tr>
							<%
								do {
													int tId = rs.getInt("teamId");
													String team = rs.getString("teamName");
													int reviewID = rs.getInt("ID");
													boolean bReviewed = rs.getBoolean("checked");
													boolean bRejected = rs.getBoolean("rejected");
													String strChecked = bReviewed ? "checked" : "";
													String strRejectChecked = bRejected
															? "checked"
															: "";

													String strReviewer = rs.getString("reviewer") == null
															? ""
															: rs.getString("reviewer");
													strReviewer = strReviewer.replace(" ", "");
													String strReviewerTitle = strReviewer.trim()
															.equals("") ? "" : strReviewer;

													boolean bIsApprover_t = (strReviewer.trim()
															.toLowerCase() + ";")
															.indexOf(strCurLogin + ";") > -1
															|| strReviewer.equals("");
													//wenhu added july 21 2010
													bIsApprover_t = bIsApprover_t
															|| ("," + strApproverTeamIds + ",")
																	.indexOf("," + tId + ",") > -1;

													boolean bCheckBoxEnabled = bIsApprover_t
															&& (bIsLogPending || bIsLogInProgress);
													bCheckBoxEnabled = bCheckBoxEnabled
															|| bIsLoginLogOwner
															|| bIsLoginSiteOwner;
													bCheckBoxEnabled = bCheckBoxEnabled
															|| bIsSysadmin;

													String strEnabled = bCheckBoxEnabled
															? ""
															: "disabled";

													String byWho = rs.getString("byWho");
													String checkDate = rs.getString("checkDate");
													String strTitle = checkDate + ": " + byWho;
							%>
							<tr>
								<td nowrap><span title="<%=strReviewerTitle%>"><%=team%></span></td>
								<td><input class="approveBox" type='checkbox'
									name='teamCheck<%=reviewID%>' id='teamCheck<%=reviewID%>'
									value='<%=reviewID%>' <%=strEnabled%> <%=strChecked%>
									title='<%=strTitle%>'
									onclick="teamReview('teamCheck<%=reviewID%>',<%=reviewID%>);"></td>
								<td><input class="rejectBox" type='checkbox'
									name='teamReject<%=reviewID%>' id='teamReject<%=reviewID%>'
									value='<%=reviewID%>' <%=strEnabled%> <%=strRejectChecked%>
									title='<%=strTitle%>'
									onclick="teamReject('teamReject<%=reviewID%>',<%=reviewID%>);"></td>
							</tr>
							<%
								teamSignatureArray.add("teamCheck" + reviewID);
												} while (rs.next());
							%>
						</table>
					</span>
					<%
						}//end if
								}//end for
					%>




					<%
						String strMyLineTeamIds = "";
								sql = "select * from tblLineTeam where charindex('"
										+ strCurLogin
										+ "',acct)>0 and (hidden is null or hidden<>'Y')";
								rs = st.executeQuery(sql);
								while (rs.next()) {
									int aLineTeamId = rs.getInt("id");
									strMyLineTeamIds += aLineTeamId + ",";

								}
								strMyLineTeamIds = strMyLineTeamIds.length() > 0
										? strMyLineTeamIds.substring(0,
												strMyLineTeamIds.length() - 1)
										: strMyLineTeamIds;

								sql = "select LTR.*,LT.lineteam,LT.lineids, A.areaName from tblLineTeamReview LTR, tblLineTeam LT, tblArea A where logid="
										+ strLog
										+ " and LTR.lineteamid=LT.id and LT.deptid=A.areaId order by A.areaName,LT.lineids,LT.lineteam";
								rs = st.executeQuery(sql);
								String oldLineIds = "";
								int cnt = 0;
								if (rs.next()) {
					%>


					<%
						do {
										int aLTRId = rs.getInt("id");
										int aLineTeamId = rs.getInt("lineteamId");
										String aDeptName = rs.getString("areaName");
										String aLineIds = rs.getString("lineIds"); //line team line ids eg. LT56: 25,26
										String aLineTeam = rs.getString("lineteam");
										String aAcct = rs.getString("acct");
										boolean bLTApproved = rs.getString("approved") == null
												? false
												: rs.getString("approved").equals("Y");
										boolean bLTRejected = rs.getString("rejected") == null
												? false
												: rs.getString("rejected").equals("Y");
										boolean bIsLTApprover = aAcct.indexOf(strCurLogin) > -1;
										bIsLTApprover = bIsLTApprover
												|| (strMyLineTeamIds.length() > 0 && (","
														+ strMyLineTeamIds + ",")
														.indexOf("," + aLineTeamId + "'") > -1);

										String strEnabled = (bIsLTApprover && bIsLogInProgress)
												|| bIsSysadmin || bIsLoginLogOwner
												? ""
												: "disabled";
										String strByWho = rs.getString("byWho") == null
												? ""
												: rs.getString("byWho");
										String strApprovalTime = rs
												.getTimestamp("approvaltime") == null
												? ""
												: datetimeFmt.format(rs
														.getTimestamp("approvaltime"));
										String strTitle = strByWho + ":" + strApprovalTime;

										if (!oldLineIds.equals(aLineIds)) {
											oldLineIds = aLineIds;
											if (cnt > 0) {
					%></table>
					</span>
					<%
						}
					%>
					<span
						style="display: inline-block; vertical-align: top; margin-bottom: 5px; margin-right: 5px;">

						<table border="1" cellspacing="0"
							style="font-size: 8pt; border-collapse: collapse; border: 1px solid #000000;">
							<tr>
								<th colspan="3"><%=aDeptName%></th>
							</tr>
							<tr style="background-color: #c0c0c0">
								<th>LT</th>
								<th><img src="./images/icon_thumb_up.gif" title="Approve" /></th>
								<th><img src="./images/icon_thumb_down.gif" title="Reject" /></th>
							</tr>
							<%
								}
							%>
							<tr
								style="background-color:<%=bIsLTApprover ? "#ff8000" : "transparent"%>;">
								<td title="<%=aAcct%>"><input type="hidden"
									name="LTRId<%=cnt%>" id="LTRId<%=cnt%>" value="<%=aLTRId%>"><%=aLineTeam%></td>
								<td><input type="checkbox" class="approveBox"
									title="<%=strTitle%>" id="LTRApprove<%=cnt%>"
									name="LTRApprove<%=cnt%>" <%=strEnabled%>
									<%=bLTApproved ? "checked" : ""%>
									onclick="LTR_approve(<%=cnt%>);"></td>
								<td><input type="checkbox" class="rejectBox"
									title="<%=aAcct%>" id="LTRReject<%=cnt%>"
									name="LTRReject<%=cnt%>" <%=strEnabled%>
									<%=bLTRejected ? "checked" : ""%>
									onclick="LTR_reject(<%=cnt%>);"></td>
							</tr>
							<%
								lineTeamSignatureArray.add("LTRApprove" + cnt);
												cnt++;

											} while (rs.next());
							%>
						</table>
					</span>
				</div>
				<%
					}
				%>
				<!-- add comment -- scrollable div-->

				<div id="TeamCommentPanel" name="TeamCommentPanel"
					style="border: 0px solid #a0a0a0;">
					<table border="0" cellpadding="0" cellspacing="0"
						style="width: 100%; border-collapse: collapse; font-size: 10pt;">
						<tr style="background-color: #d0d0d0">
							<th style="border: 1px solid #000000; width: 30px;">Act.</th>
							<th
								style="border: 1px solid #000000; width: 80px; overflow: hidden;">By</th>
							<th style="border: 1px solid #000000;"><a
								href="comment.jsp?n=<%=strLog%>" target="_blank">Comment</a></th>
						</tr>
					</table>
				</div>
				<div id="TeamCommentPanel" name="TeamCommentPanel"
					style="border: 0px solid #a0a0a0; overflow-y: auto; height: 150px;">
					<table border="0" cellpadding="0" cellspacing="0"
						style="width: 100%; border-collapse: collapse; font-size: 10pt;">

						<%
							sql = "select * from tblComments where logId=" + strLog
											+ " and deleted=0 order by id";
									rs = st.executeQuery(sql);
									cnt = 0;
									while (rs.next()) {
										int LTCommentId = rs.getInt("id");
										String strLTCommentBy = rs.getString("byWho");
										String strLTComment = rs.getString("comment") == null
												? ""
												: rs.getString("comment");

										java.sql.Timestamp LTCommentTime = rs
												.getTimestamp("commentDate");
										String strLTDate = LTCommentTime == null
												? ""
												: datetimeFmt.format(LTCommentTime);

										String strResponse = rs.getString("response") == null
												? ""
												: rs.getString("response");
										java.sql.Timestamp LTResponseTime = rs
												.getTimestamp("responseDate");
										String strResponseDate = LTResponseTime == null
												? ""
												: datetimeFmt.format(LTResponseTime);

										boolean bIsLTCommentor = strLTCommentBy.toLowerCase()
												.equals(strCurLogin.toLowerCase())
												|| bIsSysadmin || bIsLoginLogOwner;
						%>
						<tr id="TLCommentRow<%=cnt%>" name="TLCommentRow<%=cnt%>">
							<td style="border: 1px solid #000000; width: 30px;"><input
								type="hidden" name="LTCommentId<%=cnt%>"
								id="LTCommentId<%=cnt%>" value="<%=LTCommentId%>">
								<div style="width: 30px;">
									<%
										if (bIsLTCommentor) {
									%><a href="javascript:deleteLTComment(<%=cnt%>)"><img
										src="./images/deleteIcon.gif" style="border: 0px;"></a>
									<%
										}
									%>
								</div></td>
							<td style="border: 1px solid #000000;">
								<div style="width: 80px; overflow: hidden;"
									title="<%=strLTDate%>"><%=strLTCommentBy%></div> <%
 	if (strResponse.trim().length() > 0) {
 %>
								<div style="width: 80px; overflow: hidden;"
									title="<%=strResponseDate%>"><%=strCreator%></div> <%
 	}
 %>
							</td>
							<td style="border: 1px solid #000000;">
								<div>
									<input type="text" style="width: 600px;" id="LTComment<%=cnt%>"
										name="LTComment<%=cnt%>" value="<%=strLTComment%>"
										<%if (bIsLTCommentor) {%> onchange="saveLTComment(<%=cnt%>);"
										<%}%>>

									<%
										if (bIsCreator && strResponse.trim().length() <= 0) {
									%>
									<button
										onclick="document.getElementById('LTResponse<%=cnt%>').style.display='';">R</button>
									<%
										}
									%>
								</div> <%
 	String strDisplay = strResponse.trim().length() > 0
 						? ""
 						: "none";
 %>
								<div>
									<input type="text" style="width:600px;display:<%=strDisplay%>"
										id="LTResponse<%=cnt%>" name="LTResponse<%=cnt%>"
										value="<%=strResponse%>" <%if (bIsCreator) {%>
										onchange="saveLTResponse(<%=cnt%>);" <%}%>>
								</div>
							</td>
						</tr>
						<%
							cnt++;
									}
						%>
						<tr style="background-color: #ff8000;">
							<td style="border: 1px solid #000000;"><input type="hidden"
								name="LTCommentId<%=cnt%>" id="LTCommentId<%=cnt%>" value="">
								<div style="width: 30px;">+</div></td>
							<td style="border: 1px solid #000000;"><div
									style="width: 80px; overflow: hidden;">-</div></td>
							<td style="border: 1px solid #000000; width: 96%"><input
								type="text" style="width: 99%;" id="LTComment<%=cnt%>"
								name="LTComment<%=cnt%>" value="<%=strComment%>"
								onchange="saveLTComment(<%=cnt%>);"></td>
						</tr>
					</table>


				</div>
			</div>
		</div>


		<%
			if (!bIsSiteOnly) { //diplay departmental approval
		%>
		<div id="deptapproval">
			<span
				style="font-size: 12pt; background-color: #ffff00; font-weight: bold">DEPARTMENT
				APPROVAL</span><br />
			<div
				style="font-size: 10pt; width: 95%; border: black 2px solid; white-space: nowrap;">
				Process Owners should refer to the Site Change Control Checklist for
				scope of responsibility.<br />

				<table border='0' cellspacing="2" cellpadding="2"
					style="font-size: 10pt;">
					<tr style="margin-top: 10px; margin-bottom: 10px;">
						<th style="width: 20px;">&nbsp;</th>
						<th style="text-align: center; width: 160px; font-weight: bold;">Approval
							Type</th>
						<th style="text-align: center; width: 100px; font-weight: bold;">Approver</th>
						<th style="width: 20px; text-align: center;"><img
							src="images/icon_thumb_up.gif" alt="Approve"></th>
						<th style="width: 20px; text-align: center;"><img
							src="images/icon_thumb_down.gif" alt="Reject"></th>
						<th style="width: 130px; text-align: center; font-weight: bold;">Signature</th>
						<th style="width: 80px; text-align: left; font-weight: bold;">Followup<br />Required
						</th>
						<th style="width: 200px; text-center: left; font-weight: bold;">Signature=<br />Follow
							up Complete
						</th>
					</tr>
					<%
						st = c.createStatement();
									//select all non-site approvers
									cnt = 0;
									sql = "select  tas.*,isnull(CONVERT(VARCHAR(10),checkDate, 101),'') checkDateStr,isnull(CONVERT(VARCHAR(10),followupCheckDate, 101),'') followupCheckDateStr from tblApprovalSignature tas  where tas.logID in ("
											+ strLog
											+ ") and (tas.approverID not in (select approverId from tblApprovers where areaID in (select areaId from tblArea where areaName='Site')) or tas.approverID<0)";
									rs = st.executeQuery(sql);
									while (rs.next()) {
										long id = rs.getLong("id");
										signatureArray.add("signatureBox" + id);
										hasFollowupArray.add("hasFollowupHidden" + id);
										followupSignatureArray.add("followupSignatureBox"
												+ id);

										int iApproverID = rs.getInt("approverID");
										String strApproverType = rs
												.getString("approverType");
										String strApproverName = rs
												.getString("approverName");
										String strApproverAccount = rs
												.getString("ApproverAccout");
										boolean isChecked = rs.getBoolean("isChecked");
										boolean isRejected = rs.getBoolean("rejected");

										String strCheckedBy = rs.getString("byWho");
										String strCheckDate = rs.getString("checkDateStr");
										boolean hasFollowup = rs.getBoolean("hasFollowup");
										String strFollowup = rs.getString("followup") == null
												? ""
												: rs.getString("followup");
										strFollowup = strFollowup.replace("\"", "&quot;");
										boolean isFollowupSigned = rs
												.getBoolean("isFollowupChecked");
										String strFollowupCheckedBy = rs
												.getString("followupByWho");
										String strFollowupCheckDate = rs
												.getString("followupCheckDateStr");

										boolean bIsApprover_t = ((strApproverAccount.trim()
												.toLowerCase() + ";").indexOf(strCurLogin
												+ ";") > -1)
												|| strApproverAccount.trim().equals("");

										String strChecked = isChecked ? "checked" : "";
										String strRejectChecked = isRejected
												? "checked"
												: "";

										boolean bSignBoxEnabled = bIsApprover_t
												&& (bIsLogPending || bIsLogInProgress);
										bSignBoxEnabled = bSignBoxEnabled
												|| (bIsLoginSiteOwner || bIsLoginLogOwner);
										bSignBoxEnabled = bSignBoxEnabled || bIsSysadmin;

										boolean isDelegate = strCurLogin
												.equalsIgnoreCase(DelegateHelper
														.getDelegate(strApproverAccount));
										bSignBoxEnabled = bSignBoxEnabled || isDelegate;

										String strSignatureEnabled = bSignBoxEnabled
												? ""
												: "disabled";
										String strTitle = strCheckedBy + ":" + strCheckDate;

										String strHasFollowup = hasFollowup
												? "checked"
												: "";
										String strFollowupBoxImg = hasFollowup
												? "./images/checkbox_y.jpg"
												: "./images/checkbox_n.jpg";

										boolean bHasFollowupEnabled = bIsApprover_t
												&& (bIsLogPending || bIsLogInProgress);
										bHasFollowupEnabled = bHasFollowupEnabled
												|| bIsLoginLogOwner || bIsLoginSiteOwner
												|| bIsSysadmin;

										strFollowupBoxImg = bHasFollowupEnabled
												? strFollowupBoxImg
												: (hasFollowup
														? "./images/discheckbox_y.jpg"
														: "./images/discheckbox_n.jpg");

										String strHasFollowupBoxEnabled = bHasFollowupEnabled
												? ""
												: "disabled";
										String strFollowupReadOnly = bHasFollowupEnabled
												? ""
												: "readonly";

										String strFollowupMark = hasFollowup
												? "<img title='Followup' onclick=\"handleMouseClick('iconOpen"
														+ id
														+ "',"
														+ id
														+ ");\" id='followupMark"
														+ id
														+ "' name='followupMark"
														+ id
														+ "' src='./images/comment.gif'>"
												: "";

										String strFollowupSigned = isFollowupSigned
												? "checked"
												: "";
										String strFollowupTitle = strFollowupCheckedBy
												+ ":" + strFollowupCheckDate;

										boolean bSignFollowupBoxEnabled = bIsApprover_t
												&& (bIsLogPending || bIsLogInProgress
														|| bIsLogApproved || bIsLogImplemented);
										bSignFollowupBoxEnabled = (bSignFollowupBoxEnabled
												|| bIsLoginSiteOwner || bIsLoginLogOwner)
												&& hasFollowup;
										bSignFollowupBoxEnabled = bSignFollowupBoxEnabled
												|| bIsSysadmin;

										String strFollowupSignatureEnabled = bSignFollowupBoxEnabled
												? ""
												: "disabled";

										String signatureFilePath = application
												.getRealPath("/") + "images\\Signatures\\";
										File signatureFile = new File(signatureFilePath
												+ strCheckedBy + ".jpg");
										boolean bSignatureExist = signatureFile.exists();
										String strSignaturePicture = bSignatureExist
												? "<img class='signature' src='./images/Signatures/"
														+ strCheckedBy
														+ ".jpg' alt='"
														+ strCheckedBy + "'>"
												: strCheckedBy;

										File followupSignatureFile = new File(
												signatureFilePath + strFollowupCheckedBy
														+ ".jpg");
										boolean bFollowupSignatureExist = followupSignatureFile
												.exists();
										String strFollowupSignaturePicture = bFollowupSignatureExist
												? "<img class='signature' src='./images/Signatures/"
														+ strFollowupCheckedBy
														+ ".jpg' alt='"
														+ strFollowupCheckedBy + "'>"
												: strFollowupCheckedBy;

										String strSignature = isChecked || isRejected
												? strSignaturePicture
												: "&nbsp;";
										String strFollowupSignature = isFollowupSigned
												? strFollowupSignaturePicture
												: "&nbsp;";

										String strDisplay = "display:none;";
										if (strCollapse.equals("yes"))
											strDisplay = "";
										else if (strCollapse.equals("no"))
											strDisplay = "display:none;";
										else
											strDisplay = ((strApproverAccount + ";")
													.indexOf(strCurLogin + ";") > -1)
													? ""
													: "display:none;";
										String strIconStatus = strDisplay.equals("")
												? "open"
												: "close";
										String strHasFollowupStyle = hasFollowup ? "" : "";
										String strRowStyle = "";
										if (isDelegate)
											strRowStyle = "background-color:#FFFF00;";
										else if (bIsApprover_t)
											strRowStyle = "background-color:#ff8000;";

										// test if this approval has a check list
										sql = "select llist.*, isnull(CONVERT(VARCHAR(10),checkDate, 101),'') checkDateStr from tblLogSiteList llist where llist.logID in ("
												+ strLog
												+ ") and approverID="
												+ iApproverID;
										st2 = c.createStatement();
										rs2 = st2.executeQuery(sql);
										boolean bHasSubList = false;
										if (rs2.next())
											bHasSubList = true;
										if (!bHasSubList)
											strFollowupMark = hasFollowup
													? "<img title='Followup' align='top' onclick=\"showFollowupWindow('followupwindow"
															+ id
															+ "',true);\" id='followupMark"
															+ id
															+ "' name='followupMark"
															+ id
															+ "' src='./images/comment.gif'>"
													: "";
					%>
					<tr style="height:30px;<%=strRowStyle%>">
						<td style="width: 20px;">
							<%
								if (bHasSubList) {
							%> <img id="iconOpen<%=id%>" name="iconOpen<%=id%>"
							src="images/icon_<%=strIconStatus%>_b.gif"
							onmouseover="handleMouseOver(this);"
							onmouseout="handleMouseOut(this);"
							onclick="handleMouseClick('iconOpen<%=id%>',<%=id%>);"> <%
 	} else {
 %> &nbsp; <%
 	}
 %>
						</td>

						<td
							style="text-align:left; width:160px;font-weight:bold; <%=strHasFollowupStyle%>"><%=strApproverType%></td>
						<td title="<%=strApproverAccount%>"
							style="vertical-align: bottom; width: 100px; border-bottom: #cccccc thin solid;">
							<%=strApproverName%> <input type="hidden"
							name="deptApproverAcct<%=cnt%>" id="deptApproverAcct<%=cnt%>"
							value="<%=strApproverAccount%>">
						</td>
						<td style="vertical-align: bottom; width: 20px;"><input
							class="approveBox" type='checkbox' name='signatureBox<%=id%>'
							id='signatureBox<%=id%>' value=<%=strApproverAccount%>
							' <%=strChecked%> <%=strSignatureEnabled%>
							onclick="sign('signatureBox<%=id%>','signaturePanel<%=id%>',<%=id%>);"
							title='<%=strTitle%>'></td>
						<td style="vertical-align: bottom; width: 20px;"><input
							class="rejectBox" type='checkbox' name='rejectBox<%=id%>'
							id='rejectBox<%=id%>' value=<%=strApproverAccount%>
							' <%=strRejectChecked%> <%=strSignatureEnabled%>
							onclick="reject('rejectBox<%=id%>','signaturePanel<%=id%>',<%=id%>);"
							title='<%=strTitle%>'></td>
						<td id='signaturePanel<%=id%>' name='signaturePanel<%=id%>'
							style='vertical-align: bottom; width: 130px; border-bottom: #cccccc thin solid;'>
							<%=strSignature%>
						</td>
						<td style="vertical-align: bottom; width: 80px; text-align: left;">
							<input type="hidden" name="hasFollowupHidden<%=id%>"
							id="hasFollowupHidden<%=id%>" value="<%=hasFollowup%>"> <%
 	if (bHasSubList) {
 %> <span style="width: 30px; text-align: center; display: inline-block">
								<img name="followupCheckBoxImg<%=id%>"
								id="followupCheckBoxImg<%=id%>" src="<%=strFollowupBoxImg%>"
								onclick="handleMouseClick('iconOpen<%=id%>',<%=id%>);">
						</span><span id='followupMarkPanel<%=id%>'
							name='followupMarkPanel<%=id%>'><%=strFollowupMark%></span> <%
 	} else { //no sublist show real checkbox
 %> <span style="width: 30px; text-align: center; display: inline-block">
								<input type='checkbox' name='followupBox<%=id%>'
								id='followupBox<%=id%>' value='Y'
								onclick="handleFollowup('followupBox<%=id%>','followupwindow<%=id%>',<%=id%>);"
								<%=strHasFollowup%> <%=strHasFollowupBoxEnabled%>>
						</span><span id='followupMarkPanel<%=id%>'
							name='followupMarkPanel<%=id%>'><%=strFollowupMark%></span>

							<div name="followupwindow<%=id%>" id="followupwindow<%=id%>"
								style="display: none; border: 3px solid #808080; color: #008000; position: absolute; z-index: 10">
								<table border='0'
									style="border-collapse: collapse; background-color: #C0C0C0"
									bordercolor="#111111">
									<tr>
										<td align='center'
											style="color: #FFFFFF; background-color: #000080">
											Followup</td>
									</tr>
									<tr>
										<td><input type="hidden" name='oldTxtFollowup<%=id%>'
											id='oldTxtFollowup<%=id%>' value="<%=strFollowup%>">
											<textarea name='txtFollowup<%=id%>' id='txtFollowup<%=id%>'
												rows='5' cols='40' <%=strFollowupReadOnly%>><%=strFollowup%></textarea>
										</td>
									</tr>
									<tr>
										<td align='center'><input type="button" name="okBtn"
											id="okBtn" value="Save" <%=strHasFollowupBoxEnabled%>
											onclick="addFollowup('txtFollowup<%=id%>',<%=id%>);showFollowupWindow('followupwindow<%=id%>',0);document.getElementById('oldTxtFollowup<%=id%>').value=document.getElementById('txtFollowup<%=id%>').value">&nbsp;&nbsp;
											<input type="button" name="cancelBtn" id="cancelBtn"
											value="Cancel"
											onclick="showFollowupWindow('followupwindow<%=id%>',0); document.getElementById('txtFollowup<%=id%>').value=document.getElementById('oldTxtFollowup<%=id%>').value">
										</td>
									</tr>
								</table>
							</div> <%
 	} //end of showing real followup checkbox
 %>
						</td>
						<td
							style='vertical-align: bottom; width: 200px; border-bottom: #cccccc thin solid;'>
							<input type='checkbox' name='followupSignatureBox<%=id%>'
							id='followupSignatureBox<%=id%>' value='<%=strApproverAccount%>'
							<%=strFollowupSigned%> <%=strFollowupSignatureEnabled%>
							onclick="signFollowup('followupSignatureBox<%=id%>','followupSignaturePanel<%=id%>', <%=id%> );"
							title='<%=strFollowupTitle%>'> <span
							id='followupSignaturePanel<%=id%>'
							name='followupSignaturePanel<%=id%>'><%=strFollowupSignature%></span>
						</td>
					</tr>

					<%
						if (bHasSubList) { //display the sublist
					%>
					<tr id="list<%=id%>" name="list<%=id%>"
						style="margin-left:50px;margin-top:10px;<%=strDisplay%>">
						<td colspan='8'>
							<table style="margin-left: 60px" border="0" cellspacing='5'
								style="background-color:#DDDDDD;text-align:left;border-collapse: collapse;  font-family:Courier New; font-size:10pt">
								<tr style="color: #ffffff; background-color: #000088">
									<th align="center" width="300px"><u>Item</u></th>
									<th align="center" title="">Required</u></th>
									<th align="center">Comment</th>
								</tr>
								<%
									int subItemCnt = 0;
														do {
															String lstRequiredStr = rs2
																	.getString("requiredString");
															long lslID = rs2.getLong("ID");
															boolean isRequired = rs2
																	.getBoolean("isRequired");

															String lslCheckedBy = rs2
																	.getString("byWho") == null
																	? ""
																	: rs2.getString("byWho");
															String strIsSubCat = rs2
																	.getString("isSubCat") == null
																	? "N"
																	: rs2.getString("isSubCat");
															String strSiteListComment = rs2
																	.getString("comment") == null
																	? ""
																	: rs2.getString("comment");
															strSiteListComment = strSiteListComment
																	.replace("\"", "&quot;");
															String lslCheckDate = rs2
																	.getString("checkDateStr");

															String lslTitle = lslCheckedBy + ":"
																	+ lslCheckDate;
															String strCheckStatus = isRequired
																	? "checked"
																	: "";
															String strHidden = isRequired
																	? "visible"
																	: "hidden";

															if (strIsSubCat.equals("Y"))
																lstRequiredStr = "<span class='listInfo'>"
																		+ lstRequiredStr + "</span>";
															else
																subItemCnt++;
								%>
								<tr>
									<td align="left" width="300px"
										style="border-bottom-style: solid; border-color: #eeeeee; border-bottom-width: 1px;">
										<%=lstRequiredStr%>
									</td>
									<td align="center">
										<%
											if (!strIsSubCat.equals("Y")) {
										%> <input style="visibility: visible" type="checkbox"
										id="SiteControlLslBox_<%=id%>_<%=subItemCnt%>"
										<%=strCheckStatus%> title="<%=lslTitle%>"
										<%=strHasFollowupBoxEnabled%>
										onclick="handle_lsl('SiteControlLslBox_<%=id%>_<%=subItemCnt%>',<%=lslID%>,<%=iApproverID%>,<%=id%>,<%=subItemCnt%>);">
										<%
											} else {
										%> &nbsp; <%
 	}
 %>
									</td>
									<td>
										<%
											if (!strIsSubCat.equals("Y")) {
										%> <textarea class=""
											style="width:300px;visibility:<%=strHidden%>"
											id="SiteListComment_<%=id%>_<%=subItemCnt%>"
											onchange="handle_lsl_comment('SiteListComment_<%=id%>_<%=subItemCnt%>',<%=lslID%>,<%=iApproverID%>,<%=id%>,<%=subItemCnt%>);"
											title="<%=strSiteListComment%>" <%=strFollowupReadOnly%>><%=strSiteListComment%></textarea>
										<%
											} else {
										%> &nbsp; <%
 	}
 %>
									</td>
								</tr>
								<%
									} while (rs2.next());
								%>
								<tr style="display: none">
									<td><input type="hidden" name="subItemCnt_<%=id%>"
										id="subItemCnt_<%=id%>" value="<%=subItemCnt%>"></td>
								</tr>
								<%
									rs2.close();
														st2.close();
								%>
							</table>
						</td>
					</tr>
					<!-- end of list-->
					<%
						}//end of sublist
										cnt++;
									}//end of while
					%>

					<%
						// display take to site row
									String strTake2SiteEnabled = (bIsLoginLogOwner
											&& (bIsLogPending || bIsLogInProgress) && !bLogContainSite)
											|| bIsSysadmin ? "" : "disabled";
									String strIsSiteControlChecked = bIsSiteControl
											? "checked"
											: "";
									String strIsNotSiteControlChecked = bIsSiteControl
											? ""
											: "checked";
					%>
					<%--		
	<tr valign="top">
	   <td colspan="2" align='right'>Need to take to Site<br/>Change Management?</td>
	  <td>
	   <input type="radio" name="siteControlGroup" id="siteControlYes" value="Y" onclick="updateSiteControl2(this,1);"  <%=strIsSiteControlChecked%> <%=strTake2SiteEnabled%>>Yes
	   <input type="radio" name="siteControlGroup" id="siteControlNo" value="N" onclick="updateSiteControl2(this,0);" <%=strIsNotSiteControlChecked%> <%=strTake2SiteEnabled%>>No
	  </td>
	 <td colspan="4">If "No", then Department Change Owner to Sign:</td>
	 <td>
	  <table border ='0' style="font-size:10pt;">
	  <%
         st=c.createStatement();
	     sql = "select *,isnull(CONVERT(VARCHAR(10),checkDate, 101),'') checkDateStr from tblOwnerSignature where logID in ("+strLog+") and areaID<0";
         rs = st.executeQuery(sql);
         while(rs.next()){
			 int ownerid=rs.getInt("id");
			 boolean bIsSigned =rs.getBoolean("isChecked");
			 String strApproverAccount=rs.getString("approveraccount")==null?"":rs.getString("approveraccount");
 			 String strSignedBy=rs.getString("byWho")==null?"":rs.getString("byWho");
			 String strSignBoxCheck=bIsSigned? "checked":"";

 			 boolean bIsOwner=((strApproverAccount.trim()+";").indexOf(strCurLogin+";")>-1)||strApproverAccount.trim().equals("");

 		     String signatureFilePath=application.getRealPath("/")+"images\\Signatures\\";
		     File signatureFile=new File(signatureFilePath+strSignedBy+".jpg");
             boolean bSignatureExist=signatureFile.exists() ;
		     String strSignaturePicture=bSignatureExist?"<img class='signature' src='./images/Signatures/"+strSignedBy+".jpg' alt='"+strSignedBy+"'>":strSignedBy;
             strSignaturePicture=bIsSigned?strSignaturePicture:"";

			 String strTitle=rs.getString("byWho")+":"+rs.getString("checkDateStr");

			 boolean bSignBoxEnabled=(bIsOwner && (bIsLogPending || bIsLogInProgress) )|| bIsSysadmin;
             String strEnabled=  bSignBoxEnabled ?"":"disabled";
	     %>
     	  <tr>
		    <td valign='bottom' style='border-bottom: #cccccc thin solid; '>
			<input class="approveBox" type='checkbox' name='ownerSignatureBox<%=ownerid%>' id='ownerSignatureBox<%=ownerid%>' value='<%=ownerid%>' <%=strSignBoxCheck%> title='<%=strTitle%>' onclick="ownerSign('ownerSignatureBox<%=ownerid%>','ownerSignaturePanel<%=ownerid%>');" <%=strEnabled%>>
			<span style="width:150px;" id='ownerSignaturePanel<%=ownerid%>'><%=strSignaturePicture%></span>
		  </tr>
	      <tr><td align="center" title="<%=strApproverAccount%>"><%=rs.getString("approverName")%></td></tr>
        <%
	     }
	   %>
	  </table>
     </td>
	</tr>
	--%>
				</table>

			</div>
		</div>
		<%
			} //end of display departmental approval
		%>


		<%
			// start
					if (bIsSiteControl) {
		%>
		<div id="site">
			<span
				style="font-size: 12pt; background-color: #ffff00; font-weight: bold">SITE
				APPROVAL</span><br />
			<div style="font-size: 10pt; width: 95%; border: black 2px solid;">
				<table border='0' cellspacing="2" cellpadding="2"
					style="font-size: 10pt;">
					<tr style="margin-top: 10px; margin-bottom: 10px;">
						<th style="width: 20px;">&nbsp;</th>
						<th style="text-align: center; width: 160px; font-weight: bold;">Approval
							Type</th>
						<th style="text-align: center; width: 100px; font-weight: bold;">Approver</th>
						<th style="width: 20px; text-align: center;"><img
							src="images/icon_thumb_up.gif" alt="Approve"></th>
						<th style="width: 20px; text-align: center;"><img
							src="images/icon_thumb_down.gif" alt="Reject"></th>
						<th style="width: 130px; text-align: center; font-weight: bold;">Signature</th>
						<th style="width: 80px; text-align: left; font-weight: bold;">Followup<br />Required
						</th>
						<th style="width: 200px; text-center: left; font-weight: bold;">Signature=<br />Follow
							up Complete
						</th>
					</tr>
					<%
						st = c.createStatement();
									sql = "select  tas.*,isnull(CONVERT(VARCHAR(10),checkDate, 101),'') checkDateStr,isnull(CONVERT(VARCHAR(10),followupCheckDate, 101),'') followupCheckDateStr from tblApprovalSignature tas  where tas.logID in ("
											+ strLog
											+ ") and tas.approverID in (select approverID from tblApprovers where  areaid=(select areaid from tblarea where areaname='Site'))";
									rs = st.executeQuery(sql);
									//  int seq=0;
									while (rs.next()) {
										long id = rs.getLong("id");
										signatureArray.add("signatureBox" + id);
										hasFollowupArray.add("hasFollowupHidden" + id);
										followupSignatureArray.add("followupSignatureBox"
												+ id);

										int iApproverID = rs.getInt("approverID");
										String strApproverType = rs
												.getString("approverType");
										String strApproverName = rs
												.getString("approverName");
										String strApproverAccount = rs
												.getString("ApproverAccout");
										boolean isChecked = rs.getBoolean("isChecked");
										boolean isRejected = rs.getBoolean("rejected");

										String strCheckedBy = rs.getString("byWho");
										String strCheckDate = rs.getString("checkDateStr");
										boolean hasFollowup = rs.getBoolean("hasFollowup");
										String strFollowup = rs.getString("followup") == null
												? ""
												: rs.getString("followup");
										strFollowup = strFollowup.replace("\"", "&quot;");

										boolean isFollowupSigned = rs
												.getBoolean("isFollowupChecked");
										String strFollowupCheckedBy = rs
												.getString("followupByWho");
										String strFollowupCheckDate = rs
												.getString("followupCheckDateStr");

										boolean bIsApprover_t = ((strApproverAccount.trim()
												.toLowerCase() + ";").indexOf(strCurLogin
												+ ";") > -1)
												|| strApproverAccount.trim().equals("");

										String strChecked = isChecked ? "checked" : "";
										String strRejectChecked = isRejected
												? "checked"
												: "";

										boolean bSignBoxEnabled = bIsApprover_t
												&& (bIsLogPending || bIsLogInProgress);
										bSignBoxEnabled = bSignBoxEnabled
												|| bIsLoginSiteOwner;
										bSignBoxEnabled = bSignBoxEnabled || bIsSysadmin;

										boolean isDelegate = strCurLogin
												.equalsIgnoreCase(DelegateHelper
														.getDelegate(strApproverAccount));
										bSignBoxEnabled = bSignBoxEnabled || isDelegate;

										String strSignatureEnabled = bSignBoxEnabled
												? ""
												: "disabled";
										String strTitle = strCheckedBy + ":" + strCheckDate;

										String strHasFollowup = hasFollowup
												? "checked"
												: "";
										String strFollowupBoxImg = hasFollowup
												? "./images/checkbox_y.jpg"
												: "./images/checkbox_n.jpg";

										boolean bHasFollowupEnabled = bIsApprover_t
												&& (bIsLogPending || bIsLogInProgress);
										bHasFollowupEnabled = bHasFollowupEnabled
												|| bIsLoginLogOwner || bIsLoginSiteOwner
												|| bIsSysadmin;

										strFollowupBoxImg = bHasFollowupEnabled
												? strFollowupBoxImg
												: (hasFollowup
														? "./images/discheckbox_y.jpg"
														: "./images/discheckbox_n.jpg");

										String strHasFollowupBoxEnabled = bHasFollowupEnabled
												? ""
												: "disabled";
										String strFollowupReadOnly = bHasFollowupEnabled
												? ""
												: "readonly";

										String strFollowupMark = hasFollowup
												? "<img title='Followup' onclick=\"handleMouseClick('iconOpen"
														+ id
														+ "',"
														+ id
														+ ");\" id='followupMark"
														+ id
														+ "' name='followupMark"
														+ id
														+ "' src='./images/comment.gif'>"
												: "";

										String strFollowupSigned = isFollowupSigned
												? "checked"
												: "";
										String strFollowupTitle = strFollowupCheckedBy
												+ ":" + strFollowupCheckDate;

										boolean bSignFollowupBoxEnabled = bIsApprover_t
												&& (bIsLogPending || bIsLogInProgress
														|| bIsLogApproved || bIsLogImplemented);
										bSignFollowupBoxEnabled = (bSignFollowupBoxEnabled
												|| bIsLoginSiteOwner || bIsLoginLogOwner)
												&& hasFollowup;
										bSignFollowupBoxEnabled = bSignFollowupBoxEnabled
												|| bIsSysadmin;

										String strFollowupSignatureEnabled = bSignFollowupBoxEnabled
												? ""
												: "disabled";

										String signatureFilePath = application
												.getRealPath("/") + "images\\Signatures\\";
										File signatureFile = new File(signatureFilePath
												+ strCheckedBy + ".jpg");
										boolean bSignatureExist = signatureFile.exists();
										String strSignaturePicture = bSignatureExist
												? "<img class='signature' src='./images/Signatures/"
														+ strCheckedBy
														+ ".jpg' alt='"
														+ strCheckedBy + "'>"
												: strCheckedBy;

										File followupSignatureFile = new File(
												signatureFilePath + strFollowupCheckedBy
														+ ".jpg");
										boolean bFollowupSignatureExist = followupSignatureFile
												.exists();
										String strFollowupSignaturePicture = bFollowupSignatureExist
												? "<img class='signature' src='./images/Signatures/"
														+ strFollowupCheckedBy
														+ ".jpg' alt='"
														+ strFollowupCheckedBy + "'>"
												: strFollowupCheckedBy;

										String strSignature = isChecked
												? strSignaturePicture
												: "&nbsp;";
										String strFollowupSignature = isFollowupSigned
												? strFollowupSignaturePicture
												: "&nbsp;";

										String strDisplay = "display:none;";
										if (strCollapse.equals("yes"))
											strDisplay = "";
										else if (strCollapse.equals("no"))
											strDisplay = "display:none;";
										else
											strDisplay = ((strApproverAccount + ";")
													.indexOf(strCurLogin + ";") > -1)
													? ""
													: "display:none;";
										String strIconStatus = strDisplay.equals("")
												? "open"
												: "close";
										String strHasFollowupStyle = hasFollowup
												? "color:#0044ff;"
												: "";
										String strRowStyle = ""; //bIsApprover_t?"background-color:#ff8000;":"";
										if (isDelegate)
											strRowStyle = "background-color:#FFFF00;";
										else if (bIsApprover_t)
											strRowStyle = "background-color:#ff8000;";
					%>
					<tr style="height:30px;<%=strRowStyle%>">
						<td style="width: 20px;"><img id="iconOpen<%=id%>"
							name="iconOpen<%=id%>" src="images/icon_<%=strIconStatus%>_b.gif"
							onmouseover="handleMouseOver(this);"
							onmouseout="handleMouseOut(this);"
							onclick="handleMouseClick('iconOpen<%=id%>',<%=id%>);"></td>

						<td
							style="text-align:left; width:160px;font-weight:bold; <%=strHasFollowupStyle%>"><%=strApproverType%></td>
						<td title="<%=strApproverAccount%>"
							style="vertical-align: bottom; width: 100px; border-bottom: #cccccc thin solid;">
							<%=strApproverName%></td>
						<td style="vertical-align: bottom; width: 20px;"><input
							class="approveBox" type='checkbox' name='signatureBox<%=id%>'
							id='signatureBox<%=id%>' value=<%=strApproverAccount%>
							' <%=strChecked%> <%=strSignatureEnabled%>
							onclick="sign('signatureBox<%=id%>','signaturePanel<%=id%>',<%=id%>);"
							title='<%=strTitle%>'></td>
						<td style="vertical-align: bottom; width: 20px;"><input
							class="rejectBox" type='checkbox' name='rejectBox<%=id%>'
							id='rejectBox<%=id%>' value=<%=strApproverAccount%>
							' <%=strRejectChecked%> <%=strSignatureEnabled%>
							onclick="reject('rejectBox<%=id%>','signaturePanel<%=id%>',<%=id%>);"
							title='<%=strTitle%>'></td>
						<td id='signaturePanel<%=id%>' name='signaturePanel<%=id%>'
							style='vertical-align: bottom; width: 130px; border-bottom: #cccccc thin solid;'>
							<%=strSignature%>
						</td>

						<td style="vertical-align: bottom; width: 80px; text-align: left;">
							<input type="hidden" name="hasFollowupHidden<%=id%>"
							id="hasFollowupHidden<%=id%>" value="<%=hasFollowup%>"> <img
							name="followupCheckBoxImg<%=id%>" id="followupCheckBoxImg<%=id%>"
							src="<%=strFollowupBoxImg%>"
							onclick="handleMouseClick('iconOpen<%=id%>',<%=id%>);">
							&nbsp;<%=strFollowupMark%>
						</td>

						<td
							style='vertical-align: bottom; width: 200px; border-bottom: #cccccc thin solid;'>
							<input type='checkbox' name='followupSignatureBox<%=id%>'
							id='followupSignatureBox<%=id%>' value='<%=strApproverAccount%>'
							<%=strFollowupSigned%> <%=strFollowupSignatureEnabled%>
							onclick="signFollowup('followupSignatureBox<%=id%>','followupSignaturePanel<%=id%>', <%=id%> );"
							title='<%=strFollowupTitle%>'> <span
							id='followupSignaturePanel<%=id%>'
							name='followupSignaturePanel<%=id%>'><%=strFollowupSignature%></span>
						</td>
					</tr>


					<tr id="list<%=id%>" name="list<%=id%>"
						style="margin-left:50px;margin-top:10px;<%=strDisplay%>">
						<td colspan='8'>
							<%
								sql = "select llist.*, isnull(CONVERT(VARCHAR(10),checkDate, 101),'') checkDateStr from tblLogSiteList llist where llist.logID in ("
														+ strLog
														+ ") and approverID="
														+ iApproverID;
												st2 = c.createStatement();
												rs2 = st2.executeQuery(sql);
							%>

							<table style="margin-left: 60px" border="0" cellspacing='5'
								style="background-color:#DDDDDD;text-align:left;border-collapse: collapse;  font-family:Courier New; font-size:10pt">
								<tr style="color: #ffffff; background-color: #000088">
									<th align="center" width="300px"><u>Item</u></th>
									<th align="center" title="">Required</u></th>
									<th align="center">Comment</th>
								</tr>
								<%
									int subItemCnt = 0;
													while (rs2.next()) {
														String lstRequiredStr = rs2
																.getString("requiredString");
														long lslID = rs2.getLong("ID");
														boolean isRequired = rs2
																.getBoolean("isRequired");

														String lslCheckedBy = rs2.getString("byWho");
														String strIsSubCat = rs2.getString("isSubCat") == null
																? "N"
																: rs2.getString("isSubCat");
														String strSiteListComment = rs2
																.getString("comment") == null
																? ""
																: rs2.getString("comment");
														strSiteListComment = strSiteListComment
																.replace("\"", "&quot;");
														String lslCheckDate = rs2
																.getString("checkDateStr");

														String lslTitle = lslCheckedBy + ":"
																+ lslCheckDate;
														String strCheckStatus = isRequired
																? "checked"
																: "";
														String strHidden = isRequired
																? "visible"
																: "hidden";

														if (strIsSubCat.equals("Y"))
															lstRequiredStr = "<span class='listInfo'>"
																	+ lstRequiredStr + "</span>";
														else
															subItemCnt++;
								%>
								<tr>
									<td align="left" width="300px"
										style="border-bottom-style: solid; border-color: #eeeeee; border-bottom-width: 1px;">
										<%=lstRequiredStr%>
									</td>
									<td align="center">
										<%
											if (!strIsSubCat.equals("Y")) {
										%> <input style="visibility: visible" type="checkbox"
										id="SiteControlLslBox_<%=id%>_<%=subItemCnt%>"
										<%=strCheckStatus%> title="<%=lslTitle%>"
										<%=strHasFollowupBoxEnabled%>
										onclick="handle_lsl('SiteControlLslBox_<%=id%>_<%=subItemCnt%>',<%=lslID%>,<%=iApproverID%>,<%=id%>,<%=subItemCnt%>);">
										<%
											} else {
										%> &nbsp; <%
 	}
 %>
									</td>
									<td>
										<%
											if (!strIsSubCat.equals("Y")) {
										%> <textarea class=""
											style="width:300px;visibility:<%=strHidden%>"
											id="SiteListComment_<%=id%>_<%=subItemCnt%>"
											onchange="handle_lsl_comment('SiteListComment_<%=id%>_<%=subItemCnt%>',<%=lslID%>,<%=iApproverID%>,<%=id%>,<%=subItemCnt%>);"
											title="<%=strSiteListComment%>" <%=strFollowupReadOnly%>><%=strSiteListComment%></textarea>
										<%
											} else {
										%> &nbsp; <%
 	}
 %>
									</td>
								</tr>
								<%
									}
								%>
								<tr style="display: none">
									<td><input type="hidden" name="subItemCnt_<%=id%>"
										id="subItemCnt_<%=id%>" value="<%=subItemCnt%>"></td>
								</tr>
								<%
									rs2.close();
													st2.close();
								%>
							</table>
						</td>
					</tr>
					<!-- end of list-->


					<%
						}
					%>
				</table>
			</div>
		</div>
		<%
			}//end
		%>





		<div id="finalapproval">
			<span
				style="font-size: 12pt; background-color: #ffff00; font-weight: bold">FINAL
				AUTHORIZATION</span><br />
			<div style="font-size: 10pt; width: 95%; border: black 2px solid;">
				<table border="0" style="font-size: 10pt;">
					<tr style="vertical-align: top;">
						<th nowrap>HS&E Department Leader:</th>
						<td nowrap>
							<%
								st = c.createStatement();
										sql = "select *,isnull(CONVERT(VARCHAR(10),checkDate, 101),'') checkDateStr from tblOwnerAllSignature where logID in ("
												+ strLog + ")";
										rs = st.executeQuery(sql);
										while (rs.next()) {
											int iid = rs.getInt("id");
											boolean bIsSigned = rs.getBoolean("isChecked");
											String strApproverAccount = rs
													.getString("approverAccount");
											String strApproverName = rs.getString("approverName");
											String strCheckedBy = rs.getString("byWho");
											String strSigned = bIsSigned ? " checked " : "";

											String signatureFilePath = application.getRealPath("/")
													+ "images\\Signatures\\";
											File signatureFile = new File(signatureFilePath
													+ strCheckedBy + ".jpg");
											boolean bSignatureExist = signatureFile.exists();
											String strSignaturePicture = bSignatureExist
													? "<img class='signature' src='./images/Signatures/"
															+ strCheckedBy
															+ ".jpg' alt='"
															+ strCheckedBy + "'>"
													: strCheckedBy;

											String strSignature = bIsSigned
													? strSignaturePicture
													: "&nbsp;";
											String strTitle = strCheckedBy + ":"
													+ rs.getString("checkDateStr");

											boolean bIsOwner = strApproverAccount.trim().equals("")
													|| (strApproverAccount.trim() + ";")
															.indexOf(strCurLogin + ";") > -1;

											boolean bSignBoxEnabled = bIsOwner && !bIsSigned
													&& !bIsLogCancelled && !bIsLogRejected;
											bSignBoxEnabled = bSignBoxEnabled || bIsSysadmin
													|| bIsDirector;

											String strEnabled = bSignBoxEnabled ? "" : "disabled";
											String strSignDate = bIsSigned ? rs
													.getString("checkDateStr") : "&nbsp;";
							%> <span
							style="display: inline-block; width: 150px; border-bottom: thin solid #cccccc; overflow: hidden;"><%=strApproverName%></span>
							<span style="display: inline-block; width: 30px;"><input
								class="approveBox" type='checkbox'
								name='ownerAllSignatureBox<%=iid%>'
								id='ownerAllSignatureBox<%=iid%>' value='<%=iid%>'
								<%=strSigned%> title='<%=strTitle%>'
								onclick="ownerAllSign('ownerAllSignatureBox<%=iid%>','ownerAllSignaturePanel<%=iid%>');"
								<%=strEnabled%>> </span> <span
							id='ownerAllSignaturePanel<%=iid%>'
							style="border-bottom: 1px solid #cccccc; display: inline-block; width: 100px;"><%=strSignature%></span>
							<span id='ownerAllDatePanel<%=iid%>'
							style="border-bottom: 1px solid #cccccc; display: inline-block; width: 100px;"><%=strSignDate%></span><br />
							<%
								}
							%> <span
							style="display: inline-block; width: 150px; overflow: hidden;">FOR
								ALL CHANGES</span> <span style="display: inline-block; width: 30px;">&nbsp;</span>
							<span style="display: inline-block; width: 100px;">Signature</span>
							<span style="display: inline-block; width: 100px;">Date</span>

						</td>
					</tr>
				</table style="font-size:10pt;">

				<%
					//System.out.println(strApprovalStatus);
							String strDisabled = (bCanApprove || bIsCreator)
									&& (!"Cancelled".equals(strApprovalStatus))
									? ""
									: "disabled";
							//String strDisabled = bCanApprove || (bIsCreator && bIsLogApproved) ? "" : "disabled";
							String strApprovalStatusTitle = strApprovedBy + ":"
									+ strApprovedDate;
				%>
				<table border="0"
					style="font-size: 10pt; text-align: left; background-color: #b0b0b0;">
					<tr style="vertical-align: top;">
						<th style="color: #ff4000"><span
							title="<%=strApprovalStatusTitle%>">Change Request Status:</span></th>
						<td><span style="vertical-align: top"
							id="statusSelectContainer" name="statusSelectContainer"> <select
								style="width: 100px;" <%=strDisabled%> id="approvalStatus"
								name="approvalStatus"
								onchange="processStatusChange('approvalStatus');">
									<%
										st = c.createStatement();
												sql = "select * from tblApprovalStatus where hidden<>'Y' or hidden is null";
												rs = st.executeQuery(sql);
												int selectIndex = -1;
												int si = -1;
												while (rs.next()) {
													int iID = rs.getInt("approvalStatusID");
													String strApprovalStatusTemp = rs
															.getString("approvalStatus");
													String strSelectedTemp = (iID == iApprovalStatusID
															? " selected "
															: "");
									%>
									<option value="<%=iID%>" <%=strSelectedTemp%>><%=strApprovalStatusTemp%></option>
									<%
										si++;
													selectIndex = (iID == iApprovalStatusID)
															? si
															: selectIndex;
												}
									%>
							</select> <input type="hidden" name="selIndex" id="selIndex"
								value="<%=selectIndex%>">
						</span>
							<div id="logStatcommentContainter"
								name="logsStatcommentContainter"
								style="z-index: 1000; position: absolute; width: 300px; display: none;">
								<table
									style="border: 2px double #0000ff; border-collapse: collapse;">
									<tr>
										<td
											style="background-color: #0000ff; color: #ffffff; text-align: center">Status
											Comment</td>
									</tr>
									<tr>
										<td style="padding: 2px"><textarea class=""
												id="finalComment" name="finalComment"
												style="padding: 2px; border: 1px solid #444444; width: 300px; height: 60px"><%=strStatusComment%></textarea></td>
									</tr>
									<tr>
										<td style="text-align: center"><input type="button"
											title="Click to finalize the status change"
											name="btnStatCommentSave" id="btnStatCommentSave"
											value="Proceed"
											onclick="handleApprovalStatusOk('approvalStatus');">
											<input type="button" name="btnStatCommentCancel"
											id="btnStatCommentCancel" value="Cancel"
											onclick="handleApprovalStatusCancel('approvalStatus');"></td>
									</tr>
								</table>
							</div></td>
						<td nowrap><b>Comment: </b> <span
							id="requestStatCommentPanel" name="requestStatCommentPanel"
							style="display: inline-block; width: 400px;"><%=strStatusComment%></span>
						</td>
					</tr>
				</table>

			</div>
		</div>
		<script type="text/javascript">
		 var signatureArray=new Array();
	     var hasFollowupArray=new Array();
 		 var followupSignatureArray=new Array();
		 var teamSignatureArray=new Array();

		 var lineTeamSignatureArray=new Array();
  <%for (int i = 0; i < signatureArray.size(); i++) {
						out.println("signatureArray[" + i + "]='"
								+ (String) signatureArray.get(i) + "';");
					}
					for (int i = 0; i < hasFollowupArray.size(); i++) {
						out.println("hasFollowupArray[" + i + "]='"
								+ (String) hasFollowupArray.get(i) + "';");
					}
					for (int i = 0; i < followupSignatureArray.size(); i++) {
						out.println("followupSignatureArray[" + i + "]='"
								+ (String) followupSignatureArray.get(i) + "';");
					}
					for (int i = 0; i < teamSignatureArray.size(); i++) {
						out.println("teamSignatureArray[" + i + "]='"
								+ (String) teamSignatureArray.get(i) + "';");
					}

					for (int i = 0; i < lineTeamSignatureArray.size(); i++) {
						out.println("lineTeamSignatureArray[" + i + "]='"
								+ (String) lineTeamSignatureArray.get(i) + "';");
					}%>
	</script>
		<%
			}
		%>
	</form>
</body>
</html>
<%
	} catch (Exception e) {
		out.println(e);
	} finally {
		DBHelper.closeResultset(rs);
		DBHelper.closeStatement(st);
		DBHelper.closeResultset(rs2);
		DBHelper.closeStatement(st2);
		DBHelper.closeResultset(rs3);
		DBHelper.closeStatement(st3);
		DBHelper.closeConnection(c);

	}
%>

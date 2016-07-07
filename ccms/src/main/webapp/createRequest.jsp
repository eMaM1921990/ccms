<%@page contentType="text/html; charset=ISO-8859-6"%>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@page import="java.io.File"%>
<%@page import="java.util.*"%>
<%@ include file="inc.jsp"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.util.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	PreparedStatement pstmt2 = null;
	ResultSet rs = null;
	String sql = "";
	String strClass = "";
	try {
		c = DBHelper.getConnection();
%>

<html>
<head>
<title>New Request</title>
<script language="javascript" type="text/javascript"
	src="datetimepicker.js"></script>
<script language="javascript" type="text/javascript" src="jsHelper.js"></script>
<script language="javascript" type="text/javascript"
	src="createRequest.js?v=30"></script>
<link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
</head>

<body style="margin-left: 5%;">

	<%
		String strErrorMsg = "<font color='#ff0000'>(*)</font>";

			String strPageAction = "";
			boolean isMissing = false;
			String strIsSafety = "N";
			String strIsEmergency = "N";
			String strOriginator = strCurUserName;
			boolean bOriginator = false;
			String strCreatorTeam = "";
			boolean bCreatorTeam = false;
			String strArea = "";
			boolean bArea = false;
			String strAreaName = "";
			String strLine = "";
			boolean bLine = false;
			String strLineName = "";
			String strEquipment = "";
			boolean bEquipment = false;
			String strOtherEquipment = "";
			String strReApp = "";
			boolean bReApp = false;
			String strReAppFrom = "";
			String strCreatorPhone = "";
			boolean bPhone = false;
			String strStartDate = "";
			boolean bStartDate = false;
			String strEndDate = "";
			boolean bEndDate = false;
			String strCost = "";
			boolean bCost = false;
			double dblCost = 0.0;
			String strType = "";
			boolean bType = false;
			String strDesc = "";
			boolean bDesc = false;
			String strReason = "";
			boolean bReason = false;
			
			String q1_selection="";
			boolean bq1_selection= false;
			String q1_answer="";
			boolean bq1_answer=false;
			
			String q2_selection="";
			boolean bq2_selection= false;
			String q2_answer="";
			boolean bq2_answer=false;
			
			String q3_selection="";
			boolean bq3_selection= false;
			String q3_answer="";
			boolean bq3_answer=false;
			
			String q4_selection="";
			boolean bq4_selection= false;
			String q4_answer="";
			boolean bq4_answer=false;
			
			String q5_selection="";
			boolean bq5_selection= false;
			String q5_answer="";
			boolean bq5_answer=false;
			
			String q6_selection="";
			boolean bq6_selection= false;
			String q6_answer="";
			boolean bq6_answer=false;
			
			String q7_selection="";
			boolean bq7_selection= false;
			String q7_answer="";
			boolean bq7_answer=false;
			
			String q8_selection="";
			boolean bq8_selection= false;
			String q8_answer="";
			boolean bq8_answer=false;
			
			String q9_selection="";
			boolean bq9_selection= false;
			String q9_answer="";
			boolean bq9_answer=false;
			
			String q10_selection="";
			boolean bq10_selection= false;
			String q10_answer="";
			boolean bq10_answer=false;
			
			String q11_selection="";
			boolean bq11_selection= false;
			String q11_answer="";
			boolean bq11_answer=false;
			
			String q12_selection="";
			boolean bq12_selection= false;
			String q12_answer="";
			boolean bq12_answer=false;
			
			String q13_selection="";
			boolean bq13_selection= false;
			String q13_answer="";
			boolean bq13_answer=false;
			
			String tor_selection="";
			boolean btor_selecton=false;
			
			boolean bRenderPage = true;

			boolean isMultipart = ServletFileUpload
					.isMultipartContent(request);

			if (isMultipart) { //form is submitted
				//DBHelper.log(null,strCurLogin,"createRequest_LT.jsp submitted.");
				ServletFileUpload upload = new ServletFileUpload(
						new DiskFileItemFactory());
				List fileItemsList = upload.parseRequest(request);
				Iterator iter = fileItemsList.iterator();

				while (iter.hasNext()) {
					FileItem item = (FileItem) iter.next();
					String fieldName = item.getFieldName();
					if (item.isFormField()) {
						String strFieldValue = item.getString("ISO-8859-6");
						if (fieldName.equals("safety"))
							strIsSafety = strFieldValue == null
									? "N"
									: strFieldValue;
						else if (fieldName.equals("emergency"))
							strIsEmergency = strFieldValue == null
									? "N"
									: strFieldValue;
						else if (fieldName.equals("originator"))
							strOriginator = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("creatorteam"))
							strCreatorTeam = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("area"))
							strArea = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("line"))
							strLine = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("areaName"))
							strAreaName = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("lineName"))
							strLineName = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("equipment"))
							strEquipment = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("otherEquipment"))
							strOtherEquipment = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("reapp"))
							strReApp = strFieldValue == null
									? "N"
									: strFieldValue;
						else if (fieldName.equals("reappFrom"))
							strReAppFrom = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("sdate"))
							strStartDate = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("edate"))
							strEndDate = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("cost"))
							strCost = strFieldValue == null
									|| strFieldValue.trim().equals("")
									? "0"
									: strFieldValue;
						else if (fieldName.equals("type"))
							strType = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("description"))
							strDesc = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("phone"))
							strCreatorPhone = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("reason"))
							strReason = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("pageAction"))
							strPageAction = strFieldValue == null
									? ""
									: strFieldValue;
						else if (fieldName.equals("q1"))
							q1_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q1_ans"))
							q1_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q2"))
							q2_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q2_ans"))
							q2_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q3"))
							q3_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q3_ans"))
							q3_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q4"))
							q4_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q4_ans"))
							q4_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q5"))
							q5_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q5_ans"))
							q5_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q6"))
							q6_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q6_ans"))
							q6_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q7"))
							q7_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q7_ans"))
							q7_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q8"))
							q8_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q8_ans"))
							q8_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q9"))
							q9_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q9_ans"))
							q9_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q10"))
							q10_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q10_ans"))
							q10_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q11"))
							q11_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q11_ans"))
							q11_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q12"))
							q12_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q12_ans"))
							q12_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q13"))
							q13_selection=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("q13_ans"))
							q13_answer=strFieldValue==null?""
									:strFieldValue;
						
						else if (fieldName.equals("TOR"))
							tor_selection=strFieldValue==null?""
									:strFieldValue;
							
					} //end of if (formField)
				}//end of while , 

				if (strOriginator.trim().equals("")) {
					isMissing = true;
					bOriginator = true;
				}
				if (strCreatorTeam.trim().equals("")) {
					isMissing = true;
					bCreatorTeam = true;
				}
				if (strArea.equals("")) {
					isMissing = true;
					bArea = true;
				}
				if (strLine.equals("")) {
					isMissing = true;
					bLine = true;
				}
				if (strEquipment.equals("")) {
					isMissing = true;
					bEquipment = true;
				}
				if (strCreatorPhone.equals("")) {
					isMissing = true;
					bPhone = true;
				}
				if (!strReApp.equals("Y") && !strReApp.equals("N")) {
					isMissing = true;
					bReApp = true;
				}
				if (strStartDate.trim().equals("")) {
					isMissing = true;
					bStartDate = true;
				}
				if (strEndDate.trim().equals("")) {
					isMissing = true;
					bEndDate = true;
				}
				if (!bStartDate && !bEndDate) { //both dates are set
					long d1 = 0;
					long d2 = 0;
					try {
						d1 = new SimpleDateFormat("MM/dd/yyyy").parse(
								strStartDate).getTime();
					} catch (Exception fe) {
						isMissing = true;
						bStartDate = true;
					}

					try {
						d2 = new SimpleDateFormat("MM/dd/yyyy").parse(
								strEndDate).getTime();
					} catch (Exception fe) {
						isMissing = true;
						bEndDate = true;
					}

					if (!bStartDate && !bEndDate && d1 > d2) {
						isMissing = true;
						bStartDate = true;
						bEndDate = true;
					}
				}
				if (strType.equals("")) {
					isMissing = true;
					bType = true;
				}
				try {
					dblCost = Double.parseDouble(strCost);
				} catch (Exception e) {
					isMissing = true;
					bCost = true;
				}

				if (strDesc.trim().equals("")) {
					isMissing = true;
					bDesc = true;
				}
				if (strReason.trim().equals("")) {
					isMissing = true;
					bReason = true;
				}

				if (strDesc.length() > 1000)
					strDesc = strDesc.substring(0, 1000);
				if (strReason.length() > 1000)
					strReason = strReason.substring(0, 1000);
				if (strReAppFrom.length() > 50)
					strReAppFrom = strReAppFrom.substring(0, 50);
				// Process the attachments after we processed the form fields.
				if (!isMissing) {
					int key = -999;
					String ownerName = "";
					String ownerEmail = "";

					int pendingID = -9999;
					boolean bHasPendingID = false;
					sql = "select * from tblApprovalStatus where upper(approvalstatus)='PENDING' and (hidden<>'Y' or hidden is null)";
					st = c.createStatement();
					rs = st.executeQuery(sql);
					if (rs.next()) {
						pendingID = rs.getInt("approvalStatusId");
						bHasPendingID = true;
					}
					if (!bHasPendingID) {
						throw new Exception("Pending status is not defined");
					}

					sql = "insert into tblChangeControlLog (requestDate,originator,AreaID,LineID, EquipmentID, IsReApplication,ReApp,startTiming, endTiming,cost,";
					sql += "CostType,changeDesc,changeReason,approvalStatusID,approvalDate,IsPrinted,OtherEquipment,Cost2,IsSafety,IsEmergency,creator,creatorEmail,take2site,approvedBy,approvedDate,areaNames,lineNames,statuscomment,hidden,notified,creatorteam,creatorPhone,"+
							"Q1_SELECTION,Q1_ANS,Q2_SELECTION,Q2_ANS,Q3_SELECTION,Q3_ANS,Q4_SELECTION,Q4_ANS,Q5_SELECTION,Q5_ANS,Q6_SELECTION,Q6_ANS,Q7_SELECTION,Q7_ANS,"+
							"Q8_SELECTION,Q8_ANS,Q9_SELECTION,Q9_ANS,Q10_SELECTION,Q10_ANS,Q11_SELECTION,Q11_ANS,Q12_SELECTION,Q12_ANS,Q13_SELECTION,Q13_ANS,TOR_SELECTION) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
					
					System.out.println("Selection of Request :"+tor_selection);
					pstmt = c.prepareStatement(sql,
							Statement.RETURN_GENERATED_KEYS);
					pstmt.setTimestamp(1, new java.sql.Timestamp(
							new java.util.Date().getTime()));
					pstmt.setString(2, strOriginator);
					pstmt.setString(3, strArea);
					pstmt.setString(4, strLine);
					pstmt.setInt(5, Integer.parseInt(strEquipment));
					pstmt.setBoolean(6, strReApp.equals("Y"));
					pstmt.setString(7, strReAppFrom);
					pstmt.setDate(8,
							new java.sql.Date(new SimpleDateFormat(
									"MM/dd/yyyy").parse(strStartDate)
									.getTime()));
					pstmt.setDate(9,
							new java.sql.Date(new SimpleDateFormat(
									"MM/dd/yyyy").parse(strEndDate)
									.getTime()));
					pstmt.setDouble(10, dblCost);
					pstmt.setString(11, strType);
					pstmt.setString(12, strDesc);
					pstmt.setString(13, strReason);
					pstmt.setInt(14, pendingID); //approvalStatus pending
					pstmt.setDate(15, null);//aproval date
					pstmt.setBoolean(16, false);//printed
					pstmt.setString(17, strOtherEquipment);
					pstmt.setString(18, strCost);
					pstmt.setBoolean(19, strIsSafety.equals("Y"));
					pstmt.setBoolean(20, strIsEmergency.equals("Y"));
					pstmt.setString(21,
							(String) (session.getAttribute("user")));
					pstmt.setString(22,
							(String) (session.getAttribute("email")));
					pstmt.setBoolean(23, true); // Site Approvals
					pstmt.setString(24, "");
					pstmt.setDate(25, null);
					pstmt.setString(26, strAreaName);
					pstmt.setString(27, strLineName);
					pstmt.setString(28, "");
					pstmt.setString(29, "N");
					pstmt.setInt(30, 0);
					pstmt.setString(31, strCreatorTeam);
					pstmt.setString(32, strCreatorPhone);
					pstmt.setString(33, q1_selection);
					pstmt.setString(34, q1_answer);
					pstmt.setString(35, q2_selection);
					pstmt.setString(36, q2_answer);
					pstmt.setString(37, q3_selection);
					pstmt.setString(38, q3_answer);
					pstmt.setString(39, q4_selection);
					pstmt.setString(40, q4_answer);
					pstmt.setString(41, q5_selection);
					pstmt.setString(42, q5_answer);
					pstmt.setString(43, q6_selection);
					pstmt.setString(44, q6_answer);
					pstmt.setString(45, q7_selection);
					pstmt.setString(46, q7_answer);
					pstmt.setString(47, q8_selection);
					pstmt.setString(48, q8_answer);
					pstmt.setString(49, q9_selection);
					pstmt.setString(50, q9_answer);
					pstmt.setString(51, q10_selection);
					pstmt.setString(52, q10_answer);
					pstmt.setString(53, q11_selection);
					pstmt.setString(54, q11_answer);
					pstmt.setString(55, q12_selection);
					pstmt.setString(56, q12_answer);
					pstmt.setString(57, q13_selection);
					pstmt.setString(58, q13_answer);
					pstmt.setString(59, tor_selection);
					int ret = pstmt.executeUpdate();
					rs = pstmt.getGeneratedKeys();
					if (rs != null && rs.next()) {
						key = rs.getInt(1);
					}
					DBHelper.closeStatement(pstmt);
					if (key < 0) {
						throw new Exception(
								"Can not generate a log# for this request.");
					}
					//  System.out.println("------insert into log----");

					//sql="select teamID from tblTeams where charindex(','+cast(areaID as varchar)+',',"+","+strArea+",)>0";

					sql = "select * from tblLine where lineid in ("
							+ strLine
							+ ") and (hidden is null or hidden<>'Y')";
					st = c.createStatement();
					rs = st.executeQuery(sql);
					String newLineIds = "";
					String allAreaIds = "";
					while (rs.next()) {
						int aLineId = rs.getInt("lineId");
						int aAreaId = rs.getInt("areaId");
						String aLine = rs.getString("lineName");
						if (aLine.trim().toUpperCase().startsWith("ALL"))
							allAreaIds += aAreaId + ",";
						else
							newLineIds += aLineId + ",";
					}
					allAreaIds = allAreaIds.length() > 0
							? allAreaIds.substring(0,
									allAreaIds.length() - 1) : allAreaIds;

					if (allAreaIds.length() > 0) {
						sql = "select * from tblLine where areaId in ("
								+ allAreaIds
								+ ") and (hidden is null or hidden<>'Y')";
						st = c.createStatement();
						rs = st.executeQuery(sql);
						while (rs.next()) {
							int aLineId = rs.getInt("lineId");
							newLineIds += aLineId + ",";
						}
					}
					newLineIds = newLineIds.length() > 0
							? newLineIds.substring(0,
									newLineIds.length() - 1) : newLineIds;

					String deptIdHasLineTeam = "";
					if (newLineIds.length() > 0) { // 

						sql = "insert into tblLineTeamReview(LogID,lineTeamid,approved,rejected,name,email,acct,byWho) values (?,?,?,?,?,?,?,?)";
						pstmt = c.prepareStatement(sql);

						sql = "select distinct LT.* from tblLineTeam LT,tblLine L where charindex(','+convert(varchar(10),L.lineid)+',' ,  ','+LT.lineids+',')>0 and L.lineid in ("
								+ newLineIds
								+ ") order by LT.deptid, LT.lineTeam";

						rs = st.executeQuery(sql);
						while (rs.next()) {
							int lineTeamId = rs.getInt("id");
							int deptId = rs.getInt("deptId");
							deptIdHasLineTeam += deptId + ",";
							String strLineTeam = rs.getString("lineteam");
							String strName = rs.getString("name");
							String strEmail = rs.getString("email");
							String strAcct = rs.getString("acct");
							strEmail = strEmail.replace(",", ";"); //replace , with ;

							pstmt.setInt(1, key);
							pstmt.setInt(2, lineTeamId);
							pstmt.setString(3, "N");
							pstmt.setString(4, "N");
							pstmt.setString(5, strName);
							pstmt.setString(6, strEmail);
							pstmt.setString(7, strAcct);
							pstmt.setString(8, "");
							pstmt.executeUpdate();
						}
						DBHelper.closeStatement(pstmt);
					}
					deptIdHasLineTeam = deptIdHasLineTeam.length() > 0
							? deptIdHasLineTeam.substring(0,
									deptIdHasLineTeam.length() - 1)
							: deptIdHasLineTeam;

					//insert into team review now use teams for the rest of the areas
					String sqlInsert = "insert into tblTeamReview(LogID,TeamID,checked,rejected,reviewer,reviewerEmail,byWho,checkDate,teamName) values (?,?,?,?,?,?,?,?,?)";
					pstmt = c.prepareStatement(sqlInsert);

					sql = "select teamId, isnull(team,'') team, isnull(reviewer,'') reviewer,isnull(reviewerEmail,'') reviewerEmail from tblTeams where (hidden<>'Y' or hidden is null ) and areaID in ("
							+ strArea + ") ";
					sql += deptIdHasLineTeam.length() > 0
							? " and areaId not in(" + deptIdHasLineTeam
									+ ")"
							: "";
					sql += " order by areaId,sortorder";

					st = c.createStatement();
					rs = st.executeQuery(sql);
					while (rs.next()) {
						int id = rs.getInt("teamID");
						String strTeamName = rs.getString("team");
						String strReviewer = rs.getString("reviewer");
						String strReviewerEmail = rs
								.getString("reviewerEmail");
						strReviewer = strReviewer.replace(",", ";"); //replace , with ;
						strReviewerEmail = strReviewerEmail.replace(",",
								";"); //replace , with ;

						pstmt.setInt(1, key);
						pstmt.setInt(2, id);
						pstmt.setBoolean(3, false);
						pstmt.setBoolean(4, false);
						pstmt.setString(5, strReviewer);
						pstmt.setString(6, strReviewerEmail);
						pstmt.setString(7, "");
						pstmt.setTimestamp(8, null);
						pstmt.setString(9, strTeamName);
						pstmt.executeUpdate();
					}

					//    System.out.println("------insert into team review----");
					//insert blank signature  rows

					sqlInsert = "insert into tblApprovalSignature(LogID,approverID,ApproverType,ApproverName,ApproverAccout,ApproverEmail, isChecked,rejected,byWho,checkDate,hasFollowup,followup,isFollowupChecked, followupByWho,followupCheckdate) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"; //approverID is null for non site request
					pstmt = c.prepareStatement(sqlInsert);

					// added by Wenhu Tian, Nov. 4 2008
					//add line owner and equipment owner into the approval section
					//line owner info is from tblLine, equipment owner info is from tblEquipmentowner

					sql = "select l.* from tblLine l where (l.hidden<>'Y' or l.hidden is null) and l.lineid in ("
							+ strLine + ")";
					st = c.createStatement();
					rs = st.executeQuery(sql);
					String strLineOwnerName = "";
					String strLineOwnerAccount = "";
					String strLineOwnerEmail = "";
					int iLineId = -999;

					while (rs.next()) {
						iLineId = rs.getInt("lineId");
						strLineOwnerName = rs.getString("ownername") == null
								? ""
								: rs.getString("ownername");
						strLineOwnerAccount = rs.getString("owneraccount") == null
								? ""
								: rs.getString("owneraccount");
						strLineOwnerEmail = rs.getString("owneremail") == null
								? ""
								: rs.getString("owneremail");

						if (!strLineOwnerName.trim().equals("")) {
							pstmt.setInt(1, key);
							pstmt.setInt(2, -iLineId); //approverID ='-LineId' if area is not site
							pstmt.setString(3, "Line Leader");
							pstmt.setString(4, strLineOwnerName);
							pstmt.setString(5, strLineOwnerAccount);
							pstmt.setString(6, strLineOwnerEmail);
							pstmt.setBoolean(7, false);
							pstmt.setBoolean(8, false);
							pstmt.setString(9, "");
							pstmt.setTimestamp(10, null);
							pstmt.setBoolean(11, false);
							pstmt.setString(12, "");
							pstmt.setBoolean(13, false);
							pstmt.setString(14, "");
							pstmt.setTimestamp(15, null);
							pstmt.executeUpdate();
						}
					}
					sql = "select e.* from tblEquipmentOwner e where (e.hidden<>'Y' or e.hidden is null) and e.equipmentid="
							+ strEquipment
							+ " and e.areaid in ("
							+ strArea
							+ ") and e.lineid in (" + strLine + ")";
					st = c.createStatement();
					rs = st.executeQuery(sql);

					String strEquipmentOwnerName = "";
					String strEquipmentOwnerAccount = "";
					String strEquipmentOwnerEmail = "";
					int iEquipmentOwnerId = -999;
					while (rs.next()) {
						iEquipmentOwnerId = rs.getInt("id");
						strEquipmentOwnerName = rs.getString("ownername") == null
								? ""
								: rs.getString("ownername");
						strEquipmentOwnerAccount = rs
								.getString("owneraccount") == null
								? ""
								: rs.getString("owneraccount");
						strEquipmentOwnerEmail = rs.getString("owneremail") == null
								? ""
								: rs.getString("owneremail");
						if (!strEquipmentOwnerName.trim().equals("")) {
							pstmt.setInt(1, key);
							pstmt.setInt(2, -iEquipmentOwnerId); //approverID ='' if area is not site
							pstmt.setString(3, "Equipment Owner");
							pstmt.setString(4, strEquipmentOwnerName);
							pstmt.setString(5, strEquipmentOwnerAccount);
							pstmt.setString(6, strEquipmentOwnerEmail);
							pstmt.setBoolean(7, false);
							pstmt.setBoolean(8, false);
							pstmt.setString(9, "");
							pstmt.setTimestamp(10, null);
							pstmt.setBoolean(11, false);
							pstmt.setString(12, "");
							pstmt.setBoolean(13, false);
							pstmt.setString(14, "");
							pstmt.setTimestamp(15, null);
							pstmt.executeUpdate();
						}
					}
					//dept approver
					sql = "select approverID newApproverID, approverType, ApproverAccout,approverName,approverEmail from  tblApprovers where areaID in ("
							+ strArea
							+ ") and hidden<>'Y' and areaID not in (select areaId from tblArea where areaname='Site') ";
					boolean isMultipleAreas = strArea.indexOf(",") > -1;
					if (isMultipleAreas)
						sql += "order by approverType";
					else
						sql += "order by sortorder";

					st = c.createStatement();
					rs = st.executeQuery(sql);
					while (rs.next()) {
						pstmt.setInt(1, key);
						pstmt.setInt(2, rs.getInt("newApproverID")); //approverID ='' if area is not site
						pstmt.setString(3, rs.getString("ApproverType"));
						pstmt.setString(4, rs.getString("ApproverName"));
						pstmt.setString(5, rs.getString("ApproverAccout"));
						pstmt.setString(6, rs.getString("approverEmail"));
						pstmt.setBoolean(7, false);
						pstmt.setBoolean(8, false);
						pstmt.setString(9, "");
						pstmt.setTimestamp(10, null);
						pstmt.setBoolean(11, false);
						pstmt.setString(12, "");
						pstmt.setBoolean(13, false);
						pstmt.setString(14, "");
						pstmt.setTimestamp(15, null);
						pstmt.executeUpdate();
					}
					//site approvers
					sql = "select  approverID newApproverID, approverType, ApproverAccout,approverName,approverEmail from  tblApprovers where areaID in ("
							+ strArea
							+ ") and hidden<>'Y' and areaID in (select areaId from tblArea where areaname='Site') and approverID IN (SELECT ApprovalID FROM tblApprovalGroup WHERE ApprovalGroupRequest='"+tor_selection+"' AND AreaID='"+strArea+"') order by sortorder";

					st = c.createStatement();
					rs = st.executeQuery(sql);
					while (rs.next()) {
						pstmt.setInt(1, key);
						pstmt.setInt(2, rs.getInt("newApproverID")); //approverID ='' if area is not site
						pstmt.setString(3, rs.getString("ApproverType"));
						pstmt.setString(4, rs.getString("ApproverName"));
						pstmt.setString(5, rs.getString("ApproverAccout"));
						pstmt.setString(6, rs.getString("approverEmail"));
						pstmt.setBoolean(7, false);
						pstmt.setBoolean(8, false);
						pstmt.setString(9, "");
						pstmt.setTimestamp(10, null);
						pstmt.setBoolean(11, false);
						pstmt.setString(12, "");
						pstmt.setBoolean(13, false);
						pstmt.setString(14, "");
						pstmt.setTimestamp(15, null);
						pstmt.executeUpdate();
					}
					DBHelper.closeStatement(pstmt);

					//   System.out.println("------insert into approvers----");

					//insert owner signature
					sqlInsert = "insert into tblOwnerSignature(logID, areaID,approverName,approverAccount,approverEmail,isChecked, byWho, checkDate) values (?,?,?,?,?,?,?,?)";

					pstmt = c.prepareStatement(sqlInsert);

					sql = "select distinct (case when areaID<>11 then -999 else areaID end) newAreaID, ChangeOwnerAccount,ChangeOwnerName,changeownerEmail from tblAreaOwners where areaID in ("
							+ strArea + ")";
					st = c.createStatement();
					rs = st.executeQuery(sql);

					while (rs.next()) {
						int t_id = rs.getInt("newAreaID");
						String t_OwnerName = rs
								.getString("ChangeOwnerName") == null
								? ""
								: rs.getString("ChangeOwnerName");
						String t_OwnerAcct = rs
								.getString("ChangeOwnerAccount") == null
								? ""
								: rs.getString("ChangeOwnerAccount");
						String t_OwnerEmail = rs
								.getString("ChangeOwnerEmail") == null
								? ""
								: rs.getString("ChangeOwnerEmail");

						ownerName += t_OwnerName + ";";
						ownerEmail += t_OwnerEmail + ";";

						if (rs.getInt("newAreaID") < 0) {
							pstmt.setInt(1, key);
							pstmt.setInt(2, t_id);
							pstmt.setString(3, t_OwnerName);
							pstmt.setString(4, t_OwnerAcct);
							pstmt.setString(5, t_OwnerEmail);
							pstmt.setBoolean(6, false);
							pstmt.setString(7, "");
							pstmt.setTimestamp(8, null);
							pstmt.executeUpdate();
						}

					}

					String sqlInsert2 = "insert into tblOwnerAllSignature(logID, approverName,approverAccount,approverEmail,isChecked, byWho, checkDate) values (?,?,?,?,?,?,?)";
					pstmt2 = c.prepareStatement(sqlInsert2);

					sql = "SELECT * FROM tblCMSUser WHERE director = 'Y'";
					st = c.createStatement();
					rs = st.executeQuery(sql);

					while (rs.next()) {
						String email = rs.getString("email");
						String acct = rs.getString("account");
						String name = rs.getString("fullName") == null
								? acct
								: rs.getString("fullName");

						pstmt2.setInt(1, key);
						//pstmt2.setInt(2,t_id);
						pstmt2.setString(2, name);
						pstmt2.setString(3, acct);
						pstmt2.setString(4, email);
						pstmt2.setBoolean(5, false);
						pstmt2.setString(6, "");
						pstmt2.setTimestamp(7, null);
						pstmt2.executeUpdate();
					}

					DBHelper.closeStatement(pstmt);

					//  System.out.println("------insert into owner----");

					sqlInsert = "insert into tblLogSiteList(logID, approverID,listID,requiredString, isRequired,byWho, checkDate,comment,isSubCat,type) values (?,?,?,?,?,?,?,?,?,?)";
					pstmt = c.prepareStatement(sqlInsert);
					sql = "select lst.* from tblSiteList lst,tblApprovers appr where (appr.hidden<>'Y' or appr.hidden is null) and (lst.hidden<>'Y' or lst.hidden is null) and lst.approverID=appr.approverID and appr.areaID in ("
							+ strArea
							+ ") order by appr.areaID,lst.sortorder";
					st = c.createStatement();
					rs = st.executeQuery(sql);
					while (rs.next()) {
						pstmt.setInt(1, key);
						pstmt.setInt(2, rs.getInt("approverID"));
						pstmt.setInt(3, rs.getInt("ID"));
						pstmt.setString(4, rs.getString("requiredString"));
						pstmt.setBoolean(5, false);
						pstmt.setString(6, "");
						pstmt.setTimestamp(7, null);
						pstmt.setString(8, "");
						pstmt.setString(9, rs.getString("isSubCat") == null
								? "N"
								: rs.getString("isSubCat"));
						pstmt.setString(10, rs.getString("type") == null
								? "P"
								: rs.getString("type"));
						pstmt.executeUpdate();
					}
					DBHelper.closeStatement(pstmt);

					// now deal with the attachments
					String strContentType = "";
					String strSuffix = "";
					String strDocName = "";
					String strTruncatedName = "";

					try {
						sqlInsert = "insert into tblAttachments(LogID,docName,originalName,docType,docSuffix,byWho,attacheDate,hidden) values (?,?,?,?,?,?,?,?)";
						pstmt = c.prepareStatement(sqlInsert,
								Statement.RETURN_GENERATED_KEYS);

						Iterator it = fileItemsList.iterator();
						while (it.hasNext()) {
							FileItem item = (FileItem) it.next();
							if (!item.isFormField()) {
								String name = item.getName();
								if (name.trim().equals(""))
									continue;
								strContentType = item.getContentType();
								strSuffix = name.lastIndexOf(".") > -1
										? name.substring(name
												.lastIndexOf(".")) : ""; //include '.'
								strDocName = name.lastIndexOf("\\") > -1
										? name.substring(name
												.lastIndexOf("\\") + 1)
										: name; //exclude '\'

								strContentType = strContentType.length() >= 255
										? strContentType.substring(0, 255)
										: strContentType;
								strSuffix = strSuffix.length() >= 50
										? strSuffix.substring(0, 50)
										: strSuffix;
								strDocName = strDocName.length() >= 255
										? strDocName.substring(0, 255)
										: strDocName;
								strTruncatedName = name.length() >= 1000
										? name.substring(0, 1000)
										: name;

								pstmt.setInt(1, key);
								pstmt.setString(2, strDocName);
								pstmt.setString(3, strTruncatedName);
								pstmt.setString(4, strContentType);
								pstmt.setString(5, strSuffix);
								pstmt.setString(6, strCurLogin);
								pstmt.setTimestamp(
										7,
										new java.sql.Timestamp(
												new java.util.Date()
														.getTime()));
								pstmt.setString(8, "N");
								pstmt.executeUpdate();

								rs = pstmt.getGeneratedKeys();

								int fileKey = -1;
								if (rs != null && rs.next())
									fileKey = rs.getInt(1);
								if (fileKey < 0)
									throw new Exception(
											"cannot generate attachment key.");

								String strFileName = key + "_" + fileKey
										+ strSuffix;

								String strFilePath = getServletContext()
										.getRealPath("/")
										+ "Attachments\\"
										+ strFileName;
								item.write(new File(strFilePath));

							} //end of if (Is an form field)
						}//end while
					} catch (Exception errE) {
						//	       DBHelper.sendEMail("brkchangemanagement@pg.com","tian.w.4@pg.com","attachment error",strTruncatedName);
						throw errE;
					}

					//ibrahimah
					sqlInsert = "update tblChangeControlLog set take2Site=1 where logID="
							+ key + " and take2Site <> 1";
					pstmt = c.prepareStatement(sqlInsert);
					pstmt.executeUpdate();
					DBHelper.closeStatement(pstmt);

					sqlInsert = "insert into tblApprovalSignature(logID, approverID,approverType,approverName,approverAccout,approverEmail,isChecked,rejected, byWho, checkDate, hasFollowup,followup,isFollowupChecked,followupByWho,followupCheckDate) ";
					sqlInsert += "select "
							+ key
							+ ", appr.ApproverID, appr.approverType,appr.approverName, approverAccout,approverEmail, 0,0, '', null,0,'',0,'',null from tblApprovers appr where (appr.hidden<>'Y' or appr.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
					sqlInsert += "and (not exists (select logID, ApproverID from tblApprovalSignature where logID= "
							+ key
							+ " and approverID in (select approverID from tblApprovers where areaID=(select areaid from tblArea where areaname='Site')))) order by appr.sortorder";

					pstmt = c.prepareStatement(sqlInsert);
					pstmt.executeUpdate();
					DBHelper.closeStatement(pstmt);

					sqlInsert = "insert into tblLogSiteList(logID,approverID,listID, requiredString,isrequired, byWho,checkDate,comment,issubcat) ";
					sqlInsert += "select "
							+ key
							+ ",sitelist.approverID,sitelist.ID,sitelist.requiredString,0,'',null,'', sitelist.isSubCat from tblSiteList sitelist, tblApprovers appr where sitelist.approverID=appr.ApproverID and (sitelist.hidden<>'Y' or sitelist.hidden is null) and appr.areaID=(select areaid from tblArea where areaname='Site') ";
					sqlInsert += "and sitelist.approverID not in (select approverID from tblLogSiteList where logID="
							+ key
							+ ") order by sitelist.approverID, sitelist.sortorder";

					pstmt = c.prepareStatement(sqlInsert);
					pstmt.executeUpdate();
					DBHelper.closeStatement(pstmt);

					c.commit();
					// c.rollback();
					DBHelper.log(null, strCurLogin, "createRequest3.jsp:"
							+ key);

					String strMsg = "Hello, " + ownerName + "<br/>";
					strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
					if (strIsEmergency.equals("Y")) {
						strMsg += "<p style='color:#ff0000'>IMPORTANT- EMERGENCY CHANGE REQUEST. Review Immediately</p>";
					}
					strMsg += " A new Change Management Request:" + key
							+ " has been generated by <b>" + strOriginator
							+ "</b><br/>";
					strMsg += " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n="
							+ key
							+ "' target='review'>here </a> to view the request.<br/>";
					strMsg += "<br/>Change Description:<br/><div style='border:1px solid #000000;padding:10px;'>"
							+ strDesc + "</div>";
					String strSubject = "New Change Request: " + key;
					if (strIsEmergency.equals("Y")) {
						strSubject = "IMPORTANT - EMERGENCY CHANGE REQUEST: "
								+ key;
					}

					MailSender.sendEMail(DBHelper.getSystemOwnerEmail()
							+ ";" + ownerEmail, strSubject, strMsg);

					String creatorEmail = (String) session
							.getAttribute("email");

					strMsg = "Hello, " + "<br/>";
					strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
					strMsg += " A new Change Management Request:" + key
							+ " has been generated.<br/>";
					strMsg += " A notification message has been sent to department owner.<BR/>";
					strMsg += " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n="
							+ key
							+ "' target='review'>here </a> to view the request.<br/>";
					strMsg += "<br/>Change Description:<br/><div style='border:1px solid #000000;padding:10px;'>"
							+ strDesc + "</div>";
					strSubject = "New Change Request: " + key;

					MailSender.sendEMail(creatorEmail, strSubject, strMsg);

					bRenderPage = false;

					response.sendRedirect("createRequestConfirm.jsp?key="
							+ key + "&ownername=" + ownerName);

				} else { //sth is missing
					bRenderPage = true;
				}
			} //end of if bIsMultiPart
			else {
				bRenderPage = true;
			}

			if (bRenderPage) {
	%>
	<%@ include file="jsInc.jsp"%>

	<form ENCTYPE='multipart/form-data' name="the_form" id="the_form"
		method="post" action="#">
		<div class="title">Create New Change Request</div>

		<p>
			<span style="background-color: #FFFF00; font-weight: bold">This
				is EO/Chemical Clearance:</span><input type='checkbox' value='Y'
				name='safety'
				<%if (strIsSafety.equals("Y"))
						out.print(" checked");%>> <span
				style="margin-left: 20px; background-color: #FFFF00; font-weight: bold">This
				is an emergency change:</span><input type='checkbox' value='Y'
				name='emergency'
				<%if (strIsEmergency.equals("Y"))
						out.print(" checked");%>>
		</p>


		<p>
		<table>
			<tr>
				<td colspan="1"><select id='typeOfRequest' name="TOR">
						<option value="0">Select your request type</option>
						<option value="Building Change/New Building">Building Change/New Building</option>
						<option value="New Mechanical Equipment or Mechanical Change">New Mechanical Equipment or Mechanical Change</option>
						<option value="Only Electrical Change">Only Electrical Change</option>
						<option value="Quality Assurance Change">Quality Assurance Change</option>
						<option value="Technical Packaging Change">Technical Packaging Change</option>
						<option value="New Chemical/Material">New Chemical/Material</option>
						<option value="New EO">New EO</option>
						<option value="Maintenace Activities">Maintenace Activities</option>
						<option value="Site Facility Change">Site Facility Change</option>
						<option value="New Project">New Project</option>
						
				</select></td>
			</tr>
			<tr><td>1.  Is this change in the building ? <b style="color:red">*</b></td><td><input type="radio" name="q1" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q1" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q1_ans" name="q1_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>2.  Is this change in mechanical part.   Line- pump -  fan -  feeder ? <b style="color:red">*</b></td><td><input type="radio" name="q2" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q2" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q2_ans"  name="q2_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>3.  Is this change in dust control system. Enzyme -  agm? <b style="color:red">*</b></td><td><input type="radio" name="q3" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q3" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q3_ans" name="q3_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>4.  Is this change in the existing chemicals? <b style="color:red">*</b></td><td><input type="radio" name="q4" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q4" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q4_ans" name="q4_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>5.  Is this new chemical? <b style="color:red">*</b></td><td><input type="radio" name="q5" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q5" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q5_ans" name="q5_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>6.  Is this change in building structures? <b style="color:red">*</b></td><td><input type="radio" name="q6" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q6" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q6_ans" name="q6_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>7.  Is this new building ? <b style="color:red">*</b></td><td><input type="radio" name="q7" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q7" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q7_ans" name="q7_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>8.  Is this change in sop ? <b style="color:red">*</b></td><td><input type="radio" name="q8" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q8" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q8_ans" name="q8_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>9. Is this change in the existing traffic system ? <b style="color:red">*</b></td><td><input type="radio" name="q9" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q9" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q9_ans" name="q9_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>10.  Is this change in material handling equipment ? <b style="color:red">*</b></td><td><input type="radio" name="q10" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q10" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q10_ans" name="q10_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>11.  Is this new electrical panel ? <b style="color:red">*</b></td><td><input type="radio" name="q11" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q11" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q11_ans" name="q11_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>12.  Is this change in existing electrical equipment -  panels ? <b style="color:red">*</b></td><td><input type="radio" name="q12" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q12" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q12_ans" name="q12_ans" style="visibility:collapse;display:none"></textarea></td></tr>
			
			<tr><td>13.  Is this change in medium volt system ? <b style="color:red">*</b></td><td><input type="radio" name="q13" value="Y" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>Yes  <input type="radio" name="q13" value="N" onchange="handleQuestionAns(getAttribute('name'),this.value)"/>No</td></tr>
			<tr ><td colspan="1"><textarea rows="3" cols="80" id="q13_ans" name="q13_ans" style="visibility:collapse;display:none"></textarea></td></tr>
		</table>

		<span class="bold">Originator:</span>
		<%
			strClass = bOriginator ? "missing" : "";
		%>
		<input type="text" readonly class="<%=strClass%>"
			value='<%=strOriginator%>' name="originator" style="width: 150px">

		<input type="hidden" name="creatorteam" id="creatorteam" value="-N/A-"
			class="<%=strClass%>" />
		<%-- 
   <span style="margin-left:50px" class="bold">Team:</span>
       <select name="creatorteam" id="creatorteam" class="<%=strClass%>">
	   <option value=""></option>
	   <% strClass=bCreatorTeam?"missing":""; 
         sql="select * from tblCreatorTeam where (hidden<>'Y' or hidden is null) order by teamname";
         st=c.createStatement();
         rs = st.executeQuery(sql);
       	while(rs.next()){
		  String strCreatorTeam_t=rs.getString("teamname")==null?"":rs.getString("teamname");
		  String strSelected=strCreatorTeam_t.equals(strCreatorTeam)?"selected":"";
       %>
        <option value="<%=strCreatorTeam_t%>" <%=strSelected%>><%=strCreatorTeam_t%></option>
		<%
		}
		 %>

       </select>
       --%>
		</p>

		<p>
			<span class="bold">Phone No.</span>
			<%
				strClass = bPhone ? "missing" : "";
			%>
			<input type="text" class="<%=strClass%>" name="phone" id="phone"
				value="<%=strCreatorPhone%>">
		</p>

		<p>
		<table border="0">
			<tr>
				<td><span class="bold">Department Impacted:</span></td>
				<td><span class="bold"> Line:</span></td>
			</tr>
			<tr style="vertical-align: top;">
				<td>
					<%
						strClass = bArea ? "missing" : "";
					%> <select
					class="<%=strClass%>" name="areaList" id="areaList" size="4"
					multiple style="width: 200px;"
					onChange="doChange('areaList','lineList',areaArray,lineArray); doChange('areaList','equipmentList',areaArray,equipmentArray);">
				</select> <%
 	if (bArea)
 				out.print(strErrorMsg);
 %> <input type="hidden"
					name="area" id="area" value="<%=strArea%>"> <input
					type="hidden" name="areaName" id="areaName"
					value="<%=strAreaName%>">
				</td>
				<td>
					<%
						strClass = bLine ? "missing" : "";
					%> <select class="<%=strClass%>"
					name="lineList" id="lineList" multiple size="4"
					style="width: 200px"></select> <input type="hidden" name="line"
					id="line" value="<%=strLine%>"> <input type="hidden"
					name="lineName" id="lineName" value="<%=strLineName%>">
				</td>

			</tr>
		</table>
		</p>

		<p>

			<%
				strClass = bEquipment ? "missing" : "";
			%>
			<span class="bold">Equipment:</span> <select class="<%=strClass%>"
				name="equipmentList" id="equipmentList" onChange="checkEquipment();"
				style="vertical-align: top; width: 200px">
			</select> &nbsp; <img src="./images/question.png"
				onClick="alert('Contact the department owner if the equipment is not shown in the list');">
			<input type="hidden" name="equipment" id="equipment"
				value="<%=strEquipment%>"> <span name="id1" id="id1"
				style="visibility:<%if (strEquipment.equals("54"))
						out.print("visible");
					else
						out.print("hidden");%>">
				&nbsp;&nbsp;&nbsp;<span class="bold">Specify:</span><input
				type="text" name="otherEquipment" value="<%=strOtherEquipment%>">
			</span>
		</p>
		<p>
			<span class="bold">Is this a Re-Application:</span>
			<%
				strClass = bReApp ? "missing" : "";
			%>
			<input class="<%=strClass%>" type="radio" name="reappGrp"
				id="reappGrp" value="Y" onclick='checkReapp()'
				<%if (strReApp.equals("Y"))
						out.print(" checked");%>>Yes <input
				class="<%=strClass%>" type="radio" name="reappGrp" id="reappGrp"
				value="N" onclick='checkReapp()'
				<%if (strReApp.equals("N"))
						out.print(" checked");%>>No <input
				type="hidden" name="reapp" id="reapp" value="<%=strReApp%>">
			<span id="id2" name="id2"
				style="visibility:<%if (strReApp.equals("Y"))
						out.print("visible");
					else
						out.print("hidden");%>">
				<span class="bold">Specify where reapp is from:</span><input
				type="text" value="<%=strReAppFrom%>" name="reappFrom"
				id="reappFrom" maxlength="50">(max. 50 chars)
			</span>
		</p>
		<p>
		<fieldset style="width: 520px;">
			<legend>
				<span class="bold">Proposed Timing</span>
			</legend>
			<%
				strClass = bStartDate ? "missing" : "";
			%>
			Start of Construction:<input class="<%=strClass%>" readonly
				title="MM/DD/YYYY" type="Text" name="sdate" id="sdate"
				maxlength="10" size="10" value="<%=strStartDate%>"><a
				href="javascript:NewCal('sdate','mm/dd/yyyy' )"><img
				src="./images/cal.gif" width="16" height="16" border="0"
				alt="Pick a date"></a> &nbsp;&nbsp;&nbsp;&nbsp;
			<%
				strClass = bEndDate ? "missing" : "";
			%>
			Project Startup: <input class="<%=strClass%>" readonly
				title="MM/DD/YYYY" type="Text" name="edate" id="edate"
				maxlength="10" size="10" value="<%=strEndDate%>"><a
				href="javascript:NewCal('edate','MM/DD/YYYY' )"><img
				src="./images/cal.gif" width="16" height="16" border="0"
				alt="Pick a date"></a>
		</fieldset>
		</p>


		<input type="hidden" id="type" name="type" value="Nocost" /> <input
			type="hidden" name="cost" id="cost" size="10" maxlength="20"
			value="<%=strCost%>">

		<%--
  <p>
  
  <fieldset style="width:450px;"><legend><span class="bold">Cost and Type</span></legend>
 Costs($): <input type="text" name="cost" id="cost" size="10" maxlength="20" value="<%=strCost%>" title="Numbers Only" onBlur="if (!isValidNumber('cost')) {alert('Enter a valid number!'); this.focus();}">
    &nbsp;&nbsp;&nbsp;&nbsp;
    
 Type: 
 <%   
	  if (bType) strClass = "missing";  else strClass="";
  %>
    <select class="<%=strClass%>" name="type" id="type" >
    <option value="">select cost type</option>
    <% strClass = bType ? "missing" : ""; 
    sql="select * from tblCostType where (hidden<>'Y' or hidden is null) order by costType";
    st=c.createStatement();
    rs = st.executeQuery(sql);
	while(rs.next()){
		String strCostType_t = rs.getString("costType") == null ? "" : rs.getString("costType");
		String strCostTypeDesc_t = rs.getString("costTypeDesc") == null ? "" : rs.getString("costTypeDesc");
		String strSelected = strCostType_t.equals(strType) ? "selected" : "";
  %>
        <option value="<%=strCostType_t%>" <%=strSelected%>><%=strCostTypeDesc_t%></option>

  <%
	}
  %>
	</select>     
 
	</fieldset>
  </p>
    --%>
		<p>
			<span class="bold">Description of Change</span> <span
				style="background-color: #ffff00"
				title=" More than 1000 chars, use Attachment">(max:1000
				chars)</span><br />
			<%
				strClass = bDesc ? "missing" : "";
			%>
			<textarea class="<%=strClass%>" name="description" id="description"
				rows='5' cols='80'
				onKeyUp="handle_keyup(this,1000,'You reached the length limit,please use attachment.');"><%=strDesc%></textarea>
		</p>
		<p>
			<span class="bold">Reason for Change</span> <span
				style="background-color: #ffff00"
				title=" More than 1000 chars, use Attachment">(max:1000
				chars)</span><br />
			<%
				strClass = bReason ? "missing" : "";
			%>
			<textarea class="<%=strClass%>" name="reason" id="reason" rows='5'
				cols='80'
				onKeyUp="handle_keyup(this,1000,'You reached the length limit,please use attachment.');"><%=strReason%></textarea>
		</p>
		<div>
			<span class="bold">Attachments</span><br /> <span name="uploadPanel"
				id="uploadPanel" style="display: inline-block"> File 1:<input
				type='file' name='file1' id='file1'> File 2:<input
				type='file' name='file2' id='file2'><br /> File 3:<input
				type='file' name='file3' id='file3'> File 4:<input
				type='file' name='file4' id='file4'><br />

			</span>

		</div>

		<p>
			<input type="hidden" name="pageAction" id="pageAction" value="">
			<input type="button" name="btnSubmit" value="Submit"
				onClick="doSubmit(this);"> <input type="reset"
				name="btnReset" value="Reset">
		</p>

		<script type='text/javascript'>
			init();
		</script>
	</form>
	<%
		} //end of if renderPage
	%>
</body>
</html>
<%
	} catch (Exception e) {
		DBHelper.log(null, strCurLogin, "createRequest.jsp:" + e);
		System.out.println("exception:" + e);
		c.rollback();
		//	 e.printStackTrace();
		out.println("<h2> Error </h2>");
		out.println("<hr/>");
		out.println(e);
		out.println("please contact system owner");
	} finally {
		DBHelper.closeResultset(rs);
		DBHelper.closeStatement(st);
		DBHelper.closeStatement(pstmt);
		DBHelper.closeStatement(pstmt2);
		DBHelper.closeConnection(c);
	}
%>
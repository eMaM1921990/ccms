<%@page contentType="text/html; charset=ISO-8859-6"%>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
	if (!bIsLoginOwner && !bIsSysadmin) {
		return;
	}

	Connection c = null;
	Statement st = null;
	Statement st2 = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	ResultSet rs2 = null;
	String strLog = request.getParameter("n") == null ? "" : request
			.getParameter("n");
	String strApproverEmails = "";

	if (strLog.trim().equals("")) {
		out.println("Missing Parameter.");
		return;
	}
	DBHelper.log(null, strCurLogin, "notifyApprover.jsp:" + strLog);

	try {
		String updateSql = "update tblChangeControlLog set notified=notified+1 where logID="
				+ strLog;
		c = DBHelper.getConnection();
		st = c.createStatement();

		updateSql = "update tblChangeControlLog set approvalStatusID="
				+ 3 + ",approvedby='" + strCurLogin
				+ "', approvedDate=getDate() where logID=" + strLog
				+ " and approvalStatusID=0";

		String strSql = "select * from tblChangeControlLog where logID="
				+ strLog;
		String strDesc = "";
		rs = st.executeQuery(strSql);
		int times = 0;
		if (rs.next()) {
			times = rs.getInt("notified");
			strDesc = rs.getString("changeDesc") == null ? "" : rs
					.getString("changeDesc");
		}

		strSql = "select approverEmail from tblApprovalSignature where isChecked=0 and rejected=0 and  logID="
				+ strLog;
		rs = st.executeQuery(strSql);
		while (rs.next()) {
			String strEmail = rs.getString("approverEmail");
			if (strEmail != null && strEmail.indexOf("@") > -1)
				strApproverEmails += ";" + strEmail;
		}
		strSql = "select reviewerEmail from tblTeamReview where checked=0 and rejected=0 and logid="
				+ strLog;
		rs = st.executeQuery(strSql);
		while (rs.next()) {
			String strEmail = rs.getString("reviewerEmail") == null ? ""
					: rs.getString("reviewerEmail");
			if (!strEmail.equals("") && strEmail.indexOf("@") > -1)
				strApproverEmails += ";" + strEmail;
		}

		strSql = "select email from tblLineTeamReview where approved<>'Y' and rejected<>'Y' and logid="
				+ strLog;
		rs = st.executeQuery(strSql);
		while (rs.next()) {
			String strEmail = rs.getString("email") == null ? "" : rs
					.getString("email");
			if (!strEmail.equals("") && strEmail.indexOf("@") > -1)
				strApproverEmails += ";" + strEmail;
		}

		if (strApproverEmails.length() > 0) {
			strApproverEmails = strApproverEmails.substring(1);
			
			String strMsg = "<span style=\"font-size:12.0pt;font-family:&quot;Calibri&quot;,sans-serif\"><b>Dear Approvals ,</b><u></u><u></u></span><br/><br/><br/>";
			strMsg += "<span style=\"font-family:&quot;Calibri&quot;,sans-serif;color:#00b0f0\">What you need to know:<u></u><u></u></span><br/>";
			strMsg += "<p><b><span style=\"font-family:&quot;Calibri&quot;,sans-serif\">The following Change Management Request:";
			strMsg += "</span></b><span style=\"font-family:&quot;Calibri&quot;,sans-serif\">";
			strMsg += "<span style=\"color:red\">#" + strLog
					+ "</span> needs your approval.</span><br>";
			strMsg += "Click <a href=\"#SERVER#/ccms/reviewRequest3.jsp?n="
					+ strLog + "\" target=\"_blank\">";
			strMsg += "here</a> to review the change request.<br>";
			strMsg += "<span style=\"color:red\">This is an auto-generated message by online Change Management System, ";
			strMsg += "please do NOT reply!<u></u><u></u></span></p>";

			strMsg += "<span style=\"font-family:&quot;Arial&quot;,sans-serif;color:#00b0f0\">Information:<u></u><u></u></span><br/>";
			strMsg += "<span style=\"font-family:&quot;Calibri&quot;,sans-serif;color:black;background:white\">Full Change Body</span><br/><br/><br/>";
			strMsg += "<span style=\"color:#00b0f0\">Description of Change:<u></u><u></u></span><p>"
					+ strDesc + "</p>";

			strMsg += "<br/><br/><span style=\"font-family:&quot;Arial&quot;,sans-serif;color:#00b0f0\">What you need to do:<u></u><u></u></span><br/><br/>";
			strMsg += "<span style=\"font-size:10.5pt;font-family:&quot;Arial&quot;,sans-serif;color:black\">Please Approve to start work safely<u></u><u></u></span><br/><br/>";
			strMsg += " <br/><br/>Email Notification:" + times;

			strMsg += "<br/><img src='#SERVER#/ccms/images/icare.jpg'/>";
			MailSender.sendEMail(strApproverEmails,
					"Approval needed for Change Request:" + strLog,
					strMsg);

			out.println("success");
		} else {
			out.println("No one left to sign off, or the approvers don't have email setup. LOG:"
					+ strLog);
			DBHelper.log(null, strCurLogin, "notifyApprover.jsp:"
					+ strLog + "  No email addresses can be sent to.");
			c.rollback();
		}

	} catch (Exception e) {
		c.rollback();
		DBHelper.log(null, strCurLogin,
				"NotifyApprover.jsp Error:" + e.toString());
		out.println(e.getMessage());
	} finally {
		DBHelper.closeResultset(rs);
		DBHelper.closeResultset(rs2);
		DBHelper.closeStatement(st2);
		DBHelper.closeStatement(st);
		DBHelper.closeConnection(c);
	}
%>

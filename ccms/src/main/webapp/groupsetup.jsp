<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "SELECT AreaID,AreaName FROM tblArea where hidden<>'Y' and AreaName='Site'";
	try {
		c = DBHelper.getConnection();
		st = c.createStatement();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript"
	src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

<script type="text/javascript" src="ccms.js"></script>
<title>Insert title here</title>
</head>
<body onload="loadApproval()">
	<div>
		<a href="settings.jsp">Settings</a> > Group Approval Setup
	</div>
	<div
		style="margin-top: 10px; width: 100%; height: 30px; background: #EEEEEE; font-size: 16pt">Group
		Approval Setup</div>
	<div id="response"></div>
	<table>

		<tr>
			<td>
			
				<table>

					<tr>
						<td>Type Of Request :</td>
						<td colspan="1"><select id='typeOfRequest' name="TOR"
							onchange="resetDep();loadApproval()">
								<option value="0">Select your request type</option>
								<option value="Building Change/New Building">Building
									Change/New Building</option>
								<option value="New Mechanical Equipment or Mechanical Change">New
									Mechanical Equipment or Mechanical Change</option>
								<option value="Only Electrical Change">Only Electrical
									Change</option>
								<option value="Quality Assurance Change">Quality
									Assurance Change</option>
								<option value="Technical Packaging Change">Technical
									Packaging Change</option>
								<option value="New Chemical/Material">New
									Chemical/Material</option>
								<option value="New EO">New EO</option>
								<option value="Maintenace Activities">Maintenace
									Activities</option>
								<option value="Site Facility Change">Site Facility
									Change</option>
								<option value="New Project">New Project</option>
								<option value="New Software">New Software / Website or Modification ins Software/ Website</option>

						</select></td>
					</tr>

					<tr>

						<td>Department :</td>
						<td><select name="department"
							onchange="getApprovalByDepartment();loadApproval()"
							id="department">
								<option value="0">Select department</option>
								<%
									rs = st.executeQuery(sql);
										while (rs.next()) {
								%>
								<option value="<%=rs.getString(1)%>"><%=rs.getString(2)%></option>
								<%
									}
										rs.close();
								%>

						</select></td>
					</tr>
					<tr>
						<td>List Of Approval :</td>
						<td><select class="" name="approval" id="approval" size="4"
							multiple="" style="width: 200px;">

						</select></td>

					</tr>
					<tr>
						<td><input type="button" value="SaveGroup"
							onclick="saveApprovalGroups()" /></td>
					</tr>

				</table>

			</td>
			<td>
			

			<table id="approvaldata">
				<tr>
					<td width="300px">Approval</td>
					<td>Action</td>

				</tr>
			</table>

			</td>

		</tr>
	</table>


</body>
</html>
<%
	} catch (Exception e) {
		out.println(e);
	} finally {
		DBHelper.closeResultset(rs);
		DBHelper.closeStatement(st);
		DBHelper.closeStatement(pstmt);
		DBHelper.closeConnection(c);
	}
%>
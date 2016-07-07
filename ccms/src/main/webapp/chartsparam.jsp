<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "SELECT AreaID,AreaName FROM tblArea where hidden<>'Y'";
	try {
		c = DBHelper.getConnection();
		st = c.createStatement();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

<title>Reports</title>
</head>
<body>
	<div class="title">General Report Parameter page</div>
	<form name="the_form" id="the_form" method="POST"
		action="chartsgenerate.jsp">
		<table border='0'>
			<tr>

				<td>Department:</td>
				<td><select name="department">
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
		</table>
		<input type="submit" value="Generate Report" />
		</form>
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
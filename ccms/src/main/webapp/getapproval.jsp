<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "SELECT ApproverID,ApproverName FROM tblApprovers where hidden<>'Y' AND areaID='"+request.getParameter("dept_id")+"' AND ApproverID NOT IN (SELECT ApprovalID FROM tblApprovalGroup WHERE ApprovalGroupRequest='"+request.getParameter("request_type")+"' AND AreaID='"+request.getParameter("dept_id")+"')";
	System.err.println(sql);
	try {
		String buffer=null;
		c = DBHelper.getConnection();
		st = c.createStatement();
		rs = st.executeQuery(sql);
		while (rs.next()) {
			if(buffer==null){
				buffer="<option value="+rs.getInt(1)+">"+rs.getString(2)+"</option>";
			}else{
				buffer=buffer+"<option value="+rs.getInt(1)+">"+rs.getString(2)+"</option>";
			}
		}
		
		response.getWriter().write(buffer);
		
		
	} catch (Exception e) {
		out.println(e);
	} finally {
		DBHelper.closeResultset(rs);
		DBHelper.closeStatement(st);
		DBHelper.closeStatement(pstmt);
		DBHelper.closeConnection(c);
	}
%>
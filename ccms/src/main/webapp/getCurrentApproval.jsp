<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	String sql = "SELECT ApproverID,ApproverName FROM tblApprovers where hidden<>'Y' AND areaID='"+request.getParameter("dept_id")+"' AND ApproverID  IN (SELECT ApprovalID FROM tblApprovalGroup WHERE ApprovalGroupRequest='"+request.getParameter("request_type")+"' AND AreaID='"+request.getParameter("dept_id")+"')";
	System.err.println(sql);
	try {
		String buffer=null;
		c = DBHelper.getConnection();
		st = c.createStatement();
		rs = st.executeQuery(sql);
		while (rs.next()) {
			if(buffer==null){
				buffer="<tr><td>"+rs.getInt(2)+"</td><td><a href='#' onclick='removeApproval("+rs.getString(1)+")'>Remove</a></td></tr>";
			}else{
				buffer=buffer+"<tr><td>"+rs.getInt(2)+"</td><td><a href='#' onclick='removeApproval("+rs.getString(1)+")'>Remove</a></td></tr>";
			}
		}
		if(buffer==null){
			response.getWriter().write("<tr><td colspan='2'>No data found</td></tr>");
		}else{
			response.getWriter().write(buffer);	
		}
		
		
		
	} catch (Exception e) {
		out.println(e);
	} finally {
		DBHelper.closeResultset(rs);
		DBHelper.closeStatement(st);
		DBHelper.closeStatement(pstmt);
		DBHelper.closeConnection(c);
	}
%>
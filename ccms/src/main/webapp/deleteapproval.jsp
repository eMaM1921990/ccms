<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*" %>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	String sql = "DELETE FROM tblApprovalGroup WHERE ApprovalID=? AND ApprovalGroupRequest=? AND AreaID=?";
	
	int areaid=Integer.valueOf(request.getParameter("selected_department"));
	String type_of_request=request.getParameter("selected_request");
	try {
		String buffer=null;
		c = DBHelper.getConnection();
		
		pstmt=c.prepareStatement(sql);

			pstmt.setString(1, request.getParameter("id"));
			pstmt.setString(2, type_of_request);
			pstmt.setInt(3, areaid);
			
			int u=pstmt.executeUpdate();
		
		c.commit();
		
		response.getWriter().write("Data delete Successfully");
		
		
	} catch (Exception e) {
		response.getWriter().write(e.getMessage());
		out.println(e);
	} finally {
		
		DBHelper.closeStatement(st);
		DBHelper.closeStatement(pstmt);
		DBHelper.closeConnection(c);
	}
%>
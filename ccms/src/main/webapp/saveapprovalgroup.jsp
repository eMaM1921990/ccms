<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*" %>

<%
	Connection c = null;
	Statement st = null;
	PreparedStatement pstmt = null;
	String sql = "INSERT INTO dbo.tblApprovalGroup (ApprovalGroupRequest,ApprovalID,AreaID) VALUES (?,?,?)";
	List<String> approval_ids =null;
	if(request.getParameter("approval").indexOf(",")>-1){
		approval_ids = Arrays.asList(request.getParameter("approval").split("\\s*,\\s*"));
	}else{
		approval_ids=Arrays.asList(request.getParameter("approval"));
	}
	
	int areaid=Integer.valueOf(request.getParameter("selected_department"));
	String type_of_request=request.getParameter("selected_request");
	try {
		String buffer=null;
		c = DBHelper.getConnection();
		
		pstmt=c.prepareStatement(sql);

		for(int i=0;i<approval_ids.size();i++){
	
			pstmt.setString(1, type_of_request);
			pstmt.setInt(2, Integer.valueOf(approval_ids.get(i)));
			pstmt.setInt(3, areaid);
			System.out.println("Rsa");
			int u=pstmt.executeUpdate();
			System.out.println("Aciton :"+u);
		}
		
		c.commit();
		
		response.getWriter().write("Data Saved Successfully");
		
		
	} catch (Exception e) {
		response.getWriter().write(e.getMessage());
		out.println(e);
	} finally {
		
		DBHelper.closeStatement(st);
		DBHelper.closeStatement(pstmt);
		DBHelper.closeConnection(c);
	}
%>
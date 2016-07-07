<%@page import="java.nio.charset.CharsetDecoder"%>
<%@page import="com.sun.corba.se.impl.ior.ByteBuffer"%>
<%@page import="java.nio.CharBuffer"%>
<%@page import="java.nio.charset.Charset"%>
<%@page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%

String strMethod = request.getMethod();
String strQueryStr = request.getQueryString();

if (!strMethod.toUpperCase().equals("POST")){
	out.println("Error: Cannot be called by GET.");
	return;
}

String strSql = request.getParameter("sql") == null ? "" : request.getParameter("sql");
int noOfParams = Integer.parseInt(request.getParameter("paramsNo"));

//byte[] utf8 = strSql.getBytes("UTF-8");
//byte[] latin1 = new String(utf8, "UTF-8").getBytes("ISO-8859-6");

//strSql = new String(latin1, "ISO-8859-6");


DBHelper.log(null, strCurLogin, "updateDB.jsp:" + strSql);

Connection c = null;
Statement st = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

if (strSql != null && !strSql.trim().equals(""))
 {
    try {
      c = DBHelper.getConnection();
      //st = c.createStatement();
      pstmt = c.prepareStatement(strSql);
      
      for(int i = 0 ; i < noOfParams ; i++)
    	  pstmt.setString(i + 1, request.getParameter("param" + (i+1)));
      //st.executeUpdate(strSql);
      pstmt.executeUpdate();
//	  DBHelper.log(c,strCurLogin,"updateDB.jsp:"+strSql);
	  c.commit();
	  out.println("Success");
    }
    catch(Exception e){
         DBHelper.log(null, strCurLogin, "Error in updateDB.jsp:" + e.toString() + "/" + strSql);
		 c.rollback();
         out.println("Failed:"+e.getMessage());
    }
     finally{
        DBHelper.closeStatement(st);
        DBHelper.closeConnection(c);
    }
 }
else{
	DBHelper.log(null, strCurLogin, "updateDB.jsp:Missing sql statement");
	out.println("Failed, please try again.");
}
%>
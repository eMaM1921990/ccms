<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%

String strMethod = request.getMethod();
String strQueryStr = request.getQueryString();
//out.println("method:"+strMethod+ " QueryString:"+strQueryStr);
if (!strMethod.toUpperCase().equals("POST")){
	out.println("Error: Cannot be called by GET.");
	return;
}
String strSql = request.getParameter("sql") == null ? "" :request.getParameter("sql");
DBHelper.log(null, strCurLogin, "updateDB.jsp:" + strSql);

Connection c = null;
Statement st = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

if (strSql != null && !strSql.trim().equals(""))
 {
    try {
      c = DBHelper.getConnection();
      st = c.createStatement();
      st.executeUpdate(strSql);
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
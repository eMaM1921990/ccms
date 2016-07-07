<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
 
String strMethod=request.getMethod();
String strQueryStr=request.getQueryString();
//out.println("method:"+strMethod+ " QueryString:"+strQueryStr);
if (!strMethod.toUpperCase().equals("POST")){
	out.println("Disabled");
	return;
}
String strSql=request.getParameter("sql")==null?"":request.getParameter("sql");
String strSql2=request.getParameter("sql2")==null?"":request.getParameter("sql2");
String strSql3=request.getParameter("sql3")==null?"":request.getParameter("sql3");
String strSql4=request.getParameter("sql4")==null?"":request.getParameter("sql4");


DBHelper.log(null,strCurLogin,"updateDB2.jsp:"+strSql);
Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
ResultSet rs =null;

    try {
      c=DBHelper.getConnection();
      st=c.createStatement();
	  if (!strSql.trim().equals(""))
          st.executeUpdate(strSql);
  	  if (!strSql2.trim().equals(""))
          st.executeUpdate(strSql2);
	  if (!strSql3.trim().equals(""))
          st.executeUpdate(strSql3);
      if (!strSql4.trim().equals(""))
          st.executeUpdate(strSql4);

	  c.commit();
	  out.println("Success");
    }
    catch(Exception e){
         DBHelper.log(null,strCurLogin,"updateDB2.jsp Error:"+e.toString());
		 c.rollback();
         out.println("updateDB2.jsp Failed:"+e.getMessage());
    }
     finally{
        DBHelper.closeStatement(st);
        DBHelper.closeConnection(c);
    }
%>

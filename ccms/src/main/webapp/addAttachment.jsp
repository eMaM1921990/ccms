<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="java.sql.*"%>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@ include file="inc.jsp" %>

<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.util.*"%>
<%@page import="org.apache.commons.fileupload.servlet.*"%>

<%
Connection c = null;
Statement st = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String sql = null;
%>
<%
//  out.println("n="+request.getParameter("n"));

  int key = -1;


  try {
     key = Integer.parseInt(request.getParameter("n"));
  } catch(Exception ee) {
	  out.println("Wrong request#");
      return;
  }
  String strCreator = "";
  try{
	  c = DBHelper.getConnection();
      st = c.createStatement();

	  sql = "select *  from tblChangeControlLog where logID="+key+" and (hidden<>'Y' or hidden is null)";
	  rs = st.executeQuery(sql);
	  if (rs.next()) {
		  strCreator=rs.getString("creator");
	  }

  } catch(Exception e) {
    out.println(e);
	return;
  }
  finally {
     DBHelper.closeResultset(rs);
	 DBHelper.closeStatement(pstmt);
	 DBHelper.closeStatement(st);
	 DBHelper.closeConnection(c);
  }
  boolean  bIsCreator=strCreator.equals(strCurLogin);
 
  if (!bIsCreator && !bIsLoginOwner && !bIsSysadmin){
	  out.println("<p>You don't have permission to add attchments to this change request.</p>");
	  out.println("<p>Only originator or department owners can use this function.</p>");
	  return;

  }
  %>
 <html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<title>Add Attchments</title>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>
<body>

<%

  boolean isMultipart = ServletFileUpload.isMultipartContent(request);
  if (isMultipart){
   try{
   ServletFileUpload upload = new ServletFileUpload();
   FileItemIterator iter = upload.getItemIterator(request);
   String  sqlInsert="insert into tblAttachments(LogID,docName,originalName,docType,docSuffix,byWho,attacheDate,hidden) values (?,?,?,?,?,?,?,?)";
   c=DBHelper.getConnection();
   pstmt = c.prepareStatement(sqlInsert,Statement.RETURN_GENERATED_KEYS);

   while (iter.hasNext()) {
      FileItemStream item = iter.next();
      if (item.isFormField()) {
            
   //    out.println("Form field " + name + " with value "+ Streams.asString(stream) + " detected.<BR/>");
      } else {
     //   out.println("File field " + name + " with file name " + item.getName() + " detected.<BR/>");

		   String name = item.getName();
		   if (name.trim().equals("")) continue;
		   InputStream stream = item.openStream();
           String strContentType=item.getContentType() ;
           String strSuffix = name.lastIndexOf(".") >-1 ? name.substring(name.lastIndexOf(".")):"";//include '.'
		   String strDocName=name.lastIndexOf("\\")>-1 ? name.substring(name.lastIndexOf("\\")+1):name; //exclude '\'
		   //System.out.println(strOriFileName);
			strContentType=strContentType.length()>=255?strContentType.substring(0,255):strContentType;
			strSuffix=strSuffix.length()>=50?strSuffix.substring(0,50):strSuffix;
			strDocName=strDocName.length()>=255?strDocName.substring(0,255):strDocName;
		  String strTruncatedName=name.length()>=1000?name.substring(0,1000):name;           

		   pstmt.setInt(1,key);
           pstmt.setString(2,strDocName);
           pstmt.setString(3,strTruncatedName);
           pstmt.setString(4,strContentType);
		   pstmt.setString(5,strSuffix);
           pstmt.setString(6,(String)(session.getAttribute("user")));
		   pstmt.setTimestamp(7,new java.sql.Timestamp(new java.util.Date().getTime()));
   		   pstmt.setString(8,"N");
           pstmt.executeUpdate();

           rs=pstmt.getGeneratedKeys();

           int fileKey=-1;
           if (rs!=null && rs.next()){
          	  fileKey=rs.getInt(1);
           }
           String strFileName=key+"_"+fileKey+strSuffix;
           String strFilePath=  System.getProperty("catalina.base")+"\\webapps\\CCMS\\Attachments\\"+strFileName;
           FileOutputStream os = new FileOutputStream(strFilePath);
           int b;
           while((b=stream.read())!=-1){
              os.write(b);
           }
           os.close();
           stream.close();
        } //end of else
     }//end while
	 c.commit();
	 out.println("<div style='font-size: 12pt; color: #008000;  border: 1px solid #000000; padding-left: 4; padding-right: 4; padding-top: 1; padding-bottom: 1; background-color: #C0C0C0; width:400;'>");
     out.println("<p align='center'><u>Success</u></p>");
     out.println("<p>Your attachements have been uploaded successfully!");
     out.println("</p>");
	 out.println("<p><a href='reviewRequest3.jsp?n="+key+"'>Review</a></p>");
     out.println("</div>");
    }catch(Exception e)
	{
 		c.rollback();
		out.println("Error:"+e);
	 }
	 finally{
		 DBHelper.closeResultset(rs);
		 DBHelper.closeStatement(pstmt);
		 DBHelper.closeStatement(st);
		 DBHelper.closeConnection(c);
	 }
  }
  else {
  %>
  <form ENCTYPE='multipart/form-data' name="the_form" id ="the_form" method="post" action="#">

  <div class="title">Add Attachments for Request:#<%=key%></div>
   File1:<input type='file' name='file1' id='file1' style="width:400px;"><br/>
   File2:<input type='file' name='file2' id='file2' style="width:400px;"><br/>
   File3:<input type='file' name='file3' id='file3' style="width:400px;"><br/>
   File4:<input type='file' name='file4' id='file4' style="width:400px;"><br/>
  <p> <input type ="submit" name="btnSubmit" value ="Submit"> <input type ="reset" name="btnReset" value="Reset"> </p>
    </form>
  <%
  }
  %>


  </body>
  </html>
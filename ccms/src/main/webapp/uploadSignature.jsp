<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.util.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<script  type="text/javascript">
  function handle_submit(){
   var u= document.getElementById("acct");
   var f= document.getElementById("file1");
   if (u.value.length<1 || f.value.length<1 ){
	   alert("Filed(s) cannot be blank");
	   return false;
   }
  }
</script>
</head>
<body>

<%
 

if (!bIsLoginOwner && !bIsApprover &&!bIsSysadmin){
	out.println("<p>You don't have permission to run this function.</p>");
	return;
}
String strEnabled ="";
if (!bIsLoginOwner  && !bIsSysadmin)
  strEnabled="readonly";

boolean bComplete=true;

boolean isMultipart = ServletFileUpload.isMultipartContent(request);

if (isMultipart){  //click the upload button
 String strAcct="noname";

   try{
   ServletFileUpload upload = new ServletFileUpload();
   FileItemIterator iter = upload.getItemIterator(request);
 
   while (iter.hasNext()) {
      FileItemStream item = iter.next();

	  String strFieldName=item.getFieldName();
      InputStream stream = item.openStream();    

      if (item.isFormField()){
		  if (strFieldName.equals("acct")){
 	          strAcct=Streams.asString(stream).toLowerCase(); //make it lower case
			  if (strAcct.trim().equals(""))
				  bComplete=false;
		  }
      } else {

		   String name = item.getName();
		   if (name.trim().equals("")) {
			   bComplete=false;
			   break;
		   }
		
           String strContentType=item.getContentType() ;
           String strSuffix = name.lastIndexOf(".") >-1 ? name.substring(name.lastIndexOf(".")):"";//include '.'
		   if (!strSuffix.equalsIgnoreCase(".JPG")){
			   bComplete=false;
			   break;
		   }

           String strFileName=strAcct+strSuffix.toLowerCase();
           String strFilePath=  System.getProperty("catalina.base")+"\\webapps\\CCMS\\images\\Signatures\\"+strFileName;
           FileOutputStream os = new FileOutputStream(strFilePath);
           int b;
           while((b=stream.read())!=-1){        os.write(b);    }
		   os.close();
        } //end of else
		 stream.close();
     }//end while
     if(bComplete){
	    out.println("<div style='font-size: 12pt; color: #008000;  border: 1px solid #000000; padding-left: 4; padding-right: 4; padding-top: 1; padding-bottom: 1; background-color: #C0C0C0; width:400;'>");
        out.println("<p align='center'><u>Success</u></p>");
        out.println("<p>Your signature has been uploaded successfully!");
        out.println("</p>");
	    out.println("<p><img width='120px' height='24px' src='./images/Signatures/"+strAcct+".jpg'></p>");
        out.println("</div>");
	 }
    }catch(Exception e)
	{
		out.println("Error:"+e);

	 }
	 finally{
		
	 }
  }
 if (!bComplete||!isMultipart){
  %>
  <form ENCTYPE='multipart/form-data' name="the_form" id ="the_form" method="post" action="#" onSubmit="return handle_submit();">

  <h3>Signature Upload Form</h3>
  <span style="width:120px;text-align:right">Intranet Account:</span><input type="text" name="acct" id="acct" value="<%=strCurLogin%>"  <%=strEnabled%>><br/>
  <span style="width:120px;text-align:right">Signature File:</span><input type='file' name='file1' id='file1'><br/>

  <p> <input type ="submit" name="btnSubmit" value ="Upload"> <input type ="reset" name="btnReset" value="Reset"> </p>
    </form>
 <p>
   *Note:<br/>
    1. Signature file has to be in <b>jpg</b> format.<br/>
	2. Signature image is properly sized .(eg. 200x50 pixels)
  </p>

  <%
  }
  %>
 
  </body>
  </html>
<%@ page import="java.io.*, java.util.*, javax.servlet.*, javax.servlet.http.*" %> 
<%@ include file="../inc.jsp" %>


<%
 if (!bIsSysadmin){
	out.println("You don't have permission to use this function.");
	return;
 }
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<title>Wiki</title>
</head>
<body>
<form method="post" name ="the_form" id="the_form" action="#">
<%

  String path=  application.getRealPath("/");
  String fullName=null;
  String strFileName=null;

  if (request.getParameter("btnSubmit")!=null){
    strFileName=request.getParameter("fn");
    fullName=path+strFileName;
	 FileOutputStream fos=null;
	try{
           fos= new FileOutputStream(fullName);
           String newContent=request.getParameter("content");
           fos.write(newContent.getBytes());
	       out.println(strFileName+" is saved!");
	}catch(Exception e){
		out.println("cannot save file:"+e);
	}

  	finally{
           if (fos!=null){fos.close();fos=null;}
	}
  }
  else{   //didn't submit
      
       StringBuffer strContentBuffer=new StringBuffer();
       FileInputStream fis =null;
       strFileName=request.getParameter("fn");
       if (strFileName!=null){
            fullName=path+strFileName;
            File aFile =new File(fullName);
            if (aFile.exists() ){
            try{
              fis =new FileInputStream(aFile);
              int i;
              while ((i=fis.read()) != -1) {
	      	     strContentBuffer.append((char)i);
              }
            }catch(Exception e){
               out.println("Error:"+e);
            }
            finally{
             if (fis!=null) fis.close();
            }

           String test=strContentBuffer.toString();
		   test=test.replace("&","&amp;");
		   test=test.replace("<","&lt;");
           test=test.replace(">","&gt;");
      %>
 
      <h2>Update:<%=fullName%></h2>

      <input type="hidden" name="fn" value="<%=strFileName%>">
      <input type="submit" name="btnSubmit" value="Save" >
      <input type="button" name="btnClose" value="Close" onClick="window.close();">
      <br/>
      <textarea rows="25" cols="100" name="content"><%=test%></textarea>
      <br/>
      <input type="submit" name="btnSubmit" value="Save">
      <input type="button" name="btnClose" value="Close" onClick="window.close();">
      <%
           }
          else //file not exists
          {
           out.println("File doesn't exist");
	      }
       }  //end of strFileName!=null
      
  }//end of not submit yet
  
%>
</form>
</body>
</html>
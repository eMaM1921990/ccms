<%
 String strIsLogin=((String)session.getAttribute("isLogin"));
 if (strIsLogin!=null && strIsLogin.equals("true")){
  session.removeAttribute("isLogin");
  session.invalidate();
  
 }
 out.println("<script type='text/javascript'>\n");
  out.println("parent.location='./login.jsp';");
  out.println("</script>");
%>
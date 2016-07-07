package com.pg.ccms.web;

import java.io.FileInputStream;
import java.io.IOException;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class DownloadFile
  extends HttpServlet
{
  private static final long serialVersionUID = 1L;
  
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
  {
    String fileName = request.getParameter("fileName");
    
    FileInputStream fileStream = new FileInputStream(getServletContext().getRealPath("/Attachments") + "\\" + fileName);
    byte[] content = new byte[fileStream.available()];
    fileStream.read(content);
    fileStream.close();
    
    response.getOutputStream();
    ServletContext context = getServletConfig().getServletContext();
    String mimetype = context.getMimeType(fileName);
    
    response.setContentType(mimetype != null ? mimetype : "application/octet-stream");
    response.setContentLength(content.length);
    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
    
    ServletOutputStream op = response.getOutputStream();
    op.write(content);
    op.flush();
    op.close();
  }
}

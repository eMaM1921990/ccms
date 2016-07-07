
   var http_request;
    
   function makePOSTRequest(url, parameters) {
	   alert("what is the requst:"+http_request);
	  if (typeof http_request=='undefined'){
         if (window.XMLHttpRequest) { // Mozilla, Safari,...
            http_request = new XMLHttpRequest();
            if (http_request.overrideMimeType) {
         	// set type accordingly to anticipated content type
            //http_request.overrideMimeType('text/xml');
                http_request.overrideMimeType('text/html');
            }
          } else if (window.ActiveXObject) { // IE
            try {
                http_request = new ActiveXObject("Msxml2.XMLHTTP");
                } catch (e) {
                    try {
                        http_request = new ActiveXObject("Microsoft.XMLHTTP");
                      } catch (e) {}
                }
          }
	  }
      if (!http_request) {
         alert('Cannot create XMLHTTP instance');
         return false;
      }
      
      http_request.onreadystatechange = alertContents(http_request);
      http_request.open('POST', url, true);
      http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http_request.setRequestHeader("Content-length", parameters.length);
      http_request.setRequestHeader("Connection", "close");
      http_request.send(parameters);
   }

   function alertContents(httpReq) {
	   alert("ajax:"+httpReq.readyState);
      if (httpReq.readyState == 4) {
         if (httpReq.status == 200) {
            alert(httpReq.responseText);
            //result = http_request.responseText;
            //document.getElementById('myspan').innerHTML = result;            
         } else {
            alert('There was a problem with the request.');
         }
      }
   }
   
  


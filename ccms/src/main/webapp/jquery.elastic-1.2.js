(function($){
	 $.fn.extend(
	  {elastic:function(){
		 var g=new Array("paddingTop","paddingRight","paddingBottom","paddingLeft","fontSize","lineHeight","fontFamily","width");
		 return this.each(function(){
			 if(this.type=="textarea"){
				 var b=$(this);
				 var c=parseInt(b.css("lineHeight"))*2||parseInt(b.css("fontSize"))*2;
				 var d=parseInt(b.css("height"))||c;
				 var m=parseInt(b.css("max-height"));
                 if (isNaN(m))
                 {
					 m=200;
                 }
				 var e=0;var f=null;
				 function update(){
					 if(!f){
						 f=$("<div />").css({"display":"none","position":"absolute","overflow-x":"hidden"}).appendTo("body");
						 $.each(g,function()
						 {f.css(this,b.css(this))}
						       )
						   }
				    var a=b.val().replace(/<|>/g," ").replace(/\n/g,"<br />");
					 if(f.text()!=a){
						 f.html(a);
						 e=(f.height()>d)?f.height():d;
						 e=e>m?m:e;

						 if(e!=b.height()){
							 b.animate({"height":e},2)
								 }
					 }
				}
				 b.css({overflow:"auto",display:"block"}).bind("focus",function(){
								 self.periodicalUpdater=window.setInterval(function(){
									 update()},400)}).bind("blur",function(){
										 clearInterval(self.periodicalUpdater)}
										                                   );
										 update()}})}})})(jQuery);
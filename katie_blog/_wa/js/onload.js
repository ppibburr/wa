      function preview(txt) {
        _('#_editor').style.display = 'none';
        el = document.querySelector('#_preview');
        el.style.display='block';
        el.contentWindow.document.documentElement.innerHTML = txt;
       // console.log(txt);
      }
      

      
    function _(qs) {
      return document.querySelector(qs);
    }
    
    function _rc(e, c) {
      e.classList.remove(c);
      return e;
    }
    
    function _ac(e, c) {
      e.classList.add(c);
      return e;
    }    
    
    var pages=[
      'settings',
      'posts',
      'nav',
      'media',
      'pages',
      'editor',
      'image-modal'
    ];
    var back;
    
    function nav(id) {
		console.log('to: '+id);
 	  for (page in pages) {
		 _ac(_("#"+pages[page]),'hidden');
	  }
	  
	  if (id == 'editor') {
	      back = 'posts';
	  } else {
		  _ac(_("#back"),'hidden');
	  }
 	  _rc(_("#"+id),'hidden'); 
    }
    
  
    function edit(idx) {
	  _j('/admin/edit/post/'+idx, function(j) {
        _("#title").value = j.title;
        e=_("trix-editor").editor;
        e.setSelectedRange([0, -1]);
        e.insertHTML(j.html);
        
        back='posts';
	    nav('editor');
	    _rc(_("#back"),'hidden');	
	  });
    }
	
	
	function nav2(what, to,after) {
	  _(what).onclick = function() {
		  nav(to);
	  
	  
	      if (after) {
		      after.call()
	      }
	  }
    }
	
	nav2("#nav_posts",'posts',function() {
	   _j('/admin/list/posts', function(j) {
	     _("#posts").outerHTML = j.html;
	     _rc(_('#posts'),'hidden');
         _('#posts').onclick = function(evt) {
		   if (evt.target.dataset.post) {
		     edit(evt.target.dataset.index)
	       }
	     }	     
       });	
	});
	
    nav2("#nav_pages",'pages');
    nav2("#nav_settings",'settings');
    nav2("#nav_media",'media', function() {loadImages(true);});
    nav2("#home", 'nav');
    nav2("#from-gallery",'media', function() {
		loadImages(true);
	    back='image-modal';
	    _rc(_("#back"),'hidden');
	});
	
    nav2('#insert-image','image-modal', function() {
	  back='editor';
	  _rc(_('#back'),'hidden');
    });


	    
    
    nav2("#new_post", 'editor', function() {
		back='posts';
		_rc(_("#back"),'hidden');
	});
	
	_("#back").onclick = function() {
		nav(back)
		if (back != 'editor' && back != 'posts') {
			back=null;
		}
	}
	
	function _rcall(cls) {
		l=document.getElementsByClassName(cls);
		console.log(l.length);
		for (x=0;x<l.length;x++) {
			console.log(x);
		  _rc(l.item(x),cls);	
		}
	}
	


    _ac(_("#back"),'hidden');
    
    function _c(what, fun) {
	  _(what).onclick = fun;
	}
    
    _c("#preview", function() {
		_p('/admin/preview',{
          body: _('#trix-input-1').value,
          title: _("#title").value
        }, function() {
		  window.location = 'http://192.168.1.121:4567/blogs/katie/2017/preview';	
		});
	});
	
	function _p(url, obj, succ) {
		xhr = new XMLHttpRequest();
        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function () {
          if (this.readyState != 4) return;

          if (this.status == 200) {
			  if (succ) {
                succ();	
		      }
          }
        };
    
        xhr.send(JSON.stringify(obj));		
	}

    function _j(url,fun) {
		xmlhttp = new XMLHttpRequest();
		
		xmlhttp.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200) {
				j = JSON.parse(this.responseText);
				fun(j);
			}
		};
		xmlhttp.open("GET", url, true);
		xmlhttp.send();		
	}

function _e(l,fun) {
	var i;
	for (i=0;i<l.length;i++) {
		console.log(i);
		console.log(l.item(i));
		fun(i,l.item(i));
	}
}

var files = [];

function loadImages(bool) {
	_j("/images", function(j) {
		_("#media").outerHTML = j.html;

    nav2('#insert', "editor", function() {
	  back='editor';
	  _('trix-editor').editor.insertHTML("<img src="+_("#insert-image-url").value+"></img>");	
	  _rc(_("#back"),'hidden')		
	});
    
    nav2("#select", 'image-modal', function() {
		back = 'editor';
        _("#insert-image-url").value = _('.active-item').src;
	});
	
	    if (bool) {
			_rc(_("#media"),'hidden');
		}
	
	    _("#gallery").onclick = function(evt) {
		  _rcall('active-item');
		  _ac(evt.target,'active-item');
	    }
 
        _("#image-upload").onchange = function(event) {
           _e(event.target.files, function(index, file) {
             var reader = new FileReader();
             reader.onload = function(event) {  
               o = {};
               o.filename = file.name;
               o.data = event.target.result;
    
               _p("/admin/upload/image", {filename: o.filename, data: o.data}, function() {
				   loadImages(true);
			   });         
             };  
    
             reader.readAsDataURL(file);
           });
        }
    });
}


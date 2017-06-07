  function loadImages(bool) {
	_j("/images", function(j) {
		_o("#media", j.html);
	
	    if (bool) {
			view('media');
		}
		
		console.log(_("#gallery"));
	
	    _c("#gallery",function(evt) {
		  _rcall('active-item');
		  _ac(evt.target,'active-item');
	    });
    });
}

function active(t,i) {
	activeEntryID = i;
	activeEntryType = t;
}

    function edit(type, idx) {
	  _j('/admin/edit/'+type+'/'+idx, function(j) {
        _("#title").value = j.title;
        e=_("trix-editor").editor;
        e.setSelectedRange([0, -1]);
        e.insertHTML(j.html);
        
        active(type,idx);
        
        nav('editor');
	  });
    }

page({
	id: 'nav',
	actions:{
	  'view': {
		  onclick: function() {
			  window.location = "/blogs/katie/";
		  }
	  }	
	},
	root: true
})

page({
	id: 'posts',
	actions:{
		'add': {
			onclick: function() {
				_j('/admin/add/posts/' , function(j) {
					edit('posts', j.index);
			    });
			}
		}
	},
	
	onshow: function() {
       _j('/admin/list/posts', function(j) {
	     _o("#posts", j.html);
	     
         console.log('onshow: posts');
	     view('posts');

         _('#posts').onclick = function(evt) {
		   if (evt.target.dataset.post) {
		     edit('posts', evt.target.dataset.index)
	       }
	     }	     
       });			
	}
});

page({
	id: 'drafts',
	actions:{
		'add': {
			onclick: function() {
				_j('/admin/add/drafts/' , function(j) {
					edit('drafts', j.index);
			    });
			}
		}
	},
	
	onshow: function() {
       _j('/admin/list/drafts', function(j) {
	     _o("#drafts", j.html);
	     
         console.log('onshow: drafts');
	     view('drafts');

         _('#drafts').onclick = function(evt) {
		   if (evt.target.dataset.draft) {
		     edit('drafts', evt.target.dataset.index)
	       }
	     }	     
       });			
	}
});


page({
	id: 'pages',
	actions: {
	  'add': {
		  onclick: function() {

		  }
	  }	
	},
});

page({
	id: 'settings',
	actions: {
		// ...
	},
});


page({
	id: 'image-modal',
	actions: {
	  'apply': {
		  onclick: function() {
			  _('trix-editor').editor.insertHTML("<img src="+_("#insert-image-url").value+"></img>");
			  previous();
		  }
	  }	
	},
});


var files = [];

page({
	id: 'media',
	actions: {
		'upload': {
          onchange: function(event) {
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
		},
		'delete': {
			onclick: function() {
				_p("/admin/delete/", {
				  file: _('.active-item').src
			    }, function() {  loadImages(true);});
			}
		},
		'apply': {
			onclick: function() {
		      _("#insert-image-url").value = _('.active-item').src;
		      previous();		
			}
		}	
	},
	
	onshow: function() {
		loadImages(true);
		console.log("media prev: "+ pages['media'].previous);
		if (pages['media'].previous != 'image-modal') {
			_ac(_('#apply'), 'hidden');
		}
	}
});

var activeEntryType = 'posts';
var activeEntryID = 0;
page({
	id: 'front-matter',
	onshow: function() {
       _j('/admin/front-matter/'+activeEntryType+'/'+activeEntryID, function(j) {
	      _h("#front-matter", j.html);
	    });		
	}
});

page({
	id: 'editor',
	directLoad: function() {
		nav(rootPage);
	},
	actions:{
		'delete': {
			onclick: function() {
				
			}
		},
		'view': {
			onclick: function() {
		      _p('/admin/preview',{
                  body: _('#trix-input-1').value,
                  title: _("#title").value
                }, function() {
		          window.location = '/blogs/katie/2017/preview'
		        }
		      );
		    }	
		},
		'apply': {
			onclick: function() {
				
			}
		},
		'item-settings': {
			onclick: function() {
				nav('front-matter');
			}
		}
	},
});


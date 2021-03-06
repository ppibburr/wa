  
    var pages={};
    var current;
    var actionItems = [];
    var actions = {};
    
    function previous() {
		_("#back").click();
	}
    
    _ac(_("#back"),'hidden');
    
	_("#back").onclick = function() {
		prev = pages[current].previous;
		pages[current].previous = null;
		nav(prev);
	}    
    
    function page(obj) {
		pages[obj.id] = obj;
		if (obj.root == true) {
			nav(obj.id);
		}
	}
    
    function view(pg, fun) {
		for (var idx in pages) {
		  id = pages[idx].id;
		  _ac(_("#"+id),'hidden');
	    }
	    
	    for(action in pages[pg].actions) {
			act = pages[pg].actions[action]
		    for (evt in act) {
				_("#"+action)[evt] = act[evt];
		    }
		}
		
		console.log('view: '+pg);
	    _rc(_("#"+pg),'hidden');		
		
		if (fun) {
			fun();
		}
		
		route();
	}
    
    function nav(id, fun) {
 	  console.log('nav-to: '+id);
 	
 	  _e(actionItems, function(i,e){
		 _ac(e, 'hidden') 
	  });

      if (pages[id].actions) { 	  
 	  for (item in pages[id].actions) {
		  console.log('action-bar: show - '+item);
		  _rc(_("#"+item),'hidden');
		  
	  }}
	  
	  if (pages[id].previous) {
		  
	  } else {
		  console.log('current page: '+current);
		  console.log('previous: '+pages[id].previous);
		  pages[id].previous = current;
	  }
	  
	  current = id;
	  
	  if  (pages[id].root != true) {
	    back2(pages[id].previous);	  
	  } else {
		_ac(_("#back"),'hidden');  
	  }
	  
	  console.log('nav - show: '+id);
	  view(id, pages[id].onshow);
	  
	  window.location = "#"+id;
	  
	  if (fun) {
		  fun();
	  }
    }
	
	function nav2(what, to) {
	  _(what).onclick = function() {
		  nav(to);
	  }
    }
	
	function back2(w,fun) {
        pages[current].previous = w;
		_rc(_("#back"), 'hidden');
	}
		
	function action(pg, item, fun) {
		if (actions[pg]) {
		} else { 
		  actions[pg] = {};
	    }
		if (actions[pg].items) {
		} else { 
		  actions[pg].items = {};
	    }
		actions[pg].items[item] = {fun: fun}; 
	} 
	
	function route() {
		actionItems = _all('.action-item');
		_all('.nav_item', function(idx, ele) {
		  nav2("#"+ele.id, ele.dataset.dest);	
		});
	}
	
_ready(function() {	
   nav2("#home", 'nav');	
	
h = window.location.hash;
if (h) {
	console.log("route hash: " + h);
	if (_(h)) {
		console.log('hash nav:  '+_(h).id)
	  nav(_(h).id);
	} else {
		route();
	}
} else {
	route();
}
});

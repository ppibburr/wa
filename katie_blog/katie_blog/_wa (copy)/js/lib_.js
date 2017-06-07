

    function _(qs) {
      return document.querySelector(qs);
    }
    
    function _all(qs,fun) {
      l=document.querySelectorAll(qs);
      if (fun) {
	    _e(l,fun);
      }
	  return l;
	  
    }    
    
    function _rc(e, c) {
      e.classList.remove(c);
      return e;
    }
    
    function _ac(e, c) {
      e.classList.add(c);
      return e;
    }    

    function _ready(callback) {
      if (document.readyState === "complete" || (document.readyState !== "loading" && !document.documentElement.doScroll)) {
        callback();
      } else {
        document.addEventListener("DOMContentLoaded", callback);
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
    
    function _c(what, fun) {
	  _(what).onclick = fun;
	}
    	
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

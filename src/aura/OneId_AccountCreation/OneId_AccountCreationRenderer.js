({
	// Your renderer method overrides go here// 
	afterRender: function(component, helper) {
			
		this.superAfterRender();
		let modes = ['Billing', 'Shipping'];

		for(let i = 0; i < modes.length; i++){
				
			var city = component.find(modes[i]+'City');		
			var state = component.find(modes[i]+'State');
			//console.log('@@MAC afterRender city -> '+city);
			//console.log('@@MAC afterRender state-> '+state);
			//var addDocComponent = component.find('addDocComponent');
			//var street = addDocComponent.find(modes[i]+'Street');
			var currentFocus = -1;
			var c = component;
			var h = helper;
			
			if(state){
				state.getElement().addEventListener('click', function(e){
					h.clearContextLabelWarnings(c,e,h);
				});
			}
			

			/*street.getElement().addEventListener('click', function(e){
				h.clearContextLabelWarnings(c,e,h);
			});*/

		
			city.getElement().addEventListener('click', function(e){			
				h.clearContextLabelWarnings(c,e,h);
			});

			
			city.getElement().addEventListener('input', function(e){
				h.toggleInvalidCityWarning(c,e,h);			
				h.getPredictions(c, e, h, this.value, modes[i]);
			});

			city.getElement().addEventListener('keydown',function(e) {
				
				
				var x = document.getElementById("autocomplete-list-"+modes[i]);
				//console.log(modes[i]);
				if (x) x = x.getElementsByTagName("div");
				
				if (e.keyCode == 40) {				
					/*If the arrow DOWN key is pressed,
					increase the currentFocus variable:*/
					currentFocus++;
					/*and and make the current item more visible:*/
					
					addActive(x);
				} else if (e.keyCode == 38) { //up
					/*If the arrow UP key is pressed,
					decrease the currentFocus variable:*/
					currentFocus--;
					/*and and make the current item more visible:*/
					addActive(x);
				} else if (e.keyCode == 13) {
					/*If the ENTER key is pressed, prevent the form from being submitted,*/
					e.preventDefault();
					if (currentFocus > -1) {
					/*and simulate a click on the "active" item:*/
					if (x) x[currentFocus].click();
					}
				}else if(e.keyCode == 9){
					closeAllLists(null, modes[i]);
				}else{
					currentFocus = -1;
				}
			});			
		}

		addActive = function (x) {
			//console.log('addActive');
			/*a function to classify an item as "active":*/
			if (!x) return false;
			/*start by removing the "active" class on all items:*/
			removeActive(x);
			if (currentFocus >= x.length) currentFocus = 0;
			if (currentFocus < 0) currentFocus = (x.length - 1);
			/*add class "autocomplete-active":*/
			x[currentFocus].classList.add("autocomplete-active");
			}
			
		removeActive = function (x) {
			//	console.log('removeActive');
			/*a function to remove the "active" class from all autocomplete items:*/
			for (var i = 0; i < x.length; i++) {
				x[i].classList.remove("autocomplete-active");
			}
		}

		closeAllLists = function(elmnt, m) {
			
			/*close all autocomplete lists in the document,
			except the one passed as an argument:*/
			var y = document.getElementsByClassName("autocomplete-items-"+m);
		
			for (var i = 0; i < y.length; i++) {
				if (elmnt != y[i] && elmnt != city.getElement()) {
					//y[i].parentNode.removeChild(y[i]);
					h.removeList(c, h, m);
				}
			}
		}
		

		document.addEventListener("click", function (e) {
			for(let i = 0; i < modes.length; i++){
				closeAllLists(e.target, modes[i]);
			}  
			
  		});
	}
})
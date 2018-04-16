({
	doInit: function(component, event, helper) {
      //Fetch the expense list from the Apex controller
      helper.getAccount(component);
	  component.set("v.activeTab", "Identification");
	  component.set("v.oldTab", "Identification");

	  var device = $A.get("$Browser.formFactor");
	  if(device == 'TABLET') {
		  component.set("v.showTabs2",false);
		  component.set("v.showRightButton",true);

	  }
        // alert("You are using a " + device);
   	},
	changeTab : function (component, event, helper) {
		var target = event.getSource();
		var oldTabName = component.get("v.oldTab");
        var oldTab = component.find(oldTabName);
        var newTabName = target.get("v.value");
        var newTab = component.find(newTabName);
		// console.log(l);
		component.set("v.activeTab", newTabName);
		$A.util.addClass(newTab, 'slds-active');
		$A.util.removeClass(oldTab, 'slds-active');
		component.set("v.oldTab", newTabName);

	},
	moveRight : function (component, event, helper) {
console.log( 'right' );
		component.set("v.showTabs1", false);
		component.set("v.showTabs2", true);
		component.set("v.showLeftButton", true);

	},
	moveLeft : function (component, event, helper) {
console.log( 'left' );
		component.set("v.showTabs2", false);
		component.set("v.showTabs1", true);
		component.set("v.showRightButton", true);

	},
    jQueryStart: function(component, event, helper) {
        /*
         *  Handle the tab swiching
         */
        $('.slds-tabs--default__item').on('click', function(){
            // Deselect the previous tab
            var oldTab = $(".slds-active");
            $(oldTab).removeClass('slds-active');
            $(oldTab).find('a').attr('aria-selected', false);
            
            // Hide the previous content
            var oldContent = $('#'+$(oldTab).find('a').attr('aria-controls'));
            $(oldContent).removeClass('slds-show');
            $(oldContent).addClass('slds-hide');
            
            // Select the new tab
            $(this).addClass('slds-active');
            $(this).find('a').attr('aria-selected', true);
            
            // Show the new content
            var $contentToShow = $('#'+$(this).find('a').attr('aria-controls'));
            $contentToShow.removeClass('slds-hide');
            $contentToShow.addClass('slds-show');
        });
    }

})
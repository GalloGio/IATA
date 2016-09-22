({
	doInit: function(component, event, helper) {
      //Fetch the expense list from the Apex controller   
      helper.getAccount(component);
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
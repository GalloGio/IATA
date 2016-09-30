({
    doInit: function(component, event, helper) {
      	// Update the Searchstring with the preselection if it exists
      	var strPreselectedAccount = component.get("v.preselectedSearchString");

        if (strPreselectedAccount != '' && strPreselectedAccount !== undefined) {
        	component.set("v.searchString", strPreselectedAccount);

            // Hide the Input Element
            var inputElement = component.find('lookup');
            $A.util.addClass(inputElement, 'slds-hide');

            // Show the Lookup pill
            var lookupPill = component.find("lookup-pill");
            $A.util.removeClass(lookupPill, 'slds-hide');

            // Lookup Div has selection
            var inputElement = component.find('lookup-div');
            $A.util.addClass(inputElement, 'slds-has-selection');
        }

   	},
    /**
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        helper.doSearch(cmp);
    },

    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },

    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp);
    }
})
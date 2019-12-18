({
    init : function(component, event, helper) {
        var columns = [
            {type: 'url', fieldName: 'accountLink', label: 'Account Name', typeAttributes: {label: {fieldName: 'accountName'}, target: '_blank'}}, 
            {type: 'text', fieldName: 'locationType', label: 'Location Type'}, 
            {type: 'text', fieldName: 'locationClass', label: 'Location Class'},
            {type: 'text', fieldName: 'iataCode', label: 'IATA Code'},
            {type: 'text', fieldName: 'sector', label: 'Sector'},
            {type: 'text', fieldName: 'category', label: 'Category'},
            {type: 'text', fieldName: 'country', label: 'Country'}
        ];

        component.set('v.gridColumns', columns);
    },
    openHierarchy : function(component, event, helper) {
        helper.resetTable(component);

        var modal = component.find('hierarchy-modal');
        $A.util.removeClass(modal, 'slds-hide');

        var topParentId = event.getParam('arguments').topParentId
        console.log(topParentId);
        helper.loadHierarchy(component, topParentId);
    },
    closeHierarchy : function(component, event, helper) {
        helper.resetTable(component);

        var modal = component.find('hierarchy-modal');
        $A.util.addClass(modal, 'slds-hide');   
    }
})
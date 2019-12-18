({
    init : function(component, event, helper) {
        helper.initTable(component);
        helper.fetchData(component);
    },
    expandRow : function(component, event, helper) {
        var iconId = event.target.getAttribute('id');
        document.getElementById(iconId).classList.add("slds-hide");
        document.getElementById(iconId.replace('expand','collapse')).classList.remove("slds-hide");
        helper.displayChilds(component,iconId.replace('expand_',''));
    },
    collapseRow : function(component, event, helper) {
        var iconId = event.target.getAttribute('id');
        document.getElementById(iconId).classList.add("slds-hide");
        document.getElementById(iconId.replace('collapse','expand')).classList.remove("slds-hide");
        helper.hideChilds(component,iconId.replace('collapse_',''));
    },
    print : function(component,event,helper) {
        var accountId = component.get('v.accountId');
        window.open('/apex/AWW_AccountGroups_Printable?Id=' +  accountId);
    },
    openReport : function(component,event,helper) {
        var accountId = component.get('v.accountId');
        var action = component.get('c.getReportId');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var path = '/'+ response.getReturnValue() +'?isdtp=p1&pv0=' + accountId + '&pv1=' + accountId + '&pv2=' + accountId + '&export=1&enc=UTF-8&xf=xls';
                var popup = component.find('popup-warning');
                $A.util.addClass(popup, 'slds-hide');
                window.open(path, '_blank');
            }
        });

        $A.enqueueAction(action);
    },
    filterByCountry : function(component,event,helper) {
        var country = component.get('v.selectedCountry');

        if(!country || country == 'All') {
            component.set('v.gridData', component.get('v.originalData'));
            component.set('v.gridExpandedRows', component.get('v.originalExpRows'));
        } else {
            helper.hanldeCountryFilter(component,country);
        }        
    }
})
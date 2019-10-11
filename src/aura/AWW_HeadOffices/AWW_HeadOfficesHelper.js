({
    initTable : function(component) {
        var actions = [
            {label: 'Vew Hierachy', name: 'view_hierarchy', 'iconName': 'utility:hierarchy'}
        ];

        component.set('v.columns', [
            {label: 'Account Name', fieldName: 'accountLink', type: 'url', sortable : true, typeAttributes: {label: {fieldName: 'accountName'}, target: '_blank'}},
            {label: 'Location Type', fieldName: 'locationType', type: 'text', sortable : true},
            {label: 'IATA Code', fieldName: 'iataCode', type: 'text', sortable : true},
            {label: 'Country', fieldName: 'country', type: 'text', sortable : true},
            {type: 'action', typeAttributes: {rowActions: actions}}
        ]);
    },
    loadHeadOffices : function(component, helper) {
        var action = component.get('c.getHeadOffices');
        var accountId = component.get('v.accountId');
        action.setParams({'accountId': accountId});        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.data', result);
                component.set('v.filteredData', result);
                component.set('v.originalData', result);
                if(component.get('v.sortBy')) {
                    this.sortData(component,component.get('v.sortBy'),component.get('v.sortDirection'));
                }
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.currentPageNumber",1);
                this.buildData(component);
            }
        });

        $A.enqueueAction(action);
    },
    handleResetFilter : function(component) {
        var inputCmp = component.find('search-agency');
        inputCmp.set('v.value', '');
        inputCmp.setCustomValidity('');
        inputCmp.reportValidity();

        component.set('v.filteredData', component.get('v.originalData'));
        component.set("v.totalPages", Math.ceil(component.get('v.originalData')/component.get("v.pageSize")));
        component.set("v.currentPageNumber",1);
        component.set('v.sortBy','');
        component.set('v.sortDirection','');
        this.buildData(component);
    },
    validateInput : function(component) {
        var inputCmp = component.find('search-agency');
        var inputVal = inputCmp.get('v.value');
        var isValid = true;

        inputCmp.setCustomValidity('');

        if(!inputVal || inputVal.length < 3) {
            inputCmp.setCustomValidity('Please enter at least 3 characters before search.')
            isValid = false;
        }

        inputCmp.reportValidity();
        return isValid;
    },
    handleSearch : function(component, helper) {
        var data = component.get('v.originalData');
        var term = component.find('search-agency').get('v.value');

        if(term) {
            var regex = new RegExp(term, 'i');
            var results = data.filter(row => regex.test(row.accountName) || regex.test(row.iataCode) || regex.test(row.country));
            component.set('v.filteredData', results);
        } else {
            component.set('v.filteredData', data);
            component.set('v.sortBy','');
            component.set('v.sortDirection','');
        }
        component.set("v.totalPages", Math.ceil(component.get('v.filteredData').length/component.get("v.pageSize")));
        component.set("v.currentPageNumber",1);
        this.buildData(component);
    },
    sortData : function(component,fieldName,sortDirection,helper) {
        var data = component.get('v.filteredData');
        var reverse = sortDirection == 'asc' ? 1: -1;
        var key = function(a) { if(fieldName == 'accountLink'){return a['accountName']} else {return a[fieldName]}}
        data.sort(function(a,b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set('v.data', data);
        this.buildData(component);
    }
})
({
    initTable : function(component) {
        component.set('v.columns', [
            {title: 'Name', fieldname: 'contactName', sortable: true},
            {title: 'Type', fieldname: 'contactType', sortable: false},
            {title: 'Primary for', fieldname: 'primaryFor', sortable: true},
            {title: 'Title', fieldname: 'title', sortable: true},
            {title: 'Phone', fieldname: 'phone', sortable: false},
            {title: 'Mobile', fieldname: 'mobile', sortable: false},
            {title: 'Email', fieldname: 'email', sortable: true}
        ]);
    },
    loadContacts : function(component) {
        var action = component.get('c.getKeyContacts');
        var accountId = component.get('v.accountId');

        action.setParams({'accountId': accountId});  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.data', result);
                component.set('v.filteredData', result);
            }
        });

        $A.enqueueAction(action);    
    },
    handleSearch : function(component) {
        var data = component.get('v.data');
        var term = component.find('search-contact').get('v.value');

        if(term) {
            var regex = new RegExp(term, 'i');
            var results = data.filter(row => regex.test(row.contactName) || regex.test(row.accountSite));
            component.set('v.filteredData', results);
        } else {
            component.set('v.filteredData', data);
        }

        this.resetSort(component);
    },
    resetSort : function(component) {
        component.set('v.sortField', 'Name');
        component.set('v.ascOrder', true);
    },
    sortRecords : function(component, sortField, ascOrder) {
        var records = component.get('v.filteredData');
        records.sort(function(a,b) {
            var t1 = a[sortField].toLowerCase() == b[sortField].toLowerCase(),
                t2 = a[sortField].toLowerCase() > b[sortField].toLowerCase();
            return t1? 0: (ascOrder?-1:1)*(t2?-1:1);
        });

        component.set('v.filteredData', records);
    }
})
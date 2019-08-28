({
    initTable : function(component) {
        var columns = [
            {label: 'Account Name', fieldName: 'accountLink', type: 'url', sortable : true, typeAttributes: {label: {fieldName: 'accountName'}, target: '_blank'}},
            {label: 'CATEGORY', fieldName: 'subsidiaryType', type: 'text', sortable : true},
            {label: 'Percentage Held', fieldName: 'percentageTable', type: 'percent', sortable : true, typeAttributes : {maximumFractionDigits: 2, minimumFractionDigits: 2}}
        ];

        if(component.get('v.canEdit') == true) {
            var actions = [      
                {label: 'Edit', name: 'edit_record', iconName: 'utility:edit'},
                {label: 'Remove', name: 'remove_record', iconName: 'utility:delete'}
            ];
            columns.push({type: 'action', typeAttributes: {rowActions: actions}});
        }

        component.set('v.columns', columns);
    },
    fetchData : function(component) {
        var action = component.get('c.getSubsidiaries');
        action.setParams({
            accountId : component.get('v.accountId')
        });

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
    deleteRecord : function(component,event) {
        var modalCmp = component.find('delete-record');
        modalCmp.showModal(event.getParam('row').ownershipRecordId);
    },
    editRecord : function(component,event) {
        var modalCmp = component.find('owners-edit');
        var record = event.getParam('row');
        modalCmp.showModal('Subsidiary','Edit',record);
    },
    sortData : function(component,fieldName,sortDirection) {
        var data = component.get('v.filteredData');
        var reverse = sortDirection == 'asc' ? 1: -1;
        var key = function(a) { return a[fieldName.replace('Link','Name')]}
        data.sort(function(a,b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set('v.data', data);
        this.buildData(component);
    },
    buildData : function(component) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.filteredData");
        var x = (pageNumber-1)*pageSize;
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
            	data.push(allData[x]);
            }
        }
        
        component.set("v.data", data);
        this.generatePageList(component, pageNumber);
    },

    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    }
})
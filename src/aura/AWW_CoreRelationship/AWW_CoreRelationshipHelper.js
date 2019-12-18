({
    initTables : function(component) {
        var columns1 = [
            {label: 'Description', fieldName: 'label', type: 'text', sortable : true},
            {label: 'Value', fieldName: 'value', type: 'text', sortable : true, cellAttributes: { alignment: 'center' }}
        ];
        component.set('v.columns1', columns1);

        var columns2 = [
            {label: 'Country', fieldName: 'label', type: 'text', sortable : true},
            {label: 'Total', fieldName: 'value', type: 'number', sortable : true, cellAttributes: { alignment: 'center' }}
        ];
        component.set('v.columns2', columns2);

        var columns3 = [
            {label: 'Region', fieldName: 'label', type: 'text', sortable : true},
            {label: 'Total', fieldName: 'value', type: 'number', sortable : true, cellAttributes: { alignment: 'center' }}
        ];
        component.set('v.columns3', columns3);

        var columns4 = [
            {label: 'PASSENGER ENTITIES', fieldName: 'label', type: 'text', sortable : true},
            {label: 'Related', fieldName: 'value', type: 'boolean', cellAttributes: { alignment: 'center' }}
        ];
        component.set('v.columns4', columns4);

        var columns5 = [
            {label: 'CARGO ENTITIES', fieldName: 'label', type: 'text', sortable : true},
            {label: 'Related', fieldName: 'value', type: 'boolean', cellAttributes: { alignment: 'center' }}
        ];
        component.set('v.columns5', columns5);
    },
    fetchData : function(component) {
        var action = component.get('c.calculateAccountRelations');
        action.setParams({
            'accountId': component.get('v.accountId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                
                var result = response.getReturnValue();
                console.log(result);
                let aux = result.iataRelations;
                let popped = aux.pop();
                component.set('v.data1',aux );
                component.set('v.data2', result.countries);
                component.set('v.data3', result.regions);
                //result.externalRelationsPAX.unshift({label: 'Passenger', value: false});
                component.set('v.data4', result.externalRelationsPAX);
                //result.externalRelationsCARGO.unshift({label: 'Cargo', value: false});
                component.set('v.data5', result.externalRelationsCARGO);
                component.set('v.data6', popped);
                component.set('v.record', result.record);
            }   
        });

        $A.enqueueAction(action);
    },
    buildTable : function(rows,columns,data) {
        rows.push([columns[0].label,columns[1].label]);

        if(data) {        
            for(var i=0; i<data.length; i++) {
                rows.push([data[i].label,data[i].value]);
            }
        }
        rows.push(['','']);
    },
    handleExport : function(component,rows) {        
        var csvContent = 'data:text/csv;charset=utf-8,' + rows.map(e => e.join(';')).join('\n');
        var encodedUri = encodeURI(csvContent);
        var encodedUri = encodeURI(csvContent);
        var link = document.createElement('a');
        link.setAttribute('href', encodedUri);
        link.setAttribute('download', 'Core Relationships.csv');
        document.body.appendChild(link); 

        link.click();
    },
    checkHaveAMPAgencyManagement : function(component) {
        var action = component.get('c.getUserAccessRightsAMPAgencyManagement');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                
                var result = response.getReturnValue();
                console.log(result);
                component.set('v.haveAMPAgencyManagement',result );
            }   
        });

        $A.enqueueAction(action);
    }
})
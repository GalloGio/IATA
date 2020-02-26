({
    init : function(component,event,helper) {
        helper.initTables(component);
        helper.fetchData(component);
        helper.checkHaveAMPAgencyManagement(component);
    },
    edit : function(component,event,helper) {
        var modalCmp = component.find('edit-modal');
        var record = component.get('v.record');
        modalCmp.openEditModal(record);
    },
    refreshTab : function(component,event,helper) {
        if(event.getParam('tabName') == 'core_relationships') {
            helper.fetchData(component);
        }
    },
    exportDetails : function(component,event,helper) {
        var rows = [];

        rows.push(['Core Relationship with IATA (active accounts only)','']);
        let newElementForCoreRelationshipwithIATA = component.get('v.data1');
        if(newElementForCoreRelationshipwithIATA[newElementForCoreRelationshipwithIATA.length - 1].label != 'NDC engagement'){
            let newData = component.get('v.data6')[0];
            newElementForCoreRelationshipwithIATA.push({label: newData.label, value: newData.value});
        }
        helper.buildTable(rows,component.get('v.columns1'),newElementForCoreRelationshipwithIATA);        

        rows.push(['Relationship with External Entities PAX','']);
        let dataForPax = component.get('v.data4');
        if(dataForPax[dataForPax.length - 1].label != 'OTHER'){
            dataForPax.push({label: "OTHER", value: component.get('v.record').External_Entities_PAX_OTHER__c});
        }
        helper.buildTable(rows,component.get('v.columns4'),dataForPax); 

        rows.push(['Relationship with External Entities CARGO','']);
        let columnsUpdatedForCargo = component.get('v.columns4');
        columnsUpdatedForCargo[0].label = 'CARGO ENTITIES';
        let dataForCargo = component.get('v.data5');
        if(dataForCargo[dataForCargo.length - 1].label != 'OTHER'){
            dataForCargo.push({label: "OTHER", value: component.get('v.record').External_Entities_CARGO_OTHER__c});
        }
        helper.buildTable(rows,columnsUpdatedForCargo,dataForCargo); 

        rows.push(['Active Locations per Country','']);
        helper.buildTable(rows,component.get('v.columns2'),component.get('v.data2'));         

        rows.push(['Active Locations per Region','']);
        helper.buildTable(rows,component.get('v.columns3'),component.get('v.data3')); 
        
        helper.handleExport(component,rows);
    }
})
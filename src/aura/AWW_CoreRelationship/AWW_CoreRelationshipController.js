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

        rows.push(['Core Relationship with IATA','']);
        helper.buildTable(rows,component.get('v.columns1'),component.get('v.data1'));        

        rows.push(['Relationship with External Entities PAX','']);
        helper.buildTable(rows,component.get('v.columns4'),component.get('v.data4')); 

        rows.push(['Relationship with External Entities CARGO','']);
        helper.buildTable(rows,component.get('v.columns4'),component.get('v.data5')); 

        rows.push(['Accredited Locations per Country','']);
        helper.buildTable(rows,component.get('v.columns2'),component.get('v.data2'));         

        rows.push(['Accredited Locations per Region','']);
        helper.buildTable(rows,component.get('v.columns3'),component.get('v.data3')); 
        
        helper.handleExport(component,rows);
    }
})
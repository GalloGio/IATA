({

    initializeComponent : function(component, event, helper) {
        helper.getTableData(component, event);
    },

    updateMatchCriteria : function(component, event, helper) {
        component.set('v.PrivateMatchCriteria', event.getParam('value'));
        helper.retrieveTotalRecords(component);
        helper.retrieveRecords(component, true);
    },

    /*selectRecord : function(component, event, helper){
        helper.switchRow(component, parseInt(event.srcElement.dataset.id), event.srcElement.checked);
    },

    selectAllRecords : function(component, event, helper){
        helper.switchAllRows(component, event.srcElement.checked);
    },*/

    changeSort : function(component, event, helper){
        let clicked_element = event.srcElement;
        let sort_field = clicked_element.dataset.id;
        let current_sort_field = component.get('v.SortByField');
        let sort_order = component.get('v.SortOrder');
        if(sort_field === current_sort_field){
            if(sort_order === 'ASC'){
                sort_order = 'DESC';
            } else {
                sort_order = 'ASC';
            }
        } else {
            current_sort_field = sort_field;
            sort_order = 'DESC';
        }
        component.set('v.PageNumber', 1);
        component.set('v.SortByField', current_sort_field);
        component.set('v.SortOrder', sort_order);

        let isSuperUser = component.get('v.isSuperUser');
        let isGadmUser = component.get('v.isGadmUser');
        let businessUnits = component.get('v.businessUnits');

        helper.retrieveRecords(component, false, isSuperUser, isGadmUser, businessUnits, sort_order === 'DESC');
    },

    firstPage : function(component, event, helper) {
        let has_previous = component.get('v.HasPrevious');
        if(has_previous){
            component.set('v.PageNumber', 1);
            helper.updateTableRows(component);
        }
    },

    previousPage : function(component, event, helper) {
        let has_previous = component.get('v.HasPrevious');
        if(has_previous){
            let page_number = component.get('v.PageNumber');
            page_number = page_number - 1;
            component.set('v.PageNumber', page_number);
            helper.updateTableRows(component);
        }
    },

    nextPage : function(component, event, helper) {
        let has_next = component.get('v.HasNext');
        if(has_next){
            let page_number = component.get('v.PageNumber');
            page_number = page_number + 1;
            component.set('v.PageNumber', page_number);
            helper.updateTableRows(component);
        }
    },

    lastPage : function(component, event, helper) {
        let has_next = component.get('v.HasNext');
        if(has_next){
            let page_number = component.get('v.PageTotal');
            component.set('v.PageNumber', page_number);
            helper.updateTableRows(component);
        }
    },

    changePageSize : function(component, event, helper) {
        component.set('v.PageNumber', 1);
        component.set('v.PageSize', component.find('pageSizeInput').get('v.value'));
        helper.updateTableRows(component);
    },

    navigateToSObject : function (component, event, helper) {
        let record_id = event.currentTarget.id;
        let navigate = $A.get('e.force:navigateToSObject');
        navigate.setParams({
            'recordId': record_id,
            'slideDevName': 'detail'
        });
        navigate.fire();
    },
	 handleDetailsShow: function(component,event,helper) {
         var rowNum = event.getSource().get("v.name");
         var pageNum = component.get('v.PageNumber');
         var rowsPerPage = component.get('v.PageSize');
         var idx = (rowsPerPage * (pageNum-1)) + rowNum;
         var rowData = component.get('v.AllRecords')[idx];

         let selectedUserInfo = {};

         selectedUserInfo.con = {};
         selectedUserInfo.actorsData = {};
         selectedUserInfo.rolesData= {};
         selectedUserInfo.buData = {};

         if(! $A.util.isEmpty(rowData.Contact)) {
             selectedUserInfo.con = rowData.Contact;
         }
         if(! $A.util.isEmpty(rowData.ActorData)) {
             selectedUserInfo.actorsData = rowData.ActorData;
         }
         if(! $A.util.isEmpty(rowData.RolesData)) {
            selectedUserInfo.rolesData= rowData.RolesData;
         }
         if(! $A.util.isEmpty(rowData.BusinessUnitsData)) {
             selectedUserInfo.buData = rowData.BusinessUnitsData;
         }

         component.set('v.selectedUserInfo', selectedUserInfo);
         component.set("v.detailsShown", !component.get("v.detailsShown"));

		 helper.toggleTable(component);
		 helper.toggleDetails(component);

    },
    handleInvitationShow: function(component,event,helper) {
        component.set("v.invitationShown", !component.get("v.invitationShown"));
        helper.toggleTable(component);
        helper.toggleInvitation(component);
    },
    handleDetailsBackEvt: function(component,event,helper) {
         
         let dataModified = event.getParam('dataModified');
         let page = event.getParam('page');

         if(dataModified === true) {
             component.set("v.detailsShown", !component.get("v.detailsShown"));
             component.set('v.dataModified', true);
             helper.getTableData(component, event);
         }else{
             helper.toggleTable(component);
             if(page === 'detail'){
                component.set("v.detailsShown", !component.get("v.detailsShown"));
             	helper.toggleDetails(component);
                 
             } else if (page === 'invitation'){
                component.set("v.invitationShown", !component.get("v.invitationShown"));
             	helper.toggleInvitation(component);
             }
         }
    },

    showList : function(component, event, helper) {
        helper.handleReload(component, event);

    },


})
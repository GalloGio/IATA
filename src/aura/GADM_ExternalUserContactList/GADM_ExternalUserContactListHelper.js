({

    getTableData : function(component, event) {
        component.set('v.PrivateMatchCriteria', component.get('v.MatchCriteria'));
        component.set('v.SelectedRecordsMap', new Map());
        this.initializePageSizeSelectList(component);
        this.initializeColumnMetaData(component);
    },

    initializePageSizeSelectList : function(component) {
        let page_size = component.get('v.PageSize');
        let available_page_sizes = component.get('v.AvailablePageSizes');
        let options = [];
        for(let option in available_page_sizes){
            options.push({
                value: available_page_sizes[option],
                label: available_page_sizes[option],
                selected: (available_page_sizes[option] === page_size)
            });
        }
        component.find('pageSizeInput').set('v.options', options);
    },

    initializeColumnMetaData : function(component) {
        this.toggleSpinner(component);
        let column_metadata = {"Name":{"field_type":"STRING","field_label":"Name","field_is_sortable":true,"field_is_reference":false,"field_api_name":"Name"},
                             "Contact":{"field_type":"STRING","field_label":"Contact","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Contact"},
                             "Actor":{"field_type":"STRING","field_label":"Actor","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Actor"},
                             "ActorData":{"field_type":"STRING","field_label":"ActorData","field_is_sortable":false,"field_is_reference":false,"field_api_name":"ActorData"},
                             "Roles":{"field_type":"STRING","field_label":"Roles","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Roles"},
                             "RolesData":{"field_type":"STRING","field_label":"RolesData","field_is_sortable":false,"field_is_reference":false,"field_api_name":"RolesData"},
                             "Business Units":{"field_type":"STRING","field_label":"Business Units","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Business Units"},
                             "BusinessUnitsData":{"field_type":"STRING","field_label":"BusinessUnitsData","field_is_sortable":false,"field_is_reference":false,"field_api_name":"BusinessUnitsData"}};

        let table_columns = [{"is_selection_column":false,"field_name":"Name","field_api_name":"Name","field_label":"Name","field_type":"STRING","field_is_reference":false,"field_is_sortable":true},
                          {"is_selection_column":false,"field_name":"Actor","field_api_name":"Actor","field_label":"Actor","field_type":"STRING","field_is_reference":false,"field_is_sortable":false},
                          {"is_selection_column":false,"field_name":"Roles","field_api_name":"Roles","field_label":"Roles","field_type":"STRING","field_is_reference":false,"field_is_sortable":false},
                          {"is_selection_column":false,"field_name":"Business Units","field_api_name":"Business Units","field_label":"Business Units","field_type":"STRING","field_is_reference":false,"field_is_sortable":false}];

        component.set('v.ColumnMetadata', column_metadata);
        component.set('v.TableColumns', table_columns);
        this.getCurrentUserInfo(component, event);
    },


    getCurrentUserInfo : function(component, event) {
        let action = component.get('c.getCurrentUserInformation');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const userInformation = response.getReturnValue();
                if(! $A.util.isEmpty(userInformation)) {

                    component.set('v.currentUserInfo', userInformation);

                    let businessUnitsIds = [];
                    if(! $A.util.isEmpty(userInformation.grantedBusinessUnits)) {
                        let units = userInformation.grantedBusinessUnits;
                        for(let i in units) {
                            businessUnitsIds.push(units[i].Id);
                        }
                        component.set('v.businessUnits', businessUnitsIds);
                    }

                    let grantedRoles = userInformation.grantedRoles;
                    if(! $A.util.isEmpty(grantedRoles)) {

                        let isPowerUser = false;
                        let isSuperUser = false;
                        let isGadmUser = false;

                        for(let i in grantedRoles) {
                            if(grantedRoles[i].Name === 'Service Power User') {
                                isPowerUser = true;
                                continue;
                            }
                            if(grantedRoles[i].Name === 'Service Super User') {
                                isSuperUser = true;
                                continue;
                            }
                            if(grantedRoles[i].Name === 'GADM User') {
                                isGadmUser = true;
                                continue;
                            }
                        }

                        if(isPowerUser) {//Power User

                            component.set('v.isPowerUser', isPowerUser);
                            this.retrieveRecords(component, true, false, false, businessUnitsIds, false);

                        }else if(isSuperUser && !isPowerUser) {//Super User

                            component.set('v.isSuperUser', isSuperUser);
                            this.retrieveRecords(component, true, true, false, businessUnitsIds, false);

                        }else if(!isPowerUser && ! isSuperUser && isGadmUser) {//isGadmUser

                            component.set('v.isGadmUser', isGadmUser);
                            this.retrieveRecords(component, true, false, true, businessUnitsIds/*, false, null*/, false);

                        }else{

                            this.handleErrorMessage(component, 'Unknown user roles!');
                        }

                    }else{

                        this.handleErrorMessage(component, 'Unable to get user roles!');
                    }

                }else{

                    this.handleErrorMessage(component, 'Empty user information retrieved!');
                }

            }else{

                this.handleErrorMessage(component, 'Unable to get user information!');
            }
        });
        $A.enqueueAction(action);
    },

    retrieveRecords : function(component, criteria_have_changed, isSuperUser, isGadmUser, businessUnits, sortDesc){
        let action = component.get('c.getContactsVisibleToUser');
        action.setParams({
            'userId' : $A.get("$SObjectType.CurrentUser.Id"),
            'isSuperUser' : isSuperUser,
            'isGadmUser' : isGadmUser,
            'businessUnitsIds' : businessUnits,
            'sortDesc' : sortDesc
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {
                    let data = [];
                    for(let i = 0; i < result.length; i++) {

                        let roles = result[i].roles;
                        let rolesString = '';
                        if(! $A.util.isEmpty(roles)) {
                           rolesString = roles[0];
                           for(let j = 1; j < roles.length; j++) {
                               rolesString += ', ' + roles[j]
                           }
                        }

                        let rolesData = [];
                        if(! $A.util.isEmpty(result[i].rolesData)) {
                            rolesData = result[i].rolesData;
                        }


                        let businessUnits = result[i].businessUnits;
                        let businessUnitsString = '';
                        if(! $A.util.isEmpty(businessUnits)) {
                           businessUnitsString = businessUnits[0];
                           for(let j = 1; j < businessUnits.length; j++) {
                               businessUnitsString += ', ' + businessUnits[j];
                           }
                        }

                        let businessUnitData = [];
                        if(! $A.util.isEmpty(result[i].buData)) {
                            businessUnitData = result[i].buData;
                        }


                        let actors = result[i].actors;
                        let actorsString = '';
                        if(! $A.util.isEmpty(actors)) {
                           actorsString = actors[0];
                           for(let j = 1; j < actors.length; j++) {
                               actorsString += ', ' + actors[j]
                           }
                        }

                        let actorsData = [];
                        if(! $A.util.isEmpty(result[i].actorsData)) {
                            actorsData = result[i].actorsData;
                        }

                        let contact = {};
                        if(! $A.util.isEmpty(result[i].con)) {
                            contact = result[i].con;
                        }

                        let firstName = '';//firstName on Contact is NOT mandatory
                        if(! $A.util.isEmpty(contact.FirstName)) {
                            firstName = ', ' + contact.FirstName;
                        }

                        let row = {'Contact' : contact, 'Name' : contact.LastName + firstName, 'Actor' : actorsString, 'ActorData': actorsData, 'Roles' : rolesString, 'RolesData' : rolesData, 'Business Units' : businessUnitsString, 'BusinessUnitsData' : businessUnitData};
                        data.push(row);
                    }

                    let preserve_selected_records = component.get('v.PreserveSelectedRecords');
                    component.set('v.AllRecords', data);
                    component.set('v.TotalRecords', data.length);
                    component.set('v.TotalRecordsLoaded', result.length);

                    if(!preserve_selected_records && criteria_have_changed){
                        component.set('v.SelectedRecordsMap', new Map());
                        component.set('v.AllRecordsSelected', false);
                        this.updateSelectedRecords(component);
                        this.toggleTable(component);
                        this.toggleSpinner(component);
                    }
                //empty result - show empty table
                }else{
                    this.toggleTable(component);
                    this.toggleSpinner(component);
                }
                this.updateTableRows(component);
                if(component.get('v.dataModified')) {
                    this.showSaveMessage(component, 'Changes saved.');
                    component.set('v.dataModified', false);
                }

            } else if(state === 'ERROR'){
                this.handleErrorMessage(component, response.getError());
            }

        });
        $A.enqueueAction(action);
    },

    /*retrieveTotalRecords : function(component){
        let action = component.get('c.getTotalRecords');
        action.setParams({
           sobject_name: component.get('v.SObjectName'),
           match_criteria: component.get('v.PrivateMatchCriteria')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let total_records = parseInt(response.getReturnValue());
                component.set('v.TotalRecords', total_records);
            } else if(state === 'ERROR'){
                this.handleErrorMessage(component, response.getError());
                this.toggleTable(component);
                this.toggleSpinner(component);
            }
            this.toggleTable(component);
            this.toggleSpinner(component);
        });
        $A.enqueueAction(action);
    },*/

    updateTableRows : function(component) {
        this.updatePagination(component);
        let all_records = component.get('v.AllRecords');
        let table_rows = [];
        if(all_records.length){
            let first_record_on_page = component.get('v.FirstRecordOnPage');
            let last_record_on_page = component.get('v.LastRecordOnPage');
            let table_columns = component.get('v.TableColumns');
            let selected_records_map = component.get('v.SelectedRecordsMap');
            for(let i = first_record_on_page-1; i < last_record_on_page; i++){
                let row = [];
                for(let j = 0; j < table_columns.length; j++){
                    if(table_columns[j].is_selection_column){
                        row.push({
                            is_selection_column: true,
                            is_checked: selected_records_map.has(all_records[i].Id)
                        });
                    } else {
                        let fields = table_columns[j].field_api_name.split('.');
                        let value;
                        let reference;
                        if(fields.length > 1){
                            let record = all_records[i];
                            for(let k = 0; k < fields.length-1; k++){
                                record = record[fields[k]];
                            }
                            if(typeof(record) !== 'undefined'){
                                value = record[fields[fields.length-1]];
                                reference = record.Id;
                            }
                        } else {
                            value = all_records[i][table_columns[j].field_api_name];
                            reference = all_records[i].Id;
                        }
                        if(table_columns[j].field_type === 'PERCENT'){
                            value = (value != null) ? (value * 100) : 0
                        }
                            if(table_columns[j].field_override_type != undefined && table_columns[j].field_override_type != table_columns[j].field_type){
                            switch(table_columns[j].field_override_type){
                                case 'BOOLEAN':{
                                    if(table_columns[j].field_type === 'CURRENCY'
                                    || table_columns[j].field_type === 'DOUBLE'
                                    || table_columns[j].field_type === 'INTEGER'
                                    || table_columns[j].field_type === 'PERCENT'){
                                        value = (value != undefined && value != 0);
                                    } else {
                                        value = (value != undefined);
                                    }
                                    break;
                                }
                                case 'CURRENCY':{
                                    if(table_columns[j].field_type !== 'DOUBLE' && table_columns[j].field_type !== 'INTEGER'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'DATE':{
                                    if(table_columns[j].field_type !== 'DATETIME'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'DATETIME':{
                                    if(table_columns[j].field_type !== 'DATE'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'DOUBLE':{
                                    if(table_columns[j].field_type === 'BOOLEAN'){
                                        value = value ? 1.0 : 0.0;
                                    } else if(table_columns[j].field_type !== 'CURRENCY' && table_columns[j].field_type !== 'INTEGER' && table_columns[j].field_type !== 'PERCENT'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'INTEGER':{
                                    if(table_columns[j].field_type === 'BOOLEAN'){
                                        value = value ? 1 : 0;
                                    } else if((table_columns[j].field_type === 'CURRENCY' || table_columns[j].field_type === 'DOUBLE' || table_columns[j].field_type === 'PERCENT') && value != undefined){
                                        value = parseInt(value);
                                    } else {
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'PERCENT':{
                                    if(table_columns[j].field_type === 'DOUBLE' || table_columns[j].field_type === 'INTEGER'){
                                        if(value == undefined){
                                            value = 0;
                                        }
                                    } else {
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'STRING':{
                                    if(value != undefined){
                                        value = value.toString();
                                    }
                                    break;
                                }
                            }
                        }
                        row.push({
                            is_selection_column: false,
                            field_type: table_columns[j].field_override_type ? table_columns[j].field_override_type : table_columns[j].field_type,
                            reference: table_columns[j].field_is_reference ? reference : null,
                            value: value
                        });
                    }
                }
                table_rows.push(row);
            }
        }
        component.set('v.TableRows', table_rows);
    },

    updatePagination : function(component) {
        let page_number = component.get('v.PageNumber');
        let page_size = component.get('v.PageSize');
        let total_records = component.get('v.TotalRecordsLoaded');

        let pages_total = Math.ceil(total_records / page_size);

        let first_record_on_page = (total_records > 0) ? (((page_number - 1) * page_size) + 1) : 0;
        let last_record_on_page;
        if((page_number * page_size) > total_records){
            last_record_on_page = total_records;
        } else {
            last_record_on_page = (page_number * page_size);
        }

        let has_previous = page_number > 1;
        let has_next = page_number < pages_total;

        component.set('v.PageTotal', pages_total);
        component.set('v.FirstRecordOnPage', first_record_on_page);
        component.set('v.LastRecordOnPage', last_record_on_page);
        component.set('v.HasPrevious', has_previous);
        component.set('v.HasNext', has_next);

        component.find('firstButton').set('v.disabled', (!has_previous));
        component.find('previousButton').set('v.disabled', (!has_previous));
        component.find('nextButton').set('v.disabled', (!has_next));
        component.find('lastButton').set('v.disabled', (!has_next));
    },

    /*switchRow : function(component, index, is_checked){
        let all_records = component.get('v.AllRecords');
        let first_record_on_page = component.get('v.FirstRecordOnPage');
        let selected_records_map = component.get('v.SelectedRecordsMap');
        let index_on_page = (first_record_on_page + index - 1);
        if(index_on_page <= all_records.length){
            all_records[index_on_page].is_checked = is_checked;
            if(is_checked){
                selected_records_map.set(all_records[index_on_page].Id, all_records[index_on_page]);
            } else {
                selected_records_map.delete(all_records[index_on_page].Id);
                component.set('v.AllRecordsSelected', false);
            }
        }
        this.updateSelectedRecords(component);
    },

    switchAllRows : function(component, is_checked){
        let all_records = component.get('v.AllRecords');
        let selected_records_map = component.get('v.SelectedRecordsMap');
        if(is_checked){
            for(let i = 0; i < all_records.length; i++){
                all_records[i].is_checked = true;
                selected_records_map.set(all_records[i].Id, all_records[i]);
            }
        } else {
            for(let i = 0; i < all_records.length; i++){
                all_records[i].is_checked = false;
                selected_records_map.delete(all_records[i].Id);
            }
        }
        component.set('v.AllRecordsSelected', is_checked);
        this.updateTableRows(component);
        this.updateSelectedRecords(component);
    },*/

    updateSelectedRecords : function(component){
        let selected_records_map = component.get('v.SelectedRecordsMap');
        let selectedRecords = component.get('v.SelectedRecords');
        component.set('v.SelectedRecords', Array.from(selected_records_map.values()));
    },

    handleErrorMessage : function(component, message){
        let action = $A.get('e.force:showToast');
        action.setParams({
            title: 'Data Submission Result Error',
            message: message,
            type: 'error'
        });
        action.fire();
        this.toggleSpinner(component);
        this.toggleTable(component);
        component.set('v.ErrorMessage', message);
    },

    showSaveMessage : function(component, message) {
        let action = $A.get('e.force:showToast');
        action.setParams({
            title: 'Save successful',
            message: message,
            type: 'success'
        });
        action.fire();
    },

    toggleSpinner : function(component) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    },

    toggleTable : function(component) {
        var tableContainer = component.find('tableContainer');
        $A.util.toggleClass(tableContainer, 'slds-hide');
    },

    toggleDetails : function(component) {
        var detailsContainer = component.find('detailContainer');
        $A.util.toggleClass(detailsContainer, 'slds-hide');
    },
	toggleInvitation : function(component) {
        var invitationContainer = component.find('invitationContainer');
        $A.util.toggleClass(invitationContainer, 'slds-hide');
    },

    /*handleReload : function(component, event) {
        let tabId = component.get('v.tabId');
        let selectedTabId = event.getParam('value');
        if(tabId === selectedTabId) {
            let tableContainer = component.find('tableContainer');
            let isTabShown = !tableContainer.getElement().classList.contains('slds-hide');

            let detailShown = component.get('v.detailsShown');

            if(isTabShown && !detailShown) {
                component.set('v.PageNumber', 1);
                component.set('v.PageSize', 10);
                this.toggleTable(component);
                this.getTableData(component, event);
            }else if(!isTabShown && detailShown) {
                component.set('v.PageNumber', 1);
                component.set('v.PageSize', 10);
                component.set('v.detailsShown', false);
                this.getTableData(component, event);
            }
        }

    },*/


})
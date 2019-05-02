({

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
        let column_metadata = {"Name":{"field_type":"STRING","field_label":"Name","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Name"},
                             "Id":{"field_type":"STRING","field_label":"Id","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Id"},
                             "Actor":{"field_type":"STRING","field_label":"Actor","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Actor"},
                             "Roles":{"field_type":"STRING","field_label":"Roles","field_is_sortable":false,"field_is_reference":false,"field_api_name":"Roles"}};

        let table_columns = [{"is_selection_column":false,"field_name":"Name","field_api_name":"Name","field_label":"Name","field_type":"STRING","field_is_reference":false,"field_is_sortable":false},
                          {"is_selection_column":false,"field_name":"Actor","field_api_name":"Actor","field_label":"Actor","field_type":"STRING","field_is_reference":false,"field_is_sortable":false},
                          {"is_selection_column":false,"field_name":"Roles","field_api_name":"Roles","field_label":"Roles","field_type":"STRING","field_is_reference":false,"field_is_sortable":false}];

        component.set('v.ColumnMetadata', column_metadata);
        component.set('v.TableColumns', table_columns);
        this.retrieveRecords(component, true);
        //this.toggleSpinner(component);
    },

    retrieveTotalRecords : function(component){
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
    },

    retrieveRecords : function(component, criteria_have_changed){
        let action = component.get('c.getContactsVisibleToUser');
        action.setParams({
            'userId' : $A.get("$SObjectType.CurrentUser.Id")
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {
                    console.log('result:: ' + JSON.stringify(result));
                    let data = [];
                    for(let i = 0; i < result.length; i++) {
                        let roles = result[i].roles;
                        let rolesString = roles[0];
                        for(let j = 1; j < roles.length; j++) {
                            rolesString += ', ' + roles[j]
                        }
                        let actors = result[i].actors;
                        let actorsString = actors[0];
                        for(let j = 1; j < actors.length; j++) {
                            actorsString += ', ' + actors[j]
                        }

                        let firstName = '';//firstName on Contact is NOT mandatory
                        if(! $A.util.isEmpty(result[i].con.FirstName)) {
                            firstName = ', ' + result[i].con.FirstName;
                        }

                        let row = {'Actor' : actorsString, 'Id' : result[i].con.Id, 'Name' : result[i].con.LastName + firstName, 'Roles' : rolesString};
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
                    }
                }
                this.updateTableRows(component);
                this.toggleTable(component);
                this.toggleSpinner(component);

            } else if(state === 'ERROR'){
                this.handleErrorMessage(component, response.getError());
            }

        });
        $A.enqueueAction(action);
    },

    updateTableRows : function(component) {
        this.updatePagination(component);
        let all_records = component.get('v.AllRecords');
        console.log('allRecords:: ' + JSON.stringify(all_records));
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

    switchRow : function(component, index, is_checked){
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
    },

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

})
import { LightningElement, track, api } from 'lwc';

import getPIRFormList from '@salesforce/apex/ISSP_Baggage_Proration.getPIRFormList';
import OneId_Profile_Information from '@salesforce/label/c.OneId_Profile_Information';

//import {getUserStationsJS}  from 'c/portalIftpUtilsJS';
//import {stations}  from 'c/portalIftpUtilsJS';

export default class PortalProratePirFormList extends LightningElement {

    @track dataRecords = false;
    @track loading = false;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    fieldLabels = [
        'PIR Form Ref.','PIR File Ref.','Airline issuing','Airport (Arrival)','Passenger\'s First Name','Passenger\'s Last Name','Created Date','Passenger Converted Amount'
    ];
    
    @track IdPIRForm;

    @track showSearch = true;
    @track showForm = false;

    @track isActionEdit = false;
    @track isActionView = false;
    @track isToRefreshList = false;



    get dataRecords() {
        return this.dataRecords;
    } 
    
    /**
     * Handles 
     * 
     */
    onCheckNavigation(){
        this.checkNavigation = !this.checkNavigation ;
    }
    removeButtonSave(){
        console.log("removeButtonSave")
        // this.loading = false;
        this.isActionEdit = false ;
    }

    handleBackClick() {
        this.showSearch = true;
        this.showForm = false;

        console.log('handleBackClick isToRefreshList: ',this.isToRefreshList);
        if(this.isToRefreshList){
            this.isToRefreshList = false;
            this.handleSearch();
        }
        // this.IdPIRForm = '';
    }

    handleRefreshList(){
        console.log('INIT handleRefreshList');
        this.isToRefreshList = true;
    }

    handleSaveChldClick() {
        // this.loading = true;
        this.template.querySelector('c-portal-prorate-pir-form').handleSaveClick();
    }
    handleCancelChldClick(){
        this.isActionEdit = false;
        if(this.IdPIRForm === ''){ //do back biutton action
            this.handleBackClick()
        }else{  //else reset data on child component
            this.template.querySelector('c-portal-prorate-pir-form').reloadAgainNotEdit();
        }
        

    }    
    handleEditChldClick(){
        this.template.querySelector('c-portal-prorate-pir-form').reloadAgainEdit();
        this.isActionEdit = true;
    } 
    onRemoveLoading(){
        //this.loading = false;
    }

    handleResetButtonClick(){
        this.cleanErrors();
    }

    connectedCallback() {
        console.log('INIT connectedCallback');
        /*
        console.log(this.stationOptions);
        this.stationOptions = getUserStationsJS();
        console.log(this.stationOptions);
        */

        this.columns = [
            {label: '',
                type: 'button-icon',
                initialWidth: 10,
                typeAttributes: {
                    iconName: 'action:preview',
                    title: 'View', name: 'view',
                    variant: 'border-filled', alternativeText: 'View'}},
            {label: '',
                type: 'button-icon',
                initialWidth: 10,
                typeAttributes: {
                    iconName: 'action:edit',
                    title: 'Edit', name: 'edit',
                    variant: 'border-filled', alternativeText: 'Edit'}},  
            {label: 'PIR Form Ref.', fieldName: 'Name', type: 'text', sortable: true},
            {label: 'PIR File Ref.', fieldName: 'PIR_File_Ref__c', type: 'text', sortable: true},
            {label: 'Airline issuing', fieldName: 'Airline_issuing__r.Name', type: 'text', sortable: true},
            {label: 'Airport (Arrival)', fieldName: 'Airport_Arrival__c', type: 'text', sortable: true},
            {label: 'Passenger\'s First Name', fieldName: 'Passenger_s_First_Name__c', type: 'text', sortable: true},
            {label: 'Passenger\'s Last  Name', fieldName: 'Last_Name__c', type: 'text', sortable: true},
            {label: 'Created Date', fieldName: 'Created_Date_Formated__c', type: 'text', sortable: true},
            {label: 'Passenger Converted Amount', fieldName: 'PIR_Currency_of_conversion__c', type: 'text', sortable: true}
        ];

        this.handleSearch();
        console.log('END connectedCallback');
    }

    // The method onsort event handler
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        
        console.log('updateColumnSorting - fieldName : ', fieldName);
        console.log('updateColumnSorting - sortDirection : ', sortDirection);

        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.data = JSON.parse(JSON.stringify(this.sortData(fieldName, sortDirection)));
    }

    sortData(fieldName, sortDirection) {
        console.log('sortData - fieldName : ', fieldName);
        var auxdata = JSON.parse(JSON.stringify(this.data));
        var reverse = sortDirection !== 'asc';
        console.log('sortData - auxdata : ', auxdata);
        auxdata = Object.assign([],auxdata.sort(this.sortBy(fieldName, reverse ? -1 : 1)));
        console.log('sortData - sorted auxdata : ', auxdata);
        return auxdata;
    }

    sortBy(field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
            function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
            /*
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
            */
        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        }
    }

    handleSearch(){
        
        this.loading = true;
        getPIRFormList()
        .then(results => {
            console.log('handleSearch - results : ', results);
            console.log('handleSearch - results.length : ', results.length);
            console.log('handleSearch - results:1 : ', results[1]);


            if(results && results.length > 0) {

                results = results.map(
                    record => Object.assign(
                        { "Airline_issuing__r.Name": record.Airline_issuing__r.Name },
                        record
                    )
                );


                this.data = results;
                this.dataRecords = true;
            } else {
                this.dataRecords = false; 
            }
            this.loading = false;
        })
        .catch(error => {
            console.log('handleSearch - Error : ', error);
            console.log(error);

            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
            this.dataRecords = false;
        });  
        console.log('handleSearch - END');
        
    }


    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }

    handleCreateNewPIR(){
        this.showSearch = false;
        this.showForm = true;
        this.isActionEdit = true;
        this.isActionView = false;
        this.IdPIRForm = '';
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Row Action                                           *
    *                                                                              *
    * ******************************************************************************/

    handleRowAction(event){
        console.log('handleRowAction: Entrei');
        //let auxData = JSON.parse(JSON.stringify(this.data));
        const actionName = event.detail.action.name;
        const row = JSON.parse(JSON.stringify(event.detail.row));
        const { Id } = row;
        //const index = this.findRowIndexById(id);
        
        console.log('actionName: ' + actionName);
        console.log('event.detail.row: ', event.detail.row);
        console.log('row: ', row);
        console.log('Id: ' + Id);
        //console.log('index: ' + index);
        //console.log('auxData[index]: ', auxData[index]);
        
        switch (actionName) {
            case 'edit':
                this.isActionEdit = true;
                this.isActionView = false;
                break;
            case 'view':
                this.isActionEdit = false;
                this.isActionView = true;
                break;
            default:
        }

        this.IdPIRForm = Id;
        console.log('this.isActionEdit: ' + this.isActionEdit);
        console.log('this.IdPIRForm: ' + this.IdPIRForm);
        
        this.showSearch = false;
        this.showForm = true;
    }
    
    /*******************************************************************************
    *                                                                              *
    *  Methods to handle data export                                               *
    *                                                                              *
    * ******************************************************************************/

    handleExportToCsv(){
        // let columns = JSON.parse(JSON.stringify(this.columns));
        // let data = JSON.parse(JSON.stringify(this.data));
        // this.template.querySelector('c-portal-iftp-export-data').exportDataToCsv(columns, data, "TrainingRecordsDetailSearchResults.csv");
    }

    handleExportToExcel(){
        // let columns = JSON.parse(JSON.stringify(this.columns));
        // let data = JSON.parse(JSON.stringify(this.data));
        // this.template.querySelector('c-portal-iftp-export-data').exportDataToExcel(columns, data, "EmployeesSearchResults.xls");
    }

    handleCreate(event){
        console.log('INIT handleCreate LIST');
        console.log('event: ',event.detail);
        
        let parentid = event.detail;
        
        const createEvent = new CustomEvent('create', {
            detail: parentid
        });
        
        console.log('parentid: ',parentid);
        this.dispatchEvent(createEvent);

    } 
     
}
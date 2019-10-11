import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getEmployeeRecords from '@salesforce/apex/portalIftpEmployeeCtrl.getEmployeeRecords';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';

export default class PortalIftpEmployeeRecordTransfer extends LightningElement {

    @track userInfo;
    @track dataRecords = false;
    @track loading = true;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track selectedRows;
    @track employeesToTransfer;
    @track stationOptions;
    fieldLabels = [
        'uniqueRowId','Id','firstName', 'lastName', 'email', 'companyNumber'
    ];
    
    actionsRow = [
        { label: 'Ask for Transfer', name: 'askForTransfer' }
    ];

    @track showSearch = false;
    @track firstNameValue;
    @track lastNameValue;
    @track emailValue;
    @track stationValue;
    @track employeeCodeValue;
    @track openmodel = false;

    openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    } 
    
    get dataRecords() {
        return this.dataRecords;
    } 

    connectedCallback() {
        console.log('INIT connectedCallback');

        getUserInfo()
        .then(result => {
            let userInfo = JSON.parse(JSON.stringify(result));
            this.userInfo = userInfo;
        })

        getITPStations()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            
            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                //myTopicOptions.push({ label: myResult[el].City__c, value: myResult[el].Code__c });
                myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
            });

            this.stationOptions = this.sortData('label', 'asc', myTopicOptions);
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: 'ITP Stations',
                message: 'Unable to get ITP\'s Stations data from database.',
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(event);
            console.log('getITPStations - Error : ', error);
        });  

        this.columns = [
            {label: 'Last Name', fieldName: 'lastName', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
            {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
            {label: 'Station', fieldName: 'stationsCodesListAsString', type: 'text', sortable: true},
            {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
            {type: 'action', typeAttributes: { rowActions: this.actionsRow }}
        ];

        console.log('END connectedCallback');
    }
    handleChangeStation(event) {
        this.stationValue = event.detail.value;
    }
    
    handleChangeFirstName(event) {
        this.firstNameValue = event.detail.value;
    }
    handleChangeLastName(event) {
        this.lastNameValue = event.detail.value;
    }
    handleChangeEmail(event) {
        this.emailValue = event.detail.value;
    }
    handleChangeEmployeeCode(event) {
        this.employeeCodeValue = event.detail.value;
    }
    
    handleSearchButtonClick(){
        this.selectedRows = null;
        //Form Validations
        if(!this.firstNameValue && !this.lastNameValue && !this.employeeCodeValue){
            const event = new ShowToastEvent({
                title: 'Search Criteria Validation',
                message: 'Need to fill at least one field other than Station.',
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(event);
        } else {
            this.showSearch = true;
            this.handleSearch();
        }
    }

    handleResetButtonClick(){
        this.showSearch = false;
        this.data = null;
        this.firstNameValue = null;
        this.lastNameValue = null;
        this.emailValue = null;
        this.employeeCodeValue = null;
        this.selectedRows = null;
        this.employeesToTransfer = null;
        this.stationValue = null;
    }

    handleCancel(){
        this.handleResetButtonClick();
    }

    handleRowAction(event){
        //let auxData = JSON.parse(JSON.stringify(this.data));
        //const actionName = event.detail.action.name;
        const row = event.detail.row;
        //const { uniqueRowId } = row;
        //const index = this.findRowIndexById(uniqueRowId);
        
        if(this.employeesToTransfer == null){
            this.employeesToTransfer = [];
        }

        this.employeesToTransfer.push(row);

        this.openmodal();
    }

    handleSelectAll(){
        if(this.selectedRows.length > 0){
            this.employeesToTransfer = this.selectedRows;
        }
        this.openmodal();
    }
    
    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.uniqueRowId === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }


    handleSearch(){
        let auxSearchValues = new Map();
        //List
        auxSearchValues = [
            this.firstNameValue,
            this.lastNameValue,   
            this.emailValue,
            this.employeeCodeValue,
            this.stationValue
        ];

        this.loading = true;
        getEmployeeRecords({searchValues: auxSearchValues, accountId: this.userInfo.accountId})
        .then(results => {
            if(results && results.length > 0) {
                this.data = this.sortData('lastName', 'asc', JSON.parse(JSON.stringify(results)));
                console.log('handleSearch - this.data: ', this.data);
                this.dataRecords = true;
                this.data.forEach(rec =>{
                    rec.upperCase = 'to-upper-case';
                });
            } else {
                this.dataRecords = false; 
            }
            this.loading = false;
        })
        .catch(error => {
            console.log('handleSearch - Error : ' + error);
            console.log(error);
            this.loading = false;
            this.dataRecords = false;
            const event = new ShowToastEvent({
                title: 'Search Employees Result',
                message: 'Unbale to get Search Results from database.',
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(event);
        }); 
    }

    getSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    /*******************************************************************************
    *                                                                              *
    *  Sorting Methods                                                             *
    *                                                                              *
    * ******************************************************************************/
    // The method onsort event handler
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        let auxdata = this.data;
        this.data = this.sortData(fieldName, sortDirection, auxdata);
    }

    sortData(fieldName, sortDirection, auxdata) {
        var reverse = sortDirection !== 'asc';
        auxdata = Object.assign([],auxdata.sort(this.sortBy(fieldName, reverse ? -1 : 1)));
        return auxdata;
    }

    sortBy(field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
            function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
     
        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        }
    }
    
}
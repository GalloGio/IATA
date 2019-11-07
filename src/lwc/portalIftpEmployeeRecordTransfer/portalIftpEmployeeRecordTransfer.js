import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

import getEmployeeRecords from '@salesforce/apex/portalIftpEmployeeCtrl.getEmployeeRecords';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import requestEmployeeTransfer from '@salesforce/apex/PortalIftEmployeeRecordsManagement.requestEmployeeTransfer';

export default class PortalIftpEmployeeRecordTransfer extends LightningElement {

    @track userInfo;
    @track dataRecords = false;
    @track loading = true;
    @track loadingModal = false;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track employeesToTransfer;
    @track stationOptions;
    @track loadingSearchCriteria = false;
    @track showSearchCriteria = false;
    
    fieldLabels = [
        'uniqueRowId','Id','firstName', 'lastName', 'email', 'companyNumber'
    ];
    
    actionsRow = [
        { label: 'Ask for Transfer', name: 'askForTransfer' }
    ];

    @track showSearch = false;
    @track firstNameValue = null;
    @track lastNameValue = null;
    @track emailValue = null;
    @track stationValue = null;
    @track employeeCodeValue = null;
    @track openmodal = false;
    @track recordRequestTransfer = [];
   
    get dataRecords() {
        return this.dataRecords;
    } 

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {

        registerListener('stationsChanged', this.handleStationsChanged, this);

        this.initData();

        this.columns = [
                {label: '',
                type: 'button-icon',
                initialWidth: 30,
                typeAttributes: {
                    iconName: 'utility:edit',
                    title: 'Ask For Transfer',
                    name: 'askForTransfer',
                    variant: 'border-filled',
                    alternativeText: 'Ask For Transfer'
                }
            },
            {label: 'Last Name', fieldName: 'lastName', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
            {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
            {label: 'Station', fieldName: 'stationsCodesListAsString', type: 'text', sortable: true},
            {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
        ];

    }

    initData(){
        getUserInfo()
        .then(result => {
            let userInfo = JSON.parse(JSON.stringify(result));
            this.userInfo = userInfo;

            getITPStations({accountId: userInfo.accountId})
            .then(result2 => {
                let myResult = JSON.parse(JSON.stringify(result2));
                
                let myTopicOptions = [];
    
                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
                });
    
                this.stationOptions = this.sortData('label', 'asc', myTopicOptions);
    
                this.showSearchCriteria = true;
                this.loadingSearchCriteria = false;
    
                if(this.stationValue){
                    let stationOptions = JSON.parse(JSON.stringify(this.stationOptions));
                    let exists = false;
                    stationOptions.forEach(opt =>{
                        if(opt.value === this.stationValue){
                            exists = true;
                        }
                    })
                    if(!exists){
                        this.stationValue = null;
                    }
                }
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'ITP Stations',
                    message: 'Unable to get ITP\'s Stations data from database.',
                    variant: 'error',
                    mode: 'pester'
                });
                this.dispatchEvent(event);
            });
        })
    }

    disconnectedCallback() {
		unregisterAllListeners(this);
	}

    handleStationsChanged(){
        this.showSearchCriteria = false;
        this.loadingSearchCriteria = true;
        this.initData();
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
        this.employeesToTransfer = null;
        this.stationValue = null;
    }

    handleCancel(){
        this.handleResetButtonClick();
    }

    /***********************************************************
    *                                                          *
    *  Methods to handle Row Action                            *
    *                                                          *
    ************************************************************/

    handleRowAction(event){
        //let auxData = JSON.parse(JSON.stringify(this.data));
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const { uniqueRowId } = row;
        const index = this.findRowIndexById(uniqueRowId);

        let auxData = JSON.parse(JSON.stringify(this.data));
        let recordRequestTransfer = {};
        recordRequestTransfer.firstName = auxData[index].firstName;
        recordRequestTransfer.lastName = auxData[index].lastName;
        recordRequestTransfer.acrId = auxData[index].name;

        console.log('recordRequestTransfer', recordRequestTransfer);

        switch(actionName){
            case 'askForTransfer':
                this.openmodal = true;
                this.recordRequestTransfer = recordRequestTransfer;
                
                this.recordRequestTransfer.lmsUsername = '';
                this.recordRequestTransfer.formerItpName = '';
                this.recordRequestTransfer.formerStations = '';
                this.recordRequestTransfer.comments = '';
                break;
            default:
                break;
        }  
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

    /***********************************************************
    *                                                          *
    *  Methods to handle Ask for Transfer                      *
    *                                                          *
    ************************************************************/

    handleRequestTransferEmployeeFirstNameChange(event){
        this.recordRequestTransfer.firstName = event.detail.value;

    }

    handleRequestTransferEmployeeLastNameChange(event){
        this.recordRequestTransfer.lastName = event.detail.value;
    }

    handleRequestTransferEmployeeLmsUsernameChange(event){
        this.recordRequestTransfer.lmsUsername = event.detail.value;
    }

    handleRequestTransferEmployeeFormerITPNameChange(event){
        this.recordRequestTransfer.formerItpName = event.detail.value;
    }

    handleRequestTransferEmployeeFormerStationsChange(event){
        this.recordRequestTransfer.formerStations = event.detail.value;
    }

    handleRequestTransferEmployeeCommentsChange(event){
        this.recordRequestTransfer.comments = event.detail.value;
    }

    handleRequestTransferSave(){
        this.loadingModal = true;

        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                if(inputCmp.name === 'first_name'){
                    inputCmp.setCustomValidity(this.recordRequestTransfer.firstName ? '': 'Complete this field');

                }
                if(inputCmp.name === 'last_name'){
                    inputCmp.setCustomValidity(this.recordRequestTransfer.lastName ? '': 'Complete this field');
                }
                if(inputCmp.name === 'lms_username'){
                    inputCmp.setCustomValidity(this.recordRequestTransfer.lmsUsername ? '': 'Complete this field');
                }
                if(inputCmp.name === 'former_itp_name'){
                    inputCmp.setCustomValidity(this.recordRequestTransfer.formerItpName ? '': 'Complete this field');
                }
                if(inputCmp.name === 'former_stations'){
                    inputCmp.setCustomValidity(this.recordRequestTransfer.formerStations ? '': 'Complete this field');
                }

                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if(allValid){
            let recordRequestTransfer = JSON.parse(JSON.stringify(this.recordRequestTransfer));

            requestEmployeeTransfer({recordToRequestTransfer: recordRequestTransfer})
            .then(result => {
                
                const event = new ShowToastEvent({
                    title: 'Request Employee Transfer Result',
                    message: result.result_message,
                    variant: 'success',
                    mode: 'pester'
                });
                this.dispatchEvent(event);

                this.loadingModal = false;
                this.openmodal = false;
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Request Employee Transfer Result',
                    message: 'Unable to Complete your request.',
                    variant: 'error',
                    mode: 'pester'
                });
                this.dispatchEvent(event);
                this.loadingModal = false;
            });
        } else{
            this.loadingModal = false;
        }
    }

    cancelAskForTransfer(){
        this.openmodal = false;
        this.recordRequestTransfer = [];
        this.loadingModal = false;
    }


    /***********************************************************
    *                                                          *
    *  Methods to handle Search                                *
    *                                                          *
    ************************************************************/

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

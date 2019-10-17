import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners} from 'c/pubsub';

import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement';
import updateCertificationProficiency from '@salesforce/apex/portalIftpTrainingRecords.updateCertificationProficiency';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getCertificationTypes from '@salesforce/apex/PortalIftpUtils.getCertificationTypes';
import getITPTrainingCoordinators from '@salesforce/apex/portalIftpTrainingRecords.getITPTrainingCoordinators';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';

export default class PortalIftpProficiencyManagement extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track selectedRows;
    fieldLabels = [
        'uniqueRowId','certificationId','account_contact_role_Id','firstName', 'lastName', 'companyNumber', 'trainingName', 'itpName', 'expirationDate', 'proficiency', 'station', 'setProficiency'
    ];
    
    @track showSearchCriteria = false;
    @track loadingSearchCriteria = false;
    @track showSearch = false;
    @track stationValue;
    @track firstNameValue;
    @track lastNameValue;
    @track aircraftTypeValue;
    @track proficiencyValue = 'No';
    @track showAllProficientButton = false;

    itpStations;
    @track stationOptions;
    @track aircraftTypeOptions;
    @track proficiencyGrantedByValue;
    @track proficiencyGrantedByOptions;
    
    @track showButtonAllProficient = false;
    @track showDatatableButtons = false;
           userInfo; 

    get proficiencyOptions() {
        return [
            { label: 'No', value: 'No' },
            { label: 'Yes', value: 'Yes' },
            { label: 'All', value: 'All' },
        ];
    }

    get dataRecords() {
        return this.dataRecords;
    } 

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.showSearchCriteria = false;
        this.loadingSearchCriteria = true;
        registerListener('stationsChanged', this.handleStationsChanged, this);
       
         getCertificationTypes({certificationType: 'Aircraft'})
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));
                
                let myTopicOptions = [];

                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el].Name, value: myResult[el].Id });
                });

                this.aircraftTypeOptions = myTopicOptions;
                this.cleanErrors();
            })
            .catch(error => {
                console.error('getCertificationTypes - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  

        this.columns = [
            {label: 'Last Name', fieldName: 'lastName', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
            {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
            {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
            {label: 'Aircraft type', fieldName: 'trainingName', type: 'text', sortable: true},
            {label: 'Expiration Date', fieldName: 'expirationDate', type: 'date', sortable: true, typeAttributes: {year: "numeric", month: "long", day: "2-digit"}},
            {label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true, 
                cellAttributes: { class: { fieldName: 'proficiencyStatus' }, iconName: { fieldName: 'proficiencyIcon' }, iconPosition: 'right' } },
            {label: 'Proficiency Granted By', fieldName: 'proficiencyGrantedBy', type: 'text', sortable: true},
            {label: 'Set Proficiency', fieldName: 'setProficiency', type: 'text'},
            {type: 'action', typeAttributes: { rowActions: this.getAllActions }, cellAttributes: { class: { fieldName: 'showPicklist' }}},
        ];
        this.initData();
    }

    initData(){

        getUserInfo()
        .then(result =>{
            let myResult = JSON.parse(JSON.stringify(result));
            if(myResult){
                this.userInfo = myResult;               
                if(myResult.primaryStationCode){
                    if(!this.stationValue && !this.showSearch){
                        this.stationValue = myResult.primaryStationCode;
                    } else {
                        if(this.stationValue && !this.showSearch){
                            this.stationValue = myResult.primaryStationCode;
                        }
                    }
                } else {
                    if(this.stationValue && !this.showSearch){
                        this.stationValue = null;
                    }
                }
                getITPStations({accountId: myResult.accountId})
                .then(result => {
                    let myResult = JSON.parse(JSON.stringify(result));
    
                    this.itpStations = myResult;
                    let myTopicOptions = [];
    
                    Object.keys(myResult).forEach(function (el) {
                        //myTopicOptions.push({ label: myResult[el].City__c, value: myResult[el].Code__c });
                        myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
                    });
                    this.stationOptions = this.sortData('label', 'asc', myTopicOptions);
                    this.cleanErrors();
                })
                .catch(error => {
                    console.error('getITPStations - Error : ' + error);
                    this.mainErrorMessage = error;
                    this.error = error;
                }); 
            }

        })
        .catch(error => {
            console.error('getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        }); 

        getITPStations()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));

            this.itpStations = myResult;
            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
            });
            this.stationOptions = this.sortData('label', 'asc', myTopicOptions);
            this.cleanErrors();
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
            console.error('getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
            this.loadingSearchCriteria = false;
        });  
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
    handleChangeAircraftType(event) {
        this.aircraftTypeValue = event.detail.value;
    }
    handleChangeProficiency(event) {
        this.proficiencyValue = event.detail.value;
    }
    
    handleSearchButtonClick(){
        this.selectedRows = null;
        //Form Validations
        const allValid = [...this.template.querySelectorAll('lightning-input'), ...this.template.querySelectorAll('lightning-combobox') ]
        .reduce((validSoFar, inputCmp) => {
                        if(inputCmp.name === 'station'){
                            if(!this.stationValue){
                            inputCmp.setCustomValidity('Complete this field.');
                            } else{
                                inputCmp.setCustomValidity('');
                            }
                        }
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allValid){
            
            if(this.proficiencyValue === 'No' || this.proficiencyValue === 'All'){
                this.showButtonAllProficient = true;
            } 

            this.showSearch = true;
            this.handleSearch();
        }
    }

    getAllActions(row, doneCallback){
        let result;

        result = [
            { label: 'Yes', name: 'Yes'}
        ];
        
        doneCallback(result);
    }

    handleResetButtonClick(){
        this.showSearch = false;
        this.data = null;
        this.stationValue = null;
        this.firstNameValue = null;
        this.lastNameValue = null;
        this.aircraftTypeValue = null;
        this.proficiencyValue = 'No';
        this.error = '';
        this.mainErrorMessage = '';
        this.selectedRows = null;
        this.showDatatableButtons = false;
        this.showAllProficientButton = false;
    }

    handleCancel(){
        this.handleResetButtonClick();
    }

    handleSelectAllProficient(){
        this.setProficiency('allproficient');
    }

    handleRowAction(event){
        let auxData = JSON.parse(JSON.stringify(this.data));
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const { uniqueRowId } = row;
        const index = this.findRowIndexById(uniqueRowId);
        
        this.showDatatableButtons = true;

        switch(actionName){ 
            case 'Yes':
                auxData[index].setProficiency = 'Yes';
                break;
            default:
                break;
            
        }
        this.data = auxData;        
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
        let i;
        let auxStations = (this.stationValue == null) ? 'null' : this.stationValue;
        let auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        let auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
        
        if(this.stationValue === 'All'){
            
            for(i=0; i < this.stationOptions.length; i++){
                if(this.stationOptions[i].value === 'All'){
                    auxStations = '';
                }else{
                    auxStations = (auxStations == '' ) ? this.stationOptions[i].value : auxStations + ',' + this.stationOptions[i].value;
                }
            }
        }

        if(this.aircraftTypeValue === 'All'){
            for(i=0; i < this.aircraftTypeOptions.length; i++){
                if(this.aircraftTypeOptions[i].value === 'All'){
                    auxAircraftType = '';
                }else{
                    auxAircraftType = (auxAircraftType === '' ) ? this.aircraftTypeOptions[i].value : auxAircraftType + ',' + this.aircraftTypeOptions[i].value;
                }
            }
        }
        if(this.proficiencyValue === 'All'){
            auxProficiency = 'All';
        }

        //List
        auxSearchValues = [
            auxStations,
            'null',               //place holder for auxItp
            'Active',               //place holder for auxExperiationstatus
            auxAircraftType,
            auxProficiency,
            'null',               //place holder for auxFromDate
            'null',                //place holder for auxToDate
            this.firstNameValue,
            this.lastNameValue
        ];
     
        this.loading = true;
        getTrainingRecords({searchValues: auxSearchValues, searchType: 'ProficiencyManagement'})
        .then(results => {
            if(results && results.length > 0) {
                
                results.forEach(rec =>{
                    rec.upperCase = 'to-upper-case';
                    if(rec.proficiency === 'No'){
                        rec.showPicklist = 'slds-show';
                    } else if(rec.proficiency === 'Yes'){
                        rec.showPicklist = 'slds-hide-proficiency-action';
                    }
                })
                this.data = results;
                this.data = this.sortData('lastName', 'asc', JSON.parse(JSON.stringify(this.data)));

                if(auxProficiency === 'All' || auxProficiency === 'No'){

                    getITPTrainingCoordinators()
                    .then(r =>{
                        if(r && r.length > 0){
                            let trainingCoordinatorsList = JSON.parse(JSON.stringify(r));
                            let proficiencyGrantedByOptions = [];

                            trainingCoordinatorsList.forEach(el =>{
                                proficiencyGrantedByOptions.push({ label: el.Last_Name__c.toUpperCase() + ', ' + el.First_Name__c, value: el.Last_Name__c.toUpperCase() + ', ' + el.First_Name__c });
                                if(el.Contact__c === this.userInfo.contactId){
                                    this.proficiencyGrantedByValue = el.Last_Name__c.toUpperCase() + ', ' + el.First_Name__c;
                                }
                            });
                            this.proficiencyGrantedByOptions = this.sortData('label', 'asc', proficiencyGrantedByOptions);

                            this.showAllProficientButton = true;

                            this.dataRecords = true;
                        } else {
                            // unable to get training coordinators list
                            this.dataRecords = false; 
                        }
                        this.loading = false;
                    })
                } else {
                    this.showAllProficientButton = false;
                    this.dataRecords = true;
                    this.loading = false;
                }
            }  else {
                this.showAllProficientButton = false;
                this.dataRecords = false;
                this.loading = false;
            }   
            this.cleanErrors();
        })
        .catch(error => {
            console.error('handleSearch - Error : ', error);
            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
            this.dataRecords = false;
        });  
    }

    handleChangeproficiencyGrantedBy(event){
        this.proficiencyGrantedByValue = event.detail.value;
    }


    handleSave(){
        let dataToSave = [];
        let auxData = JSON.parse(JSON.stringify(this.data));
        let addressId;
        let addressCode;
        let grantedBy = JSON.parse(JSON.stringify(this.proficiencyGrantedByValue));
        this.itpStations.forEach(station =>{
            if(station.Code__c === this.stationValue){
                addressId = station.Id;
                addressCode = station.Code__c;
            }
        });

        Object.keys(auxData).forEach(function (el) {

            if(auxData[el].setProficiency && auxData[el].setProficiency === 'Yes' && auxData[el].setProficiency !== auxData[el].proficiency){
                let recordTosave ={};
                recordTosave.contact_role_certification_Id = auxData[el].certificationId;
                recordTosave.proficiency = auxData[el].setProficiency;
                recordTosave.proficiency_granted_by = grantedBy;
                recordTosave.address_Id = addressId;
                recordTosave.employee_code = auxData[el].companyNumber;
                recordTosave.address_code = addressCode;
                recordTosave.certification_code = auxData[el].trainingCode;
                recordTosave.certification_name = auxData[el].trainingName;
                dataToSave.push(recordTosave);
            }
        });

        this.loading = true;
        updateCertificationProficiency({dataToSave: dataToSave })
        .then(results => {
            
            if(results) {

                this.cleanErrors();
            
                Object.keys(auxData).forEach(function (el) {
                    if(auxData[el].setProficiency){ 
                        auxData[el].proficiency = auxData[el].setProficiency;
                        auxData[el].setProficiency = '';
                        auxData[el].proficiencyStatus = 'Success';
                        auxData[el].proficiencyIcon = 'utility:check';
                        auxData[el].proficiencyGrantedBy = grantedBy;
                    }
                });   
                this.data = auxData;                 
            } else {
                this.mainErrorMessage = 'An Error Occurred!';
            }
            this.loading = false;
            
            
        })
        .catch(error => {
            console.error('handleSearch - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
        });  
    }

    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }

    getSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    setProficiency(level) {
        let i, index;
        let auxData = JSON.parse(JSON.stringify(this.data));

        if(this.selectedRows.length > 0){
            this.showDatatableButtons = true;
        }
       
        for(i=0; i < this.selectedRows.length; i++){
            index = this.findRowIndexById(this.selectedRows[i].uniqueRowId);
            auxData[index].setProficiency = 'Yes';
        }
        this.data = auxData;
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Listeners                                            *
    *                                                                              *
    * ******************************************************************************/

    disconnectedCallback() {
		unregisterAllListeners(this);
	}

    handleStationsChanged(){
        this.showSearchCriteria = false;
        this.loadingSearchCriteria = true;
        this.initData();
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
        let auxdata = JSON.parse(JSON.stringify(this.data));
        this.data = this.sortData(fieldName, sortDirection, auxdata);
    }

    sortData(fieldName, sortDirection, auxdata) {
        let reverse = sortDirection !== 'asc';
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

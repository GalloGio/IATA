import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecordsDetail';
import getCertificationTypesWithLevel from '@salesforce/apex/PortalIftpUtils.getCertificationTypesWithLevel';
import getAllTrainingRecordsForDetailView from '@salesforce/apex/portalIftpTrainingRecords.getAllTrainingRecordsForDetailView';
import getAirlineITPsByStation from '@salesforce/apex/PortalIftpUtils.getAirlineITPsByStation';

export default class portalIftpTrainingRecordsDetail extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    fieldLabels = [
        'firstName', 'lastName', 'companyNumber', 'trainingName', 'itpName', 'expirationStatus', 'expirationDate', 'expirationIcon', 'proficiency', 'station', 'PREREQ EXPIRATION' 
    ];
    

    @track showSearch = false;
    @track stationValue;
    @track itpValue;
    @track experiationstatusValue;
    @track aircraftTypeValue = 'All Level 2';
    @track levelValue = 'Level 2';

    @track datePeriodValue;
    @track fromDateValue;
    @track fromDateMinValue = new Date(2019, 0, 1);
    @track fromDateMaxValue;
    @track toDateValue;
    @track toDateMinValue;
    @track toDateMaxValue;


    @track stationOptions;
           itpBYStationMap; 
    @track itpOptions;
    @track aircraftTypeOptions;
           certificationTypesWithLevel;
    
    get experiationstatusOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Active', value: 'Active' },
            { label: 'Expired', value: 'Expired' },
        ];
    }

    get levelOptions() {
        return [
            { label: 'Level 2', value: 'Level 2' },
            { label: 'Level 3', value: 'Level 3' },
            { label: 'All', value: 'All' },
        ];
    }

    get datePeriodOptions() {
        return [
            { label: 'None', value: '0' },
            { label: '30 Days', value: '30' },
            { label: '60 Days', value: '60' },
            { label: '90 Days', value: '90' },
        ];
    }

    
    get dataRecords() {
        return this.dataRecords;
    } 

    handleChangeStation(event) {
        this.stationValue = event.detail.value;
        this.itpValue = null;

        let myResult = this.itpBYStationMap[this.stationValue];
        let myTopicOptions = [];

        myResult.forEach( rec => {
            myTopicOptions.push({ label: rec.Account_Role_Relationship__r.To__r.Account__r.Name, value: rec.Account_Role_Relationship__r.To__r.Account__c });
        });
  
        this.itpOptions = this.sortData('label', 'asc', myTopicOptions);
        
        if(myTopicOptions.length > 1){
            this.itpOptions.unshift({label: 'All', value: 'All'}); 
        }
    }

    handleChangeITP(event) {
        this.itpValue = event.detail.value;
    }
    handleChangeExperiationstatus(event) {
        this.experiationstatusValue = event.detail.value;
    }
    handleChangeAircraftType(event) {
        this.aircraftTypeValue = event.detail.value;
    }

    handleChangeLevel(event) {
        this.levelValue = event.detail.value;

        let certificationTypesWithLevel = JSON.parse(JSON.stringify(this.certificationTypesWithLevel));
        let myTopicOptions;
        if(this.levelValue === 'All'){
            this.aircraftTypeValue = 'All';
            myTopicOptions = [{ label: '- All -', value: 'All' }];

            certificationTypesWithLevel.forEach(cert =>{
                myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
            });

        } else if(this.levelValue === 'Level 2'){
            this.aircraftTypeValue = 'All Level 2';
            myTopicOptions = [{ label: '- All Level 2 -', value: 'All Level 2'}];
            certificationTypesWithLevel.forEach(cert =>{
                if(cert.Prerequisite_Level__c === 'Level 2'){
                    myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
                }  
            });

        } else if(this.levelValue === 'Level 3'){
            this.aircraftTypeValue = 'All Level 3';
            myTopicOptions = [{ label: '- All Level 3 -', value: 'All Level 3'}];
            certificationTypesWithLevel.forEach(cert =>{
                if(cert.Prerequisite_Level__c === 'Level 3'){
                    myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
                }  
            });

        }           
        this.aircraftTypeOptions = this.sortData('label', 'asc', myTopicOptions);            
    }

    handleChangedatePeriod(event) {

        this.datePeriodValue = event.detail.value;

        let todaysDate = new Date(new Date().getFullYear(),new Date().getMonth() , new Date().getDate());

        let todaysDatePlus = new Date();
        
        todaysDatePlus.setDate(todaysDate.getDate() + parseInt(this.datePeriodValue));
    
        let todaysDateFormatted = todaysDate.getFullYear() + "-" + (todaysDate.getMonth() + 1) + "-" + todaysDate.getDate();
        let todaysDatePlusFormatted = todaysDatePlus.getFullYear() + "-" + (todaysDatePlus.getMonth() + 1) + "-" + todaysDatePlus.getDate();
    
        switch(this.datePeriodValue){
            case '30':
            case '60':
            case '90':
                this.fromDateValue = undefined;
                //this.fromDateValue = todaysDateFormatted;
                //this.toDateMinValue = this.fromDateValue;
                this.toDateValue = todaysDatePlusFormatted;
                break;
            default:
                this.fromDateValue = undefined;
                this.toDateMinValue = undefined;
                this.toDateValue = undefined;
        }

    }

        
    handleChangeFromDate(event) {
        this.fromDateValue = event.detail.value;
        this.toDateMinValue = this.fromDateValue;

        if(this.toDateValue < this.toDateMinValue){
            this.toDateValue = '';
        }
    }

    handleChangeToDate(event) {
        this.toDateValue = event.detail.value;
    }

    handleSearchButtonClick(){

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
            this.showSearch = true;
            if(this.itpOptions !== undefined && this.itpOptions.length === 0 ){
                this.dataRecords = false;
                this.loading = false;
            } else {
                this.handleSearch();
            }

        }
    }

    handleResetButtonClick(){
        this.stationValue = null;
        this.itpValue = null;
        this.itpOptions = [];
        this.experiationstatusValue = undefined;
        this.aircraftTypeValue = 'All Level 2';
        let myTopicOptions = [{ label: '- All Level 2 -', value: 'All Level 2'}];
        this.certificationTypesWithLevel.forEach(cert =>{
            if(cert.Prerequisite_Level__c === 'Level 2'){
                myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
            }  
        });
        this.aircraftTypeOptions = this.sortData('label', 'asc', myTopicOptions); 
        this.levelValue = 'Level 2';
        this.fromDateValue = undefined;
        this.fromDateMaxValue = undefined;
        this.toDateValue = undefined;
        this.toDateMinValue = undefined;
        this.datePeriodValue = undefined;
        this.showSearch = false;
        this.cleanErrors();
        
    }

    connectedCallback() {

       getAirlineITPsByStation()
       .then(result => {
           let myResult = JSON.parse(JSON.stringify(result));
           
           let myTopicOptions = [];

           Object.keys(myResult).forEach(function (el) {
               myTopicOptions.push({ label: myResult[el][0].Address__r.Code__c + ' - ' + myResult[el][0].Address__r.Description__c, value: myResult[el][0].Address__r.Code__c });
           });
           
           this.stationOptions = this.sortData('label', 'asc', myTopicOptions);
           this.itpBYStationMap = myResult;
   
       })
       .catch(error => {
           console.log('getAirlineITPsByStation - Error : ', error);
           this.mainErrorMessage = error;
           this.error = error;
       }); 
        
        getCertificationTypesWithLevel({certificationType: 'Aircraft'})
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));

            this.certificationTypesWithLevel = myResult;

            let myTopicOptions = [{ label: '- All Level 2 -', value: 'All Level 2'}];
            myResult.forEach(cert =>{
                if(cert.Prerequisite_Level__c === 'Level 2'){
                    myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
                }  
            });
            this.aircraftTypeOptions = this.sortData('label', 'asc', myTopicOptions);
            this.aircraftTypeValue = 'All Level 2';
            
        })
        .catch(error => {
            this.mainErrorMessage = error;
            this.error = error;
        });  


        this.columns = [
            {label: 'Last Name', fieldName: 'lastName', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
            {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
            {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
            {label: 'Operation Type', fieldName: 'trainingName', type: 'text', sortable: true},
            {label: 'Expiration', fieldName: 'expirationDate', type: 'date', sortable: true, 
                typeAttributes: {year: "numeric", month: "short", day: "2-digit"}, 
                cellAttributes: { class: { fieldName: 'expirationStatus' }, iconName: { fieldName: 'expirationIcon' }, iconPosition: 'right' } },
            {label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true},
            {label: 'Prereq', fieldName: 'indicatorPrereq', type: 'text', sortable: true,
                cellAttributes: { class: { fieldName: 'indicatorStatus' }, iconName: { fieldName: 'indicatorIcon' }, iconPosition: 'right' },
                tooltip: 'test' 
            },
            {label: 'Expiration', fieldName: 'indicatorExpiration', type: 'date', sortable: true,
                typeAttributes: {year: "numeric", month: "short", day: "2-digit"},
                cellAttributes: { class: { fieldName: 'indicatorStatus' }, iconName: { fieldName: 'indicatorIcon' }, iconPosition: 'right' },
                tooltip: 'test' 
            },
            {label: 'Station', fieldName: 'station', type: 'text', sortable: true},
            {label: 'ITP name', fieldName: 'itpName', type: 'text', sortable: true}
        ];
    }

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

    handleSearch(){
        
        //var auxSearchValues = new Map();
        var auxSearchValues = {};
        var i;
        // It is mandatory to choose one station, and one station only, checked before intering this method
        var auxStations = (this.stationValue == null) ? 'null' : this.stationValue;
        var auxItp = (this.itpValue == null) ? 'null' : this.itpValue;

        var auxExperiationstatus = (this.experiationstatusValue == null) ? 'null' : this.experiationstatusValue;
        var auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        //var auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
        var auxLevel = (this.levelValue == null) ? 'null' : this.levelValue;
        var auxProficiency = 'Yes';
        var auxFromDate = (this.fromDateValue == null) ? 'null' : this.fromDateValue;
        var auxToDate = (this.toDateValue == null) ? 'null' : this.toDateValue;
       
        if(!this.itpValue || this.itpValue === 'All'){
            for(i=0; i < this.itpOptions.length; i++){
                if(this.itpOptions[i].value === 'All'){
                    auxItp = '';
                }else{
                   auxItp = (auxItp === '' ) ? this.itpOptions[i].value : auxItp + ',' + this.itpOptions[i].value;
                }
            }
        }

        if(this.experiationstatusValue === 'All'){
            for(i=0; i < this.experiationstatusOptions.length; i++){
                if(this.experiationstatusOptions[i].value === 'All'){
                    auxExperiationstatus = '';
                }else{
                    auxExperiationstatus = (auxExperiationstatus === '' ) ? this.experiationstatusOptions[i].value : auxExperiationstatus + ',' + this.experiationstatusOptions[i].value;
                }
            }
        }

        if(this.aircraftTypeValue === 'All' || this.aircraftTypeValue === 'All Level 2' || this.aircraftTypeValue === 'All Level 3'){
            auxAircraftType = '';
            for(i=0; i < this.aircraftTypeOptions.length; i++){
                if(this.aircraftTypeOptions[i].value !== 'All' && this.aircraftTypeOptions[i].value !== 'All Level 2' && this.aircraftTypeOptions[i].value !== 'All Level 3'){
                    auxAircraftType = (auxAircraftType === '' ) ? this.aircraftTypeOptions[i].value : auxAircraftType + ',' + this.aircraftTypeOptions[i].value;
                }
            }
        }

        if(auxLevel === 'All'){
            auxLevel = '';
            for(i=0; i < this.levelOptions.length; i++){
                if(this.levelOptions[i].value !== 'All'){
                    auxLevel = (auxLevel === '' ) ? this.levelOptions[i].value : auxLevel + ',' + this.levelOptions[i].value;
                }
            }
        }
   
        //List
        auxSearchValues = [
            auxStations,
            auxItp,
            auxExperiationstatus,
            auxAircraftType,
            auxProficiency,
            auxFromDate,
            auxToDate,
            'null',               //place holder for firstName
            'null',                //place holder for lastName
            auxLevel
        ];

        
        this.loading = true;
        getTrainingRecords({searchValues: auxSearchValues, searchType: 'RecordsDetail' })
        .then(results => {
            if(results && results.length > 0) {
                results.forEach(rec =>{
                    rec.upperCase = 'to-upper-case';
                });
                this.data = results;
                this.dataRecords = true;
            } else {
                this.dataRecords = false; 
            }
            this.loading = false;
        })
        .catch(error => {
            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
            this.dataRecords = false;
        });     
    }

    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle data export                                               *
    *                                                                              *
    * ******************************************************************************/

    handleExportToCsv(){
        let columns = JSON.parse(JSON.stringify(this.columns));
        let data = JSON.parse(JSON.stringify(this.data));
        this.template.querySelector('c-portal-iftp-export-data').exportDataToCsv(columns, data, "TrainingRecordsDetailSearchResults.csv");
    }

    handleExportToExcel(){
        let columns = JSON.parse(JSON.stringify(this.columns));
        let data = JSON.parse(JSON.stringify(this.data));
        this.template.querySelector('c-portal-iftp-export-data').exportDataToExcel(columns, data, "EmployeesSearchResults.xls");
    }

    handleExportAllDataToCSV(){
        this.handleExportAllData('CSV');
    }
    handleExportAllDataToExcel(){
        this.handleExportAllData('Excel');
    }

    handleExportAllData(type){
        let auxSearchValues = {};
        // ALL Stations
        let auxStations = '';
        for(let i=0; i < this.stationOptions.length; i++){
            if(this.stationOptions[i].value === 'All'){
                auxStations = '';
            }else{
                auxStations = (auxStations === '' ) ? this.stationOptions[i].value : auxStations + ',' + this.stationOptions[i].value;
            }
        }

        // All Aircraft Types
        let auxAircraftType = '';
        for(let i=0; i < this.certificationTypesWithLevel.length; i++){
            if(this.certificationTypesWithLevel[i].value !== 'All' && this.certificationTypesWithLevel[i].value !== 'All Level 2' && this.certificationTypesWithLevel[i].value !== 'All Level 3'){
                auxAircraftType = (auxAircraftType === '' ) ? this.certificationTypesWithLevel[i].Certification__c : auxAircraftType + ',' + this.certificationTypesWithLevel[i].Certification__c;
            }
        }

        //List
        auxSearchValues = [
            auxStations,
            'null',                 // auxItp,
            'null',                 // place holder for auxExperiationstatus,
            auxAircraftType,
            'Yes',                  // place holder for auxProficiency,
            'null',                 // place holder for auxFromDate,
            'null',                 // place holder for  auxToDate,
            'null',                 // place holder for firstName
            'null',                 // place holder for lastName
            'Level 2,Level 3'       // place holder for auxLevel
        ];

        // 1st - get all data from database
        let columns = JSON.parse(JSON.stringify(this.columns));
        this.loading = true;
        getAllTrainingRecordsForDetailView({searchValues: auxSearchValues, searchType: 'RecordsDetail'})
        .then(results => {
            if(results && results.length > 0) {
                if(type === 'Excel'){
                    // 2nd - create excel file
                    this.template.querySelector('c-portal-iftp-export-data').exportDataToExcel(columns, results, "AllDataRequestResults.xls");
                } else {
                    if(type === 'CSV'){
                        this.template.querySelector('c-portal-iftp-export-data').exportDataToCsv(columns, results, "TrainingRecordsDetailSearchResults.csv");
                    }
                }
            } else {
                const event = new ShowToastEvent({
                    title: 'Download All Data Request Result',
                    message: 'The request returned no results.',
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            }
            this.loading = false;

        })
        .catch(error => {

            const event = new ShowToastEvent({
                title: 'Download All Data Request Result',
                message: 'An error has ocorred during your request. Please try again later',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(event);

            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
        });       
    }
}
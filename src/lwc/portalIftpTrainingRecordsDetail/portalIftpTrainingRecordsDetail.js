import { LightningElement, track, api } from 'lwc';

//import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';
//import searchTrainingRecords from '@salesforce/apex/portalIFTPTrainingRecords.searchTrainingRecords';
import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecords';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getITPConnectedToAirlineByStation from '@salesforce/apex/PortalIftpUtils.getITPConnectedToAirlineByStation';
import getCertificationTypes from '@salesforce/apex/PortalIftpUtils.getCertificationTypes';


//import {getUserStationsJS}  from 'c/portalIftpUtilsJS';
//import {stations}  from 'c/portalIftpUtilsJS';

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
    //@track aircraftTypeValue = 'All';
    @track aircraftTypeValue;
    @track proficiencyValue;

    @track datePeriodValue;
    @track fromDateValue;
    @track fromDateMinValue = new Date(2019, 0, 1);
    @track fromDateMaxValue;
    @track toDateValue;
    @track toDateMinValue;
    @track toDateMaxValue;


    @track stationOptions;
    @track itpOptions;
    @track aircraftTypeOptions;
    
    get experiationstatusOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Active', value: 'Active' },
            { label: 'Expired', value: 'Expired' },
        ];
    }
    get proficiencyOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'None', value: 'None' },
            { label: 'Level 2', value: 'Level 2' },
            { label: 'Level 3', value: 'Level 3' },
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

        getITPConnectedToAirlineByStation({ stationCode: this.stationValue })
            .then(result => {
                console.log(result);
                let myResult = JSON.parse(JSON.stringify(result));
                
                console.log(myResult);
                console.log('myResult : ' + myResult);
                let myTopicOptions = [{ label: 'All', value: 'All' }];

                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el].Account_Role_Relationship__r.To__r.Account__r.Name, value: myResult[el].Account_Role_Relationship__r.To__r.Account__c });
                    //myTopicOptions.push({ label: myResult[el], value: el });
                });

                console.log('getITPConnectedToAirlineByStation - myTopicOptions : ' + myTopicOptions);
                console.log(myTopicOptions);
                this.itpOptions = this.sortData('label', 'asc', myTopicOptions);
                console.log('getITPConnectedToAirlineByStation - this.itpOptions : ' + this.itpOptions);
            })
            .catch(error => {
                console.log('getITPConnectedToAirlineByStation - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  

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
    handleChangeProficiency(event) {
        this.proficiencyValue = event.detail.value;
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
                this.fromDateValue = todaysDateFormatted;
                this.toDateMinValue = this.fromDateValue;
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

        console.log('handleChangeFromDate - Comparing : ' + this.toDateValue + '::' + this.toDateMinValue);
        if(this.toDateValue < this.toDateMinValue){
            console.log('handleChangeFromDate - Error : ' + this.toDateValue + '::' + this.toDateMinValue);
            this.toDateValue = '';
        }
    }

    handleChangeToDate(event) {
        this.toDateValue = event.detail.value;
    }

    handleSearchButtonClick(){

       const allValid = [...this.template.querySelectorAll('lightning-input'), ...this.template.querySelectorAll('lightning-combobox') ]
       .reduce((validSoFar, inputCmp) => {
                    if(inputCmp.name === 'station' && !this.stationValue){
                        if(!this.stationValue){
                        inputCmp.setCustomValidity('Complete this field.');
                        } else{
                            inputCmp.setCustomValidity('');
                        }
                    } 
                    /*
                    if(inputCmp.name === 'itp' && this.itpOptions !== undefined && this.itpOptions.length < 2 ){
                        inputCmp.setCustomValidity('Need to have an ITP Provider');
                    }
                    */
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
       }, true);



        if(allValid){
            this.showSearch = true;
            if(this.itpOptions !== undefined && this.itpOptions.length < 2 ){
                console.log('this.itpOptions', this.itpOptions);
                this.dataRecords = false;
                this.loading = false;
            } else {
                this.handleSearch();
            }

        }
    }

    handleResetButtonClick(){
        this.stationValue = undefined;
        this.itpValue = undefined;
        this.experiationstatusValue = undefined;
        this.aircraftTypeValue = 'All';
        this.proficiencyValue = undefined;
        this.fromDateValue = undefined;
        this.fromDateMaxValue = undefined;
        this.toDateValue = undefined;
        this.toDateMinValue = undefined;
        this.datePeriodValue = undefined;
        this.showSearch = false;
        this.cleanErrors();
        
    }

    connectedCallback() {
        console.log('INIT connectedCallback');
        /*
        console.log(this.stationOptions);
        this.stationOptions = getUserStationsJS();
        console.log(this.stationOptions);
        */
        getITPStations()
            .then(result => {
                console.log(result);
                let myResult = JSON.parse(JSON.stringify(result));
                
                console.log(myResult);
                console.log('myResult : ' + myResult);
                //let myTopicOptions = [{ label: 'All', value: 'All' }];
                let myTopicOptions = [];

                Object.keys(myResult).forEach(function (el) {
                    //myTopicOptions.push({ label: myResult[el].City__c, value: myResult[el].Code__c });
                    myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
                });
                
                this.stationOptions = this.sortData('label', 'asc', myTopicOptions);
     
            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  
        
        getCertificationTypes({certificationType: 'Aircraft'})
            .then(result => {
                console.log(result);
                let myResult = JSON.parse(JSON.stringify(result));
                
                console.log(myResult);
                console.log('myResult : ' + myResult);
                let myTopicOptions = [{ label: 'All', value: 'All' }];

                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el].Name, value: myResult[el].Id });
                });
                this.aircraftTypeOptions = this.sortData('label', 'asc', myTopicOptions);
    
            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  


        this.columns = [
            {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
            {label: 'Last Name', fieldName: 'lastName', type: 'text', sortable: true},
            {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
            {label: 'Aircraft Type', fieldName: 'trainingName', type: 'text', sortable: true},
            {label: 'ITP name', fieldName: 'itpName', type: 'text', sortable: true},
            {label: 'Expiration Date', fieldName: 'expirationDate', type: 'date', sortable: true, 
                typeAttributes: {year: "numeric", month: "long", day: "2-digit"}, 
                cellAttributes: { class: { fieldName: 'expirationStatus' }, iconName: { fieldName: 'expirationIcon' }, iconPosition: 'right' } },
            {label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true},
            {label: 'Station', fieldName: 'station', type: 'text', sortable: true},
            {label: 'PREREQ EXPIRATION', fieldName: 'indicator', type: 'text', sortable: true,
                cellAttributes: { class: { fieldName: 'indicatorStatus' }, iconName: { fieldName: 'indicatorIcon' }, iconPosition: 'right' },
                tooltip: 'test' } 
        ];

        console.log('END connectedCallback');
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
        
        var auxSearchValues = new Map();
        var i;
        var auxStations = (this.stationValue == null) ? 'null' : this.stationValue;
        var auxItp = (this.itpValue == null) ? 'null' : this.itpValue;
        var auxExperiationstatus = (this.experiationstatusValue == null) ? 'null' : this.experiationstatusValue;
        var auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        var auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
        var auxFromDate = (this.fromDateValue == null) ? 'null' : this.fromDateValue;
        var auxToDate = (this.toDateValue == null) ? 'null' : this.toDateValue;

        console.log('handleSearch - INIT');
        console.log('auxItp', auxItp);

        console.log('this.stationValue: ' + this.stationValue);
        console.log('this.stationOptions: ' + this.stationOptions);
        console.log('this.stationOptions.length: ' + this.stationOptions.length);
        console.log(this.stationOptions);

        if(this.stationValue === 'All'){
            
            for(i=0; i < this.stationOptions.length; i++){
                if(this.stationOptions[i].value === 'All'){
                    auxStations = '';
                }else{
                    auxStations = (auxStations === '' ) ? this.stationOptions[i].value : auxStations + ',' + this.stationOptions[i].value;
                }
            }
        }

        if(this.itpValue === 'All'){
            for(i=0; i < this.itpOptions.length; i++){
                if(this.itpOptions[i].value === 'All'){
                    auxItp = '';
                }else{
                   auxItp = (auxItp === '' ) ? this.itpOptions[i].value : auxItp + ',' + this.itpOptions[i].value;
                }
            }
            console.log('auxItp', auxItp);
        }

        if(this.experiationstatusValue === 'All'){
            for(i=0; i < this.experiationstatusOptions.length; i++){
                if(this.experiationstatusOptions[i].value == 'All'){
                    auxExperiationstatus = '';
                }else{
                    auxExperiationstatus = (auxExperiationstatus === '' ) ? this.experiationstatusOptions[i].value : auxExperiationstatus + ',' + this.experiationstatusOptions[i].value;
                }
            }
        }

        if(this.aircraftTypeValue == 'All'){
            for(i=0; i < this.aircraftTypeOptions.length; i++){
                if(this.aircraftTypeOptions[i].value == 'All'){
                    auxAircraftType = '';
                }else{
                    auxAircraftType = (auxAircraftType == '' ) ? this.aircraftTypeOptions[i].value : auxAircraftType + ',' + this.aircraftTypeOptions[i].value;
                }
            }
        }

        //On search "Level 2" must include "Level 3" results also, when L3 select only show L3
        if(this.proficiencyValue === 'All' || this.proficiencyValue === 'Level 2' || !this.proficiencyValue){
            for(i=0; i < this.proficiencyOptions.length; i++){
                if(this.proficiencyOptions[i].value === 'All' || !this.proficiencyValue){
                    auxProficiency = '';
                }else{
                    if(this.proficiencyValue === 'Level 2'){
                        if(this.proficiencyOptions[i].value !== 'None'){
                            auxProficiency = (auxProficiency === '' ) ? this.proficiencyOptions[i].value : auxProficiency + ',' + this.proficiencyOptions[i].value;
                        }
                    } else {
                        auxProficiency = (auxProficiency === '' ) ? this.proficiencyOptions[i].value : auxProficiency + ',' + this.proficiencyOptions[i].value;
                    }
                }
            }
        }

        /*
        //Map
        auxSearchValues = [
            {"station" : auxStations},
            {"itp" : auxItp},
            {"experiationstatus" : auxExperiationstatus},
            {"aircraftType" : auxAircraftType},
            {"proficiency" : auxProficiency},
            {"fromDate" : auxFromDate},
            {"toDate" : auxToDate}
        ];
        */
        /*
        //Map
        auxSearchValues.set('station', auxStations);
        auxSearchValues.set('itp', auxItp);
        */
   
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
            'null'                //place holder for lastName
        ];
       
        console.log('searchValues: ', auxSearchValues);
        console.log(auxSearchValues);
        
        this.loading = true;
        //getTrainingRecords({searchValues: JSON.parse(JSON.stringify(auxSearchValues)) })
        getTrainingRecords({searchValues: auxSearchValues, origin: 'RecordsDetail' })
        .then(results => {
            console.log('handleSearch - results : ', results);
            console.log('handleSearch - results.length : ', results.length);
            console.log('handleSearch - results:1 : ', results[1]);


            if(results && results.length > 0) {
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

    fillStations(userId){

        this.stationOptions = getITPStations('');

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
    /*
    handleSearckButtonClick(evt){
        this.handleSearch(evt.target.value);
    }

    handleSearchClick(){
        this.showSearchModal = true;
        //this.modalClasses = 'slds-fade-in-open';
        //this.backdropClasses = 'slds-backdrop_open';
    }

    handleCloseSearchModalButtonClick(){
        this.showSearchModal = false;

        let objAux = JSON.parse(JSON.stringify(this.filteringObject));
        objAux.showAllComponents = false;
        this.filteringObject = objAux;        
        //this.modalClasses = '';
        //this.backdropClasses = '';
    }

    handleFiltersButtonClick(){
        this.showFiltersArea = !this.showFiltersArea;
    }

    fireChangeEvent(filters) {
       
    }
    */
}
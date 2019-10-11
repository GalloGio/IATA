import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getCertificationTypes from '@salesforce/apex/PortalIftpUtils.getCertificationTypes';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecords';


export default class PortalIftpMonitorTrainings extends LightningElement {
    @track stationValue;
    @track stationOptions;
    @track expirationStatusValue;
    @track aircraftTypeValue = 'All';
    @track aircraftTypeOptions;
    @track proficiencyValue;
    @track datePeriodValue;
    @track fromDateValue;
    @track fromDateMinValue = new Date(2019, 0, 1);
    @track fromDateMaxValue;
    @track toDateValue;
    @track toDateMinValue;
    @track toDateMaxValue;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track hasDataRecords = false;
    @track showSearch = false;
    @track loading = true;

    get expirationStatusOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Active', value: 'Active' },
            { label: 'Expired', value: 'Expired' },
        ];
    }

    get proficiencyOptions() {
        return [
            { label: 'None', value: 'None' },
            { label: 'Level 2', value: 'Level 2' },
            { label: 'Level 3', value: 'Level 3' },
            { label: 'All', value: 'All' }
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

    columns = [
        {label: 'Last Name', fieldName: 'lastName', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
        {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
        {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
        {label: 'Aircraft Type', fieldName: 'trainingName', type: 'text', sortable: true},
        {label: 'Expiration Date', fieldName: 'expirationDate', type: 'date', sortable: true, 
            typeAttributes: {year: "numeric", month: "long", day: "2-digit"}, 
            cellAttributes: { class: { fieldName: 'expirationStatus' }, iconName: { fieldName: 'expirationIcon' }, iconPosition: 'right' } },
        {label: 'Days', fieldName: 'days', type: 'number', initialWidth: 70, sortable: true,  
            cellAttributes: { class: { fieldName: 'expirationStatus' }} }, 
        {label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true},
        {label: 'Station', fieldName: 'station', type: 'text', sortable: true},
        {label: 'PREREQ EXPIRATION', fieldName: 'indicator', type: 'text', sortable: true,
            cellAttributes: { class: { fieldName: 'indicatorStatus' }, iconName: { fieldName: 'indicatorIcon' }, iconPosition: 'right' },
            tooltip: 'test' } ,

    ];


    @wire(getITPStations)
    handleGetItpStations({error, data}){
        //succeeded
        if(data){
            let myResult = JSON.parse(JSON.stringify(data));
            
            console.log('myResult : ' + myResult);
            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
            });
            this.stationOptions = this.sortData('label', 'asc', JSON.parse(JSON.stringify(myTopicOptions)));
        }

        //exception
        if(error){
            //show toast "Something went wrong"
            console.log('error : ' + error);
        }
    }

    //@wire(getCertificationTypes, {certificationType: 'Aircraft'})
    @wire(getCertificationTypes, {certificationType: ''})
    handleGetCertificationTypes({error, data}){
        if(data){
            let myResult = JSON.parse(JSON.stringify(data));
            console.log('myResult : ' + myResult);
            myResult = this.sortData('Name', 'asc', myResult);
            let myTopicOptions = [{ label: 'All', value: 'All' }];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Name, value: myResult[el].Id });
            });

            this.aircraftTypeOptions = myTopicOptions;
        }

        if(error){
            console.log('error : ' + error);
        }
    }


    handleChangeStation(event) {
        this.stationValue = event.detail.value;
    }
    handleChangeExpirationStatus(event) {
        this.expirationStatusValue = event.detail.value;
    }
    handleChangeAircraftType(event) {
        this.aircraftTypeValue = event.detail.value;
    }
    handleChangeProficiency(event) {
        this.proficiencyValue = event.detail.value;
    }
    handleChangeDatePeriod(event) {

        this.datePeriodValue = event.detail.value;

        let todaysDate = new Date(new Date().getFullYear(),new Date().getMonth() , new Date().getDate());

        let todaysDatePlus = new Date();
        
        todaysDatePlus.setDate(todaysDate.getDate() + parseInt(this.datePeriodValue) );
    
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
        this.error = [];
        this.mainErrorMessage = '';

        if(this.error.length === 0){
            this.showSearch = true;
            this.cleanErrors();
            this.handleSearch();
        }else{
            this.mainErrorMessage = 'Need to fill the required fields';
        }
    }

    handleSearch(){
        this.loading = true;
        let auxSearchValues = new Map();
        let i;
        let auxStations = (this.stationValue == null) ? 'null' : this.stationValue;
        let auxItp = (this.itpValue == null) ? 'null' : this.itpValue;
        let auxExpirationStatus = (this.expirationStatusValue == null) ? 'null' : this.expirationStatusValue;
        let auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        let auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
        let auxFromDate = (this.fromDateValue == null) ? 'null' : this.fromDateValue;
        let auxToDate = (this.toDateValue == null) ? 'null' : this.toDateValue;

        console.log('handleSearch - INIT');
        console.log('auxItp', auxItp);
        console.log('this.stationValue: ' + this.stationValue);
        console.log('this.stationOptions: ' + this.stationOptions);
        console.log('this.stationOptions.length: ' + this.stationOptions.length);

        if(this.stationValue === 'All'){
            for(i=0; i < this.stationOptions.length; i++){
                if(this.stationOptions[i].value === 'All'){
                    auxStations = '';
                }else{
                    auxStations = (auxStations === '' ) ? this.stationOptions[i].value : auxStations + ',' + this.stationOptions[i].value;
                }
            }
        }

        if(this.expirationStatusValue === 'All'){
            for(i=0; i < this.expirationStatusOptions.length; i++){
                if(this.expirationStatusOptions[i].value == 'All'){
                    auxExpirationStatus = '';
                }else{
                    auxExpirationStatus = (auxExpirationStatus === '' ) ? this.expirationStatusOptions[i].value : auxExpirationStatus + ',' + this.expirationStatusOptions[i].value;
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

        if(this.proficiencyValue === 'All' ||  !this.proficiencyValue){
            auxProficiency = 'null';
        }
        console.log('auxProficiency', auxProficiency);
        //List
        auxSearchValues = [
            auxStations,
            auxItp,
            auxExpirationStatus,
            auxAircraftType,
            auxProficiency,
            auxFromDate,
            auxToDate,
            'null',               //place holder for firstName
            'null'                //place holder for lastName
        ];
       
        console.log('searchValues: ', auxSearchValues);
        
        
        getTrainingRecords({searchValues: auxSearchValues, origin: 'MonitorTrainings' })
        .then(results => {
            console.log('handleSearch - results : ', results);
            console.log('handleSearch - results.length : ', results.length);
            console.log('handleSearch - results:1 : ', results[1]);


            if(results && results.length > 0) {
                results.forEach(rec =>{
                    rec.upperCase = 'to-upper-case';
                })
                this.data = JSON.parse(JSON.stringify(results));
                //this.data = this.sortData('lastName', 'asc', JSON.parse(JSON.stringify(results)));
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


    handleResetButtonClick(){
        this.stationValue = undefined;
        this.expirationStatusValue = undefined;
        this.aircraftTypeValue = 'All';
        this.proficiencyValue = undefined;
        this.datePeriodValue = undefined;
        this.fromDateValue = undefined;
        this.fromDateMaxValue = undefined;
        this.toDateValue = undefined;
        this.toDateMinValue = undefined;
        this.showSearch = false;
        this.cleanErrors();
        
    }

    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle data sorting                                               *
    *                                                                              *
    * ******************************************************************************/

    updateColumnSorting(event) {
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        
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
        let key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
            function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
            /*
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
            */
        return function (a, b) {
            let A = key(a);
            let B = key(b);
            return reverse * ((A > B) - (B > A));
        }
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


}
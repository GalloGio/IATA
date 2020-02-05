import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecordsDetail';
import getCertificationTypesWithLevel from '@salesforce/apex/PortalIftpUtils.getCertificationTypesWithLevel';
import getAllStations from '@salesforce/apex/PortalIftpUtils.getAllStations';


export default class PortalIftpTrainingRecordsSummary extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track columns;
    fieldLabels = [
        'itpName', 'trainingName', 'proficiency'
    ];
    

    @track showSearch = false;
    @track aircraftTypeValue = null;
            certificationTypesWithLevel;
    @track proficiencyValue = 'Level 2';

    @track aircraftTypeOptions;
    @track allStations;
    @track selectedRows = null;
    @track queryTerm = null;
    @track showSearchResults = false;
    @track sortedBy;
    @track sortedDirection;
    @track sortedByStationOptions;
    @track sortedDirectionStationOptions;
    @track listSearchStationsResult = [];
    @track columnsSelectStation = [ {label: 'Code', fieldName: 'Code__c', type: 'text', sortable: true},
                                    {label: 'City', fieldName: 'City__c', type: 'text', sortable: true},
                                    {label: 'description', fieldName: 'Description__c', type: 'text', sortable: true}
                                ];
    @track openStationsModal = false;
    @track loadingSpinner = false;

    @wire(CurrentPageReference) pageRef;
    
    get proficiencyOptions() {
        return [
            { label: 'Level 2', value: 'Level 2' },
            { label: 'Level 3', value: 'Level 3' }
        ];
    }

    get dataRecords() {
        return this.dataRecords;
    } 

    handleChangeAircraftType(event) {
        this.aircraftTypeValue = event.detail.value;
    }
    handleChangeProficiency(event) {
        this.proficiencyValue = event.detail.value;

        let myTopicOptions;
        this.certificationTypesWithLevel.forEach(cert =>{
            if(cert.Prerequisite_Level__c === this.proficiencyValue ){
                if(!myTopicOptions){
                    myTopicOptions = [{ label: cert.Certification__r.Name, value: cert.Certification__c }];
                } else{
                    myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
                }
            }  
        });
        this.aircraftTypeValue = null;
        this.aircraftTypeOptions = this.sortData('label', 'asc', myTopicOptions); 
    }
        
    handleSearchButtonClick(){
        //Form Validations
        const allValid = [...this.template.querySelectorAll('lightning-input'), ...this.template.querySelectorAll('lightning-combobox') ]
        .reduce((validSoFar, inputCmp) => {
                        if(inputCmp.name === "Search when user hits the 'enter' key"){
                            if(!this.queryTerm){
                            inputCmp.setCustomValidity('Complete this field.');
                            } else if (!this.queryTerm.includes('-')){
                                inputCmp.setCustomValidity("Click 'Search Stations' and select it.");
                            } else {
                                inputCmp.setCustomValidity('');
                            }
                        }
                        if(inputCmp.name === "proficiency"){
                            if(!this.proficiencyValue){
                              inputCmp.setCustomValidity('Complete this field.');
                            } else {
                                inputCmp.setCustomValidity('');
                            }
                        }

                        if(inputCmp.name === "aircraftType"){
                            if(!this.aircraftTypeValue){
                                inputCmp.setCustomValidity('Complete this field.');
                              } else {
                                  inputCmp.setCustomValidity('');
                              }
                        }
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
                        
        }, true);

        if(allValid){
            this.showSearch = true;
            this.handleSearch();
        }
    }

    handleResetButtonClick(){
        this.handleResetSelectStationSearch();
        this.aircraftTypeValue = null;
        this.proficiencyValue = 'Level 2';
        let myTopicOptions;
        this.certificationTypesWithLevel.forEach(cert =>{
            if(cert.Prerequisite_Level__c === 'Level 2'){
                if(!myTopicOptions){
                    myTopicOptions = [{ label: cert.Certification__r.Name, value: cert.Certification__c }];
                } else{
                    myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
                }
            }  
        });

        this.aircraftTypeOptions = this.sortData('label', 'asc', myTopicOptions); 

        this.showSearch = false;
        this.cleanErrors();
    }

    connectedCallback() {

        getAllStations()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));        
            this.allStations = myResult;

            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
            });

            this.allStationOptions = myTopicOptions;
    
        })
        .catch(error => {
            console.error('getAllStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
            fireEvent(this.pageRef, 'errorEvent', error);  
        }); 

        getCertificationTypesWithLevel({certificationType: 'Aircraft'})
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            this.certificationTypesWithLevel = myResult;

            let myTopicOptions;
            myResult.forEach(cert =>{
                if(cert.Prerequisite_Level__c === 'Level 2'){
                    if(!myTopicOptions){
                        myTopicOptions = [{ label: cert.Certification__r.Name, value: cert.Certification__c }];
                    } else{
                        myTopicOptions.push({ label: cert.Certification__r.Name, value: cert.Certification__c });
                    }
                }  
            });

            this.aircraftTypeOptions = this.sortData('label', 'asc', myTopicOptions);
            
        })
        .catch(error => {
            console.error('getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
            fireEvent(this.pageRef, 'errorEvent', error);  
        }); 


        this.columns = [
            {label: 'ITP Name', fieldName: 'itpName', type: 'text', sortable: true},
            {label: 'Operation Type', fieldName: 'trainingName', type: 'text', sortable: true},
            
            {label: 'Global OJT', fieldName: 'OJT_file_ITP', type: 'url', 
            typeAttributes: {
                label: { fieldName: "OJT_file_global_name" }
              }, 
              sortable: true},
            {label: 'Station OJT', fieldName: 'OJT_file_Station', type: 'url', typeAttributes: {
                label: { fieldName: "OJT_file_station_name" }
              }, sortable: true}
            
        ];
    }

    handleSearch(){
        
        var auxSearchValues = new Map();
        let selectedRows = JSON.parse(JSON.stringify(this.selectedRows));
        let auxStations = selectedRows[0].Code__c;
        var auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        var auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
   
        //List
        auxSearchValues = [
            auxStations,
            'null',               //place holder for auxItp
            'Active',               //place holder for auxExperiationstatus
            auxAircraftType,
            'Yes',                 // place holder for proficiency
            'null',               //place holder for auxFromDate
            'null',               //place holder for auxToDate
            'null',               //place holder for firstName
            'null',                //place holder for lastName
            auxProficiency         //place holder for level

        ];
        
        this.loading = true;
        getTrainingRecords({searchValues: auxSearchValues, searchType: 'RecordsSummary'})
        .then(results => {

            if(results && results.length > 0) {
                this.data = JSON.parse(JSON.stringify(results));
                this.dataRecords = true;

            } else {
                this.dataRecords = false; 
            }
            this.loading = false;

            this.cleanErrors();
        })
        .catch(error => {
            console.error('handleSearch - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
            this.dataRecords = false;
            fireEvent(this.pageRef, 'errorEvent', error);  
        });  
    }

    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }


    /********************************************************************************
     *                                                                              *
     *    Methods to handle Select Station in the Search Training Records Summary   *
     *                                                                              *  
     ********************************************************************************/
    
    //For Datatable in Select Station

    handleSearchStationOnClick() {
        this.selectedRows = null;
        this.handleSearchStations();

    }
    handleChangeSearch(event){
        this.queryTerm = event.detail.value; 
    }
    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
        this.selectedRows = null;
        this.handleSearchStations();
        }
    }
    
    handleSearchStations(){
        this.showSearchResults = false;
        this.loadingSpinner = true;
        this.openStationsModal = true;
        let allStations = JSON.parse(JSON.stringify(this.allStations));
        let allStationOptions = JSON.parse(JSON.stringify(this.allStationOptions));
        let searchableStations = allStations.filter(station =>{
            return allStationOptions.indexOf(station.Code__c) === -1;
        });
        let myResult =  searchableStations.filter(station => { 
            return (station.Code__c !== undefined && station.Code__c.toUpperCase().includes(this.queryTerm.toUpperCase())) || 
                    (station.Description__c !== undefined && station.Description__c.toUpperCase().includes(this.queryTerm.toUpperCase()))|| 
                    (station.City__c !== undefined  && station.City__c.toUpperCase().includes(this.queryTerm.toUpperCase()));
        });
        this.listSearchStationsResult = myResult;

        this.loadingSpinner = false;
        if(this.listSearchStationsResult.length > 0 ){
            this.showSearchResults = true;
        } 
    }

    getSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }
    handleSelectStationsSave(){
        this.openStationsModal = false;
        this.queryTerm= this.selectedRows[0].Code__c + ' - ' + this.selectedRows[0].Description__c;
    }

    handleResetSelectStationSearch(){
        this.selectedRows = null;
        this.queryTerm = null;
        this.listSearchStationsResult = [];
        this.showSearchResults = false;
    }

    handleCancel(){
        this.openStationsModal = false;
        this.handleResetSelectStationSearch();
    }
    
    /*******************************************************************************
    *                                                                              *
    *  Sorting Methods                                                             *
    *                                                                              *
    * ******************************************************************************/

   updatecolumnsSearchStationSorting(event){
        let fieldName = event.detail.fieldName;
        let sortedDirectionStationOptions = event.detail.sortDirection;
        this.sortedDirectionStationOptions = sortedDirectionStationOptions;
        this.sortedByStationOptions = fieldName;
        let auxdata = JSON.parse(JSON.stringify(this.listSearchStationsResult));
        this.listSearchStationsResult = this.sortData(fieldName, sortedDirectionStationOptions, auxdata);
    }

    // Sort Columns In SearchResults Datatable
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
}
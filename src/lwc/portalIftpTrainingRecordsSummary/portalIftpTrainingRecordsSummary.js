import { LightningElement, track } from 'lwc';

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
    //@track stationValue;
    @track aircraftTypeValue = null;
            certificationTypesWithLevel;
    @track proficiencyValue = 'Level 2';

    
    //@track stationOptions;
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
        //this.stationValue = null;
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
        console.log('INIT connectedCallback');

        getAllStations()
        .then(result => {
            console.log(result);
            let myResult = JSON.parse(JSON.stringify(result));
            
            //console.log(myResult);
            //console.log('myResult : ' + myResult);

            this.allStations = myResult;

            //console.log('this.allStations : ' + this.allStations);


            //let myTopicOptions = [{ label: 'All', value: 'All' }];
            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
            });

            this.allStationOptions = myTopicOptions;
    
        })
        .catch(error => {
            console.log('getAllStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        }); 

        getCertificationTypesWithLevel({certificationType: 'Aircraft'})
        .then(result => {
            console.log(result);
            let myResult = JSON.parse(JSON.stringify(result));
            this.certificationTypesWithLevel = myResult;

            console.log('this.certificationTypesWithLevel : ', this.certificationTypesWithLevel);

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
            console.log('getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        }); 


        this.columns = [
            {label: 'ITP Name', fieldName: 'itpName', type: 'text', sortable: true},
            {label: 'Operation Type', fieldName: 'trainingName', type: 'text', sortable: true},
            //{label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true},
            
            {label: 'Global OJT', fieldName: 'OJT_file_ITP', type: 'url', 
            typeAttributes: {
                label: { fieldName: "OJT_file_global_name" }
              }, 
              sortable: true},
            {label: 'Station OJT', fieldName: 'OJT_file_Station', type: 'url', typeAttributes: {
                label: { fieldName: "OJT_file_station_name" }
              }, sortable: true}
            
            //{label: 'Station', fieldName: 'station', type: 'text', sortable: true}
        ];

        console.log('END connectedCallback');
    }

    handleSearch(){
        
        var auxSearchValues = new Map();
        //var i;
        let selectedRows = JSON.parse(JSON.stringify(this.selectedRows));
        let auxStations = selectedRows[0].Code__c;
        //var auxStations = (this.stationValue == null) ? 'null' : this.stationValue;
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
            console.log('handleSearch - Error : ' + error);
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
        console.log('myResult: ', myResult);
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

    /********************************************************************************
     *                                                                              *
     *    Methods to handle Download of OJT files  *
     *                                                                              *  
     ********************************************************************************/

     /*

    handleRowAction(event){
        let data = JSON.parse(JSON.stringify(this.data));
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        let id = row.id;
        let index = -1;
        let recordToManage = {};
        console.log('row', JSON.parse(JSON.stringify(row)));
        
        for(let i = 0; i < data.length; i++){
            if(id === data[i].uniqueRowId){
                recordToManage = data[i];
                index = i;
                i = data.length;
            }
        }
        console.log('recordToManage', recordToManage);

        switch (actionName) {
            case 'downloadGlobal':
                recordToManage.OJT_file_ITP_name = recordToManage.itpName + ' - Global OJT file';
                this.downloadPDFFile(recordToManage.OJT_file_global_id, recordToManage.OJT_file_ITP_name);
                break;
            case 'downloadStation':

                break;
            default:
        }

    }

    downloadPDFFile(fileId, fileName){
        console.log('downloadPDFFile - start : ');
        
        getFileContent({fileId: '0690Q000000MecOQAS'})
        .then(results =>{
            let pdfFileName = fileName +'.pdf';
            console.log('downloadPDFFile - results : ', results);
            if(window.navigator.msSaveBlob) { // IE 10+
                let blob = new Blob([results], {
                              type: 'application/pdf'          
                    });
                window.navigator.msSaveBlob(blob, pdfFileName);
            }
            else
            {
            
                    // Creating anchor element to download
                    let downloadElement = document.createElement('a');
                    // below statement is required if you are using firefox browser
                    document.body.appendChild(downloadElement);
    
                    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
                    downloadElement.href = 'data: application/octet-stream;base64,' + results;
                    // CSV File Name
                    downloadElement.download = pdfFileName;
                    
                    // click() Javascript function to download CSV file
                    downloadElement.click();
            }
        })
    }
    */
}
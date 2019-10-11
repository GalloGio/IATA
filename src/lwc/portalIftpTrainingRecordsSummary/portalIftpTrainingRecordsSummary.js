import { LightningElement, track } from 'lwc';


//import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';
//import searchTrainingRecords from '@salesforce/apex/portalIFTPTrainingRecords.searchTrainingRecords';
import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecords';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getCertificationTypes from '@salesforce/apex/PortalIftpUtils.getCertificationTypes';
import getAllStations from '@salesforce/apex/PortalIftpUtils.getAllStations';
//import getFileContent from '@salesforce/apex/portalIftpTrainingRecords.getFileContent';

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
    @track aircraftTypeValue;
    @track proficiencyValue;

    
    @track stationOptions;
    @track aircraftTypeOptions;
    @track allStations;
    @track selectedRows = null;
    @track queryTerm = null;
    @track showSearchResults = false;
    @track listSearchStationsResult = [];
    @track columnsSelectStation = [ {label: 'Code', fieldName: 'Code__c', type: 'text'},
                                    {label: 'City', fieldName: 'City__c', type: 'text'},
                                    {label: 'description', fieldName: 'Description__c', type: 'text'}
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
    /*
    handleChangeStation(event) {
        this.stationValue = event.detail.value;
    }
    */
    handleChangeAircraftType(event) {
        this.aircraftTypeValue = event.detail.value;
    }
    handleChangeProficiency(event) {
        this.proficiencyValue = event.detail.value;
    }
        
    handleSearchButtonClick(){
        
        this.error = [];
        this.mainErrorMessage = '';
        console.log('1 this.error: ' + this.error);
        console.log(this.error);

        /*
        objectA.push({ 
            name: 'test',
            id: 1234
        });
        */
        //if(this.stationValue == null){
        if(this.selectedRows === null){
            this.error.push({message : 'Need to Select a Station'});
        }
        if(this.aircraftTypeValue == null){
            this.error.push({message : 'Need to Select a Aircraft Type'});
        }
        if(this.proficiencyValue == null){
            this.error.push({message : 'Need to Select a Proficiency Level'});
        }

        console.log('2 this.error: ' + this.error);
        console.log(this.error);

        if(this.error.length === 0){
            this.showSearch = true;
            this.cleanErrors();
            this.handleSearch();
        }else{
            this.mainErrorMessage = 'Need to fill the required fields';
        }
    }

    handleResetButtonClick(){
        this.handleResetSelectStationSearch();
        //this.stationValue = null;
        this.aircraftTypeValue = null;
        this.proficiencyValue = null;
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

                this.stationOptions = myTopicOptions;
                this.cleanErrors();
            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  
        
        getAllStations()
        .then(result => {
            console.log(result);
            let myResult = JSON.parse(JSON.stringify(result));
            
            //console.log(myResult);
            //console.log('myResult : ' + myResult);

            this.allStations = myResult;

            //console.log('this.allStations : ' + this.allStations);
            console.log('this.allStations.length : ' + this.allStations.length);
            console.log('this.allStations[0] : ', this.allStations[0]);


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


        getCertificationTypes({certificationType: 'Aircraft'})
            .then(result => {
                console.log(result);
                let myResult = JSON.parse(JSON.stringify(result));
                
                console.log(myResult);
                console.log('myResult : ' + myResult);
                let myTopicOptions = [];

                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el].Name, value: myResult[el].Id });
                });

                this.aircraftTypeOptions = myTopicOptions;
                this.cleanErrors();
            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  


        this.columns = [
            {label: 'ITP Name', fieldName: 'itpName', type: 'text', sortable: true},
            {label: 'Aircraft Type', fieldName: 'trainingName', type: 'text', sortable: true},
            {label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true},
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
        var i;
        let selectedRows = JSON.parse(JSON.stringify(this.selectedRows));
        let auxStations = selectedRows[0].Code__c;
        //var auxStations = (this.stationValue == null) ? 'null' : this.stationValue;
        var auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        var auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
        /*
        if(this.stationValue === 'All'){
            
            for(i=0; i < this.stationOptions.length; i++){
                if(this.stationOptions[i].value === 'All'){
                    auxStations = '';
                }else{
                    auxStations = (auxStations === '' ) ? this.stationOptions[i].value : auxStations + ',' + this.stationOptions[i].value;
                }
            }
        }
        */
        if(this.aircraftTypeValue === 'All'){
            for(i=0; i < this.aircraftTypeOptions.length; i++){
                if(this.aircraftTypeOptions[i].value === 'All'){
                    auxAircraftType = '';
                }else{
                    auxAircraftType = (auxAircraftType === '' ) ? this.aircraftTypeOptions[i].value : auxAircraftType + ',' + this.aircraftTypeOptions[i].value;
                }
            }
        }

        //On search "Level 2" must include "Level 3" results also, when L3 select only show L3
        if(this.proficiencyValue == 'All' || this.proficiencyValue == 'Level 2'){
            for(i=0; i < this.proficiencyOptions.length; i++){
                if(this.proficiencyOptions[i].value == 'All'){
                    auxProficiency = '';
                }else{
                    auxProficiency = (auxProficiency == '' ) ? this.proficiencyOptions[i].value : auxProficiency + ',' + this.proficiencyOptions[i].value;
                }
            }
        }
        console.log('*************** auxStations', auxStations);
   
        //List
        auxSearchValues = [
            auxStations,
            'null',               //place holder for auxItp
            'Active',               //place holder for auxExperiationstatus
            auxAircraftType,
            auxProficiency,
            'null',               //place holder for auxFromDate
            'null',               //place holder for auxToDate
            'null',               //place holder for firstName
            'null'                //place holder for lastName
        ];
        
        console.log('**********   searchValues: ' + auxSearchValues);
        console.log(auxSearchValues);
        
        this.loading = true;
        //getTrainingRecords({searchValues: JSON.parse(JSON.stringify(auxSearchValues)) })
        getTrainingRecords({searchValues: auxSearchValues, origin: 'Summary'})
        .then(results => {
            console.log('handleSearch - results : ', results);
            console.log('handleSearch - results.length : ' + results.length);
            console.log('handleSearch - results:1 : ', results[1]);

            if(results && results.length > 0) {
                this.data = results;
/*
                this.data.forEach(record =>{
                    if(record.OJT_file_ITP){
                        console.log('record.OJT_file_ITP' + record.OJT_file_ITP);
                    }
                    if(record.OJT_file_Station){
                        console.log('record.OJT_file_Station' + record.OJT_file_ITP);
                    }
                    record.OJT_file_ITP = 'https://iata--iftpfmdev.lightning.force.com/lightning/r/ContentDocument/0690Q000000Mi7oQAC/view';
                    record.OJT_file_global_name = record.itpName + ' - Global OJT file';
                    record.OJT_file_Station = 'https://iata--IFTPFMDEV.cs109.my.salesforce.com/sfc/p/0Q0000000SIh/a/0Q0000004KqS/UkPnpCQZuH9FzMtxfcp7t2y8LzsnTFQ7xejfUIj1G4A';
                    record.OJT_file_Station_name = record.itpName + ' - Station OJT file';
                })
*/
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
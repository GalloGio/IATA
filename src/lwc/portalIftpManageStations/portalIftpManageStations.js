import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

import deleteStationFromItp from '@salesforce/apex/PortalIftpStationsManagement.deleteStationFromItp';
import getAllIftpAirlines from '@salesforce/apex/PortalIftpStationsManagement.getAllIftpAirlines';
import getITPStationEmployees from '@salesforce/apex/PortalIftpUtils.getITPStationEmployees';
import getAllStations from '@salesforce/apex/PortalIftpUtils.getAllStations';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getItpStationsAirlines from '@salesforce/apex/PortalIftpStationsManagement.getItpStationsAirlines';
import getITPStationsForDatatable from '@salesforce/apex/PortalIftpUtils.getITPStationsForDatatable';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import insertStation from '@salesforce/apex/PortalIftpUtils.insertStation';
import manageUploadStationOJT from '@salesforce/apex/PortalIftpUtils.manageUploadStationOJT';
import updateItpAddressAirlines from '@salesforce/apex/PortalIftpStationsManagement.updateItpAddressAirlines';
import updateStation from '@salesforce/apex/PortalIftpUtils.updateStation';

export default class PortalIftpManageStations extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track loadingEditSpinner = false;
    @track loadingNew = false;
    @track loadingManageAirlinesSpinner = false;
    @track loadingDeleteSpinner = false;
    @track showStations = false;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track editData;
    @track newData;
    @track columns;
    @track columnsAddNewStation;
    @track openmodal = false;
    @track openNewModal = false;
    @track userInfo;
    @track isActionEdit = false;
    @track isActionDelete = false;
    @track modalTitle = '';
    @track askForconfirmationMessage = '';
    @track openConfirmationModal = false;


    @track queryTerm;
    @track stationsSearchResults;
    @track newData;
    @track selectedRows;
    @track showSearchResults = false;
    @track hasSearchResults = false;
    @track showSaveButton = false;
    @track stationAlreadyAdded = false;
    @track openAddAirlineModal = false;
    @track airlinesProneToAdd =[];
    @track showAirlinesList = false;
    @track manageAirlineValue = null;
    @track hasNoAirlines= true;
    recordToManage = {};
    @track itpStationsAirlinesMap;
    @track recordToManageNewAirlinesList = [];
           recordToManageOriginalAirlinesList = [];
    @track airlinesList =[];
    @track airlineOptions;
    @track fileId;
    @track sortedBy;
    @track sortedDirection;
    @track manageAirlinesSortedBy;
    @track manageAirlinesSortedDirection;
    @track sortedByStationOptions;
    @track sortedDirectionStationOptions;
    @track addStationResultsTitle = 'Search Results';
    
    fieldLabels = [
        'id', 'code', 'city', 'name', 'description'
    ];
    

    @track showSearch = false;
    @track showSearchResults = false;
    @track stationValue;
    @track aircraftTypeValue;
    @track proficiencyValue;

    
    @track allStationOptions;
    @track stationOptions;
    @track ITPStations;
    @track manageAirlinesHasChanges = false;
    @track allStations;
    Account_Role_Service = '';
    
    get dataRecords() {
        return this.dataRecords;
    } 

    @wire(CurrentPageReference) pageRef;


    /*******************************************************************************
    *                                                                              *
    *       Connected Callback                                                     *
    *                                                                              *
    * ******************************************************************************/

    connectedCallback() {

        registerListener('stationsChanged', this.handleStationsChanged, this);

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
            this.mainErrorMessage = error;
            this.error = error;
            fireEvent(this.pageRef, 'errorEvent', error);  
        });  

        getAllIftpAirlines()
        .then(result =>{
            let myResult = JSON.parse(JSON.stringify(result));
            this.airlinesList = myResult;
            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].airlineName , value: myResult[el].accountRoleId });
            });
            this.airlineOptions = myTopicOptions;
        })
        .catch(error => {
            this.mainErrorMessage = error;
            this.error = error;
            fireEvent(this.pageRef, 'errorEvent', error);  
        });

        this.initData(); 

        //Id id, String description, String code, String city, String airportDescription
        this.columns = [
            {label: '',
                type: 'button-icon',
                initialWidth: 30,
                typeAttributes: {
                    iconName: 'action:edit',
                    title: 'Edit',
                    name: 'edit',
                    variant: 'border-filled',
                    alternativeText: 'Edit'
                }
            },
            {label: '',
                type: 'button-icon',
                initialWidth: 30,
                typeAttributes: {
                    iconName: 'utility:record_create',
                    title: 'Manage Airlines',
                    name: 'manage_airlines',
                    variant: 'border-filled',
                    alternativeText: 'Manage Airlines'
                },
            },
            {label: '',
                type: 'button-icon',
                initialWidth: 30,
                typeAttributes: {
                    iconName: 'utility:delete',
                    title: 'Delete',
                    name: 'delete',
                    variant: 'border-filled',
                    alternativeText: 'Delete'
                }
            },
            {label: 'Code', fieldName: 'code', type: 'text', sortable: true},
            {label: 'City', fieldName: 'city', type: 'text', sortable: true},
            {label: 'Name', fieldName: 'airportDescription', type: 'text', sortable: true},
            {label: 'Notes', fieldName: 'description', type: 'text', sortable: true}
        ];

        //For Datatable in Add Station
        this.columnsAddNewStation = [
            {label: 'Code', fieldName: 'Code__c', type: 'text', sortable: true},
            {label: 'City', fieldName: 'City__c', type: 'text', sortable: true},
            {label: 'description', fieldName: 'Description__c', type: 'text', sortable: true}
        ];

        //For Datatable in Manage Airlines
        this.columnsManageNewAirlinesList = [
            {label: '',
                type: 'button-icon',
                initialWidth: 20,
                typeAttributes: {
                    iconName: 'utility:delete',
                    title: 'Delete',
                    name: 'deleteAirline',
                    variant: 'border-filled',
                    alternativeText: 'Delete'
                }
            },
            {label: 'Airline Name', fieldName: 'airlineName', type: 'text', sortable: true},
        ]

    }


    initData(){
        this.loading = true;
        this.showSearch = true;
        this.showStations = false;
        this.dataRecords = false;

        getUserInfo()
        .then(result => {
            let myResult2 = JSON.parse(JSON.stringify(result));
            
            this.userInfo = myResult2;
            getITPStations({accountId: myResult2.accountId})
            .then(result2 => {
                let myResult = JSON.parse(JSON.stringify(result2));
    
                let myTopicOptions = [];
    
                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push(myResult[el].Code__c);
                });
    
                this.stationOptions = myTopicOptions;
    
                this.ITPStations = myResult;
            })
            .catch(error => {
                this.mainErrorMessage = error;
                this.error = error;
                fireEvent(this.pageRef, 'errorEvent', error);  
            });  

            getITPStationsForDatatable({accountId: myResult2.accountId})
            .then(results => {
                this.showStations = true;
                if(results && results.length > 0) {
                    this.data = this.sortData('code', 'asc', JSON.parse(JSON.stringify(results)));
                    this.dataRecords = true;
                } else {
                    this.dataRecords = false; 
                }
                this.loading = false;
                this.cleanErrors();
            })
            .catch(error => {
                this.showStations = true;
                this.mainErrorMessage = error;
                this.error = error;
                this.loading = false;
                this.dataRecords = false;
                fireEvent(this.pageRef, 'errorEvent', error);  
            });  
    
    
            getItpStationsAirlines({accountId: myResult2.accountId})
            .then(resultMap =>{
                let myResult = JSON.parse(JSON.stringify(resultMap));
                this.itpStationsAirlinesMap =  myResult;
            })
            .catch(error => {
                this.mainErrorMessage = error;
                this.error = error;
                fireEvent(this.pageRef, 'errorEvent', error);  
            });
     
        })
        .catch(error => {
            this.mainErrorMessage = error;
            this.error = error;
            fireEvent(this.pageRef, 'errorEvent', error);  
        }); 


        this.loading = false;
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
        this.showSearch = true;
        this.loading = true;
        this.initData();
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Add Station                                          *
    *                                                                              *
    * ******************************************************************************/

    handleAddStation() {
        this.loadingNew = false;
        this.handleResetAddStationSearch();
        this.openNewModal = true;
    }

    // to handle the search stations on ADD STATION
    handleSearchOnClick() {
        if(this.queryTerm){
            this.selectedRows = null;
            this.handleSearch();
        } else {
            const event = new ShowToastEvent({
                title: 'Add New Station',
                message: 'Please enter search criteria before pressing \'Search\'.',
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
        }


    }
    handleChangeSearch(event){
        this.queryTerm = event.detail.value;
        
    }
    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
        this.selectedRows = null;
        this.handleSearch();
        }
    }

    handleSearch() {
        this.showSearchResults = false;
        this.hasSearchResults = false;
        this.stationAlreadyAdded = false;
        let allStations = JSON.parse(JSON.stringify(this.allStations));
        let stationOptions = JSON.parse(JSON.stringify(this.stationOptions));
        let ITPStations = JSON.parse(JSON.stringify(this.ITPStations));
        let searchableStations = allStations.filter(station =>{
            return stationOptions.indexOf(station.Code__c) === -1;
        });
        let myResult =  searchableStations.filter(station => { 
            return (station.Code__c !== undefined && station.Code__c.toUpperCase().includes(this.queryTerm.toUpperCase())) || 
                    (station.Description__c !== undefined && station.Description__c.toUpperCase().includes(this.queryTerm.toUpperCase()))|| 
                    (station.City__c !== undefined  && station.City__c.toUpperCase().includes(this.queryTerm.toUpperCase()));
        });
        this.newData = myResult;
        this.newData = this.sortData('code', 'asc', JSON.parse(JSON.stringify(this.newData)));

        
        if(this.newData.length > 0 ){
            this.addStationResultsTitle = 'Select the Station from the table below';
            this.showSearchResults = true;
            this.hasSearchResults = true;
        } else {
            this.addStationResultsTitle = 'Search Results';
            let existingStations = ITPStations.filter(station => { 
                return (station.Code__c !== undefined && station.Code__c.toUpperCase().includes(this.queryTerm.toUpperCase())) || 
                        (station.Description__c !== undefined && station.Description__c.toUpperCase().includes(this.queryTerm.toUpperCase()))|| 
                        (station.City__c !== undefined  && station.City__c.toUpperCase().includes(this.queryTerm.toUpperCase()));
            });
            if(existingStations.length > 0){
                this.stationAlreadyAdded = true;
            }
        }
            
    }

    handleCancel(){
        this.closeNewModal();
        this.handleResetAddStationSearch();
    }

    handleResetAddStationSearch(){
        this.selectedRows = null;
        this.queryTerm = null;
        this.newData = null;
        this.showSearchResults = false;
        this.hasSearchResults = false;
        this.showSaveButton = false;
        this.stationAlreadyAdded = false;
        this.addStationResultsTitle = 'Search Results';
    }

    getSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
        this.showSaveButton = true;
    }

    handleChangeNewStation(event) {
        this.stationOptions = event.detail.value;
    }

    handleChangeDescription(event) {
        this.editData.description = event.detail.value;
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Row Action                                           *
    *                                                                              *
    * ******************************************************************************/

    handleRowAction(event){
        let auxData = JSON.parse(JSON.stringify(this.data));
        let itpStationsAirlinesMap = JSON.parse(JSON.stringify(this.itpStationsAirlinesMap));
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const { id } = row;
        const index = this.findRowIndexById(id);
        const selectedStationAirlinesList = itpStationsAirlinesMap[auxData[index].addressId];
        switch (actionName) {
            case 'edit':
                this.isActionEdit = true;
                this.editData =  auxData[index];
                this.modalTitle = 'Station To Edit';
                this.openModal();
                break;
            case 'delete':
                this.isActionDelete = true;
                this.editData =  auxData[index];
                this.recordToManageOriginalAirlinesList = selectedStationAirlinesList;
                this.modalTitle = 'Station to Delete';
                this.openModal();
                break;
            case 'manage_airlines':
                this.recordToManage = auxData[index];
                this.recordToManageNewAirlinesList = [];
                this.recordToManageOriginalAirlinesList = [];
                this.modalTitle = "Manage Airlines - " + this.recordToManage.code;
                
                if(selectedStationAirlinesList){
                    this.recordToManageNewAirlinesList = selectedStationAirlinesList;
                    this.recordToManageNewAirlinesList = this.sortData('airlineName', 'asc', JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList)));
                    this.recordToManageOriginalAirlinesList = selectedStationAirlinesList;
                }

                this.initManageAirlinesModal();
                break;
            default:
        }      
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Edit Station                                         *
    *                                                                              *
    * ******************************************************************************/

    handleFileDrop(){
        this.closeModal();
    }

    handleUploadFinish(event){
        this.loadingEditSpinner = true;
        const uploadedFiles = JSON.parse(JSON.stringify(event.detail));
        let docdId = uploadedFiles[0].documentId;
        let stationInfo = this.editData.code + ' - ' + this.editData.airportDescription + '\n' + this.editData.arsname;

        manageUploadStationOJT({fileId: docdId, recordID: this.editData.id, stationInfo: stationInfo})        
        .then(result =>{
            if(result){
                const event = new ShowToastEvent({
                    title: 'Upload Station OJT Document',
                    message: 'Document was uploaded successfully and is waiting IATA validation.',
                    variant: 'success',
                    mode: 'pester'
                });
                this.dispatchEvent(event);
                this.loadingEditSpinner = false;
            } else{
                const event = new ShowToastEvent({
                    title: 'Upload Station OJT Document',
                    message: 'An error has occurred. Unable to upload document. ',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                this.loadingEditSpinner = false;
            } 
        });
        
    }


    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    openModal() {
        this.openmodal = true;
    }
    closeModal() {
        this.openmodal = false;
    }
    openNewModal() {
        this.openNewModal = true;
    }
    closeNewModal() {
        this.openNewModal = false;
        this.handleResetAddStationSearch();
    }

    handleEditDeleteCancel(){
        this.closeModal();
        this.isActionDelete = false;
        this.isActionEdit = false;
    }
   
    handleSave(){
        this.loadingEditSpinner = true;
        let dataToSave = [];
        let auxData = JSON.parse(JSON.stringify(this.data));
        let auxEditData = JSON.parse(JSON.stringify(this.editData));

        if(auxEditData.description !== undefined && auxEditData.description !== ''){ 
            dataToSave.push({ Id: auxEditData.id, Description__c: auxEditData.description, Address__c: auxEditData.addressId});
        } else {
            dataToSave.push({ Id: auxEditData.id, Description__c: '', Address__c: auxEditData.addressId});
        }

        updateStation({dataToSave: dataToSave, origin: 'updateStation', accountId: this.userInfo.accountId})
        .then(results => {
            let variant = 'error';
            let mode = 'sticky';
            let message = 'Unable to edit stations\' Notes';
            if(results.succeeded) {
                this.cleanErrors();
                
                Object.keys(auxData).forEach(function (el) {
                    if(auxData[el].id === auxEditData.id){ 
                        auxData[el].description = auxEditData.description;
                    }
                });
                variant = 'success';
                mode = 'pester'; 
                message = 'Station\' notes updated successfully.'  
                this.data = auxData;                 
            } else {
                message = results.result_message;
                this.loading = true;
                this.initData();
            }
            const event = new ShowToastEvent({
                title: 'Edit Station Result',
                message: message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);

            this.loadingEditSpinner = false;
            this.closeModal();
            this.isActionEdit = false;
            
        })
        .catch(error => {
            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
            this.loadingEditSpinner = false;
            this.closeModal();
            this.isActionEdit = false;
            fireEvent(this.pageRef, 'errorEvent', error);  
        });  

    }

    /* Add a Station in Manage Stations */
    handleNewSave(){
        let dataToSave = [];
        let auxData = JSON.parse(JSON.stringify(this.selectedRows));
        let auxStationOptions = JSON.parse(JSON.stringify(this.stationOptions));
        let auxUserInfo = JSON.parse(JSON.stringify(this.userInfo));
        let addressId = '';
        let roleAddressName = '';
        let exists = false;

        Object.keys(auxStationOptions).forEach(function (el) {

            if(auxStationOptions[el] === auxData[0].Code__c){ 
                exists = true;
            }          
        });  
        if(!exists){
            addressId = auxData[0].Id;
            
            roleAddressName = auxData[0].Code__c;
            
            dataToSave.push({ Address__c: addressId, Name: roleAddressName, Account_Role_Service__c: auxUserInfo.accountRoleSrv});
        }

        this.loadingNew = true;
        insertStation({accountId: auxUserInfo.accountId, dataToSave: dataToSave, accountName: auxUserInfo.accountName})
        .then(results => {
            let variant;
            let mode;
            if(results.succeeded){
                variant = 'success';
                mode = 'pester';

                this.showSearch = true;
                this.loading = true;
                this.initData();
                fireEvent(this.pageRef, 'stationsChanged', null);

            } else {
                variant = 'error';
                mode = 'sticky';
            }
            const event = new ShowToastEvent({
                title: 'Add Station Result',
                message: results.result_message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);

            this.loadingNew = false;
        });
        this.closeNewModal();
    }

    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Delete Station                                       *
    *                                                                              *
    * ******************************************************************************/

    handleRequestDelete(){
        this.loadingDeleteSpinner = true;
        let stationToDelete = JSON.parse(JSON.stringify(this.editData));
        let userInfo = JSON.parse(JSON.stringify(this.userInfo));

        getITPStationEmployees({accountId: userInfo.accountId, addressId: stationToDelete.addressId})
        .then(results =>{
            let existsEmployees = false;
            //Check if there are employees working in that station for that ITP
            let stationsWithEmployees = JSON.parse(JSON.stringify(results));
            if(stationsWithEmployees.Role_Addresses__r !== undefined && stationsWithEmployees.Role_Addresses__r.length > 0){
                existsEmployees = true;
            }

            if(existsEmployees) {
                const event = new ShowToastEvent({
                    title: 'Delete Station Result',
                    message: 'Failed: ' + this.editData.code + ' Cannot be deleted. The ITP still has employees working on it.',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                this.isActionDelete = false;
                this.closeModal();
                this.loadingDeleteSpinner = false;
            } else {
                this.loadingDeleteSpinner = false;
                if(this.recordToManageOriginalAirlinesList !== undefined && this.recordToManageOriginalAirlinesList.length > 0){
                    this.askForconfirmationMessage = 'There are airlines connected, are you sure you want to delete it?';
                } else {
                    this.askForconfirmationMessage = 'Are you sure you want to delete it?';
                }
                
                this.openConfirmationModal = true;
            }
            
        })
    }

    deleteConfirmation(){
        this.loadingDeleteSpinner = true;
        this.loadingSpinner = true;
        let itpStationsAirlinesMap = JSON.parse(JSON.stringify(this.itpStationsAirlinesMap));
        let stationToDelete = JSON.parse(JSON.stringify(this.editData));
        let auxItpStations = JSON.parse(JSON.stringify(this.ITPStations));
        let auxData = JSON.parse(JSON.stringify(this.data));
        let auxStationOptions = JSON.parse(JSON.stringify(this.stationOptions));
        let userInfo = JSON.parse(JSON.stringify(this.userInfo));
        
        let recordToManageOriginalAirlinesList = [];
        if(this.recordToManageOriginalAirlinesList){
            recordToManageOriginalAirlinesList = JSON.parse(JSON.stringify(this.recordToManageOriginalAirlinesList));
        }
        this.openConfirmationModal = false;
        this.askForconfirmationMessage = '';

        deleteStationFromItp({accountId:userInfo.accountId, stationToBeDeleted: stationToDelete, stationToBeDeletedAirlinesList: recordToManageOriginalAirlinesList})
        .then(results =>{
            
            let resultWrapper = JSON.parse(JSON.stringify(results));
            let variant;
            let mode;
            if(resultWrapper.succeeded){

                variant = 'success';
                mode = 'pester';
                // Update related variables to maintain consistency between interface and database
                for(let i = 0; i < auxItpStations.length; i++){
                    if(auxItpStations[i].Code__c === stationToDelete.code){
                        auxItpStations.splice(i,1);
                        i = auxItpStations.length;
                        this.ITPStations = auxItpStations;
                    }
                }
    
                for(let i = 0; i < auxStationOptions.length; i++){
                    if(auxStationOptions[i] === stationToDelete.code){
                        auxStationOptions.splice(i,1);
                        i = auxStationOptions.length;
                        this.stationOptions = auxStationOptions;
                    }
                }
                
                for(let i = 0; i < auxData.length; i++){
                    if(auxData[i].code === stationToDelete.code){
                        auxData.splice(i,1);
                        i = auxData.length;
                        this.data = auxData;
                    }
                }

                delete this.itpStationsAirlinesMap[stationToDelete.addressId];
                fireEvent(this.pageRef, 'stationsChanged', null);

            } else {
                variant = 'error';
                mode = 'sticky';
            }
            const event = new ShowToastEvent({
                title: 'Delete Station Result',
                message: resultWrapper.result_message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);

            this.closeModal();
            this.isActionDelete = false;
            this.deleteStationResetVariables();
            this.loadingDeleteSpinner = false;
        })
    }

    closeConfirmationModal(){
        this.openConfirmationModal = false;
        this.askForconfirmationMessage = '';
    }

    deleteStationResetVariables(){
        this.askForconfirmationMessage = '';
        this.editData = {};
        this.recordToManageOriginalAirlinesList = [];
        this.modalTitle = '';
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to manage Airlines                                                  *
    *                                                                              *
    * ******************************************************************************/
    initManageAirlinesModal(){
        this.openAddAirlineModal = true;
        this.loadingSpinner = true;
        let airlinesProneToAdd = [];
        let recordToManageNewAirlinesList = JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList));
        let airlineOptions = JSON.parse(JSON.stringify(this.airlineOptions));

        if(recordToManageNewAirlinesList.length > 0){
            let exists = false;
            airlineOptions.forEach(airlineOpt =>{
                recordToManageNewAirlinesList.forEach(airline =>{
                    if(airline.airlineAccRolId === airlineOpt.value){
                        exists = true;
                    }
                })
                if(!exists){
                    airlinesProneToAdd.push(airlineOpt);
                }
                exists = false;
            })
        } else {
            airlinesProneToAdd = airlineOptions;
        }
        
        if(airlinesProneToAdd.length > 0){
            this.airlinesProneToAdd = airlinesProneToAdd;
            this.airlinesProneToAdd = this.sortData('label', 'asc', JSON.parse(JSON.stringify(this.airlinesProneToAdd)));
            this.showAirlinesList = true;
        }

        if(recordToManageNewAirlinesList.length > 0){
            this.hasNoAirlines = false;
        } else{
            this.hasNoAirlines = true;
        }
        if(airlinesProneToAdd.length > 0){
            this.showAirlinesList = true;
        } else{
            this.showAirlinesList = false;
        }
        
        this.loadingSpinner = false;
    }

    handleChangeAirlinesProneToAdd(event){
        this.manageAirlineValue = event.detail.value;
    }

    handleAddAirlineToItpStation(){
        if(this.manageAirlineValue){
            this.loadingSpinner = true;
            let airlinesList = JSON.parse(JSON.stringify(this.airlinesList));
            let airlinesProneToAdd = JSON.parse(JSON.stringify(this.airlinesProneToAdd));
            let recordToManage = JSON.parse(JSON.stringify(this.recordToManage));
            let recordToManageNewAirlinesList = JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList));
            // Remove from airlinesProneToAdd list the airline selected
            for(let i = 0; i < airlinesProneToAdd.length; i++){
                if(airlinesProneToAdd[i].value === this.manageAirlineValue){
                    airlinesProneToAdd.splice(i,1);
                    i = airlinesProneToAdd.length;
                }
            }
            // Add to recordToManageNewAirlinesList the airline selected
            for(let i = 0; i < airlinesList.length; i++){
                if(this.manageAirlineValue === airlinesList[i].accountRoleId){
                    let newAirlineRecord = {};
                    newAirlineRecord.addressDescription = recordToManage.airportDescription;
                    newAirlineRecord.addressId = recordToManage.addressId;
                    newAirlineRecord.airlineAccRolId = airlinesList[i].accountRoleId;
                    newAirlineRecord.airlineAccRolServId = airlinesList[i].accountRoleServiceId;
                    newAirlineRecord.airlineName = airlinesList[i].airlineName;
    
                    recordToManageNewAirlinesList.push(newAirlineRecord);
                }
            }
            this.airlinesProneToAdd = airlinesProneToAdd;
    
            this.recordToManageNewAirlinesList = recordToManageNewAirlinesList;
            this.recordToManageNewAirlinesList = this.sortData('airlineName', 'asc', JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList)));
            if(recordToManageNewAirlinesList.length > 0){
                this.hasNoAirlines = false;
            } else{
                this.hasNoAirlines = true;
            }
            if(airlinesProneToAdd.length > 0){
                this.showAirlinesList = true;
            } else{
                this.showAirlinesList = false;
            }
            this.manageAirlinesHasChanges = true;
            this.manageAirlineValue = null;
            this.loadingSpinner = false;
        }
    }

    handleManageStationAirlinesRowAction(event){
        this.loadingSpinner = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        let airlineAccRolId = row.airlineAccRolId;
        let recordToManageNewAirlinesList = JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList));
        let airlinesProneToAdd = JSON.parse(JSON.stringify(this.airlinesProneToAdd));

        switch (actionName) {
            case 'deleteAirline':

                for(let i = 0; i < recordToManageNewAirlinesList.length; i++){
                    if(recordToManageNewAirlinesList[i].airlineAccRolId === airlineAccRolId){
                        recordToManageNewAirlinesList.splice(i, 1);
                        i = recordToManageNewAirlinesList.length;
                    }
                }

                airlinesProneToAdd.push({ label: row.airlineName, value: airlineAccRolId });
                this.airlinesProneToAdd = airlinesProneToAdd;
                this.recordToManageNewAirlinesList = recordToManageNewAirlinesList;

                if(recordToManageNewAirlinesList.length > 0){
                    this.recordToManageNewAirlinesList = this.sortData('airlineName', 'asc', JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList)));
                    this.hasNoAirlines = false;
                } else{
                    this.hasNoAirlines = true;
                }
                if(airlinesProneToAdd.length > 0){
                    this.airlinesProneToAdd = this.sortData('label', 'asc', JSON.parse(JSON.stringify(this.airlinesProneToAdd)));
                    this.showAirlinesList = true;
                } else{
                    this.showAirlinesList = false;
                }
                this.manageAirlinesHasChanges = true;
                this.loadingSpinner = false;
                break;
            default:
        }
    }

    handleManageAirlinesCancel(){
        this.openAddAirlineModal = false;
        this.resetManageAirlinesVariable();
    }

    handleManageAirlinesSave(){
        this.loadingManageAirlinesSpinner = true;
        let recordToManage = JSON.parse(JSON.stringify(this.recordToManage));
        let recordToManageNewAirlinesList = JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList));
        let recordToManageOriginalAirlinesList = JSON.parse(JSON.stringify(this.recordToManageOriginalAirlinesList));
        let userInfo = JSON.parse(JSON.stringify(this.userInfo));
        let itpAccRolId = userInfo.accountRole;

        let airlinesItpAddressToInsert = [];
        if(recordToManageNewAirlinesList.length > 0){
            recordToManageNewAirlinesList.forEach(airline =>{
                let a = {};
                a.addressId = recordToManage.addressId;
                a.addressCode = recordToManage.code;
                a.addressCity = recordToManage.city;
                a.addressDescription = recordToManage.airportDescription;
                a.airlineAccRolId = airline.airlineAccRolId;
                a.airlineName = airline.airlineName;
                a.airlineAccRolServId = airline.airlineAccRolServId;
                a.itpName = userInfo.accountName;
                a.itpAccRolId = userInfo.accountRole;
                a.itpAccRolServId = userInfo.accountRoleSrv;
                
                airlinesItpAddressToInsert.push(a);
            })
        }

        updateItpAddressAirlines({itpAccountRoleId: itpAccRolId,
                                    airlinesItpAddressToInsert: airlinesItpAddressToInsert, 
                                    airlinesItpAddressToDelete: recordToManageOriginalAirlinesList})
        .then(result =>{
            let variant;
            let mode;
            // Show message to user
            if(result.succeeded){
                variant = 'success';
                mode = 'pester';
            } else {
                variant = 'error';
                mode = 'sticky';
            }
            const event = new ShowToastEvent({
                title: 'Manage Airlines Result',
                message: result.result_message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);

            // update itpStationsAirlinesMap
            if(result.succeeded){
                this.itpStationsAirlinesMap[recordToManage.addressId] = result.airlinesItpAddressManaged;
            }
            this.openAddAirlineModal = false;
            this.resetManageAirlinesVariable();
            this.loadingManageAirlinesSpinner = false;
        })
    }

    resetManageAirlinesVariable(){
        this.airlinesProneToAdd = [];
        this.recordToManage = {};
        this.recordToManageNewAirlinesList = [];
        this.recordToManageOriginalAirlinesList = [];
        this.manageAirlinesHasChanges = false;
        this.manageAirlineValue = null;
    }

    /*******************************************************************************
    *                                                                              *
    *  Sorting Methods                                                             *
    *                                                                              *
    * ******************************************************************************/
    updatecolumnsAddNewStationSorting(event){
        let fieldName = event.detail.fieldName;
        let sortedDirectionStationOptions = event.detail.sortDirection;
        this.sortedDirectionStationOptions = sortedDirectionStationOptions;
        this.sortedByStationOptions = fieldName;
        let auxdata = JSON.parse(JSON.stringify(this.newData));
        this.newData = this.sortData(fieldName, sortedDirectionStationOptions, auxdata);
    }
    
    updatecolumnsManageNewAirlinesListSorting(event) {
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.manageAirlinesSortedBy = fieldName;
        this.manageAirlinesSortedDirection = sortDirection;
        let auxdata = JSON.parse(JSON.stringify(this.recordToManageNewAirlinesList));
        this.recordToManageNewAirlinesList = this.sortData(fieldName, sortDirection, auxdata);
    }

    // The method onsort event handler
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
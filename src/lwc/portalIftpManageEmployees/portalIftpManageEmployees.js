import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';

import addNewEmployee from '@salesforce/apex/PortalIftEmployeeRecordsManagement.addNewEmployee';
import getITPEmployeesWithStationsInfo from '@salesforce/apex/PortalIftEmployeeRecordsManagement.getITPEmployeesWithStationsInfo';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import inactivateEmployee from '@salesforce/apex/PortalIftEmployeeRecordsManagement.inactivateEmployee';
import updateEmployee from '@salesforce/apex/PortalIftEmployeeRecordsManagement.updateEmployee';
import updateEmployeeStations from '@salesforce/apex/PortalIftEmployeeRecordsManagement.updateEmployeeStations';

export default class PortalIftpManageEmployees extends LightningElement {

    @track error;
    @track mainErrorMessage;

    @track userInfo;
    @track stationOptions;
    ITPStations;
    @track ITPEmployeesWithStationsInfo = [];

    @track stationValue;
    @track manageStationValue;
    @track firstNameValue;
    @track lastNameValue;
    @track employeeCodeValue;
    @track loading = false;

    @track showSearch = false;
    @track hasSearchResults = false;

    @track columnsSearchEmployees;
    @track sortedBy;
    @track sortedDirection;
    @track sortedrecordToManageStationsListBy;
    @track sortedrecordToManageStationsListDirection;

    @track openModal = false;
    @track modalTitle = '';
    @track loadingModal = false;
    @track loadingSpinner = false;
    @track recordToManage = {};
           newEmployeeCode = '';
    @track recordToManageStationsList = [];
    @track recordToManageNewStationsList = [];
    @track managedStationOptions = [];
    @track hasNoStations = true;
    @track isActionView = false;
    @track isActionEdit = false;
    @track isActionDelete = false;
    @track isActionNew = false;
    @track enableCodeEditing = false;
    @track columnsShowEmployeeStations;
    @track employeeRoleOptions = [({label: 'ITP Trainee', value: 'ITP Trainee'})];
    @track employeeToInsert = {};
        
    @track openConfirmationModal = false;
    @track openStationsModal = false;
    @track stationsProneToAdd = [];
    @track showStationsList = false;
    @track auxSearchValues = {};
           wiredITPEmployeesWithStationsInfoResult;
    
    @wire(CurrentPageReference) pageRef;

    @wire(getITPEmployeesWithStationsInfo, {searchValues: '$auxSearchValues', origin: 'Manage Employees'} )
    handleITPEmployeesWithStationsInfoResults(result){
        this.wiredITPEmployeesWithStationsInfoResult = result;
        if(result.data){
            let myResults = JSON.parse(JSON.stringify(result.data));
            myResults.forEach(rec =>{
                rec.Primary_Station_Code = '';
                rec.upperCase = 'to-upper-case';
                if(rec.Role_Addresses__r){
                    rec.Role_Addresses__r.forEach(recRolAdd =>{
                        if(recRolAdd.Primary__c){
                            rec.Primary_Station_Code = recRolAdd.Address__r.Code__c;
                        } 
                    })
                }
            })
            this.ITPEmployeesWithStationsInfo = JSON.parse(JSON.stringify(myResults));
            if(this.ITPEmployeesWithStationsInfo.length > 0){
                this.ITPEmployeesWithStationsInfo = this.sortData('Last_Name__c', 'asc', JSON.parse(JSON.stringify(this.ITPEmployeesWithStationsInfo)));
                this.hasSearchResults = true;
            } else {
                this.hasSearchResults = false;
            }
        }
        if(result.error){
            this.hasSearchResults = false;
            const event = new ShowToastEvent({
                title: 'Employees Data',
                message: 'Unable to get employees data from database.',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
            console.log('error', result.error);
        }
    }

    connectedCallback() {
        console.log('INIT connectedCallback');
        registerListener('employeesChanged', this.handleEmployeesChanged, this);

        getITPStations()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            
            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
            });
            this.ITPStations = myResult;
            this.stationOptions = this.sortData('value', 'asc', JSON.parse(JSON.stringify(myTopicOptions)));
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
        console.log("starting");

        //For Datatable in Manage Employees Search
        this.columnsSearchEmployees = [
            {label: '',
                type: 'button-icon',
                initialWidth: 30,
                typeAttributes: {
                    iconName: 'utility:preview',
                    title: 'View',
                    name: 'view',
                    variant: 'border-filled',
                    alternativeText: 'View'
                }
            },
            {label: '',
                type: 'button-icon',
                initialWidth: 30,
                typeAttributes: {
                    iconName: 'utility:edit',
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
                    iconName: 'utility:world',
                    title: 'Manage Employee Stations',
                    name: 'manage_employee_stations',
                    variant: 'border-filled',
                    alternativeText: 'Manage Employee Stations'
                }
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
            {label: 'Last Name', fieldName: 'Last_Name__c', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
            {label: 'First Name', fieldName: 'First_Name__c', type: 'text', sortable: true},
            {label: 'Employee Code', fieldName: 'Company_Code__c', type: 'text', sortable: true},
            {label: 'Primary Station', fieldName: 'Primary_Station_Code', type: 'text', sortable: true}
        ];

        this.columnsShowEmployeeStations = [
            {label: 'Code', fieldName: 'Code__c', type: 'text', sortable: true},
            {label: 'City', fieldName: 'City__c', type: 'text', sortable: true},
            {label: 'Name', fieldName: 'Description__c', type: 'text', sortable: true},
            {label: 'Primary', fieldName: 'Primary__c', type: 'boolean', sortable: true},
        ];

        this.columnsManageEmployeeStations = [
            {label: '',
                type: 'button-icon',
                initialWidth: 20,
                typeAttributes: {
                    iconName: 'utility:delete',
                    title: 'Delete',
                    name: 'delete',
                    variant: 'border-filled',
                    alternativeText: 'Delete'
                }
            },
            {label: 'Code', fieldName: 'Code__c', type: 'text', sortable: true},
            {label: 'City', fieldName: 'City__c', type: 'text', sortable: true},
            {label: 'Name', fieldName: 'Description__c', type: 'text', sortable: true}
        ];

        console.log('END connectedCallback');

    }

    disconnectedCallback() {
		// unsubscribe from bearListUpdate event
		unregisterAllListeners(this);
	}

    handleEmployeesChanged(){
        this.handleSearchButtonClick();
    }

    /***********************************************************
    *                                                          *
    *  Methods to handle Search activities                     *
    *                                                          *
    ************************************************************/

    handleChangeFirstName(event) {
        this.firstNameValue = event.detail.value;
        this.auxSearchValues.firstName = this.firstNameValue.trim();  
    }

    handleChangeLastName(event) {
        this.lastNameValue = event.detail.value;
        this.auxSearchValues.lastName = this.lastNameValue.trim();
    }

    handleChangeEmployeeCodeValue(event) {
        this.employeeCodeValue = event.detail.value;
        this.auxSearchValues.employeeCode = this.employeeCodeValue.trim();
    }

    handleChangeStation(event) {
        this.stationValue = event.detail.value;
        this.auxSearchValues.stationCode = this.stationValue.trim();
    }

    handleSearchButtonClick() {
        this.loading = true;
        this.showSearch = true;
        refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
        this.loading = false;
    }

    handleResetButtonClick(){
        this.stationValue = null;
        this.firstNameValue = null;
        this.lastNameValue = null;
        this.employeeCodeValue = null;
        this.auxSearchValues = {};
        this.showSearch = false;
        this.hasSearchResults = false;
        this.error = '';
        this.mainErrorMessage = '';
        this.isActionView = false;
        this.isActionEdit = false;
        this.isActionDelete = false;
        this.ITPEmployeesWithStationsInfo = [];
    }

    /***********************************************************
    *                                                          *
    *  Methods to handle Add New Employee activities           *
    *                                                          *
    * **********************************************************/

    handleAddEmployee(){
        this.modalTitle = 'Add New Employee';
        this.isActionNew = true;
        this.openModal = true;
        this.employeeToInsert.role = 'ITP Trainee';
    }

    handleChangeEmployeeCode(event){
        this.employeeToInsert.code = event.detail.value;
    }
    handleChangeEmployeeFirstName(event){
        this.employeeToInsert.first_name = event.detail.value.trim();
    }

    handleChangeEmployeeLastName(event){
        this.employeeToInsert.last_name = event.detail.value.trim();
    }

    handleChangeEmployeeTitle(event){
        this.employeeToInsert.title = event.detail.value.trim();
    }

    handleChangeEmployeePhone(event){
        this.employeeToInsert.phone = event.detail.value.trim();
    }

    handleChangeEmployeeDetails(event){
        this.employeeToInsert.details = event.detail.value.trim();
    }

    handleNewEmployeeSave(){
        this.loadingSpinner = true;
        let exists = false;
        const allValid = [...this.template.querySelectorAll('lightning-input'), ...this.template.querySelectorAll('lightning-combobox') ]
            .reduce((validSoFar, inputCmp) => {
                        if(inputCmp.name === 'employee_code' && this.employeeToInsert.code){
                            for(let i = 0; i < this.ITPEmployeesWithStationsInfo.length; i++){
                                if(this.ITPEmployeesWithStationsInfo[i].Company_Code__c.toLowerCase() === this.employeeToInsert.code.toLowerCase()){
                                    exists = true;
                                    i = this.ITPEmployeesWithStationsInfo.length;
                                }
                            }
                            inputCmp.setCustomValidity(exists ? 'Employee with this Employee Code already exists.': '');
                        }
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        this.loadingSpinner = false;
        if (allValid) {
            this.loadingSpinner = true;
            addNewEmployee({employeeToInsert: this.employeeToInsert})
            .then(r => {
                let result = JSON.parse(JSON.stringify(r));
                let variant;
                let mode;
                if(result.succeeded){
                    this.openModal = false;
                    this.handleResetActionValues();
                    refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                    variant = 'success';
                    mode = 'pester';
                } else {
                    variant = 'error';
                    mode = 'sticky';
                }
                this.loadingSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Add Employee Result',
                    message: result.result_message,
                    variant: variant,
                    mode: mode
                });
                this.dispatchEvent(event);
            });
        }
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle View/Edit/Delete/AddStations actions on Employee          *
    *                                                                              *
    * ******************************************************************************/

    handleRowAction(event){
        this.handleResetActionValues();
        this.hasNoStations = true;
        let ITPEmployeesWithStationsInfo = JSON.parse(JSON.stringify(this.ITPEmployeesWithStationsInfo));
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        let id = row.Id;
        let index = -1;
        
        for(let i = 0; i < ITPEmployeesWithStationsInfo.length; i++){
            if(id === ITPEmployeesWithStationsInfo[i].Id){
                this.recordToManage = ITPEmployeesWithStationsInfo[i];
                index = i;
                i = ITPEmployeesWithStationsInfo.length;
            }
        }

        if(this.recordToManage.Role_Addresses__r){
            this.hasNoStations = false;
            for(let i = 0; i < this.recordToManage.Role_Addresses__r.length; i++){
                let station = {};
                station.City__c = this.recordToManage.Role_Addresses__r[i].Address__r.City__c;
                station.Code__c = this.recordToManage.Role_Addresses__r[i].Address__r.Code__c;
                station.Description__c = this.recordToManage.Role_Addresses__r[i].Address__r.Description__c;
                station.Id = this.recordToManage.Role_Addresses__r[i].Address__r.Id;
                station.Primary__c = this.recordToManage.Role_Addresses__r[i].Primary__c;
                this.recordToManageStationsList.push(station);
            }
            this.recordToManageStationsList = this.sortData('Code__c', 'asc', JSON.parse(JSON.stringify(this.recordToManageStationsList )));
        } else {
            this.recordToManage.Role_Addresses__r = [];
        }

        switch (actionName) {
            case 'view':
                this.isActionView = true;
                this.modalTitle = 'Employee Record Details';
                this.openModal = true;
                break;
            case 'edit':
                this.isActionEdit = true;
                this.modalTitle = 'Employee to Edit';
                this.openModal = true;
                break;
            case 'delete':
                this.isActionView = true;
                this.isActionDelete = true;
                this.modalTitle = 'Employee to Delete';
                this.openModal = true;
                break;
            case 'manage_employee_stations':
                this.modalTitle = "Manage Employee's Stations";
                this.initManageStationsModal();
                break;
            default:
        }
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle Update Action                                             *
    *                                                                              *
    * ******************************************************************************/
    handleChangeEditEmployeeCode(event){
        this.newEmployeeCode = event.detail.value.trim();
    }

    handleChangeEditEmployeeFirstName(event){
        this.recordToManage.First_Name__c = event.detail.value.trim();
    }

    handleChangeEditEmployeeLasttName(event){
        this.recordToManage.Last_Name__c = event.detail.value.trim();
    }

    handleChangeEditEmployeePhone(event){
        this.recordToManage.Business_Phone__c = event.detail.value.trim();
    }

    handleChangeEditEmployeeTitle(event){
        this.recordToManage.Title__c = event.detail.value.trim();
    }

    handleChangeEditEmployeeDetails(event){
        this.recordToManage.Details__c = event.detail.value.trim();
    }
    handleUpdateEmployeeSave(){
        this.loadingSpinner = true;
        let exists = false;
        const allValid = [...this.template.querySelectorAll('lightning-input'), ...this.template.querySelectorAll('lightning-combobox') ]
        .reduce((validSoFar, inputCmp) => {
            if(inputCmp.name === 'employee_code' && this.newEmployeeCode){
                for(let i = 0; i < this.ITPEmployeesWithStationsInfo.length; i++){
                    if((this.newEmployeeCode.toLowerCase() !== this.recordToManage.Company_Code__c) &&
                    (this.ITPEmployeesWithStationsInfo[i].Company_Code__c.toLowerCase() === this.newEmployeeCode.toLowerCase()))
                    {
                        exists = true;
                        i = this.ITPEmployeesWithStationsInfo.length;
                    }
                }
                inputCmp.setCustomValidity(exists ? 'Employee with this Employee Code already exists.': '');
            }
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);    
        this.loadingSpinner = false;
        if (allValid) {
            this.loadingSpinner = true;

            if(!this.recordToManage.Business_Phone__c){
                this.recordToManage.Business_Phone__c = '999999999';
            }

            if(this.newEmployeeCode !== ''){
                this.recordToManage.Company_Code__c = this.newEmployeeCode;
            }
            let record = JSON.parse(JSON.stringify(this.recordToManage));
            record.Role_Addresses__r = null;
            updateEmployee({recordToUpdate: record})
            .then(r => {
                let result = JSON.parse(JSON.stringify(r));
                let variant;
                let mode; 
                if(result.succeeded){
                    this.openModal = false;
                    this.handleResetActionValues();
                    refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                    variant = 'success';
                    mode = 'pester';
                } else {
                    variant = 'error';
                    mode = 'sticky';
                }
                this.loadingSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Update Employee Result',
                    message: result.result_message,
                    variant: variant,
                    mode: mode
                });
                this.dispatchEvent(event);
            });
        }
    }


    /*******************************************************************************
    *                                                                              *
    *  Methods to handle Delete Action                                             *
    *                                                                              *
    * ******************************************************************************/
    handleDelete(){
        this.openConfirmationModal = true;
    }

    deleteConfirmation(){
        this.loadingSpinner = true;
        this.closeConfirmationModal();

        let result;
        let index;
        let ITPEmployeesWithStationsInfo = JSON.parse(JSON.stringify(this.ITPEmployeesWithStationsInfo));
        for(let i = 0; i < ITPEmployeesWithStationsInfo.length; i++){
            if(ITPEmployeesWithStationsInfo[i].Id === this.recordToManage.Id){
                ITPEmployeesWithStationsInfo[i].Status__c = 'Inactive';
                index = i;
                i = ITPEmployeesWithStationsInfo.length;
            }
        }
        ITPEmployeesWithStationsInfo[index].Role_Addresses__r = null;
        inactivateEmployee({dataToInactivate: ITPEmployeesWithStationsInfo[index]})
        .then(r => {
            result = JSON.parse(JSON.stringify(r));
            let variant;
            let mode;
            if(result.succeeded){
                this.openModal = false;
                this.handleResetActionValues();
                refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                variant = 'success';
                mode = 'pester';
            } else {
                variant = 'error';
                mode = 'sticky';
            }
            this.loadingSpinner = false;

            const event = new ShowToastEvent({
                title: 'Delete Employee Result',
                message: result.result_message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);
        })
    }

    closeConfirmationModal(){
        this.openConfirmationModal = false;
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle Manage Employye's Stations                                *
    *                                                                              *
    * ******************************************************************************/
    initManageStationsModal(){
        this.openStationsModal = true;
        this.loadingModal = true;
        let stationsProneToAdd = [];
        let recordToManageNewStationsList = JSON.parse(JSON.stringify(this.recordToManageStationsList));
        let stationOptions = JSON.parse(JSON.stringify(this.stationOptions));
        this.recordToManageNewStationsList = recordToManageNewStationsList;
        if(recordToManageNewStationsList.length > 0){
            this.recordToManageNewStationsList = this.sortData('Code__c', 'asc', JSON.parse(JSON.stringify(this.recordToManageNewStationsList)));
            let exists = false;
            stationOptions.forEach(stationOpt =>{
                recordToManageNewStationsList.forEach(station =>{
                    if(station.Code__c === stationOpt.value){
                        exists = true;
                    }
                })
                if(!exists){
                    stationsProneToAdd.push(stationOpt);
                }
                exists = false;
            })
        } else {
            stationsProneToAdd = stationOptions;
        }

        this.loadingModal = false;
        if(stationsProneToAdd.length > 0){
            this.stationsProneToAdd = stationsProneToAdd;
            this.stationsProneToAdd = this.sortData('value', 'asc',JSON.parse(JSON.stringify(this.stationsProneToAdd)));
            this.showStationsList = true;
        }
    
    }



    handleChangeStationsProneToAdd(event){
        this.manageStationValue = event.detail.value;
    }

    handleAddStationToEmployee(){
        this.loadingModal = true;
        let stationsProneToAdd = JSON.parse(JSON.stringify(this.stationsProneToAdd));
        let recordToManageNewStationsList = JSON.parse(JSON.stringify(this.recordToManageNewStationsList));
        let ITPStations = JSON.parse(JSON.stringify(this.ITPStations));
        for(let i = 0; i < stationsProneToAdd.length; i ++){
            if(stationsProneToAdd[i].value === this.manageStationValue){
                stationsProneToAdd.splice(i,1);
                i = stationsProneToAdd.length;
            }
        }
        this.stationsProneToAdd = stationsProneToAdd;
        for(let j = 0; j < ITPStations.length; j++){
            if(ITPStations[j].Code__c === this.manageStationValue){
                recordToManageNewStationsList.push(ITPStations[j]);
                j = ITPStations.length;
            }
        }
        this.recordToManageNewStationsList = recordToManageNewStationsList;
        if(recordToManageNewStationsList.length > 0){
            this.recordToManageNewStationsList = this.sortData('Code__c', 'asc', JSON.parse(JSON.stringify(this.recordToManageNewStationsList)));
            this.hasNoStations = false;
        } else{
            this.hasNoStations = true;
        }
        if(stationsProneToAdd.length > 0){
            this.showStationsList = true;
        } else{
            this.showStationsList = false;
        }
        this.loadingModal = false;
    }

    handleManageEmployeeStationsRowAction(event){
        this.loadingSpinner = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        let code = row.Code__c;
        let recordToManageNewStationsList = JSON.parse(JSON.stringify(this.recordToManageNewStationsList));
        let stationsProneToAdd = JSON.parse(JSON.stringify(this.stationsProneToAdd));

        switch (actionName) {
            case 'delete':
                for(let i = 0; i < recordToManageNewStationsList.length; i++){
                    if(recordToManageNewStationsList[i].Code__c === code){
                        recordToManageNewStationsList.splice(i, 1);
                        i = recordToManageNewStationsList.length;
                    }
                }
                stationsProneToAdd.push({ label: row.Code__c + ' - ' + row.Description__c, value: row.Code__c });
                this.stationsProneToAdd = stationsProneToAdd;
                this.recordToManageNewStationsList = recordToManageNewStationsList;
                if(recordToManageNewStationsList.length > 0){
                    this.recordToManageNewStationsList = this.sortData('Code__c', 'asc', JSON.parse(JSON.stringify(this.recordToManageNewStationsList)));
                    this.hasNoStations = false;
                } else{
                    this.hasNoStations = true;
                }
                if(stationsProneToAdd.length > 0){
                    this.stationsProneToAdd = this.sortData('value', 'asc',JSON.parse(JSON.stringify(this.stationsProneToAdd)));
                    this.showStationsList = true;
                } else{
                    this.showStationsList = false;
                }
                this.loadingSpinner = false;
                break;
            default:
        }
    }


    handleManageEmployeeStationsSave(){
        this.loadingSpinner = true;
        let recordToManage = JSON.parse(JSON.stringify(this.recordToManage));
        let recordToManageNewStationsList = JSON.parse(JSON.stringify(this.recordToManageNewStationsList));
        let stationsToDelete = [];
        let stationsToInsert = [];
        if(recordToManage.Role_Addresses__r.length > 0){
            recordToManage.Role_Addresses__r.forEach((rolAddr => {
                let r = {};
                r.Id = rolAddr.Id;
                r.Account_Contact_Role__c = recordToManage.Id;
                r.Address__c = rolAddr.Address__c;
                stationsToDelete.push(r);
            }))

        }
        if(recordToManageNewStationsList.length > 0){
            recordToManageNewStationsList.forEach(station =>{
                let r = {};
                r.Account_Contact_Role__c = recordToManage.Id;
                r.Address__c = station.Id;
                stationsToInsert.push(r);
            })
        }
        updateEmployeeStations({stationsToDelete: stationsToDelete, stationsToInsert: stationsToInsert})
        .then(r => {
            let variant;
            let mode;
            let result = JSON.parse(JSON.stringify(r));
            if(result.succeeded){
                refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                variant = 'success';
                mode = 'pester';
                this.handleResetManageStationsValues();
                this.openStationsModal = false;
            } else {
                variant = 'error';
                mode = 'sticky';
            }
            this.loadingSpinner = false;

            const event = new ShowToastEvent({
                title: 'Manage Employee Stations Result',
                message: result.result_message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);
        });
    }

    /*******************************************************************************
    *                                                                              *
    *  Auxiliary Methods                                                           *
    *                                                                              *
    * ******************************************************************************/

    handleCancel(){
        this.openModal = false;
        this.openStationsModal = false;
        this.handleResetActionValues();
    }

    handleResetActionValues(){
        this.modalTitle = '';
        this.loadingModal = false;
        this.recordToManage = '';
        this.recordToManageStationsList = [];
        this.stationsProneToAdd = [];
        this.recordToManageNewStationsList = [];
        this.isActionView = false;
        this.isActionEdit = false;
        this.isActionNew = false;
        this.isActionDelete = false;
        this.enableCodeEditing = false;
        this.hasNostations = true;
        this.employeeToInsert = {};
    }

    handleResetManageStationsValues(){
        this.modalTitle = '';
        this.loadingModal = false;
        this.showStationsList = false;
        this.hasNostations = true;
        this.manageStationValue = '';
        this.recordToManage = '';
        this.recordToManageStationsList = [];
        this.recordToManageNewStationsList = [];
        this.stationsProneToAdd = [];
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle data export                                               *
    *                                                                              *
    * ******************************************************************************/

    handleExportToCsv(){
        let columns = JSON.parse(JSON.stringify(this.columnsSearchEmployees));
        let data = JSON.parse(JSON.stringify(this.ITPEmployeesWithStationsInfo));
        this.template.querySelector('c-portal-iftp-export-data').exportDataToCsv(columns, data, "EmployeesSearchResults.csv");
    }

    handleExportToExcel(){
        let columns = JSON.parse(JSON.stringify(this.columnsSearchEmployees));
        let data = JSON.parse(JSON.stringify(this.ITPEmployeesWithStationsInfo));
        this.template.querySelector('c-portal-iftp-export-data').exportDataToExcel(columns, data, "EmployeesSearchResults.xls");
    }

    /*******************************************************************************
    *                                                                              *
    *  Sorting Methods                                                             *
    *                                                                              *
    * ******************************************************************************/
    updaterecordToManageStationsListSorting(event){
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        this.sortedrecordToManageStationsListBy = fieldName;
        this.sortedrecordToManageStationsListDirection = sortDirection;

        let auxdata = JSON.parse(JSON.stringify(this.recordToManageStationsList));
        this.recordToManageStationsList = this.sortData(fieldName, sortDirection, auxdata);
    }

    // Sort Columns In SearchResults Datatable
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        let auxdata = JSON.parse(JSON.stringify(this.ITPEmployeesWithStationsInfo));
        this.ITPEmployeesWithStationsInfo = this.sortData(fieldName, sortDirection, auxdata);
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
import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

import addNewEmployee from '@salesforce/apex/PortalIftEmployeeRecordsManagement.addNewEmployee';
import resetEmployeePassword from '@salesforce/apex/PortalIftEmployeeRecordsManagement.resetEmployeePassword';
import getAllITPEmployees from '@salesforce/apex/PortalIftEmployeeRecordsManagement.getAllITPEmployees';
import getITPEmployeesWithStationsInfo from '@salesforce/apex/PortalIftEmployeeRecordsManagement.getITPEmployeesWithStationsInfo';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import inactivateEmployee from '@salesforce/apex/PortalIftEmployeeRecordsManagement.inactivateEmployee';
import updateEmployee from '@salesforce/apex/PortalIftEmployeeRecordsManagement.updateEmployee';
import updateEmployeeStations from '@salesforce/apex/PortalIftEmployeeRecordsManagement.updateEmployeeStations';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';

export default class PortalIftpManageEmployees extends LightningElement {

    @track error;
    @track mainErrorMessage;

    @track userInfo;
    @track stationOptions;
    ITPStations;
    @track ITPEmployeesWithStationsInfo = [];
            AllITPEmployees = [];

    @track stationValue;
    @track manageStationValue;
    @track firstNameValue;
    @track lastNameValue;
    @track employeeCodeValue;
    @track loading = false;
    @track loadingSearchCriteria = false;
    @track showSearchCriteria = false;

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
    @track recordToManageStationsList = [];
    @track recordToManageNewStationsList = [];
    @track managedStationOptions = [];
    @track hasNoStations = true;
    @track isActionView = false;
    @track isActionEdit = false;
    @track isActionDelete = false;
    @track isActionNew = false;
    @track isEmployeeCodeDisabled = true;
    @track enableCodeEditing = false;
    @track columnsShowEmployeeStations;
    @track employeeRoleOptions = [({label: 'ITP Trainee', value: 'ITP Trainee'})];
    @track employeeToInsert = {};
        
    @track openConfirmationModal = false;
    @track openStationsModal = false;
    @track stationsProneToAdd = [];
    @track showStationsList = false;
    @track auxSearchValues = {};
    @track openReactivateConfirmationModal = false;
        recordToReactivate = {};
    @track openResetPasswordModal = false;
    @track password = '';
    @track passwordConfirmation = '';
    
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('employeesChanged', this.handleEmployeesChanged, this);
        registerListener('stationsChanged', this.handleStationsChanged, this);
        this.showSearchCriteria = false;
        this.loadingSearchCriteria = true;

        this.initData();       

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
            {label: 'Primary Station', fieldName: 'Primary_Station_Code', type: 'text', sortable: true},
            {label: 'LMS Username', fieldName: 'Username', type: 'text', sortable: true},
            {label: '',
            type: 'button-icon',
            initialWidth: 30,
            typeAttributes: {
                iconName: 'action:password_unlock',
                title: '',
                name: 'resetPassword',
                variant: 'border-filled',
                alternativeText: 'Reset Password'
            }
        },
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
            {label: 'Name', fieldName: 'Description__c', type: 'text', sortable: true},
            {label: 'Primary', fieldName: 'Primary__c', type: 'boolean', initialWidth: 80},
            {label: '',
                type: 'button',
                initialWidth: 140,
                typeAttributes: {
                    title: 'Set As Primary',
                    name: 'set_as_primary',
                    variant: 'border-filled',
                    alternativeText: 'Set As Primary', 
                    label: 'Set as Primary',
                    class: {fieldName: 'showButton'}
                }
            },
        ];
    }

    initData(){

        getUserInfo()
        .then(result =>{
            let myResult = JSON.parse(JSON.stringify(result));
            if(myResult){
                this.userInfo = myResult;
                if(myResult.primaryStationCode){
                    if(myResult.primaryStationCode){
                        if(!this.stationValue && !this.showSearch){
                            this.stationValue = myResult.primaryStationCode;
                            this.auxSearchValues.stationCode = myResult.primaryStationCode.trim();
                        } else {
                            if(this.stationValue && !this.showSearch){
                                this.stationValue = myResult.primaryStationCode;
                                this.auxSearchValues.stationCode = myResult.primaryStationCode.trim();
                            }
                        }
                    } else {
                        if(this.stationValue && !this.showSearch){
                            this.stationValue = null;
                            this.auxSearchValues.stationCode = null;
                        }
                    }
                } 
            }

        })
        .catch(error => {
            console.log('getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        }); 

        getITPStations()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            
            let myTopicOptions = [];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
            });
            this.ITPStations = myResult;
            myTopicOptions = this.sortData('value', 'asc', myTopicOptions);
            myTopicOptions.push({label: 'Not allocated', value: 'Not Allocated'});
            this.stationOptions = myTopicOptions;

            this.showSearchCriteria = true;
            this.loadingSearchCriteria = false;

            if(this.stationValue){
                //Reset this.stationValue if this.stationValue = code of deleted station
                let stationOptions = JSON.parse(JSON.stringify(this.stationOptions));
                let exists = false;
                stationOptions.forEach(opt =>{
                    if(opt.value === this.stationValue){
                        exists = true;
                    }
                })
                if(!exists){
                    this.stationValue = null;
                    this.auxSearchValues.stationCode = null;
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
            console.log('getITPStations - Error : ', error);
        }); 
    }

    disconnectedCallback() {
		// unsubscribe from bearListUpdate event
		unregisterAllListeners(this);
	}

    handleEmployeesChanged(){
        this.handleSearchButtonClick();
    }

    handleStationsChanged(){
        this.showSearchCriteria = false;
        this.loading = true;
        this.initData();
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
        let isNotAllocated = false;
        this.loading = true;
        this.showSearch = true;
        if(this.auxSearchValues.stationCode === 'Not Allocated'){
            isNotAllocated = true;
            this.auxSearchValues.stationCode = null;
        }
        getITPEmployeesWithStationsInfo({searchValues: this.auxSearchValues, origin: 'Manage Employees'})
        .then(result =>{
            if(result){
                let myResults = JSON.parse(JSON.stringify(result));
                console.log('myResults ', myResults);

                let finalresults = [];

                myResults.forEach(rec =>{
                    rec.Primary_Station_Code = '';
                    rec.upperCase = 'to-upper-case';
                    if(rec.Contact_Role__c === 'ITP Training Coordinator'){
                        rec.Username = rec.Email__c;
                    } else {
                        rec.Username = rec.Name.substring(4, rec.Name.length);
                        rec.Username = parseInt(rec.Username);
                        rec.Username = rec.Username.toString();
                    }

                    if(rec.Role_Addresses__r){
                        rec.Role_Addresses__r.forEach(recRolAdd =>{
                            if(recRolAdd.Primary__c){
                                rec.Primary_Station_Code = recRolAdd.Address__r.Code__c;
                            } 
                        })
                    }

                    if((isNotAllocated && !rec.Primary_Station_Code) || !isNotAllocated){
                        finalresults.push(rec);
                    }
                })
                this.ITPEmployeesWithStationsInfo = JSON.parse(JSON.stringify(finalresults));
                if(this.ITPEmployeesWithStationsInfo.length > 0){
                    this.ITPEmployeesWithStationsInfo = this.sortData('Last_Name__c', 'asc', JSON.parse(JSON.stringify(this.ITPEmployeesWithStationsInfo)));
                    this.hasSearchResults = true;
                } else {
                    this.hasSearchResults = false;
                }
            }
            this.loading = false;
        })
        
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
        this.isEmployeeCodeDisabled = true;
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
                                if(this.ITPEmployeesWithStationsInfo[i].Company_Code__c){
                                    if(this.ITPEmployeesWithStationsInfo[i].Company_Code__c.toLowerCase() === this.employeeToInsert.code.toLowerCase()){
                                        exists = true;
                                        i = this.ITPEmployeesWithStationsInfo.length;
                                    }
                                }
                            }
                            inputCmp.setCustomValidity(exists ? 'Employee with this Employee Code already exists.': '');
                        }
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        this.loadingSpinner = false;
        let allITPEmployees = [];

        getAllITPEmployees()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            allITPEmployees = myResult;
            console.log('aITPEmployees', allITPEmployees);


            let existsInactive = false;
            allITPEmployees.forEach(emp => {
                if(emp.Company_Code__c === this.employeeToInsert.code.trim() && emp.Status__c ==='Inactive'){
                    console.log('there is an inactive employee with this code', existsInactive);
                    existsInactive = true;
                    this.employeeToInsert.id = emp.Id;
                    this.employeeToInsert.contactId = emp.Contact__c;
                    this.recordToReactivate = emp;
                }
            })
            if(allValid && existsInactive){
                console.log('there is an inactive employee with this code', existsInactive);
                this.openReactivateConfirmationModal = true;
                console.log('this.recordToReactivate', this.recordToReactivate);
                
            } else if (allValid && !existsInactive) {
                this.loadingSpinner = true;
                addNewEmployee({employeeToInsert: this.employeeToInsert})
                .then(r => {
                    let addNewEmployeeResult = JSON.parse(JSON.stringify(r));
                    let variant;
                    let mode;
                    if(addNewEmployeeResult.succeeded){
                        this.openModal = false;
                        this.handleResetActionValues();
                        //refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                        this.handleSearchButtonClick();
                        variant = 'success';
                        mode = 'pester';
                    } else {
                        if(addNewEmployeeResult.result_message === 'Failled: This Employee Code already exists in the database; '){
                            variant = 'warning';
                            mode = 'pester';
                            this.openModal = false;
                            this.handleResetActionValues();
                            this.handleSearchButtonClick();
                        } else {
                            variant = 'error';
                            mode = 'sticky';
                        }
                    }
                    this.loadingSpinner = false;
                    const event = new ShowToastEvent({
                        title: 'Add Employee Result',
                        message: addNewEmployeeResult.result_message,
                        variant: variant,
                        mode: mode
                    });
                    this.dispatchEvent(event);
                });
            }



        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: 'ITP Stations',
                message: 'Unable to get ITP\'s employees data from database.',
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(event);
            console.log('getITPStations - Error : ', error);
        });
    }

    closeReactivateConfirmationModal(){
        this.openReactivateConfirmationModal = false;
    }

    reactivateConfirmation(){
        this.loadingSpinner = true;
        let recordToReactivate = JSON.parse(JSON.stringify(this.recordToReactivate));
        let employeeToInsert = JSON.parse(JSON.stringify(this.employeeToInsert));
        recordToReactivate.Business_Phone__c = employeeToInsert.phone;
        recordToReactivate.Company_Code__c = employeeToInsert.code;
        recordToReactivate.Details__c = employeeToInsert.details;
        recordToReactivate.First_Name__c = employeeToInsert.first_name;
        recordToReactivate.Last_Name__c = employeeToInsert.last_name;
        recordToReactivate.Status__c = 'Active';
        recordToReactivate.Title__c = employeeToInsert.title;
        this.openReactivateConfirmationModal = false;

        
        updateEmployee({recordToUpdate: recordToReactivate, updateType: 'reactivate_and_update'})
            .then(r => {
                let result = JSON.parse(JSON.stringify(r));
                let variant;
                let mode;
                let message; 
                if(result.succeeded){
                    this.openModal = false;
                    //refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                    this.handleSearchButtonClick();
                    variant = 'success';
                    mode = 'pester';
                    message = 'Employee reactivated with success';
                } else {
                    variant = 'error';
                    mode = 'sticky';
                    message = 'Unable to reactive/add employee.';
                }
                this.loadingSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Add/Reactivate Employee Result',
                    message: message,
                    variant: variant,
                    mode: mode
                });
                this.dispatchEvent(event);
            });
            
    }



    /********************************************************************************************
    *                                                                                           *
    *  Methods to handle View/Edit/Delete/AddStations/ResetPassord actions on Employee          *
    *                                                                                           *
    * *******************************************************************************************/

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
                if(station.Primary__c){
                    station.showButton = 'slds-hide';
                } else {
                    station.showButton = 'slds-show';
                }
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
                if(!this.recordToManage.Company_Code__c && this.recordToManage.Contact_Role__c !== 'ITP Trainee'){
                    this.isEmployeeCodeDisabled = false;
                }
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
            case 'resetPassword':
                console.log('resetPassword');
                console.log('this.recordToManage', this.recordToManage);
                this.openResetPasswordModal = true;
                this.modalTitle = 'Reset Password';
            default:
        }
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle Update Action                                             *
    *                                                                              *
    * ******************************************************************************/

    handleChangeEditEmployeeCompanyCode(event){
        this.recordToManage.Company_Code__c = event.detail.value.trim();
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
            if(inputCmp.name === 'employee_code' && !this.isEmployeeCodeDisabled){
                if(this.recordToManage.Company_Code__c){
                    for(let i = 0; i < this.ITPEmployeesWithStationsInfo.length; i++){
                        if(this.ITPEmployeesWithStationsInfo[i].Company_Code__c && this.ITPEmployeesWithStationsInfo[i].Company_Code__c.toLowerCase() === this.recordToManage.Company_Code__c.toLowerCase()){
                            exists = true;
                            i = this.ITPEmployeesWithStationsInfo.length;
                        }
                    }
                    inputCmp.setCustomValidity(exists ? 'Employee with this Employee Code already exists.': '');
                } else {
                    inputCmp.setCustomValidity('Complete this field.');
                }
            }

            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);    
        this.loadingSpinner = false;
        if (allValid) {
            this.loadingSpinner = true;

            if(!this.recordToManage.Business_Phone__c){
                this.recordToManage.Business_Phone__c = '00';
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
                    //refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                    this.handleSearchButtonClick();
                    variant = 'success';
                    mode = 'pester';
                } else {
                    if(result.result_message === 'The Employee you are trying to update doesn\'t work for thir ITP anymore, has been deleted.'){
                        variant = 'warning';
                        mode = 'pester';
                        this.openModal = false;
                        this.handleResetActionValues();
                        this.handleSearchButtonClick();
                    }
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
                //refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                this.handleSearchButtonClick();
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
        if(this.manageStationValue){
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
            this.manageStationValue = '';
            this.loadingModal = false;
        } else {
            const event = new ShowToastEvent({
                title: '\'Add Station\' Button Click',
                message: 'Select a Station from the dropdown list before pressing \'Add Station\'.',
                variant: 'warning',
                mode: 'pester'
            });
            this.dispatchEvent(event);
            
        }
        
    }

    handleManageEmployeeStationsRowAction(event){
        this.loadingSpinner = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        let code = row.Code__c;
        let recordToManageNewStationsList = JSON.parse(JSON.stringify(this.recordToManageNewStationsList));
        let stationsProneToAdd = JSON.parse(JSON.stringify(this.stationsProneToAdd));
        let isPrimary = false;

        switch (actionName) {
            case 'delete':
                for(let i = 0; i < recordToManageNewStationsList.length; i++){
                    if(recordToManageNewStationsList[i].Code__c === code){
                        if(recordToManageNewStationsList[i].Primary__c){
                            isPrimary = true;
                        }
                        recordToManageNewStationsList.splice(i, 1);
                        i = recordToManageNewStationsList.length;
                    }
                }
                stationsProneToAdd.push({ label: row.Code__c + ' - ' + row.Description__c, value: row.Code__c });
                this.stationsProneToAdd = stationsProneToAdd;
                this.recordToManageNewStationsList = recordToManageNewStationsList;
                if(recordToManageNewStationsList.length > 0){
                    if(isPrimary){
                        const event2 = new ShowToastEvent({
                            title: 'Manage Employee Stations Remove Station',
                            message: 'You have removed the primary station. Choose another as primary.',
                            variant: 'warning',
                            mode: 'pester'
                        });
                        this.dispatchEvent(event2);
                    }
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
            case 'set_as_primary':
                
                if(recordToManageNewStationsList.length > 0){
                    console.log('recordToManageNewStationsList', recordToManageNewStationsList);

                    recordToManageNewStationsList.forEach(station =>{
                        if(station.Code__c === code){
                            station.Primary__c = true;
                            station.showButton = 'slds-hide';

                        } else {
                            station.Primary__c = false;
                            station.showButton = 'slds-show';
                        }
                    })
                    console.log('recordToManageNewStationsList', recordToManageNewStationsList);
                    this.recordToManageNewStationsList = recordToManageNewStationsList;
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
        let originalStationsList = [];
        let newStationsList = [];
        let existsPrimary = false;
        if(recordToManageNewStationsList.length > 0){
            recordToManageNewStationsList.forEach(station =>{
                if(station.Primary__c){
                    existsPrimary = true;
                }
            })
        }
        
        if(!existsPrimary && recordToManageNewStationsList.length > 0){
            const event2 = new ShowToastEvent({
                title: 'Manage Employee Stations',
                message: 'You need to select a station as primary before saving.',
                variant: 'warning',
                mode: 'pester'
            });
            this.dispatchEvent(event2);
        } else {
            if(recordToManage.Role_Addresses__r.length > 0){
                recordToManage.Role_Addresses__r.forEach((rolAddr => {
                    let r = {};
                    r.Id = rolAddr.Id;
                    r.Account_Contact_Role__c = recordToManage.Id;
                    r.Address__c = rolAddr.Address__c;
                    if(rolAddr.Primary__c){
                        r.Primary__c = rolAddr.Primary__c;
                    } else {
                        r.Primary__c = false;
                    }
                    originalStationsList.push(r);
                }))

            }
            
            if(recordToManageNewStationsList.length > 0){
                recordToManageNewStationsList.forEach(station =>{
                    console.log('station', station);
                    let r = {};
                    r.Account_Contact_Role__c = recordToManage.Id;
                    r.Address__c = station.Id;
                    if(station.Primary__c){
                        r.Primary__c = station.Primary__c;
                    } else {
                        r.Primary__c = false;
                    }
                    
                    newStationsList.push(r);
                })
            }

            updateEmployeeStations({originalStationsList: originalStationsList, newStationsList: newStationsList})
            .then(r => {
                let result = JSON.parse(JSON.stringify(r));
                let variant;
                let mode;
                
                if(result.succeeded){
                    //refreshApex(this.wiredITPEmployeesWithStationsInfoResult);
                    this.handleSearchButtonClick();
                    variant = 'success';
                    mode = 'pester';
                    this.handleResetManageStationsValues();
                    this.openStationsModal = false;
                    fireEvent(this.pageRef, 'stationsChanged', null);
                } else {
                    if(result.result_message === 'Employee doesn\'t work for your ITP anymore.'){
                        variant = 'warning';
                        mode = 'pester';
                        this.handleSearchButtonClick();
                        this.handleResetManageStationsValues();
                        this.openStationsModal = false;
                    }
                    variant = 'error';
                    mode = 'sticky';
                }

                const event = new ShowToastEvent({
                    title: 'Manage Employee Stations Result',
                    message: result.result_message,
                    variant: variant,
                    mode: mode
                });
                this.dispatchEvent(event);
                
            });
        }
        this.loadingSpinner = false;
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle Password Reset                                             *
    *                                                                              *
    * ******************************************************************************/

    handleChangeInPassword(event){
        this.password = event.detail.value;
    }

    handleChangeInConfirmePassword(event){
        this.passwordConfirmation = event.detail.value;
    }
    
    handleResetPassword(){
        console.log('in handleResetPassword');
        this.loadingModal = true;
        //check if password == confirmPassword
        //check if password has at least 6 caracters
        let password = JSON.parse(JSON.stringify(this.password));
        let passwordConfirmation = JSON.parse(JSON.stringify(this.passwordConfirmation));
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    if(inputCmp.name === 'password'){
                        if(password){
                            if(password.length < 6){
                                inputCmp.setCustomValidity('Password must have at least 6 caracters.');
                            } else {
                                inputCmp.setCustomValidity('');
                            }
                        } else {
                            inputCmp.setCustomValidity('Complete this field.');
                        }
                    }

                    if(inputCmp.name === 'passwordConfirmation'){
                        if(passwordConfirmation){
                            if(passwordConfirmation.trim() === password.trim()){
                                inputCmp.setCustomValidity('');
                            } else {
                                inputCmp.setCustomValidity('Confirm Password must be the same as Password.');
                            }
                        } else {
                            inputCmp.setCustomValidity('Complete this field.');
                        }
                    }

                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);

        this.loadingModal = false;

        if(allValid){
            //callout to absorb api
            resetEmployeePassword({globalId: this.recordToManage.Global_ID__c, newPassword: password})
            .then(results => {
                if(results !== undefined){
                    if(results === true){
                        this.showSuccessToast();
                    }
                    else{
                       this.showErrorToast();
                    }
                }
                
            });
            /*const event = new ShowToastEvent({
                title: 'Reset Password Result',
                message: 'Password was successfully changed.',
                variant: 'success',
                mode: 'pester'
            });
            this.dispatchEvent(event);*/

            this.loadingModal = false;
            this.handleResetPasswordCancel();
        }
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            variant: 'success',
            message: 'Password changed successfully.',
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message: 'An Error has occurred while trying to reset password. Please contact your administtrator.',
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }

    handleResetPasswordCancel(){
        this.openResetPasswordModal = false;
        this.modalTitle = '';
        this.password = '';
        this.passwordConfirmation = '';
        this.loadingModal = false;
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

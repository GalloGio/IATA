import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners} from 'c/pubsub';

import getCertificationTypes from '@salesforce/apex/PortalIftpUtils.getCertificationTypes';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecordsForMonitorTrainings';
import updateCertificationEnroll from '@salesforce/apex/portalIftpTrainingRecords.updateCertificationEnroll';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';


export default class PortalIftpMonitorTrainings extends LightningElement {
    @track stationValue;
    @track stationOptions;
    @track expirationStatusValue = 'All';
    @track employeeCodeValue;
    @track aircraftTypeValue = 'All';
    @track aircraftTypeOptions;
    @track fromDateValue;
    @track fromDateMinValue = new Date(2019, 0, 1);
    @track fromDateMaxValue;
    @track toDateValue;
    @track toDateMinValue;
    @track toDateMaxValue;
    @track data;
    fullData = null;
    originalData = null;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track hasDataRecords = false;
    @track showSearch = false;
    @track loading = true;
    @track showSearchCriteria = false;
    @track selectedRows;
    @track selectedRowsKeys;
    @track showDatatableButtons = false;
    @track isNotEditable = true;

    get expirationStatusOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Not Expired', value: 'Not Expired' },
            { label: 'Expired', value: 'Expired' },
            { label: 'Expired in 30 days', value: 'Expired in 30 days' },
            { label: 'Expired in 60 days', value: 'Expired in 60 days' },
            { label: 'Expired in 90 days', value: 'Expired in 90 days' },
            { label: 'Manual', value: 'Manual' }
        ];
    }

    columns = [
        {label: '',
        type: 'button-icon',
        initialWidth: 30,
        typeAttributes: {
            iconName: 'utility:filterList',
            title: 'Filter By Employee Code',
            name: 'filter',
            variant: 'border-filled',
            alternativeText: 'Filter'
        }
    },
        {label: 'Last Name', fieldName: 'lastName', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
        {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
        {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
        {label: 'Course', fieldName: 'trainingName', type: 'text', sortable: true},
        {label: 'Expiration Date', fieldName: 'expirationDate', type: 'date', sortable: true, 
            typeAttributes: {year: "numeric", month: "short", day: "2-digit"}, 
            cellAttributes: { class: { fieldName: 'expirationStatus' }, iconName: { fieldName: 'expirationIcon' }, iconPosition: 'right' } },
        {label: 'Days', fieldName: 'days', type: 'number', initialWidth: 70, sortable: true,  
            cellAttributes: { class: { fieldName: 'expirationStatus' }} },
        {label: 'Primary Station', fieldName: 'primaryStation', type: 'text', sortable: true},
        {label: 'Enrolled', fieldName: 'enrolled', type: 'text', sortable: true,
            cellAttributes: { class: { fieldName: 'enrollmentStatus' }, iconName: { fieldName: 'enrollmentIcon' }, iconPosition: 'right' } },
        {label: 'Set Enroll', fieldName: 'setEnroll', type: 'text'},
        {label: '',
            type: 'action', 
            cellAttributes: { class: {fieldName: 'showPicklist' }},
            typeAttributes: { rowActions: this.getAllActions}
        }
    ];

    @wire(getCertificationTypes, {certificationType: ''})
    handleGetCertificationTypes({error, data}){
        if(data){
            let myResult = JSON.parse(JSON.stringify(data));
            myResult = this.sortData('Name', 'asc', myResult);
            let myTopicOptions = [{ label: 'All', value: 'All' }];

            Object.keys(myResult).forEach(function (el) {
                myTopicOptions.push({ label: myResult[el].Name, value: myResult[el].Id });
            });

            this.aircraftTypeOptions = myTopicOptions;
        }

        if(error){
            console.error('error : ' + error);
        }
    }

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('stationsChanged', this.handleStationsChanged, this);
        let toDateValue = new Date();
        this.toDateValue = toDateValue.getFullYear()+'-'+(toDateValue.getMonth()+1)+'-'+toDateValue.getDate();

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
            }
            getITPStations({accountId: myResult.accountId})
            .then(result_2 => {
                let myResult_2 = JSON.parse(JSON.stringify(result_2));
                let myTopicOptions = [];
                Object.keys(myResult_2).forEach(function (el) {
                    myTopicOptions.push({ label: myResult_2[el].Code__c + ' - ' + myResult_2[el].Description__c, value: myResult_2[el].Code__c });
                });
                myTopicOptions = this.sortData('label', 'asc', JSON.parse(JSON.stringify(myTopicOptions)));

                let options = [];
                if(this.userInfo.hasAssociatedStations){
                    options.push({ label: 'All my associated stations', value: 'All my associated stations'});
                }
                options = options.concat(myTopicOptions);
                this.stationOptions = JSON.parse(JSON.stringify(options));
                
                this.showSearchCriteria = true;
                this.loading = false;
            })
            .catch(error => {
                console.error('getITPStations - Error : ' + error);
                this.loading = false;
            }); 
        })
        .catch(error => {
            console.error('getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        });  
    }

    handleChangeStation(event) {
        this.stationValue = event.detail.value;
    }
    handleChangeExpirationStatus(event) {
        this.expirationStatusValue = event.detail.value;
        let today = new Date();
        let toDateValue = today;
        
        if(this.expirationStatusValue === 'Expired in 30 days'){
            toDateValue.setDate(today.getDate() + 30);
        } 
        else 
        {
            if(this.expirationStatusValue === 'Expired in 60 days'){
                toDateValue.setDate(today.getDate() + 60);
        }  else {
                if(this.expirationStatusValue === 'Expired in 90 days'){
                    toDateValue.setDate(today.getDate() + 90);
                }
            }
        }
        this.toDateValue = toDateValue.getFullYear()+'-'+(toDateValue.getMonth()+1)+'-'+toDateValue.getDate();
        if(this.expirationStatusValue === 'Manual'){
            this.isNotEditable = false;
        } else {
            this.isNotEditable = true;
        }
    }
    handleChangeAircraftType(event) {
        this.aircraftTypeValue = event.detail.value;
    }

    handleChangeEmployeeCodeValue(event){
        this.employeeCodeValue = event.detail.value;
    }
   
    handleChangeToDate(event) {
        this.toDateValue = event.detail.value;
    }

    handleSearchButtonClick(){
        this.selectedRows = null;

        this.error = [];
        this.mainErrorMessage = '';
        let isToDateValueOk = true;
        if(this.expirationStatusValue === 'Manual'){
            let today = new Date();
            today = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
            if(!this.toDateValue || this.toDateValue <= today){
                isToDateValueOk = false;
                const event = new ShowToastEvent({
                    title: 'Monitor Trainings Result',
                    message: 'For Course Status \'Manual\' the Expiration Date must be greater then today. ',
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            }
        }
        if(isToDateValueOk){
            if(this.error.length === 0){
                this.showSearch = true;
                this.cleanErrors();
                this.handleSearch();
            }else{
                this.mainErrorMessage = 'Need to fill the required fields';
            }
        }
    }

    handleSearch(){
        this.loading = true;
        let auxSearchValues = {};
        let i;
        let auxStation = (this.stationValue == null) ? 'null' : this.stationValue;
        let auxItp = (this.itpValue == null) ? 'null' : this.itpValue;
        let auxExpirationStatus = (this.expirationStatusValue == null) ? 'null' : this.expirationStatusValue;
        let auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        let auxFromDate = (this.fromDateValue == null) ? 'null' : this.fromDateValue;
        let auxToDate = (this.toDateValue == null) ? 'null' : this.toDateValue;
        let auxEmployeeCode = (!this.employeeCodeValue) ? 'null' : this.employeeCodeValue.trim();

        if(this.expirationStatusValue === 'All' || this.expirationStatusValue === 'Not Expired' ){
            auxToDate = 'null';
        }
        if(this.expirationStatusValue === 'Not Expired'){
            auxExpirationStatus = 'Active';
        } else{
            auxExpirationStatus = 'Active, Expired';
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

        //List
        auxSearchValues = [
            auxStation,
            auxItp,
            auxExpirationStatus,
            auxAircraftType,
            'null',                 //auxProficiency,
            auxFromDate,
            auxToDate,
            'null',                 //place holder for firstName
            'null',                 //place holder for lastName
            auxEmployeeCode
        ];

        getTrainingRecords({searchValues: auxSearchValues, searchType: 'MonitorTrainings' })
        .then(results => {

            if(results && results.length > 0) {
                results.forEach(rec =>{
                    rec.upperCase = 'to-upper-case';
                    if(rec.enrolled !== 'Yes'){
                        rec.enrolled = null;
                    } else{
                        //rec.showPicklist = 'slds-hide-action';
                    }
                })
                this.data = this.sortData('days', 'asc', JSON.parse(JSON.stringify(results)));
                this.originalData = this.data;
                this.fullData = this.data;
                this.dataRecords = true;
            } else {
                this.dataRecords = false; 
            }
            this.loading = false;
        })
        .catch(error => {
            console.error('handleSearch - Error : ', error);

            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
            this.dataRecords = false;
        });        
    }


    handleResetButtonClick(){
        this.data = null;
        this.fullData = null;
        this.originalData = null;
        this.stationValue = undefined;
        this.expirationStatusValue = 'All';
        this.aircraftTypeValue = 'All';
        this.employeeCodeValue = undefined;
        this.fromDateValue = undefined;
        this.fromDateMaxValue = undefined;
        let today = new Date();
        this.toDateValue = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        this.toDateMinValue = undefined;
        this.showSearch = false;
        this.selectedRows = null;
        this.showDatatableButtons = false;
        this.cleanErrors();
        
    }

    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Enrolment                                            *
    *                                                                              *
    * ******************************************************************************/

    getSelectedRows(event){
        this.selectedRows = event.detail.selectedRows;
        this.selectedRowsKeys = [];
        for(let i=0; i < this.selectedRows.length; i++){
            this.selectedRowsKeys.push(this.selectedRows[i].uniqueRowId);
        }
    }

    handleSelectAllEnroll(){
        let i, index;
        let auxData = JSON.parse(JSON.stringify(this.data));

        if(this.selectedRows.length > 0){
            this.showDatatableButtons = true;
        }
       
        for(i=0; i < this.selectedRows.length; i++){
            index = this.findRowIndexById(this.selectedRows[i].uniqueRowId);
            auxData[index].setEnroll = 'Enroll';
        }
        this.data = auxData;
        if(this.data.length === this.fullData.length){
            this.fullData = this.data;
        } else{
            let auxFullData = JSON.parse(JSON.stringify(this.fullData));
            auxData.forEach(dataRecord =>{
                auxFullData.forEach(fullDataRecord =>{
                    if(dataRecord.certificationId === fullDataRecord.certificationId){
                        fullDataRecord.setEnroll = dataRecord.setEnroll;
                    }
                })
            })
            this.fullData = auxFullData;
        }
        this.selectedRows = null;
        this.selectedRowsKeys = [];
        
    }

    handleSelectAllUnenroll(){
        let i, index;
        let auxData = JSON.parse(JSON.stringify(this.data));

        if(this.selectedRows.length > 0){
            this.showDatatableButtons = true;
        }
       
        for(i=0; i < this.selectedRows.length; i++){
            index = this.findRowIndexById(this.selectedRows[i].uniqueRowId);
            auxData[index].setEnroll = 'Unenroll';
        }
        this.data = auxData;
        if(this.data.length === this.fullData.length){
            this.fullData = this.data;
        } else{
            let auxFullData = JSON.parse(JSON.stringify(this.fullData));
            auxData.forEach(dataRecord =>{
                auxFullData.forEach(fullDataRecord =>{
                    if(dataRecord.certificationId === fullDataRecord.certificationId){
                        fullDataRecord.setEnroll = dataRecord.setEnroll;
                    }
                })
            })
            this.fullData = auxFullData;
        }
        this.selectedRows = null;
        this.selectedRowsKeys = [];
        
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

    handleEnrolmentSave(){
        if(this.data.length === this.fullData.length){
            let dataToSave = [];
            let auxData = JSON.parse(JSON.stringify(this.data));
            
            auxData.forEach(rec => {
                if(rec.setEnroll && rec.setEnroll === 'Enroll' && rec.enrolled !== 'Yes'){
                    let recordTosave ={};
                    recordTosave.contact_role_certification_id = rec.certificationId;
                    recordTosave.action = 'Enroll';
                    dataToSave.push(recordTosave);
                }
                if(rec.setEnroll && rec.setEnroll === 'Unenroll' && rec.enrolled === 'Yes'){
                    let recordTosave ={};
                    recordTosave.contact_role_certification_id = rec.certificationId;
                    recordTosave.action = 'Unenroll';
                    dataToSave.push(recordTosave);
                }
                if(rec.setEnroll && rec.setEnroll === 'Stop'){
                    let recordTosave ={};
                    recordTosave.contact_role_certification_id = rec.certificationId;
                    recordTosave.action = 'Stop';
                    dataToSave.push(recordTosave);

                }
            })

            if(dataToSave.length > 0){
                this.loading = true;
                updateCertificationEnroll({dataToSave: dataToSave })
                .then(data => {
                    auxData.forEach(rec => {
                        if(rec.setEnroll === 'Enroll'){
                            rec.enrolled = 'Yes';
                            rec.enrollmentStatus = 'Success';
                            rec.enrollmentIcon = 'utility:check';
                        } else if(rec.setEnroll === 'Unenroll'){
                            rec.enrolled = '';
                            rec.enrollmentStatus = 'Success';
                            rec.enrollmentIcon = 'utility:check';
                        } else if(rec.setEnroll === 'Stop'){
                            rec.enrolled = '';
                            rec.enrollmentStatus = 'Success';
                            rec.enrollmentIcon = 'utility:close';
                        }
                    }) 
                    this.data = auxData;  
                    const event = new ShowToastEvent({
                        title: 'Save Enrollments',
                        message: 'Data updated successfully ',
                        variant: 'success',
                        mode: 'pester'
                    });
                    this.dispatchEvent(event);               
                    this.loading = false;
                    
                })
                .catch(error => {
                    console.error('handleSearch - Error : ', error);
    
                    const event = new ShowToastEvent({
                        title: 'Save Enrollments',
                        message: 'Unable to save data. ',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);

                    this.loading = false;
    
                }); 




            } else {
                const event = new ShowToastEvent({
                    title: 'Save Enrollments',
                    message: 'All the selected records were already enrolled. ',
                    variant: 'warning',
                    mode: 'pester'
                });
                this.dispatchEvent(event);

                this.loading = false;  
            }
        } else {
            const event = new ShowToastEvent({
                title: 'Save Enrollments',
                message: 'Before save remove filter, to check all enrollments assigned. ',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(event);
        }
    }

    handleEnrolmentCancel(){
        this.data = this.originalData;
        this.fullData = this.originalData;
        this.selectedRows = null;
        this.showDatatableButtons = false;
    }

    getAllActions(row, doneCallback){
        let result;
        if(row.enrolled === 'Yes'){
            result = [
                { label: 'Unenroll', name: 'Unenroll'}
            ];
        } else if(row.enrolled !== 'Yes'){
            result = [
                { label: 'Enroll', name: 'Enroll'}
            ];
        }

        if(row.expirationStatus === 'Expired' && (row.isGeneralTraining === 'No' || (row.isGeneralTraining === 'Yes' && row.level === 'Level 3') )){
            result.push({ label: 'Stop', name: 'Stop'})
        }

        doneCallback(result);
    }

    /*******************************************************************************
    *                                                                              *
    *       Methods to Handle Row Action                                           *
    *                                                                              *
    * ******************************************************************************/

    handleMonitorTrainingsRowAction(event){
        this.loading = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const { uniqueRowId } = row;
        const index = this.findRowIndexById(uniqueRowId);
        let employee_code = row.companyNumber;
        let auxData = JSON.parse(JSON.stringify(this.data));

        switch (actionName) {
            case 'filter':

                if(this.fullData.length !== this.data.length){
                    this.data = JSON.parse(JSON.stringify(this.fullData));
                } else {
                    this.data = auxData.filter(record => record.companyNumber === employee_code);
                    
                }
                this.loading = false;
                break;

            case 'Enroll':
                auxData[index].setEnroll = 'Enroll';
                this.data = auxData;

                if(this.data.length === this.fullData.length){
                    this.fullData = this.data;
                } else{
                    let auxFullData = JSON.parse(JSON.stringify(this.fullData));
                    auxData.forEach(dataRecord =>{
                        auxFullData.forEach(fullDataRecord =>{
                            if(dataRecord.certificationId === fullDataRecord.certificationId){
                                fullDataRecord.setEnroll = dataRecord.setEnroll;
                            }
                        })
                    })
                    this.fullData = auxFullData;
                }
                this.showDatatableButtons = true;
                this.loading = false;
                break;

            case 'Unenroll':
                auxData[index].setEnroll = 'Unenroll';
                this.data = auxData;

                if(this.data.length === this.fullData.length){
                    this.fullData = this.data;
                } else{
                    let auxFullData = JSON.parse(JSON.stringify(this.fullData));
                    auxData.forEach(dataRecord =>{
                        auxFullData.forEach(fullDataRecord =>{
                            if(dataRecord.certificationId === fullDataRecord.certificationId){
                                fullDataRecord.setEnroll = dataRecord.setEnroll;
                            }
                        })
                    })
                    this.fullData = auxFullData;
                }
                this.showDatatableButtons = true;
                this.loading = false;
                break;

            case 'Stop':
                auxData[index].setEnroll = 'Stop';
                this.data = auxData;

                if(this.data.length === this.fullData.length){
                    this.fullData = this.data;
                } else{
                    let auxFullData = JSON.parse(JSON.stringify(this.fullData));
                    auxData.forEach(dataRecord =>{
                        auxFullData.forEach(fullDataRecord =>{
                            if(dataRecord.certificationId === fullDataRecord.certificationId){
                                fullDataRecord.setEnroll = dataRecord.setEnroll;
                            }
                        })
                    })
                    this.fullData = auxFullData;
                }
                this.showDatatableButtons = true;
                this.loading = false;
                break;
        
            default:
                this.loading = false;
                break;
        }
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
        this.loading = true;
        this.initData();
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
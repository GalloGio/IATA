import { LightningElement, track, wire } from 'lwc';
//import { refreshApex } from '@salesforce/apex';
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
    @track expirationStatusValue;
    @track employeeCodeValue;
    @track aircraftTypeValue = 'All';
    @track aircraftTypeOptions;
    //@track proficiencyValue;
    @track datePeriodValue;
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

    get expirationStatusOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Active', value: 'Active' },
            { label: 'Expired', value: 'Expired' },
        ];
    }
/*
    get proficiencyOptions() {
        return [
            { label: 'None', value: 'None' },
            { label: 'Level 2', value: 'Level 2' },
            { label: 'Level 3', value: 'Level 3' },
            { label: 'All', value: 'All' }
        ];
    }
*/
    get datePeriodOptions() {
        return [
            { label: 'None', value: '0' },
            { label: '30 Days', value: '30' },
            { label: '60 Days', value: '60' },
            { label: '90 Days', value: '90' },
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
        {label: 'Aircraft Type', fieldName: 'trainingName', type: 'text', sortable: true},
        {label: 'Expiration Date', fieldName: 'expirationDate', type: 'date', sortable: true, 
            typeAttributes: {year: "numeric", month: "long", day: "2-digit"}, 
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
        //{label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true},
        //{label: 'Station', fieldName: 'station', type: 'text', sortable: true},
        /*{label: 'PREREQ EXPIRATION', fieldName: 'indicator', type: 'text', sortable: true,
            cellAttributes: { class: { fieldName: 'indicatorStatus' }, iconName: { fieldName: 'indicatorIcon' }, iconPosition: 'right' },
            tooltip: 'test' } ,
        */
    ];
/*
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
*/
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

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        console.log('INIT connectedCallback');
        registerListener('stationsChanged', this.handleStationsChanged, this);

        this.initData();
        
        console.log('END connectedCallback');
    }

    initData(){
        getUserInfo()
        .then(result =>{
            let myResult = JSON.parse(JSON.stringify(result));
            console.log('myResult.primaryStationCode', myResult.primaryStationCode);
            if(myResult){
                this.userInfo = myResult;
                console.log('this.userInfo', this.userInfo);
                console.log('this.userInfo.primaryStationCode', this.userInfo.primaryStationCode);
                console.log('this.userInfo.hasAssociatedStations', this.userInfo.hasAssociatedStations);
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
            getITPStations()
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));

                console.log('myResult : ' + myResult);
                let myTopicOptions = [];
                    //myTopicOptions.push({ label: 'All my associated stations', value: 'All my associated stations'});
                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
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
                console.log('this.stationOptions', this.stationOptions);
/*
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
                    }
                }
            */
            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);

                this.loading = false;
            }); 
        })
        .catch(error => {
            console.log('getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        });  
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

    handleChangeEmployeeCodeValue(event){
        this.employeeCodeValue = event.detail.value;
    }
    /*
    handleChangeProficiency(event) {
        this.proficiencyValue = event.detail.value;
    }
    */
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
        this.selectedRows = null;

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
        let auxStation = (this.stationValue == null) ? 'null' : this.stationValue;
        let auxItp = (this.itpValue == null) ? 'null' : this.itpValue;
        let auxExpirationStatus = (this.expirationStatusValue == null) ? 'null' : this.expirationStatusValue;
        let auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        //let auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
        let auxFromDate = (this.fromDateValue == null) ? 'null' : this.fromDateValue;
        let auxToDate = (this.toDateValue == null) ? 'null' : this.toDateValue;
        let auxEmployeeCode = (this.employeeCodeValue == null) ? 'null' : this.employeeCodeValue.trim();

        console.log('handleSearch - INIT');
        console.log('auxItp', auxItp);
        console.log('this.stationValue: ' + this.stationValue);
        console.log('this.stationOptions: ' + this.stationOptions);
        console.log('this.stationOptions.length: ' + this.stationOptions.length);
        console.log('this.employeeCodeValue: ' + this.employeeCodeValue);
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
/*
        if(this.proficiencyValue === 'All' ||  !this.proficiencyValue){
            auxProficiency = 'null';
        }
        console.log('auxProficiency', auxProficiency);
        */
        //List
        auxSearchValues = [
            auxStation,
            auxItp,
            auxExpirationStatus,
            auxAircraftType,
            'null',    //auxProficiency,
            auxFromDate,
            auxToDate,
            'null',               //place holder for firstName
            'null',                //place holder for lastName
            auxEmployeeCode
        ];
       
        console.log('searchValues: ', auxSearchValues);
        
        
        getTrainingRecords({searchValues: auxSearchValues, searchType: 'MonitorTrainings' })
        .then(results => {
            console.log('handleSearch - results : ', results);
            console.log('handleSearch - results.length : ', results.length);
            console.log('handleSearch - results:1 : ', results[1]);


            if(results && results.length > 0) {
                results.forEach(rec =>{
                    rec.upperCase = 'to-upper-case';
                    if(rec.enrolled !== 'Yes'){
                        rec.enrolled = null;
                    } else{
                        //rec.showPicklist = 'slds-hide-action';
                    }
                })
                //this.data = JSON.parse(JSON.stringify(results));
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
        this.data = null;
        this.fullData = null;
        this.originalData = null;
        this.stationValue = undefined;
        this.expirationStatusValue = undefined;
        this.aircraftTypeValue = 'All';
        this.employeeCodeValue = undefined;
        //this.proficiencyValue = undefined;
        this.datePeriodValue = undefined;
        this.fromDateValue = undefined;
        this.fromDateMaxValue = undefined;
        this.toDateValue = undefined;
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
        
        console.log('this.selectedRows ', JSON.parse(JSON.stringify(this.selectedRows)));
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
            console.log('this.data', this.data);
            console.log('this.fullData', this.fullData);
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
            console.log('this.data', this.data);
            console.log('this.fullData', this.fullData);
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
                    recordTosave.isEnrollment = true;
                    console.log('recordTosave', recordTosave);
                    dataToSave.push(recordTosave);
                }
                if(rec.setEnroll && rec.setEnroll === 'Unenroll' && rec.enrolled === 'Yes'){
                    let recordTosave ={};
                    recordTosave.contact_role_certification_id = rec.certificationId;
                    recordTosave.isEnrollment = false;
                    console.log('recordTosave', recordTosave);
                    dataToSave.push(recordTosave);
                }
            })

            console.log('dataToSave: ',dataToSave);
            
            if(dataToSave.length > 0){
                this.loading = true;
                updateCertificationEnroll({dataToSave: dataToSave })
                .then(results => {
                    console.log('updateCertificationEnroll - results', results);
                    if(results) {
                        auxData.forEach(rec => {
                            if(rec.setEnroll === 'Enroll'){
                                rec.enrolled = 'Yes';
                                rec.enrollmentStatus = 'Success';
                                rec.enrollmentIcon = 'utility:check';
                            } else if(rec.setEnroll === 'Unenroll'){
                                rec.enrolled = '';
                                rec.enrollmentStatus = 'Success';
                                rec.enrollmentIcon = 'utility:check';
                            }
                        }) 
                        this.data = auxData;                 
                    } else {
                        const event = new ShowToastEvent({
                            title: 'Save Enrollments',
                            message: 'Unable to save data. ',
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(event);
                        //send Toast: error message to the user
                    }
                    this.loading = false;
                    
                })
                .catch(error => {
                    console.log('handleSearch - Error : ', error);
                    console.log(error);
    
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
        console.log('row', row);
        let result;
/*
        result = [
            { label: 'Yes', name: 'Yes'}
        ];

*/
        if(row.enrolled === 'Yes'){
            result = [
                { label: 'Unenroll', name: 'Unenroll'}
            ];
        } else if(row.enrolled !== 'Yes'){
            result = [
                { label: 'Enroll', name: 'Enroll'}
            ];
        }

        console.log('result', result);
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

        console.log('row.companyNumber', row.companyNumber);
        console.log('uniqueRowId', uniqueRowId);
        console.log('actionName', actionName);
        console.log('index', index);

        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'filter':
                console.log('this.fullData', this.fullData);
                console.log('this.fullData.length', this.fullData.length);
                console.log('this.data', this.data);
                console.log('this.data.length', this.data.length);

                if(this.fullData.length !== this.data.length){
                    this.data = JSON.parse(JSON.stringify(this.fullData));
                } else {
                    this.data = auxData.filter(record => record.companyNumber === employee_code);
                    
                }
                this.loading = false;
                break;
            //case 'Yes':
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
                    console.log('this.data', this.data);
                    console.log('this.fullData', this.fullData);
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
                    console.log('this.data', this.data);
                    console.log('this.fullData', this.fullData);
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
        console.log('Listener - handleStationsChanged');
        this.showSearchCriteria = false;
        this.loading = true;
        this.initData();
        console.log('Listener - handleStationsChanged, after this.initData() in ProficiencyManagement');
        console.log('Listener - handleStationsChanged, after this.initData() in ProficiencyManagement');
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
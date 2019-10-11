import { LightningElement, track } from 'lwc';

//import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';
//import searchTrainingRecords from '@salesforce/apex/portalIFTPTrainingRecords.searchTrainingRecords';
import getTrainingRecords from '@salesforce/apex/portalIftpTrainingRecords.getTrainingRecords';
import updateCertificationProficiency from '@salesforce/apex/portalIftpTrainingRecords.updateCertificationProficiency';
import getITPStations from '@salesforce/apex/PortalIftpUtils.getITPStations';
import getCertificationTypes from '@salesforce/apex/PortalIftpUtils.getCertificationTypes';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';

//import {getUserStationsJS}  from 'c/portalIftpUtilsJS';
//import {stations}  from 'c/portalIftpUtilsJS';


export default class PortalIftpProficiencyManagement extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track selectedRows;
    fieldLabels = [
        'uniqueRowId','certificationId','account_contact_role_Id','firstName', 'lastName', 'companyNumber', 'trainingName', 'itpName', 'expirationDate', 'proficiency', 'station', 'setProficiency'
    ];
    

    @track showSearch = false;
    @track stationValue;
    @track firstNameValue;
    @track lastNameValue;
    @track aircraftTypeValue;
    @track proficiencyValue = 'None';

    @track stationOptions;
    @track aircraftTypeOptions;
    
    @track showButtonNone = false;
    @track showButtonLevel2 = false;
    @track showButtonLevel3 = false;
    @track showDatatableButtons = false;

    get proficiencyOptions() {
        return [
            { label: 'None', value: 'None' },
            { label: 'Level 2', value: 'Level 2' },
            { label: 'Level 3', value: 'Level 3' },
            { label: 'All', value: 'All' },
        ];
    }

    get dataRecords() {
        return this.dataRecords;
    } 

    connectedCallback() {
        console.log('INIT connectedCallback');

        getUserInfo()
            .then(result =>{
                let myResult = JSON.parse(JSON.stringify(result));
                console.log('myResult.primaryStationCode', myResult.primaryStationCode);
                if(myResult && myResult.primaryStationCode){
                    this.stationValue = myResult.primaryStationCode;
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
                    //myTopicOptions.push({ label: myResult[el].City__c, value: myResult[el].Code__c });
                    myTopicOptions.push({ label: myResult[el].Code__c + ' - ' + myResult[el].Description__c, value: myResult[el].Code__c });
                });
                this.stationOptions = this.sortData('label', 'asc', myTopicOptions)
                this.cleanErrors();
            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  
        
        getCertificationTypes({certificationType: 'Aircraft'})
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));
                
                let myTopicOptions = [];

                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el].Name, value: myResult[el].Id });
                });

                this.aircraftTypeOptions = myTopicOptions;
                this.cleanErrors();
            })
            .catch(error => {
                console.log('getCertificationTypes - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  

        this.columns = [
            {label: 'Last Name', fieldName: 'lastName', type: 'text', cellAttributes: { class: { fieldName: 'upperCase' }}, sortable: true},
            {label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true},
            {label: 'Employee Code', fieldName: 'companyNumber', type: 'text', sortable: true},
            {label: 'Aircraft type', fieldName: 'trainingName', type: 'text', sortable: true},
            //{label: 'ITP', fieldName: 'itpName', type: 'text', sortable: true},
            {label: 'Expiration Date', fieldName: 'expirationDate', type: 'date', sortable: true, typeAttributes: {year: "numeric", month: "long", day: "2-digit"}},
            {label: 'Proficiency', fieldName: 'proficiency', type: 'text', sortable: true, 
                cellAttributes: { class: { fieldName: 'proficiencyStatus' }, iconName: { fieldName: 'proficiencyIcon' }, iconPosition: 'right' } }
            //{label: 'Station', fieldName: 'station', type: 'text', sortable: true},
        ];

        console.log('END connectedCallback');
    }

    handleChangeStation(event) {
        this.stationValue = event.detail.value;
    }
    handleChangeFirstName(event) {
        this.firstNameValue = event.detail.value;
    }
    handleChangeLastName(event) {
        this.lastNameValue = event.detail.value;
    }
    handleChangeAircraftType(event) {
        this.aircraftTypeValue = event.detail.value;
    }
    handleChangeProficiency(event) {
        this.proficiencyValue = event.detail.value;
    }
    
    handleSearchButtonClick(){
        this.selectedRows = null;
        //Form Validations
        const allValid = [...this.template.querySelectorAll('lightning-input'), ...this.template.querySelectorAll('lightning-combobox') ]
        .reduce((validSoFar, inputCmp) => {
                        if(inputCmp.name === 'station'){
                            if(!this.stationValue){
                            inputCmp.setCustomValidity('Complete this field.');
                            } else{
                                inputCmp.setCustomValidity('');
                            }
                        }
                        /*
                        if(inputCmp.name === 'aircraftType'){
                            if(!this.aircraftTypeValue){
                            inputCmp.setCustomValidity('Complete this field.');
                            } else{
                                inputCmp.setCustomValidity('');
                            }
                        }
                        if(inputCmp.name === 'proficiency'){
                            if(!this.proficiencyValue){
                            inputCmp.setCustomValidity('Complete this field.');
                            } else{
                                inputCmp.setCustomValidity('');
                            }
                        }
                        */
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allValid){

            //show/hide action buttons && set Proficiency Action Column
            if(this.proficiencyValue === 'None'){
                this.showButtonNone = false;
                this.showButtonLevel2 = true;
                this.showButtonLevel3 = true;
            }else if(this.proficiencyValue === 'Level 2'){
                this.showButtonNone = true;
                this.showButtonLevel2 = false;
                this.showButtonLevel3 = true;
            }else if(this.proficiencyValue === 'Level 3'){
                this.showButtonNone = true;
                this.showButtonLevel2 = true;
                this.showButtonLevel3 = false;
            } else if(this.proficiencyValue === 'All' || this.proficiencyValue === null){
                this.showButtonNone = true;
                this.showButtonLevel2 = true;
                this.showButtonLevel3 = true;
            }

            //remove column "Set Proficiency" and row action if it exists
            let i;
            for(i = 0; i < this.columns.length; i++){
                if(this.columns[i].fieldName === 'setProficiency'){
                        this.columns.splice(i,2); 
                    }
            }
            this.columns.push({label: 'Set Proficiency', fieldName: 'setProficiency', type: 'text'});
            this.columns.push({type: 'action', typeAttributes: { rowActions: this.getAllActions }});

            this.showSearch = true;
            this.handleSearch();
        }
    }

    getAllActions(row, doneCallback){
        let result;
        console.log('row.proficiency', row.proficiency);

        if(row.proficiency === 'None'){
            result = [
                { label: 'Level 2', name: 'level2' },
                { label: 'Level 3', name: 'level3' },
            ];
        }
        else if(row.proficiency === 'Level 2'){
            result = [
                { label: 'None', name: 'none' },
                { label: 'Level 3', name: 'level3' },
            ];
        }
        else if(row.proficiency === 'Level 3'){
            result = [
                { label: 'None', name: 'none' },
                { label: 'Level 2', name: 'level2' },
            ];
        } 
        console.log('row.proficiency', row.proficiency);
        console.log('result', result);
        doneCallback(result);
    }

    handleResetButtonClick(){
        this.showSearch = false;
        this.data = null;
        this.stationValue = null;
        this.firstNameValue = null;
        this.lastNameValue = null;
        this.aircraftTypeValue = null;
        this.proficiencyValue = null;
        this.error = '';
        this.mainErrorMessage = '';
        this.selectedRows = null;
        this.showDatatableButtons = false;
    }

    handleCancel(){
        this.handleResetButtonClick();
    }

    handleSelectAllNone(){
        this.setProficiency('allnone');
    }

    handleSelectAllLevel2(){
        this.setProficiency('alll2');
    }

    handleSelectAllLevel3(){
        this.setProficiency('alll3');
    }

    handleRowAction(event){
        let auxData = JSON.parse(JSON.stringify(this.data));
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const { uniqueRowId } = row;
        const index = this.findRowIndexById(uniqueRowId);
        
        this.showDatatableButtons = true;

        console.log('uniqueRowId: ' + uniqueRowId);
        console.log('index: ' + index);

        switch (actionName) {
            case 'none':
                auxData[index].setProficiency = 'None';
                break;
            case 'level2':
                auxData[index].setProficiency = 'Level 2';
                break;
            case 'level3':
                auxData[index].setProficiency = 'Level 3';
                break;
            default:
        }
        this.data = auxData;        
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


    handleSearch(){
        
        let auxSearchValues = new Map();
        let auxsearchType = 'Proficiency';
        let i;
        let auxStations = (this.stationValue == null) ? 'null' : this.stationValue;
        let auxAircraftType = (this.aircraftTypeValue == null) ? 'null' : this.aircraftTypeValue;
        let auxProficiency = (this.proficiencyValue == null) ? 'null' : this.proficiencyValue;
        
        if(this.stationValue === 'All'){
            
            for(i=0; i < this.stationOptions.length; i++){
                if(this.stationOptions[i].value === 'All'){
                    auxStations = '';
                }else{
                    auxStations = (auxStations == '' ) ? this.stationOptions[i].value : auxStations + ',' + this.stationOptions[i].value;
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

        if(this.proficiencyValue === 'All'){
            auxProficiency = '';
            for(i=0; i < this.proficiencyOptions.length; i++){
                
                if(this.proficiencyOptions[i].value !== 'All'){
                    auxProficiency = (auxProficiency === '' ) ? this.proficiencyOptions[i].value : auxProficiency + ',' + this.proficiencyOptions[i].value;
                } 
            }
        }
        //List
        auxSearchValues = [
            auxStations,
            'null',               //place holder for auxItp
            'Active',               //place holder for auxExperiationstatus
            auxAircraftType,
            auxProficiency,
            'null',               //place holder for auxFromDate
            'null',                //place holder for auxToDate
            this.firstNameValue,
            this.lastNameValue
        ];
        console.log('auxProficiency ', auxProficiency);
        
        this.loading = true;
        //getTrainingRecords({searchValues: JSON.parse(JSON.stringify(auxSearchValues)) })
        getTrainingRecords({searchValues: auxSearchValues, searchType: auxsearchType , origin: 'ProficiencyManagement'})
        .then(results => {
            if(results && results.length > 0) {
                this.data = results;
                results.forEach(rec =>{
                    rec.upperCase = 'to-upper-case';
                })
                this.data = this.sortData('lastName', 'asc', JSON.parse(JSON.stringify(this.data)));
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


    handleSave(){
        let dataToSave = [];
        let auxData = JSON.parse(JSON.stringify(this.data));

        console.log('handleSave INIT');
        console.log('auxData: ',auxData);


        Object.keys(auxData).forEach(function (el) {
            if(auxData[el].setProficiency != null && auxData[el].setProficiency != ''){ 
                dataToSave.push({ Id: auxData[el].certificationId, Proficiency__c: auxData[el].setProficiency });
            }
        });

        console.log('dataToSave: ',dataToSave);

        this.loading = true;
        updateCertificationProficiency({dataToSave: dataToSave })
        .then(results => {
            
            if(results) {

                this.cleanErrors();
            
                Object.keys(auxData).forEach(function (el) {
                    if(auxData[el].setProficiency != null && auxData[el].setProficiency != ''){ 
                        auxData[el].proficiency = auxData[el].setProficiency;
                        auxData[el].setProficiency = '';
                        auxData[el].proficiencyStatus = 'Success';
                        auxData[el].proficiencyIcon = 'utility:check';
                    }
                });   
                this.data = auxData;                 
            } else {
                this.mainErrorMessage = 'An Error Occurred!';
            }
            this.loading = false;
            
            
        })
        .catch(error => {
            console.log('handleSearch - Error : ' + error);
            console.log(error);
            this.mainErrorMessage = error;
            this.error = error;
            this.loading = false;
            //this.dataRecords = false;
        });  

        console.log('handleSave END ');

    }

    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }

    getSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    /*
    handleHeaderAction(event) {
        // Retrieves the name of the selected filter
        const actionName = event.detail.action.name;
        console.log('handleHeaderAction - actionName : ' + actionName);
        
        //const colDef = event.detail.columnDefinition;
        //console.log('handleHeaderAction - colDef : ' + colDef);
        //console.log('handleHeaderAction - colDef.label : ' + colDef.label);
        
        this.setProficiency(actionName);

    }
    */

    setProficiency(level) {
        let i, index;
        let auxValue;
        let auxData = JSON.parse(JSON.stringify(this.data));

        if(this.selectedRows.length > 0){
            this.showDatatableButtons = true;
        }

        switch (level) {
            case 'allnone':
                auxValue = 'None';
                break;
            case 'alll2':
                auxValue = 'Level 2';
                break;
            case 'alll3':
                auxValue = 'Level 3';
                break;
            default:
        }
            
        for(i=0; i < this.selectedRows.length; i++){
            index = this.findRowIndexById(this.selectedRows[i].uniqueRowId);
            auxData[index].setProficiency = auxValue;
        }
        this.data = auxData;
    }

    /*******************************************************************************
    *                                                                              *
    *  Sorting Methods                                                             *
    *                                                                              *
    * ******************************************************************************/
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
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import importEmployeesCSVFile from '@salesforce/apex/PortalIftpUtils.importEmployeesCSVFile';
import inactivateEmployeesCSVFile from '@salesforce/apex/PortalIftpUtils.inactivateEmployeesCSVFile';


export default class PortalIftpImportEmployees extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track myRecordId;
    @track userInfo;
    @track showSearch = false;
    @track acceptedFormats = ['.pdf'];
    @track data;
            importResultsData;
    @track sortedBy;
    @track sortedDirection;
    @track showOnlyFailledValue = false; 
    @track resultsTitle = '';

    @wire(CurrentPageReference) pageRef;

    connectedCallback(){
        
        getUserInfo()
            .then(result => {
                console.log(result);
                let myResult = JSON.parse(JSON.stringify(result));
                
                this.userInfo = myResult;
                console.log(' this.userInfo: ',  this.userInfo);
                console.log(' this.userInfo.accountRole: ',  this.userInfo.accountRole);
                this.myRecordId = this.userInfo.accountRole;

            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  



        this.columns = [
            {label: 'Employee Code', fieldName: 'code', type: 'text', sortable: true},
            {label: 'Employee Last Name', fieldName: 'lastName', type: 'text', sortable: true},
            {label: 'Employee First Name', fieldName: 'firstName', type: 'text', sortable: true},
            {label: 'Result', fieldName: 'result', type: 'text', sortable: true,
                cellAttributes: { class: { fieldName: 'resultStatus' }}}
        ];

    }

    handleChangeshowOnlyFailed(event){
        console.log('event', event.detail.checked);
        console.log('event',  JSON.parse(JSON.stringify(event.detail)));

        let isChecked = event.detail.checked;

        if(isChecked){
            this.data = this.importResultsData.filter(e =>{
                return e.resultStatus === 'Failed';
            })
        } else {
            this.data = this.importResultsData;
        }
        
        
    }

    handleUploadInsertFinish(event){
        console.log('handleUploadInsertFinish - begin');
        this.resultsTitle = "Employees to Insert";
        this.loading = true;
        //const uploadedFiles = event.detail;
        const uploadedFiles = JSON.parse(JSON.stringify(event.detail));
        
        let docId = uploadedFiles[0].documentId;
        console.log('PortalIftpImportStations - handleUploadFinish - uploadedFiles: ',uploadedFiles );
        console.log('PortalIftpImportStations - handleUploadFinish - uploadedFiles.documentId: ', uploadedFiles[0].documentId);
        
        this.showSearch = true;
        
        importEmployeesCSVFile({fileId: docId })
            .then(results => {
                console.log('handleSearch - results : ' + results);
                console.log('handleSearch - results.length : ' + results.length);
                console.log('handleSearch - results:1 : ' + results[1]);


                if(results && results.length > 0) {
                    this.importResultsData = results;
                    this.data = results;
                    this.dataRecords = true;
                    fireEvent(this.pageRef, 'employeesChanged', null);
                } else {
                    this.dataRecords = false; 
                }
                this.loading = false;

            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });      
    }


    handleUploadInactivateFinish(event){
        this.resultsTitle = "Employees to Delete";
        this.loading = true;
        //const uploadedFiles = event.detail;
        const uploadedFiles = JSON.parse(JSON.stringify(event.detail));
        
        let docId = uploadedFiles[0].documentId;
        console.log('PortalIftpImportStations - handleUploadInactivateFinish - uploadedFiles: ',uploadedFiles );
        console.log('PortalIftpImportStations - handleUploadInactivateFinish - uploadedFiles.documentId: ', uploadedFiles[0].documentId);
        
        this.showSearch = true;

        inactivateEmployeesCSVFile({fileId: docId })
        .then(results => {
            console.log('handleUploadInactivateFinish - results : ' + results);
            console.log('handleUploadInactivateFinish - results.length : ' + results.length);
            console.log('handleUploadInactivateFinish - results:1 : ' + results[1]);


            if(results && results.length > 0) {
                this.importResultsData = results;
                this.data = results;
                this.dataRecords = true;
                fireEvent(this.pageRef, 'employeesChanged', null);
            } else {
                this.dataRecords = false; 
            }
            this.loading = false;

        })
        .catch(error => {
            console.log('handleUploadInactivateFinish - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        });
    }

    // Sort Columns In Import Employees Results Datatable

    // The method onsort event handler
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.data = this.sortData(fieldName, sortDirection);
    }

    sortData(fieldName, sortDirection) {
        var auxdata = this.data;
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
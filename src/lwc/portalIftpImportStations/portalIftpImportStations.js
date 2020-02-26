import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import importStationsCSVFile from '@salesforce/apex/PortalIftpUtils.importStationsCSVFile';



export default class PortalIftpImportStations extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track myRecordId;
    @track userInfo;
    @track showSearch = false;
    @track acceptedFormats = ['.pdf'];
    @track data;
    @track sortedBy;
    @track sortedDirection;

    @wire(CurrentPageReference) pageRef;

    connectedCallback(){
        
        getUserInfo()
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));
                
                this.userInfo = myResult;
                this.myRecordId = this.userInfo.accountRole;

            })
            .catch(error => {
                console.error('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
                fireEvent(this.pageRef, 'errorEvent', error);  
            });  



        this.columns = [
            {label: 'code', fieldName: 'code', type: 'text', sortable: true},
            {label: 'description', fieldName: 'description', type: 'text', sortable: true},
            {label: 'result', fieldName: 'result', type: 'text', sortable: true}
        ];

    }

    handleUploadFinish(event){
        this.loading = true;
        //const uploadedFiles = event.detail;
        const uploadedFiles = JSON.parse(JSON.stringify(event.detail));
        
        let docId = uploadedFiles[0].documentId;
        
        this.showSearch = true;
        
        importStationsCSVFile({fileId: docId })
            .then(results => {
                if(results && results.length > 0) {
                    this.data = this.sortData('code', 'asc', results);
                    this.dataRecords = true;
                    fireEvent(this.pageRef, 'stationsChanged', null);
                } else {
                    this.dataRecords = false; 
                }
                this.loading = false;

            })
            .catch(error => {
                console.error('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
                fireEvent(this.pageRef, 'errorEvent', error);  
            });      
    }

    /*******************************************************************************
    *                                                                              *
    *  Sorting Methods                                                             *
    *                                                                              *
    * ******************************************************************************/

    // Sort Columns In Import Employees Results Datatable
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
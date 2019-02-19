import { LightningElement, api, track, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getNetworkRecordConnection from '@salesforce/apex/RecordSharingController.getNetworkRecordConnection';
import getNetworkConnection from '@salesforce/apex/RecordSharingController.getNetworkConnection';
import stopSharingConnection from '@salesforce/apex/RecordSharingController.stopSharingConnection';
import insertRecordConnection from '@salesforce/apex/RecordSharingController.insertRecordConnection';
import getUserPermission from '@salesforce/apex/RecordSharingController.getUserPermission';

export default class ExternalSharing extends LightningElement {
    @api recordId;
    @track error;
    @track data;
    @track columns = [
        {label: 'Action', type: 'button', typeAttributes: {name: 'stopsharing', title: 'Stop Sharing', label: 'Stop Sharing', disabled: { fieldName: 'connectionActive' }}},
        {label: 'Status', fieldName: 'connectionStatus', type: 'text' },
        {label: 'Connection', fieldName: 'connectionName', type: 'text' },
        {label: 'Date', fieldName: 'connectionDate', type: 'date', typeAttributes: {year: "numeric", month: "long", day: "2-digit"}}
    ];
    wiredRecordConnectionsResult;
    wiredConnectionsResult;
    @track options = [];
    @track showModal = false;
    @track selected = [];
    @track userPermission;
    @track sendEmail = false;   

    @wire(getNetworkRecordConnection, { recordId: '$recordId' })
    wiredRecordConnections(results) {
        this.wiredRecordConnectionsResult = results;
        if (results.data) {
            this.data = results.data;            
        } else if (results.error) {
            this.error = results.error;
        }
    }

    @wire(getUserPermission)
    wiredUserPermission(results) {
        if(results.data) {
            this.userPermission = results.data;
        } else if(results.error) {
            this.error = results.error;
        }
    }
    
    get dataRecords() {
        return (this.data && this.data.length) > 0? true : false;
    }

    get optionsRecords() {
        return (this.options && this.options.length) > 0 ? true : false;
    }
    
    handleRowAction(event) {
        const row = event.detail.row;        

        stopSharingConnection({ recordConnectionId: row.recordConnectionId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Connection deleted',
                        variant: 'success'
                    })
                );
                return refreshApex(this.wiredRecordConnectionsResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });        
    }

    selectedOption(event) {
        this.selected.push(event.detail.value[(event.detail.value.length)-1]);
    }

    handleSendEmail() {
        this.sendEmail = this.sendEmail ? false : true;
    }

    openModal() {
        if(this.showModal) {
            this.showModal = false;
        } else {
            getNetworkConnection()
            .then(results => {
                let options = [];
                results.forEach(function(opt)  { 
                    options.push({ value: opt.Id, label: opt.ConnectionName });
                });     
                this.options = options; 
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });
            this.showModal = true;            
        }
    }

    saveConnection() {
        if(this.selected != null && this.selected !== undefined) {            
            insertRecordConnection({ connectionId: this.selected, localRecordId: this.recordId, sendEmail: this.sendEmail })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'This case is externally shared',
                        variant: 'success'
                    })
                );
                return refreshApex(this.wiredRecordConnectionsResult); 
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });
            this.showModal = false;
        }
        this.showModal = false;    
    }
}
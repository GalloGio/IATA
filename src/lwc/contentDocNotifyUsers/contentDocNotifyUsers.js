import { LightningElement,api,track,wire } from 'lwc';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import LAST_VERSION_ID from '@salesforce/schema/ContentDocument.LatestPublishedVersionId';

import SENT_DATE from '@salesforce/schema/ContentVersion.notify_users_date__c';
import CREATED_DATE from '@salesforce/schema/ContentVersion.CreatedDate';
import triggerUserNotification from '@salesforce/apex/CSP_Utils.triggerUserNotification';

import { refreshApex } from '@salesforce/apex';

const fieldcd=[LAST_VERSION_ID];
const fieldcv=[SENT_DATE,CREATED_DATE];

export default class ContentDocNotifyUsers extends LightningElement {

    @api recordId;

    @track contentVersionId;
    @track notified=false;
    @track contentVersionData;
    @track loading=true;
    @track checkFile=[];
    @track confirmed=false;

    get options(){
        return [{ label: 'Document reviewed before send notification to Portal Users.', value: 'confirmed' }]
    };

    @wire(getRecord, { recordId: '$recordId',fields:fieldcd})
    contentDocData(result){
        if(result.data){
        this.contentVersionId=getFieldValue(result.data, LAST_VERSION_ID);
        }
    }

    @wire(getRecord, { recordId: '$contentVersionId',fields: fieldcv})
    contentVersData(result){
        this.contentVersionData=result;
        if(result.data){
        let createdDate=getFieldValue(result.data, CREATED_DATE);
        let sentDate=getFieldValue(result.data, SENT_DATE);
        this.notified=createdDate<sentDate;
        this.loading=false;      

        }
    }

    handleChange(e){
        this.checkFile = e.detail.value;
        this.confirmed = e.detail.value.length>0;
        this.template.querySelector('lightning-button').disabled= !this.confirmed;
    }
    
    click(){      
        this.loading=true;
        this.checkFile = [];
        this.confirmed=false;
         triggerUserNotification({cvId : this.contentVersionId})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact updated',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                refreshApex(this.contentVersionData);
            })
            .catch(error => {
                this.loading=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    } 

}
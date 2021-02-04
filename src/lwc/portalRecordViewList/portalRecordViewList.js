import { LightningElement, api, track } from 'lwc';
import getIHubLists from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderFieldLists';

export default class PortalRecordViewList extends LightningElement {

    @track providerId;
    @track field = '';
    @track list = '';
    @track label;

    @api 
    get providerIdApi(){
        return this.providerId;
    }
    set providerIdApi(value){
        this.providerId = value;
    }

    @api 
    get fieldApi(){
        return this.field;
    }
    set fieldApi(value){
        this.field = value;
    }

    @api 
    get labelApi(){
        return this.label;
    }
    set labelApi(value){
        this.label = value;
    }

    connectedCallback() {
        getIHubLists({ providerId: this.providerId, field: this.field }).then(result => {
            switch (this.field) {
                case 'Technology__c':
                    if(result[0].Technology__c != undefined){
                        this.list = result[0].Technology__c.split(';');
                    }
                  break;

                case 'Focus_Areas__c': 
                    if(result[0].Focus_Areas__c != undefined){
                        this.list = result[0].Focus_Areas__c.split(';');
                    }
                    break;

                case 'Tags_Of_Categories__c':
                    if(result[0].Tags_Of_Categories__c != undefined){
                        this.list = result[0].Tags_Of_Categories__c.split(';');
                    }
                    break;

                default:
                    this.list = [];
              }

        });
    }

}
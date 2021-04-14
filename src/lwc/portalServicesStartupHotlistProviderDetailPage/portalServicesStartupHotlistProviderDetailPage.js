import { LightningElement, track } from 'lwc';

//apex methods
import getProviderPropertiesAndCardsList from '@salesforce/apex/PortalServicesStartupHotlistCtrl.getProviderDetailsPropertiesAndCardsList';

//navigation
import {getParamsFromPage} from 'c/navigationUtils';

export default class PortalServicesStartupHotlistProviderDetailPage extends LightningElement{

    @track propertiesAndCardsList = {};
    @track componentLoading = true;
    @track providerId;

    connectedCallback() {
        let pageParams = getParamsFromPage();
        if(pageParams !== undefined){
            if(pageParams.providerId !== undefined){
                this.providerId = pageParams.providerId;
            }
        }

        getProviderPropertiesAndCardsList({providerId: this.providerId})
        .then(result => {
            this.propertiesAndCardsList = JSON.parse(JSON.stringify(result));
            this.componentLoading = false;
        });

    }
}
import { LightningElement, track } from 'lwc';

//apex methods
import getProviderPropertiesAndCardsList from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderDetailsPropertiesAndCardsList';

//navigation
import {getParamsFromPage} from 'c/navigationUtils';

export default class PortalServicesInnovationHubProviderDetailPage extends LightningElement{

    @track propertiesAndCardsList = {};
    @track componentLoading = true;

    connectedCallback() {

        let providerId = '';
        let pageParams = getParamsFromPage();
        if(pageParams !== undefined){
            if(pageParams.providerId !== undefined){
                providerId = pageParams.providerId;
            }
        }

        getProviderPropertiesAndCardsList({providerId: providerId})
        .then(result => {
            this.propertiesAndCardsList = JSON.parse(JSON.stringify(result));
            this.componentLoading = false;
        });

    }
}
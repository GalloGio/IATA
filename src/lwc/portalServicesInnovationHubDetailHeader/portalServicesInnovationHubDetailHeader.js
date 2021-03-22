import { LightningElement, track } from 'lwc';

import { getParamsFromPage, navigateToPage } from'c/navigationUtils';

//Contact Apex Methods
import getProviderHeaderFields from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderHeaderFields';

//Import custom labels
import ISSP_CompanyName from '@salesforce/label/c.ISSP_CompanyName';
import ISSP_Contact from '@salesforce/label/c.ISSP_Contact';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesInnovationHubDetailHeader extends LightningElement {

    @track backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/MyProfileBackground.jpg';

    //Loading && Error
    @track loading = false;
    @track backgroundStyle;
    @track profileDivStyle;
    @track iconLink;
    @track contact = {};
    @track providerId;
    @track headerFields = {};

    _labels = {
        ISSP_CompanyName,
        ISSP_Contact,
    };

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value;
    }

    connectedCallback() {
        let pageParams = getParamsFromPage();
        if(pageParams !== undefined){
            if(pageParams.providerId !== undefined){
                this.providerId = pageParams.providerId;
            }
        }

        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px;'
        this.profileDivStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px; width: 196px; height: 196px; position: absolute; top: 72px; left: 32px; border-radius: 50%;  box-shadow: 0px 1px 12px 0px #827f7f; background-color:white;';
        
        getProviderHeaderFields({ providerId: this.providerId}).then(result => {
            this.headerFields = result;
            console.log(this.headerFields);
        });
        

    }

    closeAlreadyL2Popup(){
        navigateToPage(CSP_PortalPath,{});
    }

}
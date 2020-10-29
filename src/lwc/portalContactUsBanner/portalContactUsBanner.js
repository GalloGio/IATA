import { LightningElement,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import title from '@salesforce/label/c.CSP_Contact_Us_Banner_Title';
import msg from '@salesforce/label/c.CSP_Contact_Us_Banner_Msg';

export default class PortalContactUsBanner extends NavigationMixin(LightningElement)  {

    @track label={
        title,
        msg
    };

    iconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/InfoIcon.svg';
  
    goTo (){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-reach-us"
            }})
            .then(url => {
                navigateToPage(url, {});
            });
    }

}
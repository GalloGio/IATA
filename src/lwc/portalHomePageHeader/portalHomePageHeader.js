import { LightningElement, api, track } from 'lwc';

//import apex methods
import getUserName from '@salesforce/apex/PortalHomeCtrl.getUserName';

//import labels
import CSP_Search_Home_Placeholder from '@salesforce/label/c.CSP_Search_Home_Placeholder';
import CSP_Home_WelcomeTitle from '@salesforce/label/c.CSP_Home_WelcomeTitle';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalHomePageHeader extends LightningElement {

    @track label = {
        CSP_Search_Home_Placeholder,
        CSP_Home_WelcomeTitle
    };
    
    //Used to inject label for header
    @api headerLabel;

    //links for images
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/HomeBackground.jpg';

    @track backgroundStyle;

    @track greetinglabel = '';
    @track loadingGreeting = true;

    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:396px;';

        getUserName({})
        .then(result => {
            //console.log('getUserName: ', result);
            if(!result)result='';
             this.greetinglabel = this.label.CSP_Home_WelcomeTitle.replace('[username]',result);
            this.loadingGreeting = false;
        }).catch(error => {
            this.loadingGreeting = false;
        });

    }

}
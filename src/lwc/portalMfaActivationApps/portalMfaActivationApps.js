import { LightningElement, wire, track, api } from 'lwc';
import getAuthenticatorLinks from '@salesforce/apex/MFA_LoginFlowController.getAuthenticatorLinks';

import MFAStylesResources from '@salesforce/resourceUrl/MFA_Styles';

export default class PortalMfaActivationApps extends LightningElement {
	@api translations;

    icons = {
        android: MFAStylesResources + '/icons/android.svg',
        ios: MFAStylesResources + '/icons/iOS.svg',
        explorer: MFAStylesResources + '/icons/explorer.svg'
    }

    @track links;
    @track availableApps;

	/**
	 * @description	Obtain the authentication apps
	 */
    @wire (getAuthenticatorLinks)
    getAuthenticatorLinksWired({ error, data }) {
        if(data){
			this.links = data;
            this.availableApps = data;
        }
	}

	/* HTML attributes - START */
    get authenticationAppsToDisplay(){
        return this.availableApps;
    }

    get containerClass(){
        return 'slds-p-horizontal_medium mfa-font-family around-border';
    }

    get labels(){
        return this.translations;
    }
	/* HTML attributes - END */
}
import { LightningElement } from 'lwc';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_PortalBaseURL from '@salesforce/label/c.CSP_PortalBaseURL';
import isGuestUser from '@salesforce/apex/CSP_Utils.isGuestUser';
import { getPageName } from 'c/navigationUtils';

export default class PortalGuestPageHeader extends LightningElement {

	logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
	internalUser;
	pageName;

	connectedCallback() {
		isGuestUser().then(results => {
			this.internalUser = !results;
		});

        this.pageName = getPageName();
	}

	get displayPublicHeader() {
		return !this.internalUser;
	}

	navigateToHomePage() {
		window.location.href = '' + CSP_PortalBaseURL + CSP_PortalPath;
	}
}
import { LightningElement, api, track } from 'lwc';

import updateLastModifiedService from '@salesforce/apex/PortalServicesCtrl.updateLastModifiedService';
import paymentLinkRedirect from '@salesforce/apex/PortalServicesCtrl.paymentLinkRedirect';
import changeIsFavoriteStatus from '@salesforce/apex/PortalServicesCtrl.changeIsFavoriteStatus';
import verifyCompleteL3Data from '@salesforce/apex/PortalServicesCtrl.verifyCompleteL3Data';
import getPortalServiceId from '@salesforce/apex/PortalServicesCtrl.getPortalServiceId';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

//import labels
import CSP_Services_GoToService from '@salesforce/label/c.CSP_Services_GoToService';

export default class PortalServicesInnovationHubProviderCard extends NavigationMixin(LightningElement) {

	@api provider;

	@track isLoading = false;

	label = {
		CSP_Services_GoToService
	};

	get hasIcon(){
		return this.provider.imageUrl !== undefined && this.provider.imageUrl !== '';
	}

	openProviderDetails(event) {
		event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "service-innovationhub-provider"
			},
			state: {
                providerId: this.provider.id
			}
		
		})
        .then(url => window.open(url));
	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}
}
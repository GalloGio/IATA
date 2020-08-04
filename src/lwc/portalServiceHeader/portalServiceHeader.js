import { LightningElement, api, track } from 'lwc';
import serviceDetails from '@salesforce/apex/PortalServicesCtrl.getPortalServiceDetails';

export default class PortalServiceHeader extends LightningElement {

	@api name;
	@api title;
	@api breadcrumblabel;
	@track serviceData = {};
	
	connectedCallback(){
		serviceDetails({serviceName: this.name})
		.then(data => {
			this.serviceData = data;
		})
		.catch(error => {
		})
		.finally(() => {
		})
	}

	@track _showBreadcrumbs = true;
	@api get showBreadcrumbs() {
		return this._showBreadcrumbs;
	}

	set showBreadcrumbs(v) {
		this._showBreadcrumbs = v;
	}

	get displayedTitle() {
		return this.title ? 
				this.title :
				this.serviceData && this.serviceData.recordService && this.serviceData.recordService.ServiceName__c !== null ? 
					this.serviceData.recordService.ServiceName__c : 
					'';
	}

	get imageUrl() {
		return this.serviceData && this.serviceData.recordService && this.serviceData.recordService.Application_icon_URL__c !== null ?
				this.serviceData.recordService.Application_icon_URL__c : false;
	}
}
import { LightningElement, api, wire } from 'lwc';

import goToOldPortalService from '@salesforce/apex/PortalServicesCtrl.goToOldPortalService';
import updateLastModifiedService from '@salesforce/apex/PortalServicesCtrl.updateLastModifiedService';
import verifyCompleteL3Data from '@salesforce/apex/PortalServicesCtrl.verifyCompleteL3Data';
import getPortalServiceId from '@salesforce/apex/PortalServicesCtrl.getPortalServiceId';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

//import labels
import CSP_Services_ManageService from '@salesforce/label/c.CSP_Services_ManageService';
import CSP_Services_GoToService from '@salesforce/label/c.CSP_Services_GoToService';

export default class PortalServicesAccessGrantedCard extends NavigationMixin(LightningElement) {

	@api service;

	label = {
		CSP_Services_ManageService,
		CSP_Services_GoToService
	};

	goToManageServiceButtonClick(event) {
		let serviceAux = JSON.parse(JSON.stringify(this.service));

		let params = {};
		params.serviceId = serviceAux.recordService.Id;

		event.preventDefault();
		event.stopPropagation();
		this[NavigationMixin.GenerateUrl]({
			type: "standard__namedPage",
			attributes: {
				pageName: "manage-service"
			}})
			.then(url => navigateToPage(url, params));
	}

	goToServiceButtonClick() {
		//because proxy.......
		let serviceAux = JSON.parse(JSON.stringify(this.service)).recordService;

		//attributes stored on element that is related to the event
		let appUrlData = serviceAux.Application_URL__c
		let appFullUrlData = serviceAux.Application_URL__c;
		let openWindowData = serviceAux.New_Window__c;
		let requestable = serviceAux.Requestable__c;
		let recordId = serviceAux.Id;

		// update Last Visit Date on record
		updateLastModifiedService({ serviceId: recordId })

		let myUrl;
		let flag = false;
		if (appUrlData !== '') {
			myUrl = appUrlData;
			flag = true;
		} else if (appFullUrlData !== '') {
			myUrl = appFullUrlData;
			flag = true;
		}

		if (flag) {
			//verifies if the event target contains all data for correct redirection
			if (openWindowData !== null && openWindowData !== undefined) {
				//determines if the link is to be opened on a new window or on the current
				if (openWindowData) {
					//open new tab with the redirection

					if (myUrl.startsWith('/')) {
						goToOldPortalService({ myurl: myUrl })
							.then(result => {
								//open new tab with the redirection
								window.open(result);
								this.toggleSpinner();
							})
							.catch(error => {
								//throws error
								this.error = error;
							});

					} else {
						if(serviceAux.ServiceName__c === 'Training Platform (LMS)'){
							getPortalServiceId({ serviceName: serviceAux.ServiceName__c })
								.then(serviceId => {
									console.log('service Id: ' + recordId);
									verifyCompleteL3Data({serviceId: recordId})
									.then(result => {
										if(result){
											console.log('to service');
											window.open(myUrl);
										}
										else{
											console.log('fire event')
											fireEvent(this.pageRef, 'fireL3Registration', serviceId);

										}
										this.toggleSpinner();
									})
									.catch(error => {
										this.error = error;
									});
								})
								.catch(error => {
									this.error = error;
							});

						}
						else{
							if (!myUrl.startsWith('http')) {
								myUrl = window.location.protocol + '//' + myUrl;
							}
							window.open(myUrl);
							this.toggleSpinner();
						}
					}


				} else if (myUrl !== '') {
					//redirects on the same page
					//method that redirects the user to the old portal maintaing the same loginId
					goToOldPortalService({ myurl: myUrl })
						.then(result => {
							//open new tab with the redirection
							window.location.href = result;
							this.toggleSpinner();
						})
						.catch(error => {
							//throws error
							this.error = error;
						});

				}
			}
		} else {
			console.info('No link to the service has been set.')
		}


	}

	@wire(CurrentPageReference) pageRef;

}
import { LightningElement, api, track } from 'lwc';

import goToOldPortalService from '@salesforce/apex/PortalServicesCtrl.goToOldPortalService';
import updateLastModifiedService from '@salesforce/apex/PortalServicesCtrl.updateLastModifiedService';
import paymentLinkRedirect from '@salesforce/apex/PortalServicesCtrl.paymentLinkRedirect';
import changeIsFavoriteStatus from '@salesforce/apex/PortalServicesCtrl.changeIsFavoriteStatus';
import verifyCompleteL3Data from '@salesforce/apex/PortalServicesCtrl.verifyCompleteL3Data';
import getPortalServiceId from '@salesforce/apex/PortalServicesCtrl.getPortalServiceId';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import checkLatestTermsAndConditionsAccepted from '@salesforce/apex/ServiceTermsAndConditionsUtils.checkLatestTermsAndConditionsAccepted';
import getContactInfo from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

//import labels
import CSP_Services_ManageService from '@salesforce/label/c.CSP_Services_ManageService';
import CSP_Services_GoToService from '@salesforce/label/c.CSP_Services_GoToService';
import CSP_Services_AddFavorite from '@salesforce/label/c.CSP_Services_AddFavorite';
import CSP_Services_RemoveFavorite from '@salesforce/label/c.CSP_Services_RemoveFavorite';

export default class PortalServicesAccessGrantedCard extends NavigationMixin(LightningElement) {
	/* Images */
	favoriteIcon = CSP_PortalPath + 'CSPortal/Images/Icons/favorite.png';
	notFavoriteIcon = CSP_PortalPath + 'CSPortal/Images/Icons/not_favorite.png';

	@api service;
	@api showOnlyFavorites;

	@track isLoading = false;
	@track contactId;
    @track isLatestAccepted = false;
    @track displayAcceptTerms = false;

	label = {
		CSP_Services_ManageService,
		CSP_Services_GoToService,
		CSP_Services_AddFavorite,
		CSP_Services_RemoveFavorite
	};

	get hasIcon(){
		return this.service.recordService.Application_icon_URL__c !== undefined;
	}

	connectedCallback(){
        getContactInfo().then(result => {
            let userInfo = JSON.parse(JSON.stringify(result));
            this.contactId = userInfo.Id;

            checkLatestTermsAndConditionsAccepted({portalServiceId: this.service.recordService.Id, contactId: userInfo.Id}).then(result2 => {
                let isLatestAccepted = JSON.parse(JSON.stringify(result2));

                this.isLatestAccepted = isLatestAccepted;
            });
        });
    }

    cancelTermsAcceptance(){
        this.displayAcceptTerms = false;
    }

    acceptTerms(){
        this.displayAcceptTerms = false;
        this.goToService();
	}
	
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
        // check if service has terms and conditions and that they're all accepted
        if(!this.isLatestAccepted){
            this.displayAcceptTerms = true;
        }
        else{
            this.goToService();
        }
    }

	goToService() {
		//because proxy.......
		let serviceAux = JSON.parse(JSON.stringify(this.service)).recordService;

		//attributes stored on element that is related to the event
		let appUrlData = serviceAux.Application_URL__c
		let appFullUrlData = serviceAux.Application_URL__c;
		let openWindowData = serviceAux.New_Window__c;
		let requestable = serviceAux.Requestable__c;
		let recordId = serviceAux.Id;
		let appName = serviceAux.ServiceName__c;

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
		} else if (appName === 'Payment Link' || appName === 'Paypal') {
			myUrl = '';
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
                        if (appName === 'Payment Link' || appName === 'Paypal') {
                            paymentLinkRedirect()
                                .then(result => {
                                    if (result !== undefined && result !== '') {
                                        myUrl = result;
                                        if (!myUrl.startsWith('http')) {
                                            myUrl = window.location.protocol + '//' + myUrl;
                                        }
                                    }
                                    window.open(myUrl);
                                    this.toggleSpinner();
                                });

                        } 
                        else if(appName === 'Training Platform (LMS)'){
							getPortalServiceId({ serviceName: appName })
								.then(serviceId => {
									verifyCompleteL3Data({serviceId: recordId})
									.then(result => {
										if(result !== 'not_complete'){
											window.open(result);
										}
										else{
											navigateToPage(CSP_PortalPath+'?firstLogin=true&lms=yas');
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
                        else {
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
		}
	}

	changeIsFavoriteStatus(){
		this.startLoading();
		changeIsFavoriteStatus({portalApplicationId:this.service.recordService.Id, portalApplicationRightId:this.service.portalApplicationRightId, isFavorite: !this.service.isFavorite})
			.then(result => {
				if(result){
					this.dispatchEvent(new CustomEvent('changefavoritestatus'));
				}
			});
	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}
}

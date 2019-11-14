
import { LightningElement, track, api } from 'lwc';

//navigation
import { navigateToPage, getPageName } from 'c/navigationUtils';

//toast on portal
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUserInformation from '@salesforce/apex/TreasuryDashboardCtrl.getUserInformation';

export default class PortalTreasuryDashboardIframesContainer extends LightningElement {

    @api reportName = 'Treasury_Dashboard';
    @api premiumReportName = 'Treasury_Dashboard_Premium';
    @api applicationName = 'TreasuryDashboard';
    @api tdPremiumService;
    @api userId;
    @api contactId;

    @track loading = true;
    @track error;

    @track hasTwoFactor;
    @track isStandardUser;
    @track isPremiumUser;


    connectedCallback() {

        getUserInformation({})
            .then(result => {

                this.hasTwoFactor = result.hasTwoFactor;
                this.userId = result.user.Id;
                this.contactId = result.user.ContactId;
                this.isStandardUser = result.isStandardUser;
                this.isPremiumUser = result.isPremiumUser;
                this.tdPremiumService = result.tdPremium;

                //TODO:temporal solution
                this.hasTwoFactor = true;
                this.isStandardUser = true;
                this.isPremiumUser = false;

                console.log('hasTwoFactor: ', this.hasTwoFactor);
                console.log('isStandardUser: ', this.isStandardUser);
                console.log('isPremiumUser: ', this.isPremiumUser);

                //no two factor for user -> log out user
                if(! this.hasTwoFactor) {
                    console.log('no two factor authentication');
                    navigateToPage("/secur/logout.jsp");
                }
                //no access to Standard Dashboard -> redirect to Home page
                else if(! this.isStandardUser && ! this.isPremiumUser) {
                    console.log('not a standard nor premium user');
                    navigateToPage("/ISSP_Homepage");
                } else {
                    console.log('iframes container OK');
                    this.loading = false;
                }

            })
            .catch(error => {
                this.error = error;
                this.loading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.parse(JSON.stringify(error)).body.message,
                        variant: 'error',
                        mode: 'pester'
                    })
                );
            });


    }


}
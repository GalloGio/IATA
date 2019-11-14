import { LightningElement, track, api } from 'lwc';

/*//navigation
import { navigateToPage, getPageName } from 'c/navigationUtils';

//toast on portal
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUserInformation from '@salesforce/apex/TreasuryDashboardCtrl.getUserInformation';*/

export default class PortalTreasuryDashboardContainer extends LightningElement {

    //@track hasTwoFactor = false;
    /*@track error;
    @track loading = true;

    @track hasTwoFactor;
    @api userId;
    @api isStandardUser;
    @api isPremiumUser;

    connectedCallback() {

        getUserInformation({})
            .then(result => {
                console.log(JSON.stringify(result));
                this.hasTwoFactor = result.hasTwoFactor;
                this.isStandardUser = result.isStandardUser;
                this.isPremiumUser = result.isPremiumUser;
                this.userId = result.user.Id;

                //TODO:temporal solution
                this.hasTwoFactor = true;
                this.isStandardUser = false;
                this.isPremiumUser = true;

                console.log('hasTwoFactor: ', this.hasTwoFactor);
                console.log('isStandardUser: ', this.isStandardUser);
                console.log('isPremiumUser: ', this.isPremiumUser);

                //no two factor for user -> log out user
                if(! this.hasTwoFactor) {
                    navigateToPage("/secur/logout.jsp");
                }
                //no access to Standard Dashboard -> redirect to Home page
                else if(! this.isStandardUser && ! this.isPremiumUser) {
                    navigateToPage("/ISSP_Homepage");
                }
                this.loading = false;

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



    }*/


}
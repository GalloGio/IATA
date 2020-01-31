
import { LightningElement, track, api } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import gerCaseRecordTypeId from '@salesforce/apex/TreasuryDashboardCtrl.getCaseRecordTypeId';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalTreasuryDashboardContactUs extends NavigationMixin(LightningElement) {

    @track supportReachUsCreateNewCaseURL;
    @track loading = true;

    //case record type id
    recordTypeId;

    conversationImageURL = CSP_PortalPath + 'CSPortal/Images/Icons/messageBallons.svg';

    connectedCallback() {
        gerCaseRecordTypeId()
            .then(result => {
                if(result !== undefined && result !== null) {
                    this.recordTypeId = result;
                    this[NavigationMixin.GenerateUrl]({
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "support-reach-us-create-new-case"
                            }})
                        .then(url => this.supportReachUsCreateNewCaseURL = url);
                }
                this.loading = false;

            })
            .catch(error => {
                console.log('PortalTreasuryDashboardContactUs error: ', JSON.parse(error).body.message);
            });

    }


    redirectToSupport(event) {
        event.preventDefault();
        event.stopPropagation();

        let params = {};
        if(this.recordTypeId !== undefined && this.recordTypeId !== null) {
            params.recordTypeId = this.recordTypeId;
            params.concerncase=false;
            params.emergency=false;
        }

        navigateToPage(this.supportReachUsCreateNewCaseURL, params);
    }

}
import { LightningElement, track } from 'lwc';

//import labels
import CSP_Services_MyServicesHelpText from '@salesforce/label/c.CSP_Services_MyServicesHelpText';
import CSP_Services_ShowOnlyFavorites from '@salesforce/label/c.CSP_Services_ShowOnlyFavorites';

export default class PortalServicesMyServices extends LightningElement {

    @track showOnlyFavorites = false;

    showAllServicesLabel = 'Show All';

    get buttonsLabel(){
        if(this.showOnlyFavorites){
            return this.showAllServicesLabel;
        }
        return CSP_Services_ShowOnlyFavorites;
    }

    label = {
        CSP_Services_MyServicesHelpText
    };

    handleGoToAvailableServicesTab(event){
        this.dispatchEvent(
            new CustomEvent('gotoavailableservicestab')
        );
    }

    handleShowOnlyFavorites(){
        this.showOnlyFavorites = ! this.showOnlyFavorites;
    }

}
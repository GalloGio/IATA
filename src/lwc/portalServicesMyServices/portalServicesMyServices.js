import { LightningElement, track } from 'lwc';

//import labels
import CSP_Services_MyServicesHelpText from '@salesforce/label/c.CSP_Services_MyServicesHelpText';
import CSP_Services_ShowOnlyFavorites from '@salesforce/label/c.CSP_Services_ShowOnlyFavorites';
import CSP_Services_ShowAll from '@salesforce/label/c.CSP_Services_ShowAll';

export default class PortalServicesMyServices extends LightningElement {

    @track showOnlyFavorites = false;

    get buttonsLabel(){
        if(this.showOnlyFavorites){
            return CSP_Services_ShowAll;
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
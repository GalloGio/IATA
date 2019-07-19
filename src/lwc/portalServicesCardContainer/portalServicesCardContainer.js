import { LightningElement, api, track } from 'lwc';

export default class PortalServicesCardContainer extends LightningElement {

    @api imageUrl;

    @api
    get backgroundVariant() {
        return this.filteringObject;
    }
    set backgroundVariant(value) {
        if(value === 'white'){
            this.backgroundClass = 'customCardWhiteService cardProperties';
            this.fadeClass = 'slds-m-vertical_small text-xsmall text-gray fadeWhite'; 
        }
        if(value === 'lightGray'){
            this.backgroundClass = 'customCardLightGrayService cardProperties';
            this.fadeClass = 'slds-m-vertical_small text-xsmall text-gray fadeLightGray';
        }
    }

    @track backgroundClass = '';
    @track fadeClass = '';


}
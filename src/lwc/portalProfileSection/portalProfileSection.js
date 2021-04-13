/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement,api,track } from 'lwc';

export default class PortalProfileSection extends LightningElement {
    @api className;
    @api headerClass = 'slds-m-vertical_small';
    @track titleClass = 'text-medium text-bold text-darkGray';

    connectedCallback() {
        if(window.location.pathname.includes('service-startuphotlist')){
            this.titleClass = 'text-medium text-bold SHBlue' ;   
        }
    }
}
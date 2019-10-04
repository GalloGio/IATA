/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement,api } from 'lwc';

export default class PortalProfileSection extends LightningElement {
    @api className;
    @api headerClass = 'slds-m-vertical_small';
}
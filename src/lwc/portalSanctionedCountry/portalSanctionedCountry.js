import { LightningElement, track } from 'lwc';
import { navigateToPage }      from 'c/navigationUtils';
import message from '@salesforce/label/c.ISSP_Sanctions_Message';

export default class PortalSanctionedCountry extends LightningElement {
    label = {
        message
    };
}
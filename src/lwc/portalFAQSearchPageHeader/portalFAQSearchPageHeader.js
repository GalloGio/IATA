import { LightningElement, track } from 'lwc';
import CSP_FAQ_HeaderTitle from '@salesforce/label/c.CSP_FAQ_HeaderTitle';

export default class PortalFAQSearchPageHeader extends LightningElement {
    @track label = { CSP_FAQ_HeaderTitle };
}
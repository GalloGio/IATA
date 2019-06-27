import { LightningElement, track } from 'lwc';
import CSP_DocumentsLabel from '@salesforce/label/c.CSP_DocumentsLabel';

export default class PortalDocumentsPageHeader extends LightningElement {
    @track label = {
        CSP_DocumentsLabel
    };
    documents = CSP_DocumentsLabel;
    iconFolder = '/csportal/s/CSPortal/Images/Support/Documents.svg';
}
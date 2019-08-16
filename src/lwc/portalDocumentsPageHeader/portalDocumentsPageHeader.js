import { LightningElement, track } from 'lwc';
import CSP_DocumentsLabel from '@salesforce/label/c.CSP_Documents';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalDocumentsPageHeader extends LightningElement {
    @track label = {
        CSP_DocumentsLabel
    };
    documents = CSP_DocumentsLabel;
    iconFolder = CSP_PortalPath + 'CSPortal/Images/Support/Documents.svg';
}
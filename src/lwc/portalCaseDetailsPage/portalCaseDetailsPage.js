import { LightningElement, track } from 'lwc';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCaseDetailsPage extends LightningElement {
    @track now = '';

    //links for images
    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
    printIcon = CSP_PortalPath + 'CSPortal/Images/Icons/print-blue.svg';

    downloadedOn() {
        let d = new Date();
        let n = d.toLocaleString();
        this.now = n;
    }
    toPDF() {
        window.print();
    }

}
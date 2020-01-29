import { LightningElement, track } from 'lwc';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
//custom labels
import CSP_Print from '@salesforce/label/c.CSP_Print';
import CSP_Printed_Date from '@salesforce/label/c.CSP_Printed_Date';

export default class PortalCaseDetailsPage extends LightningElement {
    @track now = '';

    // Expose the labels to use in the template.
    @track label = {
        CSP_Print,
        CSP_Printed_Date
    };
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

 @track isExpired;

    handleExpired(event) {
        this.isExpired = event.detail;
      }

}

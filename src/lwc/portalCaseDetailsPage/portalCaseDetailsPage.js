import { LightningElement, track } from 'lwc';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import { getParamsFromPage } from'c/navigationUtils';

//custom labels
import CSP_Print from '@salesforce/label/c.CSP_Print';
import CSP_Printed_Date from '@salesforce/label/c.CSP_Printed_Date';

export default class PortalCaseDetailsPage extends LightningElement {
    @track now = '';

	@track recordId;

    // Expose the labels to use in the template.
    @track label = {
        CSP_Print,
        CSP_Printed_Date
    };
    //links for images
    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
    printIcon = CSP_PortalPath + 'CSPortal/Images/Icons/print-blue.svg';

	connectedCallback() {
		//get the parameters for this page
        this.pageParams = getParamsFromPage();

        if(this.pageParams.caseId !== undefined){
			this.recordId = this.pageParams.caseId;
        }
    }

    downloadedOn() {
        let d = new Date();
        let n = d.toLocaleString();
        this.now = n;
    }
    toPDF() {
        window.print();
    }

}

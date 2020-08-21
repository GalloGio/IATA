import { LightningElement, track } from 'lwc';
import { getPageName }    from 'c/navigationUtils';

//import labels
import CSP_Service_TIPReports_Title from '@salesforce/label/c.CSP_Service_TIPReports_Title';
import CSP_Service_AirlineDailySales_Title from '@salesforce/label/c.CSP_Service_AirlineDailySales_Title';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesTIPReportsPageHeader extends LightningElement {
    label = { 
        CSP_Service_TIPReports_Title,
        CSP_Service_AirlineDailySales_Title
    };
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/CasesBackground.jpg';
    @track imageInfo = '';

    pageName = '';

    get title() {
        if (this.pageName==='service-tipreports') {
            return this.label.CSP_Service_TIPReports_Title;
        }
        if (this.pageName==='airline-daily-sales') {
            return this.label.CSP_Service_AirlineDailySales_Title;
        }
        return '';
    }

    connectedCallback() {
        this.imageInfo = 'background-image: url("' + this.backgroundIcon + '");'
        this.pageName = getPageName();
    }
}
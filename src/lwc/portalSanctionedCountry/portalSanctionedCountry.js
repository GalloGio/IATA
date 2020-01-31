import { LightningElement, track } from 'lwc';
import { navigateToPage }          from 'c/navigationUtils';
import message                     from '@salesforce/label/c.CSP_Restricted_Login_Message';
import CSP_PortalPath              from '@salesforce/label/c.CSP_PortalPath';
import ISSP_Registration_Privacy   from '@salesforce/label/c.ISSP_Registration_Privacy';
import ISSP_Registration_Legal     from '@salesforce/label/c.ISSP_Registration_Legal';
import csp_Footer_Legal_URL        from '@salesforce/label/c.csp_Footer_Legal_URL';
import csp_Footer_Privacy_URL      from '@salesforce/label/c.csp_Footer_Privacy_URL';
import headerLabel                 from '@salesforce/label/c.CSP_Restricted_Login_Title';

export default class PortalSanctionedCountry extends LightningElement {
    logoIcon        = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';

    labels = {
        message,
        headerLabel,
        csp_Footer_Legal_URL,
        csp_Footer_Privacy_URL,
        ISSP_Registration_Legal,
        ISSP_Registration_Privacy
    };
}
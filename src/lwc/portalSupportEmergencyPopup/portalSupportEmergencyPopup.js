import { LightningElement,api,track } from 'lwc';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_Emergency_Selected_Case_Creation_Title from '@salesforce/label/c.CSP_Emergency_Selected_Case_Creation_Title';
import CSP_Emergency_Selected_Case_Creation_Message from '@salesforce/label/c.CSP_Emergency_Selected_Case_Creation_Message';
import CSP_Emergency_Selected_Case_Creation_Message2 from '@salesforce/label/c.CSP_Emergency_Selected_Case_Creation_Message2';
import CSP_Emergency_Selected_Reason1 from '@salesforce/label/c.CSP_Emergency_Selected_Reason1';
import CSP_Emergency_Selected_Reason2 from '@salesforce/label/c.CSP_Emergency_Selected_Reason2';
import CSP_Emergency_Selected_Reason3 from '@salesforce/label/c.CSP_Emergency_Selected_Reason3';
import CSP_Emergency_Selected_Reason4 from '@salesforce/label/c.CSP_Emergency_Selected_Reason4';

 
export default class PortalSupportEmergencyPopup extends LightningElement {

    @track label={
         CSP_Emergency_Selected_Case_Creation_Title,
         CSP_Emergency_Selected_Case_Creation_Message,
         CSP_Emergency_Selected_Case_Creation_Message2,
         CSP_Emergency_Selected_Reason1,
         CSP_Emergency_Selected_Reason2,
         CSP_Emergency_Selected_Reason3,
         CSP_Emergency_Selected_Reason4 

    }


    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';
    @api showClose = false;

    handleSubmitRequest(){
        this.dispatchEvent(new CustomEvent('confirmaction',{}));    
    }

    abortRequest(){
        this.dispatchEvent(new CustomEvent('abortaction',{}));    
    }

}
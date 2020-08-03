import { LightningElement,api,track } from 'lwc';
 
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
export default class PortalGenericPopupWindow extends LightningElement {


    @track warningIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';
    @track successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/successIcon.svg';


    @api 
    get variant(){}
    set variant(val){

        switch (val) {
            case 'success':
                this.iconSrc=this.successIcon;
                this.variantCls='success';
                
                break;
                
            case 'warning':
                this.iconSrc=this.warningIcon;     
                this.variantCls='warning';  
                break;

            default:
                break;
        }
        

    }

    @track iconSrc;
}
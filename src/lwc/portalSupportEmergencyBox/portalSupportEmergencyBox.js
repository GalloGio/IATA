import { LightningElement,track,api } from 'lwc';
import CSP_Emergency_Box_Message from '@salesforce/label/c.CSP_Emergency_Box_Message'
import CSP_Emergency_Tooltip from '@salesforce/label/c.CSP_Emergency_Tooltip'
import CSP_Emergency_Footer_Message from '@salesforce/label/c.CSP_Emergency_Footer_Message'
 
export default class PortalSupportEmergencyBox extends LightningElement {
    
    @track label={
        CSP_Emergency_Box_Message,
        CSP_Emergency_Tooltip,
        CSP_Emergency_Footer_Message
    }

    @track _isEmergencyCase=false;
    @track _isShowTooltip=false;
    @api
    get isEmergencyCase(){
        return this._isEmergencyCase;
    }
    set isEmergencyCase(value){
        this._isEmergencyCase=value;
    }

    @api
    get showTooltip(){
        return this._isShowTooltip;
    }
    set showTooltip(value){
        this._isShowTooltip=value;
    }

    handleIsEmergency(){
        this._isEmergencyCase=!this._isEmergencyCase;
        this.dispatchEvent(new CustomEvent('checkchange',{detail:{value:this._isEmergencyCase}}));
    }

    get showWarning(){
        return this._isShowTooltip===false  && this._isEmergencyCase===true;
    }

}
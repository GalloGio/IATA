import { LightningElement,track,api } from 'lwc';

//custom labels
import CSP_L2_Business_Address_Information from '@salesforce/label/c.CSP_L2_Business_Address_Information';
import CSP_L2_Create_New_Account from '@salesforce/label/c.CSP_L2_Create_New_Account';
import CSP_L2_Company_Information_Message from '@salesforce/label/c.CSP_L2_Company_Information_Message';
import CSP_L2_Company_Information from '@salesforce/label/c.CSP_L2_Company_Information';
import ISSP_MyProfile_SECTOR from '@salesforce/label/c.ISSP_MyProfile_SECTOR';
import ISSP_MyProfile_CATEGORY from '@salesforce/label/c.ISSP_MyProfile_CATEGORY';
import CSP_L2_Company_Name from '@salesforce/label/c.CSP_L2_Company_Name';
import CSP_L2_Website from '@salesforce/label/c.CSP_L2_Website';
import CSP_L2_Business_Address_Information_Message from '@salesforce/label/c.CSP_L2_Business_Address_Information_Message';
import CSP_L2_Back_to_Company_Information from '@salesforce/label/c.CSP_L2_Back_to_Company_Information';
import CSP_L2_Next_Confirmation from '@salesforce/label/c.CSP_L2_Next_Confirmation';

export default class PortalRegistrationAddressInformation extends LightningElement {

    // inputs
    @api account;
    @api address;
    @api addressSuggestions;
    @api countryId;

    @track localAddress;

    // flag to enable/disable the "Next Step / Confirmation" button
    @track isConfirmationButtonDisabled;

    // labels
    _labels = {
        CSP_L2_Business_Address_Information,
        CSP_L2_Create_New_Account,
        CSP_L2_Company_Information_Message,
        CSP_L2_Company_Information,
        ISSP_MyProfile_SECTOR,
        ISSP_MyProfile_CATEGORY,
        CSP_L2_Company_Name,
        CSP_L2_Website,
        CSP_L2_Business_Address_Information_Message,
        CSP_L2_Back_to_Company_Information,
        CSP_L2_Next_Confirmation
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    connectedCallback() {
        this.localAddress = JSON.parse(JSON.stringify(this.address));
        this.dispatchEvent(new CustomEvent('scrolltotop'));
    }

    toCompanyInformation(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'3'}));
    }

    toConfirmation(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'5'}));
    }

    setValidationStatus(event){
        if(this.isConfirmationButtonDisabled !== !event.detail){
            this.isConfirmationButtonDisabled = !event.detail;
            this.dispatchEvent(new CustomEvent('completionstatus',{detail : event.detail}));
        }
    }

    startLoading(){
        this.dispatchEvent(new CustomEvent('startloading'));
    }

    stopLoading(){
        this.dispatchEvent(new CustomEvent('stoploading'));
    }

    @api
    getAddressInformation(){
        let addressInformation = this.template.querySelector('c-portal-address-form').getAddressInformation();
        this.localAddress = JSON.parse(JSON.stringify(addressInformation));

        return this.localAddress;
    }
}
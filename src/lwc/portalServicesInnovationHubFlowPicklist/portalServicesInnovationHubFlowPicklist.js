import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';
import Available from '@salesforce/label/c.Available';
import Selected from '@salesforce/label/c.icg_selected';
import ChooseAny from '@salesforce/label/c.CSP_IHub_ChooseAny';

export default class PortalServicesInnovationHubFlowPicklist extends LightningElement {

    labels = { 
        Available, 
        Selected, 
        ChooseAny       
    };

    @api
    get field() {
        return this._field;
    }

    set field(value) {
        this._field = value;
    }

    @api
    get selectedOption() {
        return this._selectedOption;
    }

    set selectedOption(value) {
        this._selectedOption = value;
    }

    @api
    get label() {
        return this._label;
    }

    set label(value) {
        this._label = value;
    }

    @track _recordId = ''; 
    @track _field = '';
    @track _label = '';
    @track _selectedOption = '';
    @track _allOptions = [];

    connectedCallback(){
        this.getOptions();
    }

    handleChange(e) {
        this._selectedOption = e.detail.value;
    }

    getOptions(){
        getPickListValues({ sobj: 'IH_Account_Role_Detail__c' , field: this._field }).then(result => {
            this._allOptions = JSON.parse(JSON.stringify(result));
        });
        
    }

}
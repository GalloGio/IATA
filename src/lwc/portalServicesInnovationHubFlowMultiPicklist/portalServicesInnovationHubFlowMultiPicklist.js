import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';
import Available from '@salesforce/label/c.Available';
import Selected from '@salesforce/label/c.icg_selected';
import ChooseAny from '@salesforce/label/c.CSP_IHub_ChooseAny';

export default class PortalServicesInnovationHubFlowMultiPicklist extends LightningElement {

    labels = { 
        Available, 
        Selected, 
        ChooseAny       
    };

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
    }

    @api
    get field() {
        return this._field;
    }

    set field(value) {
        this._field = value;
    }

    @api
    get selectedOptions() {
        return this._selectedOptions;
    }

    set selectedOptions(value) {
        this._selectedOptions = value;
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
    @track _selectedOptions = '';
    @track _defaultOptions = [];
    @track _allOptions = [];

    connectedCallback(){
        this.getOptions();
        this.convertDefaultOptionsToArray();
    }

    handleChange(e) {
        let auxOptions = e.detail.value;
        this._selectedOptions = auxOptions.join(';');  
    }

    getOptions(){
        getPickListValues({ sobj: 'IH_Account_Role_Detail__c' , field: this._field }).then(result => {
            this._allOptions = JSON.parse(JSON.stringify(result));
        });
        
    }

    convertDefaultOptionsToArray(){
        this._defaultOptions = this._selectedOptions.toString().split(';');      
    }

}
import { LightningElement,track, api } from 'lwc';

//import apex methods
import getLabelPicklistValuesAndSelected from '@salesforce/apex/PortalServicesInnovationHubCtrl.getLabelPicklistValuesAndSelected';

export default class PortalRecordViewEditMultipicklistSelector extends LightningElement {

    @api
    get recordIdInput(){
        return this.recordId;
    }
    set recordIdInput(value){
        this.recordId = value;
    }

    @api
    get objectNameInput(){
        return this.objectName;
    }
    set objectNameInput(value){
        this.objectName = value;
    }

    @api
    get fieldNameInput(){
        return this.fieldName;
    }
    set fieldNameInput(value){
        this.fieldName = value;
    }

    @track picklistProperties = {};
    @track recordId = '';
    @track objectName = '';
    @track fieldName = '';
    @track componentLoading = true;

    connectedCallback(){
        getLabelPicklistValuesAndSelected({objectName : this.objectName, fieldName : this.fieldName, recordId : this.recordId})
        .then(result => {
            this.picklistProperties = JSON.parse(JSON.stringify(result));
            this.componentLoading = false;
        });
    }

    changeOption(event){
        event.preventDefault();

        let selectedCheckbox = event.target.dataset.item;
        let checked = event.target.checked;
        
        let selectedValues = [];
        let picklistPropertiesAux = JSON.parse(JSON.stringify(this.picklistProperties));
        for(let i = 0;i < picklistPropertiesAux.lstPickOptions.length; i++){
            
            if(picklistPropertiesAux.lstPickOptions[i].value === selectedCheckbox){
                picklistPropertiesAux.lstPickOptions[i].checked = checked;
            }

            if(picklistPropertiesAux.lstPickOptions[i].checked === true){
                selectedValues.push(picklistPropertiesAux.lstPickOptions[i].value);
            }
        }
        this.picklistProperties = picklistPropertiesAux;
        
        // Creates the event with the contact ID data.
        let selectedEvent = new CustomEvent('updatemultipickvalue', { detail: {fieldName : this.fieldName, fieldValue : selectedValues.join(';')} });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

}
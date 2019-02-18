import { LightningElement, api, track } from 'lwc';
// import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';
// import FUNCTION_FIELD from '@salesforce/schema/Contact.Function__c';
// import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
// import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
// import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
// import ACCOUNTNAME_FIELD from '@salesforce/schema/Contact.AccountName';
// import ISOCOUNTRY_FIELD from '@salesforce/schema/Contact.ISO_Country__c';
// import EPORTALSTATUS_FIELD from '@salesforce/schema/Contact.User_Portal_Status__c';
// import PHONE_FIELD from '@salesforce/schema/Contact.Phone';

export default class ResetPassword extends LightningElement {
    @api recordId;
    @track options = [
        {value: 'E-commerce', label: 'E-commerce'},
        {value: 'ISS Customer Portal', label: 'ISS Customer Portal'},
        {value: 'CNS Customer Portal', label: 'CNS Customer Portal'},
    ];
    @track selected = [];
    contactFields = ['Salutation', 'Function__c', 'FirstName', 'LastName', 'Email', 'AccountName', 'ISO_Country__c', 'User_Portal_Status__c', 'Phone'];
    passwordFields = ['Community__c'];

    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selected = event.detail.value;
        console.log(this.selected);
    }
    
    sendPassword() {
        console.log(this.selected);
    }
}
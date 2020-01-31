import { LightningElement, api, track } from 'lwc';

import { navigateToPage } from 'c/navigationUtils';

import getAccountInfo                       from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getAccountInfo';
import createIsoCity                        from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.createIsoCity';
import registrationWithNewAccount           from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.registrationWithNewAccount';
import registrationWithExistingAccount      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.registrationWithExistingAccount';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import ISSP_CompanyName      from '@salesforce/label/c.ISSP_CompanyName';

import CSP_L2_Change_Categorization_Warning from '@salesforce/label/c.CSP_L2_Change_Categorization_Warning';
import CSP_L2_Confirmation_Message from '@salesforce/label/c.CSP_L2_Confirmation_Message';
import CSP_L2_Personal_Details from '@salesforce/label/c.CSP_L2_Personal_Details';
import CSP_L2_Personal_Details_Message from '@salesforce/label/c.CSP_L2_Personal_Details_Message';
import CSP_L2_Back_to_Edit from '@salesforce/label/c.CSP_L2_Back_to_Edit';
import CSP_L2_Company_Account from '@salesforce/label/c.CSP_L2_Company_Account';
import CSP_L2_Company_Account_Message from '@salesforce/label/c.CSP_L2_Company_Account_Message';
import CSP_L2_Back_to_Business_Address_Information from '@salesforce/label/c.CSP_L2_Back_to_Business_Address_Information';
import CSP_L2_Submit from '@salesforce/label/c.CSP_L2_Submit';
import CSP_L2_Company_Information from '@salesforce/label/c.CSP_L2_Company_Information';
import CSP_L2_Business_Address_Information from '@salesforce/label/c.CSP_L2_Business_Address_Information';
import CSP_L2_Is_PO_Box_Address from '@salesforce/label/c.CSP_L2_Is_PO_Box_Address';
import CSP_L2_Company_Location from '@salesforce/label/c.CSP_L2_Company_Location';

import CSP_L2_Title from '@salesforce/label/c.CSP_L2_Title';
import CSP_L2_Date_of_Birth from '@salesforce/label/c.CSP_L2_Date_of_Birth';
import CSP_L2_Job_Function from '@salesforce/label/c.CSP_L2_Job_Function';
import CSP_L2_Job_Title from '@salesforce/label/c.CSP_L2_Job_Title';
import CSP_L2_Back_to_Account_Selection from '@salesforce/label/c.CSP_L2_Back_to_Account_Selection';
import CSP_L2_Category from '@salesforce/label/c.CSP_L2_Category';
import CSP_L2_Sector from '@salesforce/label/c.CSP_L2_Sector';
import CSP_L2_Street from '@salesforce/label/c.CSP_L2_Street';
import CSP_L2_PO_Box_Number from '@salesforce/label/c.CSP_L2_PO_Box_Number';
import CSP_L2_Country from '@salesforce/label/c.CSP_L2_Country';
import CSP_L2_Trade_Name from '@salesforce/label/c.CSP_L2_Trade_Name';
import CSP_L2_Legal_Name from '@salesforce/label/c.CSP_L2_Legal_Name';
import CSP_L2_Phone_Number from '@salesforce/label/c.CSP_L2_Phone_Number';
import CSP_L2_Email_Address from '@salesforce/label/c.CSP_L2_Email_Address';
import CSP_L2_Website from '@salesforce/label/c.CSP_L2_Website';
import CSP_L2_State from '@salesforce/label/c.CSP_L2_State';
import CSP_L2_City from '@salesforce/label/c.CSP_L2_City';
import CSP_L2_Postal_Code from '@salesforce/label/c.CSP_L2_Postal_Code';

import CSP_L2_Details_Saved from '@salesforce/label/c.CSP_L2_Details_Saved';
import CSP_L2_Details_Saved_Message from '@salesforce/label/c.CSP_L2_Details_Saved_Message';
import CSP_L2_Details_Saved_Service_Message from '@salesforce/label/c.CSP_L2_Details_Saved_Service_Message';
import CSP_L2_Details_Saved_Topic_Message from '@salesforce/label/c.CSP_L2_Details_Saved_Topic_Message';
import CSP_L2_Go_To_Homepage from '@salesforce/label/c.CSP_L2_Go_To_Homepage';
import CSP_L2_Go_To_Profile from '@salesforce/label/c.CSP_L2_Go_To_Profile';
import CSP_L2_Go_To_Service from '@salesforce/label/c.CSP_L2_Go_To_Service';
import CSP_L2_Go_To_Topic from '@salesforce/label/c.CSP_L2_Go_To_Topic';

import CSP_L2_Registration_Error_Title from '@salesforce/label/c.CSP_L2_Registration_Error_Title';
import CSP_L2_Registration_Error_Message from '@salesforce/label/c.CSP_L2_Registration_Error_Message';
import CSP_L2_Go_Back from '@salesforce/label/c.CSP_L2_Go_Back';
import CSP_L2_Contact_Support from '@salesforce/label/c.CSP_L2_Contact_Support';

export default class PortalRegistrationConfirmation extends LightningElement {
    /* Images */
    successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';
    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';

    @api trigger;
    @api isTriggeredByRequest;
    @api contactInfo;
    @api account;
    @api address;
    @api searchResults;
    @api selectedAccountId;

    selectedAccount;

    @track street;
    @track zip;
    @track city;
    @track state;
    @track selectedAccountFields = [];

    createdCityId;

    @track selectedAccountSet = false;

    @track openSuccessModal = false;
    successModalMessage;
    successModalButton1Label;
    successModalButton2Label;

    @track openErrorModal = false;

    @track isCategorizationModified = false;

    // label variables
    _labels = {
        CSP_L2_Back_to_Account_Selection,
        CSP_L2_Back_to_Business_Address_Information,
        CSP_L2_Back_to_Edit,
        CSP_L2_Business_Address_Information,
        CSP_L2_City,
        CSP_L2_Company_Account,
        CSP_L2_Company_Account_Message,
        CSP_L2_Company_Information,
        CSP_L2_Confirmation_Message,
        CSP_L2_Country,
        CSP_L2_Date_of_Birth,
        CSP_L2_Details_Saved,
        CSP_L2_Details_Saved_Message,
        CSP_L2_Email_Address,
        CSP_L2_Go_To_Homepage,
        CSP_L2_Go_To_Service,
        CSP_L2_Job_Function,
        CSP_L2_Job_Title,
        CSP_L2_Legal_Name,
        CSP_L2_Personal_Details,
        CSP_L2_Personal_Details_Message,
        CSP_L2_Phone_Number,
        CSP_L2_Postal_Code,
        CSP_L2_Is_PO_Box_Address,
        CSP_L2_State,
        CSP_L2_Street,
        CSP_L2_PO_Box_Number,
        CSP_L2_Submit,
        CSP_L2_Title,
        CSP_L2_Trade_Name,
        CSP_L2_Website,
        ISSP_CompanyName,
        CSP_L2_Category,
        CSP_L2_Sector,
        CSP_L2_Change_Categorization_Warning,
        CSP_L2_Registration_Error_Title,
        CSP_L2_Registration_Error_Message,
        CSP_L2_Go_Back,
        CSP_L2_Contact_Support
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    connectedCallback(){

        if(this.trigger === 'homepage'){
            this.successModalMessage = CSP_L2_Details_Saved_Message;
            this.successModalButton1Label = '';
            this.successModalButton2Label = CSP_L2_Go_To_Homepage;
        }
        else if(this.trigger === 'profile'){
            this.successModalMessage = CSP_L2_Details_Saved_Message;
            this.successModalButton1Label = CSP_L2_Go_To_Homepage;
            this.successModalButton2Label = CSP_L2_Go_To_Profile;
        }
        else if(this.trigger === 'service'){
            this.successModalMessage = CSP_L2_Details_Saved_Service_Message;
            this.successModalButton1Label = CSP_L2_Go_To_Homepage;
            this.successModalButton2Label = CSP_L2_Go_To_Service;
        }
        else if(this.trigger === 'topic'){
            this.successModalMessage = CSP_L2_Details_Saved_Topic_Message;
            this.successModalButton1Label = CSP_L2_Go_To_Homepage;
            this.successModalButton2Label = CSP_L2_Go_To_Topic;
        }
    

        if(this.selectedAccountId){
            getAccountInfo({accountId : this.selectedAccountId})
            .then(result => {
                let country = result.IATA_ISO_Country__r.Name;
                
                this.selectedAccount = JSON.parse(JSON.stringify(result));

                this.isCategorizationModified = this.isTriggeredByRequest && (this.selectedAccount.Sector__c !== this.contactInfo.Account.Sector__c || this.selectedAccount.Category__c !== this.contactInfo.Account.Category__c);

                for(let i = 0; i < this.searchResults.wrappedResults.length; i++){
                    if(this.searchResults.wrappedResults[i].isSelected){
    
                        let selectedAcc = [];
    
                        // the first four entries are Account Name, Sector, Category and Street
                        // we must include the country and reorder
                        // If there are additional entries, they go next

                        // 1. Account Name + separator
                        selectedAcc.push({ 'label': this.searchResults.fieldLabels[0], 'value': this.searchResults.wrappedResults[i].fields[0], 'addSeparator' : true });
                        
                        // 2. Street
                        selectedAcc.push({ 'label': this.searchResults.fieldLabels[3], 'value': this.searchResults.wrappedResults[i].fields[3], 'addSeparator' : false });

                        // 3. Country + separator
                        selectedAcc.push({ 'label': CSP_L2_Company_Location, 'value': country, 'addSeparator' : true });

                        // 2. Sector
                        selectedAcc.push({ 'label': this.searchResults.fieldLabels[1], 'value': this.searchResults.wrappedResults[i].fields[1], 'addSeparator' : false });

                        // 3. Category + separator
                        selectedAcc.push({ 'label': this.searchResults.fieldLabels[2], 'value': this.searchResults.wrappedResults[i].fields[2], 'addSeparator' : true });

                        for(let j = 4; j < this.searchResults.fieldLabels.length; j++){
                            selectedAcc.push({ 'label': this.searchResults.fieldLabels[j], 'value': this.searchResults.wrappedResults[i].fields[j], 'addSeparator' : (j%2 === 1) });
                            // insert the country after the street
                            if(j === 3){
                                moduloToInsertSeparator = 0;
                                selectedAcc.push({ 'label': CSP_L2_Company_Location, 'value': country, 'addSeparator' : (j%2 === moduloToInsertSeparator) });
                            }
                        }
                        this.selectedAccountFields = selectedAcc;
                    }
                }

                this.selectedAccountSet = true;
            })
            .catch((error) => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
            });


        }
        else{
            this.street = this.address.street;
            this.zip = this.address.zip;
            this.city = this.address.cityName;
            this.state = this.address.stateName;

            for(let i = 0; i < this.address.addressSuggestions.length; i++){
                if(this.address.addressSuggestions[i].isSelected){
                    this.street = this.address.addressSuggestions[i].street;
                    this.zip = this.address.addressSuggestions[i].postalCode;

                    if(this.address.stateId === ''){
                        this.state = this.address.addressSuggestions[i].province !== undefined? this.address.addressSuggestions[i].province : '';
                        this.city = this.address.addressSuggestions[i].locality !== undefined? this.address.addressSuggestions[i].locality : '';
                    }
                }
            }
        }
        this.dispatchEvent(new CustomEvent('scrolltotop'));
    }

    get isExistingAccountSelected(){
        return this.selectedAccountId !== '';
    }

    startLoading(){
        this.dispatchEvent(new CustomEvent('startloading'));
    }

    stopLoading(){
        this.dispatchEvent(new CustomEvent('stoploading'));
    }

    submit(){
        // The user selected an existing account
        if(this.selectedAccountId != ''){
            this.startLoading();

            let account = { 'sobjectType': 'Account' };
            account.Id = this.selectedAccountId;

            registrationWithExistingAccount({acc : account, con: this.contactInfo})
                .then(result => {
                    if(result == true){
                        this.openSuccessModal = true;
                    }
                    else{
                        this.openErrorModal = true;
                    }
                    this.stopLoading();
                })
                .catch(error => {
                    console.log('Error: ', JSON.parse(JSON.stringify(error)));
                    this.openErrorModal = true;
                    this.stopLoading();
                });
        }
        // If the selectedAccountId is null and the submit method is called, it means that the user is willing to create an account
        else{
   
            this.startLoading();

            // Check first if we need to create a Geoname city
            if(this.address.stateId !== '' && this.address.cityId === ''){
                createIsoCity({name : this.address.cityName, stateId: this.address.stateId, isPoBox: this.address.isPoBox})
                .then(result => {
                    this.createdCityId = result;
                    this.registerNewAccount();
                })
                .catch(error => {
                    console.log('Error: ', JSON.parse(JSON.stringify(error)));
                    this.openErrorModal = true;
                    this.stopLoading();
                });
            }
            else{
                this.registerNewAccount();
            }
        }
    }

    registerNewAccount(){
        // The event data needs to indicate if the creation form is fine. Let's say that if data is null, it means the form is invalid
        // otherwise it should contain the account information

        let account = { 'sobjectType': 'Account' };
        account.Name = this.account.legalName;
        account.Legal_name__c = this.account.legalName;
        account.TradeName__c = this.account.tradeName;
        account.Phone = this.account.phone;
        account.Email__c = this.account.email;
        account.Website = this.account.website;
        account.Sector__c = this.account.customerTypeSector;
        account.Category__c = this.account.customerTypeCategory;

        // business address

        // Street
        if(this.address.isPoBox){
            account.Business_PO_Box__c = this.street;
        }
        else{
            account.Business_Street__c = this.street;
        }
        account.BillingStreet = this.street;
        account.ShippingStreet = this.street;

        // Zip
        account.Business_Postal_Code__c = this.zip;
        account.BillingPostalCode = this.zip;
        account.ShippingPostalCode = this.zip;

        // Country
        account.BillingCountry = this.address.countryName;
        account.ShippingCountry = this.address.countryName;

        account.IATA_ISO_Country__c = this.address.countryId;
        account.IATA_ISO_Shipping_Country__c = this.address.countryId;

        // City and State
        if(this.address.stateId !== ''){
            account.Business_City__c = this.address.cityId !== '' ? this.address.cityId : this.createdCityId;
            account.Business_City_Name__c = this.address.cityName;

            account.Geoname_Billing_City__c = this.address.cityId !== '' ? this.address.cityId : this.createdCityId;
            account.BillingCity = this.address.cityName;
            
            account.Geoname_Shipping_City__c = this.address.cityId !== '' ? this.address.cityId : this.createdCityId;
            account.ShippingCity = this.address.cityName;

            account.Iso_State__c = this.address.stateId;
            
            account.Business_State_Name__c = this.address.stateName;

            account.IATA_ISO_Billing_State__c = this.address.stateId;
            account.BillingState = this.address.stateName;

            account.IATA_ISO_Shipping_State__c = this.address.stateId;
            account.ShippingState = this.address.stateName;
        }
        else{
            account.Business_City_Name__c = this.city;
            account.BillingCity = this.city;
            account.ShippingCity = this.city;

            account.Business_State_Name__c = this.state;
            account.BillingState = this.state;
            account.ShippingState = this.state;
        }

        registrationWithNewAccount({acc: account, con: this.contactInfo})
            .then(result => {
                if(result){
                    this.openSuccessModal = true;
                }
                else{
                    this.openErrorModal = true;
                }
                this.stopLoading();
            })
            .catch(error => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
                this.openErrorModal = true;
                this.stopLoading();
            });
    }

    button1Action(){
        this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactionone'));
    }

    button2Action(){
        this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactiontwo'));
    }

    closeSuccessModal(){
       this.dispatchEvent(new CustomEvent('secondlevelregistrationcompleted'));
    }

    closeErrorModal(){
        this.openErrorModal = false;
    }

    contactSupport(){
        document.body.style.overflow = 'auto';
        let category = 'Platforms';
        let topic = 'Customer_Portal';
        let subtopic = 'Customer_Portal_Support';
        var page = "support-reach-us?tile=question&category=" + category + "&topic=" + topic + "&subtopic=" + subtopic;
        navigateToPage(page);
    }

    toProfileDetails(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'1'}));
    }

    toAccountSelection(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'2'}));
    }

    toCompanyInformation(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'3'}));
    }

    toAddressInformation(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'4'}));
    }
}
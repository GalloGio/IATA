import { LightningElement, api, track } from 'lwc';

import { navigateToPage } from 'c/navigationUtils';

import getAccountInfo                       from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getAccountInfo';
import createIsoCity                        from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.createIsoCity';
import registrationWithNewAccount           from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.registrationWithNewAccount';
import registrationWithExistingAccount      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.registrationWithExistingAccount';
import createNewAccount                     from '@salesforce/apex/AccountCreationCtrl.createNewAccount';
import getCSPortalPath                      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getCSPortalPath';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import CSP_L2_Confirmation_Message from '@salesforce/label/c.CSP_L2_Confirmation_Message';
import CSP_L2_Additional_Details from '@salesforce/label/c.CSP_L2_Additional_Details';
import CSP_L2_Personal_Details_Message from '@salesforce/label/c.CSP_L2_Personal_Details_Message';
import CSP_L2_Back_to_Edit from '@salesforce/label/c.CSP_L2_Back_to_Edit';
import CSP_L2_Company_Account from '@salesforce/label/c.CSP_L2_Company_Account';
import CSP_L2_Company_Account_Message from '@salesforce/label/c.CSP_L2_Company_Account_Message';
import CSP_L2_Back_to_Additional_Details from '@salesforce/label/c.CSP_L2_Back_to_Additional_Details';
import CSP_L2_Back_to_Business_Address_Information from '@salesforce/label/c.CSP_L2_Back_to_Business_Address_Information';
import CSP_L2_Submit from '@salesforce/label/c.CSP_L2_Submit';
import CSP_L2_Company_Information from '@salesforce/label/c.CSP_L2_Company_Information';
import CSP_L2_Business_Address_Information from '@salesforce/label/c.CSP_L2_Business_Address_Information';
import CSP_L2_Is_PO_Box_Address from '@salesforce/label/c.CSP_L2_Is_PO_Box_Address';
import CSP_L2_Work_Location from '@salesforce/label/c.CSP_L2_Work_Location';

import CSP_L2_Title from '@salesforce/label/c.CSP_L2_Title';
import CSP_L2_Job_Function from '@salesforce/label/c.CSP_L2_Job_Function';
import CSP_L2_Job_Title from '@salesforce/label/c.CSP_L2_Job_Title';
import CSP_L2_Back_to_Account_Selection from '@salesforce/label/c.CSP_L2_Back_to_Account_Selection';
import CSP_L2_Category from '@salesforce/label/c.CSP_L2_Category';
import CSP_L2_Sector from '@salesforce/label/c.CSP_L2_Sector';
import CSP_L2_Street from '@salesforce/label/c.CSP_L2_Street';
import CSP_L2_PO_Box_Number from '@salesforce/label/c.CSP_L2_PO_Box_Number';
import CSP_L2_Country from '@salesforce/label/c.CSP_L2_Country';
import CSP_L2_Company_Name from '@salesforce/label/c.CSP_L2_Company_Name';
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
    @track portalPath = CSP_PortalPath;

    /* Images */
    get successIcon(){
        return this.portalPath + 'CSPortal/Images/Icons/youaresafe.png';
    }

    get alertIcon(){
        return this.portalPath + 'CSPortal/alertIcon.png';
    }

    @api trigger;
    @api contactInfo;
    @api account;
    @api address;
    @api searchResults;
    @api selectedAccountId;
    @api internalUser;

    selectedAccount;

    @track street;
    @track zip;
    @track city;
    @track state;
    @track selectedAccountFields = [];

    createdCityId;

    @track selectedAccountSet = false;

    // pop-ups variables
    @track openSuccessModal = false;
    @track openErrorModal = false;
    successModalTitle;
    successModalMessage;
    successModalButton1Label;
    successModalButton2Label;

    accountId;

    // label variables
    _labels = {
        CSP_L2_Back_to_Account_Selection,
        CSP_L2_Back_to_Additional_Details,
        CSP_L2_Back_to_Business_Address_Information,
        CSP_L2_Back_to_Edit,
        CSP_L2_Business_Address_Information,
        CSP_L2_City,
        CSP_L2_Company_Account,
        CSP_L2_Company_Account_Message,
        CSP_L2_Company_Information,
        CSP_L2_Confirmation_Message,
        CSP_L2_Country,
        CSP_L2_Details_Saved,
        CSP_L2_Details_Saved_Message,
        CSP_L2_Go_To_Homepage,
        CSP_L2_Go_To_Service,
        CSP_L2_Job_Function,
        CSP_L2_Job_Title,
        CSP_L2_Additional_Details,
        CSP_L2_Personal_Details_Message,
        CSP_L2_Postal_Code,
        CSP_L2_Is_PO_Box_Address,
        CSP_L2_State,
        CSP_L2_Street,
        CSP_L2_PO_Box_Number,
        CSP_L2_Submit,
        CSP_L2_Title,
        CSP_L2_Website,
        CSP_L2_Company_Name,
        CSP_L2_Category,
        CSP_L2_Sector,
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

    // labels depending on the origin (internal vs portal)
    confirmationMessage;
    companyInformation;
    companyName;
    countryLabel;

    get hasContactInfo(){
        return this.contactInfo !== undefined;
    }

    connectedCallback(){
        // define labels depending on the origin (internal vs portal)
        if(this.internalUser){
            this.confirmationMessage = 'Please check the summary below before submitting.';
            this.companyInformation = 'Account Information';
            this.companyName = 'Account Name';
            this.countryLabel = CSP_L2_Country;
        }
        else{
            this.confirmationMessage = CSP_L2_Confirmation_Message;
            this.companyInformation = CSP_L2_Company_Information;
            this.companyName = CSP_L2_Company_Name;
            this.countryLabel = CSP_L2_Country;
        }

        getCSPortalPath().then(result=>{
            let path = JSON.parse(JSON.stringify(result));

            if(path !== ''){
                this.portalPath = path;
            }
        });


        if(this.selectedAccountId){
            getAccountInfo({accountId : this.selectedAccountId})
            .then(result => {
                let country = result.IATA_ISO_Country__r.Name;
                
                this.selectedAccount = JSON.parse(JSON.stringify(result));

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
                        selectedAcc.push({ 'label': CSP_L2_Work_Location, 'value': country, 'addSeparator': true });

                        // 4. Sector
                        selectedAcc.push({ 'label': this.searchResults.fieldLabels[1], 'value': this.searchResults.wrappedResults[i].fields[1], 'addSeparator' : false });

                        // 5. Category + separator
                        selectedAcc.push({ 'label': this.searchResults.fieldLabels[2], 'value': this.searchResults.wrappedResults[i].fields[2], 'addSeparator' : true });

                        for(let j = 4; j < this.searchResults.fieldLabels.length; j++){
                            selectedAcc.push({ 'label': this.searchResults.fieldLabels[j], 'value': this.searchResults.wrappedResults[i].fields[j], 'addSeparator' : (j%2 === 1) });
                            // insert the country after the street
                            if(j === 3){
                                moduloToInsertSeparator = 0;
                                selectedAcc.push({ 'label': CSP_L2_Work_Location, 'value': country, 'addSeparator' : (j%2 === moduloToInsertSeparator) });
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
        return this.selectedAccountId !== '' && this.selectedAccountId !== undefined;
    }

    startLoading(){
        this.dispatchEvent(new CustomEvent('startloading'));
    }

    stopLoading(){
        this.dispatchEvent(new CustomEvent('stoploading'));
    }

    submit(){
        // The user selected an existing account
        if(this.selectedAccountId !== '' && this.selectedAccountId !== undefined){
            this.startLoading();

            let account = { 'sobjectType': 'Account' };
            account.Id = this.selectedAccountId;

            registrationWithExistingAccount({acc : account, con: this.contactInfo})
                .then(result => {
                let res = JSON.parse(JSON.stringify(result));
                    if(res === true){
                        this.configureAndOpenSuccessModal();
                    }
                    else{
                        this.configureAndOpenErrorModal('Error');
                    }
                    this.stopLoading();
                })
                .catch(error => {
                    this.configureAndOpenErrorModal(error);
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
                    this.configureAndOpenErrorModal(error);
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
        account.Name = this.account.name;
        account.VAT_Number__c = this.account.vatNumber;
        account.Website = this.account.website;
        account.Sector__c = this.account.customerTypeSector;
        account.Category__c = this.account.customerTypeCategory;
        account.Reason_for_creation__c = 'Created by customer';

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

        if(this.hasContactInfo){
	        registrationWithNewAccount({acc: account, con: this.contactInfo})
	            .then(result => {
	                if(result){
	                    this.configureAndOpenSuccessModal();
	                }
                	else{
                    	this.configureAndOpenErrorModal('Error');
                	}
                	this.stopLoading();
            	})
            	.catch(error => {
                	this.configureAndOpenErrorModal(error);
                	this.stopLoading();
            	});	
		}
        else{
            createNewAccount({ acc: account})
                .then(result => {

                    let res = JSON.parse(JSON.stringify(result));
                    if(res.startsWith('accountId')){
                        this.accountId = res.replace('accountId', '');
                        this.configureAndOpenSuccessModal();
                    }
                    else{
                        this.configureAndOpenErrorModal(res);
                    }

                    this.stopLoading();                
                })
                .catch(error => {
                    this.configureAndOpenErrorModal(error);
                    this.stopLoading();
                });            
        }
    }

    configureAndOpenErrorModal(message){
        this.errorModalMessage = message;
        this.openErrorModal = true;    
    }

    configureAndOpenSuccessModal(){
        if(this.hasContactInfo){
            this.successModalTitle = CSP_L2_Details_Saved;

            if (this.trigger === 'homepage') {
                this.successModalMessage = CSP_L2_Details_Saved_Message;
                this.successModalButton1Label = '';
                this.successModalButton2Label = CSP_L2_Go_To_Homepage;
            }
            else if (this.trigger === 'profile') {
                this.successModalMessage = CSP_L2_Details_Saved_Message;
                this.successModalButton1Label = CSP_L2_Go_To_Homepage;
                this.successModalButton2Label = CSP_L2_Go_To_Profile;
            }
            else if (this.trigger === 'service') {
                this.successModalMessage = CSP_L2_Details_Saved_Service_Message;
                this.successModalButton1Label = CSP_L2_Go_To_Homepage;
                this.successModalButton2Label = CSP_L2_Go_To_Service;
            }
            else if (this.trigger === 'topic') {
                this.successModalMessage = CSP_L2_Details_Saved_Topic_Message;
                this.successModalButton1Label = CSP_L2_Go_To_Homepage;
                this.successModalButton2Label = CSP_L2_Go_To_Topic;
            }
        }
        else{
            this.successModalTitle = undefined;
            this.successModalMessage = 'Account created succesfully!';
            this.successModalButton1Label = '';
            this.successModalButton2Label = 'Go to Account';
        }
        this.openSuccessModal = true;
    }

    button1Action(){
        this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactionone'));
    }

    button2Action(){
        if(this.hasContactInfo){
        	this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactiontwo'));
    	}
        else{
            this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactiontwo',{detail : this.accountId}));
        }
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
        var page = "support-reach-us?topic=" + topic;
        navigateToPage(page);
    }

    toAccountSelection(){
        this.dispatchEvent(new CustomEvent('gobackfromconfirmation', { detail: 'accountSelection' }));
    }

    toCompanyInformation(){
        this.dispatchEvent(new CustomEvent('gobackfromconfirmation', { detail: 'companyInformation' }));
    }

    toAddressInformation(){
        this.dispatchEvent(new CustomEvent('gobackfromconfirmation', { detail: 'addressInformation' }));
    }

    toDuplicateCheckTool() {
        this.dispatchEvent(new CustomEvent('gobackfromconfirmation', { detail: 'duplicateCheckTool' }));
    }

    toProfileDetails() {
        this.dispatchEvent(new CustomEvent('gobackfromconfirmation', { detail: 'profileDetails' }));
    }
}
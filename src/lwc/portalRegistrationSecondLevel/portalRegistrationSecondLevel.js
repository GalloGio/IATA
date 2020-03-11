import { LightningElement, track, wire, api} from 'lwc';

import getContactInfo                       from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getCustomerTypeFromSectorAndCategory from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getCustomerTypeFromSectorAndCategory';

import { navigateToPage} from'c/navigationUtils';

//custom labels
import CSP_L2_Banner_Title                  from '@salesforce/label/c.CSP_L2_Banner_Title';
import CSP_L2_Profile_Details               from '@salesforce/label/c.CSP_L2_Profile_Details';
import CSP_L2_Account_Selection             from '@salesforce/label/c.CSP_L2_Account_Selection';
import CSP_L2_Confirmation                  from '@salesforce/label/c.CSP_L2_Confirmation';
import CSP_L2_Profile_Incomplete            from '@salesforce/label/c.CSP_L2_Profile_Incomplete';
import CSP_L2_Profile_Incomplete_Message    from '@salesforce/label/c.CSP_L2_Profile_Incomplete_Message';
import CSP_L2_Yes                           from '@salesforce/label/c.CSP_L2_Yes';
import CSP_L2_No                            from '@salesforce/label/c.CSP_L2_No';
import CSP_PortalPath                       from '@salesforce/label/c.CSP_PortalPath';

export default class PortalRegistrationSecondLevel extends LightningElement {
    /* Images */
    youAreSafeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';
    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';
    homeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_home.png';
    crossIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_cross.png';
    stepCheckedLogo = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_valid.png';
    step1ActiveLogo = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_1_active.png';
    step2ActiveLogo = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_2_active.png';
    step2InactiveLogo = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_2_inactive.png';
    step3ActiveLogo = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_3_active.png';
    step3InactiveLogo = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_3_inactive.png';

    @api trigger;
    @api isTriggeredByRequest = false;

    @track openMessageModal = false;


    get accountSelectionLogo(){
        // If account selection is complete, we display the check mark logo
        if(this.step1Complete || (this.step2Complete && this.step3Complete)){
            return this.stepCheckedLogo;
        }
        // Otherwise, it means that we're in the Account Selection step and we display the "step 1" active logo
        return this.step1ActiveLogo;
    }

    get additionalDetailsLogo(){
        // If account selection is not complete, we can't reach the Additional Details step
        // and we display the "step 2" inactive logo
        if(!(this.step1Complete || (this.step2Complete && this.step3Complete))){
            return this.step2InactiveLogo;
        }

        // If we are in step 1 (Account Search), 2 (Company Information) or 3 (Address Information), we can
        // reach the Additional Details step and we display the "step 2" active logo
        if(this.currentStep === 1 || this.currentStep === 2 || this.currentStep === 3){
            return this.step2ActiveLogo;
        }

        // If we are in step 4 (Additional Details)
        if(this.currentStep === 4){
            // If the step is complete, we display the check mark logo
            if(this.step4Complete){
                return this.stepCheckedLogo;
            }
            // Otherwise, we display the "step 2" active logo
            else{
                return this.step2ActiveLogo;
            }
        }

        // Last case: we are in the confirmation page, we display the check mark logo
        return this.stepCheckedLogo;
    }

    get confirmationLogo(){
        // If account selection or additional information is not complete, we can't reach the Confirmation step
        // and we display the "step 3" inactive logo
        if(!(this.step1Complete || (this.step2Complete && this.step3Complete)) || !this.step4Complete){
            return this.step3InactiveLogo;
        }

        // If we are in step 1 (Account Search), 2 (Company Information), 3 (Address Information) or 4 (Additional Details) we can
        // reach the Confirmation step and we display the "step 3" active logo
        if(this.currentStep === 1 || this.currentStep === 2 || this.currentStep === 3 || this.currentStep === 4){
            return this.step3ActiveLogo;
        }

        // Last case: we are in the confirmation page, we display the check mark logo
        return this.stepCheckedLogo;
    }

    get accountSelectionTitleCssClass(){
        var css = "itemTitle";
        
        if(this.isAccountSelectionReachable){
            css += " itemClickable";
        }
        
        if(this.currentStep === 1 || this.currentStep === 2 || this.currentStep === 3){
            css += " currentStep";
        }

        return css;
    }

    get additionalDetailsTitleCssClass(){
        var css = "itemTitle";
        
        if(this.isAdditionalDetailsReachable){
            css += " itemClickable";
        }
        
        if(this.currentStep === 4){
            css += " currentStep";
        }

        return css;
    }

    get confirmationTitleCssClass(){
        var css = "itemTitle";
        
        if(this.isConfirmationReachable){
            css += " itemClickable";
        }
        
        if(this.currentStep === 5){
            css += " currentStep";
        }

        return css;
    }

    get accountSelectionLogoCssClass(){
        if(this.accountSelectionLogo === this.stepCheckedLogo){
            return "checkedIcon";
        }
        else{
            return "uncheckedIcon";
        }
    }

    get additionalDetailsLogoCssClass(){
        if(this.additionalDetailsLogo === this.stepCheckedLogo){
            return "checkedIcon";
        }
        else{
            return "uncheckedIcon";
        }
    }

    get confirmationLogoCssClass(){
        if(this.confirmationLogo === this.stepCheckedLogo){
            return "checkedIcon";
        }
        else{
            return "uncheckedIcon";
        }
    }

    get isAccountSelectionReachable(){
        // Account Selection step is reachable if the current step is Additional Details or Confirmation
        return this.currentStep === 4 || this.currentStep === 5;
    }

    get isAdditionalDetailsReachable(){
        // Additional Details step is reachable if it's not the current step and if the Account Selection step is complete
        return this.currentStep !== 4 && (this.step1Complete || (this.step2Complete && this.step3Complete));
    }

    get isConfirmationReachable(){
        // Confirmation step is reachable if it's not the current step if Account Selection and Additional Details steps are complete
        return this.currentStep !== 5 && (this.step1Complete || (this.step2Complete && this.step3Complete)) && this.step4Complete;
    }

    /*
        1 : Account Selection
        2 : Account Creation - Company Information
        3 : Account Creation - Address Information
        4 : Profile Details
        5 : Confirmation
    */
   @track currentStep = 0;

   @track isLoading = false;

    // Collected information
    selectedAccountId = '';
    selectedCountryId;
    selectedCustomerType;
    searchResults;
    address = {
        'isPoBox':false,
        'countryId':'',
        'countryCode':'',
        'countryName':'',
        'stateId':'',
        'stateName':'',
        'cityId':'',
        'cityName':'',
        'street':'',
        'zip':'',
        'validationStatus':0,
        'checkPerformed':false,
        'inputModified':true,
        'geonameWarning1':'',
        'geonameWarning2':'',
        'addressSuggestions':[]
    };

    account = {
        'name':'',
        'website':'',
        'customerType':'',
        'customerTypeSector':'',
        'customerTypeCategory':'',
        'sector':'',
        'category':''
    };

    @track contactInfo;
    @track contactFound;

    landingPage;

    // customer type variables
    originalCustomerType;
    @track selectedMetadataCustomerType;
    @track isCustomerTypeGeneralPublic;

    // label variables
    _labels = {
        CSP_L2_Banner_Title,
        CSP_L2_Profile_Details,
        CSP_L2_Account_Selection,
        CSP_L2_Confirmation,
        CSP_L2_Profile_Incomplete,
        CSP_L2_Profile_Incomplete_Message,
        CSP_L2_Yes,
        CSP_L2_No
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    scrollToTop(){
        let scrollobjective = this.template.querySelector('[data-name="top"]');
        scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
    }

    connectedCallback() {
        // hide page scrollbar to prevent having 2 scrollbars
        document.body.style.overflow = 'hidden';

        // Retrieve Contact information
        getContactInfo()
            .then(result => {
                this.contactInfo = result;
                this.contactInfo.salutationNotSet = this.contactInfo.Salutation === '' || this.contactInfo.Salutation === null || this.contactInfo.Salutation === undefined;
                this.contactFound = this.contactInfo != null;

                if(!this.contactFound){
                    return;
                }

                // set up cached data
                var countryName = this.contactInfo.Account.IATA_ISO_Country__r.Name;
                if(countryName.toLowerCase() === 'no country'){
                    this.selectedCountryId = '';
                }
                else{
                    this.selectedCountryId = this.contactInfo.Account.IATA_ISO_Country__r.Id;
                }

                if(this.contactInfo.Title == undefined){
                    this.contactInfo.Title = null;
                }

                if(this.contactInfo.Account.Sector__c === 'General Public'){
                    this.selectedCustomerType = '';
                    this.originalCustomerType = '';
                    this.currentStep = 1;
                }
                else{
                    getCustomerTypeFromSectorAndCategory({sector : this.contactInfo.Account.Sector__c, category : this.contactInfo.Account.Category__c})
                    .then(result => {
                        this.selectedCustomerType = result;
                        this.originalCustomerType = result;
                        this.currentStep = 1;
                    });
                }
            });
        }

    startLoading(){
        this.isLoading = true;
    }

    stopLoading(){
        this.isLoading = false;
    }

    cancel(){
        this.dispatchEvent(
            new CustomEvent('closesecondlevelregistration')
        );
    }


    /* NAVIGATION METHODS */

    @track step1Complete = false;
    @track step2Complete = false;
    @track step3Complete = false;
    @track step4Complete = false;

    step1CompletionStatus(event){
        this.step1Complete = event.detail;
    }

    step2CompletionStatus(event){
        this.step2Complete = event.detail;
    }

    step3CompletionStatus(event){
        this.step3Complete = event.detail;
    }

    step4CompletionStatus(event){
        this.step4Complete = event.detail;
    }

    getCurrentStepData(futureStep){
        // Account Selection
        if(this.currentStep === 1){
            var accountSelectionInfos = this.template.querySelector('c-portal-registration-account-selection').getAccountSelectionInfos();

            this.selectedCustomerType = accountSelectionInfos.get('customerType');
            this.selectedCountryId = accountSelectionInfos.get('countryId');
            this.selectedAccountId = accountSelectionInfos.get('accountId');
    
            var searchResults = this.template.querySelector('c-portal-registration-account-selection').getSearchResults();
            
            if(searchResults !== undefined){
                this.searchResults = JSON.parse(JSON.stringify(searchResults));
            }
            this.currentStep = futureStep;
        }
        // Company Information
        else if(this.currentStep === 2){
            var companyInformation= this.template.querySelector('c-portal-registration-company-information').getCompanyInformation();

            this.account = JSON.parse(JSON.stringify(companyInformation));
            this.selectedCustomerType = companyInformation.customerType;    
            this.currentStep = futureStep;
        }
        // Address Information
        else if(this.currentStep === 3){
            var addressInformation = this.template.querySelector('c-portal-registration-address-information').getAddressInformation();
            this.address = JSON.parse(JSON.stringify(addressInformation));
            this.currentStep = futureStep;
        }
        // Profile Details
        else if(this.currentStep === 4){
            var contactInfo = this.template.querySelector('c-portal-registration-profile-details').getContactInfo();
            this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
            this.currentStep = futureStep;
        }
        // Confirmation
        else if(this.currentStep === 5){
            this.currentStep = futureStep;
        }
    }

    goToAccountSelection(){
        this.getCurrentStepData(1);
    }

    goToCompanyInformation(){
        this.getCurrentStepData(2);
    }

    goToAddressInformation(){
        this.getCurrentStepData(3);
    }

    goToProfileDetails(){
        this.getCurrentStepData(4);
    }

    goToConfirmation(){
        this.getCurrentStepData(5);
    }

    goBackFromProfileDetails(){
        if(this.selectedAccountId !== '' && this.selectedAccountId !== null){
            this.getCurrentStepData(1);
        }
        else{
            this.getCurrentStepData(3);
        }
    }

    goBackFromConfirmation(event){
        var detail = event.detail;

        if(detail === 'accountSelection'){
            this.getCurrentStepData(1);
        }
        else if(detail === 'companyInformation'){
            this.getCurrentStepData(2);
        }
        else if(detail === 'addressInformation'){
            this.getCurrentStepData(3);
        }
        else if(detail === 'profileDetails'){
            this.getCurrentStepData(4);
        }
    }

    get isAccountSelectionStep(){
        return this.currentStep === 1;
    }

    get isCompanyInformationStep(){
        return this.currentStep === 2;
    }

    get isAddressInformationStep(){
        return this.currentStep === 3;
    }

    get isProfileInformationStep(){
        return this.currentStep === 4;
    }

    get isConfirmationStep(){
        return this.currentStep === 5;
    }

    get isAccountStep(){
        return this.currentStep === 1 || this.currentStep === 2 || this.currentStep === 3;
    }

    openClosePopup(){
        this.landingPage = 'same';
        this.openMessageModal = true;
    }

    openGoToHomePopup(){
        this.landingPage = 'homepage';
        this.openMessageModal = true;
    }

    cancel(){
        this.openMessageModal = false;
    }

    close(){
        this.openMessageModal = false;
        if(this.landingPage == 'same'){
            document.body.style.overflow = 'auto';
            this.dispatchEvent(new CustomEvent('closesecondlevelregistration'));
        }
        else if(this.landingPage == 'homepage'){
            navigateToPage(CSP_PortalPath,{});
        }
    }

    secondLevelRegistrationCompletedAction1(){
        document.body.style.overflow = 'auto';
        this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactionone'));
    }

    secondLevelRegistrationCompletedAction2(){
        document.body.style.overflow = 'auto';
        this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactiontwo'));
    }
}
import { LightningElement, track, wire, api} from 'lwc';

import getContactInfo                       from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import saveContactInfo                      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.saveContactInfo';
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

    // Banner logo and links getters
    get step1Logo(){
        if(this.step1Complete){
            return this.stepCheckedLogo;
        }
        else{
            return this.step1ActiveLogo;
        }
    }

    get isStep1LogoChecked(){
        return this.step1Logo === this.stepCheckedLogo;
    }

    get hasStep1Link(){
        return this.currentStep !== 1;
    }

    get step2Logo(){
        if(this.step2Complete){
            return this.stepCheckedLogo;
        }
        if(this.step1Complete && this.step3Complete && this.step4Complete && this.currentStep !== 2){
            return this.stepCheckedLogo;
        }
        if(this.currentStep === 1){
            return this.step2InactiveLogo;
        }
        return this.step2ActiveLogo;
    }

    get isStep2LogoChecked(){
        return this.step2Logo === this.stepCheckedLogo;
    }

    get hasStep2Link(){
        if(this.currentStep === 2 || this.currentStep === 3 || this.currentStep === 4){
            return false;
        }
        if(this.currentStep === 5 || (this.currentStep === 1 && this.step1Complete)){
            return true;
        }
        return false;
    }

    get step2Link(){
        if(!this.hasStep2Link){
            return this.currentPage;
        }
        if(this.step2Complete || !this.step3Complete){
            return 2;
        }
        return 3;
    }

    get step3Logo(){
        if(this.currentStep === 5){
            return this.step3ActiveLogo;
        }
        if(this.step1Complete && (this.step2Complete || (this.step3Complete && this.step4Complete))){
            return this.stepCheckedLogo;
        }
        return this.step3InactiveLogo;
    }

    get isStep3LogoChecked(){
        return this.step3Logo === this.stepCheckedLogo;
    }

    get hasStep3Link(){
        return this.step3Logo === this.stepCheckedLogo;
    }

    goToProfileDetailsFromBanner(){
        this.getCurrentStepData();
        this.currentStep = 1;
    }

    goToAccountSelectionFromBanner(){
        this.getCurrentStepData();
        this.currentStep = this.step2Link;
    }

    goToConfirmationFromBanner(){
        this.getCurrentStepData();
        this.currentStep = 5;
    }

    /*
        1 : Profile Details
        2 : Account Selection
        3 : Account Creation - Company Information
        4 : Account Creation - Address Information
        5 : Confirmation
    */
   @track currentStep = 1;

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
        'legalName':'',
        'tradeName':'',
        'phone':'',
        'email':'',
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
                }
                else{
                    getCustomerTypeFromSectorAndCategory({sector : this.contactInfo.Account.Sector__c, category : this.contactInfo.Account.Category__c})
                    .then(result => {
                        this.selectedCustomerType = result;
                        this.originalCustomerType = result;
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

    getCurrentStepData(){
        // Profile Details
        if(this.currentStep === 1){
            var contactInfo = this.template.querySelector('c-portal-registration-profile-details').getContactInfo();
            this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
        }
        // Account Selection
        else if(this.currentStep === 2){
            var accountSelectionInfos = this.template.querySelector('c-portal-registration-account-selection').getAccountSelectionInfos();

            this.selectedCustomerType = accountSelectionInfos.get('customerType');
            this.selectedCountryId = accountSelectionInfos.get('countryId');
            this.selectedAccountId = accountSelectionInfos.get('accountId');
    
            var searchResults = this.template.querySelector('c-portal-registration-account-selection').getSearchResults();
            
            if(searchResults !== undefined){
                this.searchResults = JSON.parse(JSON.stringify(searchResults));
            }
        }
        // Company Information
        else if(this.currentStep === 3){
            var companyInformation= this.template.querySelector('c-portal-registration-company-information').getCompanyInformation();

            this.account = JSON.parse(JSON.stringify(companyInformation));
            this.selectedCustomerType = companyInformation.customerType;    
        }
        // Address Information
        else if(this.currentStep === 4){
            var addressInformation = this.template.querySelector('c-portal-registration-address-information').getAddressInformation();
            this.address = JSON.parse(JSON.stringify(addressInformation));
        }
    }

    goToStep(event){
        var futureStep = parseInt(event.detail);
        this.getCurrentStepData();
        this.currentStep = futureStep;
    }

    get isProfileInformationStep(){
        return this.currentStep === 1;
    }

    get isAccountSelectionStep(){
        return this.currentStep === 2;
    }

    get isCompanyInformationStep(){
        return this.currentStep === 3;
    }

    get isAddressInformationStep(){
        return this.currentStep === 4;
    }

    get isConfirmationStep(){
        return this.currentStep === 5;
    }

    get isAccountStep(){
        return this.currentStep === 2 || this.currentStep === 3 || this.currentStep === 4;
    }

    openSaveAndClosePopup(){
        this.setSaveAndClosePopup('same');
    }

    openSaveAndGoToHomePopup(){
        this.setSaveAndClosePopup('homepage');
    }

    setSaveAndClosePopup(page){
        this.startLoading();
        if(this.isProfileInformationStep){
            // retrieve profile details
            var contactInfo = this.template.querySelector('c-portal-registration-profile-details').getContactInfo();
            this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
        }

        //save contact info
        saveContactInfo({con : this.contactInfo})
        .then(result => {
            this.landingPage = page;
            this.openMessageModal = true;
            this.stopLoading();
        });
    }

    cancel(){
        this.openMessageModal = false;
    }

    saveAndClose(){
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
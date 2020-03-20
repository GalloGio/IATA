import { LightningElement, track, api  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';

/* APEX METHODS */
import getUIThemeDescription from '@salesforce/apex/AccountCreationCtrl.getUIThemeDescription';

/* STATIC RESOURCES */
import cspStylesheet    from '@salesforce/resourceUrl/CSP_Stylesheet';

export default class AccountCreation extends NavigationMixin(LightningElement) {

    /*
        1 : Account Selection
        2 : Account Creation - Company Information
        3 : Account Creation - Address Information
        4 : Confirmation
    */
	@track currentStep = 0;
	@track step1Complete = false;
    @track step2Complete = false;
    @track step3Complete = false;
    @track step3CompleteBackup = false;

    retUrl;

	get isAccountSelectionStep(){
        return this.currentStep === 1;
    }

    get isCompanyInformationStep(){
        return this.currentStep === 2;
    }

    get isAddressInformationStep(){
        return this.currentStep === 3;
    }

    get isConfirmationStep(){
        return this.currentStep === 4;
	}
	
    // Collected information
    selectedCustomerType = '';
    selectedCountryId = '';
	selectedAccountId = '';
	accountId;
	searchResults;
    account = {
        'name':'',
        'website':'',
        'customerType':'',
        'customerTypeSector':'',
        'customerTypeCategory':'',
        'sector':'',
        'category':'',
        'vatLabel':'',
        'vatNumber':''
    };
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
    @track countryModifiedInCompanyInformation = false;

	@track isLoading = false;

    connectedCallback() {
        loadStyle(this, cspStylesheet)
        .then(() => {
            console.log('CSP Stylesheet loaded.');
        });

        let pageParams = getParamsFromPage();
        if(pageParams !== undefined){
            if(pageParams.retURL !== undefined){
                this.retUrl = decodeURIComponent(pageParams.retURL);
            }
        }
		this.currentStep = 1;
	}

    scrollToTop(){
        let scrollobjective = this.template.querySelector('[data-name="top"]');
        scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
    }

	/* NAVIGATION METHODS */
    step1CompletionStatus(event){
        this.step1Complete = event.detail;
    }

    step2CompletionStatus(event){
        this.step2Complete = event.detail;

        // Retrieve the country Information
        var addressInformation = this.template.querySelector('c-portal-registration-company-information').getAddressInformation();
        let retrievedAddress = JSON.parse(JSON.stringify(addressInformation));

        // Compare with the current country in the address variable
        // if the country is different, we need to flag the step 3 as incomplete,
        // but we're keeping track of the old value in the step3CompleteBackup variable
        this.countryModifiedInCompanyInformation = retrievedAddress.countryId !== this.address.countryId;
        this.step3Complete = this.step3CompleteBackup && !this.countryModifiedInCompanyInformation;
    }

    step3CompletionStatus(event){
        this.step3Complete = event.detail;
        this.step3CompleteBackup = event.detail;
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

            var addressInformation = this.template.querySelector('c-portal-registration-company-information').getAddressInformation();
            let retrievedAddress = JSON.parse(JSON.stringify(addressInformation));

            // If country has been modified, the address information step becomes invalid
            if(this.address.countryId !== retrievedAddress.countryId){
                this.address.isPoBox = false;
                this.address.countryId = retrievedAddress.countryId;
                this.address.countryCode = retrievedAddress.countryCode;
                this.address.countryName = retrievedAddress.countryName;
                this.address.stateId = '';
                this.address.stateName = '';
                this.address.cityId = '';
                this.address.cityName = '';
                this.address.street = '';
                this.address.zip = '';
                this.address.validationStatus = 0;
                this.address.checkPerformed = false;
                this.address.inputModified = true;
                this.address.geonameWarning1 = '';
                this.address.geonameWarning2 = '';
                this.address.addressSuggestions = [];
            }

            this.currentStep = futureStep;
        }
        // Address Information
        else if(this.currentStep === 3){
            var addressInformation = this.template.querySelector('c-portal-registration-address-information').getAddressInformation();
            this.address = JSON.parse(JSON.stringify(addressInformation));
			this.currentStep = futureStep;
        }
        // Confirmation
        else if(this.currentStep === 4){
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

    goToConfirmation(){
        this.getCurrentStepData(4);
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
    }

	navigateToAccount(event){
		this.accountId = JSON.parse(JSON.stringify(event.detail));

		getUIThemeDescription()
		.then(result => {
			let baseURL = window.location.origin;

			// classic
			if(result === 'Theme1' || result === 'Theme2' || result === 'Theme3'){
				let fullPathClassic = baseURL +  '/' + this.accountId;
				window.location.href = fullPathClassic;
			}
			// lightning
			else {
				this[NavigationMixin.GenerateUrl]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.accountId,
						actionName: 'view'
					},
				}).then(url => {
					let fullPath = baseURL + url;
					window.location.href = fullPath;
				});
			}			
		});
    }

	cancel(){
		getUIThemeDescription()
		.then(result => {
			if(result === 'Theme1' || result === 'Theme2' || result === 'Theme3'){
                let baseURL = window.location.origin;
                window.location.href = baseURL + this.retUrl;
			} else {
				window.history.go(-1);
			}
		});
	}

    startLoading(){
        this.isLoading = true;
    }

    stopLoading(){
        this.isLoading = false;
    }
}
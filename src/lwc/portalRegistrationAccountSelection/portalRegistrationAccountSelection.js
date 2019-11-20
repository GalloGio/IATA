import { LightningElement, track, api} from 'lwc';

import getISOCountries              from '@salesforce/apex/GCS_RegistrationController.getISOCountries';
import getCustomerTypePicklists     from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getCustomerTypePicklistsForL2';
import getMetadataCustomerType      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getMetadataCustomerTypeForL2';
import searchAccounts               from '@salesforce/apex/GCS_RegistrationController.searchAccounts';

//custom labels
import CSP_L2_Account_Selection_Message from '@salesforce/label/c.CSP_L2_Account_Selection_Message';
import CSP_L2_Account_Information from '@salesforce/label/c.CSP_L2_Account_Information';
import CSP_L2_Account_Information_Message from '@salesforce/label/c.CSP_L2_Account_Information_Message';
import CSP_L2_Sector from '@salesforce/label/c.CSP_L2_Sector';
import CSP_L2_Category from '@salesforce/label/c.CSP_L2_Category';
import CSP_L2_IATA_Codes from '@salesforce/label/c.CSP_L2_IATA_Codes';
import CSP_L2_Company_Location from '@salesforce/label/c.CSP_L2_Company_Location';
import CSP_L2_Back_to_Profile_Details from '@salesforce/label/c.CSP_L2_Back_to_Profile_Details';
import CSP_L2_Search from '@salesforce/label/c.CSP_L2_Search';
import CSP_L2_Search_Results from '@salesforce/label/c.CSP_L2_Search_Results';
import CSP_L2_Select from '@salesforce/label/c.CSP_L2_Select';
import CSP_L2_Select_Company_Message from '@salesforce/label/c.CSP_L2_Select_Company_Message';
import CSP_L2_Search_Results_Above_Limit from '@salesforce/label/c.CSP_L2_Search_Results_Above_Limit';
import CSP_L2_Search_Results_Above_Limit_Link_1 from '@salesforce/label/c.CSP_L2_Search_Results_Above_Limit_Link_1';
import CSP_L2_Search_Results_Above_Limit_Link from '@salesforce/label/c.CSP_L2_Search_Results_Above_Limit_Link';
import CSP_L2_Search_Results_Above_Limit_Link_2 from '@salesforce/label/c.CSP_L2_Search_Results_Above_Limit_Link_2';
import CSP_L2_Did_Not_Find from '@salesforce/label/c.CSP_L2_Did_Not_Find';
import CSP_L2_Did_Not_Find_Message from '@salesforce/label/c.CSP_L2_Did_Not_Find_Message';
import CSP_L2_Create_Account_Message from '@salesforce/label/c.CSP_L2_Create_Account_Message';
import CSP_L2_Create_New_Account from '@salesforce/label/c.CSP_L2_Create_New_Account';
import CSP_L2_Next_Confirmation from '@salesforce/label/c.CSP_L2_Next_Confirmation';
import CSP_L2_Company_Name from '@salesforce/label/c.CSP_L2_Company_Name';
import CSP_L2_No_Matching_Results from '@salesforce/label/c.CSP_L2_No_Matching_Results';
import CSP_L2_Required from '@salesforce/label/c.CSP_L2_Required';
import CSP_PortalPath                   from '@salesforce/label/c.CSP_PortalPath';
import CSP_L2_Search_Message from '@salesforce/label/c.CSP_L2_Search_Message';
import CSP_L2_Change_Categorization_Warning from '@salesforce/label/c.CSP_L2_Change_Categorization_Warning';

export default class PortalRegistrationAccountSelection extends LightningElement {
    /* Images */
    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';
    arrowFirst = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-first.png';
    arrowFirstLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-first-lightgrey.png';
    arrowPrevious = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-prev.png';
    arrowPreviousLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-prev-lightgrey.png';
    arrowNext = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-next.png';
    arrowNextLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-next-lightgrey.png';
    arrowLast = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-last.png';
    arrowLastLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-last-lightgrey.png';

    @api customerType;
    @api countryId;
    @api accountId;
    @api isTriggeredByRequest;
    @api searchResults;

    // categorization
    @track customerTypesList;
    @track isOtherPicklistDisplayed = false;
    @track firstCategorizationPicklist;
    @track secondCategorizationPicklist;
    @track thirdCategorizationPicklist;
    @track atLeastTwoPicklists = false;
    @track threePicklists = false;

    // search variables
    max = 50;
    get tooManyResults(){
        if(this.localSearchResults !== undefined){
            return this.localSearchResults.totalAccounts > this.localSearchResults.wrappedResults.length;
        }
        return false;
    }

    // country variables
    @track localCountryId;

    /* Picklist options */
    @track isoCountriesPicklistOptions;

    // customer type variables
    @track selectedCustomerType;
    @track selectedCustomerTypeMetadata;
    @track isCategorizationSearchable;
    @track isIataCodeSearchDisabled;
    fakeCategoryPicklist;

    @track selectedAccountId;

    @track accountNotSelected;

    checkCompletion(){
        var currentCompletionStatus = this.accountNotSelected;

        this.accountNotSelected = this.selectedAccountId === '';

        if(this.accountNotSelected !== currentCompletionStatus){
            this.dispatchEvent(new CustomEvent('completionstatus',{detail : !this.accountNotSelected}));
        }
    }


    // search inputs
    @track iataCodeInput = '';
    @track accountNameInput ='';

    get isSearchDisabled(){
        return !this.isCategorizationSearchable || (this.iataCodeInput.length < 2 && this.accountNameInput.length < 3) || this.localCountryId === '' || !this.inputModified;
    }

    // flag to warn user requesting access to a service/topic
    @track isCategorizationModified = false;
    
    //search results variables
    @track localSearchResults;
    @track resultsToDisplay;
    resultsPerPage = 10;
    @track currentPage = 1;
    @track pageNumbersBeforeCurrent;
    @track pageNumbersAfterCurrent;

    get accountFounds(){
        return this.localSearchResults !== undefined && this.localSearchResults.wrappedResults.length > 0;
    }

    get numberOfFields(){
        if(this.localSearchResults === undefined){
            return 0;
        }
        return this.localSearchResults.fieldLabels.length;        
    }

    @track inputModified = true;

    get searchPerformed(){
        return this.localSearchResults !== undefined;
    }

    // label variables
    get searchResultsAboveLimitLink_1(){
        return CSP_L2_Search_Results_Above_Limit_Link_1 === '--empty--' ? '' : CSP_L2_Search_Results_Above_Limit_Link_1 + ' '; 
    }

    get searchResultsAboveLimitLink_2(){
        return CSP_L2_Search_Results_Above_Limit_Link_2 === '--empty--' ? '' : ' ' + CSP_L2_Search_Results_Above_Limit_Link_2;
    }

    _labels = {
        CSP_L2_Account_Selection_Message,
        CSP_L2_Account_Information,
        CSP_L2_Account_Information_Message,
        CSP_L2_Sector,
        CSP_L2_Category,
        CSP_L2_Company_Name,
        CSP_L2_IATA_Codes,
        CSP_L2_Company_Location,
        CSP_L2_Back_to_Profile_Details,
        CSP_L2_Search,
        CSP_L2_Search_Results,
        CSP_L2_Select_Company_Message,
        CSP_L2_Search_Results_Above_Limit,
        CSP_L2_Search_Results_Above_Limit_Link,
        CSP_L2_Select,
        CSP_L2_Create_Account_Message,
        CSP_L2_Create_New_Account,
        CSP_L2_Next_Confirmation,
        CSP_L2_Did_Not_Find,
        CSP_L2_Did_Not_Find_Message,
        CSP_L2_No_Matching_Results,
        CSP_L2_Required,
        CSP_L2_Search_Message,
        CSP_L2_Change_Categorization_Warning
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }
    
    performingSearch = false;
    
    renderedCallback(){
        if(this.performingSearch){
            let scrollobjective = this.template.querySelector('[data-name="searchDiv"]');
            scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
            this.performingSearch = false;
        }
    }

    connectedCallback() {
        this.startLoading();
        //if(this.customerType === 'Student' || this.customerType === 'General_Public_Category'){
        if(this.customerType === ''){
            this.setCustomerType(null);
        }
        else{
            this.setCustomerType(this.customerType);
        }

        this.fakeCategoryPicklist = [];

        this.localCountryId = this.countryId;
        this.selectedAccountId = this.accountId;
        this.checkCompletion();

        if(this.searchResults !== undefined){
            this.localSearchResults = JSON.parse(JSON.stringify(this.searchResults));
            this.generateResultsToDisplay(true);
        }

        // Retrieve Iso Countries list
        // Pre-select country of Contact's Account
        getISOCountries()
            .then(result => {
                var countriesList = [];

                countriesList.push({
                    label: '',
                    value: ''
                });
                
                for (var i = 0; i < result.countryList.length; i++) {
                    countriesList.push({
                        label: result.countryList[i].Name,
                        value: result.countryList[i].Id
                    });
                }
                this.isoCountriesPicklistOptions = countriesList;
                this.dispatchEvent(new CustomEvent('scrolltotop'));
            })
            .catch((error) => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
                this.dispatchEvent(new CustomEvent('scrolltotop'));
            });

    }

    /* Events handler methods */
    setCustomerType(customerType){
        this.selectedCustomerType = customerType;

        // Retrieve customer type
        if(customerType != null){
            getMetadataCustomerType({customerTypeKey:this.selectedCustomerType})
                .then(result => {
                    this.selectedCustomerTypeMetadata = result;
                    this.isCategorizationSearchable = this.selectedCustomerTypeMetadata != null && this.selectedCustomerTypeMetadata.Search_Option__c === 'User Search';
                    this.isIataCodeSearchDisabled = this.selectedCustomerTypeMetadata === null 
                                                    || ((this.selectedCustomerTypeMetadata.Fields_Targeted_Partial_Match__c === undefined 
                                                            || this.selectedCustomerTypeMetadata.Fields_Targeted_Partial_Match__c === '')  
                                                        && (this.selectedCustomerTypeMetadata.Fields_Targeted_Exact_Match__c === undefined 
                                                            || this.selectedCustomerTypeMetadata.Fields_Targeted_Exact_Match__c === null));

                    if(this.isIataCodeSearchDisabled){
                        this.iataCodeInput = '';
                    }

                    // if user is requesting access to a service or a topic, he must be warned in case he select a categorization different than the one of his GP account
                    // we first check that the category has been selected
                    if(this.isTriggeredByRequest){
                        // then we check if the sector-category combination is different than the bucket account's one
                        this.isCategorizationModified = this.selectedCustomerTypeMetadata.DeveloperName !== this.customerType && this.isCategorizationSearchable;
                    }
                })
                .catch((error) => {
                    console.log('Error: ', JSON.parse(JSON.stringify(error)));
                });
        }
        else{
            this.isCategorizationSearchable = false;
            this.isIataCodeSearchDisabled = true;
            this.iataCodeInput = '';
        }

        // Update customer type picklists
        getCustomerTypePicklists({leaf:this.selectedCustomerType})
            .then(result => {
                this.customerTypesList = [];
                this.isOtherPicklistDisplayed = false;

                var arrayLength = result.length;
                for (var i = 0; i < arrayLength; i++) {
                    var selectedOption;
                    var customerTypesOptions = [];
                    
                    for(var j = 0; j < result[i].picklistOptions.length; j++){
                        // replace placeholders labels
                        if(j === 0){
                            customerTypesOptions.push({
                                label: '',
                                value: result[i].picklistOptions[j].key
                            });
                        }
                        else{
                            customerTypesOptions.push({
                                label: result[i].picklistOptions[j].label,
                                value: result[i].picklistOptions[j].key
                            });
                        }

                        if(result[i].picklistOptions[j].isSelected){
                            selectedOption = result[i].picklistOptions[j].key;

                            // We need to know if the Other intermediary picklist is displayed
                            if(result[i].picklistOptions[j].key === 'Other'){
                                this.isOtherPicklistDisplayed = true;
                            }
                        }
                    }

                    var customerTypesItem = {
                        label: result[i].picklistLabel,
                        selectedItem: selectedOption,
                        options: customerTypesOptions
                    };

                    this.customerTypesList.push(customerTypesItem);
                }

                this.firstCategorizationPicklist = this.customerTypesList[0];

                this.atLeastTwoPicklists = this.customerTypesList.length > 1;
                if(this.atLeastTwoPicklists){
                    this.secondCategorizationPicklist = this.customerTypesList[1];
                }
                else{
                    this.secondCategorizationPicklist = null;
                }

                this.threePicklists = this.customerTypesList.length > 2;
                if(this.threePicklists){
                    this.thirdCategorizationPicklist = this.customerTypesList[2];
                }
                else{
                    this.thirdCategorizationPicklist = null;
                }

                this.stopLoading();
            })
            .catch((error) => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
            });
    }

    changeSelectedCustomerType(event) {
        this.setCustomerType(event.target.value);
        this.inputModified = true;
    }

    changeNameInput(event){
        this.accountNameInput = event.target.value;
        this.inputModified = true;
    }

    changeIataCodeInput(event){
        this.iataCodeInput = event.target.value;
        this.inputModified = true;
    }

    changeSelectedCountry(event){
        this.localCountryId = event.target.value;
        this.inputModified = true;
    }

    search(){
        this.startLoading();

        searchAccounts({
                customerTypeKey: this.selectedCustomerType,
                countryId: this.localCountryId,
                userInputIataCodes: this.iataCodeInput,
                userInputCompanyName: this.accountNameInput,
                max: this.max
            })
            .then(result => {
                var searchResult = result;
                this.localSearchResults = JSON.parse(JSON.stringify(searchResult));
                this.currentPage = 1;
                this.selectedAccountId = '';
                this.checkCompletion();
                this.inputModified = false;
                this.generateResultsToDisplay(false);
                this.stopLoading();
                this.performingSearch = true;
            })
            .catch((error) => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
                this.stopLoading();
            });
    }

    generateResultsToDisplay(moveSelectedAccount){
        // if an account is selected, it must be the first record
        if(moveSelectedAccount){
            let results = this.localSearchResults;
            let reorderedResults = [];
            for(let i = 0; i < results.wrappedResults.length; i++){
                if(results.wrappedResults[i].isSelected){
                    reorderedResults.unshift(results.wrappedResults[i]);
                }
                else{
                    reorderedResults.push(results.wrappedResults[i]);
                }
            }
            results.wrappedResults = reorderedResults;
            
            this.localSearchResults = results;
        }
        
        var results = [];

        var startIndex = (this.currentPage - 1) * this.resultsPerPage;
        var stopIndex = Math.min(startIndex + this.resultsPerPage, this.localSearchResults.wrappedResults.length) ;

        for(let i = startIndex; i < stopIndex; i++){
            results.push(this.localSearchResults.wrappedResults[i]);
        }
        this.resultsToDisplay =  results;

        let pageNumbersBefore= [];
        let pageNumbersAfter= [];

        if(this.numberOfPages < 9){
            for(let i = 1; i <= this.numberOfPages; i++){
                if(i < this.currentPage){
                    pageNumbersBefore.push(i);
                }
                else if(i > this.currentPage){
                    pageNumbersAfter.push(i);
                }
            }
        }
        else{
            if(this.currentPage > 1){
                pageNumbersBefore.push(1);
            }

            if(this.currentPage - 2 > 2){
                pageNumbersBefore.push('...');
            }

            let start;
            if(this.currentPage + 5 < this.numberOfPages){
                start = Math.max(this.currentPage - 2, 2);
            }
            else{
                start = Math.min(this.currentPage - 2, this.numberOfPages - 5);
            }

            for(let i = start; i < start + 5; i++){
                if(i < this.currentPage){
                    pageNumbersBefore.push(i);
                }
                else if(i > this.currentPage){
                    pageNumbersAfter.push(i);
                }
            }

            if(this.currentPage + 2 < this.numberOfPages - 1){
                pageNumbersAfter.push('...');
            }

            if(this.currentPage < this.numberOfPages){
                pageNumbersAfter.push(this.numberOfPages);
            }
        }

        this.pageNumbersBeforeCurrent = pageNumbersBefore;
        this.pageNumbersAfterCurrent = pageNumbersAfter;
    }

    changeSelectedAccountId(event){
        var accountId = event.target.getAttribute('data-id');
        var results = this.localSearchResults;

        for(var i = 0 ; i < results.wrappedResults.length; i++){
            if(results.wrappedResults[i].accountId === accountId){
                results.wrappedResults[i].isSelected = true;
                this.selectedAccountId = accountId;
                this.checkCompletion();
            }
            else{
                results.wrappedResults[i].isSelected = false;
            }
        }
        this.localSearchResults = results;
    }

    /* Pagination methods and flags */
    goToFirstPage(){
        this.currentPage = 1;
        this.generateResultsToDisplay(false);
        this.performingSearch = true;
    }

    goToPreviousPage(){
        this.currentPage = this.currentPage - 1;
        this.generateResultsToDisplay(false);
        this.performingSearch = true;
    }

    get isFirstPage(){
        return this.currentPage === 1;
    }

    goToPage(event){
        var pageNumber = event.target.getAttribute('data-id');

        if(pageNumber === '...'){
            return;
        }

        this.currentPage = parseInt(pageNumber);
        this.generateResultsToDisplay(false);
        this.performingSearch = true;
    }

    goToNextPage(){
        this.currentPage = Math.min(this.currentPage + 1, this.numberOfPages);
        this.generateResultsToDisplay(false);
        this.performingSearch = true;
    }

    goToLastPage(){
        this.currentPage = this.numberOfPages;
        this.generateResultsToDisplay(false);
        this.performingSearch = true;
    }

    get isLastPage(){
        return this.currentPage === this.numberOfPages;
    }

    get numberOfPages(){
        if(this.localSearchResults === undefined){
            return 1;
        }

        let rest = this.localSearchResults.wrappedResults.length % this.resultsPerPage;
        if(rest === 0){
            return this.localSearchResults.wrappedResults.length / this.resultsPerPage;
        }
        else{
            return 1 + (this.localSearchResults.wrappedResults.length - rest) / this.resultsPerPage;
        }
    }

    scrollToSearchInputs(){
        let scrollobjective = this.template.querySelector('[data-name="inputDiv"]');
        scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
    }

    /* Navigation methods */
    previous(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'1'}));
    }

    next(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'5'}));
    }

    createAccount(){
        // discard selected account
        if(this.localSearchResults !== undefined){
            this.selectedAccountId = '';
            this.checkCompletion();
            for(let i = 0; i < this.localSearchResults.wrappedResults.length; i++){
                this.localSearchResults.wrappedResults[i].isSelected = false;
            }
        }

        this.dispatchEvent(new CustomEvent('gotostep', {detail:'3'}));
    }

    startLoading(){
        this.dispatchEvent(new CustomEvent('startloading'));
    }

    stopLoading(){
        this.dispatchEvent(new CustomEvent('stoploading'));
    }

    /* API  methods */
    @api
    getAccountSelectionInfos(){
        var accountSelectionInfos = new Map();
        accountSelectionInfos.set('customerType', this.selectedCustomerType);
        accountSelectionInfos.set('countryId', this.localCountryId);
        accountSelectionInfos.set('accountId', this.selectedAccountId);

        return accountSelectionInfos;
    }

    @api
    getSearchResults(){
        return this.localSearchResults;
    }
}
import { LightningElement, api, track } from 'lwc';

//Methods
import getLstProviders from '@salesforce/apex/PortalServicesInnovationHubCtrl.getLstProviders';
import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';

//Labels
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Contacts_NoResults_text1 from '@salesforce/label/c.CSP_Contacts_NoResults_text1';
import CSP_Contacts_NoResults_text2 from '@salesforce/label/c.CSP_Contacts_NoResults_text2';
import CSP_FilterBy from '@salesforce/label/c.ICCS_Filter_By';
import CSP_ResetFilters from '@salesforce/label/c.CSP_ResetFilters';
import CSP_FundingStage from '@salesforce/label/c.CSP_FundingStage';
import CSP_Technology from '@salesforce/label/c.CSP_Technology';
import CSP_FocusAreas from '@salesforce/label/c.CSP_FocusAreas';
import CSP_Categories from '@salesforce/label/c.CSP_Categories';
import CSP_SearchByName from '@salesforce/label/c.CSP_SearchByName';

export default class PortalServicesInnovationHubSearchTab extends LightningElement {

    labels = { 
        CSP_NoSearchResults, 
        CSP_Contacts_NoResults_text1, 
        CSP_Contacts_NoResults_text2, 
        CSP_FilterBy,
        CSP_ResetFilters,
        CSP_FundingStage,
        CSP_Technology,
        CSP_FocusAreas,
        CSP_Categories,
        CSP_SearchByName
    };

    //icons
    searchColored = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
    searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';

    @track filteringObject = {
        fundingStage: '',
        technologies: [],
        focusAreas: [],
        categories: [],
    }

    //@track componentLoading = true;
    @track providerLoading = false;
    @track techLoading = false;
    @track fsLoading = false;
    @track faLoading = false;
    @track catLoading = false;
    @track showCross = false;

    @track techToggle = false;
    @track faToggle = false;
    @track fsToggle = false;
    @track csToggle = false;
    
    @track lstAllProviders = [];
    @track lstAllFS = [];
    @track lstAllTech = [];
    @track lstAllFocusAreas = [];
    @track lstAllCategories = [];
    @track searchText = '';

    @track paginationObject = {
        totalItems : 10,
        currentPage : 1,
        pageSize : 10,
        maxPages : 3
    }

    get hasProviders() {
        return this.pageRecords.length > 0;
    }

    connectedCallback(){
        this.getFundingStages();
        this.getTechnologies();
        this.getFocusAreas();
        this.getCategories();    
        this.getProviders();
    }

    getProviders(){
        this.providerLoading = true;
        getLstProviders({searchText: this.searchText, filteringObject: JSON.stringify(this.filteringObject)})
        .then(results => {
            this.lstAllProviders = results;

            for(let i = 0; i < results.length; i++){
                if(results[i].imageUrl !== undefined && results[i].imageUrl !== ''){

                    //Check domain in production
                    results[i].imageCSS = 'background: url(' + '"' + results[i].imageUrl + '"' + ');';
                }else{
                    results[i].imageCSS = '';
                }
            }

            this.providerLoading = false;
            this.resetPagination();
        });
    }

    getFundingStages(){
        this.fsLoading = true;
        getPickListValues({ sobj: 'IH_Account_Role_Detail__c', field: 'Funding_Stage__c' }).then(result => {
            this.lstAllFS = JSON.parse(JSON.stringify(result));
            this.fsLoading = false;
        });
        
    }

    getTechnologies(){
        this.techLoading = true;
        getPickListValues({ sobj: 'IH_Account_Role_Detail__c', field: 'Technology__c' }).then(result => {
            this.lstAllTech = JSON.parse(JSON.stringify(result));
            this.setUncheckedProperty('tech');
            this.techLoading = false;
        });
        
    }

    getFocusAreas(){
        this.faLoading = true;
        getPickListValues({ sobj: 'IH_Account_Role_Detail__c', field: 'Focus_Areas__c' }).then(result => {
            this.lstAllFocusAreas = JSON.parse(JSON.stringify(result));
            this.setUncheckedProperty('fa');
            this.faLoading = false;
        });
        
    }

    getCategories(){
        this.catLoading = true;
        getPickListValues({ sobj: 'IH_Account_Role_Detail__c', field: 'Tags_of_categories__c' }).then(result => {
            this.lstAllCategories = JSON.parse(JSON.stringify(result));
            this.setUncheckedProperty('cat');
            this.catLoading = false;
        });
        
    }

    searchProviders(event){
        let search = event.target.value;
        this.searchText = search;
 
        clearTimeout(this.timeout);

        this.timeout = setTimeout(() => {
            this.getProviders();
            this.showCross = this.searchText.length > 0;
        }, 500, this);
    }

    //Filter Toggles
    handleFundingStageToggle(){
        this.fsToggle = !this.fsToggle;
    }

    handleTechToggle(){
        this.techToggle = !this.techToggle;
    }

    handleFAToggle(){
        this.faToggle = !this.faToggle;
    }

    handleCategoriesToggle(){
        this.csToggle = !this.csToggle;
    }

    //Filter Selections

    selectionFS(event) {
        this.filteringObject.fundingStage = event.detail.value;
        this.getProviders();
    }

    selectionTech(event) {
        let selected = event.target.dataset.item;
        let idx = 0;

        for(let i = 0; i < this.lstAllTech.length; i++){
            if(this.lstAllTech[i].value == selected){
                idx = i;
            }
        }

        if (!this.filteringObject.technologies.includes(selected)) {
            this.lstAllTech[idx].checked = true;
            this.filteringObject.technologies.push(selected); 

        }

        else {
            this.lstAllTech[idx].checked = false;
            this.filteringObject.technologies = this.filteringObject.technologies.filter(e => e !== selected);
        }

        this.getProviders();
    }

    selectionFA(event) {
        let selected = event.target.dataset.item;
        let idx = 0;

        for(let i = 0; i < this.lstAllFocusAreas.length; i++){
            if(this.lstAllFocusAreas[i].value == selected){
                idx = i;
            }
        }

        if (!this.filteringObject.focusAreas.includes(selected)) {
            this.lstAllFocusAreas[idx].checked = true;
            this.filteringObject.focusAreas.push(selected); 
        }
        else {
            this.lstAllFocusAreas[idx].checked = false;
            this.filteringObject.focusAreas = this.filteringObject.focusAreas.filter(e => e !== selected);
        }

        this.getProviders();
    }

    selectionCAT(event) {
        let selected = event.target.dataset.item;
        let idx = 0;

        for(let i = 0; i < this.lstAllTech.length; i++){
            if(this.lstAllCategories[i].value == selected){
                idx = i;
            }
        }

        if (!this.filteringObject.categories.includes(selected)) {
            this.lstAllCategories[idx].checked = true;
            this.filteringObject.categories.push(selected); 
        }
        else {
            this.lstAllCategories[idx].checked = false;
            this.filteringObject.categories = this.filteringObject.categories.filter(e => e !== selected);
        }

        this.getProviders();
    }

    //pagination methods

    @track pageRecords = [];

    resetPagination(){

        this.paginationObject = {
            totalItems : this.lstAllProviders.length,
            currentPage : 1,
            pageSize : 10,
            maxPages : 3
        }

        this.pageRecords = [];
        this.processPage();
    }

    handleSelectedPage(event){
        //the event contains the selected page
        let requestedPage = event.detail;
        let paginationObjectAux = JSON.parse(JSON.stringify(this.paginationObject)); 
        paginationObjectAux.currentPage = requestedPage;
        this.paginationObject = paginationObjectAux;
        this.processPage();
    }

    processPage(){
        let pageRecordsAux = [];
        let realRequestedPage = this.paginationObject.currentPage-1;
        let offset = realRequestedPage * this.paginationObject.pageSize;
        let offsetLimit = offset + this.paginationObject.pageSize;
        for(let i = offset; i < this.lstAllProviders.length && i < offsetLimit ; i++){
            pageRecordsAux.push(this.lstAllProviders[i]);
        }

        this.pageRecords = pageRecordsAux;
    }

    removeTextSearch(){
        this.searchText = '';
        this.showCross = false;
        this.getProviders();
    }

    resetFilters(){

        this.filteringObject = {
            fundingStage: '',
            technologies: [],
            focusAreas: [],
            categories: [],
        }
        
        this.setUncheckedProperty('tech');
        this.setUncheckedProperty('fa');
        this.setUncheckedProperty('cat');

        this.removeTextSearch();
    }

    startLoading(){
        this.componentLoading = true;
    }

    stopLoading(){
        this.componentLoading = false;
    }

    setUncheckedProperty(filter){

        switch(filter) {
            case 'tech':
                for(let i=0;i<this.lstAllTech.length;i++){
                    this.lstAllTech[i].checked = false; 
                }
                break;

            case 'fa':
                for(let i=0;i<this.lstAllFocusAreas.length;i++){
                    this.lstAllFocusAreas[i].checked = false; 
                }
                break;

            case 'cat':
                for(let i=0;i<this.lstAllCategories.length;i++){
                    this.lstAllCategories[i].checked = false; 
                }
                break;
            
            default: // Do nothing
          }
    }

}
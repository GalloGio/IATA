import { LightningElement, track } from 'lwc';

import { getParamsFromPage } from 'c/navigationUtils';

//import labels
import CSP_Search_Home_Placeholder from '@salesforce/label/c.CSP_Search_Home_Placeholder';
import CSP_Breadcrumb_AdvancedSearch_Title from '@salesforce/label/c.CSP_Breadcrumb_AdvancedSearch_Title';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';
import CSP_Search_NoResults_text3 from '@salesforce/label/c.CSP_Search_NoResults_text3';
import CSP_Search_TypeIn_text1 from '@salesforce/label/c.CSP_Search_TypeIn_text1';
import CSP_Search_TypeIn_text2 from '@salesforce/label/c.CSP_Search_TypeIn_text2';
import CSP_Search_TypeIn_text3 from '@salesforce/label/c.CSP_Search_TypeIn_text3';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalAdvancedSearchPage extends LightningElement {

    label = {
        CSP_Search_Home_Placeholder,
        CSP_Breadcrumb_AdvancedSearch_Title,
        CSP_Search_NoResults_text1,
        CSP_Search_NoResults_text2,
        CSP_Search_NoResults_text3,
        CSP_Search_TypeIn_text1,
        CSP_Search_TypeIn_text2,
        CSP_Search_TypeIn_text3
    };

    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
    searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';


    @track filteringObject;

    timeout = null;
    @track searchText = "";

    @track noResultsClass = 'display: none;';
    @track resultsClass = 'display: none;';
    @track emptySearchStringClass = 'display: none;';

    @track loadingTypehead = false;

    //links for images
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/AdvancedSearchBackground.jpg';
    @track backgroundStyle;

    @track showCross = false;

    connectedCallback(){

        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:230px;';

        let hightlightComponent = '';

        this.pageParams = getParamsFromPage();
        if (this.pageParams.searchText !== undefined) {
            this.searchText = decodeURIComponent((this.pageParams.searchText+'').replace(/\+/g, '%20'));
        }
        if (this.pageParams.highlight !== undefined && 
                (this.pageParams.highlight === 'servicesComponent' || this.pageParams.highlight === 'casesComponent' || 
                 this.pageParams.highlight === 'faqsComponent' || this.pageParams.highlight === 'documentsComponent' || 
                 this.pageParams.highlight === 'profileComponent')) {
            hightlightComponent = this.pageParams.highlight;
        }

        let filteringObjectAux = {
            showAllComponents : true,
            searchText : this.searchText,
            highlightTopResults : false,
            advancedSearch : true,
            servicesComponent : {
                show : false,
                highlight : false,
                loading : true,
                nrResults : 0
            },
            casesComponent : {
                show : false,
                loading : true,
                highlight : false,
                nrResults : 0,
                caseTypeFilter : "",
                caseCountryFilter : ""
            },
            faqsComponent : {
                show : false,
                loading : true,
                highlight : false,
                nrResults : 0,
                faqCategoryFilter : "",
                faqTopicFilter : "",
                faqSubtopicFilter : "",
                faqSubtopicsList : []
            },
            documentsComponent : {
                show : false,
                loading : true,
                highlight : false,
                nrResults : 0,
                documentCategoryFilter : "",
                documentProductCategoryFilter : "",
                documentCountryFilter : ""
            },
            profileComponent : {
                show : false,
                loading : true,
                highlight : false,
                nrResults : 0,
                profileTypeFilter : "",
                profileCountryFilter : "",
                profileContactStatusFilter : ""
            }
        };

        if(hightlightComponent === ''){
            filteringObjectAux.highlightTopResults = true;
            filteringObjectAux.servicesComponent.show = true;
            filteringObjectAux.casesComponent.show = true;
            filteringObjectAux.faqsComponent.show = true;
            filteringObjectAux.documentsComponent.show = true;
            filteringObjectAux.profileComponent.show = true;
        }else{
            filteringObjectAux[hightlightComponent].highlight = true;

            if(hightlightComponent === 'servicesComponent'){
                filteringObjectAux.servicesComponent.show = true;
            }
            if(hightlightComponent === 'casesComponent'){
                filteringObjectAux.casesComponent.show = true;
            }
            if(hightlightComponent === 'faqsComponent'){
                filteringObjectAux.faqsComponent.show = true;
            }
            if(hightlightComponent === 'documentsComponent'){
                filteringObjectAux.documentsComponent.show = true;
            }
            if(hightlightComponent === 'profileComponent'){
                filteringObjectAux.profileComponent.show = true;
            }
        }

        this.filteringObject = filteringObjectAux;

        this.updateResultsDiv();

    }

    onchangeSearchInput(event){
        //update temporary search term until times out
        this.searchText = event.target.value;

        if (this.searchText.length > 0) {
            this.showCross = true;
        } else {
            this.showCross = false;
        }
        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        this.loadingTypehead = true;

        // Make a new timeout set to go off in 1500ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();

            this.loadingTypehead = false;

            if(this.searchText.length > 2){
                this.showHoverResults = true;
                let objAux = JSON.parse(JSON.stringify(this.filteringObject));

                objAux.searchText = this.searchText + "";
                objAux.showAllComponents = true;
                this.filteringObject = objAux;
            }else{
                this.showHoverResults = false;
                this.updateResultsDiv();
            }


        }, 1500, this);

    }

    handlefilterchanged(event){

        let eventObject = JSON.parse(JSON.stringify(event.detail.object));
        let eventComponentName = JSON.parse(JSON.stringify(event.detail.componentName));

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux[eventComponentName] = eventObject[eventComponentName];

        this.filteringObject = filteringObjectAux;

        this.updateResultsDiv();
    }

    handlehighlightfilterchanged(event){
        let detailObject = JSON.parse(JSON.stringify(event.detail));
        this.filteringObject = detailObject;
        this.updateResultsDiv();
    }

    updateResultsDiv(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if(this.searchText.length < 3){
            this.noResultsClass = 'display: none;';
            this.resultsClass = 'display: none;';
            this.emptySearchStringClass = '';
        }else{
            if(this.searchText.length > 2 &&
                
                ((filteringObjectAux.servicesComponent.nrResults === 0 && filteringObjectAux.casesComponent.nrResults === 0 &&
                filteringObjectAux.faqsComponent.nrResults === 0 && filteringObjectAux.documentsComponent.nrResults === 0 && 
                filteringObjectAux.profileComponent.nrResults === 0) ||
                
                (filteringObjectAux.servicesComponent.nrResults === 0 && filteringObjectAux.servicesComponent.highlight ) ||
                (filteringObjectAux.casesComponent.nrResults === 0 && filteringObjectAux.casesComponent.highlight ) ||
                (filteringObjectAux.faqsComponent.nrResults === 0 && filteringObjectAux.faqsComponent.highlight ) ||
                (filteringObjectAux.documentsComponent.nrResults === 0 && filteringObjectAux.documentsComponent.highlight )||
                (filteringObjectAux.profileComponent.nrResults === 0 && filteringObjectAux.profileComponent.highlight )

                )
                ){
                this.noResultsClass = '';
                this.emptySearchStringClass = 'display: none;';
                this.resultsClass = 'display: none;';
            }else{
                this.noResultsClass = 'display: none;';
                this.resultsClass = '';
                this.emptySearchStringClass = 'display: none;';
            }
        }
    }

    removeTextSearch() {
        this.filteringObject.searchText = '';
        this.searchText = '';
        this.showCross = false;
    }
}

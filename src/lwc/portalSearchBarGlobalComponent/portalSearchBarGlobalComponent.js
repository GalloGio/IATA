import { LightningElement, api, track } from 'lwc';

export default class PortalSearchBarGlobalComponent extends LightningElement {

    @api showServices;
    @api showCases;
    @api showFAQs;
    @api showDocuments;
    @api showPortalFeatures;

    @api searchBarPlaceholder;

    @track filteringObject;

    showservicesComponent(){ return this.showServices === 'true'; }
    showcasesComponent(){ return this.showCases === 'true'; }
    showfaqsComponent(){ return this.showFAQs === 'true'; }
    showdocumentsComponent(){ return this.showDocuments === 'true'; }
    showportalFeaturesComponent(){ return this.showPortalFeatures === 'true'; }

    connectedCallback() {

        let filteringObjectAux = {
            showAllComponents : true,
            searchText : "",
            highlightTopResults : false,
            advancedSearch : true,
            servicesComponent : {
                show : this.showservicesComponent(),
                highlight : false,
                loading : true,
                nrResults : 0
            },
            casesComponent : {
                show : this.showcasesComponent(),
                loading : true,
                highlight : false,
                nrResults : 0,
                caseTypeFilter : "",
                caseCountryFilter : ""
            },
            faqsComponent : {
                show : this.showfaqsComponent(),
                loading : true,
                highlight : false,
                nrResults : 0,
                faqCategoryFilter : "",
                faqTopicFilter : "",
                faqSubtopicFilter : "",
                faqSubtopicsList : []
            },
            documentsComponent : {
                show : this.showdocumentsComponent(),
                loading : true,
                highlight : false,
                nrResults : 0,
                documentCategoryFilter : "",
                documentProductCategoryFilter : "",
                documentCountryFilter : ""
            }
        };

        this.filteringObject = filteringObjectAux;

    }    


}
import { LightningElement, api, track } from 'lwc';

export default class PortalSearchBarGlobalComponent extends LightningElement {

    @api showServices = false;
    @api showCases = false;
    @api showFAQs = false;
    @api showDocuments = false;
    @api showAdvancedSearch = false;
    @api language;
    @api searchBarPlaceholder;

    @track filteringObject;

    connectedCallback() {

        let filteringObjectAux = {
            showAllComponents : true,
            searchText : "",
            highlightTopResults : false,
            advancedSearch : this.showAdvancedSearch,
            language : this.language,
            servicesComponent : {
                show : this.showServices,
                highlight : false,
                loading : true,
                nrResults : 0
            },
            casesComponent : {
                show : this.showCases,
                loading : true,
                highlight : false,
                nrResults : 0,
                caseTypeFilter : "",
                caseCountryFilter : ""
            },
            faqsComponent : {
                show : this.showFAQs,
                loading : true,
                highlight : false,
                nrResults : 0,
                faqCategoryFilter : "",
                faqTopicFilter : "",
                faqSubtopicFilter : "",
                faqSubtopicsList : []
            },
            documentsComponent : {
                show : this.showDocuments,
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

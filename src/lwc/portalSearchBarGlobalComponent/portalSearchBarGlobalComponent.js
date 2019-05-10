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
       //console.log(this.searchBarPlaceholder);

        this.filteringObject = {
            "showAllComponents" : false,
            "searchText" : "",
            "servicesComponent" : {
                "show" : this.showservicesComponent(),
                "searchable" : this.showservicesComponent(),
                "filters" : {
                    "type" : ""
                }
            },
            "casesComponent" : {
                "show" : this.showcasesComponent(),
                "searchable" : this.showcasesComponent(),
                "filters" : {
                    "type" : "",
                    "status" : ""
                }
            },
            "faqsComponent" : {
                "show" : this.showfaqsComponent(),
                "searchable" : this.showfaqsComponent(),
                "filters" : {
                    "category" : "",
                    "topic" : ""
                }
            },
            "documentsComponent" : {
                "show" : this.showdocumentsComponent(),
                "searchable" : this.showdocumentsComponent(),
                "filters" : {
                    "category" : "",
                    "topic" : "",
                    "productType" : "",
                    "publishedCountry" : ""
                }
            },
            "portalFeaturesComponent" : {
                "show" : this.showportalFeaturesComponent(),
                "searchable" : this.showportalFeaturesComponent(),
                "filters" : {

                }
            }
        };

    }    


}
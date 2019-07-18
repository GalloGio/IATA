import { LightningElement, api, track } from 'lwc';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Features_Title from '@salesforce/label/c.CSP_Features_Title';

export default class PortalSearchCasesList extends LightningElement {

    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_Features_Title
    };

    //list of services to display
    @track dataRecords;
    
    //clone of the filtering object passed from the parent
    @track filteringObject;

    //lock screen while loading
    @track loading = false;

    //these are the filters passed from the search
    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }
    set filteringObjectParent(value) {
        this.filteringObject = value;
        // console.log('FeaturesList : ', JSON.parse(JSON.stringify(this.filteringObject)));
        this.searchWithNewFilters();
    }
    
    get showComponent() {
        return this.toggleComponent();
    }

    toggleComponent() {
        return this.filteringObject !== undefined && 
            this.filteringObject.showAllComponents && 
            this.filteringObject.portalFeaturesComponent.show && 
            this.filteringObject.portalFeaturesComponent.searchable;    
    }

    searchWithNewFilters() {
        if(this.toggleComponent()) {
            //process call to salesforce here
        }
    }
}
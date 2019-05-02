import { LightningElement, api, track } from 'lwc';
import getUserServicesList from '@salesforce/apex/PortalServicesCtrl.getUserServicesList';
import { NavigationMixin } from 'lightning/navigation';

import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Services_Title from '@salesforce/label/c.CSP_Services_Title';

export default class PortalSearchServicesList extends NavigationMixin(LightningElement) {

    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_Services_Title
    };

    //list of services to display
    @track dataRecords = false;
    
    //clone of the filtering object passed from the parent
    @track filteringObject;

    //lock screen while loading
    @track loading = true;

    @track error;
    @track data;
    @track columns = [
        {label: 'Name', fieldName: 'Application_Name__c', type: 'text'},
        {label: '', fieldName: '', cellAttributes:
                { iconName: 'utility:forward', iconPosition: 'right' }}
    ];

    @track
    servicesListUrl;

    //these are the filters passed from the search
    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }
    set filteringObjectParent(value) {
        console.log('new filtering object : ', value);
        this.filteringObject = value;
        this.searchWithNewFilters();
    }
    
    get showComponent(){
        return this.showComponentBool();
    }

    get dataRecords() {
        return this.dataRecords;
    }  

    showComponentBool(){
        return this.filteringObject !== undefined && 
                this.filteringObject.showAllComponents && 
                this.filteringObject.servicesComponent.show && 
                this.filteringObject.servicesComponent.searchable;
    }

    connectedCallback(){ 

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "cases-list",
            },
            state: {
                "c__searchText":"helloworld" 
            }})
        .then(url => this.servicesListUrl = url);

        this.loading = false;
    }

    searchWithNewFilters() {
        if(this.showComponentBool()){
            getUserServicesList({ refinedSearchSerialized : JSON.stringify(this.filteringObject )})
            .then(results => {
                if(results && results.length > 0) {
                    this.data = results;
                    this.dataRecords = true;
                } else {
                    this.dataRecords = false; 
                }
                this.loading = false;
            })
            .catch(error => {
                this.error = error;
                this.loading = false;
                this.dataRecords = false;
            });   
        }
    }

    viewAll(event) {
        console.log(this.url);

        event.preventDefault();
        event.stopPropagation();

        navigateToPage(this.servicesListUrl, {});

        // Navigate to the Account Home page.
        location.replace(this.servicesListUrl);
    }


}
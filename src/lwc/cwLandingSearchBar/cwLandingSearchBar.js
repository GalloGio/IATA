import { LightningElement, track, wire } from 'lwc';
import getLocationsList from '@salesforce/apex/CW_LandingSearchBarController.getLocationsList';
import getCompanyNamesList from '@salesforce/apex/CW_LandingSearchBarController.getCompanyNamesList';
import getCertificationsList from '@salesforce/apex/CW_LandingSearchBarController.getCertificationsList';
import SEARCH_ICON from '@salesforce/resourceUrl/ICG_Search_Icon';
import fileico from '@salesforce/resourceUrl/IATA_CSS_guidelines_v1';
import demoFiles from '@salesforce/resourceUrl/demo_resource';
import icons from '@salesforce/resourceUrl/icons';

export default class CwLandingSearchBar extends LightningElement {
    initialized = false;

    //Available Search Types
    searchtypelocation = 'location';
    searchtypecertification = 'certification';
    searchtypecompanyname = 'companyname'

    searchIcon = SEARCH_ICON;
    dropdownicon = fileico + '/IATA-CSS-guidelines-v1/assets/icon-dropdown.svg';
    bluearrow = demoFiles + '/demo_resource/blue-arrow.svg';
    searchbycertification = icons + '/icons/search-by-certification.svg';
    searchbycompany = icons + '/icons/search-by-company.svg';
    searchbylocation = icons + '/icons/search-by-location.svg';

    searchbycertificationresp = icons + '/icons/responsive/ic-search-by-certf--yellow.svg';
    searchbycompanyresp = icons + '/icons/responsive/ic-search-companyname--yellow.svg';
    searchbylocationresp = icons + '/icons/responsive/ic-location--yellow.svg';
    yellowarrow = icons + '/icons/responsive/ic-arrow--yellow.svg';

    @track showSearchTypeCombo = false;
    @track searchType = this.searchtypelocation;
    @track predictiveValues = [];
    @track searchValue = '';

    availableLocations;
    availableCompanyNames;
    availableCertifications;

    @wire(getLocationsList, {})
    wiredLocations({ data }) {
        if (data) {
            this.availableLocations = JSON.parse(data);
        }
    }
    @wire(getCompanyNamesList, {})
    wiredCompanyNames({ data }) {
        if (data) {
            this.availableCompanyNames = JSON.parse(data);
        }
    }
    @wire(getCertificationsList, {})
    wiredCertifications({ data }) {
        if (data) {
            this.availableCertifications = JSON.parse(data);
        }
    }
    renderedCallback() { // invoke the method when component rendered or loaded
        if (this.initialized) {
            return;
        }
        this.initialized = true;

        //Align datalist for predictive results with inputs.
        //This code is performed to avoid the id changes that LWC makes to elements.
        let listId = this.template.querySelector('datalist').id;
        this.template.querySelector("input").setAttribute("list", listId);

    }
    get isLocation() {
        return this.searchType === this.searchtypelocation;
    }
    get isCertification() {
        return this.searchType === this.searchtypecertification;
    }
    get isCompanyName() {
        return this.searchType === this.searchtypecompanyname;
    }
    closeSearchTypeCombo() {
        this.showSearchTypeCombo = false;
    }
    setLocationSearchType() {
        this.searchType = this.searchtypelocation;
        this.closeSearchTypeCombo();
        this.predictiveValues = [];
    }
    setCertificationSearchType() {
        this.searchType = this.searchtypecertification;
        this.closeSearchTypeCombo();
        this.predictiveValues = [];
    }
    setCompanyNameSearchType() {
        this.searchType = this.searchtypecompanyname;
        this.closeSearchTypeCombo();
        this.predictiveValues = [];
    }
    displaySearchTypeCombo() {
        this.showSearchTypeCombo = true;

    }
    get searchBoxPlaceholder() {
        if (this.isLocation) return 'Type Location';
        else if (this.isCertification) return 'Type Certification';
        else if (this.isCompanyName) return 'Type Company';

        return 'Please, pick a type';
    }
    hideSearchTypeCombo(event) {

        event.stopPropagation();

        let ele = event.target || event.srcElement;
        if (ele.className === "containercombo") {
            this.closeSearchTypeCombo();
        }
    }

    predictiveSearch(event) {
        this.predictiveValues = [];
        this.searchValue = event.target.value;
        if (!event.target.value || event.target.value.length < 3) {
            return;
        }

        if (this.isLocation) {
            for (let loc in this.availableLocations) {
                // skip loop if the property is from prototype
                if (!this.availableLocations.hasOwnProperty(loc)) continue;
                this.predictiveValues.push({ key: loc, value: this.availableLocations[loc] });

            }
        } else if (this.isCompanyName) {
            for (let company in this.availableCompanyNames) {
                // skip loop if the property is from prototype
                if (!this.availableCompanyNames.hasOwnProperty(company)) continue;
                this.predictiveValues.push({ key: company, value: this.availableCompanyNames[company] });

            }
        } else if (this.isCertification) {
            for (let cert in this.availableCertifications) {
                // skip loop if the property is from prototype
                if (!this.availableCertifications.hasOwnProperty(cert)) continue;
                this.predictiveValues.push({ key: cert, value: this.availableCertifications[cert] });

            }
        }
    }

    resultsPage() {
        let searchList = [];

        let searchObject = { operator: 'LIKE', value: this.searchValue };
        if (this.isLocation) {
            searchObject.obj = 'ICG_Account_Role_Detail__c';
            searchObject.field = 'City__c';
            searchObject.fields = ['Nearest_Airport__c', 'Country__c', 'City__c'];
        } else if (this.isCompanyName) {
            searchObject.obj = 'ICG_Account_Role_Detail__c';
            searchObject.field = 'Account_Role__r.Account__r.Name';
            searchObject.fields = ['Account_Role__r.Account__r.Name'];
        } else if (this.isCertification) {
            searchObject.obj = 'ICG_Account_Role_Detail_Certification__c';
            searchObject.field = 'Certification__r.Name';
            searchObject.fields = ['Certification__r.Name'];
            searchObject.relationfield = 'ICG_Account_Role_Detail__c';
        }
        searchList.push(searchObject);

        //window.open('https://nourlfound1234.com?q='+encodeURI(btoa(encodeURI(JSON.stringify(searchList)))).replace('=',''));
        // window.location.href = 'https://nextlink1-customer-portal-iata.cs83.force.com/identity/s/resultspage?q='+encodeURI(btoa(encodeURI(JSON.stringify(searchList)))).replace('=','');
        // window.location.href = 'https://nextlink4-customer-portal-iata.cs85.force.com/identity/s/resultspage?q=' + encodeURI(btoa(encodeURI(JSON.stringify(searchList)))).replace('=', '');
        // window.location.href = 'https://nextlink3-customer-portal-iata.cs85.force.com/identity/s/resultspage?q=' + encodeURI(btoa(encodeURI(JSON.stringify(searchList)))).replace('=', '');
        window.location.href = 'https://sit-customer-portal-iata.cs109.force.com/identity/s/resultspage?q=' + encodeURI(btoa(encodeURI(JSON.stringify(searchList)))).replace('=', '');

        //TODO -> pass to metadata
    }
}
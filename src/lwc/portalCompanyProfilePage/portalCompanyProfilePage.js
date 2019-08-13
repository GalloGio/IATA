/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/**
 * Created by pvavruska on 5/23/2019.
 */

import { LightningElement, wire, track } from 'lwc';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import canEditBasics from '@salesforce/apex/PortalProfileCtrl.canEditBasics';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import getFieldsMap from '@salesforce/apex/PortalProfileCtrl.getFieldsMap';
import getContactFieldsToInsert from '@salesforce/apex/PortalProfileCtrl.getContactFieldsToInsert';
import getContactsListFields from '@salesforce/apex/PortalProfileCtrl.getContactsListFields';
import getBranchesListFields from '@salesforce/apex/PortalProfileCtrl.getBranchesListFields';
import getInvoicesListFields from '@salesforce/apex/PortalProfileCtrl.getInvoicesListFields'; //WMO-627 - ACAMBAS
import getContacts from '@salesforce/apex/PortalProfileCtrl.getAccountContacts';
import getBranches from '@salesforce/apex/PortalProfileCtrl.getCompanyBranches';
import getInvoices from '@salesforce/apex/PortalProfileCtrl.getCustomerInvoices'; //WMO-627 - ACAMBAS
import searchContacts from '@salesforce/apex/PortalProfileCtrl.searchAccountContacts';
import searchBranches from '@salesforce/apex/PortalProfileCtrl.searchCompanyBranches';
import { getParamsFromPage } from 'c/navigationUtils';
import CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';
import FindBranch from '@salesforce/label/c.csp_Find_Branch';
import FindContact from '@salesforce/label/c.csp_Find_Contact';
import NewContact from '@salesforce/label/c.csp_CreateNewContact';
import NoAccount from '@salesforce/label/c.CSP_NoAccount';
import CSP_Branch_Offices from '@salesforce/label/c.CSP_Branch_Offices';
import ISSP_Contacts from '@salesforce/label/c.ISSP_Contacts';
import CSP_Outstanding_Invoices from '@salesforce/label/c.CSP_Outstanding_Invoices'; //WMO-627 - ACAMBAS
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import IATA_Invoices from '@salesforce/label/c.CSP_IATA_Invoices'; //WMO-627 - ACAMBAS 
import EF_Invoices from '@salesforce/label/c.CSP_EF_Invoices'; //WMO-627 - ACAMBAS


export default class PortalCompanyProfilePage extends LightningElement {

    //icons
    searchColored = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    constructor() {
        super();
        var self = this;
        window.addEventListener('scroll', function(e) { self.handleScroll(window.scrollY, self); });
    }

    @track isAdmin = false;
    @track sectionMap = [];
    @track handleScrolling = true;
    @track accountId;
    @track emailAddress;
    @track userLoaded = false;
    @track currentSection;
    @track lstTabs = [];
    @track contacts = [];
    @track branches = [];
    @track invoices = []; //WMO-627 - ACAMBAS
    @track branchesLoaded = false;
    @track contactsLoaded = false;
    @track iataInvoicesLoaded = false; //WMO-627 - ACAMBAS
    @track efInvoicesLoaded = false; //WMO-627 - ACAMBAS
    @track branchFields;
    @track contactFields;
    @track invoiceFields; //WMO-627 - ACAMBAS
    @track editBasics = false;

    //Search
    @track searchMode = false;
    @track searchFromRedirect = false;
    @track contactsSearch = [];
    @track branchesSearch = [];
    @track searchTextContacts;
    @track searchTextBranches;
    @track contactsEndedSearch = false;
    @track branchesEndedSearch = false;
    @track contactsQuery;
    @track branchesQuery;

    //Infinite loading
    @track contactsOffset = 0;
    @track branchesOffset = 0;
    @track invoicesOffset = 0; //WMO-627 - ACAMBAS
    @track branchesOffsetSearch = 0;
    @track contactsOffsetSearch = 0;
    @track contactsEnded = false;
    @track branchesEnded = false;
    @track invoicesEnded = false; //WMO-627 - ACAMBAS
    @track isFetching = false;
    lastPosition;


    @track openmodel = false;
    @track recordid;
    @track objectid;
    @track objectName = "Contact";
    @track fieldsListToCreate = [];
    @track searchValue;
    // ------------------- //



    get noAccount() {
        return (this.loggedUser == null || this.loggedUser.Contact == null || this.loggedUser.Contact.AccountId == null);
    }

    _labels = { CompanyInformation, FindBranch, FindContact, NewContact, NoAccount, CSP_Branch_Offices, ISSP_Contacts, CSP_Outstanding_Invoices, IATA_Invoices, EF_Invoices };
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }


    connectedCallback() {

        let displayTabs = new Promise((resolve, reject) => { //WMO-627 - ACAMBAS
            isAdmin().then(result => {
                this.isAdmin = result;

                let pageParams = getParamsFromPage();
                let viewContacts = false;
                let viewInvoices = false; //WMO-627 - ACAMBAS

                if (pageParams.tab !== undefined && pageParams.tab !== '') {
                    if (pageParams.tab === 'contact') {
                        viewContacts = true;
                    }
                    //WMO-627 - ACAMBAS: Begin
                    else if (pageParams.tab === 'invoices') {
                        viewInvoices = true;
                    }
                    //WMO-627 - ACAMBAS: End
                }

                let tabsAux = [];
                this.isAdmin = true;
                let tabNames = [this.labels.CompanyInformation, this.labels.CSP_Branch_Offices, this.labels.ISSP_Contacts, this.labels.CSP_Outstanding_Invoices]; //+'Company Calendar', 'Activity Log'];

                for (let i = 0; i < tabNames.length; i++) {
                    let tabAux = {};

                    //Only Portal Admin can see other tabs
                    if (i === 0 || this.isAdmin) {
                        tabAux = {
                            active: !viewContacts && !viewInvoices,
                            label: tabNames[i],
                            id: i,
                            class: "slds-p-around_small cursorPointer text-darkGray"
                        };

                        if (i === 2) {
                            tabAux.active = viewContacts;
                        }
                        //WMO-627 - ACAMBAS: Begin
                        else if (i === 3) {
                            tabAux.active = viewInvoices;
                        } else if (i !== 0) {
                            tabAux.active = false;
                        }
                        //WMO-627 - ACAMBAS: end
                    }

                    tabsAux.push(tabAux);
                }

                if (pageParams.contactName !== undefined && pageParams.contactName !== '') {
                    this.searchValue = decodeURIComponent((pageParams.contactName + '').replace(/\+/g, '%20'));
                    this.onchangeSearchInputContactsFromNotification(this.searchValue);
                }

                this.lstTabs = tabsAux;

                if (viewContacts) {
                    //this.retrieveContacts();
                    this.contactsLoaded = true;
                    this.isFetching = true;
                    this.searchContacts(this.searchValue);
                }
            });

            //WMO-627 - ACAMBAS: Begin

            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        let displaySubTabs = new Promise((resolve, reject) => {
            //Check if there are E&F Invoices
            getInvoices({ offset: 0, type: 'EF_AIRPORT' }).then(result => {
                //this.isFetching = false;
                let subTabsAux = [];
                let subTabNames;

                if (result.length === 0) {
                    //Hide E&F Invoices tab if there are no E&F Invoices
                    subTabNames = [this.labels.IATA_Invoices];
                } else {
                    subTabNames = [this.labels.IATA_Invoices, this.labels.EF_Invoices];
                }

                for (let i = 0; i < subTabNames.length; i++) {
                    let subTabAux = {};

                    subTabAux = {
                        label: subTabNames[i],
                        id: i,
                        class: "slds-p-around_small cursorPointer text-darkGray"
                    };

                    if (i === 0) {
                        subTabAux.active = true;
                    } else {
                        subTabAux.active = false;
                    }

                    subTabsAux.push(subTabAux);
                }

                this.lstSubTabs = subTabsAux;
            });

            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        let getInvoicesData = new Promise((resolve, reject) => {
            // if (viewInvoices) {
            //alert('retrieveInvoices(IATA_OFFICE)');
            this.iataInvoicesLoaded = false;
            this.efInvoicesLoaded = false;
            this.retrieveInvoices('IATA_OFFICE');
            this.isFetching = true;
            //}

            let error = false;
            if (!error) resolve();
            else reject();
        });

        let displayInvoices = function() {
            Promise.all([
                displayTabs,
                displaySubTabs,
                getInvoicesData
            ]);
        }

        displayInvoices();

        //WMO-627 - ACAMBAS: end

        canEditBasics().then(result => {
            this.editBasics = result;
        });

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
            this.objectid = this.loggedUser.Contact.AccountId;
            this.userLoaded = true;
        });

        this.refreshview();

        getContactFieldsToInsert().then(result => {
            this.fieldsListToCreate = result;
        });
    }

    refreshview() {
        //For contacts tab
        this.getContactsFieldMap();

        //For branches tab
        this.getBranchesFieldMap();

        //For outstanding invoices tab
        this.getInvoicesFieldMap(); //WMO-627 - ACAMBAS

        //For company information tab
        getFieldsMap({ type: 'CompanyProfile' }).then(result => {

            this.sectionMap = JSON.parse(JSON.stringify(result));

            let sectionMap = this.sectionMap;

            let localMap = [];
            for (let key in this.sectionMap) {
                // Preventing unexcepted data
                if (sectionMap.hasOwnProperty(key)) { // Filtering the data in the loop
                    let value = sectionMap[key];
                    localMap.push({ 'value': value, 'key': key });
                }
            }
            this.mapOfValues = localMap;

        });
    }

    renderedCallback() {
        let sections = this.template.querySelectorAll('.section');


        const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
        if (leftNav) {
            /* Set nav items for sticky navigation */
            let navItems = [];
            for (let key in this.sectionMap) {
                navItems.push({ label: key, value: key, open: true });
            }

            leftNav.navItems = navItems;
            leftNav.activesection = 'Basics';
        }
    }


    navItemSelected(event) {
        this.navItem = event.detail.item;
    }

    handleScroll(yposition, self) {
        if (!this.handleScrolling) { return; }
        let sections = self.template.querySelectorAll('.section');

        for (let i = 0; i < sections.length; i++) {
            let sectionName = sections[i].attributes.getNamedItem('data-name').value;
            let offsetTop = sections[i].offsetTop;

            let windowHeight = window.innerHeight;
            //let positionFromTop = sections[i].getBoundingClientRect().top;

            let triggerPosition = windowHeight / 2;
            if ((offsetTop - yposition < triggerPosition) && (offsetTop - yposition > -triggerPosition)) {
                if (self.currentSection != sectionName) {
                    self.currentSection = sectionName;
                    const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
                    if (leftNav) {
                        leftNav.activesection = sectionName;
                    }
                }
            }

        }


        //Infinite load
        //let endPage = self.template.querySelector('.endOfPage');
        let wholePage = self.template.querySelector('.profilePageWrapper');

        //let loadMoreTrigger = (window.innerHeight / 5) * 4;
        let treshhold = 250;

        let isFetching = this.isFetching;

        let lastPosition = this.lastPosition;

        if (Math.abs(wholePage.getBoundingClientRect().bottom - yposition) < treshhold) { //if((Math.abs(yposition-loadMoreTrigger) < treshhold)){
            if (!isFetching && (lastPosition == null || lastPosition < yposition)) {
                this.loadMore();
            }
        }

        this.lastPosition = yposition;
    }

    onmouseenterTab(event) {
        let clickedTab = event.target.dataset.item;

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray activeTab";
            } else {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray";
            }
        }

        this.lstTabs = tabsAux;
    }

    //WMO-627 - ACAMBAS: Begin
    onmouseenterSubTab(event) {
            let clickedSubTab = event.target.dataset.item;

            //because proxy.......
            let subTabsAux = JSON.parse(JSON.stringify(this.lstSubTabs));

            for (let i = 0; i < subTabsAux.length; i++) {
                if (i + "" === clickedSubTab) {
                    subTabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray activeTab";
                } else {
                    subTabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray";
                }
            }

            this.lstSubTabs = subTabsAux;
        }
        //WMO-627 - ACAMBAS: End

    onmouseleaveTab(event) {
        let clickedTab = event.target.dataset.item;

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray";
            }
        }

        this.lstTabs = tabsAux;
    }

    //WMO-627 - ACAMBAS: Begin
    onmouseleaveSubTab(event) {
            let clickedSubTab = event.target.dataset.item;

            //because proxy.......
            let subTabsAux = JSON.parse(JSON.stringify(this.lstSubTabs));

            for (let i = 0; i < subTabsAux.length; i++) {
                if (i + "" === clickedSubTab) {
                    subTabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray";
                }
            }

            this.lstSubTabs = subTabsAux;
        }
        //WMO-627 - ACAMBAS: End

    onclickTab(event) {
        this.searchTextBranches = '';
        this.searchTextContacts = '';

        let clickedTab = event.target.dataset.item;
        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        //Add onclick method to retrieve Accounts/Contacts
        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].active = true;

                if (i == 1 && !this.branchesLoaded) {
                    //Branches
                    this.retrieveBranches();
                } else if (i == 2 && !this.contactsLoaded) {
                    //Contacts
                    this.retrieveContacts();
                }
                //WMO-627 - ACAMBAS: Begin
                else if (i == 3 && !this.iataInvoicesLoaded) {
                    if (this.lstSubTabs[0] != null && this.lstSubTabs[0].active) {
                        //IATA Invoices
                        this.iataInvoicesLoaded = false;
                        this.retrieveInvoices('IATA_OFFICE');
                    } else {
                        //E&F Invoices
                        this.efInvoicesLoaded = false;
                        this.retrieveInvoices('EF_AIRPORT');
                    }

                }
                //WMO-627 - ACAMBAS: End
            } else {
                tabsAux[i].active = false;
            }
        }

        this.lstTabs = tabsAux;

    }

    //WMO-627 - ACAMBAS: Begin
    onclickSubTab(event) {
            this.searchTextBranches = '';
            this.searchTextContacts = '';

            let clickedTab = event.target.dataset.item;

            //because proxy.......
            let tabsAux = JSON.parse(JSON.stringify(this.lstSubTabs));

            for (let i = 0; i < tabsAux.length; i++) {
                if (i + "" === clickedTab) {
                    tabsAux[i].active = true;

                    if (i == 0 && !this.iataInvoicesLoaded) {
                        //IATA Invoices
                        this.iataInvoicesLoaded = false;
                        this.retrieveInvoices('IATA_OFFICE');
                    } else if (i == 1 && !this.efInvoicesLoaded) {
                        //E&F Invoices
                        this.efInvoicesLoaded = false;
                        this.retrieveInvoices('EF_AIRPORT');
                    }
                } else {
                    tabsAux[i].active = false;
                }
            }

            this.lstSubTabs = tabsAux;
        }
        //WMO-627 - ACAMBAS: End

    handleNavigation(event) {
        let section = event.detail;
        let target = this.template.querySelector(`[data-name="${section}"]`);
        this.handleScrolling = false;

        target.scrollIntoView({ behavior: "smooth", block: "start" });

        this.timeout = setTimeout(function() {
            this.handleScrolling = true;
        }.bind(this), 2000);
    }

    createContact() {
        let contactList = this.template.querySelector('c-portal-contact-list');
        contactList.openModal();
    }


    retrieveContacts() {
        let offset = this.contactsOffset;
        getContacts({ offset: offset }).then(result => {
            this.isFetching = false;

            if (result.length == 0) {
                this.contactsEnded = true;
                this.contactsLoaded = true;
                return;
            }

            let loadedContacts = offset != 0 ? JSON.parse(JSON.stringify(this.contacts)) : [];
            this.contactsOffset = this.contactsOffset + result.length;
            let unwrappedContacts = this.processContacts(result, loadedContacts);

            this.contacts = unwrappedContacts; //contacts;
            this.contactsLoaded = true;
        });
    }

    processContacts(result, unwrappedContacts) {
        let contacts = JSON.parse(JSON.stringify(result));

        for (let i = 0; i < contacts.length; i++) {
            let contact = contacts[i].contact;
            let user = contacts[i].contactUser;
            let services = contacts[i].services;

            let locationType = contact.Account.Location_Type__c ? contact.Account.Location_Type__c : '';
            let iataCode = contact.IATA_Code__c ? contact.IATA_Code__c : '';

            contact.LocationCode = iataCode + ' ' + locationType;

            if (user && user.LastLoginDate != null) {
                let locale = user.LanguageLocaleKey.replace('_', '-');
                let lastLogin = new Date(user.LastLoginDate);
                contact.LastLoginDate = lastLogin;

                let day = lastLogin.getDate();
                let monthIndex = lastLogin.getMonth();
                let year = lastLogin.getFullYear();
                let month;

                try {
                    month = lastLogin.toLocaleString(locale, { month: "long" });
                    contact.LastLogin = month + ' ' + day + ', ' + year;
                } catch (e) {
                    contact.LastLogin = day + '.' + (monthIndex + 1) + '. ' + year;
                }
            }

            if (services != null) {
                contact.services = services;
            }

            contact.IsoCountry = (contact.Account.IATA_ISO_Country__r != null) ? contact.Account.IATA_ISO_Country__r.Name : '';

            unwrappedContacts.push(contact);

        }
        return unwrappedContacts;
    }

    getContacts() {
        this.contactsLoaded = false;
        this.retrieveContacts();
    }

    get contactsNotLoaded() {
        return !this.contactsLoaded;
    }

    retrieveBranches() {
        let offset = this.branchesOffset;
        getBranches({ offset: offset }).then(result => {

            this.isFetching = false;

            if (result.length == 0) {
                this.branchesEnded = true;
                this.branchesLoaded = true;
                return;
            }

            this.branchesOffset = this.branchesOffset + result.length;

            let existingBranches = offset != 0 ? JSON.parse(JSON.stringify(this.branches)) : [];

            let branches = JSON.parse(JSON.stringify(result));

            for (let i = 0; i < branches.length; i++) {
                let branch = branches[i];
                branch.LocationCode = branch.IATACode__c;
                if (branch.IATA_ISO_Country__r != null) {
                    branch.IsoCountry = branch.IATA_ISO_Country__r.Name;
                }
                existingBranches.push(branch);
            }

            this.branches = existingBranches;

            this.branchesLoaded = true;
        });
    }

    //WMO-627 - ACAMBAS: Begin
    retrieveInvoices(type) {
            let offset = 0; //this.invoicesOffset;

            getInvoices({ offset: offset, type: type }).then(result => {
                this.isFetching = false;

                if (result.length == 0) {
                    this.invoicesEnded = true;

                    if (type == 'IATA_OFFICE') {
                        this.iataInvoicesLoaded = true;
                        this.efInvoicesLoaded = false;
                    } else {
                        this.iataInvoicesLoaded = false;
                        this.efInvoicesLoaded = true;
                    }

                    return;
                }

                this.invoicesOffset = offset + result.length;
                let existingInvoices = offset != 0 ? JSON.parse(JSON.stringify(this.invoices)) : [];
                let invoices = JSON.parse(JSON.stringify(result));

                for (let i = 0; i < invoices.length; i++) {
                    existingInvoices.push(invoices[i]);
                }

                this.invoices = existingInvoices;

                if (type == 'IATA_OFFICE') {
                    this.iataInvoicesLoaded = true;
                    this.efInvoicesLoaded = false;
                } else {
                    this.iataInvoicesLoaded = false;
                    this.efInvoicesLoaded = true;
                }
            });
        }
        //WMO-627 - ACAMBAS: End

    getContactsFieldMap() {
        getContactsListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            this.contactFields = sectionMap;
        });
    }

    getBranchesFieldMap() {
        getBranchesListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            this.branchFields = sectionMap;
        });
    }

    //WMO-627 - ACAMBAS: Begin
    getInvoicesFieldMap() {
            getInvoicesListFields().then(result => {
                let sectionMap = JSON.parse(JSON.stringify(result));
                this.invoiceFields = sectionMap;
            });
        }
        //WMO-627 - ACAMBAS: End

    onchangeSearchInputContacts(event) {
        this.searchFromRedirect = false;
        this.searchTextContacts = event.target.value;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        this.timeout = setTimeout(() => {
            //this.testfunction();

            //let contactList = this.template.querySelector('c-portal-contact-list');

            this.contactsQuery = this.searchTextContacts;
            this.searchRecords('Contact');

        }, 500, this);

    }

    onchangeSearchInputContactsFromNotification(name) {
        this.searchTextContacts = name;
        this.searchFromRedirect = true;
        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        this.timeout = setTimeout(() => {
            //this.testfunction();

            //let contactList = this.template.querySelector('c-portal-contact-list');
            this.contactsQuery = this.searchTextContacts;

            this.searchRecords('Contact');

        }, 1000, this);

    }

    searchContacts(query) {
        searchContacts({ queryString: query, offset: this.contactsOffsetSearch }).then(result => {
            let contactList = this.template.querySelector('c-portal-contact-list');

            this.isFetching = false;
            this.searchMode = true;

            if (result.length == 0) {
                this.contactsEndedSearch = true;
                if (this.contactsOffsetSearch == 0) {
                    contactList.records = [];
                }
                return;
            }

            let contactsSearch = this.contactsSearch;
            let processed = this.processContacts(result, contactsSearch);

            contactList.recordsInitDone = false;
            contactList.records = processed;

            this.contactsOffsetSearch += result.length;
        });
    }

    searchBranches(query) {
        searchBranches({ queryString: query, offset: this.branchesOffsetSearch }).then(result => {
            let branchesList = this.template.querySelector('c-portal-contact-list');
            this.isFetching = false;
            this.searchMode = true;

            if (result.length == 0) {
                this.branchesEndedSearch = true;

                if (this.branchesOffsetSearch == 0) {
                    branchesList.records = [];
                }
                return;
            }

            let branches = JSON.parse(JSON.stringify(result));
            let branchesSearch = this.branchesSearch;

            for (let i = 0; i < branches.length; i++) {
                let branch = branches[i];
                branch.LocationCode = branch.IATACode__c;

                if (branch.IATA_ISO_Country__r != null) {
                    branch.IsoCountry = branch.IATA_ISO_Country__r.Name;
                }
                branchesSearch.push(branch);
            }

            branchesList.recordsInitDone = false;
            branchesList.records = branchesSearch;

            this.branchesOffsetSearch += result.length;
        });
    }

    searchRecords(sobjectType) {
        let query;

        if (sobjectType == 'Contact') {
            query = this.contactsQuery;
            this.contactsOffsetSearch = 0;
            this.contactsEndedSearch = false;
            this.contactsSearch = [];

            if (query == null || query.length == 0) {
                this.contactsOffset = 0;
                this.searchMode = false;
                this.contactsQuery = '';

                let recordList = this.template.querySelector('c-portal-contact-list');
                recordList.resetInit();
                this.retrieveContacts();
            } else {
                this.searchContacts(query);
            }
        } else if (sobjectType == 'Account') {

            query = this.branchesQuery;
            this.branchesOffsetSearch = 0;
            this.branchesEndedSearch = false;
            this.branchesSearch = [];

            if (query == null || query.length == 0) {
                this.branchesOffset = 0;
                this.searchMode = false;
                this.branchesQuery = '';

                let recordList = this.template.querySelector('c-portal-contact-list');
                recordList.resetInit();
                this.retrieveBranches();
            } else {
                this.searchBranches(query);
                this.searchMode = true;
            }
        }

    }

    onchangeSearchInputBranches(event) {
        this.searchFromRedirect = false;
        this.searchTextBranches = event.target.value;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        this.timeout = setTimeout(() => {
            //this.testfunction();
            this.branchesQuery = this.searchTextBranches;
            this.searchRecords('Account');

        }, 500, this);

    }

    loadMore() {
        if (this.tab0Active || this.searchFromRedirect) {
            return;
        }

        let offset;
        if (this.tab1Active && ((!this.searchMode && !this.branchesEnded) || (this.searchMode && !this.branchesEndedSearch))) {
            //Get more branches
            this.isFetching = true;
            offset = this.branchesOffset;

            let contactList = this.template.querySelector('c-portal-contact-list');
            contactList.resetInit();

            if (this.searchMode) {
                this.searchBranches(this.branchesQuery);
            } else {
                this.retrieveBranches();
            }
        }
        if (this.tab2Active && ((!this.searchMode && !this.contactsEnded) || (this.searchMode && !this.contactsEndedSearch))) {
            //Get more contacts
            this.isFetching = true;
            offset = this.contactsOffset;

            let contactList = this.template.querySelector('c-portal-contact-list');
            contactList.resetInit();

            if (this.searchMode) {
                this.searchContacts(this.contactsQuery);
            } else {
                this.retrieveContacts();
            }
        }


    }

    get tab0Active() { return this.lstTabs[0] != null && this.lstTabs[0].active; }
    get tab1Active() { return this.lstTabs[1] != null && this.lstTabs[1].active; }
    get tab2Active() { return this.lstTabs[2] != null && this.lstTabs[2].active; }
    get tab3Active() { return this.lstTabs[3] != null && this.lstTabs[3].active; }
    get tab4Active() { return this.lstTabs[4] != null && this.lstTabs[4].active; }
    get tab5Active() { return this.lstTabs[5] != null && this.lstTabs[5].active; }

    get subTab0Active() { return this.lstSubTabs[0] != null && this.lstSubTabs[0].active; }
    get subTab1Active() { return this.lstSubTabs[1] != null && this.lstSubTabs[1].active; }
}
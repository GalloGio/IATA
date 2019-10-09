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
import getContacts from '@salesforce/apex/PortalProfileCtrl.getAccountContacts';
import getBranches from '@salesforce/apex/PortalProfileCtrl.getCompanyBranches';
import searchContacts from '@salesforce/apex/PortalProfileCtrl.searchAccountContacts';
import searchBranches from '@salesforce/apex/PortalProfileCtrl.searchCompanyBranches';
import checkCanEdit from '@salesforce/apex/PortalProfileCtrl.checkCanEdit';
import goToOldIFAP from '@salesforce/apex/PortalProfileCtrl.goToOldIFAP';
import isAdminAndIATAAgencyAcct from '@salesforce/apex/PortalProfileCtrl.isAdminAndIATAAgencyAcct';
import getPortalAdmins from '@salesforce/apex/PortalServicesCtrl.getPortalAdmins';
import LANG from '@salesforce/i18n/lang';

import { getParamsFromPage } from 'c/navigationUtils';



import CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';
import FindBranch from '@salesforce/label/c.csp_Find_Branch';
import FindContact from '@salesforce/label/c.csp_Find_Contact';
import NewContact from '@salesforce/label/c.csp_CreateNewContact';
import NoAccount from '@salesforce/label/c.CSP_NoAccount';
import CSP_Branch_Offices from '@salesforce/label/c.CSP_Branch_Offices';
import ISSP_Contacts from '@salesforce/label/c.ISSP_Contacts';
import ISSP_Assign_IFAP from '@salesforce/label/c.ISSP_Assign_IFAP';
import CSP_Portal_Administrators from '@salesforce/label/c.CSP_Portal_Administrators';
import ContactNameLabel from '@salesforce/label/c.CSP_Name';
import EmailLabel from '@salesforce/label/c.Email';
import CountryLabel from '@salesforce/label/c.ISSP_Country';
import NoResults from '@salesforce/label/c.CSP_NoSearchResults';
import ISSP_Inactivate from '@salesforce/label/c.ISSP_Inactivate';
import ISSP_Activate from '@salesforce/label/c.ISSP_Activate';


import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';


export default class PortalCompanyProfilePage extends LightningElement {

    //icons
    searchColored = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    lang = LANG;

    constructor() {
        super();
        var self = this;
        window.addEventListener('scroll', function (e) { self.handleScroll(window.scrollY, self); });
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
    @track contactsWrapper = [];
    @track branches = [];
    @track branchesLoaded = false;
    @track contactsLoaded = false;
    @track branchFields;
    @track contactFields;
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
    @track branchesOffsetSearch = 0;
    @track contactsOffsetSearch = 0;
    @track contactsEnded = false;
    @track branchesEnded = false;
    @track isFetching = false;
    lastPosition;


    @track openmodel = false;
    @track recordid;
    @track objectid;
    @track objectName = "Contact";
    @track fieldsListToCreate = [];
    @track searchValue;

    @track showEdit = true;
    @track showIFAPBtn = false;
    // ------------------- //

    // Portal Admins
    @track hasPortalAdmins = false;
    @track portalAdminList = [];
    @track portalAdminColumns = [
        { label: ContactNameLabel, fieldName: 'Name' },
        { label: EmailLabel, fieldName: 'Email', type: 'text' },
        { label: CountryLabel, fieldName: 'Country' },
    ];

	@track tabName = '';
    
    @track showManageButtons = false;
    @track action = '';
    
    @wire(getPortalAdmins) 
    getPortalAdminList({ error, data }) {
        if(data) {
            this.portalAdminList = [];

            data.forEach(admin => {
                const portalAdmin = {};
                portalAdmin.Name = [admin.User.Contact.Salutation, admin.User.Contact.Name].filter(Boolean).join(" ");
                if(admin.User.Contact.User_Portal_Status__c !== 'Pending Approval') {
                    portalAdmin.Email = admin.User.Contact.Email;
                    portalAdmin.Country = admin.User.Contact.Account.BillingCountry;
                }
                
                this.portalAdminList.push( portalAdmin );
            });
            this.error = undefined;
        } else if(error) {
            console.error('error', JSON.parse(JSON.stringify(error)));
            this.error = error;
            this.portalAdminList = undefined;
        }

        this.hasPortalAdmins = this.portalAdminList && this.portalAdminList.length > 0 ? true : false;
    }


    get noAccount() {
        return (this.loggedUser == null || this.loggedUser.Contact == null || this.loggedUser.Contact.AccountId == null);
    }

    @track _labels = { CompanyInformation, FindBranch, FindContact, NewContact, NoAccount, CSP_Branch_Offices, ISSP_Contacts, ISSP_Assign_IFAP, CSP_Portal_Administrators, NoResults, ISSP_Inactivate, ISSP_Activate };
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }


    connectedCallback() {
        isAdmin().then(result => {
            this.isAdmin = result;

            let pageParams = getParamsFromPage();

            let viewContacts = false;
            if (pageParams.tab !== undefined && pageParams.tab !== '' && pageParams.tab === 'contact') {
                viewContacts = true;
            }

            let tabsAux = [];

            let tabNames = [this.labels.CompanyInformation, this.labels.CSP_Branch_Offices, this.labels.ISSP_Contacts]; //+'Company Calendar', 'Activity Log'];
            for (let i = 0; i < tabNames.length; i++) {

                let tabAux = {};
                //Only Portal Admin can see other tabs
                if (i === 0 || this.isAdmin) {
                    tabAux = {
                        active: !viewContacts,
                        label: tabNames[i],
                        id: i,
                        class: "slds-p-around_small cursorPointer text-darkGray"
                    };
                    if (i === 1) {
                        tabAux.active = false;
                    }
                    if (i === 2) {
                        tabAux.active = viewContacts;
                    }
                }
                tabsAux.push(tabAux);
            }

            let tabNameLocal;
            tabsAux.forEach( function(tab){
                if(tab.active) {
                    tabNameLocal = tab.label;
            }
            });

            this.tabName = tabNameLocal;

            let noSearch = false;

            if (pageParams.contactName !== undefined && pageParams.contactName !== '') {
                this.searchValue = decodeURIComponent((pageParams.contactName + '').replace(/\+/g, '%20'));
                this.onchangeSearchInputContactsFromNotification(this.searchValue);
            }else{
                noSearch = true
            }

            this.lstTabs = tabsAux;
            if (viewContacts) {
                if(!noSearch){
					this.contactsLoaded = true;
					this.isFetching = true;
					this.searchContacts(this.searchValue);
                }
            }

        });

        
        isAdminAndIATAAgencyAcct().then(result => {
            this.showIFAPBtn = result;
        });
        
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

        checkCanEdit().then(result => {
            this.showEdit = result;
        });

    }

    refreshview() {
        this.getContactsFieldMap();
        //For contacts tab

        this.getBranchesFieldMap();
        //For branches tab


        getFieldsMap({ type: 'CompanyProfile' }).then(result => {

            this.sectionMap = JSON.parse(JSON.stringify(result));

            this.mapOfValues = [];

            for(let i = 0; i < this.sectionMap.length; i++){
                this.mapOfValues.push({ 
                                    'value': this.sectionMap[i].lstFieldWrapper, 
                                    'key': this.sectionMap[i].cardTitle
                                });
            }

        });

        this.contactsOffset = 0;
        this.contacts = [];
        this.getContacts();
    }

    renderedCallback() {
        const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
        if (leftNav) {
            /* Set nav items for sticky navigation */
            let navItems = [];
            for(let i = 0; i < this.sectionMap.length; i++){
                navItems.push({ label: this.sectionMap[i].cardTitle, value: this.sectionMap[i].cardTitle, open: true });
            }
            navItems.push({ label: this.labels.CSP_Portal_Administrators, value: 'adminContacts', open: true });

            leftNav.navItems = navItems;
            leftNav.activesection = 'Basics';
        }


        // Scroll to specific section
        let pageParams = getParamsFromPage();

        if (pageParams.section !== undefined && pageParams.section !== '') {
            this.timeout = setTimeout(() => {
                leftNav.activesection = pageParams.section;
                this.handleNavigation({ detail: pageParams.section });
            }, 1500, this);
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
            let positionFromTop = sections[i].getBoundingClientRect().top;

            let triggerPosition = windowHeight / 2;
            if ((offsetTop - yposition < triggerPosition) && (offsetTop - yposition > - triggerPosition)) {
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
        let endPage = self.template.querySelector('.endOfPage');
        let wholePage = self.template.querySelector('.profilePageWrapper');

        let loadMoreTrigger = (window.innerHeight / 5) * 4;
        let treshhold = 250;

        let isFetching = this.isFetching;

        let lastPosition = this.lastPosition;

        if (Math.abs(wholePage.getBoundingClientRect().bottom - yposition) < treshhold) {//if((Math.abs(yposition-loadMoreTrigger) < treshhold)){
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

    onmouseleaveTab(event) {
        let clickedTab = event.target.dataset.item;

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray";
            } else {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray";
            }
        }

        this.lstTabs = tabsAux;
    }

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


            } else {
                tabsAux[i].active = false;
            }
        }

        this.lstTabs = tabsAux;

    }

    handleNavigation(event) {
        let section = event.detail;
        let target = this.template.querySelector(`[data-name="${section}"]`);
        this.handleScrolling = false;

        target.scrollIntoView({ behavior: "smooth", block: "start" });

        this.timeout = setTimeout(function () {
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
            let _oldContactsWrapper = offset !== 0 ? JSON.parse(JSON.stringify(this.contactsWrapper)) : [];
            let _contactsWrapper = JSON.parse(JSON.stringify(result));
            for (let i = 0; i < _contactsWrapper.length; i++) {
                _oldContactsWrapper.push(_contactsWrapper[i]);
            } 

            this.contactsWrapper = _oldContactsWrapper;
            this.isFetching = false;
            if (result.length == 0) { this.contactsEnded = true; this.contactsLoaded = true; return; }

            let loadedContacts = offset != 0 ? JSON.parse(JSON.stringify(this.contacts)) : [];
            this.contactsOffset = this.contactsOffset + result.length;
            let unwrappedContacts = this.processContacts(result, loadedContacts);

            this.contacts = unwrappedContacts; //contacts;
            this.contactsLoaded = true;
        });
    }

    processContacts(result, unwrappedContacts) {
        let contacts = JSON.parse(JSON.stringify(result));

        let locale = this.lang;

        for (let i = 0; i < contacts.length; i++) {
            let contact = contacts[i].contact;
            let user = contacts[i].contactUser;
            let services = contacts[i].services;
            let status = contact.User_Portal_Status__c;

            contact.PortalStatus = status;

            if (contact.Account.RecordType.Name === 'Airline Headquarters' || contact.Account.RecordType.Name === 'Airline Branch') {
                contact.LocationCode = (contact.hasOwnProperty('IATA_Code__c') ? contact.IATA_Code__c : '') + (contact.hasOwnProperty('Account_site__c') ? ' (' + contact.Account_site__c + ')' : '') + ')';
            } else if (contact.hasOwnProperty('IATA_Code__c') && contact.IATA_Code__c !== null ) {
                contact.LocationCode = contact.IATA_Code__c + (contact.Account.hasOwnProperty('BillingCity') ? ' (' + contact.Account.BillingCity + ')' : '');
            } else {
                contact.LocationCode = '';
            }

            if (user !== undefined) {
                if (user.hasOwnProperty('LastLoginDate')) {
                    if (user.LastLoginDate != null) {
                        let lastLogin = new Date(user.LastLoginDate);
                        contact.LastLoginDate = lastLogin;

                        let day = lastLogin.getDate();
                        let monthIndex = lastLogin.getMonth();
                        let year = lastLogin.getFullYear();
                        let month;

                        try {
                            month = lastLogin.toLocaleString(locale, { month: "long" });
                            contact.LastLogin = month + ' ' + day + ', ' + year;
                        }
                        catch (e) {
                            contact.LastLogin = day + '.' + (monthIndex + 1) + '. ' + year;
                        }
                    }
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
        this.contacts = [];
        this.contactsOffset = 0;
        this.retrieveContacts();
    }

    get contactsNotLoaded() {
        return !this.contactsLoaded;
    }

    retrieveBranches() {
        let offset = this.branchesOffset;
        getBranches({ offset: offset }).then(result => {

            this.isFetching = false;
            if (result.length == 0) { this.branchesEnded = true; this.branchesLoaded = true; return; }

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


    getContactsFieldMap() {
        getContactsListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            sectionMap.VIEW.forEach( element => {
                if(element.fieldName === 'ISSP_Account_Name__c') {
                    element.canChangeAccount = true;
                }
            });
            this.contactFields = sectionMap;
        });
    }

    getBranchesFieldMap() {
        getBranchesListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            this.branchFields = sectionMap;
        });
    }

    onchangeSearchInputContacts(event) {
        this.searchFromRedirect = false;
        this.searchTextContacts = event.target.value;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();

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
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();

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

                if(branch.IATA_ISO_Country__r != null){
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
        // eslint-disable-next-line @lwc/lwc/no-async-operation
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

    get canEditAccount(){
        return this.editBasics;
    }

    navigateToIFAP() { 
        goToOldIFAP({hasContact : false}).then(results => {
            window.open(results, "_self");
        });
    }

    get tab0Active() { return this.lstTabs[0] != null && this.lstTabs[0].active; }
    get tab1Active() { return this.lstTabs[1] != null && this.lstTabs[1].active; }
    get tab2Active() { return this.lstTabs[2] != null && this.lstTabs[2].active; }
    get tab3Active() { return this.lstTabs[3] != null && this.lstTabs[3].active; }
    get tab4Active() { return this.lstTabs[4] != null && this.lstTabs[4].active; }

    manageUsers(event) {
        let contactsSelected = event.detail;

        if((typeof contactsSelected === 'number' && contactsSelected !== 0) || (typeof contactsSelected === 'boolean' && contactsSelected === true)) {
            this.showManageButtons = true;
        } else {
            this.showManageButtons = false;
            this.action = '';
        }
    }

    grantAccess(event) {
        this.action = event.target.dataset.item;
    }

    denyAccess(event) {
        this.action = event.target.dataset.item;
    }
}
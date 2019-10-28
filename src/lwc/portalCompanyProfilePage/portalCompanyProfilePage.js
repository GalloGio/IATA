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
import No_Invoices_To_Display from '@salesforce/label/c.No_Invoices_To_Display'; //WMO-699 - ACAMBAS
import CSP_Branch_Offices from '@salesforce/label/c.CSP_Branch_Offices';
import ISSP_Contacts from '@salesforce/label/c.ISSP_Contacts';
import ISSP_Assign_IFAP from '@salesforce/label/c.ISSP_Assign_IFAP';
import CSP_Portal_Administrators from '@salesforce/label/c.CSP_Portal_Administrators';
import ContactNameLabel from '@salesforce/label/c.CSP_Name';
import EmailLabel from '@salesforce/label/c.Email';
import CountryLabel from '@salesforce/label/c.ISSP_Country';
import NoResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Outstanding_Invoices from '@salesforce/label/c.CSP_Outstanding_Invoices'; //WMO-627 - ACAMBAS


import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import IATA_Invoices from '@salesforce/label/c.CSP_IATA_Invoices'; //WMO-627 - ACAMBAS 
import EF_Invoices from '@salesforce/label/c.CSP_EF_Invoices'; //WMO-627 - ACAMBAS
import showIATAInvoices from '@salesforce/apex/PortalHeaderCtrl.showIATAInvoices'; //WMO-696 - ACAMBAS


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
    @track lstSubTabs = []; //WMO-627 - ACAMBAS
    @track contacts = [];
    @track branches = [];
    @track invoices = []; //WMO-627 - ACAMBAS
    @track branchesLoaded = false;
    @track contactsLoaded = false;
    @track iataInvoicesLoaded = false; //WMO-627 - ACAMBAS
    @track efInvoicesLoaded = false; //WMO-627 - ACAMBAS
    @track branchFields;
    @track contactFields;
    @track iataInvoiceFields; //WMO-627 - ACAMBAS
    @track efInvoiceFields; //WMO-627 - ACAMBAS
    @track editBasics = false;
    @track IATAInvoicesNum; //WMO-699 - ACAMBAS
    @track EFInvoicesNum; //WMO-699 - ACAMBAS
    @track TotalInvoicesNum; //WMO-699 - ACAMBAS

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

    @track showEdit = true;
    @track showIFAPBtn = false;

    //Flag that defines if the Outstanding Invoices tab is to be displayed or not
    @track displayInvoicesTab; //WMO-696 - ACAMBAS
    // ------------------- //

    IATA_INVOICE_TYPE = 'IATA OFFICE'; //WMO-627 - ACAMBAS
    EF_INVOICE_TYPE = 'E&F AIRPORT'; //WMO-627 - ACAMBAS
    

    // Portal Admins
    @track hasPortalAdmins = false;
    @track portalAdminList = [];
    @track portalAdminColumns = [
        { label: ContactNameLabel, fieldName: 'Name' },
        { label: EmailLabel, fieldName: 'Email', type: 'text' },
        { label: CountryLabel, fieldName: 'Country' },
    ];

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

    @track _labels = { CompanyInformation, FindBranch, FindContact, NewContact, NoAccount, CSP_Branch_Offices, ISSP_Contacts, ISSP_Assign_IFAP, CSP_Portal_Administrators, NoResults, CSP_Outstanding_Invoices, IATA_Invoices, EF_Invoices, No_Invoices_To_Display };
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }


    connectedCallback() {
        //WMO-696 - ACAMBAS: Begin
        showIATAInvoices().then(result => {
            this.displayInvoicesTab = result;
            this.displayTabs();
        });
        //WMO-696 - ACAMBAS: End

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

    displayTabs() { //WMO-627 - ACAMBAS
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

            let tabNames = [];
            if (this.displayInvoicesTab) { //WMO-696 - ACAMBAS
                tabNames = [this.labels.CompanyInformation, this.labels.CSP_Branch_Offices, this.labels.ISSP_Contacts, this.labels.CSP_Outstanding_Invoices]; //+'Company Calendar', 'Activity Log'];
            } else {
                tabNames = [this.labels.CompanyInformation, this.labels.CSP_Branch_Offices, this.labels.ISSP_Contacts];
            }


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

            this.getIATAInvoices();
        });
    }

    getIATAInvoices() {
        getInvoices({ offset: 0, type: this.IATA_INVOICE_TYPE }).then(result => {
            this.IATAInvoicesNum = result.length;
            this.displaySubTabs();
        });
    }

    displaySubTabs() {
        //Check if there are E&F Invoices
        getInvoices({ offset: 0, type: this.EF_INVOICE_TYPE }).then(result => {

            this.EFInvoicesNum = result.length; //WMO-699 - ACAMBAS

            let subTabsAux = [];
            let subTabNamesAux = [];

            //WMO-699 - ACAMBAS: Begin
            if (this.IATAInvoicesNum > 0) {
                subTabNamesAux.push(this.labels.IATA_Invoices);
            }
            if (this.EFInvoicesNum > 0) {
                subTabNamesAux.push(this.labels.EF_Invoices);
            }
            //WMO-699 - ACAMBAS: End

            for (let i = 0; i < subTabNamesAux.length; i++) {
                let subTabAux = {};

                subTabAux = {
                    label: subTabNamesAux[i],
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

            this.getInvoicesData();
        });
    }

    getInvoicesData() {
        if (this.IATAInvoicesNum > 0) {
            this.retrieveInvoices(this.IATA_INVOICE_TYPE);
        } else if (this.EFInvoicesNum > 0) {
            this.retrieveInvoices(this.EF_INVOICE_TYPE);
        }

        this.isFetching = true;
    }

    refreshview() {
        //For contacts tab
        this.getContactsFieldMap();

        //For branches tab
        this.getBranchesFieldMap();

        //For outstanding invoices tab
        this.getIATAInvoicesFieldMap(); //WMO-627 - ACAMBAS
        this.getEFInvoicesFieldMap(); //WMO-627 - ACAMBAS

        //For company information tab
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
            } else {
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
                else if (i == 3) {
                    if (this.lstSubTabs[0] != null && this.lstSubTabs[0].active && this.IATAInvoicesNum > 0) {
                        this.iataInvoicesLoaded = false;
                        this.retrieveInvoices(this.IATA_INVOICE_TYPE);
                    } else {
                        this.efInvoicesLoaded = false;
                        this.retrieveInvoices(this.EF_INVOICE_TYPE);
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
                        this.retrieveInvoices(this.IATA_INVOICE_TYPE);
                    } else if (i == 1 && !this.efInvoicesLoaded) {
                        //E&F Invoices
                        this.retrieveInvoices(this.EF_INVOICE_TYPE);
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

    //WMO-627 - ACAMBAS: Begin
    retrieveInvoices(type) {
            let offset = 0; //this.invoicesOffset;

            getInvoices({ offset: offset, type: type }).then(result => {
                this.isFetching = false;
                this.invoicesOffset = offset + result.length;
                let existingInvoices = offset != 0 ? JSON.parse(JSON.stringify(this.invoices)) : [];
                let invoices = JSON.parse(JSON.stringify(result));

                for (let i = 0; i < invoices.length; i++) {
                    existingInvoices.push(invoices[i]);
                }

                this.invoices = existingInvoices;

                if (type == this.IATA_INVOICE_TYPE) {
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

    //WMO-627 - ACAMBAS: Begin
    getIATAInvoicesFieldMap() {
        getInvoicesListFields({ invoiceType: this.IATA_INVOICE_TYPE }).then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            this.iataInvoiceFields = sectionMap;
        });
    }

    getEFInvoicesFieldMap() {
            getInvoicesListFields({ invoiceType: this.EF_INVOICE_TYPE }).then(result => {
                let sectionMap = JSON.parse(JSON.stringify(result));
                this.efInvoiceFields = sectionMap;
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

    get tab0Active() { return this.lstTabs[0] != null && this.lstTabs[0].active; } //company information
    get tab1Active() { return this.lstTabs[1] != null && this.lstTabs[1].active; } //branch offices
    get tab2Active() { return this.lstTabs[2] != null && this.lstTabs[2].active; } //contacts
    get tab3Active() { return this.lstTabs[3] != null && this.lstTabs[3].active; } //outstanding invoices
    get tab4Active() { return this.lstTabs[4] != null && this.lstTabs[4].active; }
    get tab5Active() { return this.lstTabs[5] != null && this.lstTabs[5].active; }

    get subTab0Active() { return this.lstSubTabs[0] != null && this.lstSubTabs[0].active && this.IATAInvoicesNum > 0 }
    get subTab1Active() { return (this.lstSubTabs[0] != null && this.lstSubTabs[0].active && this.IATAInvoicesNum == 0 && this.EFInvoicesNum > 0) || (this.lstSubTabs[1] != null && this.lstSubTabs[1].active); }
    get hasNoInvoices() { return (this.IATAInvoicesNum + this.EFInvoicesNum) === 0; } //WMO-699 - ACAMBAS
}

import { LightningElement,track } from 'lwc';

import goToOldIFAP from '@salesforce/apex/PortalProfileCtrl.goToOldIFAP';
import getContactsListFields from '@salesforce/apex/PortalProfileCtrl.getContactsListFields';
import getContactFieldsToInsert from '@salesforce/apex/PortalProfileCtrl.getContactFieldsToInsert';
import searchForCompanyContacts from '@salesforce/apex/PortalProfileCtrl.searchForCompanyContacts';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import LANG from '@salesforce/i18n/lang';

import csp_Find_Branch from '@salesforce/label/c.csp_Find_Branch';
import ISSP_Inactivate from '@salesforce/label/c.ISSP_Inactivate';
import ISSP_Activate from '@salesforce/label/c.ISSP_Activate';
import ISSP_Assign_IFAP from '@salesforce/label/c.ISSP_Assign_IFAP';
import csp_CreateNewContact from '@salesforce/label/c.csp_CreateNewContact';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCompanyProfileContactsList extends LightningElement {

    //icons
    searchColored = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    lang = LANG;

    label = {
        csp_Find_Branch,
        ISSP_Activate,
        ISSP_Inactivate,
        ISSP_Assign_IFAP,
        csp_CreateNewContact
    };

    @track contactsLoaded = false;

    @track contactsFilteringObject = {
        searchInput : '',
        sortField : 'Name',
        sortDirection : 'ASC',
        firstLetter : 'All'
    };

    /*@track paginationObject = {
        totalItems : 15,
        currentPage : 1,
        pageSize : 10,
        maxPages : 5
    }*/


    @track showManageButtons = false;
    @track contactFields;
    @track fieldsListToCreate = [];
    @track contacts = [];
    @track currentPage = 1;
    //@track contactsCount = 0;
    @track contactsWrapper = [];
    @track openmodel = false;
    @track recordid;
    @track accountId;
    @track objectid;
    @track action = '';

    @track alphaFilters = [
        {letter : 'A', selected : false},
        {letter : 'B', selected : false},
        {letter : 'C', selected : false},
        {letter : 'D', selected : false},
        {letter : 'E', selected : false},
        {letter : 'F', selected : false},
        {letter : 'G', selected : false},
        {letter : 'H', selected : false},
        {letter : 'I', selected : false},
        {letter : 'J', selected : false},
        {letter : 'K', selected : false},
        {letter : 'L', selected : false},
        {letter : 'M', selected : false},
        {letter : 'N', selected : false},
        {letter : 'O', selected : false},
        {letter : 'P', selected : false},
        {letter : 'Q', selected : false},
        {letter : 'R', selected : false},
        {letter : 'S', selected : false},
        {letter : 'T', selected : false},
        {letter : 'U', selected : false},
        {letter : 'V', selected : false},
        {letter : 'W', selected : false},
        {letter : 'X', selected : false},
        {letter : 'Y', selected : false},
        {letter : 'Z', selected : false},
        {letter : 'Other', selected : false},
        {letter : 'All', selected : true}
    ];

    connectedCallback(){

        getContactsListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            sectionMap.VIEW.forEach( element => {
                if(element.fieldName === 'ISSP_Account_Name__c') {
                    element.canChangeAccount = true;
                }
            });
            this.contactFields = sectionMap;
        });

        getContactFieldsToInsert().then(result => {
            this.fieldsListToCreate = result;
        });

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
            this.objectid = this.loggedUser.Contact.AccountId;
            this.userLoaded = true;
        });


        //init the contacts list
        this.resetContactsList();
    }

    //resets and recalls the first branches page
    resetContactsList(){
        this.contacts = [];
        this.contactsFilteringObject.searchInput = '';
        this.currentPage = 1;
        //this.contactsCount = 0;

        this.retrieveContactsList(this.currentPage);
    }

    retrieveContactsList(requestedPage) {
        let requestedPageAux = requestedPage - 1;

        searchForCompanyContacts({ 
            companybranchFilterWrapper: JSON.stringify(this.contactsFilteringObject), 
            requestedPage: requestedPageAux + '' 
        })
        .then(result => {
            let contactsListAux = JSON.parse(result.recordsString);

            //first return contains the total records count
            /*if(requestedPage === 1){
                this.contactsCount = result.totalItemCount;
            }*/
            //process contact records
            this.contactsWrapper = JSON.parse(JSON.stringify(contactsListAux));
            this.contacts = this.processContacts(contactsListAux);
            

            /*this.paginationObject = {
                totalItems : this.contactsCount,
                currentPage : requestedPage,
                pageSize : 10,
                maxPages : 3
            }*/

            this.contactsLoaded = true;
        });
    }

    processContacts(contacts) {
        let contactListAux = [];

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

            contactListAux.push(contact);

        }
        return contactListAux;
    }

    /*
    //receives the event from the pagination component and requestes the contact page
    handleSelectedPage(event){
        //the event contains the selected page
        let requestedPage = event.detail;

        this.contactsLoaded = false;
        this.retrieveContactsList(requestedPage);
    }*/

    //event fired when search text changes
    onchangeContactsSearchText(event){
        let searchtext = event.target.value;

        this.contactsFilteringObject.searchInput = searchtext;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();

            this.contactsLoaded = false;
            this.retrieveContactsList(1);

        }, 500, this);
    }

    changeAlphaFilterLetter(event){
        let filterLetter = event.target.dataset.item;
        //console.log('filterLetter: ' , filterLetter);

        let alphaFiltersAux = JSON.parse(JSON.stringify(this.alphaFilters));
        for(let i = 0; i < alphaFiltersAux.length; i++ ){
            alphaFiltersAux[i].selected = alphaFiltersAux[i].letter === filterLetter;
        }
        this.alphaFilters = alphaFiltersAux;
        this.contactsFilteringObject.firstLetter = filterLetter;
        this.contactsLoaded = false;
        this.showManageButtons = false;
        this.retrieveContactsList(1);
    }

    createContact() {
        let contactList = this.template.querySelector('c-portal-contact-list');
        contactList.openModal();
    }

    get contactsNotLoaded() {
        return !this.contactsLoaded;
    }

    navigateToIFAP() { 
        goToOldIFAP({hasContact : false}).then(results => {
            window.open(results, "_self");
        });
    }

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
import { LightningElement,track,api } from 'lwc';

import goToOldIFAP from '@salesforce/apex/PortalProfileCtrl.goToOldIFAP';
import getContactsListFields from '@salesforce/apex/PortalProfileCtrl.getContactsListFields';
import getContactFieldsToInsert from '@salesforce/apex/PortalProfileCtrl.getContactFieldsToInsert';
import searchForCompanyContacts from '@salesforce/apex/PortalProfileCtrl.searchForCompanyContacts';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import LANG from '@salesforce/i18n/lang';

import csp_Find_Contact from '@salesforce/label/c.csp_Find_Contact';
import ISSP_Inactivate from '@salesforce/label/c.ISSP_Inactivate';
import ISSP_Activate from '@salesforce/label/c.ISSP_Activate';
import ISSP_Assign_IFAP from '@salesforce/label/c.ISSP_Assign_IFAP';
import csp_CreateNewContact from '@salesforce/label/c.csp_CreateNewContact';
import ISSP_Download from '@salesforce/label/c.ISSP_Download';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ISSP_Pending_Approval from '@salesforce/label/c.ISSP_Pending_Approval';
import CSP_ALPHAFILTER_All from '@salesforce/label/c.CSP_ALPHAFILTER_All';
import CSP_ALPHAFILTER_Other from '@salesforce/label/c.CSP_ALPHAFILTER_Other';

export default class PortalCompanyProfileContactsList extends LightningElement {

    //icons
    searchColored = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    lang = LANG;

    label = {
        csp_Find_Contact,
        ISSP_Activate,
        ISSP_Inactivate,
        ISSP_Assign_IFAP,
        csp_CreateNewContact,
        ISSP_Download,
        ISSP_Pending_Approval,
        CSP_ALPHAFILTER_All,
        CSP_ALPHAFILTER_Other
    };

    @api 
    reloadData(){
        //reloads Data when the Contacts tab (active) is clicked
        if(this.contactsFilteringObject.searchInput !== ''){
            this.removeTextSearch();
        }
    }

    @track contactsLoaded = false;

    @track contactsFilteringObject = {
        searchInput: '',
        sortField: 'Name',
        sortDirection: 'ASC',
        firstLetter: 'All'
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
    @track showCross = false;

    @track alphaFiltersNormal = [
        { value:'A', label: 'A', selected: false },
        { value:'B', label: 'B', selected: false },
        { value:'C', label: 'C', selected: false },
        { value:'D', label: 'D', selected: false },
        { value:'E', label: 'E', selected: false },
        { value:'F', label: 'F', selected: false },
        { value:'G', label: 'G', selected: false },
        { value:'H', label: 'H', selected: false },
        { value:'I', label: 'I', selected: false },
        { value:'J', label: 'J', selected: false },
        { value:'K', label: 'K', selected: false },
        { value:'L', label: 'L', selected: false },
        { value:'M', label: 'M', selected: false },
        { value:'N', label: 'N', selected: false },
        { value:'O', label: 'O', selected: false },
        { value:'P', label: 'P', selected: false },
        { value:'Q', label: 'Q', selected: false },
        { value:'R', label: 'R', selected: false },
        { value:'S', label: 'S', selected: false },
        { value:'T', label: 'T', selected: false },
        { value:'U', label: 'U', selected: false },
        { value:'V', label: 'V', selected: false },
        { value:'W', label: 'W', selected: false },
        { value:'X', label: 'X', selected: false },
        { value:'Y', label: 'Y', selected: false },
        { value:'Z', label: 'Z', selected: false },
        { value:'Other', label: this.label.CSP_ALPHAFILTER_Other, selected: false },
        { value:'All', label: this.label.CSP_ALPHAFILTER_All, selected: true }
    ];

    @track alphaFiltersMobile = [
        { value:'All', label: this.label.CSP_ALPHAFILTER_All, selected: true },
        { value:'Other', label: this.label.CSP_ALPHAFILTER_Other, selected: false },
        { value:'A', label: 'A', selected: false },
        { value:'B', label: 'B', selected: false },
        { value:'C', label: 'C', selected: false },
        { value:'D', label: 'D', selected: false },
        { value:'E', label: 'E', selected: false },
        { value:'F', label: 'F', selected: false },
        { value:'G', label: 'G', selected: false },
        { value:'H', label: 'H', selected: false },
        { value:'I', label: 'I', selected: false },
        { value:'J', label: 'J', selected: false },
        { value:'K', label: 'K', selected: false },
        { value:'L', label: 'L', selected: false },
        { value:'M', label: 'M', selected: false },
        { value:'N', label: 'N', selected: false },
        { value:'O', label: 'O', selected: false },
        { value:'P', label: 'P', selected: false },
        { value:'Q', label: 'Q', selected: false },
        { value:'R', label: 'R', selected: false },
        { value:'S', label: 'S', selected: false },
        { value:'T', label: 'T', selected: false },
        { value:'U', label: 'U', selected: false },
        { value:'V', label: 'V', selected: false },
        { value:'W', label: 'W', selected: false },
        { value:'X', label: 'X', selected: false },
        { value:'Y', label: 'Y', selected: false },
        { value:'Z', label: 'Z', selected: false }
    ];

    connectedCallback() {

        getContactsListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));
            sectionMap.VIEW.forEach(element => {
                if (element.fieldName === 'ISSP_Account_Name__c') {
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
        this.contactsLoaded = false;
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
            } else if (contact.hasOwnProperty('IATA_Code__c') && contact.IATA_Code__c !== null) {
                contact.LocationCode = contact.IATA_Code__c + (contact.Account.hasOwnProperty('BillingCity') ? ' (' + contact.Account.BillingCity + ')' : '');
            } else {
                contact.LocationCode = '';
            }

            if (user !== undefined && user !== null && user.LastLoginDate !== undefined && user.LastLoginDate !== null) {
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
            this.showCross = searchtext.length > 0;
        }, 500, this);
    }

    handleChangeAlphaFilterNormal(event){
        let filterLetter = event.target.dataset.item;
        //console.log('filterLetter: ' , filterLetter);
        this.changeAlphaFilterLetter(filterLetter);
    }

    handleChangeAlphaFilterMobile(event){
        let selectedOption = event.detail.value;
        this.changeAlphaFilterLetter(selectedOption);
    }

    changeAlphaFilterLetter(filterLetter) {
        //change normal version 
        let alphaFiltersAux = JSON.parse(JSON.stringify(this.alphaFiltersNormal));
        for (let i = 0; i < alphaFiltersAux.length; i++) {
            alphaFiltersAux[i].selected = alphaFiltersAux[i].value === filterLetter;
        }
        this.alphaFiltersNormal = alphaFiltersAux;

        //change mobile version
        let alphaFiltersMobileAux = JSON.parse(JSON.stringify(this.alphaFiltersMobile));
        for (let i = 0; i < alphaFiltersMobileAux.length; i++) {
            alphaFiltersMobileAux[i].selected = alphaFiltersMobileAux[i].value === filterLetter;
        }
        this.alphaFiltersMobile = alphaFiltersMobileAux;

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

    getAllContactsToExport() {
        this.contactsLoaded = false;

        let allContactsFilteringObject = {
            searchInput : '',
            sortField : 'Name',
            sortDirection : 'ASC',
            firstLetter : 'All'
        };

        searchForCompanyContacts({ 
            companybranchFilterWrapper: JSON.stringify(allContactsFilteringObject), 
            requestedPage: '1' 
        })
            .then(result => {
                this.allContacts = this.processContacts(JSON.parse(result.recordsString), []);
                this.downloadCSV();
            })
            .catch(error => {
                this.contactsLoaded = true;
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);
        });
    }

    downloadCSV() {
        let rowEnd = '\n';
        let csvString = '';
        let rowDataLabel = new Set();
        let rowDataFieldsMap = [];
        let allContacts = this.contactFields.ROWS;

        // CSV Header
        allContacts.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowDataLabel.add(record.label);
                rowDataFieldsMap[record.fieldName] = record.label;
            });
        });

        rowDataLabel = Array.from(rowDataLabel);
        csvString += rowDataLabel.join(','); // columns
        csvString += rowEnd;

        // get the data from allContacts based on key value (columns name) from rowDataFieldsMap
        for(let i=0; i < this.allContacts.length; i++) {
            let colValue = 0;

            for(let key in rowDataFieldsMap) {
                if(rowDataFieldsMap.hasOwnProperty(key)) {
                    let rowKey = key; // get columns name
                    
                    if(colValue > 0) {
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV.
                    let value = this.allContacts[i][rowKey] === undefined ? '' : this.allContacts[i][rowKey]; 
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURIComponent(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'exportContacts.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
        this.contactsLoaded = true;
    }    

    removeTextSearch() {
        this.showCross = false;
        this.contactsLoaded = false;
        this.resetContactsList();
    }
}
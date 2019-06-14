/**
 * Created by pvavruska on 5/23/2019.
 */

import { LightningElement, wire, track } from 'lwc';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import getFieldsMap from '@salesforce/apex/PortalProfileCtrl.getFieldsMap';
import getContactFieldsToInsert from '@salesforce/apex/PortalProfileCtrl.getContactFieldsToInsert';
import getContactsListFields from '@salesforce/apex/PortalProfileCtrl.getContactsListFields';
import getBranchesListFields from '@salesforce/apex/PortalProfileCtrl.getBranchesListFields';
import getContacts from '@salesforce/apex/PortalProfileCtrl.getAccountContacts';
import getBranches from '@salesforce/apex/PortalProfileCtrl.getCompanyBranches';




import CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';
import FindBranch from '@salesforce/label/c.csp_Find_Branch';
import FindContact from '@salesforce/label/c.csp_Find_Contact';
import NewContact from '@salesforce/label/c.csp_CreateNewContact';
import NoAccount from '@salesforce/label/c.CSP_NoAccount';
import CSP_Branch_Offices from '@salesforce/label/c.CSP_Branch_Offices';
import ISSP_Contacts from '@salesforce/label/c.ISSP_Contacts';




export default class PortalCompanyProfilePage extends LightningElement {

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
    @track branches = [];
    @track branchesLoaded = false;
    @track contactsLoaded = false;
    @track branchFields;
    @track contactFields;
    @track searchTextContacts;
    @track searchTextBranches;

    @track openmodel = false;
    @track recordid;
    @track objectid;
    @track objectName = "Contact";
    @track fieldsListToCreate = [];
    // ------------------- //



    get noAccount() {
        return (this.loggedUser == null || this.loggedUser.Contact == null || this.loggedUser.Contact.AccountId == null);
    }

    _labels = {CompanyInformation,FindBranch,FindContact,NewContact,NoAccount,CSP_Branch_Offices,ISSP_Contacts};
    get labels() {return this._labels;}
    set labels(value) {this._labels = value;}


    connectedCallback() {
        isAdmin().then(result =>{
           this.isAdmin = result;
        });

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
            this.objectid = this.loggedUser.Contact.AccountId;
            this.userLoaded = true;
        });

        this.getContactsFieldMap();//For contacts tab
        this.getBranchesFieldMap();//For branches tab


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

        let tabsAux = [];

        let tabNames = [this.labels.CompanyInformation,this.labels.CSP_Branch_Offices,this.labels.ISSP_Contacts]; //+'Company Calendar', 'Activity Log'];
        for (let i = 0; i < tabNames.length; i++) {

            //Only Portal Admin can see other tabs
            if(i > 0 && this.isAdmin){

            }

            tabsAux.push({
                "active": (i == 0),
                "label": tabNames[i],
                "id": i,
                "class": "slds-p-around_small cursorPointer text-darkGray"
            });
        }

        this.lstTabs = tabsAux;

        getContactFieldsToInsert().then(result => {
            this.fieldsListToCreate = result;
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
        let clickedTab = event.target.dataset.item;
        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        //Add onclick method to retrieve Accounts/Contacts
        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].active = true;

                if(i == 1 && !this.branchesLoaded){
                    //Branches
                    this.retrieveBranches();
                }else if(i == 2 && !this.contactsLoaded){
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

    createContact(){
        let contactList = this.template.querySelector('c-portal-contact-list');
        contactList.openModal();
    }


    retrieveContacts(){
        getContacts().then(result => {
            //this.contacts
            let contacts = JSON.parse(JSON.stringify(result));
            let unwrappedContacts = [];
            for(let i=0;i<contacts.length;i++){
                let contact = contacts[i].contact;
                let user = contacts[i].contactUser;


                contact.LocationCode = contact.IATA_Code__c+' '+contact.Account.Location_Type__c;
                if(user.LastLoginDate != null){
                    let locale = user.LanguageLocaleKey.replace('_','-');
                    let lastLogin = new Date(user.LastLoginDate);
                    contact.LastLoginDate = lastLogin;

                    let day = lastLogin.getDate();
                    let monthIndex = lastLogin.getMonth();
                    let year = lastLogin.getFullYear();
                    let month;

                    try{
                        month = lastLogin.toLocaleString(locale, { month: "long" });
                        contact.LastLogin = month+' '+day+', '+year;
                    }
                    catch(e){
                        contact.LastLogin = day+'.'+(monthIndex+1)+'. '+year;
                    }
                 }
                //contact.LastLogin = user.LastLoginDate;
                contact.IsoCountry = contact.Account.IATA_ISO_Country__r.Name;
                unwrappedContacts.push(contact);

            }
            this.contacts = unwrappedContacts; //contacts;
            this.contactsLoaded = true;
        });
    }

    getContacts(){
        this.contactsLoaded = false;
        this.retrieveContacts();
    }
    
    get contactsNotLoaded(){
        return !this.contactsLoaded;
    }

    retrieveBranches(){

        getBranches().then(result => {

            let branches = JSON.parse(JSON.stringify(result));
            for(let i=0;i<branches.length;i++){
                let branch = branches[i];
                branch.LocationCode = branch.IATACode__c;
                branch.IsoCountry = branch.IATA_ISO_Country__r.Name;
            }
            this.branches = branches;
            this.branchesLoaded = true;
        });
    }


    getContactsFieldMap(){
        getContactsListFields().then(result => {
           let sectionMap = JSON.parse(JSON.stringify(result));

           let localMap = [];
           for (let key in sectionMap) {
               // Preventing unexcepted data
               if (sectionMap.hasOwnProperty(key)) { // Filtering the data in the loop
                   let value = sectionMap[key];
                   localMap.push({ 'value': value, 'key': key });
               }
           }

           //this.contactFields = localMap;
           this.contactFields = sectionMap;
        });
    }

    getBranchesFieldMap(){
        getBranchesListFields().then(result => {
            let sectionMap = JSON.parse(JSON.stringify(result));

            let localMap = [];
            for (let key in sectionMap) {
                // Preventing unexcepted data
                if (sectionMap.hasOwnProperty(key)) { // Filtering the data in the loop
                    let value = sectionMap[key];
                    localMap.push({ 'value': value, 'key': key });
                }
            }
            //this.contactFields = localMap;
            this.branchFields = sectionMap;
         });
    }

    onchangeSearchInputContacts(event){
            this.searchTextContacts = event.target.value;

            // Clear the timeout if it has already been set.
            // This will prevent the previous task from executing
            // if it has been less than <MILLISECONDS>
            clearTimeout(this.timeout);

            // Make a new timeout set to go off in 1500ms
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.timeout = setTimeout(() => {
                //this.testfunction();

                let contactList = this.template.querySelector('c-portal-contact-list');

                if(this.searchTextContacts.length > 0){
                    contactList.searchRecords(this.searchTextContacts);
                }else{
                    contactList.searchRecords(null);
                }

            }, 500, this);

    }

    onchangeSearchInputBranches(event){
        this.searchTextBranches = event.target.value;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();
            let branchList = this.template.querySelector('c-portal-contact-list');

            if(this.searchTextBranches.length > 0){
                branchList.searchRecords(this.searchTextBranches);
            }else{
                branchList.searchRecords(null);
            }

        }, 500, this);

        }

    get tab0Active() { return this.lstTabs[0].active; }
    get tab1Active() { return this.lstTabs[1].active; }
    get tab2Active() { return this.lstTabs[2].active; }
    //get tab3Active() { return this.lstTabs[3].active; }
    //get tab4Active() { return this.lstTabs[4].active; }
}
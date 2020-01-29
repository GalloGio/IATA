import { LightningElement, track, wire } from 'lwc';

import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import canEditBasics from '@salesforce/apex/PortalProfileCtrl.canEditBasics';
import getFieldsMap from '@salesforce/apex/PortalProfileCtrl.getFieldsMap';
import getPortalAdmins from '@salesforce/apex/PortalServicesCtrl.getPortalAdmins';

import { getParamsFromPage } from 'c/navigationUtils';

import CSP_Portal_Administrators from '@salesforce/label/c.CSP_Portal_Administrators';
import CSP_Name from '@salesforce/label/c.CSP_Name';
import Email from '@salesforce/label/c.Email';
import ISSP_Country from '@salesforce/label/c.ISSP_Country';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';


import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCompanyProfileInformation extends LightningElement {

    //icons
    searchColored = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    constructor() {
        super();
        let self = this;
        window.addEventListener('scroll', function (e) { self.handleScroll(window.scrollY, self); });
    }

    @track mapOfValues = [];

    @track sectionMap = [];
    @track handleScrolling = true;
    @track userLoaded = false;
    @track currentSection;

    @track editBasics = false;


    // ------------------- //

    // Portal Admins
    @track hasPortalAdmins = false;
    @track portalAdminList = [];
    @track portalAdminColumns = [
        { label: CSP_Name, fieldName: 'Name' },
        { label: Email, fieldName: 'Email', type: 'text' },
        { label: ISSP_Country, fieldName: 'Country' },
    ];


    @track tabName = CompanyInformation;

    @wire(getPortalAdmins) 
    getPortalAdminList({ error, data }) {
        if(data) {
            this.portalAdminList = [];

            data.forEach(admin => {
                if(admin.User.Contact !== undefined && admin.User.Contact !== null) {
                    const portalAdmin = {};
                    portalAdmin.Name = [admin.User.Contact.Salutation, admin.User.Contact.Name].filter(Boolean).join(" ");
                    if(admin.User.Contact.User_Portal_Status__c !== 'Pending Approval') {
                        portalAdmin.Email = admin.User.Contact.Email;
                        portalAdmin.Country = admin.User.Contact.Account.BillingCountry;
                    }
                    
                    this.portalAdminList.push( portalAdmin );
                }
            });
            this.error = undefined;
        } else if(error) {
            this.portalAdminList = undefined;
        }

        this.hasPortalAdmins = this.portalAdminList && this.portalAdminList.length > 0 ? true : false;
    }

    @track _labels = {
        CSP_Portal_Administrators, 
        CSP_NoSearchResults};
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }


    connectedCallback() {

        canEditBasics().then(result => {
            this.editBasics = result;
        });

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
        });

        getFieldsMap({ type: 'CompanyProfile' }).then(result => {
            this.sectionMap = JSON.parse(JSON.stringify(result));
            this.mapOfValues = [];
            for(let i = 0; i < this.sectionMap.length; i++){
                this.mapOfValues.push({ 
                    'value': this.sectionMap[i].lstFieldWrapper, 
                    'key': this.sectionMap[i].cardTitle
                });
            }

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
        });
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
            if ((offsetTop - yposition < triggerPosition) && (offsetTop - yposition > - triggerPosition)) {
                if (self.currentSection !== sectionName) {
                    self.currentSection = sectionName;
                    const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
                    if (leftNav) {
                        leftNav.activesection = sectionName;
                    }
                }
            }
        }
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

    get canEditAccount(){
        return this.editBasics;
    }

}
import { LightningElement, track, api } from 'lwc';

import getFieldsMap from '@salesforce/apex/PortalProfileCtrl.getFieldsMap';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import getServices from '@salesforce/apex/PortalServicesCtrl.getUserAccessGrantedServices';

import getContactDetails from '@salesforce/apex/PortalMyProfileCtrl.getContactInfo';

import IdCard from '@salesforce/label/c.CSP_Id_Card';

export default class PortalMyProfilePage extends LightningElement {

    constructor() {
        super();
        var self = this;
        window.addEventListener('scroll', function (e) { self.handleScroll(window.scrollY, self); });
    }

    @track services = [];
    @track contactInfo;

    @track handleScrolling = true;
    @track currentSection;
    @track sectionMapContact = [];
    @track sectionMapAccount = [];

    @track loggedUser;

    @track mapOfValuesContact = [];
    @track mapOfValuesAccount = [];

    connectedCallback() {

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
        });

        this.refreshview();

        /* Hide business contact section for now*/
        //this.getBusinessContact();

        getServices().then(result => {
            this.services = result;
        });

        getContactDetails().then(result => {
            let contact = result.contact;
            contact.cardName   = result.cardName   !== undefined ? result.cardName   : undefined;
            contact.cardPhoto  = result.cardPhoto  !== undefined ? result.cardPhoto  : undefined;
            contact.cardNumber = result.cardNumber !== undefined ? result.cardNumber : undefined;
            contact.cardDate   = result.cardDate   !== undefined ? result.cardDate   : undefined;
            contact.cardStatus = result.cardStatus !== undefined ? result.cardStatus : undefined;

            this.contactInfo = contact;
        });

    }

    renderedCallback() {
        let sections = this.template.querySelectorAll('.section');

        const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
        if (leftNav) {
            let navItems = [];

            for(let i = 0; i < this.sectionMapContact.length; i++){
                navItems.push({ label: this.sectionMapContact[i].cardTitle, value: this.sectionMapContact[i].cardTitle, open: true });
            }

            for(let i = 0; i < this.sectionMapAccount.length; i++){
                navItems.push({ label: this.sectionMapAccount[i].cardTitle, value: this.sectionMapAccount[i].cardTitle, open: true });
            }

            leftNav.navItems = navItems;
            leftNav.activesection = 'Basics';
        }
    }

    refreshview() {
        getFieldsMap({ type: 'MyProfile' }).then(result => {

            this.sectionMapContact = JSON.parse(JSON.stringify(result));
            let sectionMapContactLocal = JSON.parse(JSON.stringify(result));

            this.mapOfValuesContact = [];
            let mapOfValuesContactLocal = [];

            for (let i = 0; i < sectionMapContactLocal.length; i++) {
                mapOfValuesContactLocal.push({
                    'value': sectionMapContactLocal[i].lstFieldWrapper,
                    'key': sectionMapContactLocal[i].cardTitle,
                    'showfunction': (sectionMapContactLocal[i].cardTitle === 'Professional'),
                    'isEditable': sectionMapContactLocal[i].isEditable
                    'isEditIdCard': (sectionMapContactLocal[i].cardTitle === IdCard),
		    'sectionKeyName': sectionMapContactLocal[i].cardKey,
                    'idCardRedirectionUrl':sectionMapContactLocal[i].idCardUrl
                });
            }

            this.mapOfValuesContact = mapOfValuesContactLocal;

        });
    }


    navItemSelected(event) {
        this.navItem = event.detail.item;
    }

    handleScroll(yposition, self) {
        if (!this.handleScrolling) { return; }
        let sections = self.template.querySelectorAll('.section');

        for (let i = 0; i < sections.length; i++) {
            let offsetTop = sections[i].offsetTop;
            let sectionName = sections[i].attributes.getNamedItem('data-name').value;

            if ((offsetTop - yposition < 200) && (offsetTop - yposition > -200)) {
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

    handleNavigation(event) {
        let section = event.detail;
        let target = this.template.querySelector(`[data-name="${section}"]`);
        this.handleScrolling = false;

        target.scrollIntoView({ behavior: "smooth", block: "start" });

        this.timeout = setTimeout(function () {
            this.handleScrolling = true;
        }.bind(this), 1000);
    }

    getBusinessContact(){
        getFieldsMap({ type: 'MyProfileAccFields' }).then(result => {

            this.sectionMapAccount = JSON.parse(JSON.stringify(result));

            this.mapOfValuesAccount = [];

            for(let i = 0; i < this.sectionMapAccount.length; i++){
                this.mapOfValuesAccount.push({ 
                                    'value': this.sectionMapAccount[i].lstFieldWrapper, 
                                    'key': this.sectionMapAccount[i].cardTitle, 
                                    'isEditable' : this.sectionMapAccount[i].isEditable
                                });
            }
        });
    }

}
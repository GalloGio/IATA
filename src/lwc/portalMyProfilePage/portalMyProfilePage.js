import { LightningElement, track, api } from 'lwc';

import getFieldsMap from '@salesforce/apex/PortalProfileCtrl.getFieldsMap';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import getServices from '@salesforce/apex/PortalServicesCtrl.getUserAccessGrantedServices';

import getContactDetails from '@salesforce/apex/PortalMyProfileCtrl.getContactInfo';
import getContactTrainingDetails from '@salesforce/apex/PortalMyProfileCtrl.getContactTrainingInfo';
import getContactCertifications from '@salesforce/apex/PortalMyProfileCtrl.getContactCertificationInfo';


export default class PortalMyProfilePage extends LightningElement {

    constructor() {
        super();
        var self = this;
        window.addEventListener('scroll', function (e) { self.handleScroll(window.scrollY, self); });
    }

    @track services = [];
    @track contactInfo;
    @track contactTrainingInfo;
    @track contactCertificationInfo;
    @track contactTrainingIds;
    @track contactCertificationIds;

    @track handleScrolling = true;
    @track currentSection;
    @track sectionMapContact = [];
    @track sectionMapAccount = [];
    @track sectionMapTraining = [];
    @track sectionMapCertification = [];

    @track loggedUser;

    @track mapOfValuesContact = [];
    @track mapOfValuesAccount = [];
    @track mapOfValuesTraining = [];
    @track mapOfValuesCertification = [];

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
            contact.cardNumber = result.cardNumber !== undefined ? result.cardNumber : undefined;
            contact.cardDate = result.cardDate !== undefined ? result.cardDate : undefined;

            this.contactInfo = contact;
        });

        getContactTrainingDetails().then(result => {
            let trainings = result;

            this.contactTrainingInfo = trainings;

            this.contactTrainingIds = trainings.map(a => a.Id);
        });

        getContactCertifications().then(result => {
            let trainings = result;

            this.contactCertificationInfo = trainings;

            this.contactCertificationIds = trainings.map(a => a.Id);
        });

    }

    renderedCallback() {
        let sections = this.template.querySelectorAll('.section');

        const leftNav = this.template.querySelector('c-portal-company-profile-info-nav');
        if (leftNav) {
            let navItems = [];
            for (let key in this.sectionMapContact) {
                navItems.push({ label: key, value: key, open: true });
            }

            for (let key in this.sectionMapAccount) {
                navItems.push({ label: key, value: key, open: true });
            }

            for (let key in this.sectionMapTraining) {
                navItems.push({ label: key, value: key, open: true });
            }

            for (let key in this.sectionMapCertification) {
                navItems.push({ label: key, value: key, open: true });
            }


            leftNav.navItems = navItems;
            leftNav.activesection = 'Basics';
        }
    }

    refreshview() {
        getFieldsMap({ type: 'MyProfile' }).then(result => {

            this.sectionMapContact = JSON.parse(JSON.stringify(result));

            let sectionMap = this.sectionMapContact;

            let localMap = [];
            for (let key in this.sectionMapContact) {

                if (sectionMap.hasOwnProperty(key)) {
                    let value = sectionMap[key];
                    localMap.push({ 'value': value, 'key': key,'showfunction' : (key === 'Professional') });//

                }
            }
            this.mapOfValuesContact = localMap;

        });

        getFieldsMap({ type: 'MyTrainings' }).then(result => {

            this.sectionMapTraining = JSON.parse(JSON.stringify(result));

            let sectionMap = this.sectionMapTraining;

            let localMap = [];
            for (let key in this.sectionMapTraining) {

                if (sectionMap.hasOwnProperty(key)) {
                    let value = sectionMap[key];
                    localMap.push({'value': value, 'key': key});

                }
            }
            this.mapOfValuesTraining = localMap;

        });

        getFieldsMap({ type: 'MyCertifications' }).then(result => {

            this.sectionMapCertification = JSON.parse(JSON.stringify(result));

            let sectionMap = this.sectionMapCertification;

            let localMap = [];
            for (let key in this.sectionMapCertification) {

                if (sectionMap.hasOwnProperty(key)) {
                    let value = sectionMap[key];
                    localMap.push({'value': value, 'key': key});

                }
            }
            this.mapOfValuesCertification = localMap;

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

            let sectionMap = this.sectionMapAccount;

            let localMap = [];
            for (let key in this.sectionMapAccount) {
                if (sectionMap.hasOwnProperty(key)) {
                    let value = sectionMap[key];
                    localMap.push({ 'value': value, 'key': key });
                }
            }

            this.mapOfValuesAccount = localMap;
        });
    }

}
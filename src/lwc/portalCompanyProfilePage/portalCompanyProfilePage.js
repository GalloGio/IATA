/**
 * Created by pvavruska on 5/23/2019.
 */

import { LightningElement, wire, track } from 'lwc';
import getFieldsMap from '@salesforce/apex/PortalProfileCtrl.getFieldsMap';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';

import CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';


export default class PortalCompanyProfilePage extends LightningElement {

    constructor() {
        super();
        var self = this;
        window.addEventListener('scroll', function (e) { self.handleScroll(window.scrollY, self); });
    }

    @track sectionMap = [];

    @track handleScrolling = true;
    @track accountId;
    @track emailAddress;

    @track objectApiName = 'User';

    @track userLoaded = false;

    @track currentSection;
    @track lstTabs = [];

    @track accFields = [];
    @track contactFields = [];

    get noAccount() {
        return (this.loggedUser == null || this.loggedUser.Contact == null || this.loggedUser.Contact.AccountId == null);
    }

    _labels = {CompanyInformation};
    get labels() {return this._labels;}
    set labels(value) {this._labels = value;}


    connectedCallback() {

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
            this.userLoaded = true;
        });

        getFieldsMap({ type: 'CompanyProfile' }).then(result => {

            this.sectionMap = JSON.parse(JSON.stringify(result));

            let sectionMap = this.sectionMap;//console.log('SECTION MAP BEFORE: ' , this.sectionMap );

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

        //Different tabs based on current user's access

        let tabNames = [this.labels.CompanyInformation]//, 'Branch Offices', 'Contacts', 'Company Calendar', 'Activity Log'];
        for (let i = 0; i < tabNames.length; i++) {
            tabsAux.push({
                "active": (i == 0),
                "label": tabNames[i],
                "id": i,
                "style": ""
            });
        }

        this.lstTabs = tabsAux;
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
        console.log('item: ' + item);
    }

    handleScroll(yposition, self) {
        if (!this.handleScrolling) { console.log('not scrolling'); return; }
        let sections = self.template.querySelectorAll('.section');

        //console.log('window: '+window.innerHeight);
        //console.log('yposition: '+yposition);

        for (let i = 0; i < sections.length; i++) {
            let sectionName = sections[i].attributes.getNamedItem('data-name').value;
            let offsetTop = sections[i].offsetTop;

            let windowHeight = window.innerHeight;
            let positionFromTop = sections[i].getBoundingClientRect().top;
            if (positionFromTop - windowHeight <= 0) {
                //console.log('inView '+sectionName)
            }


            let triggerPosition = windowHeight / 2; //650
            if ((offsetTop - yposition < triggerPosition) && (offsetTop - yposition > - triggerPosition)) {
                if (self.currentSection != sectionName) {
                    //console.log('Looking at '+sectionName);
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
        //console.log('onmouseenterTab', clickedTab);

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].style = "color:#f04632;border-bottom: 2px solid #f04632;";
            } else {
                tabsAux[i].style = "";
            }
        }

        this.lstTabs = tabsAux;

    }

    onmouseleaveTab(event) {
        let clickedTab = event.target.dataset.item;

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));
        //console.log(tabsAux);

        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].style = "";
            } else {
                tabsAux[i].style = "";
            }
        }

        this.lstTabs = tabsAux;
    }

    onclickTab(event) {
        let clickedTab = event.target.dataset.item;
        //console.log('onclickTab', clickedTab);

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));
        //console.log(tabsAux);

        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].active = true;
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

    get tab0Active() { return this.lstTabs[0].active; }
    //get tab1Active() { return this.lstTabs[1].active; }
    //get tab2Active() { return this.lstTabs[2].active; }
    //get tab3Active() { return this.lstTabs[3].active; }
    //get tab4Active() { return this.lstTabs[4].active; }
}
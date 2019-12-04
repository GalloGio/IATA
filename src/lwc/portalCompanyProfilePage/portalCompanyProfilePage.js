import { LightningElement, track } from 'lwc';

import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';

import { getParamsFromPage } from 'c/navigationUtils';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ISSP_CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';
import NoAccount from '@salesforce/label/c.CSP_NoAccount';
import CSP_Branch_Offices from '@salesforce/label/c.CSP_Branch_Offices';
import ISSP_Contacts from '@salesforce/label/c.ISSP_Contacts';

export default class PortalCompanyProfilePage extends LightningElement {

    labels = { ISSP_CompanyInformation, NoAccount, CSP_Branch_Offices, ISSP_Contacts };

    @track isAdmin = false;
    @track userLoaded = false;
    @track lstTabs = [];

	@track tabName = '';

    get noAccount() {
        return (this.loggedUser == null || this.loggedUser.Contact == null || this.loggedUser.Contact.AccountId == null);
    }

    connectedCallback() {
        isAdmin().then(result => {
            this.isAdmin = result;

            let pageParams = getParamsFromPage();

            let viewContacts = false;
            if (pageParams.tab !== undefined && pageParams.tab !== '' && pageParams.tab === 'contact') {
                viewContacts = true;
            }

            let tabsAux = [];

            let tabNames = [this.labels.ISSP_CompanyInformation, this.labels.CSP_Branch_Offices, this.labels.ISSP_Contacts]; //+'Company Calendar', 'Activity Log'];
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

            this.lstTabs = tabsAux;

        });
        

        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
            this.userLoaded = true;
        });


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
            } else {
                tabsAux[i].active = false;
            }
        }

        this.lstTabs = tabsAux;
    }

    get tab0Active() { return this.lstTabs[0] != null && this.lstTabs[0].active; }
    get tab1Active() { return this.lstTabs[1] != null && this.lstTabs[1].active; }
    get tab2Active() { return this.lstTabs[2] != null && this.lstTabs[2].active; }
    get tab3Active() { return this.lstTabs[3] != null && this.lstTabs[3].active; }
    get tab4Active() { return this.lstTabs[4] != null && this.lstTabs[4].active; }

}
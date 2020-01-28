import { LightningElement, track } from 'lwc';

import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import showIATAInvoices from '@salesforce/apex/PortalHeaderCtrl.showIATAInvoices'; //WMO-696 - ACAMBAS
import getInvoices from '@salesforce/apex/PortalProfileCtrl.getCustomerInvoices'; //WMO-627 - ACAMBAS
import getInvoicesListFields from '@salesforce/apex/PortalProfileCtrl.getInvoicesListFields'; //WMO-627 - ACAMBAS

import { getParamsFromPage } from 'c/navigationUtils';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ISSP_CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';
import NoAccount from '@salesforce/label/c.CSP_NoAccount';
import CSP_Branch_Offices from '@salesforce/label/c.CSP_Branch_Offices';
import ISSP_Contacts from '@salesforce/label/c.ISSP_Contacts';
import CSP_Outstanding_Invoices from '@salesforce/label/c.CSP_Outstanding_Invoices'; //WMO-699 - ACAMBAS
import No_Invoices_To_Display from '@salesforce/label/c.No_Invoices_To_Display'; //WMO-699 - ACAMBAS
import IATA_Invoices from '@salesforce/label/c.CSP_IATA_Invoices'; //WMO-627 - ACAMBAS 
import EF_Invoices from '@salesforce/label/c.CSP_EF_Invoices'; //WMO-627 - ACAMBAS


export default class PortalCompanyProfilePage extends LightningElement {

    labels = { ISSP_CompanyInformation, NoAccount, CSP_Branch_Offices, ISSP_Contacts, IATA_Invoices, EF_Invoices, No_Invoices_To_Display, CSP_Outstanding_Invoices };

    @track isAdmin = false;
    @track userLoaded = false;
    @track lstTabs = [];
    @track lstSubTabs = []; //WMO-627 - ACAMBAS
    @track invoices = []; //WMO-627 - ACAMBAS
    @track iataInvoicesLoaded = false; //WMO-627 - ACAMBAS
    @track efInvoicesLoaded = false; //WMO-627 - ACAMBAS
    @track iataInvoiceFields; //WMO-627 - ACAMBAS
    @track efInvoiceFields; //WMO-627 - ACAMBAS
    @track editBasics = false;
    @track IATAInvoicesNum; //WMO-699 - ACAMBAS
    @track EFInvoicesNum; //WMO-699 - ACAMBAS
    @track TotalInvoicesNum; //WMO-699 - ACAMBAS

    //Infinite loading
    @track invoicesOffset = 0; //WMO-627 - ACAMBAS
    @track invoicesEnded = false; //WMO-627 - ACAMBAS
    @track isFetching = false;

    @track recordid;
    @track objectid;

    //Flag that defines if the Outstanding Invoices tab is to be displayed or not
    @track displayInvoicesTab; //WMO-696 - ACAMBAS
    // ------------------- //


    IATA_INVOICE_TYPE = 'IATA OFFICE'; //WMO-627 - ACAMBAS
    EF_INVOICE_TYPE = 'E&F AIRPORT'; //WMO-627 - ACAMBAS

	@track tabName = '';

    get noAccount() {
        return (this.loggedUser == null || this.loggedUser.Contact == null || this.loggedUser.Contact.AccountId == null);
    }

    connectedCallback() {
        //WMO-696 - ACAMBAS: Begin
        showIATAInvoices().then(result => {
            this.displayInvoicesTab = result;
            this.displayTabs();
        });
        //WMO-696 - ACAMBAS: End


        getLoggedUser().then(result => {
            this.loggedUser = JSON.parse(JSON.stringify(result));
            this.objectid = this.loggedUser.Contact.AccountId;
            this.userLoaded = true;
        });

        this.refreshview();
    }

    displayTabs() { //WMO-627 - ACAMBAS
        isAdmin().then(result => {
            this.isAdmin = result;

            let pageParams = getParamsFromPage();
            let viewInvoices = false; //WMO-627 - ACAMBAS

            let viewContacts = false;
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
                tabNames = [this.labels.ISSP_CompanyInformation, this.labels.CSP_Branch_Offices, this.labels.ISSP_Contacts, this.labels.CSP_Outstanding_Invoices]; //+'Company Calendar', 'Activity Log'];
            } else {
                tabNames = [this.labels.ISSP_CompanyInformation, this.labels.CSP_Branch_Offices, this.labels.ISSP_Contacts];
            }
            for (let i = 0; i < tabNames.length; i++) {
                let tabAux = {};
                //Only Portal Admin can see other tabs
                if (i === 0 || this.isAdmin) {
                    tabAux = {
                        active: !viewContacts && !viewInvoices,
                        label: tabNames[i],
                        id: i,
                        class: "slds-p-around_small cursorPointer text-darkGray itemTab"
                    };
                    if (i === 1) {
                        tabAux.active = false;
                    }
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

            let tabNameLocal;
            tabsAux.forEach( function(tab){
                if(tab.active) {
                    tabNameLocal = tab.label;
            }
            });

            this.tabName = tabNameLocal;

            this.lstTabs = tabsAux;

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
        //For outstanding invoices tab
        this.getIATAInvoicesFieldMap(); //WMO-627 - ACAMBAS
        this.getEFInvoicesFieldMap(); //WMO-627 - ACAMBAS
    }

    onmouseenterTab(event) {
        let clickedTab = event.target.dataset.item;

        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray activeTab";
            } else {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray itemTab";
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
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray itemTab";
            } else {
                tabsAux[i].class = "slds-p-around_small cursorPointer text-darkGray itemTab";
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

        let clickedTab = event.target.dataset.item;
        //because proxy.......
        let tabsAux = JSON.parse(JSON.stringify(this.lstTabs));

        //Add onclick method to retrieve Accounts/Contacts
        for (let i = 0; i < tabsAux.length; i++) {
            if (i + "" === clickedTab) {
                tabsAux[i].active = true;

                //WMO-627 - ACAMBAS: Begin
                if (i == 3) {
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

    get tab0Active() { return this.lstTabs[0] != null && this.lstTabs[0].active; } //company information
    get tab1Active() { return this.lstTabs[1] != null && this.lstTabs[1].active; } //branch offices
    get tab2Active() { return this.lstTabs[2] != null && this.lstTabs[2].active; } //contacts
    get tab3Active() { return this.lstTabs[3] != null && this.lstTabs[3].active; } //outstanding invoices
    get tab4Active() { return this.lstTabs[4] != null && this.lstTabs[4].active; }
    get tab5Active() { return this.lstTabs[5] != null && this.lstTabs[5].active; }

    get subTab0Active() { return this.lstSubTabs[0] != null && this.lstSubTabs[0].active && this.IATAInvoicesNum > 0 }
    get subTab1Active() { return (this.lstSubTabs[0] != null && this.lstSubTabs[0].active && this.IATAInvoicesNum == 0 && this.EFInvoicesNum > 0) || (this.lstSubTabs[1] != null && this.lstSubTabs[1].active); }
    get hasNoInvoices() { return (this.IATAInvoicesNum + this.EFInvoicesNum) === 0; } //WMO-699 - ACAMBAS

    reloadData(){
        if(this.tab2Active){
            //performs the reload in case the Contacts tab is clicked--- Api function exposed on the c-portal-company-profile-contacts-list component
            this.template.querySelector('c-portal-company-profile-contacts-list').reloadData();
        }
    }
}
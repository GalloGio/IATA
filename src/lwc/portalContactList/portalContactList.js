/**
 * Created by pvavruska on 6/4/2019.
 */

import { LightningElement, track, api } from 'lwc';

import getAccountDomains from '@salesforce/apex/PortalProfileCtrl.getAccountDomains';
import isAccountDomain from '@salesforce/apex/PortalProfileCtrl.isAccountDomain';

import BasicsSection from '@salesforce/label/c.csp_Basics_Section_label';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import ISSP_ContactList_HoverPopup_Text from '@salesforce/label/c.ISSP_ContactList_HoverPopup_Text';


export default class PortalContactList extends LightningElement {

    @api isAccount;

    @api openmodel;
    @api recordid;
    @track originalRecords;
    @api objectid;
    @api objectName;
    @api defaultSort;
    @api fetching;
    isAsc = true;
    sortBy;
    @track isLoading = true;
    @track isLoadingRecords = true;
    @api fieldsListToCreate;
    @track recordsLocal;
    @api recordsInitDone = false;
    @track openId;
    @track showEditLocal = false;
    @track _searchKey = false;
    @track isAccountDomain;
    @track accountDomain = [];

    
    
    searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';

    /* Dynamic fields*/
    @api sectionMap;


    @api
    get showEdit(){
        return this.showEditLocal;
    }

    set showEdit(value){
        this.showEditLocal = value;
    }

    @api
    get searchKey(){
        return this._searchKey;
    }

    set searchKey(value){
        this._searchKey = value;
    }


    @api
    get fieldsList() {
        return this._fieldsList;
    }

    set fieldsList(value) {
        this._fieldsList = value;
    }


    @api
    get records() {
        return this.recordsLocal;
    }
    set records(value) {
        this.recordsLocal = value;

        //In the first run, add rendering flags
        if (!this.recordsInitDone) {
            this.recordsInitDone = true;
            if (this.sortBy != null) {
                this.orderRows(this.sortBy);
            } else if (this.defaultSort != null) {
                this.orderRows(this.defaultSort);
            }
            else{
                this.processRecords();
            }
        }
    }

    get hasRecords() { return this.records !== undefined && this.records.length > 0; }

    get fieldCount() {
        if (!this.fieldsList) {
            return 0;
        } else {
            return this.fieldsList.ROWS.length + 3; // Adding extra colspans for spacing columns
        }
    }



    _labels = { BasicsSection, CSP_NoSearchResults, CSP_Search_NoResults_text1, CSP_Search_NoResults_text2 , ISSP_ContactList_HoverPopup_Text};
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }

    connectedCallback() {
        this.fetching = false;
        this.isAccount = (this.isAccount === 'true' ? true : false);

        isAccountDomain().then(result => {
            this.isAccountDomain = result;
            if (result) {
                getAccountDomains({ accountId: this.objectid }).then(results => {
                    let accountDomainsLocal = JSON.parse(JSON.stringify(results));
                    let domainValues = [];
                    accountDomainsLocal.forEach( function(domain) {
                        domainValues.push(domain.Name);
                    });
                    this.accountDomain = domainValues;
                    this.processRecords();
                });
            } else {
                this.processRecords();
            }
        });
        
    }

    openRecordDetail(event) {
        this.openId = null;
        let recordIndex = parseInt(event.target.dataset.item, 10);

        let records = JSON.parse(JSON.stringify(this.records));

        for (let i = 0; i < records.length; i++) {
            if (recordIndex == i && (records[i].open === undefined || records[i].open === false)) {
                this.openId = records[i].Id;
                records[i].open = true;
            } else {
                records[i].open = false;
            }
        }

        this.records = records;
    }

    @api resetInit() {
        this.recordsInitDone = false;
    }
    @api
    openModal() { this.openmodel = true; }
    closeModal() { this.openmodel = false; }
    closemodalWithSuccess() {
        this.openmodel = false;
        this.dispatchEvent(new CustomEvent('getcontacts'));
    }

    processRecords() {
        let records = JSON.parse(JSON.stringify(this.records));
        //let fields = this.rowFields;
        let fields = this.fieldsList.ROWS;

        if (fields && records) {
            for (let r = 0; r < records.length; r++) {
                let record = records[r];
                let rowValues = [];

                for (let i = 0; i < fields.length; i++) {
                    let field = fields[i];
                    let fieldName = fields[i].fieldName;

                    let rowValue = {};

                    if (record[fieldName] != null) {

                        rowValue.className = field.className;

                        if (fieldName === 'Email' && this.isAccountDomain && this.accountDomain.length > 0) {
                            let emailError = this.checkEmail(record[fieldName]);
                                rowValue.emailHasError = true;
                                let emailArray = record[fieldName].split('@');
                                rowValue.email = emailArray[0];
                                rowValue.domain = '@' + emailArray[1];

                            if (emailError){
                                rowValue.emailClass = 'invalidEmail';
                                rowValue.showIcon = true;
                            } else {
                                rowValue.emailClass = 'validEmail';
                            }
                        } else {
                            rowValue.value = record[fieldName];
                        }
                        
                        

                        let extraStyle = this.getRowStyle(fieldName, record[fieldName]);
                        if (extraStyle != null) {
                            rowValue.className += ' ' + extraStyle;
                        }
                    } else {
                        rowValue.value = '';
                        rowValue.className = field.className;//this.getRowStyle(fieldName,null);
                    }

                    if(fieldName == this.sortBy){
                        rowValue.className += ' activeField ';
                    }else{
                        rowValue.className = rowValue.className.split(' activeField ').join('');
                    }

                    rowValues.push(rowValue);
                }
                record.rowValues = rowValues;

                if (this.openId != null && this.openId == record.Id) {
                    record.open = true;
                }
            }

            this.records = records;
            this.originalRecords = records;
        }


    }


    getRowStyle(fieldName, value) {
        let objectName = this.objectName;

        if (fieldName == 'Status__c' && objectName == 'Account') {
            if (value != null) {
                if (value == 'Approved' || value == 'Resolved') {
                    return 'lightGreen';
                }
                if (value == 'Pending') {
                    return 'amber';
                }
            } else {
                return 'underLinded';
            }
        }

        return 'underLinded';
    }

    checkEmail(value) {
        let accountDomainLocal = JSON.parse(JSON.stringify(this.accountDomain));
        let hasError = true;
        
        accountDomainLocal.forEach( function(domain){
            let val = value.trim();
            if( val.includes(domain) ){
               hasError = false;
            }
        });

        return hasError;
    }

    columnSort(event) {
        let fieldName = event.target.dataset.name;
        this.isAsc = !this.isAsc;
        this.orderRows(fieldName);
    }


    /** Sort & Filer*/
    orderRows(fieldName) {
        let isAsc = this.isAsc;
        let sortBy = this.sortBy;
        let records = JSON.parse(JSON.stringify(this.records));


        //Choose different field for login date
        if (fieldName === 'LastLogin') { fieldName == 'LastLoginDate'; }

        this.sortBy = fieldName;
        //Handle sort direction
        if (sortBy != null) {
            if (sortBy == fieldName) {
                isAsc = this.isAsc;
            } else {
                isAsc = true;
                this.isAsc = true;
            }
        }
        

        //Do sorting
        records.sort((a, b) => {
            let aEmpty = (a[fieldName] == null) || (a[fieldName].length == 0);
            let bEmpty = (b[fieldName] == null) || (b[fieldName].length == 0);

            if ((aEmpty && bEmpty) || (a[fieldName] == b[fieldName])) {
                return 0;
            }

            if (aEmpty) {
                return 1 * (isAsc ? 1 : -1);
            }

            if (bEmpty) {
                return -1 * (isAsc ? 1 : -1);
            }

            return (a[fieldName].toLowerCase() < b[fieldName].toLowerCase() ? -1 : 1) * (isAsc ? 1 : -1)
        });

        this.records = records;

        //Set field classes
        let fieldsList = JSON.parse(JSON.stringify(this.fieldsList));
        let rowFields = fieldsList.ROWS; //this.rowFields;
        for (let f = 0; f < rowFields.length; f++) {
            if (rowFields[f].fieldName == fieldName) {
                rowFields[f].className = rowFields[f].className.replace(/\inactive\b/g, ' activated ');
                rowFields[f].isAsc = isAsc;
                rowFields[f].isDesc = !isAsc;
            } else {
                rowFields[f].className = rowFields[f].className.replace(/\activated\b/g, ' inactive ');
                rowFields[f].isAsc = false;
                rowFields[f].isDesc = false;
            }
        }
        this.fieldsList = fieldsList;

        this.processRecords();
    }

    refreshview() {
        this.dispatchEvent(new CustomEvent('refreshview'));
    }

}

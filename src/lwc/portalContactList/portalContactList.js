/**
 * Created by pvavruska on 6/4/2019.
 */

import { LightningElement, track, api, wire } from 'lwc';

import getAccountDomains from '@salesforce/apex/PortalProfileCtrl.getAccountDomains';
import isAccountDomain from '@salesforce/apex/PortalProfileCtrl.isAccountDomain';
import inactivate from '@salesforce/apex/PortalProfileCtrl.inactivate';
import approve from '@salesforce/apex/PortalProfileCtrl.approve';
import getRejectionReasons from '@salesforce/apex/ISSP_PortalUserStatusChange.getRejectionReasons';
import { reduceErrors } from 'c/ldsUtils';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import BasicsSection from '@salesforce/label/c.csp_Basics_Section_label';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import ISSP_ReasonInactivation from '@salesforce/label/c.ISSP_ReasonInactivation';
import CSP_selectReason from '@salesforce/label/c.CSP_selectReason';
import ISSP_Confirm from '@salesforce/label/c.ISSP_Confirm';
import ISSP_InactiveUser_IdCard from '@salesforce/label/c.ISSP_InactiveUser_IdCard';
import ISSP_SureToContinue from '@salesforce/label/c.ISSP_SureToContinue';
import ISSP_SelectOneContact from '@salesforce/label/c.ISSP_SelectOneContact';
import ISSP_ContactList_HoverPopup_Text from '@salesforce/label/c.ISSP_ContactList_HoverPopup_Text';
import ISSP_Activate from '@salesforce/label/c.ISSP_Activate';
import ISSP_MakeAdmin from '@salesforce/label/c.ISSP_MakeAdmin';
import ISSP_AMS_eBulletin_Disabled from '@salesforce/label/c.ISSP_AMS_eBulletin_Disabled';
import PKB2_js_error from '@salesforce/label/c.PKB2_js_error';
import CSP_Success from '@salesforce/label/c.CSP_Success';

export default class PortalContactList extends LightningElement {

    _labels = { 
        BasicsSection, 
        CSP_NoSearchResults, 
        CSP_Search_NoResults_text1, 
        CSP_Search_NoResults_text2, 
        ISSP_ContactList_HoverPopup_Text, 
        ISSP_ReasonInactivation, 
        CSP_selectReason,
        ISSP_Confirm,
        ISSP_InactiveUser_IdCard,
        ISSP_SureToContinue,
        ISSP_SelectOneContact,
        ISSP_Activate,
        ISSP_MakeAdmin,
        ISSP_AMS_eBulletin_Disabled,
        PKB2_js_error,
        CSP_Success
    };
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }

    @api isAccount;
    @track _actionName = '';
    @api openmodel;
    @api recordid;
    @track originalRecords;
    @api objectid;
    @api objectName;
    @api defaultSort;
    @api fetching;
    isAsc = true;
    sortBy;
    @track loading = false;
    @track isLoadingRecords = true;
    @api fieldsListToCreate;
    @track recordsLocal;
    @track contactsWrapper;
    @api recordsInitDone = false;
    @track openId;
    @track showEditLocal = false;
    @track _searchKey = false;
    @track manualOrder = false;
    @track isAccountDomain;
    @track accountDomain = [];
    @track allContacts = [];
    @track inactiveModal = false;
    @track inactiveReason = '';
    @track hasError = false;
    @track errorMessage = '';
    @track contactsSelected = [];
    @track allContactsSelected = false;

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

    @api
    get wrapper() {
        return this.contactsWrapper;
    }
    set wrapper(value) {
        this.contactsWrapper = value;
    }

    @api
    get actionName() {
        return this._actionName;
    }
    set actionName(value) {
        this._actionName = value;
        
        if(this._actionName !== '') {
            if(this._actionName === 'approve') { 
                this.grantAccessAll(); 
            } else if(this._actionName === 'inactive') {
                this.denyAccess();
            }
        }
    }

    get hasRecords() { return this.records !== undefined && this.records.length > 0; }

    get fieldCount() {
        if (!this.fieldsList) {
            return 0;
        } else {
            return this.fieldsList.ROWS.length + 5; // Adding extra colspans for spacing columns
        }
    }

    @wire(getRejectionReasons) inactiveOptions;

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

    get noSelected() {
        return (this.inactiveReason === '');
    }

    grantAccess(event) {
        this.loading = true;

        let contact = [];
        contact.push(event.target.dataset.item);
        let exp = event.target.dataset.name;

        switch(exp) {
            case 'approve':
                this.processApprove(contact, 'Approved User');
                break;
            case 'approveAdmin':
                this.processApprove(contact, 'Approved Admin');
                break;
            default:
                break;
        }
    }

    grantAccessAll(event) {
        this.loading = true;

        let exp = event !== undefined ? event.target.dataset.name : this._actionName;
        switch(exp) {
            case 'approve':
                this.processApprove(this.contactsSelected, 'Approved User');
                break;
            case 'approveAdmin':
                this.processApprove(this.contactsSelected, 'Approved Admin');
                break;
            default:
                break;
        }
    }

    processApprove(contactsList, appStatus) {
        let records = JSON.parse(JSON.stringify(this.contactsWrapper));
        let found = true;

        for (let i = 0; i < records.length; i++) { 
            if(contactsList.includes(records[i].contact.Id)) {
                records[i].selected = true;
                if(found) found = false;
            } else {
                records[i].selected = false;
            }
        }

        this.contactsWrapper = records;

        if(found) {
            this.loading = false;
            const toastEvent = new ShowToastEvent({
                title: this._labels.PKB2_js_error,
                message: this._labels.ISSP_SelectOneContact,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        } else {
            approve({ contactList : JSON.stringify(this.contactsWrapper), approvalStatus : appStatus })
                .then(results => {
                    this.loading = false;
                    if(results.isSuccess) {
                        const toastEvent = new ShowToastEvent({
                            title: this._labels.CSP_Success,
                            message: results.successMsg,
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);
                        this.refreshview();
                    } else {
                        const toastEvent = new ShowToastEvent({
                            title: this._labels.PKB2_js_error,
                            message: results.errorMsg,
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                        this.refreshview();
                    }
                })
                .catch(error => {
                    this.loading = false;
                    const toastEvent = new ShowToastEvent({
                        title: this._labels.PKB2_js_error,
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                    this.refreshview();
            });
        }
    }

    denyAccess(event) {        
        let contactSelected = event !== undefined ? event.target.dataset.item : '';

        this.inactiveModal = true;

        let records = JSON.parse(JSON.stringify(this.contactsWrapper));
        let conSelected = JSON.parse(JSON.stringify(this.contactsSelected));
        
        for (let i = 0; i < records.length; i++) { 
            if((contactSelected !== '' && contactSelected === records[i].contact.Id) || records[i].selected || conSelected.includes(records[i].contact.Id)) {
                records[i].selected = true;

                if(records[i].hasIdCard) {
                    let conf = confirm(this._labels.ISSP_InactiveUser_IdCard + ' ' + this._labels.ISSP_SureToContinue + ' ' + records[i].contact.Name);
                    if(conf) {
                        records[i].hasIdCard = false;
                    } else {
                        this.inactiveModal = false;
                    }
                }
            } else {
                records[i].selected = false;
            }
        }

        this.contactsWrapper = records;

    }

    processInactive() {
        this.loading = true;

        let records = JSON.parse(JSON.stringify(this.contactsWrapper));
        let found = true;

        for (let i = 0; i < records.length; i++) {
            if(records[i].selected) {
                found = false;
                break;
            }
        }

        if(found) {
            this.loading = false;
            const toastEvent = new ShowToastEvent({
                title: this._labels.PKB2_js_error,
                message: this._labels.ISSP_SelectOneContact,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        } else {
            inactivate({ contactList : JSON.stringify(this.contactsWrapper), reasonToInactive : this.inactiveReason })
                .then(results => {
                    this.loading = false;
                    if(results.isSuccess) {
                        const toastEvent = new ShowToastEvent({
                            title: this._labels.CSP_Success,
                            message: results.successMsg,
                            variant: 'success'
                        });
                        this.dispatchEvent(toastEvent);
                        this.refreshview();
                        this.closeInactiveModal();
                    } else {
                        this.hasError = true;
                        this.errorMessage = results.errorMsg;
                    }
                    
                })
                .catch(error => {
                    this.loading = false;
                    const toastEvent = new ShowToastEvent({
                        title: _labels.PKB2_js_error,
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                    this.refreshview();
                    this.closeInactiveModal();
            });
        }
    }

    handleInactiveReason(event) {
        this.inactiveReason = event.detail.value;
    }

    handleRadioOptions(event) {        
        let contactSelected = event.target.dataset.item;

        let fieldValue = JSON.parse(JSON.stringify(this.contactsSelected));

        if (!fieldValue.includes(contactSelected)) {
            fieldValue.push(contactSelected)
        } else {
            for (let i = fieldValue.length - 1; i >= 0; i--) {
                if (fieldValue[i] === contactSelected) {
                    fieldValue.splice(i, 1);
                }
            }
        }

        this.contactsSelected = fieldValue;

        let records = JSON.parse(JSON.stringify(this.records));

        for (let i = 0; i < records.length; i++) {
            if(records[i].Id === contactSelected) {
                records[i].selected = true;
                break;
            }
        }

        this.records = records;
        
        if(this.allContactsSelected && this.contactsSelected.length === 0) this.allContactsSelected = false;

        this.dispatchEvent(new CustomEvent('manageusers', { detail: this.contactsSelected.length }));
    }

    handleRadioAllOptions() {
        let recordsWrapper = JSON.parse(JSON.stringify(this.contactsWrapper));
        let fieldValue = [];

        for (let i = 0; i < recordsWrapper.length; i++) {
            if(this.allContactsSelected) {
                recordsWrapper[i].selected = false;
            } else {
                recordsWrapper[i].selected = true;
            }
        }

        this.contactsWrapper = recordsWrapper;
        
        let records = JSON.parse(JSON.stringify(this.records));

        for (let i = 0; i < records.length; i++) {
            if(this.allContactsSelected) {
                records[i].selected = false;
            } else {
                records[i].selected = true;
                fieldValue.push(records[i].Id);
            }
        }

        this.records = records;

        if(this.allContactsSelected) {
            this.allContactsSelected = false;
            this.contactsSelected = [];
        } else {
            this.contactsSelected = fieldValue;
            this.allContactsSelected = true;
        }

        this.dispatchEvent(new CustomEvent('manageusers', { detail: this.allContactsSelected }));
    }

    closeInactiveModal() {
        if(!this.loading) {
            this.inactiveModal = false;
            this.hasError = false;
            this.errorMessage = '';
            this.inactiveReason = '';
            this.contactsSelected = [];
            this.allContactsSelected = false;

            this.dispatchEvent(new CustomEvent('manageusers', { detail: false }));

            let recordsWrapper = JSON.parse(JSON.stringify(this.contactsWrapper));

            for (let i = 0; i < recordsWrapper.length; i++) {
                recordsWrapper[i].selected = false;
            }
    
            this.contactsWrapper = recordsWrapper;

            let records = JSON.parse(JSON.stringify(this.records));

            for (let i = 0; i < records.length; i++) {
                records[i].selected = false;
            }
    
            this.records = records;
        }
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

                record.selected = record.selected !== undefined ? record.selected : false;
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
                return 'underLined';
            }
        }

        return 'underLined';
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
        this.manualOrder = true;
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
        if (fieldName === 'LastLogin') { fieldName = 'LastLoginDate'; }

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

        if(this.manualOrder) {
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
        } else {
            let orderedRecords = [];
            for (let i = 0; i < records.length; i++) {
                if(records[i].PortalStatus === 'Pending Approval') {
                    let con = records[i];
                    delete records[i];
                    orderedRecords.unshift(con);
    
                } else {
                    orderedRecords.push(records[i]);
                }
            }

            this.records = orderedRecords;
        }

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
/**
 * Created by pvavruska on 6/4/2019.
 */

import { LightningElement, track, api } from 'lwc';
import BasicsSection from '@salesforce/label/c.csp_Basics_Section_label';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';


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

    /* Dynamic fields*/
    @api sectionMap;


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
            this.processRecords();
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



    _labels = { BasicsSection, CSP_NoSearchResults };
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }

    connectedCallback() {
        this.isAccount = (this.isAccount === 'true' ? true : false);
    }

    openRecordDetail(event) {
        let recordIndex = parseInt(event.target.dataset.item, 10);

        let records = JSON.parse(JSON.stringify(this.records));

        for (let i = 0; i < records.length; i++) {
            if (recordIndex == i && records[i].open === false) {
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
    @api
    searchRecords(searchParam) {

        if (searchParam != null && searchParam.length > 0) {
            let records = JSON.parse(JSON.stringify(this.originalRecords));

            let filtered = records.filter(function (el) {
                let stringed = JSON.stringify(el.rowValues).toLowerCase();
                return stringed.includes(searchParam.toLowerCase());
            });

            this.records = filtered;
        } else {
            this.records = this.originalRecords;
        }
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
                        rowValue.value = record[fieldName];
                        rowValue.className = field.className;
                        let extraStyle = this.getRowStyle(fieldName, record[fieldName]);
                        if (extraStyle != null) {
                            rowValue.className += ' ' + extraStyle;
                        }
                    } else {
                        rowValue.value = '';
                        rowValue.className = field.className;//this.getRowStyle(fieldName,null);
                    }

                    rowValues.push(rowValue);
                }
                record.rowValues = rowValues;
                if (record.open == null) {
                    record.open = false;
                }
            }

            this.records = records;
            this.originalRecords = records;

            if (this.defaultSort != null) {

                //this.orderRows(this.defaultSort);
            }
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

    columnSort(event) {
        let fieldName = event.target.dataset.name;
        this.orderRows(fieldName);
    }


    /** Sort & Filer*/
    orderRows(fieldName) {
        let isAsc = this.isAsc;
        let sortBy = this.sortBy;
        let records = JSON.parse(JSON.stringify(this.records));


        //Choose different field for login date
        if (fieldName === 'LastLogin') { fieldName == 'LastLoginDate'; }

        //Handle sort direction
        if (sortBy != null) {
            if (sortBy == fieldName) {
                this.isAsc = !isAsc;
                isAsc = !isAsc;
            } else {
                isAsc = true;
                this.isAsc = true;
            }
        }
        this.sortBy = fieldName;

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
                rowFields[f].className = rowFields[f].className.replace(/\inactive\b/g, ' active ');
                rowFields[f].isAsc = isAsc;
                rowFields[f].isDesc = !isAsc;
            } else {
                rowFields[f].className = rowFields[f].className.replace(/\active\b/g, ' inactive ');
                rowFields[f].isAsc = false;
                rowFields[f].isDesc = false;
            }
        }
        this.fieldsList = fieldsList;
    }

    refreshview() {
        this.dispatchEvent(new CustomEvent('refreshview'));
    }

}
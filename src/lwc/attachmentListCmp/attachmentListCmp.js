import { api, LightningElement, track, wire } from 'lwc';
import getAllAttachments from '@salesforce/apex/AttachmentListCtrl.getAllAttachmentsByParentIdAndPortal';
import checkIfSaamSidra from '@salesforce/apex/AttachmentListCtrl.checkIfSidraSaam';
import getExpiringLink from '@salesforce/apex/AttachmentListCtrl.getExpiringLink';
import redirectToOldPortal from '@salesforce/apex/CSP_Utils.redirectToOldPortal';
import getLabels from '@salesforce/apex/CSP_Utils.getSelectedColumns';

import getContentDetails from '@salesforce/apex/AttachmentListCtrl.getContentDetails';
import deleteAttachment from '@salesforce/apex/AttachmentListCtrl.deleteAttachment';

import { refreshApex } from '@salesforce/apex';

import AddNewDocuments from '@salesforce/label/c.CSP_Add_New_Documents';
import SupportedFileExt from '@salesforce/label/c.CSP_Supported_File_Extensions';
import FileName from '@salesforce/label/c.File_Name';
import FileSize from '@salesforce/label/c.File_Size';
import Datelabel from '@salesforce/label/c.ISSP_Date';


export default class AttachmentListCmp extends LightningElement {

    @api shownorecords;

    @api
    get parentid() {
        return this.trackedParentId;
    }
    set parentid(value) {
        this.trackedParentId = value;
        this.loadData();
    }

    @api
    get isportal() {
        return this.trackedIsPortal;
    }
    set isportal(value) {
        this.trackedIsPortal = value;
        this.loadData();
    }

    @api
    get showModal() {
        return this.trackedshowAddAttsModal;
    }
    set showModal(value) {
        this.trackedshowAddAttsModal = value;
    }

    @track label = {};

    @track loading = true;

    @track lstDocuments = [];

    @track trackedParentId;
    @track trackedIsPortal;
    @track trackedCheckIfSaamSidra;

    @track trackedshowAddAttsModal = false;
    @track newDocsList = [];

    @wire(getAllAttachments, { parentId: '$trackedParentId', isPortal: '$isportal', isSAAMorSIDRA: '$trackedCheckIfSaamSidra' })
    WireDocsList(result) {
        this.docListResult = result;
        if (result.data) {
            let attlist = JSON.parse(JSON.stringify(result.data));
            if (attlist) {
                this.lstDocuments = this.prepareData(attlist);
                this.loading = false;
                this.dispatchEvent(new CustomEvent('updateddocs', { detail: { ndocs: attlist.length } }));// sends to parent the nr of records
            }

        }
    }



    get acceptedFormats() {
        return ['.pdf', '.jpeg', '.jpg', '.png', '.ppt', '.pptx', '.xls', '.xlsx', '.tif', '.tiff', '.zip'];
    }



    @api noAttachmentMsg;


    docListResult;


    get documentsColumns() {
        return [
            { label: '', fieldName: 'viewURL', type: 'button', typeAttributes: { label: 'View', name: 'view-attach' }, cellAttributes: { alignment: "center", class: "view_attachment_link" } },
            { label: this.label.FileName, fieldName: 'name', type: 'text' },
            { label: this.label.FileSize, fieldName: 'size', type: 'text' },
            { label: this.label.Datelabel, fieldName: 'createdDate', type: 'date', typeAttributes: { year: "numeric", month: "long", day: "2-digit" } }
        ]
    };


    get newDocumentsColumns() {
        return [
            { label: '', fieldName: 'viewURL', type: 'button', typeAttributes: { label: 'View', name: 'view-attach' }, cellAttributes: { class: "view_attachment_link" } },
            { label: this.label.FileName, fieldName: 'name', type: 'text' },
            { label: this.label.FileSize, fieldName: 'size', type: 'text' },
            { label: this.label.Datelabel, fieldName: 'createdDate', type: 'date', typeAttributes: { year: "numeric", month: "long", day: "2-digit" } },
            {
                label: '', type: 'button-icon', typeAttributes: { label: '', name: 'delete-attach', title: 'Click to Delete', iconName: 'utility:delete', iconClass: 'deleteNewAttach' }
            }
        ]
    };


    connectedCallback() {
        this.label = {
            AddNewDocuments,
            Datelabel,
            FileName,
            FileSize,
            SupportedFileExt
        };

    }

    loadData() {
        if (this.parentid == null || this.isportal == null) return;
        let localparentid = this.trackedParentId;
        checkIfSaamSidra({ caseId: localparentid }).then(
            result => {
                this.trackedCheckIfSaamSidra = result;
            });
    }

    prepareData(attList) {
        if (!attList) return;
        attList.forEach(el => { // sets the size unit to be displayed
            let sz = Number(el.size);
            el.size = sz < 0.09 ? (sz * 1000).toPrecision(2) + 'Kb' : sz.toPrecision(2) + ' Mb';
        });
        return attList;
    }

    get renderDataTable() {
        return this.lstDocuments.length > 0;
    }

    handleAddAttachs() {
        if (this.trackedCheckIfSaamSidra)
            this.redirectToUploadFiles();
        else
            this.handleShowModal();
    }
    handleShowModal() {
        this.trackedshowAddAttsModal = true;
    }

    handleCloseModal() {
        refreshApex(this.docListResult);// refreshes document list
        this.trackedshowAddAttsModal = false;
        this.newDocsList = [];
    }

    redirectToUploadFiles() {
        redirectToOldPortal({ url: '/ISSP_AddAttachment?caseId=' + this.parentid }).then(
            result => {
                if (result)
                    window.open(result);
            }
        ).error(error => {
            console.error('Error', error);
        });

    }

    handleFinishAddNewAttachs(event) {
        let templist = JSON.parse(JSON.stringify(this.newDocsList));
        let newFiles = [];
        event.detail.files.forEach((el) => {
            newFiles.push(el.documentId);
        });
        console.log(newFiles);
        //gets details from the inserted files
        getContentDetails({ attachList: newFiles }).then(result => {
            this.newDocsList = templist.concat(this.prepareData(result));
            this.loading = false;
        });

    }

    get renderModalDataTable() {
        return this.newDocsList.length > 0;
    }

    handleRowAction(event) {
        //handles table row actions (view attacment and delete temp file)
        const row = event.detail.row;
        const actionName = event.detail.action.name;

        switch (actionName) {
            case 'view-attach':
                this.viewAttachment(row);
                break;
            case 'delete-attach':
                this.deleteAttach(row);
                break;
            default:
        }
    }

    viewAttachment(row) {
        if (row.viewURL == '') {
            //gets Amazon File Link
            getExpiringLink({
                fileName: row.fullName
            })
                .then(
                    result => {
                        window.open(result, '_blank');
                    })
                .catch(error => {
                    console.error('This File Contains error', error);
                }
                );
        } else {
            //opens salesforce file link
            window.open(row.viewURL, '_blank');
        }

    }

    deleteAttach(row) {
        deleteAttachment({ attachId: row.id }).then(
            () => {
                this.newDocsList = this.newDocsList.filter((val, idx, arr) => { return val.id != row.id; });
            }).catch(error => {
                console.error('Error', error);
            });

    }

}
import { api, LightningElement, track, wire } from 'lwc';
import getAllAttachments from '@salesforce/apex/AttachmentListCtrl.getAllAttachmentsPortal';
import checkIfSaamSidra from '@salesforce/apex/AttachmentListCtrl.checkIfSidraSaamOSCAR';
import getExpiringLinkWithRecId from '@salesforce/apex/AttachmentListCtrl.getExpiringLinkWithRecId';
import redirectToOldPortal from '@salesforce/apex/CSP_Utils.redirectToOldPortal';

import getContentDetails from '@salesforce/apex/AttachmentListCtrl.getContentDetails';
import deleteAttachment from '@salesforce/apex/AttachmentListCtrl.deleteAttachment';
import updateParentRecord from '@salesforce/apex/AttachmentListCtrl.updateParentRecord'; //ACAMBAS - WMO-611

import { refreshApex } from '@salesforce/apex';

import AddNewDocuments from '@salesforce/label/c.CSP_Add_New_Documents';
import SupportedFileExt from '@salesforce/label/c.CSP_Supported_File_Extensions';
import FileName from '@salesforce/label/c.File_Name';
import FileSize from '@salesforce/label/c.File_Size';
import Datelabel from '@salesforce/label/c.ISSP_Date';
import Viewlabel from '@salesforce/label/c.ISSP_View';
import Deletelabel from '@salesforce/label/c.ISSP_AMC_DELETE';
import GenericErrorMsg from '@salesforce/label/c.ISSP_ANG_GenericError';
import ErrorTitle from '@salesforce/label/c.PKB2_js_error';
import Done from '@salesforce/label/c.Done';



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
    
    @api
    get acceptedFormats() {
       return this.trackedAllowedFormats;
    }
    set acceptedFormats(value) {
        this.trackedAllowedFormats = value;
    }

    @track trackedIsExpired;

    @api
    get expired() {
        return this.trackedIsExpired;
    }
    set expired(value) {
        this.trackedIsExpired = value;
    }

   label = {
    AddNewDocuments,
    Datelabel,
    FileName,
    FileSize,
    SupportedFileExt,
    Viewlabel,
    Deletelabel,
    GenericErrorMsg,
    ErrorTitle,
    Done
};
    
    @track loading = true;

    @track lstDocuments = [];

    @track trackedParentId;
    @track trackedIsPortal;
    @track trackedCheckIfSaamSidra;

    @track trackedAllowedFormats;

    @track trackedshowAddAttsModal = false;
    @track newDocsList = [];
    
    @api noAttachmentMsg;
    docListResult;//get the wired function result(used to refresh Apex)


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

    get documentsColumns() {
        return [
            { label: '', fieldName: 'viewURL', type: 'button', typeAttributes: { label: this.label.Viewlabel, name: 'view-attach' }, cellAttributes: { alignment: "center", class: "view_attachment_link" } },
            { label: this.label.FileName, fieldName: 'name', type: 'text' },
            { label: this.label.FileSize, fieldName: 'size', type: 'text' },
            { label: this.label.Datelabel, fieldName: 'createdDate', type: 'date', typeAttributes: { year: "numeric", month: "long", day: "2-digit" } }
        ]
    };


    get newDocumentsColumns() {
        return [
            { label: '', fieldName: 'viewURL', type: 'button', typeAttributes: { label: this.label.Viewlabel, name: 'view-attach' }, cellAttributes: { class: "view_attachment_link" } },
            { label: this.label.FileName, fieldName: 'name', type: 'text' },
            { label: this.label.FileSize, fieldName: 'size', type: 'text' },
            { label: this.label.Datelabel, fieldName: 'createdDate', type: 'date', typeAttributes: { year: "numeric", month: "long", day: "2-digit" } },
            {
                label: '', type: 'button-icon', typeAttributes: { label: '', name: 'delete-attach', title: this.label.Deletelabel, iconName: 'utility:delete', iconClass: 'deleteNewAttach' }
            }
        ]
    };

    
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
                    window.open(result,'_self');
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

        //gets details from the inserted files
        getContentDetails({ attachList: newFiles }).then(result => {
            this.newDocsList = templist.concat(this.prepareData(JSON.parse(JSON.stringify(result))));
            this.loading = false;
        });

        //ACAMBAS - WMO-611: Begin
        //updates parent record
        updateParentRecord({ recordId: this.parentid }).then(
            result => {
                //do nothing
            }
        ).error(error => {
            console.error('Error', error);
        });
        //ACAMBAS - WMO-611: End
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
        if (row.sfdcContext == 'content' || row.sfdcContext == 'amazon') {
            getExpiringLinkWithRecId({
                recId: row.id
            })
                .then(
                    result => {
                        window.open(result, '_blank');
                    })
                .catch(error => {
                    console.error('This File Contains error', error);
                    this.showErrorToast();
                });
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
                this.showErrorToast();
            });

    }

    showErrorToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.label.ErrorTitle,
                message: this.label.GenericErrorMsg,
                variant: 'error'
            })
        );
        let scrollobjective = this.template.querySelector('[data-id="caseDetails"]');
        scrollobjective.scrollIntoView({ behavior: 'smooth' });
    }


}
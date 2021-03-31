import { LightningElement, wire, api, track } from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import uploadIGOMDocument from '@salesforce/apex/IGOMDocumentUtil.uploadIGOMDocument';
import activateIGOMManual from '@salesforce/apex/IGOMDocumentUtil.activateIGOMManual';

import IGOM_MANUAL_OBJECT from '@salesforce/schema/Document__c';

import { util, constants } from 'c/igUtility';
import { label } from 'c/igLabels';

const UPLOAD_MODAL_STATES = {
    NO_FILE: 'NO_FILE',
    FILE_SELECTED: 'FILE_SELECTED',
    UPLOADING_FILE: 'UPLOADING_FILE',
    UPLOAD_FAILED: 'UPLOAD_FAILED',
    UPLOAD_SUCCESSFUL: 'UPLOAD_SUCCESSFUL'
}

export default class IgIgomReaderUploadModal extends LightningElement {

    label = label;
    
    modalState = UPLOAD_MODAL_STATES.NO_FILE;
    fileReader;
    uploadModalProgress = 0;
    uploadModalErrorDescription = '';
    uploadedManualId = null;

    constructor() {
        super();
        this.fileReader = new FileReader();
    }

    @api
    showModal() {
        this.modalState = UPLOAD_MODAL_STATES.NO_FILE;
        this.uploadModalProgress = 0;
        this.uploadModalErrorDescription = '';
        this.uploadedManualId = null;
        this.template.querySelector('c-ig-modal.upload-modal').show();
        /* this.clearErrors(); */
    }

    @wire(getObjectInfo, { objectApiName: IGOM_MANUAL_OBJECT })
    objectInfo;

    // documentTypePicklist = util.object.toPicklist(constants.MANUAL.DOCUMENT_TYPE);

    get wiresQueried() {
        return (this.objectInfo && this.objectInfo.data && this.objectInfo.data.fields);
    }

    get isUploadModalAcceptDisabled() {
        return this.modalState === UPLOAD_MODAL_STATES.NO_FILE;
    }

    get isUploadModalDisabled() {
        return this.modalState === UPLOAD_MODAL_STATES.UPLOADING_FILE;
    }

    get isUploadModalFileSelectorShown() {
        return this.modalState === UPLOAD_MODAL_STATES.NO_FILE || this.modalState === UPLOAD_MODAL_STATES.FILE_SELECTED;
    }

    get isUploadModelUploading() {
        return this.modalState === UPLOAD_MODAL_STATES.UPLOADING_FILE;
    }

    get isUploadModelUploaded() {
        return this.modalState === UPLOAD_MODAL_STATES.UPLOAD_SUCCESSFUL;
    }

    get isUploadModelUploadFailed() {
        return this.modalState === UPLOAD_MODAL_STATES.UPLOAD_FAILED;
    }

    get isUploadComplete() {
        if (this.modalState === UPLOAD_MODAL_STATES.UPLOAD_SUCCESSFUL || this.modalState === UPLOAD_MODAL_STATES.UPLOAD_FAILED) {
            return true;
        } else {
            return false;
        }
    }

    get uploadModalButtonLabel() {
        if (this.modalState === UPLOAD_MODAL_STATES.UPLOAD_SUCCESSFUL) {
            return label.custom.issp_confirm;
        } else if (this.modalState === UPLOAD_MODAL_STATES.UPLOAD_FAILED) {
            return label.custom.ig_close;
        }
        return label.custom.ig_process_document;
    }

    get publishedDateLabel() {
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.fields && this.objectInfo.data.fields.Published_Date__c) {
            return this.objectInfo.data.fields.Published_Date__c.label;
        }
        return '[manual.Published_Date__c label unretrieved]';
    }

    get versionLabel() {
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.fields && this.objectInfo.data.fields.Version__c) {
            return this.objectInfo.data.fields.Version__c.label;
        }
        return '[manual.Version__c label unretrieved]';
    }

    get documentNameLabel() {
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.fields && this.objectInfo.data.fields.Document_Name__c) {
            return this.objectInfo.data.fields.Document_Name__c.label;
        }
        return '[manual.Document_Name__c label unretrieved]';
    }

    uploadModalAcceptHandler() {
        //If information from object was not propperly recovered, set error
        if (this.objectInfo === undefined) {
            util.debug.error('An error happened on uploadModalAcceptHandler. objectInfo', this.objectInfo);
            this.modalState = UPLOAD_MODAL_STATES.UPLOAD_FAILED;
        }
        if (this.modalState === UPLOAD_MODAL_STATES.FILE_SELECTED) {
            let file = this.template.querySelector('.upload-modal c-ig-file-picker').selectedFile;
            this.modalState = UPLOAD_MODAL_STATES.UPLOADING_FILE;
            this.uploadModalProgress = 0;
            this.uploadedManualId = null;
            this.fileReader.onloadend = (() => {
                let xmlContent = this.fileReader.result;
                this.uploadFile(xmlContent);
            });
            this.fileReader.onprogress = ((ev) => {
                this.uploadModalProgress = ev.loaded / ev.total * 100;
            });
            this.fileReader.readAsText(file);
        } else if (this.modalState === UPLOAD_MODAL_STATES.UPLOAD_FAILED) {
            this.template.querySelector('c-ig-modal.upload-modal').hide();
        } else if (this.modalState === UPLOAD_MODAL_STATES.UPLOAD_SUCCESSFUL) {
            this.updateManual();
        }
    }

    uploadModalFileSelected() {
        this.modalState = UPLOAD_MODAL_STATES.FILE_SELECTED;
    }

    uploadModalFileUnselected() {
        this.modalState = UPLOAD_MODAL_STATES.NO_FILE;
    }

    uploadFile(doc) {
        uploadIGOMDocument({xmlDoc: doc}).then(manualId => {
            this.modalState = UPLOAD_MODAL_STATES.UPLOAD_SUCCESSFUL;
            this.uploadedManualId = manualId;
            this.dispatchEvent(new CustomEvent('uploaded', {
                detail: {
                    manualId: this.uploadedManualId
                }
            }));
        }).catch(error => {
            console.error(error);
            this.uploadModalErrorDescription = JSON.stringify(error);
            this.modalState = UPLOAD_MODAL_STATES.UPLOAD_FAILED;
        });
    }

    updateManual() {
        activateIGOMManual({ manualId : this.uploadedManualId }).then(() => {
            this.dispatchEvent(new CustomEvent('updated', {
                detail: {
                    manualId: this.uploadedManualId
                }
            }));
            this.template.querySelector('c-ig-modal.upload-modal').hide();
        }).catch(error => {
            console.error(error);
            this.uploadModalErrorDescription = JSON.stringify(error);
            this.modalState = UPLOAD_MODAL_STATES.UPLOAD_FAILED;
        });
    }
}
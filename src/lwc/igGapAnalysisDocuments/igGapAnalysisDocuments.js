import { LightningElement, track, api, wire } from 'lwc';
import { constants, resources, util } from 'c/igUtility';
import { label } from 'c/igLabels';
import { refreshApex } from '@salesforce/apex';
import upsertGomDocument from '@salesforce/apex/IGOMDocumentUtil.upsertGomDocument';
import deleteGomDocument  from '@salesforce/apex/IGOMDocumentUtil.deleteGomDocument';
import getMyStationsDocuments from '@salesforce/apex/IGOMDocumentUtil.getMyStationsDocuments';
import copyManualAsGOM from '@salesforce/apex/IGOMComplianceReviewUtil.importIGOMProceduresAsConformity';
import getFullGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getFullGapAnalysis';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';
import deleteAttachment from '@salesforce/apex/IGOMAttachmentUtil.deleteAttachment';
import { permissions } from 'c/igConstants';

const DOCUMENT_FIELDS = ['id', 'recordType', 'name', 'abbreviation', 'type', 'publishDate', 'reviewDate', 'effectiveDate', 'version', 'edition', 'revision'];

const EMPTY_DOCUMENT = {
    name: '',
    type: constants.DOCUMENT.DOCUMENT_TYPE.VALUES.ONLINE_BASED,
    abbreviation: '',
    edition: '',
    version: '',
    revision: '',
    publishDate: '',
    effectiveDate: '',
    reviewDate: ''
};

const SCREEN_STATES = {
    DOCUMENT_LIST: 'DOCUMENT_LIST',
    DOCUMENT_EDITOR: 'DOCUMENT_EDITOR'
};

const LISTVIEW_ACTION = {
    EDIT: 'editDocument',
    DELETE: 'deleteDocument'
};

const documentTypeToString = {
    [constants.DOCUMENT.DOCUMENT_TYPE.VALUES.ONLINE_BASED]: 'URL-based',
    [constants.DOCUMENT.DOCUMENT_TYPE.VALUES.SOFTWARE_BASED]: 'Software-based',
    [constants.DOCUMENT.DOCUMENT_TYPE.VALUES.FILES_ON_SERVER]: 'Files on servers'
};

export default class IgGapAnalysisDocuments extends LightningElement {

    // Exposed properties
    @api stationId;
    @api gapAnalysisId;

    // Tracked properties

    @track _documentList = [];
    @track editingDocument;
    @track fileToDisplay;
    @track currentScreen = SCREEN_STATES.DOCUMENT_LIST;
    @track label = label;
    @track permissions;
    @track gapInUse;
    @track isCreatingNewDocument = false;

    // Internal properties

    get tableConfig() {
        return {
            id: {
                ignore: true
            },
            stationId: {
                ignore: true
            },
            attachments: {
                ignore: true
            },
            recordType: {
                ignore: true
            },
            type: {
                ignore: true
            },
            files: {
                ignore: true
            },
            reference: {
                ignore: true
            },
            typeString: {
                label: label.custom.ig_document_type_short
            },
            name: {
                label: label.custom.ig_document_name_short
            },
            abbreviation: {
                label: label.object.DOCUMENT.ABBREVIATED_NAME.substr(0, 4) + '.'
            },
            edition: {
                label: label.object.DOCUMENT.EDITION.substr(0, 2) + '.'
            },
            version: {
                label: label.object.DOCUMENT.VERSION.substr(0, 1) + '.'
            },
            revision: {
                label: label.object.DOCUMENT.REVISION.substr(0, 3) + '.'
            },
            publishDate: {
                label: label.object.DOCUMENT.PUBLISHED_DATE
            },
            reviewDate: {
                label: label.object.DOCUMENT.REVIEW_DATE
            },
            effectiveDate: {
                label: label.object.DOCUMENT.EFFECTIVE_DATE
            },
            [LISTVIEW_ACTION.EDIT]: {
                label: label.custom.ig_edit,
                type: 'link',
                hideHeader: true,
                centerContent: true
            },
            [LISTVIEW_ACTION.DELETE]: {
                label: label.custom.ig_delete,
                type: 'link',
                hideHeader: true,
                centerContent: true
            }
        };
    }

    // Imported properties
    resources = resources;
    constants = constants;

    pendingUploadFile;
    pendingRemovalFileId;
    disableImportButton;

    // Wires

    @wire(getMyStationsDocuments, { stationId : '$stationId' })
    getMyStationsDocumentsWired(response) {
        if (response.data) {
            this._documentList = response;
        }
    }

    @wire(getPermissionsApex, { stationId: '$stationId' })
    getPermissionsApexWired({ data, error }) {
        if (data) {
            this.permissions = data;
        }
    }

    @wire(getFullGapAnalysis, { gapAnalysisId : '$gapAnalysisId' })
    getGapAnalysisWired(response) {
        if (response.data) {
			this.gapInUse = response;
        }
	}

    // Main logic

    changeScreenToNewDocument() {
        this.editingDocument = Object.assign({}, EMPTY_DOCUMENT);
        this.fileToDisplay = undefined;
        this.pendingUploadFile = undefined;
        this.pendingRemovalFileId = undefined;
        this.currentScreen = SCREEN_STATES.DOCUMENT_EDITOR;
    }

    changeScreenToDocumentList() {
        this.editingDocument = null;
        this.fileToDisplay = undefined;
        this.pendingUploadFile = undefined;
        this.pendingRemovalFileId = undefined;
        this.currentScreen = SCREEN_STATES.DOCUMENT_LIST;
    }

    returnBack(event) {
        event.preventDefault();
        this.dispatchEvent(new CustomEvent('back'));
    }

    linkClickHandler(event) {
        const action = event.detail.column;
        const selectedDocumentId = event.detail.linkData;
        const selectedDocument = this.documentList.find(doc => doc.id == selectedDocumentId);
        if (action === LISTVIEW_ACTION.DELETE) {
            this.editingDocument = selectedDocument;
            this.template.querySelector('c-ig-modal.delete-modal').show();
        } else if (action === LISTVIEW_ACTION.EDIT) {
            this.currentScreen = SCREEN_STATES.DOCUMENT_EDITOR;
            this.editingDocument = Object.assign({}, EMPTY_DOCUMENT, selectedDocument);
            this.fileToDisplay = selectedDocument.files[0];
            this.pendingUploadFile = undefined;
        }
    }

    updateFiles(event) {
        const filePicker = this.template.querySelector('c-ig-file-picker');
        this.pendingUploadFile = filePicker.selectedFile;
    }

    unselectedFile(event) {
        const filePicker = this.template.querySelector('c-ig-file-picker');
        this.pendingUploadFile = filePicker.selectedFile;
        if (this.editingDocument.attachments && this.editingDocument.attachments.length > 0 && this.fileToDisplay) {
            const attachmentToRemove = this.editingDocument.attachments.find(att => att.Id == this.fileToDisplay.id);
            this.pendingRemovalFileId = attachmentToRemove.Id;
        }
        this.fileToDisplay = null;
    }

    renderedCallback() {
        const editorTypeSelect = this.template.querySelector('select[data-mapping="type"]');
        if (editorTypeSelect && this.editingDocument && this.editingDocument.type) {
            editorTypeSelect.value = this.editingDocument.type;
        }
    }

    mapToEditingDocument(event) {
        const mappeableInputs = Array.from(this.template.querySelectorAll('[data-mapping]'));
        for (const input of mappeableInputs) {
            const field = input.dataset.mapping;
            this.editingDocument[field] = input.value;
        }
    }

    // APEX calls

    async uploadNewDocument(event) {
        this.isCreatingNewDocument = true;
        const document = DOCUMENT_FIELDS.reduce((acc, val) => (
            this.editingDocument[val] ? {...acc, [val]: this.editingDocument[val]} : acc
        ), {});
        try {
            // Create the document
            const createdDocument = await upsertGomDocument({
                stationId: this.stationId,
				gomDocument: document
            });
            // Remove old file
            if (this.pendingRemovalFileId) {    
                await deleteAttachment({ attachmentId : this.pendingRemovalFileId });
            }
            // Upload new file if needed
            if (this.pendingUploadFile) {
				await util.chunkedUpload(this.pendingUploadFile, createdDocument.id);
            }
            refreshApex(this._documentList);
            refreshApex(this.gapInUse);
		} catch(error) {
			util.debug.error('On document creation', error);
		} finally {
            this.isCreatingNewDocument = false;
        }
        this.changeScreenToDocumentList();
    }

    async deleteModalAcceptClick(event) {
        try {
            await deleteGomDocument({ 
                gomDocumentId: this.editingDocument.id 
            });
            refreshApex(this._documentList);
        } catch(error) {
            util.debug.error('On document deletion', error);
        }
        this.template.querySelector('c-ig-modal.delete-modal').hide();
    }

    async importManualAsDocument(event) {
        this.disableImportButton = true;
		try {
			await copyManualAsGOM({
				gapAnalysisId: this.gapAnalysisId
			});
		} catch (error) {
			util.debug.error('importManualAsDocument on copy error', error);
        }
        refreshApex(this._documentList);
        refreshApex(this.gapInUse);
	}

    // Data properties

    get documentList() {
        if (this._documentList && this._documentList.data) {
            return this._documentList.data.map(doc => Object.assign({}, doc, {
                type: doc.type,
                typeString: documentTypeToString[doc.type],
                files: doc.attachments.map(attach => ({ id: attach.Id, name: attach.Name, size: attach.BodyLength, uploaded: true, url: '/sfsites/c/servlet/servlet.FileDownload?file='+attach.Id })),
                publishDate: doc.publishDate ? doc.publishDate.split('T')[0] : undefined,
                reviewDate: doc.reviewDate ? doc.reviewDate.split('T')[0] : undefined,
                effectiveDate: doc.effectiveDate ? doc.effectiveDate.split('T')[0] : undefined,
                [LISTVIEW_ACTION.EDIT]: doc.abbreviation === 'IGOM' ? null : doc.id,
                [LISTVIEW_ACTION.DELETE]: doc.id
            }))
        } else {
            return [];
        }
    };

    get labelRemoveDocumentWarning() {
        return util.string.format(label.custom.ig_remove_document_warning, { documentName: this.editingDocument.name});
    }

    // Logical properties

    get isCurrentScreenDocumentList() {
        return this.currentScreen === SCREEN_STATES.DOCUMENT_LIST;
    }
    get isCurrentScreenNewDocument() {
        return this.currentScreen === SCREEN_STATES.DOCUMENT_EDITOR;
    }
    get hasDocuments() {
        console.log('Document list ' + JSON.stringify(this.documentList));
        return this.documentList && this.documentList.length > 0;
    }
    get isFileSelected() {
        return this.pendingUploadFile != null || this.fileToDisplay != null;
    }
    get isUploadEnabled() {
        return this.isValidDocument && !this.isCreatingNewDocument;
    }
    get isUploadButtonDisabled() {
        return !this.isUploadEnabled;
    }
    get isDocumentTypeURLBased() {
        return this.editingDocument.type === constants.DOCUMENT.DOCUMENT_TYPE.VALUES.ONLINE_BASED;
    }
    get isDocumentTypeSoftwareBased() {
        return this.editingDocument.type === constants.DOCUMENT.DOCUMENT_TYPE.VALUES.SOFTWARE_BASED;
    }
    get isDocumentTypeFilesOnServer() {
        return this.editingDocument.type === constants.DOCUMENT.DOCUMENT_TYPE.VALUES.FILES_ON_SERVER;
    }
    get isEditionRequired() {
        return this.isDocumentTypeURLBased && this.editingDocument.version === '' && this.editingDocument.revision === '';
    }
    get isVersionRequired() {
        return this.isDocumentTypeFilesOnServer && this.editingDocument.edition === '' && this.editingDocument.revision === '';
    }
    get isRevisionRequired() {
        return this.isDocumentTypeFilesOnServer && this.editingDocument.version === '' && this.editingDocument.edition === '';
    }
    get isPublishDateRequired() {
        if (this.isDocumentTypeURLBased || this.isDocumentTypeSoftwareBased) {
            return this.editingDocument.reviewDate == '' && this.editingDocument.effectiveDate == '';
        } else if (this.isDocumentTypeFilesOnServer) {
            return false;
        }
    }
    get isEffectiveDateRequired() {
        if (this.isDocumentTypeURLBased || this.isDocumentTypeSoftwareBased) {
            return this.editingDocument.reviewDate == '' && this.editingDocument.publishDate == '';
        } else if (this.isDocumentTypeFilesOnServer) {
            return true;
        }
    }
    get isReviewDateRequired() {
        if (this.isDocumentTypeURLBased || this.isDocumentTypeSoftwareBased) {
            return this.editingDocument.publishDate == '' && this.editingDocument.effectiveDate == '';
        } else if (this.isDocumentTypeFilesOnServer) {
            return false;
        }
    }
    get isReviewDateDisabled() {
        return this.isDocumentTypeFilesOnServer;
    }
    get isValidDocument() {
        let mandatoryFields = ['type', 'name', 'abbreviation'];
        if (this.isEditionRequired) mandatoryFields.push('edition');
        if (this.isVersionRequired) mandatoryFields.push('version');
        if (this.isRevisionRequired) mandatoryFields.push('revision');
        if (this.isPublishDateRequired) mandatoryFields.push('publishDate');
        if (this.isEffectiveDateRequired) mandatoryFields.push('effectiveDate');
        if (this.isReviewDateRequired) mandatoryFields.push('reviewDate');
        return !mandatoryFields.some(field => this.editingDocument[field] == '');
    }
    get importIgomPermission() {
        return this.permissions && this.permissions[permissions.DOCUMENT_GAP] && this.permissions[permissions.EDIT_GAP];
    }
    get importIgomButtonDisabled() {
        return !(!this.disableImportButton && this.importIgomPermission && this.gapInUse && this.gapInUse.data && this.gapInUse.data.references && this.gapInUse.data.references.length === 0);
    }

    // Style properties

    get uploadButtonClass() {
        return 'button mr-5' + (this.isUploadEnabled ? ' btn-ig-primary' : ' btn-ig-primary-disabled');
    }
    get importIgomButtonClass() {
        return 'button mr-1' + (this.importIgomButtonDisabled ? ' btn-ig-secondary-disabled' : ' btn-ig-secondary');
    }
}
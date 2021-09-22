import { LightningElement, track, api, wire } from 'lwc';
import { resources, util, constants } from 'c/igUtility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { permissions } from 'c/igConstants';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import { label } from 'c/igLabels';

import COMMENT_LANG from '@salesforce/schema/Compliance_Review_Part__c.Comment_Language__c';
import COMPLIANCE_REVIEW_PART_OBJECT from '@salesforce/schema/Compliance_Review_Part__c';

import getFullGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getFullGapAnalysis';
import upsertProcedureCompliance from '@salesforce/apex/IGOMComplianceReviewPartUtil.upsertProcedureCompliance';
import deleteProcedureCompliance from '@salesforce/apex/IGOMComplianceReviewPartUtil.deleteProcedureCompliance';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';
import deleteAttachment from '@salesforce/apex/IGOMAttachmentUtil.deleteAttachment';

export default class IgGapAnalysisReferenceProcedureEditor extends LightningElement {
	@track label = label;

    igomRecordType;

    // Exposed properties
    @api documentList;

    // Internal properties

    resources = resources;
    constants = constants;

    @track _editingGapAnalysisItem;
    @track gapAnalysisId;

    // Recover Comment Language values for IGOM record type
    @wire(getPicklistValues, { recordTypeId: '$igomRecordType', fieldApiName: COMMENT_LANG })
    igomComplianceReviewPicklistValues;

    // Get compliance review part object
    @wire(getObjectInfo, { objectApiName: COMPLIANCE_REVIEW_PART_OBJECT })
    Function({error,data}){
        if(data){
            for (var property in data.recordTypeInfos) {
                if(data.recordTypeInfos[property].name === 'IGOM'){
                    this.igomRecordType = property;
                }
            }
        }
    };

    @wire(getObjectInfo, { objectApiName: COMPLIANCE_REVIEW_PART_OBJECT })
    igomProcedureComplianceInfo;

    @wire(getFullGapAnalysis, { gapAnalysisId :'$gapAnalysisId' })
    _gapInUse;
    
    @wire(getPermissionsApex, { gapAnalysisId: '$gapAnalysisId' })
    permissions;

    _pendingUploads = [];
    _otherLangVariation = false;
    _isLoading = false;

    set editingGapAnalysisItem(value) {
        if (value) {
            this._editingGapAnalysisItem = JSON.parse(JSON.stringify(value));
            this.renderSelectValue();
            this.gapAnalysisId = value.gapAnalysisId;
        }
    };
    get editingGapAnalysisItem() {
        return this._editingGapAnalysisItem;
    }

    // Main logic

    @api editGapAnalysisItem(item) {
        this.editingGapAnalysisItem = item;
    }

    @api newGapAnalysisItem(gapAnalysisId, selectedProcedure) {
        this.editingGapAnalysisItem = {
            userProvisionDocument: '',
            userProvisionProcedure: '',
            attachments: [],
            gapAnalysisId: gapAnalysisId,
            igomAuditableProcedureId: selectedProcedure.Id,
            igomAuditableProcedureIsCritical: selectedProcedure.Is_Safety_Critical__c,
            isReviewed: true
        };
    }

    @api close() {
        this._editingGapAnalysisItem = undefined;
    }

    debouncedUpdateEditingItem = util.debounce((info) => {
        this._editingGapAnalysisItem[info.field] = info.value;
    }, 100);

    updateEditingItem(event) {
        this.debouncedUpdateEditingItem({
            value : event.target.value,
            field : event.target.dataset.field
        });
    }
    
    updateFiles(event) {
        const filePicker = this.template.querySelector('c-ig-file-picker');
        this._pendingUploads = filePicker.selectedFile;
    }

    changeVariationStatus(event) {
        let selectedTag = event.target;
        this.editingGapAnalysisItem.variationStatus = selectedTag.dataset.variationStatus;
    }
    
    toggleAttachmentDelete(event) {
        const clickedDiv = event.target.closest('div');
        const attachmentId = clickedDiv.dataset.id;
        const selectedAttachment = this.editingGapAnalysisItem.attachments.find(el => el.Id == attachmentId);
        selectedAttachment.delete = !selectedAttachment.delete;
    }

    discardChangesButton(event) {
        this._editingGapAnalysisItem = null;
    }

    removeButton(event) {
        this.template.querySelector('c-ig-modal.delete-confirmation').show();
    }

    downloadAttachment(event) {
        const fileElement = event.target.closest('a.file');
        const id = fileElement.dataset.id;
        const name = fileElement.dataset.name;
        const downloadElement = document.createElement('a');
        const urlPath = window.location.href.substr(0,window.location.href.lastIndexOf('/'));
        downloadElement.href = urlPath + '/sfsites/c/servlet/servlet.FileDownload?file=' + id;
        downloadElement.target = '_self';
        downloadElement.download = name;
        document.body.appendChild(downloadElement);
        downloadElement.click(); 
    }

    // Apex calls

    async confirmDelete(event) {
        this._isLoading = true;
        const gapAnalysisItem = this._editingGapAnalysisItem;
		try {
			await deleteProcedureCompliance({ compliaceReviewPartId : gapAnalysisItem.id });
		} catch(error) {
			util.debug.error(error);
        }
        refreshApex(this._gapInUse);
        this._editingGapAnalysisItem = null;
        this._isLoading = false;
    }

    async saveButton(event) {
        this._isLoading = true;
        const gapAnalysisItem = this._editingGapAnalysisItem;
        const pendingAttachmentUploads = this._pendingUploads;
        const pendingAttachmentRemovals = this._editingGapAnalysisItem.attachments.filter((att) => att.delete);
        // Remove attachments
        for (const attachment of pendingAttachmentRemovals) {
			try {
				await deleteAttachment({ attachmentId: attachment.Id });
			} catch(error) {
				console.error(error);
			}
		}
        // Update the gap analysis item
		let updatedReference;
		try {
			updatedReference = await upsertProcedureCompliance({
				complianceReviewPart: gapAnalysisItem
			});
		} catch(error) {
			util.debug.error(error);
        }
		// Upload the new attachments
		for (const file of pendingAttachmentUploads) {
			try {
				const attachmentId = await util.chunkedUpload(file, updatedReference.id);
                // Upload of new attachments deletes old attachments (may change)
                updatedReference.attachments = [{
					id: attachmentId,
					parentId: updatedReference.id,
					name: file.name,
					contentType: file.type
                }];
			} catch(error) {
				util.debug.error(error);
			}
        }
        // Remove the pending attachments
        this._pendingUploads = [];
        // Refresh the wire
        refreshApex(this._gapInUse);
        // Reset the variables
        this._editingGapAnalysisItem = null;
        this._isLoading = false;
    }

    // Render logic

    renderSelectValue() {
        if (this.template) {
            const selectDocument = this.template.querySelector('select[data-field="document"]');
            if (selectDocument) {
                selectDocument.value = this.editingGapAnalysisItem.document;
            }
            const selectLanguage = this.template.querySelector('select[data-field="variationCommentLang"]');
            if (selectLanguage) {
                selectLanguage.value = this.editingGapAnalysisItem.variationCommentLang;
            }
        }
    }
    
    renderedCallback() {
        this.renderSelectValue();
    }

    addVariationLanguage(){
        this.editingGapAnalysisItem.variationAlternativeComments = null;
        this.editingGapAnalysisItem.variationCommentLang = null;
        this._otherLangVariation = !this._otherLangVariation;
    }

    // Logical properties

    get isEditingNonCriticalVariation() {
        return (this.editingGapAnalysisItem.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION
            && !this.editingGapAnalysisItem.igomAuditableProcedureIsCritical && !this.editingGapAnalysisItem.isReviewed);
    }
    get isEditingCriticalVariation() {
        return (this.editingGapAnalysisItem.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION
            && this.editingGapAnalysisItem.igomAuditableProcedureIsCritical && !this.editingGapAnalysisItem.isReviewed);
    }
    get isProcedurePendingReview() {
        return (this.editingGapAnalysisItem.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION && 
            !this.editingGapAnalysisItem.isReviewed);
    }
    get isEdition() {
        return this.editingGapAnalysisItem.id != null;
    }
    get isEditingGapAnalysisItemVariation() {
        return this.editingGapAnalysisItem.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION;
    }
    get isSavingEnabled() {
        if (this.editingGapAnalysisItem.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.OUT_OF_SCOPE){
            return true;
        } else if (this.editingGapAnalysisItem.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION){
            return this.editingGapAnalysisItem.document && 
                this.editingGapAnalysisItem.userProvisionProcedure &&
                this.editingGapAnalysisItem.variationStatus &&
                this.editingGapAnalysisItem.variationComments;
        }else{
            return this.editingGapAnalysisItem.document && 
                this.editingGapAnalysisItem.userProvisionProcedure &&
                this.editingGapAnalysisItem.variationStatus;
        }
    }
    get isSaveButtonDisabled() {
        return !this.isSavingEnabled || this._isLoading;
    }
    get canEditActionNotes() {
        return this.permissions && this.permissions.data && this.permissions.data[permissions.VIEW_COMMENTS_GAP];
    }
    get isOtherLangAdded(){
        if(this.editingGapAnalysisItem.variationAlternativeComments != null &&
            this.editingGapAnalysisItem.variationCommentLang != null){
            this._otherLangVariation = true; 
        }
        return this._otherLangVariation;
    }

    // Style properties

    get pendingReviewClass() {
        let classes = ['col-12', 'text-left', 'mb-3'];
        if (this.isEditingNonCriticalVariation) {
            classes.push('non-critical-label');
        } else if (this.isEditingCriticalVariation) {
            classes.push('critical-label');
        }
        return classes.join(' ');
    }
    get buttonTagConformityClass() {
        let classes = ['tag-button', 'btn-ig-tag-success'];
        if (this.editingGapAnalysisItem.variationStatus !== constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.CONFORMITY) {
            classes.push('btn-ig-tag-disabled');
        }
        return classes.join(' ');
    }
    get buttonTagVariationClass() {
        let classes = ['tag-button', 'ml-4'];
        if (this.editingGapAnalysisItem.igomAuditableProcedureIsCritical) {
            classes.push('btn-ig-tag-danger');
        } else {
            classes.push('btn-ig-tag-warning');
        }
        if (this.editingGapAnalysisItem.variationStatus !== constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION) {
            classes.push('btn-ig-tag-disabled');
        }
        return classes.join(' ');
    }
    get buttonTagOutOfScopeClass() {
        let classes = ['tag-button', 'btn-ig-tag-out', 'ml-4'];
        if (this.editingGapAnalysisItem.variationStatus !== constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.OUT_OF_SCOPE) {
            classes.push('btn-ig-tag-disabled');
        }
        return classes.join(' ');
    }
    get editorDivClass() {
        let classes = ['col-12', 'row', 'box-shadow-col', 'slds-grid_vertical-align-end', 'p-3', 'mt-4', 'mb-4', 'mr-0', 'ml-0'];
        if (this.isEditingNonCriticalVariation) {
            classes.push('non-critical-variation');
        } else if (this.isEditingCriticalVariation) {
            classes.push('critical-variation');
        }
        return classes.join(' ');
    }
    get saveButtonClass() {
        let classes = ['button', 'btn-ig-primary'];
        if (!this.isSavingEnabled) {
            classes.push('btn-ig-primary-disabled');
        }
        return classes.join(' ');
    }

    get addVariationCommentInLanguageClass(){
        let classes = ['col-5', 'text-left', 'cursor-pt', 'add-new-reference', 'form-group'];
        if(this._otherLangVariation || (this.editingGapAnalysisItem.variationAlternativeComments != null &&
            this.editingGapAnalysisItem.variationCommentLang != null)){
            classes.push('text-gray');
        } else {
            classes.push('text-blue');
        }
        return classes.join(' ');
    }

    get numRowsVariationComments(){
        if(this._otherLangVariation || (this.editingGapAnalysisItem.variationAlternativeComments != null &&
            this.editingGapAnalysisItem.variationCommentLang != null)){
            return 1;
        }else{
            return 3;
        }
    }

    get referenceRemoveMsg() {
        let msgToReturn = this.label.custom.ig_reference_will_be_removed;
        msgToReturn = msgToReturn.replace('{0}', (this.editingGapAnalysisItem.userProvisionDocument === undefined ? '' : this.editingGapAnalysisItem.userProvisionDocument));
        return msgToReturn.replace('{1}', (this.editingGapAnalysisItem.userProvisionProcedure === undefined ? '' : this.editingGapAnalysisItem.userProvisionProcedure));
    }

    get commentLanguages(){
        var langs = [];
        this.igomComplianceReviewPicklistValues.data.values.forEach(element => {
            langs.push(element.value);
        });
        return langs;
    }
}
import { LightningElement, api, wire, track } from 'lwc';
import { resources, util, constants } from 'c/igUtility';
import { label } from 'c/igLabels';
import markAsReviewed from '@salesforce/apex/IGOMComplianceReviewPartUtil.markAsReviewed';
import { refreshApex } from '@salesforce/apex';
import getFullGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getFullGapAnalysis';

const statusAppearance = {
    [constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.CONFORMITY]: {
        label: label.custom.ig_conformity,
        class: 'btn-ig-tag-success'
    },
    [constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.OUT_OF_SCOPE]: {
        label: label.custom.ig_out_of_scope,
        class: 'btn-ig-tag-out'
    },
    [constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION]: {
        label: label.custom.ig_variation,
        class: 'btn-ig-tag-warning'
    }
}

export default class IgGapAnalysisReferenceProcedureItem extends LightningElement {
    @track label = label;

    @api gapAnalysisItem;

    resources = resources;

    folded = true;

    // Main logic

    @wire(getFullGapAnalysis, { gapAnalysisId :'$gapAnalysisId' })
	_gapInUse;

    toggleDetails(ev) {
        ev.stopPropagation();
        this.folded = !this.folded;
    }

    downloadAttachment(event) {
        const id = event.target.dataset.id;
        const name = event.target.dataset.name;
        const downloadElement = document.createElement('a');
        const urlPath = window.location.href.substr(0,window.location.href.lastIndexOf('/'));
        downloadElement.href = urlPath + '/sfsites/c/servlet/servlet.FileDownload?file=' + id;
        downloadElement.target = '_self';
        downloadElement.download = name;
        document.body.appendChild(downloadElement);
        downloadElement.click(); 
    }

    mainDivClick() {
        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                gapAnalysisItem: this.gapAnalysisItem
            }
        }));
    }

    // Apex calls

    async markAsReviewed(event) {
        event.stopPropagation();
        if (!this.gapAnalysisItem.isReviewed) {
            try {
                await markAsReviewed({
                    compliaceReviewPartId: this.gapAnalysisItem.id
                });
            } catch (error) {
                util.debug.error(error);
            }
            refreshApex(this._gapInUse);
        }
    }

    // Data properties

    get gapAnalysisId() {
        return this.gapAnalysisItem ? this.gapAnalysisItem.gapAnalysisId : null;
    }
    get userProvisionDocument() {
        return this.gapAnalysisItem.userProvisionDocument ? this.gapAnalysisItem.userProvisionDocument : '\xa0';
    }
    get userProvisionProcedure() {
        return this.gapAnalysisItem.userProvisionProcedure ? this.gapAnalysisItem.userProvisionProcedure : '\xa0';
    }
    get attachmentNum() {
        return this.gapAnalysisItem.attachments.length;
    }
    get statusText() {
        return statusAppearance[this.gapAnalysisItem.variationStatus].label;
    }
    
    // Logical properties

    get hasComments() {
        return this.gapAnalysisItem.variationComments;
    }
    get hasCommentsInOtherLanguage() {
        return this.gapAnalysisItem.variationAlternativeComments;
    }
    get hasNotes() {
        return this.gapAnalysisItem.notes;
    }
    get hasAttachments() {
        return this.gapAnalysisItem.attachments.length > 0;
    }
    get hasAnyDetail() {
        return this.hasNotes || this.hasAttachments || this.hasComments || this.hasCommentsInOtherLanguage;
    }
    get isVariation() {
        return this.gapAnalysisItem.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION;
    }
    get isNonCriticalVariation() {
        return (this.isVariation && !this.gapAnalysisItem.igomAuditableProcedureIsCritical && !this.gapAnalysisItem.isReviewed);
    }
    get isCriticalVariation() {
        return (this.isVariation && this.gapAnalysisItem.igomAuditableProcedureIsCritical && !this.gapAnalysisItem.isReviewed);
    }

    // Styling properties

    get commentClass() {
        return (this.gapAnalysisItem.notes || this.gapAnalysisItem.variationComments) ? 'action-active' : 'action-inactive';
    }
    get attachmentClass() {
        return this.gapAnalysisItem.attachments.length > 0 ? 'action-active' : 'action-inactive';
    }
    get foldIconClass() {
        return this.hasAnyDetail ? '' : 'slds-hide';
    }
    get statusClass() {
        let classes = ['procedure-tag', 'tag-button'];
        classes.push(statusAppearance[this.gapAnalysisItem.variationStatus].class);
        if (this.isVariation && this.gapAnalysisItem.igomAuditableProcedureIsCritical) {
            classes.pop();
            classes.push('btn-ig-tag-danger');
        }
        return classes.join(' ');
    }
    get mainDivClass() {
        let styleClass = 'procedure-row slds-grid slds-wrap slds-p-around_medium slds-m-right_small slds-m-bottom_medium';
        if (this.isNonCriticalVariation) {
            styleClass += ' non-critical-variation';
        } else if (this.isCriticalVariation) {
            styleClass += ' critical-variation';
        }
        return styleClass;
    }
    get pendingReviewClass() {
        let styleClass = 'slds-col slds-align_absolute-center slds-text-align_center';
        if (!this.gapAnalysisItem.isReviewed) {
            styleClass += ' cursor-pt';
        } else {
            styleClass += ' invisible';
        }
        return styleClass;
    }

    get variationDescriptionInLangMsg(){
        let msgToReturn = this.label.custom.ig_variation_description_in_lang;
        return  msgToReturn.replace('{0}', (this.gapAnalysisItem.variationCommentLang === undefined ? '' : this.gapAnalysisItem.variationCommentLang));
    }
}
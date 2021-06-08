import { LightningElement, api } from 'lwc';
import { util, resources, constants } from 'c/igUtility';

export default class IgVariationReportProcedure extends LightningElement {

    resources = resources;

    folded = true;

    toggleDetails() {
        this.folded = !this.folded;
    }

    @api
    procedureCompliance;

    downloadAttachment(event) {
        const div = event.target.closest('.file');
        const id = div.dataset.id;
        const name = div.dataset.name;
        const downloadElement = document.createElement('a');
        const urlPath = window.location.href.substr(0,window.location.href.lastIndexOf('/'));
        downloadElement.href = urlPath + '/sfsites/c/servlet/servlet.FileDownload?file=' + id;
        downloadElement.target = '_self';
        downloadElement.download = name;
        document.body.appendChild(downloadElement);
        downloadElement.click(); 
    }

    get igomProcedureName() {
        let name = '';
        if (this.procedureCompliance.index.chapterId) {
            name += this.procedureCompliance.index.chapterNum;
            if (this.procedureCompliance.index.sectionId) {
                name += '.' + this.procedureCompliance.index.sectionNum;
                if (this.procedureCompliance.index.subsectionId) {
                    name += '.' + this.procedureCompliance.index.subsectionNum;
                }
            }
        }
        name += (name ? ' ' : '') + this.procedureCompliance.igomAuditableProcedureName;
        return name;
    }

    get attachmentNum() {
        return this.procedureCompliance.attachments ? this.procedureCompliance.attachments.length : 0;
    }

    get hasVariationComments() {
        return this.procedureCompliance.variationComments != null;
    }

    get hasMultilangVariationComments() {
        return this.procedureCompliance.variationAlternativeComments != null;
    }

    get hasAttachments() {
        return this.procedureCompliance.attachments.length > 0;
    }

    get foldIconClass() {
        return !this.hasVariationComments && !this.hasAttachments ? 'slds-hide' : '';
    }

    get mainDivClass() {
        const baseClass = 'procedure-row slds-grid slds-wrap slds-p-around_medium slds-m-right_small slds-m-bottom_medium';
        if (this.isCriticalVariation) {
            return baseClass + ' critical-variation';
        } else if (this.isNonCriticalVariation) {
            return baseClass + ' non-critical-variation';
        }
        return baseClass;
    }

    get commentClass() {
        return this.hasVariationComments ? 'action-active' : 'action-inactive';
    }

    get attachmentClass() {
        return this.hasAttachments ? 'action-active' : 'action-inactive';
    }

    get procedureActionsClass() {
        let classes = 'procedure-actions slds-p-left_small slds-size_2-of-12 slds-grid';
        if (this.hasVariationComments || this.hasAttachments) {
            classes += ' cursor-pt';
        }
        return classes;
    }

    get isCriticalVariation() {
        return (this.procedureCompliance.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION && 
            this.procedureCompliance.statusValue === constants.PROCEDURE_COMPLIANCE.STATUS_VALUE.VALUES.OUT_OF_DATE);
    }
    get isNonCriticalVariation() {
        return (this.procedureCompliance.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION && 
            this.procedureCompliance.statusValue === constants.PROCEDURE_COMPLIANCE.STATUS_VALUE.VALUES.EXPIRED);
    }

}
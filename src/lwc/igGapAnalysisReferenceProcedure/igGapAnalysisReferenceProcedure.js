import { LightningElement, api, track, wire } from 'lwc';
import { util, resources, constants } from 'c/igUtility';
import { refreshApex } from '@salesforce/apex';
import { label } from 'c/igLabels';
import getFullGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getFullGapAnalysis';

let exampleGapAnalysisItem = {
    id : 'testid',
    reference: {
        userProvisionDocument : 'example document',
        userProvisionProcedure : 'example procedure',
        variationStatus : constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION,
        statusValue: 'outOfDate',
        notes: 'example notes',
        attachments : []
    }
};

export default class igGapAnalysisReferenceProcedure extends LightningElement {
	@track label = label;
    
    // Public properties

    @api get itemSelected() {
        return this._itemSelected;
    }
    set itemSelected(value) {
        this._itemSelected = value;
        if (this.references.length === 0) {
            this.delayedAutoReference = true;
        } else {
            this.delayedAutoReference = false;
        }
        this.autogenerateReference();
    }
    @api gapAnalysisId;
    @api documentList = [];

    // Internal properties

    resources = resources;
    delayedAutoReference = false;
    editableProcedure;
    _gapInUse;
    _itemSelected;

    // Main logic

    @wire(getFullGapAnalysis, { gapAnalysisId :'$gapAnalysisId' })
	getGapAnalysisWired(response) {
		if (response.data) {
			this._gapInUse = response;
		}
    }
    
    refreshGapAnalysis() {
        refreshApex(this._gapInUse);
    }
    
    addNewGapAnalysisItem() {
        const referenceEditor = this.template.querySelector('c-ig-gap-analysis-reference-procedure-editor');
        if (this.gapAnalysisId && this.selectedProcedure && referenceEditor) {
            referenceEditor.newGapAnalysisItem(this.gapAnalysisId, this.selectedProcedure);
        }
    }

    selectGapAnalysisItem(event) {   
        const gapAnalysisItemId = event.detail.gapAnalysisItem.id;
        const gapAnalysisItem = this.references.find(gaItem => gaItem.id == gapAnalysisItemId); 
        const referenceEditor = this.template.querySelector('c-ig-gap-analysis-reference-procedure-editor');
        referenceEditor.editGapAnalysisItem(gapAnalysisItem);
    }

    moveToProcedure(event) {
        const arrowDiv = event.target.closest('div[data-name]');
        if (arrowDiv) {
            const eventName = arrowDiv.dataset.name;
            this.dispatchEvent(new CustomEvent('changeprocedure', { 
                detail: {
                    eventName: eventName,
                    procedureId: this.selectedProcedureId
                }
            }));
        }
    }

    renderedCallback() {
        if (this.delayedAutoReference) {
            this.autogenerateReference();
        }
    }

    autogenerateReference() {
        const referenceEditor = this.template.querySelector('c-ig-gap-analysis-reference-procedure-editor');
        if (referenceEditor && this.selectedProcedure) {
            if (this.delayedAutoReference) {
                referenceEditor.newGapAnalysisItem(this.gapAnalysisId, this.selectedProcedure);
            } else {
                referenceEditor.close();
            }
            this.delayedAutoReference = false;
        }
    }

    // Data properties

    get gapInUse() {
        return this._gapInUse ? this._gapInUse.data : null;
    }

    get selectedProcedureId() {
        return this.itemSelected ? this.itemSelected.procedure.Id : null;
    }

    get selectedProcedure() {
        return this.itemSelected ? this.itemSelected.procedure : null;
    }

    get references() {
        if (this.selectedProcedureId && this.gapInUse) {
            const references = this.gapInUse.references.filter(ref => ref.igomAuditableProcedureId === this.selectedProcedureId);
            return references;
        }
        return [];
    }

    // Logical properties

    get isEditingExistingProcedure() {
        return this.editableProcedure.id !== undefined;
    }
    get editableProcedureAcknowledgementsDone() {
        return this.editableProcedure.acknowledgements.filter(acknowledgement => acknowledgement.acknowledged).length;
    }
    get editableProcedureAcknowledgementsMax() {
        return this.editableProcedure.acknowledgements.length;
    }
    get documentsExist() {
        return this.documentList && this.documentList.length > 0;
    }
}
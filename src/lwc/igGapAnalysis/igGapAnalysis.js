import { LightningElement, track, api, wire } from 'lwc';
import { constants, util } from 'c/igUtility';
import { label } from 'c/igLabels';
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';
import getFullGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getFullGapAnalysis';
import getMyStationsDocuments from '@salesforce/apex/IGOMDocumentUtil.getMyStationsDocuments';
import confirmAllReferences from '@salesforce/apex/IGOMComplianceReviewPartUtil.confirmAllNonVariatingReferences';

export default class IgGapAnalysis extends LightningElement {

	@track label = label;

	@api stationId;

	@api get sectionObj() {
		return this._sectionObj;
	};
	set sectionObj(value) {
		if (value) {
			// Check to see if its the same section, so we reselect the object
			let reselectProcedureId;
			if (value && this._sectionObj && value.procedure.Id === this._sectionObj.procedure.Id && this.itemSelectedObj) {
				reselectProcedureId = this.itemSelectedObj.procedure.Id;
			}
			if (this.autoselectProcedureId) {
				reselectProcedureId = this.autoselectProcedureId;
				this.autoselectProcedureId = undefined;
			}
			// Make a deep copy to be able to modify it
			this._sectionObj = JSON.parse(JSON.stringify(value));
			// Recalculate internals
			this._index = 0;
			this._warningIndex = 0;
			this._indexPositions = [];
			this._warningIndexPositions = [];
			this._proceduresById = {};
			this.itemSelectedObj = null;
			this.setProceduresIndexes(this._sectionObj);
			this.setFirstAndLastIndexes(this._sectionObj);
			// Select the same procedure
			if (reselectProcedureId) {
				this.selectProcedure(reselectProcedureId);
			}
			if (this._sectionObj && this._gapInUse) {
				// For single procedures, autoselect them
				if (!this._sectionObj.subprocedures) {
					this.selectProcedure(this._sectionObj.procedure.Id);
				}
				this.setReferencesStatus();
			}
		}
	}
	
	@api chapter;

	@api gapAnalysisId;

	@track _documentList = [];
	@track _gapInUse;

	get gapInUse() {
		return this._gapInUse ? this._gapInUse.data : null;
	}

	selectedProcedureId;
	autoselectProcedureId;

	@track itemSelectedObj;

	_index;
	_warningIndex;
	_indexPositions;
	_warningIndexPositions;
	_proceduresById;

	@track _sectionObj;

	@wire(CurrentPageReference) pageRef;

	get documentList() {
		return this._documentList.data;
	}

	@wire(getMyStationsDocuments, { stationId : '$stationId'})
	getMyStationsDocumentsWired(response) {
		if (response.data) {
			this._documentList = response;
		}
	}

	@wire(getFullGapAnalysis, { gapAnalysisId :'$gapAnalysisId' })
	getGapAnalysisWired(response) {
		if (response.data) {
			this._gapInUse = response;
			// For single procedures, autoselect them
			if (this._sectionObj && this._gapInUse) {
				if (!this._sectionObj.subprocedures) {
					this.selectProcedure(this._sectionObj.procedure.Id);
				}
				this.setReferencesStatus();
			}
		}
	}

	async confirmReferences() {
		console.log('Confirm references');
		const autoconfirmableReferences = this.gapInUse.references.filter(reference => 
			!reference.isReviewed && reference.variationStatus !== constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION
		);
		console.log('autoconfirmableReferences ' + JSON.stringify(autoconfirmableReferences));
		await confirmAllReferences({ referencesToReview : autoconfirmableReferences });
		refreshApex(this._gapInUse);
	}

	//Recursive methods
	setProceduresIndexes(procedure){
		if (procedure.subprocedures === null || procedure.subprocedures === undefined) {
			let procedureId = procedure.procedure.Id;
			this._indexPositions.push(procedureId);
			this._proceduresById[procedureId] = procedure;
			if (procedure.modified){
				this._warningIndexPositions.push(procedure.procedure.Id);
			}
		} else {
			if(procedure.subprocedures && procedure.subprocedures.length !== 0) {
				procedure.subprocedures.forEach(subprocedure => {
					this.setProceduresIndexes(subprocedure);
				});
			}
		}
	}

	setFirstAndLastIndexes(procedure) {
		if (procedure.subprocedures === null || procedure.subprocedures === undefined) {            

			procedure.hasPositionsBefore = this._indexPositions[0] !== procedure.procedure.Id;

			procedure.hasPositionsAfter = this._indexPositions[(this._indexPositions.length-1)] !== procedure.procedure.Id;

			if(this._warningIndexPositions[0] === procedure.procedure.Id){
				procedure.hasWarningPositionsBefore = false;
			}else{
				//If the position of the procedure in the indexPositions array is smaller than the first element of the warningIndexPositions's
				//position in the indexPostions array, it won't have a warning before
				if(this._indexPositions.indexOf(procedure.procedure.Id) < this._indexPositions.indexOf(this._warningIndexPositions[0])){
					procedure.hasWarningPositionsBefore = false;
				}else{
					procedure.hasWarningPositionsBefore = true;
				}
			}

			if(this._warningIndexPositions[(this._warningIndexPositions.length-1)] === procedure.procedure.Id){
				procedure.hasWarningPositionsAfter = false;
			}else{
				//If the position of the procedure in the indexPositions array is larger than the last element of the warningIndexPositions's
				//position in the indexPostions array, it won't have a warning after
				if(this._indexPositions.indexOf(procedure.procedure.Id) > this._indexPositions.indexOf(this._warningIndexPositions[(this._warningIndexPositions.length-1)])){
					procedure.hasWarningPositionsAfter = false;
				}else{
					procedure.hasWarningPositionsAfter = true;
				}
			}
			
			if(this._warningIndexPositions.length === 0){
				procedure.hasWarningPositionsBefore = false;
				procedure.hasWarningPositionsAfter = false;
			}
		}else{
			if(procedure.subprocedures && procedure.subprocedures.length !== 0){
				procedure.subprocedures.forEach(subprocedure => {
					this.setFirstAndLastIndexes(subprocedure);
				});
			}
		}
	}

	get sectionCompleteness() {
		if (this.gapInUse && this.sectionObj) {
			const refs = this.gapInUse.references;
			const procedureList = util.flattenArrayByProperty(this.sectionObj, obj => obj.subprocedures);
			// Count the completed procedures (have at least 1 reference)
			const completedNum = procedureList.reduce((total, proc) => refs.filter(ref => ref.igomAuditableProcedureId === proc.procedure.Id).length > 0 ? total + 1 : total, 0);
			const procedureCount = procedureList.length;
			return [completedNum, procedureCount];
		} else {
			return ['?', '?']
		}
	}

	get sectionCompletenessCompleted() {
		return this.sectionCompleteness[0];
	}
	get sectionCompletenessTotal() {
		return this.sectionCompleteness[1];
	}
	get barProgressStyle() {
		const percent = (this.sectionCompletenessCompleted * 100) / this.sectionCompletenessTotal;
		return 'width: ' + percent + '%;';
	}

	//Methods called by children components
	selectPoint(event) {
		event.stopPropagation();
		const procedureId = event.detail.id;
		this.template.querySelector("c-ig-gap-analysis-igom-section-display").closest('ul').scrollTop = event.detail.scroll-135;
		this.selectProcedure(procedureId);
	}

	// Internal method to select a procedure by id
	selectProcedure(procedureId) {
		if (this._proceduresById[procedureId]) {
			this.itemSelectedObj = this._proceduresById[procedureId];
			this.selectedProcedureId = procedureId;
		} else {
			this.autoselectProcedureId = procedureId;
		}
	}

	changeProcedure(event){
		let evName = event.detail.eventName;
		let procId = event.detail.procedureId;
		let selectItemId = null;
		let procedurePosition = this._indexPositions.indexOf(procId);

		//Select the previous/next procedure's id
		if (evName === 'previousProcedure') {
			selectItemId = this._indexPositions[procedurePosition-1];
		} else if (evName === 'nextProcedure') {
			selectItemId = this._indexPositions[procedurePosition+1];
		} else if (evName === 'previousWarningProcedure') {
			if(procedurePosition !== 0){
				//Try to find the previous id (from the index positions), that is found in the warning positions array
				for(let i = procedurePosition-1; i >= 0; i--){
					let auxId = this._indexPositions[i];
					if(this._warningIndexPositions.includes(auxId) && selectItemId === null){
						selectItemId = auxId;
					}
				}
			}
		} else if(evName === 'nextWarningProcedure'){
			if(procedurePosition !== (this._indexPositions.length-1)){
				//Try to find the next id (from the index positions), that is found in the warning positions array
				for(let i = procedurePosition + 1; i < this._indexPositions.length; i++){
					let auxId = this._indexPositions[i];
					if(this._warningIndexPositions.includes(auxId) && selectItemId === null){
						selectItemId = auxId;
					}
				}
			}
		}
		if(selectItemId !== null ){
			this.selectProcedure(selectItemId);
		}

	}

	get modifiedReferencesToDisplay() {
		if (this.gapInUse) {
			return this.gapInUse.references.filter(reference => 
				!reference.isReviewed && reference.variationStatus === constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION
			);
		}
		return null;
	}

	get isTopNotificationPanelVisible() {
		return this.modifiedReferencesToDisplay && this.modifiedReferencesToDisplay.length > 0;
	}

	goToItem(event) {
		const element = event.target.closest('div');
		const procedureId = element.dataset.id;
		this.dispatchEvent(new CustomEvent('selectsection', {
			detail: {
				procedureId: procedureId
			}
		}));
		this.selectProcedure(procedureId);
	}
	
	setReferencesStatus() {
		if (this._sectionObj && this.gapInUse && this.gapInUse.references) {
			// Get a map with all the statuses per igomAuditableProcedureId
			const refs = this.gapInUse.references;
			const auditableIdToStatuses = refs.reduce((acc, reference) => {
				const statusList = acc[reference.igomAuditableProcedureId] || (acc[reference.igomAuditableProcedureId] = []);
				statusList.push(reference.variationStatus);
				return acc;
			}, {});
			// Recursively set all colors
			this.recursiveSetColors(auditableIdToStatuses, this._sectionObj);
		} else {
			this._sectionObj.referenceStatus = constants.COLORS.GAP.VALUES.BLANK;
		}
	}

	recursiveSetColors(auditableIdToStatuses, procedure) {
		if (procedure.subprocedures) {
			procedure.subprocedures.forEach(subprocedure => this.recursiveSetColors(auditableIdToStatuses, subprocedure));
		} else {
			const statusList = auditableIdToStatuses[procedure.procedure.Id];
			if (statusList) {
				if (statusList.includes(constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION)) {
					procedure.referenceStatus = procedure.procedure.Is_Safety_Critical__c ? constants.COLORS.GAP.VALUES.RED : constants.COLORS.GAP.VALUES.ORANGE;
				} else if (statusList.includes(constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.OUT_OF_SCOPE)) {
					procedure.referenceStatus = constants.COLORS.GAP.VALUES.GRAY;
				} else if (statusList.includes(constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.CONFORMITY)) {
					procedure.referenceStatus = constants.COLORS.GAP.VALUES.GREEN;
				} else {
					procedure.referenceStatus = constants.COLORS.GAP.VALUES.BLANK;
				}
			} else {
				procedure.referenceStatus = constants.COLORS.GAP.VALUES.BLANK;
			}
		}
	}

	get isConfirmAllDisabled(){
		const referencesNonVariant = this.gapInUse.references.filter(reference => 
			!reference.isReviewed && reference.variationStatus !== constants.PROCEDURE_COMPLIANCE.VARIATION_STATUS.VALUES.VARIATION
		);
		return referencesNonVariant.length == 0;
	}
	get confirmAllBtnClass(){
		return this.isConfirmAllDisabled ? 'button btn-ig-secondary m-3 hidden' : 'button btn-ig-secondary m-3';
	}
}
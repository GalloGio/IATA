import { LightningElement, track, wire, api } from 'lwc';

import getPreviousGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getImportableGapAnalysisList';
import getAllDraftGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getEditableGapAnalysisList';
import discardGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.deleteComplianceReview';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';

import { util, resources } from 'c/igUtility';
import { constants, permissions } from 'c/igConstants';
import { label } from 'c/igLabels';

const screens = {
    newFile: 'new-file',
    previousVersion: 'previous-version',
    continueDraft: 'continue-draft'
};

export default class IgGapAnalisisNFile extends LightningElement {
	@track label = label;
    
    // Object with id and name properties
    @api stationName;
    @api stationId;
    
    filenameForNew = '';
    filenameForPrevious = '';
    draftToDeleteName = '';
    draftToDeleteId;
    @track previousGapAnalysis = [];
    @track draftGapAnalysis = [];

    resources = resources;

    @track permissions;

    currentScreen;
    screens = screens;

    @wire(getPreviousGapAnalysis, { stationId: '$stationId' })
    getPreviousGapAnalysisWired({ data, error }) {
        if (data) {
            this.previousGapAnalysis = data.map(el => ({ 
                item: el, selected: false, 
                type: el.status === constants.COMPLIANCE_REVIEW.PUBLISH_STATUS.VALUES.TEMPLATE ? 'Corporate' : 'Previous analysis' 
            }));
        }
    }

    @wire(getAllDraftGapAnalysis, { stationId: '$stationId' })
    getAllDraftGapAnalysisWired({ data, error }) {
        if (data) {
            this.draftGapAnalysis = data.map(el => ({ item: el, selected: false }));
        }
    }

    @wire(getPermissionsApex, { stationId: '$stationId' })
    getPermissionsApexWired({ data, error }) {
        if (data) {
            this.permissions = data;
            if (this.isVisibleGapCreation) {
                this.currentScreen = screens.newFile;
            } else if (this.isVisibleGapEdition) {
                this.currentScreen = screens.continueDraft;
            }
        }
    }

    // Permissions properties
    get isVisibleGapCreation() {
        return this.permissions && this.permissions[permissions.CREATE_GAP];
    }
    get isVisibleGapEdition() {
        return this.permissions && (this.permissions[permissions.EDIT_GAP] || this.permissions[permissions.CREATE_GAP]);
    }
    get isVisibleDraftDiscard() {
        return this.permissions && this.permissions[permissions.CREATE_GAP];
    }
    // Screen change
    get currentNewFile() {
        return this.currentScreen === screens.newFile;
    }
    get currentPreviousVersion() {
        return this.currentScreen === screens.previousVersion;
    };
    get currentContinueDraft() {
        return this.currentScreen === screens.continueDraft;
    };
    changeScreen(event) {
        const activeSect = event.target.closest('div[data-name]');
        if (activeSect) {
            this.currentScreen = activeSect.dataset.name;
        }        
    }
    get newFileClass() {
        return 'col text-center cursor-pt gap-section' + (!this.currentNewFile ? ' disabled-filter-dark' : '');
    }
    get previousVersionClass() {
        return 'col text-center cursor-pt gap-section' + (!this.currentPreviousVersion ? ' disabled-filter-dark' : '');
    }
    get continueDraftClass() {
        return 'col text-center cursor-pt gap-section' + (!this.currentContinueDraft ? ' disabled-filter-dark' : '');
    }
    get newFileUnderlineClass() {
        return 'col-8 offset-2 pt-3 border-bottom-blue' + (!this.currentNewFile ? ' hidden' : '');
    }
    get previousVersionUnderlineClass() {
        return 'col-8 offset-2 pt-3 border-bottom-blue' + (!this.currentPreviousVersion ? ' hidden' : '');
    }
    get continueDraftUnderlineClass() {
        return 'col-8 offset-2 pt-3 border-bottom-blue' + (!this.currentContinueDraft ? ' hidden' : '');
    }

    // SCREEN 1 : New file screen
    newFilenameKeyUp(event) {
        this.filenameForNew = event.target.value;
    }
    get newAnalysisButtonDisabled() {
        return !(this.filenameForNew);
    }
    get newAnalysisButtonClass() {
        return 'button' + (this.newAnalysisButtonDisabled ? ' btn-ig-primary-disabled' : ' btn-ig-primary');
    }

    // SCREEN 2 : Previous gap analysis selection screen
    fromPreviousFilenameKeyUp(event) {
        this.filenameForPrevious = event.target.value;
    }
    selectOldGapAnalysis(event) {
        const clickedId = event.target.closest('tr').dataset.id;    
        const gapAnalysis = this.previousGapAnalysis.find(prevGap => prevGap.item.id === clickedId);
        if (gapAnalysis) {
            this.previousGapAnalysis.forEach(prevGap => prevGap.selected = false);
            gapAnalysis.selected = true;
        }
    }
    get isPreviousGapAnalysisSelected() {
        return this.previousGapAnalysis.some(prevGap => prevGap.selected);
    }
    get prevGapSelectionButtonDisabled() {
        return !(this.isPreviousGapAnalysisSelected && this.filenameForPrevious);
    }
    get prevGapSelectionButtonClass() {
        return 'button' + (this.prevGapSelectionButtonDisabled ? ' btn-ig-primary-disabled' : ' btn-ig-primary');
    }

    // SCREEN 3 : Draft selection screen
    get isDraftSelected() {
        return this.draftGapAnalysis.some(draft => draft.selected);
    }
    get draftSelectionButtonDisabled() {
        return !this.isDraftSelected;
    }
    get draftSelectionButtonClass() {
        return 'button' + (this.draftSelectionButtonDisabled ? ' btn-ig-primary-disabled' : ' btn-ig-primary');
    }
    get draftSelectedName() {
        const gapAnalysis = this.draftGapAnalysis.find(draft => draft.selected);
        return gapAnalysis ? gapAnalysis.item.name : '-';
    }

    get areYouSureDeleteDraftMsg() {
        let msgToReturn = this.label.custom.ig_are_you_sure_delete_msg;
        return msgToReturn.replace('{0}', (this.draftToDeleteName === undefined ? '' : this.draftToDeleteName));
    }

    selectDraft(event) {
        const clickedId = event.target.closest('tr').dataset.id;    
        const gapAnalysis = this.draftGapAnalysis.find(draft => draft.item.id === clickedId);
        if (gapAnalysis) {
            this.draftGapAnalysis.forEach(draft => draft.selected = false);
            gapAnalysis.selected = true;
        }
    }

    // Draft discard
    discardDraft(event) {
        event.stopPropagation();
        const element = event.target.closest('tr');
        this.draftToDeleteId = element.dataset.id;
        this.draftToDeleteName = element.dataset.name;
        this.template.querySelector('c-ig-modal').show();
    }

    async draftDiscardConfirmation() {
        if (this.draftToDeleteId) {
            this.template.querySelector('c-ig-modal').hide();
            try {
                await discardGapAnalysis({ 
                    stationId : this.stationId,
                    gapAnalysisId : this.draftToDeleteId
                 })
            } catch (error) {
                util.debug.error(error);
            }
            this.draftGapAnalysis = this.draftGapAnalysis.filter(gap => gap.item.id !== this.draftToDeleteId);
        }
    }

    goToGapAnalysis(event){
        event.preventDefault();
        const draftGapAnalysis = this.draftGapAnalysis.find(draft => draft.selected);
        const previousGapAnalysis = this.previousGapAnalysis.find(prevGap => prevGap.selected);
        this.dispatchEvent(new CustomEvent('gotogapanalysis', {
            detail: {
                id : previousGapAnalysis ? previousGapAnalysis.item.id : (draftGapAnalysis ? draftGapAnalysis.item.id : null),
                type: this.currentNewFile ? 'new' : (this.currentPreviousVersion ? 'import' : 'load'),
                name : this.currentNewFile ? this.filenameForNew : (this.currentPreviousVersion ? this.filenameForPrevious : draftGapAnalysis.item.name)
            }
        }));
    }

}
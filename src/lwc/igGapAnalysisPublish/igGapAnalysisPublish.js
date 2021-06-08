import { LightningElement, api, track, wire } from 'lwc';
import { constants, resources, util } from 'c/igUtility';
import getFullGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getFullGapAnalysis';
import getGAPNotifiableContacts from '@salesforce/apex/IGOMNotificationUtil.getGAPNotifiableContacts';
import getCurrentIGOM from '@salesforce/apex/IGOMDocumentUtil.getCurrentIGOMFormatted';
import { label } from 'c/igLabels';

// Get station related to the gap analysis
// Get all users related to the station
// Get all accounts related to the account
// Get all station managers related to the accoutn

const notifiableTableColumns = [
    { label: 'Name', fieldName: 'fullname' },
    { label: 'Station', fieldName: 'stationName' },
    { label: 'Role', fieldName: 'origin' }
];

export default class IgGapAnalysisPublish extends LightningElement {
	@track label = label;

    // Exposed properties

    @api gapAnalysisId;

    @api asTemplate;
    
    @api setLoading(loading){
        this.loading = loading;
    }

    // Tracked properties

    @track loading = false;
    @track _chapters;
    @track _notifiableUsers;
    @track _notifiableUsersInform;
    @track _notifiableUsersActReq;

    // Internal properties

    resources = resources;

    selectedChapters = [];
    _effectiveDate;
    _reminderDate;
    _gapInUse;

    // Main logic

	get availableChapters() {
		// Fill available chapters
        let availableChapters = [];
        // Wait for gap data + manual data
		if (this._gapInUse && this._gapInUse.data && this.igomManual && this.igomManual.data) {
            const data = this._gapInUse.data;
            const igomManual = this.igomManual.data;
            // List all the remaining procedure ids for a chapter
            let chapterToRemainingProcedureIds = igomManual.chapters.reduce((acc, chapter) => ({
				...acc, 
				[chapter.procedure.Id]: util.object.flattenRecursivity(chapter, chapter => chapter.subprocedures, chapter => chapter.procedure.Id)
            }), {});
            // Remove the non final procedures (categorizers)
            for (const chapterId of Object.keys(chapterToRemainingProcedureIds)) {
                const chapterProcedures = chapterToRemainingProcedureIds[chapterId];
                for (const procedureId of Object.keys(chapterProcedures)) {
                    if (chapterProcedures[procedureId].subprocedures) {
                        delete chapterProcedures[procedureId];
                    }
                }
                chapterToRemainingProcedureIds[chapterId] = new Set(Object.keys(chapterProcedures));
            }
			// Group every reference by its auditable procedure id
			const refsByProcedureId = util.array.group(data.references, ref => ref.igomAuditableProcedureId).reduce((acc, chapter) => ({...acc, [chapter.id]: chapter.list}), {});
			// Check that for each procedure theres at least 1 reference and they are all marked as reviewed
			for (const procedureId of Object.keys(refsByProcedureId)) {
				if (refsByProcedureId[procedureId].length > 0 && refsByProcedureId[procedureId].every(ref => ref.isReviewed)) {
					const chapterId = refsByProcedureId[procedureId][0].chapterId;
					chapterToRemainingProcedureIds[chapterId].delete(procedureId);
				}
			}
			// List the chapters available for publishing
			for (const chapterId of Object.keys(chapterToRemainingProcedureIds)) {
				const chapter = igomManual.chapters.find(chapter => chapter.procedure.Id === chapterId);
				const isAvailable = chapterToRemainingProcedureIds[chapterId].size === 0 || this.asTemplate;
				availableChapters.push({
					id: chapterId, 
					index: chapter.procedure.Index__c,
                    name: chapter.procedure.Name__c,
                    iconUrl: resources.icons.chapter.replace('{chapterNumber}', chapter.index),
                    isSelected: this.selectedChapters.includes(chapterId),
					isAvailable: isAvailable
				});
			}
		}
		return availableChapters;
    }
    
    @wire(getGAPNotifiableContacts, { gapAnalysisId: '$gapAnalysisId', notificationType: constants.NOTIFICATION.SEVERITY.VALUES.ACTION_REQUIRED })
    getGAPNotifiableContactsActReq({ data, error }) {
        if (data) {
            this._notifiableUsersActReq = {
                data: Object.values(data),
                columns: notifiableTableColumns
            };
        }
	}
    
    @wire(getGAPNotifiableContacts, { gapAnalysisId: '$gapAnalysisId', notificationType: constants.NOTIFICATION.SEVERITY.VALUES.INFORMATIVE })
    getGAPNotifiableContactsInformative({ data, error }) {
        if (data) {
            this._notifiableUsersInform = {
                data: Object.values(data),
                columns: notifiableTableColumns
            };
        }
	}

	get documentList() {
		return this._documentList.data;
    }
    
    @wire(getCurrentIGOM, { language : 'English'})
	igomManual;

	@wire(getFullGapAnalysis, { gapAnalysisId : '$gapAnalysisId' })
    getGapAnalysisWired(response) {
        if (response.data) {
			this._gapInUse = response;
        }
	}

    goToGapAnalysis(event) {
        this.dispatchEvent(new CustomEvent('back'));
    }

    toggleChapterSelection(event) {
        const selectedChapterElement = event.target.closest('.chapter');
        const chapterId = selectedChapterElement.dataset.id;
        const selectedChapter = this.availableChapters.find(chapter => chapter.id === chapterId);
        if (selectedChapter.isAvailable) {
            if (this.selectedChapters.includes(chapterId)) {
                this.selectedChapters = this.selectedChapters.filter(id => id !== chapterId);
            } else {
                this.selectedChapters = this.selectedChapters.concat(chapterId);
            }
        }
    }

    toggleAllChaptersSelection(event) {
        const toggleTo = !this.areAllChaptersSelected;
        if (toggleTo) {
            this.selectedChapters = this.availableChapters.filter(chapter => chapter.isAvailable).map(chapter => chapter.id);
        } else {
            this.selectedChapters = [];
        }
    }

    setEffectiveDate(event) {
        const inputElement = event.target;
        this._effectiveDate = inputElement.valueAsDate;
        if (!this.canUseReminderDate) {
            this._reminderDate = null;
        }
    }

    setReminderDate(event) {
        const inputElement = event.target;
        this._reminderDate = inputElement.valueAsDate;
    }
    
    publishChapters(event) {
        const usersDataTableInfo = this.template.querySelector('[data-name="users-to-notify-informative"]');
        const usersDataTableActReq = this.template.querySelector('[data-name="users-to-notify-action-req"]');
        var selectedInfoUserIds;
        if(usersDataTableInfo){
            selectedInfoUserIds = usersDataTableInfo.getSelectedRows().map(row => row.contactId);
        }
        var selectedActReqUserIds;
        if(usersDataTableActReq){
            selectedActReqUserIds = usersDataTableActReq.getSelectedRows().map(row => row.contactId);
        }
        const selectedUserIds = {'Informative':selectedInfoUserIds, 'Action Required':selectedActReqUserIds};
        this.loading = true;
        this.dispatchEvent(new CustomEvent('publish', { 
            detail: { 
                selectedChapters: this.selectedChapters,
                effectiveDate: this._effectiveDate,
                reminderDate: this._reminderDate,
                notifyUsers: selectedUserIds,
                isFull: this.availableChapters.length === this.selectedChapters.length
            }
        }));
    }

    // Data properties

    get minimumDate() {
        return new Date().toISOString().split("T")[0];
    }
    get maximumDate() {
        const twoYearsLater = new Date();
        twoYearsLater.setFullYear(twoYearsLater.getFullYear() + 2);
        return twoYearsLater.toISOString().split("T")[0];
    }
    get maximumReminderDate() {
        if (this._effectiveDate) {
            const oneDayBeforeEffective = new Date(this._effectiveDate);
            oneDayBeforeEffective.setDate(oneDayBeforeEffective.getDate() - 1);
            return oneDayBeforeEffective.toISOString().split("T")[0];
        }
        return '';
    }

    // Logical properties

    get areAllChaptersSelected() {
        return this.availableChapters.every(chapter => !chapter.isAvailable || chapter.isSelected);
    }
    get isAnyChapterPublishable() {
        return this.availableChapters.some(chapter => chapter.isAvailable);
    }
    get isEffectiveDateValid() {
        return this._effectiveDate && this._effectiveDate >= new Date(this.minimumDate)  && this._effectiveDate <= new Date(this.maximumDate);
    }
    get isReminderDateValid() {
        return !this._reminderDate || (this._reminderDate && this._reminderDate >= new Date(this.minimumDate)  && this._reminderDate < this._effectiveDate);
    }
    get isPublishButtonEnabled() {
        return this.availableChapters.some(chapter => chapter.isSelected) && this.isEffectiveDateValid && this.isReminderDateValid;
    }
    get isPublishButtonDisabled() {
        return !this.isPublishButtonEnabled;
    }
    get canUseReminderDate() {
        return this.isEffectiveDateValid && util.date.dayDifference(new Date(), this._effectiveDate) >= 7;
    }
    get isReminderDateDisabled() {
        return !this.canUseReminderDate;
    }

    // Styling properties

    get publishButtonClass() {
        let classes = ['button'];
        if (this.isPublishButtonEnabled) {
            classes.push('btn-ig-primary');
        } else {
            classes.push('btn-ig-primary-disabled');
        }
        return classes.join(' ');
    }
    get selectAllClass() {
        let classes = ['select-all', 'row mb-1', 'pt-2', 'pb-2', 'cursor-pt'];
        if (this.isSelectAllEnabled) {
            classes.push('disabled-filter');
        }
        return classes.join(' ');
    }

}
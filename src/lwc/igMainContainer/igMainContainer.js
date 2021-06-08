import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from "lightning/platformResourceLoader";
import { label } from 'c/igLabels';
import IG_RESOURCES from '@salesforce/resourceUrl/IG_Resources';
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";

import getCurrentIGOM from '@salesforce/apex/IGOMDocumentUtil.getCurrentIGOMFormatted';
import getCurrentIGOMLanguages from '@salesforce/apex/IGOMDocumentUtil.getCurrentIGOMLanguages';

import createNewGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.createNewGapAnalysis';
import createFromPreviousGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.importGapAnalysis';
import getDraftGapAnalysis from '@salesforce/apex/IGOMComplianceReviewUtil.getFullGapAnalysis';
import publish from  '@salesforce/apex/IGOMComplianceReviewUtil.publishGapAnalysis';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';
import acknowledgeGapNotificationsfrom from '@salesforce/apex/IGOMNotificationUtil.acknowledgeGapNotifications';
import getOwnStations from '@salesforce/apex/IGOMStationUtil.getOwnStations';
import getAllPublishedGapAnalyses from '@salesforce/apex/IGOMComplianceReviewUtil.getAllPublishedGapAnalyses';

import { addObjectLabels } from 'c/igLabels';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DOCUMENT_OBJECT from '@salesforce/schema/Document__c';

import { util, resources } from 'c/igUtility';
import { permissions } from 'c/igConstants';

export default class IgMainContainer extends LightningElement {
    @track label = label;

	resources = resources;

	@track sidebar = true;
	@track defaultSidebar = true;
	@track gapAnalysisMenuExtended = false;
	@track menuItemSelected ='';
	@track message;
	@track selectedGapId;
	@track headerGapAnalyisis = false;
	@track activeStation;
	@track permissions;

	errorDescription = '';
	igomLanguage = null;

	@track showSpinner = false;

	@track stationId;

	@track igomManual;
	@track selectedSectionObj;
	@track selectedChapter;
	@track modifiedProcedures;
	@track _gapAnalysisInUse;
	@track availableStations;
	@track selectedAccountRoleDetailId;

	@track igomLanguages;
	@wire(getCurrentIGOMLanguages)
	getCurrentIGOMLanguagesWired({ data, error }) {
		if (data) {
			let languages = JSON.parse(JSON.stringify(data));
			languages = languages.map(lang => ({ value: lang, label: lang }));
			this.igomLanguages = languages;
		}
	}

	@wire(getOwnStations)
	getOwnStationsWired({ data, error }) {
		if (data) {
			this.availableStations = Object.values(data);
			this.activeStation = this.availableStations[0];
			this.stationId = this.activeStation.id;
		}
	}

	@wire(getPermissionsApex, { stationId: '$stationId' })
    getPermissionsApexWired({ data, error }) {
        if (data) {
            this.permissions = data;
        }
	}

	// Wires to refresh

	@wire(getAllPublishedGapAnalyses, { stationId: '$stationId' })
	wireActualGapAnalyses;
	
	constructor() {
		super();
		const urlParams = util.urlParameters.get();
		if (urlParams.action === 'confirmAll' && urlParams.gapAnalysisId) {
			this.menuItemSelected = 'Message';
			this.message = 'Confirming all the notifications regarding the GAP Analysis...';
			acknowledgeGapNotificationsfrom({ gapAnalysisId: urlParams.gapAnalysisId }).then(() => {
				this.message = 'All notifications for the GAP Analysis have been confirmed';
			}).catch((error) => {
				this.message = 'An error happened while confirming the notifications';
				util.debug.error('Error while confirming notifications', error);
			});
		}
	}

	get gapAnalysisInUse() {
		return this._gapAnalysisInUse;
	}
	set gapAnalysisInUse(value) {
		// Create an empty array for each auditable procedure
		let referencesGroupedByAuditableId = {};
		for (const section of this.igomManual.chapters) {
			const procedureList = util.flattenArrayByProperty(section, obj => obj.subprocedures);
			procedureList.forEach(proc => referencesGroupedByAuditableId[proc.procedure.Id] = []);
		}
		// Push the references to the appropiate arrays
		for (const ref of value.references) {
			const procId = ref.igomAuditableProcedureId;
			if (referencesGroupedByAuditableId[procId] === undefined) {
				console.error('A reference (gapAnalysisItem) is pointing to a non-procedure (section, chapter, subchapter or father of other procedures). The reference can only point to a pure procedure.', ref)
				continue;
			}
			referencesGroupedByAuditableId[procId].push(ref);
		}
		value.references = referencesGroupedByAuditableId;
		this._gapAnalysisInUse = value;
	}

	get showAll() {
		return this.permissions;
	}
	get showDocumentsButton() {
		return this.permissions && this.permissions[permissions.DOCUMENT_GAP];
	}
	get showPublishButton() {
		return this.permissions && this.permissions[permissions.PUBLISH_GAP];
	}

	renderedCallback() {
		if (!this.loadedCss) {
			Promise.all([
				loadStyle(this, IG_RESOURCES + "/css/customIgom.css"),
				loadStyle(this, ICG_RESOURCES + "/css/custom.css"),
				loadStyle(this, ICG_RESOURCES + "/css/main.css"),
			])
			.then(() => {
				this.loadedCss = true;
			});
		}
	}

	changeLanguage(event) {
		const select = event.target;
		this.igomLanguage = select.value;
		this.refreshManual();
	}

	get igomVersion() {
			return this.igomManual ? 'IGOM version ' + this.igomManual.manual.Edition__c : '';
	}

	async refreshManual() {
		// Retrieve the manual in the appropiate language
		let newIgom;
		try {
			newIgom = await getCurrentIGOM({ language: this.igomLanguage });
		} catch (error) {
			util.debug.error('An error happened on refreshManual', error);
			return;
		}
		this.igomManual = JSON.parse(JSON.stringify(newIgom));
		// Search the current section by PermId
		const selectedSectionPermId = this.selectedSectionObj.procedure.External_Reference_ID__c;
		//const allProcedures = [].concat(...this.igomManual.chapters.map(chapter => util.flattenArrayByProperty(chapter, pr => pr.subprocedures)));
		for (const chapter of this.igomManual.chapters) {
			const foundSection = chapter.subprocedures.find(section => section.procedure.External_Reference_ID__c === selectedSectionPermId);
			if (foundSection) {
				this.selectedSectionObj = foundSection;
				this.selectedChapter = chapter.procedure.Name__c;
			}
		}
	}

	async goToGapAnalysis(event) {
		const type = event.detail.type;
		const id = event.detail.id;
		const name = event.detail.name;
		this.showGAPAnalysis = false;
		this.defaultSidebar = false;
		this.menuItemSelected = 'GAP Analysis - Detail';
		this.selectedGapId = undefined;
		let currentIGOM;
		this.showSpinner = true;
		try {
			currentIGOM = await getCurrentIGOM({
				language: this.igomLanguage
			});
		} catch (error) {
			util.debug.error('An error happened retrieving the current IGOM', error);
			this.defaultSidebar = true;
			this.sidebar = true;
			this.headerGapAnalyisis = true;
			this.template.querySelector('.m-container').classList.add('pl-60px');
		}
		if (currentIGOM) {
			this.igomManual = JSON.parse(JSON.stringify(currentIGOM));
			//Set selected IGOM section
			for (const chapter of this.igomManual.chapters) {
				if (chapter.subprocedures.length > 0) {
					this.selectedSectionObj = chapter.subprocedures[0];
					this.selectedChapter = chapter.procedure.Name__c;
					break;
				}
			}
			this.sidebar = true;
			this.headerGapAnalyisis = true;
			this.template.querySelector('.m-container').classList.add('pl-60px');
			this.getGAPAnalysis(id, type, name);
		}
	}

	showGap() {
		this.menuItemSelected = 'GAP Analysis - Detail';
		this.sidebar = true;
		this.defaultSidebar = false;
		this.template.querySelector('.m-container').classList.add('pl-60px');
	}

	async getGAPAnalysis(id, type, name) {
		let data;
		try {
			if (type === 'new') {
				data = await createNewGapAnalysis({
					stationId: this.stationId,
					name : name, 
					igomManual: this.igomManual.manual.Id
				});
			} else if (type === 'import') {
				data = await createFromPreviousGapAnalysis({
					stationId: this.stationId,
					name: name,
					gapAnalysisId: id, 
				});
			} else if (type === 'load') {
				data = await getDraftGapAnalysis({
					gapAnalysisId : id
				});
			}
		} catch (error) {
			util.debug.error('getGAPAnalysis', error);
		}
		this.gapAnalysisInUse = JSON.parse(JSON.stringify(data));
		this.selectedGapId = data.id;
		this.showSpinner = false;
	}

	showFullMenu() {
		this.gapAnalysisMenuExtended = true;
		this.template.querySelector('.m-container').classList.remove('pl-60px');
	}
	
	hideMenu() {
		this.gapAnalysisMenuExtended = false;
		this.template.querySelector('.m-container').classList.add('pl-60px');
	}

	get headerClass() {
		let classList = ['header-igom', 'pl-4'];
		if (this.gapAnalysisMenuExtended) {
			classList.push('col-10', 'offset-sidebar');
		}
		return classList.join(' ');
	}

	get sidebarClass() {
		let classList = ['p-0'];
		if (this.menuItemSelected === 'GAP Analysis - Detail') {
			if (this.gapAnalysisMenuExtended) {
				classList.push('col-2', 'sidebar-gap-absolute', 'width-extended');
			} else {
				classList.push('width-min-content', 'sidebar-gap-absolute');
			}
		} else {
			classList.push('col-2');
		}
		return classList.join(' ');
	}

	selectChapterByProcedureId(procedureId) {
		for (const chapter of this.igomManual.chapters) {
			for (const section of chapter.subprocedures) {
				const procedures = util.object.flattenRecursivity(section, proc => proc.subprocedures, proc => proc.procedure.Id);
				if (section.procedure.Id === procedureId || procedures[procedureId]) {
					this.selectedSectionObj = section;
					this.selectedChapter = chapter.procedure.Name__c;
					return;
				}
			}
        } 
	}

	gotoSectionHandler(event) {
		const procedureId = event.detail.procedureId;
		this.selectChapterByProcedureId(procedureId);
	}

	getSection(event) {
		//Set selected IGOM section
		this.selectedSectionObj = Object.assign(event.detail.section);
		this.selectedChapter = event.detail.chapterName;
		this.template.querySelector('c-ig-sidebar-menu-gap').hideMenu();
	}
	
	goToDocuments(){
		this.menuItemSelected = 'GAP Analysis - Documents';
		this.sidebar = false;
		this.defaultSidebar = false;
		this.template.querySelector('.m-container').classList.remove('pl-60px');
		this.headerGapAnalyisis = true;
	}

	goToPublish(){
		this.menuItemSelected = 'GAP Analysis - Publish';
		this.sidebar = false;
		this.defaultSidebar = false;
		this.template.querySelector('.m-container').classList.remove('pl-60px');
		this.headerGapAnalyisis = true;
	}

	showModalExitGapAnalysis(){
		this.template.querySelector('c-ig-modal.exit-confirmation').show();
	}

	//CONTENT TO DISPLAY
	get showMessageCentered() {
		return this.menuItemSelected === 'Message';
	}
	get showGapAnalysisStart() {
		return this.menuItemSelected === 'GAP Analysis';
	}
	get showDocuments() {
		return this.menuItemSelected === 'GAP Analysis - Documents';
	}
	get showPublish() {
		return this.menuItemSelected === 'GAP Analysis - Publish';
	}
	get showGapAnalysis() {
		return this.menuItemSelected === 'GAP Analysis - Detail';
	}
	get showDashboard() {
		return this.menuItemSelected === 'Dashboard';
	}
	get showNotifications() {
		return this.menuItemSelected === 'Notifications';
	}
	get showIGOMReader() {
		return this.menuItemSelected === 'IGOM Document Description';
	}
	get showVariationReport() {
		return this.menuItemSelected === 'Variation report';
	}
	get showStationAdministration() {
		return this.menuItemSelected === 'Station administration';
	}
	get showLanguageSelector() {
		return this.igomLanguages && this.igomLanguages.length > 1;
	}
	get showStationSelector() {
		return this.menuItemSelected !== 'GAP Analysis - Publish' &&
			   this.menuItemSelected !== 'GAP Analysis - Detail' &&
			   this.menuItemSelected !== 'GAP Analysis - Documents';
	}
	get containerWidth() {
		let containerClass ='m-container col-12';
		if (this.sidebar) {
			if (this.defaultSidebar) {
				containerClass = 'm-container col-10 pl-0';
			} else {
				containerClass = 'm-container col-12';
			}
		}
		return containerClass;
	}
	
	exitGapAnalysis() {
		this.menuItemSelected = 'GAP Analysis - Detail';
		this.template.querySelector('c-ig-modal.exit-confirmation').hide();
		this.defaultSidebar = true;
		this.sidebar = true;
		this.headerGapAnalyisis = false;
		this.template.querySelector('.m-container').classList.remove('pl-60px');
	}

	menuSelection(event) {
		if (event.detail.automatic && this.menuItemSelected === 'Message') {
			return;
		}
		this.menuItemSelected = event.detail.itemName;
	}

	async publishGap(event) {
		// Refresh the last version of the gap
		this.gapAnalysisInUse = JSON.parse(JSON.stringify(await getDraftGapAnalysis({
			gapAnalysisId : this.gapAnalysisInUse.id
		})));
		// Parameters taken from the event
		const selectedChapterIds = event.detail.selectedChapters;
		const effectiveDate = event.detail.effectiveDate;
		const reminderDate = event.detail.reminderDate;
		const notifyUsers = event.detail.notifyUsers;
		let gapInfo;
		try {
			gapInfo = await publish({ 
				gapAnalysisId: this.gapAnalysisInUse.id,
				chapterIds: selectedChapterIds, 
				effectiveDate: effectiveDate,
				notificationReminderDate: reminderDate,
				notifyUsers: notifyUsers,
			});
		} catch (error) {
			util.debug.error(error);
		}
		this.defaultSidebar = true;
		this.sidebar = true;
		this.headerGapAnalyisis = false;
		this.template.querySelector('.m-container').classList.remove('pl-60px');
		// Set component spinner to false
		this.template.querySelector("c-ig-gap-analysis-publish").setLoading(false);
		// Update the related publishing apex elements
		refreshApex(this.wireActualGapAnalyses);
	}

	@wire(getObjectInfo, { objectApiName: DOCUMENT_OBJECT })
	getObjectLabels({ data, error }) {
		if (error) {
			util.debug.error('An error happened on getObjectInfo for DOCUMENT', error);
		}
		if (data) {
			const documentInfo = data;
			addObjectLabels('DOCUMENT', documentInfo.fields);
		}
	}

	stationChange(event) {
		const stationId = event.detail.stationId;
		this.activeStation = this.availableStations.find(station => station.id === stationId);
		this.stationId = this.activeStation.id;
	}

}
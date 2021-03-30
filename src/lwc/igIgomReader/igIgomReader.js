import { track, wire, LightningElement } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from "lightning/platformResourceLoader";

import { util, resources, constants } from 'c/igUtility';
import { permissions } from 'c/igConstants';
import { label } from 'c/igLabels';

import getIGOMProcedures from '@salesforce/apex/IGOMDocumentUtil.getIGOMProcedures';
import getIGOMManuals from '@salesforce/apex/IGOMDocumentUtil.getIGOMManuals';
import getPermissionsApex from '@salesforce/apex/IGOMPermissions.getPermissions';

import IGOM_MANUAL_OBJECT from '@salesforce/schema/Document__c';

export default class IgIGOMDocumentDescription extends LightningElement {
    @track label = label;

    resources = resources;

    renderedCallback() {
        loadStyle(this, resources.styles.igomReader);
    }

    @track igom;

    @track selectedSection;
    @track selectedChapter;

    @track igomManualList;

    @track permissions;

    @wire(getIGOMManuals)
    wireIGOMManuals({ data, error }) {
        if (data) {
            this.igomManualList = JSON.parse(JSON.stringify(data));
            if (data[0]) {
                const selectedId = this.igom ? this.igom.manual.Id : data[0].Id;
                this.igomManualList.forEach(manual => manual.selected = manual.Id === selectedId);
            }
        }
    };

    @wire(getObjectInfo, { objectApiName: IGOM_MANUAL_OBJECT })
    getIgomManualInfo({data, error}) {
        if (data && data.fields) {
            this.label.publishedDate = data.fields.Published_Date__c.label;
            this.label.reviewDate = data.fields.Review_Date__c.label;
        }
    };
    
    constructor() {
        super();
    }

    loadIgom(id) {
        let params = id ? { manualId : id } : {};
        this.igom = null;
        getIGOMProcedures(params).then(igomProcedures => {
            if (!igomProcedures) return;
            if (igomProcedures.chapters[0]) {
                igomProcedures.chapters[0].isSelected = true;
                this.selectedChapter = igomProcedures.chapters[0];
                if (igomProcedures.chapters[0].subprocedures[0]) {
                    igomProcedures.chapters[0].subprocedures[0].isSelected = true;
                    this.selectedSection = igomProcedures.chapters[0].subprocedures[0];
                }
            }
            // Arrange the procedures by Id
            let allProceduresById = {};
            // Pre-process the conditional fields
            let procedures = [...igomProcedures.chapters];
            while(procedures.length > 0) {
                let currentProcedure = procedures.pop();
                currentProcedure.isVersionNull = currentProcedure.procedure.Version_Change_Status__c === 'Null';
                currentProcedure.isVersionNew = currentProcedure.procedure.Version_Change_Status__c === 'New';
                currentProcedure.isVersionModified = currentProcedure.procedure.Version_Change_Status__c === 'Modified';
                currentProcedure.isVersionCancelled = currentProcedure.procedure.Version_Change_Status__c === 'Cancelled';
                currentProcedure.isEmpty = currentProcedure.subprocedures.length === 0;
                allProceduresById[currentProcedure.procedure.Id] = currentProcedure;
                procedures.push(...currentProcedure.subprocedures);
            }
            // Flatten every level over 4 and mark as highlighted the ones containing modifications
            for (let currentProcedure of Object.values(allProceduresById)) {
                // 1. Flatten levels
                if (currentProcedure.procedure.Level__c > 4) {
                    let oldParent = allProceduresById[currentProcedure.procedure.Parent__c];
                    let futureParent = currentProcedure;
                    // Go to the third procedure and add it
                    for (let i = 0; i < (currentProcedure.procedure.Level__c-4+1); i++) {
                        futureParent = allProceduresById[futureParent.procedure.Parent__c];
                    }
                    oldParent.subprocedures.filter(proc => proc !== proc.currentProcedure);
                    futureParent.subprocedures.push(currentProcedure);
                }
                // 2. Cascade highlights upwards
                if (currentProcedure.procedure.Version_Change_Status__c !== 'Null') {
                    let parentProcedure = currentProcedure;
                    while (parentProcedure) {
                        parentProcedure.isHighlighted = true;
                        parentProcedure = allProceduresById[parentProcedure.procedure.Parent__c];
                    }
                }
            }
            this.igom = igomProcedures;
        }).catch(error => {
            util.debug.error(error);
        });
    }

    manualUploaded(ev) {
        let manualId = ev.detail.manualId;
        this.loadIgom(manualId);
    }

    showUploadModal() {
        this.template.querySelector('c-ig-igom-reader-upload-modal').showModal();
    }

    selectManualHandler(ev) {
        let clickedManualId = ev.target.closest('a').dataset.id;
        this.igomManualList.forEach(manual => manual.selected = manual.Id === clickedManualId);
    }

    selectorModalAcceptHandler() {
        let manualId = this.igomManualList.find(manual => manual.selected).Id;
        this.template.querySelector('c-ig-modal.selector-modal').hide();
        this.loadIgom(manualId);
    }

    showManualSelectorModal() {
        this.template.querySelector('c-ig-modal.selector-modal').show();
    }

    chapterChangeHandler(ev) {
        this.selectedChapter.isSelected = false;
        this.selectedChapter = this.igom.chapters.find(chapter => chapter.procedure.Id === ev.detail);
        this.selectedChapter.isSelected = true;
    }

    sectionChangeHandler(ev) {
        this.selectedSection.isSelected = false;
        this.selectedSection = this.selectedChapter.subprocedures.find(section => section.procedure.Id === ev.detail);
        this.selectedSection.isSelected = true;
    }

    @wire(getPermissionsApex)
    getPermissionsApexWired({ data, error }) {
        if (data) {
            this.permissions = data;
            if (this.showLastManual) {
                this.loadIgom();
            }
        }
    }

    get showLastManual() {
        return this.permissions && this.permissions[permissions.VIEW_LAST_MANUAL];
    }
    get showAllManuals() {
        return this.permissions && this.permissions[permissions.VIEW_ALL_MANUALS];
    }
    get allowManualUpload() {
        return this.permissions && this.permissions[permissions.UPLOAD_MANUAL];
    }
}
import { LightningElement, track, api } from 'lwc';
import { resources } from 'c/igUtility';
import { label } from 'c/igLabels';

export default class IgSidebarMenuGap extends LightningElement {
    @track label = label;

    resources = resources;

    @api igomManual;

    _expandedChapter;
    _selectedChapter;
    _selectedProcedure;

    _folded = true;
    @api get folded() {
        return this._folded;
    }
    set folded(value) {
        this._folded = value;
        if (!value) {
            this.dispatchEvent(new CustomEvent('showfullmenu'));
        } else {
            this.dispatchEvent(new CustomEvent('hidemenu'));
        }
    }

    @api hideMenu() {
        this.folded = true;
    }

    get logoClass() {
        return this.folded ? 'col-12 m-auto text-right' : 'col-4 m-auto text-right';
    }
    get topTextClass() {
        return 'title-sidebar gap-item' + (this.folded ? ' hidden' : '');
    }

    toggleFullMenu(event) {
        this.folded = !this.folded;
    }

    sectionClickedHandler(event) {
        const selectedSectionId = event.detail.selectedSectionId;
        let chapterName;
        let returnSection;
        for (const chapter of this.igomManual.chapters) {
            returnSection = chapter.subprocedures.find(section => section.procedure.Id === selectedSectionId);
            if (returnSection) {
                chapterName = chapter.procedure.Name__c;
                this._selectedChapter = chapter.procedure.Id;
                this._selectedProcedure = selectedSectionId;
                break;
            }
        }        
        if (returnSection) {
            this.dispatchEvent(new CustomEvent('selectedsection', { 
                detail: {
                    section : returnSection,
                    chapterName : chapterName
                }
            }));
        }
    }

    get selectedChapter() {
        if (!this._selectedChapter && this.igomManual && this.igomManual.chapters && this.igomManual.chapters[0]) {
            return this.igomManual.chapters[0].procedure.Id;
        }
        return this._selectedChapter;
    }

    get selectedProcedure() {
        if (!this._selectedProcedure && this.igomManual
            && this.igomManual.chapters && this.igomManual.chapters[0]
            && this.igomManual.chapters[0].subprocedures && this.igomManual.chapters[0].subprocedures[0]) {
            return this.igomManual.chapters[0].subprocedures[0].procedure.Id;
        }
        return this._selectedProcedure;
    }

    toggleHandler(event){
        // Chapter is toggled, if the chaper was already expanded, 
        if(this._expandedChapter != event.detail.chapterId){
            this._expandedChapter = event.detail.chapterId;
        }else{
            this._expandedChapter = null;
        }
    }

    get uppercaseGapAnalysisLbl() {
        return this.label.custom.ig_gap_analysis.toUpperCase();
    }
}
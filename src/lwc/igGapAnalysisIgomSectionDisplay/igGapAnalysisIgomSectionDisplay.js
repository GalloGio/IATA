import { LightningElement, api, } from 'lwc';
import { resources } from 'c/igUtility';

export default class IgGapAnalysisIgomSectionDisplay extends LightningElement {
    
    resources = resources;

    @api section;

    @api selectedProcedureId;

    get isCurrentSectionSelected() {
        return this.section.procedure.Id === this.selectedProcedureId;
    }

    get liClass() {
        let liClass;
        if (this.section && this.section.subprocedures) {
            liClass = 'list-group-item-parent cursor-pt';
        } else {
            liClass = 'list-group-item-child cursor-pt';
        }
        if (this.isCurrentSectionSelected) {
            liClass += ' selected-section';
        }
        return liClass;
    }

    get referenceIsNotBlank(){
        return this.section.referenceStatus !== 'Blank';
    }

    
    showChildren(event) {
        event.stopPropagation();

        const ulchild = this.template.querySelector('.list-group-child');
        ulchild.classList.toggle('hidden');

        const iconElem = this.template.querySelector('lightning-icon');
        iconElem.classList.toggle('rotate-up');
    }

    selectPoint(event) {
        event.stopPropagation();
        let element = event.target.closest('li');
        let wantedScroll = element.offsetTop;

        this.dispatchCustomEvent({
            section: this.section,
            id: this.section.procedure.Id,
            name: this.section.procedure.Name__c,
            index: this.section.index,
            scroll: wantedScroll
        });
    }

    dispatchCustomEvent(content) {
        this.dispatchEvent(new CustomEvent('sectionselected', { 
            detail: content
        }));
    }

    sectionSelected(event) {
        this.dispatchCustomEvent(event.detail);
    }
}
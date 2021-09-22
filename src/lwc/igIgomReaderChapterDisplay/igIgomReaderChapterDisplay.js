import { LightningElement, api } from 'lwc';

export default class IgIgomReaderChapterDisplay extends LightningElement {
    @api section;
    toggleSubprocedureVisibility(ev) {
        let procedureListElement = ev.target.closest('.procedure-list');
        let subproceduresElement = procedureListElement.querySelector('.subprocedures');
        if (subproceduresElement) {
            if (subproceduresElement.classList.contains('slds-hide')) {
                subproceduresElement.classList.remove('slds-hide');
                procedureListElement.classList.add('active-procedure-list');
                procedureListElement.querySelector('.open-panel').classList.add('slds-hide');
                procedureListElement.querySelector('.close-panel').classList.remove('slds-hide');
            } else {
                subproceduresElement.classList.add('slds-hide');
                procedureListElement.classList.remove('active-procedure-list');
                procedureListElement.querySelector('.open-panel').classList.remove('slds-hide');
                procedureListElement.querySelector('.close-panel').classList.add('slds-hide');
            }
        }
    }
}
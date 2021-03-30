import { LightningElement, api } from 'lwc';

export default class IgIgomReaderChapterDisplaySubsection extends LightningElement {
    _subsection;
    @api 
    get subsection() {
        return this._subsection;
    };
    set subsection(value) {
        this._subsection = value;
        this.open = this.subsection.isHighlighted;
    }

    open = false;

    get mainDivClass() {
        const baseClass = 'procedure-list shadow-drop slds-p-horizontal_x-large slds-m-bottom_large';
        return baseClass + 
            (this.subsection.isHighlighted ? ' highlight' : '') +
            (this.open ? ' active-procedure-list' : '');
    }
    toggleSubprocedureVisibility(ev) {
        this.open = !this.open;
    }
}
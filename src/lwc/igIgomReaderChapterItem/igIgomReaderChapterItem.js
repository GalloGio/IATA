import { LightningElement, api } from 'lwc';

export default class IgIGOMDocumentDescriptionChapterItem extends LightningElement {
    @api item;
    @api type;
    get className() {
        let className = '';
        if (this.type == 'chapter') {
            className = 'slds-p-around_medium';
        } else if (this.type == 'section') {
            className = 'slds-p-vertical_x-small slds-p-horizontal_x-large';
        }
        if (this.item.isSelected) {
            className += ' selected';
        }
        if (this.item.isHighlighted) {
            className += ' highlight'
        }
        return className;
    }
}
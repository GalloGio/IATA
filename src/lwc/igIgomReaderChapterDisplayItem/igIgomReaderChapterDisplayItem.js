import { LightningElement, api } from 'lwc';

import IG_RESOURCES from '@salesforce/resourceUrl/IG_Resources';

export default class IgIgomReaderChapterDisplayItem extends LightningElement {
    resources = {
        plus_icon: IG_RESOURCES + '/icons/plus-icon.svg#plus',
        warning_icon: IG_RESOURCES + '/icons/warning-icon.svg#warning',
        cancel_icon: IG_RESOURCES + '/icons/cancel-icon.svg#cancel'
    };

    @api versionChange;
    get procedureClass() {
        let className = 'slds-p-left_xx-large slds-p-vertical_small';
        switch(this.versionChange) {
            case 'Null':
                break;
            case 'New':
                className += ' procedure-new';
                break;
            case 'Modified':
                className += ' procedure-modified';
                break;
            case 'Cancelled':
                className += ' procedure-cancelled';
                break;
        }
        return className;
    }
    get isVersionNull() {
        return this.versionChange === 'Null';
    }
    get isVersionNew() {
        return this.versionChange === 'New';
    }
    get isVersionModified() {
        return this.versionChange === 'Modified';
    }
    get isVersionCancelled() {
        return this.versionChange === 'Cancelled';
    }
}
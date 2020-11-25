import { LightningElement, api } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwSpinner extends LightningElement {
    spinner = resources + '/icons/loader-animated.svg';
    @api overlay;
    @api position = 'position-absolute';
    @api width = '50%';
    @api overlayColor = 'rgba(156, 151, 151, 1);';

    get imgstyle(){
        let marginclass = this.position === 'position-relative' ? ' ' : 'margin-spinner-gif ';
        return 'customspinner '+ marginclass + this.position;
    }
    get overlaystyle(){
        return 'spinneroverlay ' + this.position;
    }
    get overlayInlineStyle(){
        let color = this.overlayColor || 'rgba(156, 151, 151, 1);';
        return 'background-color: '+ color;
    }
}
/**
 * Created by bkaya01 on 17/07/2019.
 */

import { LightningElement, track, api } from 'lwc';
import ISSP_Registration_Privacy                   from '@salesforce/label/c.ISSP_Registration_Privacy';
import ISSP_Registration_Legal                   from '@salesforce/label/c.ISSP_Registration_Legal';
import csp_Footer_Privacy_URL                   from '@salesforce/label/c.csp_Footer_Privacy_URL';
import csp_Footer_Legal_URL                   from '@salesforce/label/c.csp_Footer_Legal_URL';

export default class PortalLoginContainer extends LightningElement {

    @api preventrefresh = false;

    _labels = {
        ISSP_Registration_Privacy,
        ISSP_Registration_Legal,
        csp_Footer_Privacy_URL,
        csp_Footer_Legal_URL
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    handleLanguageChange(event){
        this.dispatchEvent(new CustomEvent('changelanguage',{detail : event.detail}));
    }

}
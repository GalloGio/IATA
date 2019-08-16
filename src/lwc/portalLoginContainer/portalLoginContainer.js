/**
 * Created by bkaya01 on 17/07/2019.
 */

import { LightningElement, track, api } from 'lwc';

export default class PortalLoginContainer extends LightningElement {

    @api forcerefresh = false;

    handleLanguageChange(event){
        this.dispatchEvent(new CustomEvent('changelanguage',{detail : event.detail}));
    }

}
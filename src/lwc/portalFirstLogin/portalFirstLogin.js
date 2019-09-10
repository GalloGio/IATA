/**
 * Created by ukaya01 on 10/09/2019.
 */

import { LightningElement, track, wire } from 'lwc';
import CSP_PortalPath         from '@salesforce/label/c.CSP_PortalPath';
import { getRecord }          from 'lightning/uiRecordApi';
import userId                 from '@salesforce/user/Id';

export default class PortalFirstLogin extends LightningElement {

    successIcon = CSP_PortalPath + 'check2xGreen.png';
    @track isLoading = false;
    @track userName = "";

    @wire(getRecord, { recordId: userId, fields: ['User.Name'] })
    WireGetUserRecord(result) {
        console.log('result: ', result);
        if (result.data) {
            let user = JSON.parse(JSON.stringify(result.data));
            let userName = user.fields.Name.value;
            this.userName = userName;
        }
    }

    handleCloseModal(){
        console.log('closefirstloginpopup');
        this.dispatchEvent(new CustomEvent('closefirstloginpopup'));
    }

    handleAccept(){
        console.log('closefirstloginpopup');
        this.dispatchEvent(new CustomEvent('closefirstloginpopup'));
    }

}
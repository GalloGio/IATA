import { LightningElement, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import is2FaOptionalForUser from '@salesforce/apex/MFA_LoginFlowController.is2FaOptionalForUser';
import hasMFAEnabled from '@salesforce/apex/MFA_LoginFlowController.hasMFAEnabled';
import MFAStylesResources from '@salesforce/resourceUrl/MFA_StylesApp';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

/**
 * @description Displays the 2FA options on the settings page
 */
export default class PortalMfaSettings extends LightningElement {
    @api styleResources = 'default';
    @api qrCodeUrl;
    @api translations;
    
    @api userInfo;

    isEditing = false;

    changesTo2FA;
    
	warningIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';

    remove = 'remove';
    change = 'change';
    change2fa = 'change2fa';

	@wire(is2FaOptionalForUser) is2FaOptional;
	@wire(hasMFAEnabled) mfaEnabled;

    /**
     * @description If oppened in a modal screen sets edit mode to false
     */
    @api setUp2FaAuthApp(){
        this.isEditing = false;
    }

    renderedCallback() {
        loadStyle(this, MFAStylesResources);
    }

    /**
     * @description Sets edit mode if it is not on it and the other way round
     */
    setup2FA(){
        if(this.userInfo.isSecurityQuestionActivated){
            this.dispatchEvent(new CustomEvent('initqr'));
        }else{
            this.dispatchEvent(new CustomEvent('setqanda'));
        }
    }

    /**
     * @description Deactivates the 2FA functionallity
     */
    deactivate2FA(){
        this.changesTo2FA = this.remove;
    }

    /**
     * @description Deregister the 2FA set method
     */
    change2FaApp(){
        this.changesTo2FA = this.change;
    }

    /**
     * @description Modal screen confirm button functionallity
     */
    confirmModal(){
        if(this.changesTo2FA === this.remove){
            this.hideModal();
            this.dispatchEvent(new CustomEvent(this.remove));
        }else if(this.changesTo2FA === this.change){
            this.hideModal();
            this.dispatchEvent(new CustomEvent(this.change2fa));
        }
    }

    /**
     * @description If oppened in a modal screen closes the modal
     */
    hideModal(){
        this.changesTo2FA = undefined;
    }

    /**
     * @description Getters for the settings page dinamic labels START
     */
    get isActivatedLbl(){
        if( this.userInfo.isAuhtAppActivated){
            return this.labels.Portal_Security_Question_Activated;
        }else{
            return this.labels.Portal_Security_Question_Not_Activated;
        }
    }   

    /**
     * @description Getters for the settings page dinamic labels END
     */

    /**
     * @description Getters for the settings page dinamic styling START
     */
    get isActivatedClass(){
        if(this.userInfo.isAuhtAppActivated){
            return 'mfa-security-question-activated-lbl slds-m-top_xx-small';
        }else{
            return 'mfa-security-question-not-activated-lbl slds-m-top_xx-small';
        }
    }

    get modalCloseTitle(){
        return 'Close with ' + this.userInfo.isSecurityQuestionActivated;
    }
    /**
     * @description Getters for the settings page dinamic styling END
     */

    /**
     * @description Getters for displaying modal or differnt sections on screen START
     */
    get displaySecurityQandASetup(){
        return this.isEditing && !this.userInfo.isSecurityQuestionActivated;
    }

    get areChangesIn2FA(){
        return this.changesTo2FA !== undefined;
    }

    get isRemoving2FA(){
        return this.changesTo2FA === this.remove;
    }

    get isChanging2FA(){
        return this.changesTo2FA === this.change;
    }

    get labels(){
        return this.translations;
    }

    get isCriticalForUser(){
        return this.userInfo.isAuhtAppActivated && this.is2FaOptional.data;
    }
    get isMfaEnabled(){
        return this.mfaEnabled.data;
    }
    /**
     * @description Getters for displaying modal or differnt sections on screen END
     */
}
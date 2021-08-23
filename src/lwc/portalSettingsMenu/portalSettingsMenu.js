import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import CSP_Change_Password      from '@salesforce/label/c.CSP_Change_Password';
import MFAStylesResources from '@salesforce/resourceUrl/MFA_StylesApp';

/**
* @description Manages the portal setting menu displayed on the csportal
*/
export default class PortalSettingsMenu extends LightningElement {
    @api translations;
    activeSection = 'security-question';

    label = {
        CSP_Change_Password
    }

    renderedCallback() {
        if(this.styleResources === 'default'){
            loadStyle(this, MFAStylesResources);
        }
    }
    
    /**
     * @description Manages the item selected on the page menu and focus the page on the selected section
     */
    selectItem(event){
        var selectedSection = event.currentTarget.id;
        var section;
        if(selectedSection.includes('security-question')){
            section = 'SecurityQuestion';
            this.activeSection = 'security-question';
        }
        else if(selectedSection.includes('two-factor-auth')){
            section = 'TwoFactorAuth';
            this.activeSection = 'two-factor-auth';
        }
        else if(selectedSection.includes('change-pass')){
            section = 'ChangePassword';
            this.activeSection = 'change-pass';
        }
        
        this.dispatchEvent(new CustomEvent('scroll', {
            detail:section
        }));
    }

    /**
     * @description Sets the styling for the security question section
     */
    get secQuestionClass(){
        var classes = 'slds-grid';
        if(this.activeSection == 'security-question'){
            classes += ' mfa-active-menu-item';
        }
        return classes;
    }

    /**
     * @description Sets the styling for the 2fa settings section
     */
    get twoFactAuthClass(){
        var classes = 'slds-grid';
        if(this.activeSection == 'two-factor-auth'){
            classes += ' mfa-active-menu-item';
        }
        return classes;
    }

    /**
     * @description Sets the styling for the change password section
     */
    get changePassClass(){
        var classes = 'slds-grid';
        if(this.activeSection == 'change-pass'){
            classes += ' mfa-active-menu-item';
        }
        return classes;
    }

    get labels(){
        return this.translations;
    }
}
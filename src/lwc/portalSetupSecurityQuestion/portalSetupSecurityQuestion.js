import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import MFAStylesResources from '@salesforce/resourceUrl/MFA_StylesApp';
/**
 * @description Component to save the related security question and answer into the user X2FA_Security_Question__c and X2FA_Security_Questions_Answer__c fields.
*/
export default class PortalSetupSecurityQuestion extends LightningElement {
    @api styleResources = 'default';
    @api translations;
    isEditing = false;
    displaySetupQuestion = false;
    @api userInfo;

    renderedCallback() {
        if(this.styleResources === 'default'){
            loadStyle(this, MFAStylesResources);
        }
    }

    /**
     * @description enables the edit mode on the component
     */
    enableEdit(){
        this.isEditing = true;
    }

    /**
     * @description Sets the question to the screen when the response must be provided
     */
    setQuestionUp(){
        this.displaySetupQuestion = true;
    }

    /**
     * @description When the component is open in a modal widow this method closes the modal
     */
    @api hideModal(){
        this.displaySetupQuestion = false;
        this.isEditing = false;
    }
    
    /**
     * @description Saves the question and aswer set by the user. The event thrown calls the correspondent apex function
     */
    saveQuestionInfo(event){
        var question = event.detail.question;
        var answer = event.detail.answer;
        this.dispatchEvent(new CustomEvent('activatesecurityquestion', {detail:
            {question: question, answer: answer, closeModal: true}
        }));
    }

    /**
     * @description Retrieves the question set for the logged user
     */
    get currentUserQuestion(){
        return this.userInfo.question;
    }

    /**
     * @description Set the correspondent label depending on when is being displayed the screen
     */
    get isActivatedLbl(){
        if(this.labels){
            if(this.userInfo.isSecurityQuestionActivated){
                return this.labels.Portal_Security_Question_Activated;
            }else{
                return this.labels.Portal_Security_Question_Not_Activated;
            }   
        }
    }

    /**
     * @description Set different styles depending on the screen mode (active, inactive)
     */
    get isActivatedClass(){
        if(this.userInfo.isSecurityQuestionActivated){
            return 'mfa-security-question-activated-lbl slds-m-top_xx-small';
        }else{
            return 'mfa-security-question-not-activated-lbl slds-m-top_xx-small';
        }
    }

    /**
     * @description Shows whether the component must appear on a modal screen or not
     */
    get displayModal(){
        return this.displaySetupQuestion || this.isEditing;
    }

    /**
     * @description return the translations to the HTML
     */
    get labels(){
        return this.translations;
    }
}
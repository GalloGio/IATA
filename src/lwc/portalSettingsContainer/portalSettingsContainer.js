import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { labelUtil } from 'c/portalLabels';

import USER_2FA_QUESTION from '@salesforce/schema/User.X2FA_Security_Question__c';
import userId from '@salesforce/user/Id';

import hasSecurityQuestionAndAnswer from '@salesforce/apex/MFA_LoginFlowController.hasSecurityQuestionAndAnswer';
import hasCurrentUserMFAMethod from '@salesforce/apex/MFA_LoginFlowController.hasCurrentUserMFAMethod';
import saveQuestionAnswer from '@salesforce/apex/MFA_LoginFlowController.saveQuestionAnswer';
import initRegisterTotp from '@salesforce/apex/MFA_LoginFlowController.initRegisterTotp';
import verifyRegisterTotp from '@salesforce/apex/MFA_LoginFlowController.verifyRegisterTotp';
import addMFAPermissionSet from '@salesforce/apex/MFA_LoginFlowController.addMFAPermissionSet';
import deleteMFAPermissionSet from '@salesforce/apex/MFA_LoginFlowController.deleteMFAPermissionSet';
import deregisterVerificationTotp from '@salesforce/apex/MFA_LoginFlowController.deregisterVerificationTotp';

import MFAStylesResources from '@salesforce/resourceUrl/MFA_Styles';

import CSP_Breadcrumb_Home_Title from '@salesforce/label/c.CSP_Breadcrumb_Home_Title';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

const elementBySection = {'SecurityQuestion': 'c-portal-setup-security-question',
'TwoFactorAuth': 'c-portal-mfa-settings',
'ChangePassword': 'c-portal-change-password'};

/**
 * @description Stores the settings page elements
 */
export default class PortalSettingsContainer extends LightningElement {

    backgroundImg = MFAStylesResources + '/background/settings_back.png';

    isLoading = true;
    labels;

    label = {
        CSP_Breadcrumb_Home_Title
    };
    /**
     * @description Stops the spinner img
     */
	finishLoad(){
		this.isLoading = false;
	}

    /**
     * @description Starts the spinner img
     */
	startLoad(){
		this.isLoading = true;
	}
    
    isSecurityQA_ActivatedWired;
    isMFA_ActivatedWired;
    userWired;

    secret;
    qrCodeURL;
    @track userInfo = {question:'', isSecurityQuestionActivated: false, isAuhtAppActivated: false };

    /**
     * @description Gets the logged user's security question 
     */
    @wire(getRecord, {recordId: userId, fields: [USER_2FA_QUESTION]})
    wireuser(result) {
        this.userWired = result;
        if (result.data) {
            this.userInfo.question = result.data.fields.X2FA_Security_Question__c.value ? result.data.fields.X2FA_Security_Question__c.value : '';
        }
    }

    /**
     * @description Checks if the logged users has a security question and answer set in an apex method
     */
    @wire (hasSecurityQuestionAndAnswer)
    hasSecurityQuestionAndAnswerWired(result) {
        this.isSecurityQA_ActivatedWired = result;
        if(result.data !== undefined){
            this.userInfo.isSecurityQuestionActivated = result.data;
        }
	}

    /**
     * @description Checks if the logged user has already registered a MFA Method in an apex method
     */
    @wire (hasCurrentUserMFAMethod)
    hasCurrentUserMFAMethodWired(result) {
        this.isMFA_ActivatedWired = result;
        if(result.data !== undefined){
            this.userInfo.isAuhtAppActivated = result.data;
        }
        this.finishLoad();
	}

	/**
	 * @description	Loads the translated labels 
	 */
	connectedCallback(){
		var container = this;
		labelUtil.getTranslations().then((result) => {
			container.labels = result;
		});
        if (this.isSetupAuthApp) {
            this.initAuthApp();
        }
	}

    /**
     * @description Sets the selected element in the top of the screen
     */
    navigateToPosition(event){
        let selectedElement = this.template.querySelector(elementBySection[event.detail]);
        let wantedScroll = selectedElement.offsetTop;
        this.scrollToPos(wantedScroll);
    }

    /**
     * @description Display the 2FA process
     */
    setUp2FA(){
        let url = new URL(window.location.href);
        url.searchParams.set('setup2FA', 1);
        window.location.href = url.toString();
    }

    /**
     * @description Scrolls the window to the beggining of the page
     */
    scrollToPos(wantedScroll){
        window.scrollTo( 0, wantedScroll );
    }

    /**
     * @description Saves the user security question and answer in an apex method and refreshes the screen
     */
    handleSecQuestionActivate(event){
        this.startLoad();
        var question = event.detail.question;
        var answer = event.detail.answer;
        var closeModal = event.detail.closeModal;

        let componentCMP = event.target;
        saveQuestionAnswer({question: question.trim(), answer: answer.trim()}).then(data => {
            if(closeModal){
                componentCMP.hideModal();
            }
            refreshApex(this.userWired);
            refreshApex(this.isSecurityQA_ActivatedWired);

            //Activate MFA authentication app if the process continues
            if(!closeModal){
                this.displayAuthApp();
            }
            this.finishLoad();
        });
    }

    /**
     * @description Displays the set 2FA methods screen
     */
    displayAuthApp(){
        let url = new URL(window.location.href);
        url.searchParams.set('setup2FA', 2);
        window.location.href = url.toString();
    }

    /**
     * @description Sets the QR code for the user to scan and saves the secret for validating the otp code
     */
    initAuthApp(){
        initRegisterTotp().then(result =>{
            if(!result.registered){
                this.secret = result.secret;
                this.qrCodeURL = result.qrCodeUrl;
            }
        });
    }

    /**
     * @description Validates the otp code set by the user, related to the given secret
     */
    validateQrCode(event){
        this.startLoad();
        verifyRegisterTotp({secret: this.secret, otp: event.detail.vcode}).then(res =>{
            if(res.isValid){
                addMFAPermissionSet().then(r => {            
                    let url = new URL(window.location.href);
                    url.searchParams.delete('setup2FA');
                    window.location.href = url.toString();
                });
            }else{
                this.finishLoad();
                this.template.querySelector('c-portal-mfa-activation-container').setError();
            }
        });
    }

    /**
     * @description Deregisters the user 2FA method and the related permission set (ps set when it is voluntary)
     */
    remove2FA(){
        this.startLoad();
        deregisterVerificationTotp().then(data => {
            refreshApex(this.isMFA_ActivatedWired);
            deleteMFAPermissionSet();
            refreshApex(this.userWired);
        });
    }

    /**
     * @description Deregisters the user 2FA method but maintains the related permission set
     */
    change2FaAuthApp(){
        this.startLoad();
        deregisterVerificationTotp().then(data => {
            refreshApex(this.isMFA_ActivatedWired);
            this.initAuthApp();
            refreshApex(this.userWired);
            this.finishLoad();
            let url = new URL(window.location.href);
            url.searchParams.set('setup2FA', 2);
            window.location.href = url.toString();
        });
    }

    /**
     * @description Navigate to homepage
     */
    navigateHome(){
        window.location.href = CSP_PortalPath;
    }

    /**
     * @description True if the 2fa setup should be displayed
     */
    get is2FASetup(){
        return new URL(window.location.href).searchParams.get('setup2FA');
    }

    get isSetupSecQandA(){
        var setup2FAStep = this.is2FASetup;
        return setup2FAStep && setup2FAStep == 1;
    }

    get isSetupAuthApp(){
        var setup2FAStep = this.is2FASetup;
        return setup2FAStep && setup2FAStep == 2;
    }

    get topBackgroundImg(){
        return 'background-image:url(\"' + this.backgroundImg + '\")';
    }
    
	get translations(){
        console.log('Labels ' + JSON.stringify(this.labels));
		return this.labels;
	}
}
import { LightningElement, track } from 'lwc';
import { getParamsFromPage } from'c/navigationUtils';
import closeCase from '@salesforce/apex/PortalCaseClosureController.closeCase';
import ignoreSurveyAction from '@salesforce/apex/PortalCaseClosureController.ignoreSurvey';
import getSurveyLink from '@salesforce/apex/PortalCaseClosureController.answerSurvey';

import CaseClosureSuccessTitle from '@salesforce/label/c.Case_Closure_Success_Title';
import CaseClosureSuccessMessage from '@salesforce/label/c.Case_Closure_Success_Message';
import CaseClosureSuccessMessage48Hours from '@salesforce/label/c.Case_Closure_Success_Message_48Hours';
import CaseClosureSurveyMessage from '@salesforce/label/c.Case_Closure_Survey_Message';
import Yes from '@salesforce/label/c.ISSP_Yes';
import No from '@salesforce/label/c.ISSP_No';
import CaseClosureIgnoreSurveyButton from '@salesforce/label/c.Case_Closure_Ignore_Survey_Button';
import CaseClosureTakeSurveyButton from '@salesforce/label/c.Case_Closure_Take_Survey_Button';
import CaseClosureIgnoreSurvey from '@salesforce/label/c.Case_Closure_Ignore_Survey';
import CaseClosureGoToCustomerPortalButton from '@salesforce/label/c.Case_Closure_Go_To_CS_Portal_Button';
import CaseClosureRedirectSurvey from '@salesforce/label/c.Case_Closure_Redirect_Survey';
import PortalBaseURL from '@salesforce/label/c.CSP_PortalBaseURL';
import PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCaseClosure extends LightningElement {

	result = {
		caseId: null,
		caseNumber: null,
		closed: false
	};

	label = {
		CaseClosureSuccessTitle,
		CaseClosureSuccessMessage,
		CaseClosureSuccessMessage48Hours,
		CaseClosureSurveyMessage,
		Yes,
		No,
		CaseClosureIgnoreSurveyButton,
		CaseClosureTakeSurveyButton,
		CaseClosureIgnoreSurvey,
		CaseClosureGoToCustomerPortalButton,
		CaseClosureRedirectSurvey,
		PortalBaseURL,
		PortalPath
	}

	waitingResponse = true;
	success = false;
	errorMessage = null;
	ignoreSurveyIntention = false;

	get successIcon() { 
		return this.label.PortalPath + 'CSPortal/Images/Icons/successIcon.svg';
	}

	connectedCallback() {
		console.log('test 123');
		var sPageURL = ''+ window.location;
		closeCase({pageUrl: sPageURL}).then(data => {
			this.success = true;
			this.result = data;
		}).catch(error => {
			this.errorMessage = error.body.message;
		}).finally(() => {
			this.waitingResponse = false;
		});
	}

	answerSurvey() {
		this.waitingResponse = true;
		getSurveyLink({caseId: this.result.caseId}).then(data => {
			console.log(data);
			location.href=data;
		}).catch(error => {
			console.log(error);
			this.errorMessage = error.body.message;
			this.success = false;
		}).finally(() => {
			this.waitingResponse = false;
		});
	}

	ignoreSurvey() {
		this.waitingResponse = true;
		this.ignoreSurveyIntention = true;
		ignoreSurveyAction({caseId: this.result.caseId}).then(data => {

		}).catch(error => {
			console.log(error);
			this.errorMessage = 'TEST -> something went wrong!';
			this.success = false;
		}).finally(() => {
			this.waitingResponse = false;
		});
	}

	goToCase() {
		window.location.href = this.label.PortalBaseURL + this.label.PortalPath + 'case-details?caseId=' + this.result.caseId;
	}

	goToPortal() {
		window.location.href = this.label.PortalBaseURL + this.label.PortalPath;
	}

	get spinnerClass() {
		return "spinner-container" +
			(this.waitingResponse ? " slds-show" : " slds-hide");
	}

	get isSuccess() {
		return !this.waitingResponse && this.success;
	}

	get isSuccessUpdated() {
		return this.isSuccess && this.result.closed;
	}

	get isSuccessNotUpdated() {
		return this.isSuccess && !this.result.closed;
	}

	get hasErrors() {
		!this.waitingResponse && !this.success;
	}

	get waitingSurveyLink() {
		return this.waitingResponse && this.success && !this.ignoreSurveyIntention;
	}

	get caseDetailsButtonLabel() {
		return this.result.caseNumber + ' - ' + this.result.caseSubject;
	}

}
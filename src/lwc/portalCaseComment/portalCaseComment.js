import { LightningElement, wire, api } from 'lwc';

import getSurveyLink from '@salesforce/apex/PortalCasesCtrl.getSurveyLink';
import setClosureStatus from '@salesforce/apex/PortalCasesCtrl.updateClosureStatus';

import Case_Comment_Have_Been_Resolved_1 from '@salesforce/label/c.Case_Comment_Have_Been_Resolved_1';
import Case_Comment_Have_Been_Resolved_2 from '@salesforce/label/c.Case_Comment_Have_Been_Resolved_2';
import Case_Comment_How_Can_Assist_You from '@salesforce/label/c.Case_Comment_How_Can_Assist_You';
import Case_Comment_Survey_Lik_Label from '@salesforce/label/c.Case_Comment_Survey_Lik_Label';
import Case_Comment_Survey_Message from '@salesforce/label/c.Case_Comment_Survey_Message';
import Case_Comment_Button_Answer_Not_Clear from '@salesforce/label/c.Case_Comment_Button_Answer_Not_Clear';
import Case_Comment_Button_Can_Close_Case from '@salesforce/label/c.Case_Comment_Button_Can_Close_Case';
import Case_Comment_Button_Have_New_Query from '@salesforce/label/c.Case_Comment_Button_Have_New_Query';
import Case_Comment_Button_Go_To_Contact_Us from '@salesforce/label/c.Case_Comment_Button_Go_To_Contact_Us';
import Case_Comment_New_Query_Confirmation_Message from '@salesforce/label/c.Case_Comment_New_Query_Confirmation_Message';
import Case_Comment_New_Query_Confirmation_Title from '@salesforce/label/c.Case_Comment_New_Query_Confirmation_Title';
import CSP_PortalBaseURL from '@salesforce/label/c.CSP_PortalBaseURL';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import ISSP_No from '@salesforce/label/c.ISSP_No';
import ISSP_Yes from '@salesforce/label/c.ISSP_Yes';

export default class PortalCaseComment extends LightningElement {

	_comment;

	@api get comment() {
		return this._comment;
	};

	set comment(c) {
		c = JSON.parse(JSON.stringify(c));
		if(c !== null && c.messageText !== undefined && c.messageText !== null &&
			c.messageText.indexOf('Auto-Reply:') === 0) {
			this.autoReply = c.messageText;
			c.messageText = null;
			c.isSelf = false;
		}
		this._comment = c;
	}

	@api case;

	autoReply = null;

	label = {
		Case_Comment_Have_Been_Resolved_1,
		Case_Comment_Have_Been_Resolved_2,
		Case_Comment_How_Can_Assist_You,
		Case_Comment_Survey_Lik_Label,
		Case_Comment_Survey_Message,
		Case_Comment_Button_Answer_Not_Clear,
		Case_Comment_Button_Can_Close_Case,
		Case_Comment_Button_Have_New_Query,
		Case_Comment_Button_Go_To_Contact_Us,
		Case_Comment_New_Query_Confirmation_Message,
		Case_Comment_New_Query_Confirmation_Title,
		CSP_PortalBaseURL,
		CSP_PortalPath,
		ISSP_Yes,
		ISSP_No
	}

	surveyLink = '';

	connectedCallback() {
		if(this.isSurvey) {
			let id = this.case.id;
			getSurveyLink({caseId: id})
			.then(data => {
				this.surveyLink = data;
			})
			.catch(error => {
				console.error(error);
			});
		}
	}

	get isAutoReply() {
		return this.autoReply !== null;
	}

	get isHaveBeenResolved() {
		return this.isAutoReply && this.autoReply.indexOf('Have_been_resolved_question') > -1;
	}

	get isNeedMoreHelp() {
		return this.isAutoReply && this.autoReply.indexOf('Need_more_help_question') > -1;
	}

	get isSurvey() {
		return this.isAutoReply && this.autoReply.indexOf('Case_survey_message') > -1;
	}

	get haveBeenResolvedButtonsDisabled() {
		return this.case.Portal_Closure_Status__c !== 'Started' || this.comment.buttonsDisabled;
	}

	get needMoreHelpButtonsDisabled() {
		return this.case.Portal_Closure_Status__c !== 'Ongoing' || this.comment.buttonsDisabled;
	}

	get hideComment() {
		return this.comment.hideComment;
	}

	get haveNotBeenResolvedHighlighted() {
		return this.comment.answer !== undefined && this.comment.answer !== null &&
			this.comment.answer.indexOf('Ongoing') > -1;
	}

	get haveBeenResolvedHighlighted() {
		return this.comment.answer !== undefined && this.comment.answer !== null &&
			this.comment.answer.indexOf('Finished_Resolved') > -1;
	}

	get answerNotClearHighlighted() {
		return this.comment.answer !== undefined && this.comment.answer !== null &&
			this.comment.answer.indexOf('Unresolved') > -1;
	}

	get haveNewQueryHighlighted() {
		return this.comment.answer !== undefined && this.comment.answer !== null &&
			this.comment.answer.indexOf('Finished_New_Case') > -1;
	}

	get canCloseCaseHighlighted() {
		return this.comment.answer !== undefined && this.comment.answer !== null &&
			this.comment.answer.indexOf('Finished_Resolved') > -1;
	}

	ignoreSurvey() {
		//TODO: set Instant_Survey_Feedback_requested__c
	}

	answerSurvey() {
		window.location.href = this.surveyLink;
	}

	@api
	replyComment(response) {
		let result = false;
		if(this.isHaveBeenResolved && !this.haveBeenResolvedButtonsDisabled) {
			if(response === 'Yes') {
				this.closeResolved();
				result = true;
			}
			else if(response === 'No') {
				this.continueClosureProcess();
				result = true;
			}
		}
		return result;
	}
	
	waitForNewComments(status) {
		return status === '' || ['Ongoing', 'Finished_Unresolved', 'Finished_Resolved', 'Finished_New_Case'].indexOf(status) > -1;
	}

	closeResolved() {
		this.updateClosureStatus('Finished_Resolved');
	}

	closeUnresolved() {
		this.updateClosureStatus('Finished_Unresolved');
	}

	closeWithNewQuery() {
		this.updateClosureStatus('Finished_New_Case');
	}

	goToContactUs() {
		let targetURL = this.label.CSP_PortalBaseURL + this.label.CSP_PortalPath + 'support-reach-us';
		window.open(targetURL,'_top');

	}

	continueClosureProcess() {
		this.updateClosureStatus('Ongoing');
	}

	reopenCase() {
		this.updateClosureStatus('Unresolved');
	}

	updateClosureStatus(newStatus) {
		let id = this.case.Id;
		if(this.waitForNewComments(newStatus)) {
			this.dispatchEvent(new CustomEvent("waitingmessages", {}));
		}
		setClosureStatus(
			{
				caseId: id,
				status: newStatus
			}
		).then(result => {
			this.dispatchEvent(
				new CustomEvent(
					"newmessages",
					{
						detail: {
							messages: result
						}
					}
				)
			);
			this.dispatchEvent(
				new CustomEvent(
					"updatedcase",
					{
						detail: {
							closureStatus: newStatus
						},
						bubbles: true,
						composed: true
					}
				)
			);
			if("Finished_New_Case" === newStatus){
				this.template.querySelector('c-iata-modal').openModal();
			}
		}).catch(error => {
			console.error(error);
			this.dispatchEvent(
				new CustomEvent(
					"error",
					{
						detail: {
							error: error.body.message
						}
					}
				)
			);
		})
	}

	get newQueryConfirmationMessage1() {
		return this.label.Case_Comment_New_Query_Confirmation_Message.split('{arg0}')[0];
	}

	get newQueryConfirmationMessage2() {
		return this.label.Case_Comment_New_Query_Confirmation_Message.split('{arg0}')[1];
	}

	get caseLink() {
		return  this.label.CSP_PortalBaseURL + this.label.CSP_PortalPath + 'case-details?caseId=' + this.case.Id;
	}

	get caseNumber() {
		return this.case.CaseNumber;
	}
}
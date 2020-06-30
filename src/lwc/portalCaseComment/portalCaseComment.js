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
import CSP_PortalBaseURL from '@salesforce/label/c.CSP_PortalBaseURL';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCaseComment extends LightningElement {

	@api comment;
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
		CSP_PortalBaseURL,
		CSP_PortalPath
	}

	surveyLink = '';

	connectedCallback() {
		let c = JSON.parse(JSON.stringify(this.comment));
		if(c !== null && c.messageText !== undefined && c.messageText !== null &&
			c.messageText.indexOf('Auto-Reply:') === 0) {
			this.autoReply = this.comment.messageText;
			c.messageText = null;
			c.isSelf = false;
		}
		this.comment = c;

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
		return status === '' || ['Ongoing', 'Finished_Unresolved', 'Finished_Resolved'].indexOf(status) > -1;
	}

	closeResolved() {
		this.updateClosureStatus('Finished_Resolved');
	}

	closeUnresolved() {
		this.updateClosureStatus('Finished_Unresolved');
	}

	closeWithNewQuery() {
		this.updateClosureStatus('Finished_New_Case');
		let targetURL = this.label.CSP_PortalBaseURL + this.label.CSP_PortalPath + 'support-reach-us';
		window.open(targetURL,'_top');
	}

	continueClosureProcess() {
		this.updateClosureStatus('Ongoing');
	}

	reopenCase() {
		this.updateClosureStatus('');
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
}
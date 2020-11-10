import { LightningElement, track,api } from 'lwc';
import getCaseMessages from '@salesforce/apex/PortalCasesCtrl.getCaseMessages';
import submitNewMessage from '@salesforce/apex/DAL_WithoutSharing.submitNewMessage';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import { getParamsFromPage } from'c/navigationUtils';

//custom labels
import CSP_CaseMessage_MessageTitle from '@salesforce/label/c.CSP_CaseMessage_MessageTitle';
import CSP_CaseMessage_HelpText from '@salesforce/label/c.CSP_CaseMessage_HelpText';
import CSP_CaseMessage_InputPlaceholder from '@salesforce/label/c.CSP_CaseMessage_InputPlaceholder';

export default class PortalHomeCalendar extends LightningElement {

    // Expose the labels to use in the template.
    label = {
        CSP_CaseMessage_MessageTitle,
        CSP_CaseMessage_HelpText,
        CSP_CaseMessage_InputPlaceholder
	};
	
    @track loading = true;
    @track lstMessages;

    @track newMessage = '';
    @track showSendMessageButton = false;
    @track messageInputLoading = false;
	@track loadingCom = false;
	@track loadingNewMessages = false;
	@api caseDetails;
	@api isCollection;

    @track trackedIsExpired;
	@track showCaseMessagingSection = true;

    conversationImageURL = CSP_PortalPath + 'CSPortal/Images/Icons/messageBallons.svg';
	replyProcessed = false;

    @api
    get expired() {
        return this.trackedIsExpired;
    }
    set expired(value) {
        this.trackedIsExpired = value;
    }

    connectedCallback() {
        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if(this.pageParams.caseId !== undefined && this.pageParams.caseId !== ''){
            //get this case messages
			this.getCaseMessagesJS();
        }else{
            //disable the component because there is no case ID
            this.loading = false;
            this.messageInputLoading = true;
		}

	}

	renderedCallback() {
		if(this.isToReply && !this.replyProcessed) {
			let caseComments = this.template.querySelectorAll('c-portal-case-comment');
			if(caseComments !== null && caseComments.length > 0) {
				let replyResult = caseComments[caseComments.length - 1].replyComment(this.pageParams.replyComment);
				if(replyResult) {
					this.replyProcessed = true;
					window.scrollTo(
						{
							left: 0,
							top: caseComments[caseComments.length - 1].offsetTop,
							behaviour: 'smooth'
						}
					);
				}
			}
		}
	}

    getCaseMessagesJS(){
        getCaseMessages({ caseId : this.pageParams.caseId })
        .then(results => {
			this.lstMessages = this.processMessages(results);
            this.loading = false;
			this.messageInputLoading = false;
        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
            this.messageInputLoading = false;
		});
	}
	
	processMessages(messages) {
		if(messages === undefined || messages === null) {
			return [];
		}
		let autoreplyMessages = [];
		let disabled = true;
		for(let i = messages.length-1; i >= 0; i--) {
			
			if(i > 0 && messages[i-1] !== undefined && messages[i-1] !== null && messages[i].messageText.indexOf('User-Answer:') === 0) {
				messages[i-1].answer = messages[i].messageText;
				messages[i].hideComment = true;
			}

			if(!messages[i].messageText.indexOf('Auto-Reply:') === 0 && !result[i].isSelf) {
				continue;
			}
			else if(messages[i].messageText.indexOf('Auto-Reply:') === 0) {
				if(disabled) {
					messages[i].buttonsDisabled = false;
					disabled = false;
				}
				if(autoreplyMessages.indexOf(messages[i].messageText) > -1) {
					messages[i].hideComment = true;
				}
				else {
					autoreplyMessages.push(messages[i].messageText);
				}
			}
		}
		console.log(messages);
		return messages;
	}

	get isToReply() {
		return this.pageParams.replyComment !== undefined && this.pageParams.replyComment !== null && this.pageParams.replyComment !== '';
	}

    get hasMessages(){
        return this.lstMessages !== undefined && this.lstMessages.length > 0;
    }

    get sendNewMessage(){
        return this.newMessage !== '';
    }

    handleInputChange(event){
        this.newMessage = event.target.value;
        this.showSendMessageButton = event.target.value !== undefined && event.target.value !== '';
    }

    handleKeyUp(event) {
        this.handleInputChange(event);
        event.target.style.height  = '5px';
        event.target.style.height = event.target.scrollHeight+'px';
    }

    sendNewMessageJS(){
        if(this.newMessage.length > 0){
            this.messageInputLoading = true;
			this.loadingCom = true;
            this.showSendMessageButton = false;
            submitNewMessage({ caseId : this.pageParams.caseId, messageTextAux : this.newMessage})
                .then(results => {
                    if(results.success === true){

                        //show success toast
                        const toastEvent = new ShowToastEvent({
                            title: "SUCCESS",
                            message: results.returnMessage,
                            variant: "success",
                        });
                        this.dispatchEvent(toastEvent);

                        this.newMessage = '';
						this.showSendMessageButton = false;
						this.loadingCom = false;                                        
                        this.getCaseMessagesJS();
						this.template.querySelector('textarea').style.height  = '5px';
                        this.template.querySelector('textarea').value = '';
                    }
                })
                .catch(error => {
                    console.log('error: ' , error);
                    this.messageInputLoading = false;
                }
            );
        }
    }

    toggleCaseMessagingSection(){
        if(this.showCaseMessagingSection){
            this.showCaseMessagingSection = false;
        }else{
            this.showCaseMessagingSection = true;
        }
        
        this.toggleCollapsed('[data-msgdiv]', 'collapsed');
        this.toggleCollapsed('[data-msgicon ]', 'arrowExpanded');
        
    }
	
	toggleCollapsed(elem, cssclass) {
		this.template.querySelector(elem).classList.toggle(cssclass);
	}

	handleWaitingNewMessages(event) {
		this.loadingNewMessages = true;
	}
	
	handleNewMessages(event) {
		let messages = JSON.parse(JSON.stringify(this.lstMessages));
		messages.push(...event.detail.messages);
		this.lstMessages = this.processMessages(messages);
		this.loadingNewMessages = false;
	}

	handleUpdatedCase(event) {
		if(event.detail.closureStatus === '') {
			const toastEvent = new ShowToastEvent({
				title: "SUCCESS",
				message: "Case reopened",
				variant: "success",
			});
			this.dispatchEvent(toastEvent);

		}
	}

	handleNewMessagesError(event) {
		this.loadingNewMessages = false;
	}

}
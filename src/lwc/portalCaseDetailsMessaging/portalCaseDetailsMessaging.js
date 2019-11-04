import { LightningElement, track } from 'lwc';
import getCaseMessages from '@salesforce/apex/PortalCasesCtrl.getCaseMessages';
import submitNewMessage from '@salesforce/apex/PortalCasesCtrl.submitNewMessage';

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
    @track caseDetails;
    @track lstMessages;

    @track newMessage = '';
    @track showSendMessageButton = false;
    @track messageInputLoading = false;

    @track showCaseMessagingSection = false;
    @track messagingHeight = 'display:none';

    conversationImageURL = CSP_PortalPath + 'CSPortal/Images/Icons/messageBallons.svg';

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

    getCaseMessagesJS(){
        getCaseMessages({ caseId : this.pageParams.caseId })
        .then(results => {
            this.lstMessages = results;
            this.loading = false;
            this.messageInputLoading = false;
        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
            this.messageInputLoading = false;
        }
    );
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
                        this.template.querySelector('textarea').style.height  = '5px';
                        this.template.querySelector('textarea').value = '';
                        this.showSendMessageButton = false;
                        this.getCaseMessagesJS();
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
	

}

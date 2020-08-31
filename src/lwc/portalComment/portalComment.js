import { LightningElement, api } from 'lwc';

export default class PortalComment extends LightningElement {

	@api comment;
	@api hideInfo = false;

	get commentContainerClass() {
		return 'slds-m-bottom_small '
			+ (this.comment.isSelf ? 'caseMessagesSelfBubbleContainer' : 'caseMessagesOtherBubbleContainer');
	}

	get commentAreaClass() {
		return 'slds-p-around_medium '
			+ (this.comment.isSelf ? 'caseMessagesSelfBubble ' : 'caseMessagesOtherBubble ');
	}

	get infoAreaClass() {
		return 'slds-m-horizontal_x-small '
			+ (this.comment.isSelf ? 'slds-float_right caseMessagesMyselfTimestamp ' : 'slds-float_left caseMessagesOtherTimestamp ');
	}

	get hasCommentBodyAttribute() {
		return this.comment.messageText !== undefined && this.comment.messageText !== null && this.comment.messageText !== '';
	}

}
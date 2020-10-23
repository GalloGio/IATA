import { LightningElement, track, wire } from 'lwc';
import { getTidsInfo } from 'c/tidsUserInfo';

import { fireEvent, registerListener } from 'c/tidsPubSub';
import { CurrentPageReference } from 'lightning/navigation';

export default class TidsVettingMenu extends LightningElement {
	@wire(CurrentPageReference) pageRef;

	@track errors = false;
	@track documents = false;

	@track vettingMode = false;

	connectedCallback(){
		// Section error listener
		registerListener('sectionErrorListener',this.handleSectionError,this);
		registerListener('sectionApproveListener',this.handleSectionApprove,this);
		let tidsInfo = getTidsInfo();
		this.vettingMode = tidsInfo.userType === 'vetting' ? true : false;
	}

	handleDocuments() {
		this.documents = !this.documents;
		let action = {
				type: 'TOGGLE_CLASS',
				payload: {
					show: true
				}
			};
		fireEvent(this.pageRef, 'documentsListener',action);
	}

	handleOnErrors() {
		console.log('vetting errors');
		this.errors = !this.errors;
		fireEvent(this.pageRef, 'vettingMenuListener',this.errors);
	}

	handleSectionError(props) {
		this.errors = props;
	}

	handleSectionApprove(props) {
		console.log(props);
	}

}
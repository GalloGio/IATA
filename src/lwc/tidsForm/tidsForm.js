import { LightningElement, wire, track } from 'lwc';
//Publish, Subscribe toggle welcome page
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, fireEvent } from 'c/tidsPubSub';

export default class TidsForm extends LightningElement {
	@wire(CurrentPageReference) pageRef;

	@track displayWelcome;
	@track displayForm;

	connectedCallback() {
		registerListener('formListener', this.handleFormListener, this);
		this.reset();
	}

	handleFormListener(props) {
		this.reset();
		switch(props.section) {
			case 'welcome':
				this.displayWelcome = true;
				break;
			case 'form':
				this.displayForm = true;
				break;
			default: break;
		}
	}

	reset() {
		this.displayForm = false;
		this.displayWelcome = false;
	}

	handleWelcomePage() {
		this.displayWelcome = false;
	}
}
import { LightningElement, track, api, wire } from 'lwc';
import { fireEvent } from 'c/tidsPubSub';
import { CurrentPageReference } from 'lightning/navigation';


export default class TidsModal extends LightningElement {
	@api open = false;
	@api fieldErrorSelected;
	@api defaultMessage = false;
	@api privateMessage = false;
	@api action;

	@track GLOBAL_MESSAGE = 'Delete all';
	@track message;
	@track isCanceable=false;

	@wire(CurrentPageReference) pageRef;

	connectedCallback() {
		if (this.privateMessage){
			this.FIELD_MESSAGE =this.fieldErrorSelected.description;
			if (this.action === 'REQUEST'){
				this.isCanceable=true;
			}
		}else if(this.fieldErrorSelected){
			this.FIELD_MESSAGE = 'You are going to delete '+ this.fieldErrorSelected.fieldLabel +' error description?';
		}
	}

	handleModalProceed(event) {
		event.preventDefault();
		console.log('this.action',this.action);
		let updateObject = JSON.parse(JSON.stringify(this.fieldErrorSelected))
		if(this.action === 'FIELD') {
			updateObject.show = false;
			updateObject.description = '';
			fireEvent(this.pageRef,'modalProceedListener',updateObject);
		} else if(this.action === 'GEONAME') {
			this.open = false;
			fireEvent(this.pageRef,'disableCityGeonameId',null);
		} else if(this.action === 'MGEONAME') {
			this.open = false;
			fireEvent(this.pageRef,'disableMCityGeonameId',null);  
		} else {
			fireEvent(this.pageRef,'modalDeleteAllErrorsListener','ALL');
		}
	}

	handleModalClose(event) {
		event.preventDefault();
		this.open = false;
		fireEvent(this.pageRef,'modalCloseListener',this.open);
	}
}
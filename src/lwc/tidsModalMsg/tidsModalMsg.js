import { LightningElement, track, api, wire } from 'lwc';
import { fireEvent } from 'c/tidsPubSub';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";

export default class TidsModal extends NavigationMixin(LightningElement) {
	@track proceed='OK';
	@track iscancel=false;
	@api open = false;
	@api fieldErrorSelected;
	@api message = '';
	@api msgpayload;
	@api action;
	@wire(CurrentPageReference) pageRef;

	connectedCallback(){
		if (this.action === 'OKTIDS'){
			this.proceed='OK';
			this.iscancel=false;
		}else if (this.action === 'RELINQUISH'){
			this.iscancel=true;
			this.proceed='Confirm';
		}else if (this.action === 'REINSTATE'){
			this.iscancel=true;
			this.proceed='Confirm';
		}else if (this.action === 'REMOVEADMINISTRATOR'){
			this.iscancel=true;
			this.proceed='Confirm';
		}else if (this.action === 'SWAPADMINISTRATOR'){
			this.iscancel=true;
			this.proceed='Confirm';
		}
	}
	handleModalCancel(event){
		if (this.action === 'REMOVEADMINISTRATOR'){
			this.open = false;
			fireEvent(this.pageRef,'cancelAdministrator', {type:'cancelADMINISTRATOR',payload:null});
		}else if (this.action === 'SWAPADMINISTRATOR'){
			this.open = false;
			fireEvent(this.pageRef,'cancelAdministrator', {type:'cancelADMINISTRATOR',payload:null});
		}else {
			this.open = false;
			fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
		}
	}
	redirectTidsApplication(){
		// event.preventDefault();
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {
				pageName: 'tids'
			},
		});
	}

	handleModalProceed(event){
		event.preventDefault();
		if(this.action === 'OK'){
			this.open = false;
		}else if(this.action === 'OKTIDS'){
			this.open = false;
			this.redirectTidsApplication();
		}else if(this.action === 'OK_CANCEL'){
			this.open = false;
			fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
		}else if(this.action === 'RELINQUISH'){ 
			this.open = false;
			fireEvent(this.pageRef,'relinquishNow', {type:'RELINQUISH',payload:this.msgpayload});
		}else if(this.action === 'REINSTATE'){ 
			this.open = false;
			fireEvent(this.pageRef,'reinstateNow', {type:'REINSTATE',payload:this.msgpayload});  
		}else if(this.action === 'SELECT_CANCEL'){
			this.open = false;
			fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
		}else if(this.action === 'REMOVEADMINISTRATOR'){
			this.open = false;
			fireEvent(this.pageRef,'removeAdministrator', {type:'REMOVEADMINISTRATOR',payload:null});
		 }else if(this.action === 'SWAPADMINISTRATOR'){
			this.open = false;
			fireEvent(this.pageRef,'swapAdministrator', {type:'SWAPADMINISTRATOR',payload:null});
		 }else{
			//fireEvent(this.pageRef,'modalDeleteAllErrorsListener','ALL');
		}
	}
}
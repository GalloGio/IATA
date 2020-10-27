import { LightningElement, api, track, wire } from 'lwc';
import { 
	getLocationType,
	getUserType, 
	getCase,
	getApplicationType,
	CHG_NAME_COMPANY,
	NEW_VIRTUAL_BRANCH,
	NEW_BRANCH 
} from "c/tidsUserInfo";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import applicationSubmitted from "@salesforce/apex/TIDS_Controller.applicationSubmitted";
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import { setSectionsDone,getTidsInfo} from "c/tidsUserInfo";


export default class TidsSubmitApplication extends NavigationMixin(LightningElement) {
	@wire(CurrentPageReference) pageRef;

	@api tidsUserInfo;
	@track vettingMode;
	@track rejectButtonShow = false;
	@track tidsCase;
	@track portalUrl = '/csportal/s/';
	@track spinner = false;
	//Modal Window
	@track modalAction;
	@track showConfimationModal=false;
	@track modalDefaultMessage='';
	@track tidsInfo;

	connectedCallback() {
		this.tidsInfo = JSON.parse(JSON.stringify(getTidsInfo()));
		let userType = getUserType();
		this.tidsCase = getCase();
		this.vettingMode = userType === 'vetting' ? true : false;
		this.setFormText();
	}

	@track istext1=false
	@track istext2=false;
	@track istext3=false;
	@track istext4=false;
	setFormText() {
		let type = getLocationType();
		let apptype=getApplicationType();
		this.istext1=true;
		this.istext2=false;
		this.istext3=false;
	
		if (apptype=== NEW_BRANCH) {
			this.istext1=false;
			this.istext2=true;
			this.istext3=false;					
		}
		
		if (apptype === NEW_VIRTUAL_BRANCH) {
			this.istext1=false;
			this.istext2=false;
			this.istext3=true;
		}		
	
		if (apptype=== CHG_NAME_COMPANY){
		  	if (type==='HO') {
				this.istext1=false;
				this.istext2=false;
				this.istext3=false;
				this.istext4=true;
			}
		}
	}
	handleSendApplication(event) {
		event.preventDefault();
		this.spinner = true;
		this.showConfimationModal=false;
		console.log('applicationData', JSON.stringify(this.tidsInfo));
		let appType = this.tidsInfo.applicationType;
		let appSections='';
		if (appType === 'chg-business-profile-specialization'){appSections = JSON.stringify(this.tidsInfo);}
		console.log('appSections', appSections);
		console.log('appType', appType);
		applicationSubmitted({caseId: this.tidsCase.Id, applicationData:appSections, applicationType:appType})
		.then(result => {
			this.spinner = false;
			console.log('handleSendApplication result',JSON.stringify(result));
			if (result.hasAnError){
				console.log('handleSendApplication error',result.reason);
				this.modalDefaultMessage='Oops! something happened, please retry.'
				this.modalAction='OK';
				this.showConfimationModal=true;
			}else{
					console.log('setSectionsDone4');
					setSectionsDone([]);
					console.log('setSectionsDone4');
					this.dispatchEvent(
						new ShowToastEvent({
								title: 'Thank you',
								message: 'Your request has been submitted to IATA for review.',
								variant: 'success'
						})
					);
					//this.spinner = false;
					//let action = {type: 'Submitted'};
					//fireEvent(this.pageRef, "applicationDecisionListener", action);
					console.log('setSectionsDone4');
					this[NavigationMixin.Navigate]({
						type: 'standard__namedPage',
						attributes: {
								pageName: 'tids'
						},
					});
			}
		 })
		.catch(error => {
			console.log('error',JSON.stringify(error));
			this.oops(error);
		});
	}
	oops(error){
		this.spinner = false;
		console.log('submit application error',error);
		this.modalDefaultMessage='Oops! something happened, please retry.'
		this.modalAction='OK';
		this.showConfimationModal=true;
	}
}
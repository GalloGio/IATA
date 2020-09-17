import { LightningElement, api, track, wire } from "lwc";
import tidsAssetsPath from "@salesforce/resourceUrl/tidsAssets";
//Labels
import tidsTitle from "@salesforce/label/c.tids_title";
import tidsWhatYouCanDo from "@salesforce/label/c.tids_what_you_can_do";
import tidsApologizeMessage from "@salesforce/label/c.tids_apologize_message";
import tidsOpenCaseTitle from "@salesforce/label/c.tids_accessibility_open_case_title";
import tidsOpenCaseDescription from "@salesforce/label/c.tids_accessibility_open_case_description_message";
import tidsVisitLinkTitle from "@salesforce/label/c.tids_visit_link_title";
import tidsVisitLinkDescription from "@salesforce/label/c.tids_visit_link_description";

// Salesforce backend logic
import actionApplication from "@salesforce/apex/TIDSHelper.actionApplication";
import discardApplication from "@salesforce/apex/TIDSHelper.discardApplication";
import getcountryISOCode from "@salesforce/apex/TIDSHelper.getcountryISOCode";

// User Info
import { getCase, resetUserInfo } from "c/tidsUserInfo";

// Publish pattern
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
import { NavigationMixin } from "lightning/navigation";

export default class TidsConditions extends NavigationMixin(LightningElement) {
	@wire(CurrentPageReference) pageRef;

	homeEligibilityVisitLink =
		tidsAssetsPath + "/images/home/home-eligibility-visit-link.png";
	homeEligibilityOpenCase =
		tidsAssetsPath + "/images/home/home-eligibility-open-case.png";

	@track portalUrl = "/csportal/s/tids";

	label = {
		tidsTitle,
		tidsWhatYouCanDo,
		tidsApologizeMessage,
		tidsOpenCaseTitle,
		tidsOpenCaseDescription,
		tidsVisitLinkTitle,
		tidsVisitLinkDescription
	};

	@api message;
	showResumeButton;

	@track tidsCase;
	@track spinner = false;
	@track apologizeMessage = false;

	// Confirmation modal
	@track showConfimationModal = false;

	//Modal Window
	@track modalAction;
	@track showConfimationMsgModal=false;
	@track modalDefaultMessage='';
	connectedCallback() {
		registerListener("showErrorMessage", this.showErrorMessageCallback, this);
		if (this.message) {
			this.message = JSON.parse(JSON.stringify(this.message));
			if (this.message.apologizeMessage === undefined) {
				this.apologizeMessage = true;
			} else {
				this.apologizeMessage = this.message.apologizeMessage;
			}
		}
		this.tidsCase = getCase();
	}

	// Callbacks
	showErrorMessageCallback(props) {
		console.log(JSON.stringify(props));
	}

	handleResume(event) {
		event.preventDefault();
		this.spinner = true;
		this.showConfimationMsgModal=false;
		console.log('this.tidsCase.Id',this.tidsCase.Id);
		actionApplication({ caseId: this.tidsCase.Id, action:'resume' })
		.then((result) => {
			console.log('this.tidsCase.Id:result_resume',result);
			if (result==='error'){
					this.spinner = false;
					this.modalDefaultMessage='Your application is being reviewed by IATA and can no longer be edited.';
					this.modalAction='OKTIDS';
					this.showConfimationMsgModal=true;
			}else{
					this.tidsCase=undefined;
					fireEvent(this.pageRef, "resumeApplication");
			}
		})
		.catch((error) => {
			console.log('error',error);
			this.oops(error);
		});
	}

	handleRecall(event) {
		event.preventDefault();
		this.spinner = true;
		this.showConfimationMsgModal=false;
		console.log('this.tidsCase.Id',this.tidsCase.Id);
		actionApplication({ caseId: this.tidsCase.Id, action:'recall' })
		.then((result) => {
				console.log('this.tidsCase.Id:result_recall',result);
				if (result==='error'){
					this.spinner = false;
					this.modalDefaultMessage='Your application is being reviewed by IATA and can no longer be edited.';
					this.modalAction='OKTIDS';
					this.showConfimationMsgModal=true;
		 }else{
					this.redirectTidsApplication();
		 }        
		})
		.catch((error) => {
			console.log('error',error);
			this.oops(error);
		});
	}
	oops(error){
		this.spinner = false;
		console.log(' fetchRoles error',error);
		this.modalDefaultMessage='Oops! something happened, please retry.';
		this.modalAction='OK';
		this.showConfimationMsgModal=true;
	}

	handleDiscard(event) {
		event.preventDefault();
		this.spinner = true;
		this.showConfimationModal=false;
		this.showConfimationMsgModal=false;
		console.log('this.tidsCase.Id',this.tidsCase.Id);
		actionApplication({ caseId: this.tidsCase.Id, action:'discard' })
		.then((result) => {
			 console.log('this.tidsCase.Id:result_discard',result);
			 this.spinner = false;
			 if (result==='error'){
					this.modalDefaultMessage='Your application is being reviewed by IATA and can no longer be edited.';
					this.modalAction='OKTIDS';
					this.showConfimationMsgModal=true;
				}else{
					this.showConfimationModal = true;
				}   
		})
		.catch((error) => {
			console.log('error',error);
			this.oops(error);
		});    
	}

	discardBusinessLogic() {
		this.spinner = true;
		discardApplication({ caseId: this.tidsCase.Id }).then((result) => {
			this.spinner = false;
			resetUserInfo();
			this.redirectTids();
		});
	}

	handleTidsCase(event) {
		event.preventDefault(); 
		this.spinner = true; 
		this.showConfimationModal=false;
		this.showConfimationMsgModal=false;   
		getcountryISOCode()
		.then((result) => {
			 console.log('handleTidsCase',result);
			 if (result!=null){
					this[NavigationMixin.Navigate](
						{
							type: "standard__webPage",
							attributes: {
								url: this.portalUrl+'/../support-reach-us-create-new-case?category=Travel&topic=Accreditation_Travel_Agent&subtopic=TIDS&countryISO='+result+'&concerncase=false&emergency=false'
							}
						},
						true
					);   
			 }
			 this.spinner = false;       
		})
		.catch((error) => {
			console.log('error',error);
			this.oops(error);
		});    
		
	}

	redirectTids() {
		this.tidsCase=undefined;
		this[NavigationMixin.Navigate](
			{
				type: "standard__webPage",
				attributes: {
					url: this.portalUrl
				}
			},
			true
		);
	}

	redirectTidsApplication(event){
		// event.preventDefault();
		this.tidsCase=undefined;
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {
					pageName: 'tids'
			},
		});
	}
	// Confirmation modal
	handleModalCancel(event) {
		event.preventDefault();
		this.showConfimationModal = false;
	}

	handleModalConfirm(event) {
		event.preventDefault();
		this.discardBusinessLogic();
	}

	handleCloseTab(event) {
		event.preventDefault();
		window.top.close();
		window.open('','_parent','');
		window.close();
	}

}
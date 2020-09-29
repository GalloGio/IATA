import { LightningElement, track, wire } from 'lwc';
import { getTidsInfo, getUserType, getCase, SECTION_CONFIRMED, SECTION_ERROR_REPORTED, APPLICATION_REJECTED, APPLICATION_APPROVED, APPLICATION_ERRORS, NOT_STARTED } from "c/tidsUserInfo";
import updateCaseStatus from "@salesforce/apex/TIDS_Controller.updateCaseStatus";
import contactApplicant from "@salesforce/apex/TIDSHelper.contactApplicant";

import { registerListener, fireEvent } from 'c/tidsPubSub';
import { CurrentPageReference } from 'lightning/navigation';
export default class TidsApplicationDecision extends LightningElement {
	@wire(CurrentPageReference) pageRef;
	@track sections = [];
	@track errorsApplication = false;
	@track approveApplication = false;
	@track approveApplicationButtonDisplay = false;
	@track contactApplicationButtonDisplay = false;
	@track notStartedApplication = false;
	@track disabledButton = false;
	@track tidsInfo;
	@track tidsCase;

	// Modal application rejection
	@track step = 'step1';
	@track rejectDialogOpen = false;
	@track step1 = false;
	@track step2 = false;
	@track rejectionReason = null;
	@track loading = false;
	@track showErrorModal=false;
	@track showErrorMsg="Unkown technical difficulty.";
	
	applicationType="";
	userType="";
	
	connectedCallback() {
		// Modal rection confirm
		registerListener("modalRejectionListener", this.modalRejectionListener, this);
		this.rejectDialogOpen = false;
		let userType = getUserType();
		this.vettingMode = userType === 'vetting' ? true : false;
		this.tidsInfo = JSON.parse(JSON.stringify(getTidsInfo()));
		this.errorMapping(this.tidsInfo);
		this.tidsCase = getCase();
	}
	
	errorMapping(props) {
		this.sections = [];
		this.resetDecisionValues();
		// eslint-disable-next-line guard-for-in
		for(let index in props.sections){
			if(props.sections[index].sectionDecision === SECTION_ERROR_REPORTED) {
				console.log('error sections:', JSON.stringify(props.sections[index]));
				this.errorsApplication = true;
				this.sections.push({sectionName: props.sections[index].sectionName, errors: props.sections[index].errors});
			} else if(props.sections[index].sectionDecision === SECTION_CONFIRMED) {
				console.log('approve sections:', JSON.stringify(props.sections[index]));
				this.approveApplication = true;
			} else if(props.sections[index].sectionDecision === NOT_STARTED) {
				console.log('not started sections:', JSON.stringify(props.sections[index]));
				this.approveApplication = false;
				this.notStartedApplication = true;
			}
		}
		if(this.errorsApplication) {
			this.contactApplicationButtonDisplay = true;
			this.approveApplicationButtonDisplay = false;
			this.disabledButton = false;
			this.disabledButton = this.notStartedApplication
			console.log('errorMapping:this.notStartedApplication',this.notStartedApplication);
			console.log('errorMapping:this.errorsApplication',this.errorsApplication);
			console.log('errorMapping:this.disabledButton',this.disabledButton);
		} else {
			this.contactApplicationButtonDisplay = false;
			this.approveApplicationButtonDisplay = true;
			this.disabledButton = false;
			this.disabledButton =  (this.errorsApplication || this.notStartedApplication);
			console.log('errorMapping:this.notStartedApplication',this.notStartedApplication);
			console.log('errorMapping:this.errorsApplication',this.errorsApplication);
			console.log('errorMapping:disabledButton',this.disabledButton);
		}
	}
	handleCloseModal(event){
		this.showErrorModal=false;
	}
	handleApproveApplication(event) {
		event.preventDefault();
		let applicationDecisionResult = this.setApplicationDecision({decision: APPLICATION_APPROVED});
		//let comment = 'Last TIDS Application has been Approved and this case is now Closed';
		this.update('Approved', applicationDecisionResult,null);
	}

	handleContactApplication(event) {
		event.preventDefault();
		let applicationDecisionResult = this.setApplicationDecision({decision: APPLICATION_ERRORS});
		// this.update('Review in progress',applicationDecisionResult,null);
		//contactApplicant(String caseId,String caseStatus, String applicationsettings)
		this.loading = true;
		let args={
			caseId: this.tidsCase.Id,
			caseStatus: 'Pending customer',
			applicationsettings: applicationDecisionResult
		};
		console.log('handleContactApplication:arguments:'+JSON.stringify(args));
		contactApplicant(args)
		.then(result => {
			this.loading = false;
			if (result!==null && result.hasAnError){
				this.showErrorModal=true;
				this.showErrorMsg=result.reason;
				//enable modal window to retry
				console.log(JSON.stringify(result));
			}else{
				let action = {type: 'Pending customer',caseId: this.tidsCase.Id};
				fireEvent(this.pageRef, "applicationDecisionListener", action);
			}
		})
		.catch(error => {
			this.loading = false;
			this.showErrorModal=true;
			//enable modal window to retry
			console.log(JSON.stringify(error));
		});
	}

	handleRejectApplication(event) {
		event.preventDefault();
		this.rejectDialogOpen = true;
		this.step1 = true;
	}

	update(status,values,comment) {
		this.loading = true;
		let args= {
			applicationDecision: status, 
			userType:this.userType,
			applicationType:this.applicationType,
			caseId: this.tidsCase.Id, 
			applicationsettings: values, 
			reason: comment
		};
		console.log('update:values:',values);
		console.log('update:arguments:',JSON.stringify(args));
		updateCaseStatus(args).then(result => {
			this.loading = false;
			if (result!==null && result.hasAnError){
				this.showErrorModal=true;
				this.showErrorMsg=result.reason;
				 //enable modal window to retry
				 console.log(JSON.stringify(result));
			}else{
				let action = {type: status}
				fireEvent(this.pageRef, "applicationDecisionListener", action);
			}
		}).catch(error => {
			this.loading = false;
			this.showErrorModal=true;
			//enable modal window to retry
			console.log(JSON.stringify(error));
		});
	}

	setApplicationDecision(props) {
		this.userType = this.tidsInfo.userType;
		this.applicationType = this.tidsInfo.applicationType;
		let applicationDecisionResult = JSON.stringify(this.tidsInfo);
		let result = applicationDecisionResult.replace('{','{"applicationDecision":"' + props.decision +'",');
		return result;
	}

	resetDecisionValues() {
		this.errorsApplication = false;
		this.approveApplication = false;
		this.notStartedApplication = false;
		this.disabledButton = true;
	}

	// Modal Confirm Rejection
	handleStep(event) {
		const stepIndex = event.detail.index;
		this.resetSteps();
		if(stepIndex === 0) {
			this.step = 'step1';
			this.step1 = true;
		} else if(stepIndex === 1) {
			this.fieldValidation();
		}
	}

	handleOnClickRejection(event) {
		event.preventDefault();
		this.step = event.target.value;
		this.resetSteps();
		if(this.step === 'step1') {
			this.step1 = true;
		} else {
			this.step2 = true;
		}
	}

	handleNext(event) {
		event.preventDefault();
		this.resetSteps();
		this.fieldValidation();
	}

	fieldValidation() {
		let input = this.template.querySelector("[data-name='reject-description']");
		if(input.validity.valid) {
			this.step = 'step2';
			this.step2 = true;
		} else {
			this.step = 'step1';
			this.step1 = true;
			input.reportValidity();
		}
	}

	handleConfirmRejection(event) {
		event.preventDefault();
		let applicationDecisionResult = this.setApplicationDecision({decision: APPLICATION_REJECTED});
		this.update('Closed', applicationDecisionResult,this.rejectionReason);
		this.rejectDialogOpen = false;
	}

	handleClose(event) {
		event.preventDefault();
		this.rejectDialogOpen = false;
		this.step = 'step1';
		this.resetSteps();
	}

	resetSteps() {
		this.step1 = false;
		this.step2 = false;
	}

	handleRejectionReason(event) {
		this.rejectionReason = event.target.value;
	}
}
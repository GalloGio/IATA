import { LightningElement, track, api, wire } from 'lwc';
// Pubsub libraries
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/tidsPubSub";
import { getReportChangesOption, getAccountSelected, setCase, updateTidsUserInfo, isAccountHeadOffice } from 'c/tidsUserInfo';
import accountHasChangeReportCase from '@salesforce/apex/TIDSReportChanges.accountHasChangeReportCase';

export default class TidsReportChanges extends LightningElement { 
	@track cmpName = 'ReportChanges';
	
	@wire(CurrentPageReference) pageRef;

	@track changeTypeOptions = [];
	@track changeTypeSelected = null;
	@track changeTypeSelectedLabel = null;
	@track displayMessage = false;
	@api branchSelected
	@api accountInfo;
	@track spinner = false;
	@track change1=false;
	@track change2=false;
	@track change3=false;

	@track tidsAccount;
	@track caseInProgress = false;
	@track disabledProceedButton = false;

	connectedCallback() {
		this.disabledProceedButton = true;
		this.changeTypeOptions = this.getChangeTypeOptions();
		this.tidsAccount = getAccountSelected();
	}

	handleChangeType(event) {
		event.preventDefault();
		this.changeTypeSelected = event.target.value;
		let change = this.changeTypeOptions.find(element => element.value === this.changeTypeSelected);
		this.changeTypeSelectedLabel = change.label;
		this.changeReportCasesOpen(this.changeTypeSelectedLabel);
		this.change1=false;
		this.change2=false;
		this.change3=false;
		if (this.changeTypeSelected==="chg-name-company"){
			 this.change1=true;
		}else if (this.changeTypeSelected==="chg-address-contact"){
			this.change2=true;
		}else if (this.changeTypeSelected==="chg-business-profile-specialization"){
			this.change3=true;
		}
	}

	changeReportCasesOpen(change) {
		this.spinner = true;
		//fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
		updateTidsUserInfo(this.tidsAccount);
		accountHasChangeReportCase({
			accountId: this.tidsAccount.Id,
			changeReport: change
		})
		.then(result => {
			this.spinner = false;
			this.displayMessage = true;
			this.caseInProgress = result;
			this.disabledProceedButton = result;
			//fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		})
		.catch(error => {
			console.log(error);
			//fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		});
	}
	handleProceed(event) {
		event.preventDefault();
		let action = {
			type: 'REPORT_CHANGES',
			payload: {
				locationtype:this.accountInfo.Location_Type__c,
				accountInfo:this.accountInfo,
				changeType:this.changeTypeSelected,
				caseId: ''
			}
		}
		setCase(null);
		fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		fireEvent(this.pageRef,'reportChangesListener', action);
	}

	getChangeTypeOptions() {
		let options = getReportChangesOption();
		return options;
	}
	handleCancel(event){
		// Prevents the anchor element from navigating to a URL.
		event.preventDefault();
		//when selecting a branch the top must become the branch 
		fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
	}
}
import { LightningElement, track, api, wire } from 'lwc';
// TIDS User Info
import { 
	getUserInfo,
	setCase,
	setApplicationType,
	setUserType,
	NEW_BRANCH,
	NEW_VIRTUAL_BRANCH
} from 'c/tidsUserInfo';
// Pubsub libraries
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/tidsPubSub";
// Salesforce Apex Methods
import createTidsCaseNewBranch from '@salesforce/apex/TIDSHelper.createTidsCaseNewBranch';
import createTidsCaseVirtualBranch from '@salesforce/apex/TIDSHelper.createTidsCaseVirtualBranch';
import getFilteredCountries from '@salesforce/apex/TIDSHelper.getCountry';
export default class TidsAddBranch extends LightningElement {
	@api accountInfo;
	@api branchSelected=false;
	@api showVirtualBranch;

	@wire(CurrentPageReference) pageRef;
	@track proceedDisabled = true;
	@track cmpName = 'AddBranch';
	@track countries = [];
	@track country;
	@track countryRules = {
		visible: true,
		disabled: false,
		required: true
	};
	//Modal Window
	@track modalAction;
	@track showConfimationModal=false;
	@track modalDefaultMessage='';
	connectedCallback() {
		getFilteredCountries()
		.then(result => {
			this.countries = result;
		})
		.catch(error => {
			console.log(error);
		});
		//this.showVirtualBranch = true;
	}
		

	changeField(event) {
		if (event.target.name === "country") {      
			this.country = event.target.value;
			this.proceedDisabled = false;
		}
	}
	handleProceed(event) {
		event.preventDefault();
		fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
		let userInfo = getUserInfo();
		if(this.showVirtualBranch) {
			let countrySelectedVirtualBranch = this.countries.find(item => item.value === this.country);
			let payload = {
				userType: "client",
				applicationType: NEW_VIRTUAL_BRANCH,
				virtualCountryOfOperations: countrySelectedVirtualBranch
			}
			let accountId = userInfo.tidsAccount.Id;
			createTidsCaseVirtualBranch({
				accountId: accountId,
				payload: JSON.stringify(payload)
			})
			.then(result => {
				// Set Case Id
				setCase({Id: result});
				// Set User Type
				setUserType(false);
				// Set Application Type
				setApplicationType(NEW_VIRTUAL_BRANCH);
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				fireEvent(this.pageRef,'newBranchListener', payload);
			})
			.catch(error => {
				this.oops(error);
			})
		} else {
			let payload = {
				userType: "client",
				applicationType: NEW_BRANCH
			}
			let accountId = userInfo.tidsAccount.Id;
			createTidsCaseNewBranch({
				accountId: accountId,
				payload: JSON.stringify(payload)
			})
			.then(result => {
				// Set Case Id
				setCase({Id: result});
				// Set User Type
				setUserType(false);
				// Set Application Type
				setApplicationType(NEW_BRANCH);
				fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
				fireEvent(this.pageRef,'newBranchListener', payload);
			})
			.catch(error => {
				this.oops(error);
			})
		}
	}
	oops(error){
		fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		console.log(' fetchRoles error',error);
		this.modalDefaultMessage='Oops! something happened, please retry.'
		this.modalAction='OK';
		this.showConfimationModal=true;
	}
	handleCancel(event){
		// Prevents the anchor element from navigating to a URL.
		event.preventDefault();
		//when selecting a branch the top must become the branch 
		fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:null});
	}
}
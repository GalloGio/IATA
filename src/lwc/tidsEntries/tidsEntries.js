import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, fireEvent } from 'c/tidsPubSub';
import { 
	getUserInfo, 
	updateInfo, 
	getTidsInfo, 
	setCase, 
	getCase,
	getApplicationType, 
	isAccountHeadOffice,
	getUserType, 
	setSfTidsInfo,
	NEW_BRANCH,
	NEW_VIRTUAL_BRANCH,
	CHG_NAME_COMPANY,
	CHG_ADDRESS_CONTACT,
	CHG_BUSINESS_PROFILE_SPECIALIZATION
} from 'c/tidsUserInfo';
import saveSettings from '@salesforce/apex/TIDSHelper.saveSettings';
import { NavigationMixin } from 'lightning/navigation';
// Report Changes
import getNameCompanyDetails from '@salesforce/apex/TIDSReportChanges.getNameCompanyDetails';
import getAddressContactDetails from '@salesforce/apex/TIDSReportChanges.getAddressContactDetails';
export default class TidsEntries extends NavigationMixin(LightningElement) {
	@track tidsUserInfo;

	@track spinner;

	@wire(CurrentPageReference) pageRef;

	@track visibleNewApplicant = false;
	@track visibleAgency = false;
	@track visibleShareholder = false;
	@track visibleAddress = false;
	@track visibleMailing = false;
	@track visibleContact = false;
	@track visibleBusinessProfile = false;
	@track visibleBusinessSpecialization = false;
	@track visibleSupportingDocuments = false;
	@track visibleSubmitApplication = false;
	@track isLoadingFinished=false;
	
	@track portalUrl = '/csportal/s/';
	@track isHeadOffice = false;
	@track userType = getUserType();
	//Modal Window
	@track modalAction;
	@track showConfimationModal=false;
	@track modalDefaultMessage='';

	connectedCallback() {
		this.isLoadingFinished=false;
		this.isHeadOffice = isAccountHeadOffice();
		this.spinner = false;
		this.tidsUserInfo = getUserInfo();
		registerListener('menuOptionSelected', this.handleMenuSelected, this);
		registerListener('tidsUserInfoUpdate',this.tidsUserInfoUpdate,this);
		
		let apptype = getApplicationType();
		//decision what is the screen to display first
		if(apptype === NEW_BRANCH || apptype === NEW_VIRTUAL_BRANCH) {
			this.startMenu('agency-legal-status');
		} else if(apptype === CHG_NAME_COMPANY) {
			this.changeNameCompany();
		} else if(apptype === CHG_ADDRESS_CONTACT) {
			this.changeAddressContact();
		} else if(apptype === CHG_BUSINESS_PROFILE_SPECIALIZATION) {
			this.startMenu('business-profile');
		} else {
			this.startMenu();
		}
		
	}

	activateSubmitPage(){
		if (!(this.visibleSupportingDocuments
			|| this.visibleBusinessSpecialization
			|| this.visibleBusinessProfile
			|| this.visibleAgency
			|| this.visibleShareholder
			|| this.visibleAddress
			|| this.visibleMailing
			|| this.visibleContact
			|| this.visibleNewApplicant)){
			this.startMenu('application-decision');
		}
	}

	//Callback
	changeNameCompany() {
		if(this.userType === 'vetting') {
			this.getSFAccountInfo();
		} else {
			this.initialCmp();
		} 
	}

	changeAddressContact() {
		let reportchange='address';
		if (this.tidsUserInfo.tidsAccount.Location_Type==='VB'){
			reportchange='mailing';
		}    
		if(this.userType === 'vetting') {
			getAddressContactDetails({
				accountId: this.tidsUserInfo.tidsAccount.Id
			})
			.then(result => {
				this.addressContactDetailsCallback(result,reportchange);
				this.activateSubmitPage();
				this.isLoadingFinished=true;
			})
			.catch(error => {
				this.oops(error);
				console.log('error',JSON.stringify(error));
				this.isLoadingFinished=true;
			});
		} else {
			this.startMenu(reportchange);
		}
	}
	
	//no Callback
	addressContactDetailsCallback(result,reportchange) {
		setSfTidsInfo(JSON.parse(JSON.stringify(result)));
		this.startMenu(reportchange);
	}
	
	//Callback
	getSFAccountInfo() {
		getNameCompanyDetails({accountId: this.tidsUserInfo.tidsAccount.Id, isLabel:false})
		.then(result => {
			this.changeNameCompanyHOCallback(result);
			this.activateSubmitPage();
			this.isLoadingFinished=true;
		})
		.catch(error => {
			this.oops(error);
			console.log('error',JSON.stringify(error));
			this.isLoadingFinished=true;
		});
	}

	changeNameCompanyHOCallback(result) {
		setSfTidsInfo(JSON.parse(JSON.stringify(result)));
		this.initialCmp();
	}
	//no Callback
	initialCmp() {
		if(this.isHeadOffice) {
			this.startMenu('welcome');
		} else if(!this.isHeadOffice) {
			this.startMenu('agency-legal-status');
		}
	}
	//no Callback
	handleMenuSelected(optionSelected) {
		this.startMenu(optionSelected);
	}
	//no Callback
	startMenu(optionSelected) {
		this.reset();
		switch(optionSelected) {
			case 'agency-legal-status':
				this.visibleAgency = true;
				break;
			case 'shareholder-details':
				this.visibleShareholder = true;
				break;
			case 'address':
				this.visibleAddress = true;
				break;
			case 'mailing':
				this.visibleMailing = true;
				break;
			case 'contact':
				this.visibleContact = true;
				break;
			case 'business-profile':
				this.visibleBusinessProfile = true;
				break;
			case 'business-specialization':
				this.visibleBusinessSpecialization = true;
				break;
			case 'supporting-documents':
				this.visibleSupportingDocuments = true;
				break;
			case 'submit-application':
				this.visibleSubmitApplication = true;
				break;
			case 'application-decision':
				this.visibleSubmitApplication = true;
				break;
			case 'new-applicant':
				this.visibleNewApplicant = true;
				break;
			case 'save-quit':
				this.saveQuitBusinessLogic();
				break;
			default:
				this.visibleNewApplicant = true;
				break;
		}
		this.isLoadingFinished=true;
		window.scrollTo(0,0);
	}

	saveQuitBusinessLogic() {
		let action = {type: 'SaveAndQuit'}
		fireEvent(this.pageRef, "applicationDecisionListener", action);
	}

	redirectHome() {
		this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
					url: this.portalUrl
			}
			},
			true 
		);
	}
	
	reset() {
		this.visibleNewApplicant = false;
		this.visibleAgency = false;
		this.visibleShareholder = false;
		this.visibleAddress = false;
		this.visibleMailing = false;
		this.visibleContact = false;
		this.visibleBusinessProfile = false;
		this.visibleBusinessSpecialization = false;
		this.visibleSupportingDocuments = false;
		this.visibleSubmitApplication = false;
	}

	tidsUserInfoUpdate(props) {
		this.spinner = true;
		this.save(props);
	}

	displayMenu(props) {
		this.startMenu(props.target);
		fireEvent(this.pageRef, 'buttonClicked', props);
	}

	save(props) {
		let accountId = null;
		updateInfo(props);
		let caseId = null;
		let applicationsettings = getTidsInfo();
		this.spinner = true;
		if(getCase() !== null && getCase().Id !== undefined) {
			caseId = getCase().Id;
		} else {
			accountId = this.tidsUserInfo.tidsAccount.Id;
		}
		saveSettings({
			accountId: accountId,
			applicationsettings: JSON.stringify(applicationsettings),
			applicationtype: applicationsettings.applicationType,
			caseId: caseId
		})
		.then(result => {
			this.spinner = false;
			if (result.hasAnError){
				this.oops(result.reason);
			}else{
				setCase({Id: result.caseId});
				this.displayMenu(props);
			}
		})
		.catch(error => {
			this.spinner = false;
			this.oops(error);
		});
	}
	oops(error){
		console.log('error',JSON.stringify(error));
		this.modalDefaultMessage='Oops! something happened, please retry.'
		this.modalAction='OK';
		this.showConfimationModal=true;
	}
}
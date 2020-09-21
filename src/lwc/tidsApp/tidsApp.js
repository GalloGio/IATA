import { LightningElement, wire, track, api } from "lwc";
// Import static resources
import tidsAssetsPath from "@salesforce/resourceUrl/tidsAssets";
import FontAwesome5 from "@salesforce/resourceUrl/fontawesome5";
// import TidsDashboardAssets from "@salesforce/resourceUrl/tidsDashboardAssets";
//Get the current User Id
import Id from "@salesforce/user/Id";
// Load external styles
import { loadStyle } from "lightning/platformResourceLoader";
//Call Apex method
import getPrincipalActivities from "@salesforce/apex/TIDSUtil.mainActivity";
import getPrincipalDestination from "@salesforce/apex/TIDSUtil.principalDestination";
import getSalesVolume from "@salesforce/apex/TIDSUtil.salesVolume";
import getMainMarketSpecialization from "@salesforce/apex/TIDSUtil.mainMarketSpecialization";
import getGDSValues from "@salesforce/apex/TIDSUtil.getGDSValues";
import getNumberOfEmployees from "@salesforce/apex/TIDSUtil.getNumberOfEmployees";
import getPreferedLanguages from "@salesforce/apex/TIDSUtil.getPreferedLanguages";
import getFocusValues from "@salesforce/apex/TIDSUtil.getFocusValues";
import getPickListValuesCompanyTypes from "@salesforce/apex/TIDSUtil.companyTypes";
//Helper
import getUserInfo1 from "@salesforce/apex/TIDSHelper.getUserInfo";
import getCountries from "@salesforce/apex/TIDSHelper.getCountry";
import getMailingCountries from "@salesforce/apex/TIDSHelper.getMailingCountries";
import getTidsCase from "@salesforce/apex/TIDSHelper.getTidsCase";
import getVettingDoneCondition from "@salesforce/apex/TIDSHelper.getVettingDoneCondition";              
// Dashboard Report Changes
import getNameCompanyDetails from "@salesforce/apex/TIDSReportChanges.getNameCompanyDetails";
import getAddressContactDetails from "@salesforce/apex/TIDSReportChanges.getAddressContactDetails";
import getBusinessProfileSpecialization from "@salesforce/apex/TIDSReportChanges.getBusinessProfileSpecialization";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";

import {
	initializeTidsInfo,
	setUserInfo,
	setUserInfoIata,
	updateSections,
	setLocationType,
	setBusinessrules,
	setUserType,
	setSectionsDone,
	setCase,
	getHeadOfficeInfo,
	setMainActivities,
	setPrincipalDestinations,
	setSalesVolume,
	setMainMarketSpecialization,
	setGDSValues,
	setNumberOfEmployees,
	setFocusValues,
	setCountries,
	setMailingCountries,
	setMailing,
	setAgencyLegalStatus,
	setAddress,
	setBusinessProfile,
	setShareholderDetails,
	setPreferedLanguages,
	setApplicationType,
	getApplicationType,
	setWelcome,
	setConfiguration,
	setContact,
	createMenu,
	setBusinessSpecialization,
	getAccountSelected,
	setIsAccountHeadOffice,
	setCompanyTypes,
	NEW_BRANCH
} from "c/tidsUserInfo";

// import FontAwesome5 from '@salesforce/resourceUrl/fontawesome5';

export default class TidsApp extends LightningElement {
	@track isMode1=false;
	@track isMode2=false;
	@track hasError=false;
	@track errorData;
	@track currentUserType;
	@track showForm = false;
	@track showDashboard = false;
	@track applicationType = null;
	@track showSpinner=false;
	// IATA Staff Vetting
	@api tidsCaseId = null;
	iata_logo = tidsAssetsPath +'/assets/tids.png';

	@wire(CurrentPageReference) pageRef;

	@wire(getPrincipalActivities) mainActivitiesCallback({ error, data }){
		if (data){
			let principalActivityValues = this.mapping(data);
			setMainActivities(principalActivityValues);
		}
	}

	@wire(getGDSValues) gdsValuesCallback({ error, data }){
		if (data){
			let gdsValues = this.mapping(data);
			setGDSValues(gdsValues);
		}
	}

	@wire(getNumberOfEmployees) numberOfEmployeesCallback({ error, data }){
		if (data){
			let numberOfEmployeesValues = this.mapping(data);
			setNumberOfEmployees(numberOfEmployeesValues);
		}
	}

	@wire(getPreferedLanguages) preferedLanguagesCallback({ error, data }){
		if (data){
			let preferedLanguagesValues = this.mapping(data);
			setPreferedLanguages(preferedLanguagesValues);
		}
	}

	@wire(getFocusValues) focusValuesCallback({ error, data }){
		if (data){
			let focusValues = this.mapping(data);
			focusValues.forEach((item) => {
				item.value = null;
			});
			setFocusValues(focusValues);
		}
	}

	@wire(getPrincipalDestination) principalDestinationsCallback({
		error,
		data
	}){
		if (data){
			let principalDestinations = this.mapping(data);
			setPrincipalDestinations(principalDestinations);
		}
	}

	@wire(getSalesVolume) salesVolumeCallback({ error, data }){
		if (data){
			let salesVolume = this.mapping(data);
			setSalesVolume(salesVolume);
		}
	}

	@wire(getMainMarketSpecialization) marketSpecializationCallback({
		error,
		data
	}){
		if (data){
			let marketSpecialization = this.mapping(data);
			setMainMarketSpecialization(marketSpecialization);
		}
	}

	@wire(getCountries) countriesCallback({ error, data }){
		if (data){
			let countries = JSON.parse(JSON.stringify(data));
			setCountries(countries);
		}
	}

	@wire(getMailingCountries) mailingCountriesCallback({ error, data }){
		if (data){
			let countries = JSON.parse(JSON.stringify(data));
			setMailingCountries(countries);
		}
	}

	@wire(getPickListValuesCompanyTypes) companyTypesCallback({ error, data }){
		if (data){
			let companyTypes = JSON.parse(JSON.stringify(data));
			setCompanyTypes(companyTypes);
		}
	}

	mapping(props){
		let values = JSON.parse(JSON.stringify(props));
		let index = 0;
		let results = [];
		values.forEach((item) => {
			results.push({
				id: index++,
				label: item.label,
				value: item.value,
				isSelected: false
			});
		});
		return results;
	}

	renderedCallback(){
		// this.loadTidsStyle();
	}

	loadTidsStyle(){
		Promise.all([
			loadStyle(this, tidsAssetsPath + "/css/eim2mwo.css"),
			loadStyle(this, FontAwesome5 + "/css/all.min.css"),
			loadStyle(this, tidsAssetsPath + "/css/materialize.min.css"),
			loadStyle(this, tidsAssetsPath + "/css/styles.css"),
			loadStyle(this, tidsAssetsPath + "/css/styles-dashboard.css")
		])
			.then(() => {
				this.init();
			})
			.catch((error) => {});
	}

	connectedCallback(){
		this.resetDisplayValues();
		registerListener('documentsListener',this.handleOpenCloseDocument, this);
		registerListener("newBranchListener", this.newBranchListener, this);
		registerListener("resumeApplication", this.handleResumeApplication, this);
		registerListener("duplicateAccountListener",this.duplicateAccountListener,this);
		registerListener("applicationDecisionListener",this.applicationDecisionListener,this);
		registerListener("reportChangesListener", this.reportChangesListener, this);
		this.loadTidsStyle();
	}
	
	init(){
		console.log('tidsApp:init');
		this.applicationType = getApplicationType();
		this.isMode1=false;
		this.isMode2=false;
		//invoking one case
		if (this.tidsCaseId){
			 getVettingDoneCondition({
				tidsCaseId:this.tidsCaseId
			 })
			 .then((result) => {
				 if (result==null){
						this.loadCase();
				 }else{
						this.showForm=false;
						this.isMode1=true;
						this.isMode2=false;
						this.showSpinner=false;
						this.showDashboard=false;
						console.log('getVettingDoneCondition:result', JSON.stringify(result));
						this.errorData = this.mappingError(result);
						console.log('getVettingDoneCondition:this.errorData', JSON.stringify(this.errorData));
						this.hasError = true;
				 }
			})
			.catch((error) => {
				console.log('getVettingDoneCondition:error', JSON.stringify(error));
			});
		} else {
			this.isMode1=true;
			this.isMode2=false;
			this.showSpinner=false;
			this.currentUserInfo(Id);
		}
	}
	loadCase(){
		getTidsCase({
			caseId: this.tidsCaseId,
			userId: Id
		})
		.then((response) => {
				console.log('response',JSON.stringify(response));
				let isHeadOffice = response.tidsCase.Account.Location_Type__c === 'HO' ? true : false;
				console.log('isHeadOffice',isHeadOffice);
				console.log('response.tidsCase.Account.Location_Type__c',response.tidsCase.Account.Location_Type__c);
				setIsAccountHeadOffice(isHeadOffice);
				setUserInfoIata({
					locationtype:response.tidsCase.Account.Location_Type__c,
					Name: response.currentUser.Name,
					Id: response.currentUser.Id,
					ContactId: response.tidsCase.ContactId,
					AccountId: response.tidsCase.AccountId,
					Country_ISO_Code: response.tidsCase.Account.Country_ISO_Code__c,
					role:response.profile.Access_Status_Reason__c
				});

				setUserType(true);
				setBusinessrules(response.businessRules);
				setCase({ Id: this.tidsCaseId });
				let jsonCaseAttachment = JSON.parse(response.tidsAttachment);
				setApplicationType(jsonCaseAttachment.applicationType);

				let tidsConfiguration = JSON.parse(response.tidsConfiguration);
				setConfiguration(tidsConfiguration);
				createMenu(tidsConfiguration);

				updateSections(jsonCaseAttachment.sections);
				setSectionsDone(jsonCaseAttachment.sectionsDone);
				console.log('setSectionsDone2', JSON.stringify(jsonCaseAttachment.sectionsDone));
 
				this.isMode1=false;
				this.isMode2=true;
				this.showSpinner=false;
				this.showForm = true;
				// eslint-disable-next-line @lwc/lwc/no-async-operation
				setTimeout(() => {
						fireEvent(this.pageRef, "formListener", { section: "form" });
					},
					1,
					this
				);
		})
		.catch((error) => {
			console.log(error);
		});
	}
	currentUserInfo(userId){
		console.log('tidsApp:currentUserInfo');
		getUserInfo1({
			userId: userId
		})
			.then((result) => {
				let sfInfo = JSON.parse(JSON.stringify(result));
				console.log('currentUserInfo:result',JSON.stringify(result));
				this.mappingUserInfo(sfInfo);

				let tidsConfiguration = JSON.parse(sfInfo.tidsConfiguration);
				console.log('currentUserInfo:sfInfo.tidsConfiguration',sfInfo.tidsConfiguration);
				setConfiguration(tidsConfiguration);
				console.log('setConfiguration(tidsConfiguration)');
				createMenu(tidsConfiguration);
				console.log('createMenu(tidsConfiguration)');
				
				if (Object.keys(result.error).length > 0){
					 console.log('tids Conditions', JSON.stringify(result.error));
					// TIDS Conditions
					this.tidsConditionsBusinessLogic(sfInfo);
				}else if (Object.keys(sfInfo.profile).length > 0){
					console.log('tids Dashboard',JSON.stringify(sfInfo));
					// TIDS Dashboard
					this.tidsDashboardBusinessLogic(sfInfo);
				}else if (Object.keys(result.currentUser).length > 0){
					console.log('tids HO New Application', JSON.stringify(result.currentUser));
					// TIDS HO Form Application
					this.tidsFormBusinessLogic(sfInfo);
				}
			})
			.catch((error) => {
				console.log(JSON.stringify(error));
			});
	}

	tidsDashboardBusinessLogic(sfInfo){
		// TIDS Admin - Portal Application Right Access_Status_Reason__c = TIDS Admin HO Primary
		// TIDS Admin - Portal Application Right Right__c = Access Granted
		let r = sfInfo.profile.Access_Status_Reason__c;
		if ( sfInfo.profile.Right__c === "Access Granted" &&
			(r === "TIDS Admin HO Primary" || r === "TIDS Admin HO Secondary" || r === "TIDS Branch Administrator")){
			this.showDashboard = true;
		}
	}

	tidsConditionsBusinessLogic(sfinfo){
		this.showForm = true;
		this.hasError = true;
		this.errorData = this.mappingError(sfinfo.error);
		//setUserType(false);
		let jsonCaseAttachment = JSON.parse(sfinfo.tidsAttachment);
		updateSections(jsonCaseAttachment.sections);
		setSectionsDone(jsonCaseAttachment.sectionsDone);
		console.log('setSectionsDone1', JSON.stringify(jsonCaseAttachment.sectionsDone));
	}

	tidsFormBusinessLogic(sfInfo){
		this.showForm = true;
		let sectionLoad={ section: "welcome" };
		if (this.applicationType === NEW_BRANCH){
			sectionLoad.section = "agency-legal-status";
		}
		//setUserType(false);
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
			fireEvent(this.pageRef, "formListener", sectionLoad);
		}, 1000);
	}

	resetDisplayValues(){
		this.isMode1=false;
		this.isMode2=false;
		this.showSpinner=true;
		this.showForm = false;
		this.showDashboard = false;
		this.hasError = false;
	}

	mappingUserInfo(props){
		setUserInfo(props);
		setUserType(false);
		setBusinessrules(props.businessRules);
		setCase({ Id: props.tidsCase.Id });
	}

	handleResumeApplication(){
		this.hasError = false;
		this.showForm = true;
		setUserType(false);
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
				fireEvent(this.pageRef, "formListener", { section: "form" });
			},
			1,
			this
		);
	}

	duplicateAccountListener(props){
		this.resetDisplayValues();
		if (props.hasAnError){
			this.hasError = props.hasAnError;
			this.errorData = this.mappingError(props.error);
			this.showForm=false;
			this.isMode1=true;
			this.isMode2=false;
			this.showSpinner=false;
			this.showDashboard=false;
		} else if(props.hasReinstatementDeadline){
			this.hasError = props.hasReinstatementDeadline;
			let errorMessage = this.accountReinstatementDeadline();
			errorMessage.description1 = props.reason;
			this.errorData = errorMessage;
		}
	}

	newBranchListener(payload){
		this.resetDisplayValues();
		this.showForm = true;
		this.isMode1=true;
		this.ismode2=false;
		this.showSpinner=false;
		let headOffice = getHeadOfficeInfo();
		console.log('handleProceed',JSON.stringify(headOffice));
		// Head Office Information
		let applicantValues={
			cmpName: "new-applicant",
			target: "NA",
			values: {
				companyLegalName: headOffice.tidsAccount.Name,
				countryName: headOffice.tidsAccount.IATA_ISO_Country__r.Name,
				countryIsoCode: headOffice.tidsAccount.IATA_ISO_Country__r.ISO_Code__c,
				countryId: headOffice.tidsAccount.IATA_ISO_Country__r.Id
			},
			sectionDecision: "NA",
			vettingErrors: []
		};
		if (payload.applicationType==='NEW_VB'){
				let address= {
						values:{
							address: headOffice.tidsAccount.BillingStreet,
							city: headOffice.tidsAccount.BillingCity,
							state: {
								label:headOffice.tidsAccount.BillingState
							},
							postalCode: headOffice.tidsAccount.BillingPostalCode,
							countryIsoCode: headOffice.tidsAccount.BillingCountry,
							virtualCountryOfOperations:payload.virtualCountryOfOperations      
						}
				};
				
				setAddress(address);
				let mailing= {
					sectionName: 'Mailing',
					cmpName: 'mailing',
					values: {
						isMailingSameAsPhysicalAddress: 'true'
					},
					sectionDecision: 'Not_Started',
					errors: []
				};
				setMailing(mailing);
		}
		console.log('handleProceed','setWelcome');
		setWelcome(applicantValues);
		let shareholdersValues = [];
		headOffice.shareholders.forEach((item) => {
			let shareholder={
				percentage: item.Percentage__c,
				type: item.Owner_Category__c,
				name: item.Owner_Name__c,
				email: item.Owner_Email__c,
				id: item.Id
			};
			shareholdersValues.push(shareholder);
		});

		let shareholderDetailValues={
			cmpName: "shareholder-details",
			target: "NA",
			values: shareholdersValues,
			sectionDecision: "NA",
			vettingErrors: this.vettingErrors
		};
		console.log('handleProceed','setShareholderDetails');
		setShareholderDetails(shareholderDetailValues);
		// Principal Activities values from GDP References table
		// Agency Legal Status
		let agencyValues={
			cmpName: "agency-legal-status",
			target: "NA",
			values: {
				tradingName: null,
				companyType: headOffice.tidsAccount.Company_Type__c,
				taxIdVATNumber1: headOffice.tidsAccount.VAT_Number__c,
				taxIdVATNumber2: headOffice.tidsAccount.VAT_Number_2__c,
				businessRegistration: headOffice.tidsAccount.License_Number__c,
				inOperationsSince: null
			},
			sectionDecision: "NA",
			vettingErrors: []
		};
		console.log('handleProceed','setAgencyLegalStatus');
		setAgencyLegalStatus(agencyValues);
		console.log('handleProceed','formListener');
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
			fireEvent(this.pageRef, "formListener", { section: "form" });
		}, 1000);
	}

	mappingError(payload){
		console.log('mappingError:payload',JSON.stringify(payload));
		let errorText={
			id: payload.Id,
			developerName: payload.DeveloperName,
			subtitle: payload.Subtitle__c,
			description1: payload.Description__c,
			description2: payload.Description_P2__c,
			description3: payload.Description_P3__c,
			createCase: payload.Create_a_Case__c,
			closeVetting: payload.Close_Vetting__c,
			caseText: payload.Open_A_Case_Text__c,
			visitWebsiteUrl: payload.Visit_URL__c,
			visitWebsiteText: payload.Visit_A_Website_Text__c,
			discardApplication: payload.Discard_Application__c,
			resumeApplication: payload.Resume_Application__c,
			recallApplication: payload.Recall_Application__c,
			yellowheader: payload.Yellow_Section_Header__c,
			yellowsection: payload.Yellow_Section_Text__c
		};
		return errorText;
	}

	applicationDecisionListener(action){
		console.log('applicationDecisionListener:action',action);
		switch (action.type){
			case "Approved":
				this.applicationDecisionApproved();
				break;
			case "Closed":
				this.applicationDecisionClosed();
				break;
			case "SaveAndQuit":
				this.saveAndQuitBusinessLogic();
				break;
			case "Pending customer":
				this.applicationPendingcustomer(action.caseId);
				break;  
			case "ApplicationRecall":
				this.saveAndQuitBusinessLogic();
				break;  
			case "Submitted":
				this.applicationSubmitted();
				break;
			default:
				break;
		}
	}
	applicationPendingcustomer(caseId){
		this.resetDisplayValues();
		getVettingDoneCondition({
			tidsCaseId:null
		})
		.then((result) => {
			this.isMode1=true;
			this.isMode2=false;
			this.showSpinner=false;
			this.showDashboard=false;
			console.log('getVettingDoneCondition:result', JSON.stringify(result));
			this.errorData = this.mappingError(result);
			console.log('getVettingDoneCondition:this.errorData', JSON.stringify(this.errorData));
			this.hasError = true;
		})
		.catch((error) => {
			console.log('getVettingDoneCondition:error', JSON.stringify(error));
		});
	}
	accountReinstatementDeadline(){
		let errorData={
			subtitle: "TIDS Reinstatement",
			description1: "Description One",
			description2: "Description Two",
			description3: "Description Three",
			createCase: false,
			closeVetting: false,
			discardApplication: false,
			resumeApplication: false,
			recallApplication: false,
			apologizeMessage: false
		};
		return errorData;
	}
	applicationDecisionApproved(){
		this.resetDisplayValues();
		getVettingDoneCondition({
			tidsCaseId:null
		})
		.then((result) => {
			this.isMode1=true;
			this.isMode2=false;
			this.showSpinner=false;
			this.showDashboard=false;
			console.log('getVettingDoneCondition:result', JSON.stringify(result));
			this.errorData = this.mappingError(result);
			console.log('getVettingDoneCondition:this.errorData', JSON.stringify(this.errorData));
			this.hasError = true;
		})
		.catch((error) => {
			console.log('getVettingDoneCondition:error', JSON.stringify(error));
		});
	}
	applicationDecisionClosed(){
		this.resetDisplayValues();
		this.resetDisplayValues();
		getVettingDoneCondition({
			tidsCaseId:null
		})
		.then((result) => {
			this.isMode1=true;
			this.isMode2=false;
			this.showSpinner=false;
			this.showDashboard=false;
			console.log('getVettingDoneCondition:result', JSON.stringify(result));
			this.errorData = this.mappingError(result);
			console.log('getVettingDoneCondition:this.errorData', JSON.stringify(this.errorData));
			this.hasError = true;
		})
		.catch((error) => {
			console.log('getVettingDoneCondition:error', JSON.stringify(error));
		});
	}
	saveAndQuitBusinessLogic(){
		this.resetDisplayValues();
		this.currentUserInfo(Id);
		this.isMode2=false;
		this.isMode1=true;
		this.showSpinner=false; 
		this.hasError = true;
	}

	applicationSubmitted(){
		this.resetDisplayValues();
		this.currentUserInfo(Id);
		this.isMode2=false;
		this.isMode1=true;
		this.showSpinner=false;
		this.hasError = true;
	}
	reportChangesListener(action){
		this.resetDisplayValues();
		this.isMode1=true;
		this.isMode2=false;
		this.showSpinner=false;
		console.log('reportChangesListener1',JSON.stringify(action));
		setLocationType(action.payload.locationtype);
		setApplicationType(action.payload.changeType);
		console.log('reportChangesListener3',action.payload.changeType);
		initializeTidsInfo();
		switch (action.payload.changeType){
			case "chg-name-company":
				console.log('reportChangesListener4');
				this.changeNameCompanyDetails();
				break;
			case "chg-address-contact":
				this.changeAddressContactDetails();
				break;
			case "chg-business-profile-specialization":
				this.changeBusinessProfileSpecialization();
				break;
			default:
				break;
		}
		console.log('action', JSON.stringify(action));
	}

	changeNameCompanyDetails(){
		let accountSelected = getAccountSelected();
		getNameCompanyDetails({ accountId: accountSelected.Id, isLabel:false })
			.then((result) => {
				this.changeNameCompanyDetailsCallback(result);
			})
			.catch((error) => {
				console.log(error);
			});
	}

	changeNameCompanyDetailsCallback(result){
		this.mappingWelcome(result);
		this.mappingAgencyLegalStatus(result);
		this.mappingShareholderDetails(result);
		this.reloadForm();
		
	}

	changeAddressContactDetails(){
		let accountSelected = getAccountSelected();
		getAddressContactDetails({ accountId: accountSelected.Id })
			.then((result) => {
				this.changeAddressContactDetailsCallback(result);
			})
			.catch((error) => {
				console.log(error);
			});
	}
	changeAddressContactDetailsCallback(account){
		let act=JSON.parse(JSON.stringify(account));
		console.log('changeAddressContactDetailsCallback:account',JSON.stringify(account));
		this.mappingWelcome(act);
		this.mappingAddress(act);
		this.mappingMailingAddress(account);
		this.mappingContact(account);
		this.reloadForm();
	}

	changeBusinessProfileSpecialization(){
		let accountSelected = getAccountSelected();
		getBusinessProfileSpecialization({ accountId: accountSelected.Id,isLabel:false })
			.then((response) => {
				this.changeBusinessProfileSpecializationCallback(response);
			})
			.catch((error) => {
				console.log(error);
			});
	}

	changeBusinessProfileSpecializationCallback(account){
		setBusinessProfile(account.businessProfile);
		setBusinessSpecialization(account.businessSpecialization);
		this.reloadForm();
	}

	mappingWelcome(account){
		let applicantValues={
			cmpName: "new-applicant",
			target: "NA",
			values: {
				companyLegalName: account.name,
				countryName: account.country.label,
				countryIsoCode: account.country.value,
				countryId: account.country.Id
			},
			sectionDecision: "NA",
			vettingErrors: []
		};

		setWelcome(applicantValues);
	}

	mappingAgencyLegalStatus(account){
		// Agency Legal Status
		let agencyValues={
			cmpName: "agency-legal-status",
			target: "NA",
			values: {
				tradingName: account.tradeName,
				companyType: account.companyType,
				taxIdVATNumber1: account.vatNumber1,
				taxIdVATNumber2: account.vatNumber2,
				businessRegistration: account.licenseNumber,
				inOperationsSince: account.inOperationsSince
			},
			sectionDecision: "NA",
			vettingErrors: []
		};

		setAgencyLegalStatus(agencyValues);
	}

	mappingShareholderDetails(account){
		let shareholdersValues = [];
		account.accountRoles.forEach((item) => {
			let shareholder={
				percentage: item.Percentage__c,
				type: item.Owner_Category__c,
				name: item.Owner_Name__c,
				email: item.Owner_Email__c,
				id: item.Id
			};
			shareholdersValues.push(shareholder);
		});

		let shareholderDetailValues={
			cmpName: "shareholder-details",
			target: "NA",
			values: shareholdersValues,
			sectionDecision: "NA",
			vettingErrors: []
		};
		setShareholderDetails(shareholderDetailValues);
	}

	mappingAddress(account){
		let addressValues={
			cmpName: this.cmpName,
			target: "NA",
			sectionDecision: "Not_Started",
			values: {
				address: account.address,
				city: account.city,
				citygeonameId: account.citygeonameId,
				state: {
					Id: account.stateProvince.Id,
					label: account.stateProvince.label,
					value: account.stateProvince.value
				},
				postalCode: account.postalCode,
				countryName: account.country.label,
				countryIsoCode: account.country.value,
				countryId: account.country.Id
			},
			vettingErrors: []
		};
		setAddress(addressValues);
	}

	mappingMailingAddress(account){
		let mailingAddressValues={};
		let isMailingSameAsPhysicalAddress = account.mailingAddress === null ? true : false;
		if (isMailingSameAsPhysicalAddress){
			mailingAddressValues={
				cmpName: "mailing",
				target: "NA",
				sectionDecision: "Not_Started",
				values: {
					isMailingSameAsPhysicalAddress: isMailingSameAsPhysicalAddre.toString(),
				},
				vettingErrors: []
			};
		} else {
			mailingAddressValues={
				cmpName: "mailing",
				target: "NA",
				sectionDecision: "Not_Started",
				values: {
					isMailingSameAsPhysicalAddress: isMailingSameAsPhysicalAddress.toString(),
					mailingAddress: account.mailingAddress,
					city: account.mailingCity,
					citygeonameId: account.mailingcitygeonameId,
					state: {
						Id: account.mailingStateProvince.Id,
						label: account.mailingStateProvince.label,
						value: account.mailingStateProvince.value
					},
					postalCode: account.mailingPostalCode,
					countryName: account.mailingCountry.label,
					countryIsoCode: account.mailingCountry.value,
					countryId: account.mailingCountry.Id
				},
				vettingErrors: []
			};
		}
		setMailing(mailingAddressValues);
	}

	mappingContact(account){
		let contactValues={
			cmpName: "contact",
			target: "NA",
			sectionDecision: "Not_Started",
			values: {
				preferedLanguage: account.preferredLanguage,
				phone: account.phone,
				fax: account.fax,
				businessEmail: account.email,
				webSite: account.website,
				omFirstName: account.managerFirstName,
				omLastName: account.managerLastName
			},
			vettingErrors: []
		};
		setContact(contactValues);
	}

	reloadForm(){
		setSectionsDone([]);
		console.log('setSectionsDone3'); 
		this.showForm = true;
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
			fireEvent(this.pageRef, "formListener", { section: "form" });
		}, 1000);
	}

	handleOpenCloseDocument(props){
		console.log('documentsListener:props', props);
		this.template.querySelector('[data-id="divblock2"]').classList.toggle('attachmentsClosed');
	}


}
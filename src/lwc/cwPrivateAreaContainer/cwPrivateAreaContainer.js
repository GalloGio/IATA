import { LightningElement, wire, track } from "lwc";
import getUserFacilities from "@salesforce/apex/CW_PrivateAreaController.getUserFacilities";
import getUserRemoteValidations from "@salesforce/apex/CW_RemoteValidationsController.getUserRemoteValidations";
import getUserRequestedAudits from "@salesforce/apex/CW_ScheduleAuditsController.getUserRequestedAudits";
import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";
import getCompanyadminContactsFromAccountId from "@salesforce/apex/CW_Utilities.getCompanyadminContactsFromAccountId";
import getActiveCertifications from "@salesforce/apex/CW_PrivateAreaController.getActiveCertifications";
import getUserCompanyInfo from "@salesforce/apex/CW_PrivateAreaController.getUserCompanyInfo";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import approveStationAutomaticProcess from "@salesforce/apex/CW_Utilities.approveStationAutomaticProcess";
import rejectStationAutomaticProcess from "@salesforce/apex/CW_Utilities.rejectStationAutomaticProcess";
import approveCrdAutomaticProcess from "@salesforce/apex/CW_Utilities.approveContactRoleDetailAutomaticProcess";
import rejectCrdAutomaticProcess from "@salesforce/apex/CW_Utilities.rejectContactRoleDetailAutomaticProcess";
import handleContactRoleDetailRemovalProcess from "@salesforce/apex/CW_Utilities.handleContactRoleDetailRemovalProcess";
import userHasOneSourceAccess from "@salesforce/apex/CW_PrivateAreaController.userHasOneSourceAccess";
import getGxaSSOUrl from "@salesforce/apex/CW_PrivateAreaController.getGxaSSOUrl";
import { refreshApex } from "@salesforce/apex";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { loadStyle } from "lightning/platformResourceLoader";
import { getQueryParameters, concatinateAddressString, concatinateFacilityAddress,getCompanyTypeImage } from "c/cwUtilities";
import pubsub from "c/cwPubSub";
import isProductionEnvironment from "@salesforce/apex/CW_PrivateAreaController.isProductionEnvironment";
import labels from 'c/cwOneSourceLabels';
import getEnvironmentVariables from '@salesforce/apex/CW_Utilities.getEnvironmentVariables';

export default class CwPrivateAreaContainer extends LightningElement {
	@track userFacilities;
	@track userRemoteValidations;
	@track userInfo;
	@track userCompanyInfo;
	@track companyAdmins;
	@track activeCertifications;
	@track selectedFacility;
	@track menuItemSelected;
	@track requestedAudits;
	@track gxaUrl = '#';
	@track sectionLoading;
	label = labels.labels();
	stationsInitialized;
	managedFacilitiesIds;
	initializedData;
	rawFacilities;
	urlBaseFacilityPage;
	@track isLoading = true;
	@track approvalModalMessage;

	CHECKED_IMAGE = resources + "/icons/ic-tic-green.svg";
	ERROR_IMAGE = resources + "/icons/error-icon.svg";

	@track showApprovalModal;
	@track showRejectModal;
	//Approval station params
	approvalSuccess;
	approvalStationId;
	approvalContactRoleId;
	removalContactRoleId;
	approvalAction;
	rejectReasonStation;
	rejectReasonContactRole;
	isProductionEnv;

	@track userHasAccess = false;

	@wire(getEnvironmentVariables, {})
    environmentVariables;

	@wire(userHasOneSourceAccess,{})
	wiredUserAccess(result){
		this.userHasAccess = result.data;
		if(this.userHasAccess != undefined && !this.userHasAccess){
			window.location.href = window.location.href.toLowerCase().indexOf('onesource.iata.org')>-1 ? '/OneSourceLogin' : '/onesource/OneSourceLogin';
		}
	}
	
	@wire(getGxaSSOUrl, {})
	wiredGxaUrl(result){
		if (result.data) this.gxaUrl = result.data;
	}

	@wire(getURL, { page: "URL_ICG_FacilityPage" })
	wiredFacilityUrl({ data }) {
		if (data) {
			this.urlBaseFacilityPage = data;
		}
	}
	@wire(getUserFacilities, {})
	wiredFacilities(result) {
		this.rawFacilities = result;
		if (result.data) {
			this.userFacilities = [];
			let objEntries = Object.entries(JSON.parse(result.data));
			objEntries.forEach(opsHierarchyGroup => {
				//0 is Group Name. 1 is Group Facilities. This is the result of object.entries.
				let [groupName, groupInfo] = opsHierarchyGroup;
				let numberOfStations = 0;
				let numberOfApprovedStations = 0;
				groupInfo.companyList.forEach(company =>{
					if(company.stations){
						numberOfStations += company.stations.length;
						company.stations.forEach(station => {
							if (station.Account_Role__c) {
								station.ctypeimage = resources + getCompanyTypeImage(station.RecordType.DeveloperName);
							}
							station.thumbnail = station.logoUrl__c ? station.logoUrl__c : resources + "/img/no-image.svg";
							station.recordUrl = this.urlBaseFacilityPage + "?eid=" + station.Id;
							station.groupName = groupName;
							station.city = company.accountInfo.Business_City__r ? company.accountInfo.Business_City__r.Name : company.accountInfo.Business_City_Name__c;
							station.country = company.accountInfo.IATA_ISO_Country__r.Name;
							station.street = company.accountInfo.Business_Street__c;
							station.state = company.accountInfo.Business_State_Name__c;
							station.postalCode = company.accountInfo.Business_Postal_Code__c;
							station.userIsCompanyAdmin = groupInfo.isCompanyAdmin;
							station.userIsPendingCompanyAdmin = groupInfo.isPendingCompanyAdmin;
							station.pendingForIataApproval = station.Status__c === 'Pending for IATA Approval';
							let location = {addressPostalCode : station.postalCode, addressStateProvince : station.state,  addressCity: station.city, location : {location:{Country : station.country}}};
							let address = concatinateAddressString(station.street) + concatinateFacilityAddress(location);
							station.address = address.slice(0,-2);
							station.CreatedDateDateFormat = (station.CreatedDate.split("-")[2]).split('T')[0] + "-" + station.CreatedDate.split("-")[1] + "-" + station.CreatedDate.split("-")[0];
							station.createdById = company.CreatedById;
							if(station.isApproved__c) numberOfApprovedStations++;
							
						})
					}
					
				})
				
				let companyList = groupInfo.companyList;
                let hasItem = (companyList.length>0);
				let isCompanyAdmin = groupInfo.isCompanyAdmin;
				let isPendingCompanyAdmin = groupInfo.isPendingCompanyAdmin;
				let status = groupInfo.status;
				let accountRoleDetailId  = groupInfo.id;
                let createdDateDateFormat = groupInfo.createdDate ? (groupInfo.createdDate.split("-")[2]).split('T')[0] + "-" + groupInfo.createdDate.split("-")[1] + "-" + groupInfo.createdDate.split("-")[0] : null;
                let createdDate = groupInfo.createdDate;
				this.userFacilities.push({accountRoleDetailId, groupName, isCompanyAdmin,isPendingCompanyAdmin, companyList, numberOfStations, numberOfApprovedStations, status, createdDateDateFormat, createdDate, hasItem});
			});
			this.isLoading = false;
		}else{
			console.log(result);
			this.isLoading = false;
		}
	}
	rawUserInfo;
	@wire(getUserInfo, {})
	wiredUserInfo(result) {
		this.rawUserInfo = result;
		if (result.data) {
			this.userInfo = JSON.parse(result.data);
			getCompanyadminContactsFromAccountId({ accountId: this.userInfo.AccountId })
				.then(cadmins => {
					if (cadmins) {
						this.companyAdmins = cadmins;
					} else {
						this.companyAdmins = [];
					}
                })
				.catch(err => {
					this.companyAdmins = [];
				});
        }
	}

	@wire(getActiveCertifications, {})
	wiredCertifications({ data }) {
		if (data) {
			this.activeCertifications = JSON.parse(data);
		}
	}
	@wire(getUserCompanyInfo, {})
	wiredCompanyInfo({ data }) {
		if (data) {
			this.userCompanyInfo = JSON.parse(data);
		}
	}

	get showUserStats() {
		return !this.showFacilityDetail && !this.showCreateNewFacility && !this.showBecomeCompanyAdmin && !this.showBecomeFacilityManager && !this.showScheduleAudits && !this.showValidationHistory && !this.showPurchaseRemoteValidation && !this.showOpenRemoteValidations && !this.showOpenRemoteValidationHistory && !this.showPendingUserApprovals && !this.showCompanyAdmins && !this.showAuditsRequested && !this.showPendingFacilityApprovals && !this.showStationManagers && !this.showMyRequests && !this.showAlertsAndEvents && !this.showCapabilityManagement;
	}
	get showAlertsAndEvents() {
		return this.menuItemSelected === "Alerts and Events" && this.userInfo;
	}
	get showFacilityDetail() {
		return this.selectedFacility && !this.menuItemSelected;
	}
	get showCreateNewFacility() {
		return this.menuItemSelected === "New Facility" && this.userFacilities && this.companyAdmins;
	}
	get showBecomeFacilityManager() {
		return this.menuItemSelected === "Become Facility Manager" && this.userInfo && this.userFacilities;
	}
	get showBecomeCompanyAdmin() {
		return this.menuItemSelected === "Become Company Admin" && this.userInfo;
	}
	get showPendingFacilityApprovals() {
		return this.menuItemSelected === "Pending Facility Approvals" && this.userInfo;
	}
	get showScheduleAudits() {
		return this.menuItemSelected === "Schedule Audits" && this.userInfo;
	}
	get showAuditsRequested() {
		return this.menuItemSelected === "Audits Requested" && this.userInfo;
	}
	get showValidationHistory() {
		return this.menuItemSelected === "Validation History" && this.userInfo;
	}
	get showCapabilityManagement() {
		return this.menuItemSelected === this.label.capability_management && this.userInfo;
	}
	get showPurchaseRemoteValidation() {
		return this.menuItemSelected === "Purchase Remote Validation" && this.userInfo;
	}
	get showOpenRemoteValidations() {
		return this.menuItemSelected === "Open Remote Validations" && this.userInfo;
	}
	get showOpenRemoteValidationHistory() {
		return this.menuItemSelected === "Remote Validation History" && this.userInfo;
	}
	get showPendingUserApprovals() {
		return this.menuItemSelected === "Pending User Approvals" && this.userInfo;
	}
	get showStationManagers() {
		return this.menuItemSelected === "Station Managers" && this.userInfo;
	}

	get showCompanyAdmins() {
		return this.menuItemSelected === "Company Admins" && this.userInfo;
	}
	get showMyRequests() {
		return this.menuItemSelected === "My Requests" && this.userInfo;
	}

	selectFacility(event) {
		this.menuItemSelected = undefined;
		this.selectedFacility = event.detail;
		this.setHash = this.selectedFacility;
	}

	setHash(hashvalue) {
		window.location.hash = hashvalue ? hashvalue : 'home';
	}

	expandMnu() {
		let thisCol = this.template.querySelector(".collapsedMnu");
		let mainCol = this.template.querySelector(".maincol");
		thisCol.style.width = "";
		thisCol.className = "col-xl-2 col-lg-2 col-md-12 col-xs-12 filter-panel";
		mainCol.classList.remove("col-xl-11-5");
		mainCol.classList.remove("col-lg-11-5");
		mainCol.classList.add("col-xl-10");
		thisCol.style.marginLeft = "0px";
		mainCol.classList.add("col-lg-10");
	}

	collapseMnu() {
		let mainCol = this.template.querySelector(".maincol");
		let thisCol = this.template.querySelector('[class="col-xl-2 col-lg-2 col-md-12 col-xs-12 filter-panel"]');
		mainCol.classList.remove("col-xl-10");
		mainCol.classList.remove("col-lg-10");
		mainCol.classList.add("col-xl-11-5");
		mainCol.classList.add("col-lg-11-5");
		thisCol.style.width = "40px";
		thisCol.style.marginLeft = "13px";
		thisCol.className = "collapsedMnu";
	}

	selectMenuItem(event) {
		this.menuItemSelected = event.detail;
	}

	refreshData() {
		refreshApex(this.rawUserInfo);
		refreshApex(this.rawFacilities);
		this.isLoading = false;
	}
	initialized = false;
	connectedCallback() {
		if (!this.initialized) {
			this.isLoading = true;
			this.initialized = true;
			this.checkAutomaticApprovals();
			this.readHash();
		}
	}

	validParam(param) {
		return param && (param.length === 15 || param.length === 18);
	}

	checkAutomaticApprovals(){
		let params = getQueryParameters();
		if(this.validParam(params.approveStation)){
			this.approvalStationId = params.approveStation;
			this.approveStation(true);
		} else if (this.validParam(params.rejectStation)) {
			this.approvalStationId = params.rejectStation;
			this.isLoading = false;
			this.showRejectModal = true;
		} else if (this.validParam(params.approveContactRole)) {
			this.approvalContactRoleId = params.approveContactRole;
			this.isLoading = false;
			this.approveContactRole(true);
		} else if (this.validParam(params.rejectContactRole)) {
			this.approvalContactRoleId = params.rejectContactRole;
			this.isLoading = false;
			this.showRejectModal = true;
		} else if (this.validParam(params.approveRemoveContactRole)) {
			this.removalContactRoleId = params.approveRemoveContactRole;
			this.isLoading = false;
			this.handleContactRoleRemoval(true, true);
		} else if (this.validParam(params.rejectRemoveContactRole)) {
			this.removalContactRoleId = params.rejectRemoveContactRole;
			this.isLoading = false;
			this.handleContactRoleRemoval(true, false);
		}else {
			this.isLoading = false;
		}
	}
	approveStation(refresh) {
		this.approvalAction = "Approve";
		approveStationAutomaticProcess({ stationId: this.approvalStationId })
			.then(resp => {
				let modalMessage;
				this.approvalSuccess = resp;
				let approvalStation = this.getStation();

				if (this.approvalSuccess) {
					modalMessage = approvalStation ? approvalStation.Name : "The Station";
					modalMessage += " has been approved. Now it is pending for IATA Approval.";
				} else {
					modalMessage = approvalStation ? approvalStation.Name : "The Station";
					modalMessage += " could not be approved. You have to be Company Admin in order to approve this station.";
				}
				this.approvalModalMessage = modalMessage;
				this.showApprovalModal = true;
				if (refresh) this.refreshData();
				this.removeUrlParams();
			})
			.catch(ex => {
				console.error(ex);
				this.approvalSuccess = false;
				this.showApprovalModal = true;
				this.isLoading = false;
			});
	}
	rejectStation(refresh) {
		this.approvalAction = "Reject";
		rejectStationAutomaticProcess({ stationId: this.approvalStationId, rejectReason: this.rejectReasonStation })
			.then(resp => {
				let modalMessage;
				this.approvalSuccess = resp;
				let approvalStation = this.getStation();

				if (this.approvalSuccess) {
					modalMessage = approvalStation ? approvalStation.Name : "The Station";
					modalMessage += " has been rejected successfully.";
				} else {
					modalMessage = approvalStation ? approvalStation.Name : "The Station";
					modalMessage += " could not be rejected. You have to be Company Admin in order to reject this station.";
				}
				this.approvalModalMessage = modalMessage;
				
				this.showApprovalModal = true;


				if (refresh) this.refreshData();
				this.removeUrlParams();
			})
			.catch(ex => {
				console.error(ex);
				this.approvalSuccess = false;
				this.showApprovalModal = true;
				this.isLoading = false;
			});
	}
	approveStationEvent(event) {
		this.isLoading = true;
		this.approvalContactRoleId = null;
		this.approvalStationId = event.detail;
		this.removalContactRoleId = null;
		this.approveStation(true);
	}
	rejectStationEvent(event) {
		this.approvalContactRoleId = null;
		this.approvalStationId = event.detail;
		this.removalContactRoleId = null;
		this.showRejectModal = true;
	}

	approveContactRole(refresh) {
		this.approvalAction = "Approve";
		approveCrdAutomaticProcess({ contactRoleDetailId: this.approvalContactRoleId })
			.then(resp => {
				this.approvalSuccess = resp;
				let approvalContactRole = this.getUser();

				let modalMessage;
				if (this.approvalSuccess) {
					modalMessage = approvalContactRole ? approvalContactRole.Name : "The Contact Role";
					modalMessage += " has been approved.";
				} else {
					modalMessage = approvalContactRole ? approvalContactRole.Name : "The Contact Role";
					modalMessage += " could not be approved. You have to be Company Admin in order to approve this user.";
				}
				this.approvalModalMessage = modalMessage;
				this.showApprovalModal = true;
				if (refresh) this.refreshData();
				this.removeUrlParams();
			})
			.catch(ex => {
				console.error(ex);
				this.approvalSuccess = false;
				this.showApprovalModal = true;
				this.isLoading = false;
			});
	}

	rejectContactRole(refresh) {
		this.approvalAction = "Reject";
		rejectCrdAutomaticProcess({ contactRoleDetailId: this.approvalContactRoleId, rejectReason: this.rejectReasonContactRole })
			.then(resp => {
				let approvalContactRole = this.getUser();
				this.approvalSuccess = resp;
				let modalMessage;
				if (this.approvalSuccess) {
					modalMessage = approvalContactRole ? approvalContactRole.Name : "The Contact Role";
					modalMessage += " has been rejected successfully.";
				} else {
					modalMessage = approvalContactRole ? approvalContactRole.Name : "The Contact Role";
					modalMessage += " could not be rejected. You have to be Company Admin in order to reject this station.";
				}
				this.approvalModalMessage = modalMessage;
				this.showApprovalModal = true;
				if (refresh) this.refreshData();
				this.removeUrlParams();
			})
			.catch(ex => {
				console.error(ex);
				this.approvalSuccess = false;
				this.showApprovalModal = true;
				this.isLoading = false;
			});
	}
	approveContactRoleEvent(event) {
		this.isLoading = true;
		this.approvalStationId = null;
		this.approvalContactRoleId = event.detail;
		this.removalContactRoleId = null;
		this.approveContactRole(true);
	}
	rejectContactRoleEvent(event) {
		this.approvalStationId = null;
		this.approvalContactRoleId = event.detail;
		this.removalContactRoleId = null;
		this.showRejectModal = true;
	}

	handleContactRoleRemovalEvent(event) {
		this.isLoading = true;
		let handleObj = event.detail;
		this.removalContactRoleId = event.detail.Id;
		this.approvalStationId = null;
		this.approvalContactRoleId = null;
		this.handleContactRoleRemoval(true, handleObj.approvedRemoval);
	}

	handleContactRoleRemoval(refresh, approvedRemoval) {
		this.approvalAction = "HandleRemoval";
		handleContactRoleDetailRemovalProcess({ contactRoleDetailId: this.removalContactRoleId, approvedRemoval: approvedRemoval })
			.then(resp => {
				console.log('resp handleremoval', resp);
				let approvalContactRole = this.getUser();
				let modalMessage;
				if(resp === 'Successful'){
					this.approvalSuccess = true;
					modalMessage = approvalContactRole ? approvalContactRole.Name : "The Contact Role";
					modalMessage += " has been removed.";
				}
				else if(resp === 'Unsuccessful'){
					this.approvalSuccess = true;
					modalMessage = "The request to remove ";
					modalMessage += approvalContactRole ? approvalContactRole.Name : " the contact";
					modalMessage += " has been rejected";
				}
				else if(resp === 'MissingRights'){
					modalMessage = 'You do not have sufficient rights for this operation.';
					this.approvalSuccess = false;
				}
				this.approvalModalMessage = modalMessage;
				this.showApprovalModal = true;
				if (refresh) this.refreshData();
				this.removeUrlParams();
			})
			.catch(ex => {
				console.error(ex);
				this.approvalSuccess = false;
				this.isError = true;
				this.showApprovalModal = true;
				this.isLoading = false;
			});
	}

	removeUrlParams() {
		window.history.replaceState(null, null, window.location.pathname + window.location.hash);
		this.isLoading = false;
	}
	readHash() {
		let hash = window.location.hash;
		if (hash && hash !== "#") {
			hash = decodeURIComponent(hash);
			hash = hash.replace("#", "");
			if (hash.indexOf('ID:')=== 0 && hash.length >= 15){
				//read if is Id of station
				let substrend = hash.indexOf('-') > 0 ? hash.indexOf('-') : hash.length;
				this.selectedFacility = hash.substring(3,substrend);
				this.menuItemSelected = null;
			}else{
				this.menuItemSelected = hash;
			}
			
		}
	}

	sectionLoadingJS(){
		this.sectionLoading = true;
	}

	sectionLoadedJS(){
		this.sectionLoading = false;
	}
	goToHome(event) {
		if (event) {
			event.stopPropagation();
			event.preventDefault();
			this.refreshData();
		}
		this.selectedFacility = null;
		this.menuItemSelected = undefined;
	}
	refreshAudits(event) {
		this.goToHome(event);
		this.getUserAudits(this.managedFacilitiesIds);
	}

	get userManagedFacilities() {
		let userManagedFacilities = [];
		if (this.userFacilities && this.stationsInitialized) {
			this.userFacilities.forEach(opsGroup => {
				opsGroup.companyList.forEach(company => {
					if(company.stations){
						company.stations.forEach(elem => {
							if (opsGroup.isCompanyAdmin || (elem.ICG_Contact_Role_Details__r && elem.ICG_Contact_Role_Details__r.totalSize > 0)) {
								let usermanagedfacility = true;
								if (!opsGroup.isCompanyAdmin) {
									usermanagedfacility = false;
									elem.ICG_Contact_Role_Details__r.records.forEach(role => {
										if (role.Status__c === "Approved" && role.ICG_Role__c === "Facility Manager") usermanagedfacility = true;
									});
								}
								if (usermanagedfacility){
									userManagedFacilities.push(elem);
								} 
							}else if(elem.CreatedById === this.userInfo.Id && !elem.isApproved__c){
								userManagedFacilities.push(elem);
							}
						})
					}
				})
			});
		}
		return userManagedFacilities;
	}
	getCertificationInfo(facility) {

		let daysForExpiringValidations = this.environmentVariables && this.environmentVariables.data ? this.environmentVariables.data.EXPIRING_VALIDATION_DAYS__c : 60;

		if (this.activeCertifications && facility) {
			let certInformation = [];
			let added;
			this.activeCertifications.forEach(activeCert => {
				added = false;
				let certInfo = {available:false};
				certInfo.certName = activeCert.Name;
				if(activeCert.Applicable_to__c && activeCert.Applicable_to__c.indexOf(facility.RecordType.Name)>-1){
					certInfo.available = true;
					let hasAssignments = facility.ICG_Capability_Assignment_Groups__r && facility.ICG_Capability_Assignment_Groups__r.totalSize > 0;
					if (hasAssignments) {
						facility.ICG_Capability_Assignment_Groups__r.records.forEach(certi => {
							let matchesCertification = certi.ICG_Certification__r && certi.ICG_Certification__r.Name === activeCert.Name;

							if (matchesCertification) {
								let expDate = certi.Expiration_Date__c ? certi.Expiration_Date__c : "-";
								certInfo.expDate = expDate;
								certInfo.RecordType = certi.RecordType.DeveloperName;
								certInformation.push(certInfo);
								added = true;
							}
						});
					}
				}
				if (!added) {
					certInfo.expDate = certInfo.available ? '-' : 'N/A';
					certInfo.RecordType = '-';
					certInformation.push(certInfo);
				}
			});

			if (facility.ICG_Capability_Assignment_Groups__r && facility.ICG_Capability_Assignment_Groups__r.totalSize > 0) {
				facility.ICG_Capability_Assignment_Groups__r.records.forEach(certi => {
					let isExpiring = certi.Expiration_Date__c && (new Date(certi.Expiration_Date__c).getTime() - (new Date()).getTime()) < (daysForExpiringValidations * 1000 * 60 * 60 * 24);

					if (certi.RecordType.DeveloperName === 'Remote_Validation' && isExpiring) {
						let certInfo = {available:true};
						let expDate = certi.Expiration_Date__c ? certi.Expiration_Date__c : "-";
						certInfo.expDate = expDate;
						certInfo.RecordType = certi.RecordType.DeveloperName;
						certInformation.push(certInfo);
					}
				});
			}
			return certInformation;
		}
		return null;
	}

	getUserDependentData() {
		if (!this.initializedData && this.userInfo && this.userFacilities && this.stationsInitialized) {
			this.managedFacilitiesIds = [];
			this.userManagedFacilities.forEach(fac => {
				this.managedFacilitiesIds.push(fac.Id);
			});
			this.getUserAudits(this.managedFacilitiesIds);
			this.getRemoteValidations(this.managedFacilitiesIds);
			this.initializedData = true;
		}
	}
	getUserAudits(managedFacilitiesIds) {
		getUserRequestedAudits({ managedFacilitiesIds })
			.then(requestedAudits => {
				this.requestedAudits = JSON.parse(requestedAudits);
				this.requestedAudits.forEach(audit => {
					audit.CreatedDate = audit.CreatedDate.substring(0, audit.CreatedDate.indexOf("T"));
				});
			})
			.catch(error => {
				console.log(error);
				this.isLoading = false;
			});
	}

	getRemoteValidations(managedFacilitiesIds) {
		getUserRemoteValidations({ managedFacilitiesIds })
			.then(userRemoteValidations => {
				this.userRemoteValidations = JSON.parse(userRemoteValidations);
				this.userRemoteValidations.forEach(activeRemote => {
					let expDate = activeRemote.Order.EffectiveDate;
					let dateArray = expDate.split("-");
					expDate = `${dateArray[2]}-${dateArray[1]}-${dateArray[0]}`;

					activeRemote.Order.EffectiveDate = expDate;
				});
			})
			.catch(error => {
				console.log(error);
				this.isLoading = false;
			});
	}
	get getCompanyAdminSectionText() {
		return this.userInfo && this.userInfo.isCompanyAdmin ? "Company Admin info" : "Become Company Admin";
	}

	_isProdEnvironment() {
		isProductionEnvironment()
		.then(result => {
			this.isProductionEnv = result;
		})
	}

	renderedCallback() {
        Promise.all([
                loadStyle(this, resources + "/css/main.css"),
                loadStyle(this, resources + "/css/custom.css")
            ])
            .then(() => {
                this.loadedCss = true;
                pubsub.fire("loadedCss");
			})
			.then(() => {
				this._isProdEnvironment()
			})
            .catch(err => {
				console.log(err);
				this.isLoading = false;
			});
			
		if(!this.stationsInitialized && this.userFacilities && this.activeCertifications){
			this.userFacilities.forEach(group =>{
				group.companyList.forEach(company => {
					if(company.stations){
						company.stations.forEach(station =>{
							station.allCertsRaw = this.getCertificationInfo(station);
							station.allCerts = [];
							if (station.allCertsRaw) {
								station.allCertsRaw.forEach(currentItem => {
									if (currentItem.expDate !== "-" && currentItem.expDate.split("-").length === 3) currentItem.expDate = currentItem.expDate.split("-")[2] + "-" + currentItem.expDate.split("-")[1] + "-" + currentItem.expDate.split("-")[0];
									station.allCerts.push(currentItem);
								});
							}
							station.certifications = station.allCerts.filter(cert => { return cert.RecordType !== 'Remote_Validation'});
							station.remoteValidations = station.allCerts.filter(cert => { return cert.RecordType === 'Remote_Validation'});
						})
					}
				})
				
			})
			this.stationsInitialized = true;
		}
		this.getUserDependentData();
	}
	
	closeApprovalModal() {
		this.showApprovalModal = false;
		this.removeUrlParams();
	}

	closeRejectModal() {
		this.showRejectModal = false;
		this.removeUrlParams();
	}

	getStation() {
		let stationToReturn;
		if (this.userFacilities) {
			this.userFacilities.forEach(group => {
				if (group.companyList) {
					group.companyList.forEach(company => {
						if (company.stations) {
							company.stations.forEach(station => {
								if (station.Id == this.approvalStationId) {
									stationToReturn = station;
								}
							});
						}
					});
				}
			});
		}

		return stationToReturn;
	}

	getUser() {
		let userToReturn;

		return userToReturn;
	}

	get rejectModalMessage() {
		let modalMessage = "Are you sure you want to reject ";
		let approvalStation = this.getStation();
		let approvalContactRole = this.getUser();

		if (approvalStation || this.approvalStationId) {
			modalMessage += approvalStation ? approvalStation.Name + "?" : " this station?";
		} else if (approvalContactRole || this.approvalContactRoleId) {
			modalMessage += approvalContactRole ? approvalContactRole.Name + "?" : " this user?";
		} else {
			modalMessage = "Are you sure you want to confirm this reject action?";
		}

		return modalMessage;
	}




	get approvalModalImage(){
		if(this.approvalSuccess){
			return this.CHECKED_IMAGE;
		}else{
			return this.ERROR_IMAGE;
		}
	}

	handleRejectReasonChanged(event) {
		if (this.approvalStationId) {
			this.rejectReasonStation = event.detail.value;
		} else if (this.approvalContactRoleId) {
			this.rejectReasonContactRole = event.detail.value;
		}
	}

	handleConfirmReject() {
		this.isLoading = true;
		this.showRejectModal = false;

		if (this.approvalStationId) {
			this.rejectStation(true);
		} else if (this.approvalContactRoleId) {
			this.rejectContactRole(true);
		}
	}

	get showBackToStationProfile(){
		return this.menuItemSelected && this.selectedFacility;
	}

	get selectedFacilityName(){
		let selectedFacilityName = '';
		if(this.selectedFacility){
			this.userFacilities.forEach(group => {
				group.companyList.forEach(company =>{
					if(company.stations){
						company.stations.forEach(station => {
							if(station.Id === this.selectedFacility) selectedFacilityName = station.Name;						
						})
					}
				})
			})
		}
		return selectedFacilityName;

	}

	emptyMenuItemSelected(event){
		event.preventDefault();
		this.menuItemSelected = undefined;
	}
}
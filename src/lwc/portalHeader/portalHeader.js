import { LightningElement, track, wire, api } from 'lwc';

//navigation
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { navigateToPage, getPageName, getParamsFromPage } from 'c/navigationUtils';
import getBreadcrumbs from '@salesforce/apex/PortalBreadcrumbCtrl.getBreadcrumbs';

//notification apex method
import getNotifications from '@salesforce/apex/PortalHeaderCtrl.getNotifications';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import increaseNotificationView from '@salesforce/apex/PortalHeaderCtrl.increaseNotificationView';
import goToManageService from '@salesforce/apex/PortalHeaderCtrl.goToManageService';
import goToOldChangePassword from '@salesforce/apex/PortalHeaderCtrl.goToOldChangePassword';
import redirectChangePassword from '@salesforce/apex/PortalHeaderCtrl.redirectChangePassword';
import getContactInfo from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getPortalServiceId from '@salesforce/apex/PortalServicesCtrl.getPortalServiceId';
import verifyCompleteL3Data from '@salesforce/apex/PortalServicesCtrl.verifyCompleteL3Data';

import redirectfromPortalHeader from '@salesforce/apex/CSP_Utils.redirectfromPortalHeader';

// Toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

//custom labels
import ISSP_Services from '@salesforce/label/c.ISSP_Services';
import CSP_Support from '@salesforce/label/c.CSP_Support';
import ICCS_Profile from '@salesforce/label/c.ICCS_Profile';
import ISSP_MyProfile from '@salesforce/label/c.ISSP_MyProfile';
import CSP_CompanyProfile from '@salesforce/label/c.CSP_CompanyProfile';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';
import CSP_Settings from '@salesforce/label/c.CSP_Settings';
import CSP_LogOut from '@salesforce/label/c.CSP_LogOut';
import PortalName from '@salesforce/label/c.PortalNameRedirect';
import MarkAsRead from '@salesforce/label/c.MarkAsRead_Notification';
import NotificationCenter from '@salesforce/label/c.NotificationCenter_Title';
import ViewDetails from '@salesforce/label/c.ViewDetails_Notification';
import NotificationDetail from '@salesforce/label/c.NotificationDetail_Detail';
import ISSP_Reset_Password from '@salesforce/label/c.ISSP_Reset_Password';

import Announcement from '@salesforce/label/c.Announcements_Notification';
import Tasks from '@salesforce/label/c.Tasks_Notification';
import AllNotifications from '@salesforce/label/c.All_Notifications_Notification';
import CSP_You_Dont_Have_Notifications from '@salesforce/label/c.CSP_You_Dont_Have_Notifications';
import CSP_You_Dont_Have_Announcements from '@salesforce/label/c.CSP_You_Dont_Have_Announcements';
import CSP_You_Dont_Have_Tasks from '@salesforce/label/c.CSP_You_Dont_Have_Tasks';


// Accept Terms
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import User_ToU_accept from '@salesforce/schema/User.ToU_accepted__c';
import AccountSector from '@salesforce/schema/User.Contact.Account.Sector__c';
import Portal_Registration_Required from '@salesforce/schema/User.Portal_Registration_Required__c';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import { registerListener,unregisterAllListeners,fireEvent } from 'c/pubsub';


export default class PortalHeader extends NavigationMixin(LightningElement) {
	@track displayAcceptTerms = true;
	@track displayRegistrationConfirmation = false;
	@track displayFirstLogin = false;
	@track firstLogin = false;
	level2RegistrationTrigger = 'homepage';
	level3LMSRegistrationTrigger = 'homepage';
	isTriggeredByRequest = false;

	@track registrationlevel = ''; //FOR LMS L3
	@track thirdLoginLMS = false; //FOR LMS L3
	@track serviceid = ''; //FOR LMS L3
	@wire(CurrentPageReference) pageRef;

	@wire(getRecord, { recordId: Id, fields: [User_ToU_accept, Portal_Registration_Required] })
	WiregetUserRecord(result) {
		if (result.data) {
			let user = JSON.parse(JSON.stringify(result.data));
			let acceptTerms = user.fields.ToU_accepted__c.value;
			let registrationRequired = user.fields.Portal_Registration_Required__c.value;
			let currentURL = window.location.href;
			if (currentURL.includes(this.labels.PortalName)) {
				this.displayAcceptTerms = acceptTerms;
			}

			console.log('displayAcceptTerms: ', this.displayAcceptTerms);
			console.log('firstLogin: ', this.firstLogin);
			console.log('registrationRequired: ', registrationRequired);

			if(acceptTerms == true){
				if(registrationRequired == true){
					this.displayRegistrationConfirmation = true;
				}else{
					if(this.firstLogin == true){
						this.displayFirstLogin = true;
					}
				}
			}
		}
	}

	@track displayCompanyTab = false;

/*
	Replaced by getContactInfo() in connectedCallback()

	@wire(getRecord, { recordId: Id, fields: [AccountSector] })
	WiregetAccountSector(result) {
		if (result.data) {
			let user = JSON.parse(JSON.stringify(result.data));
			let sector = user.fields.Contact.value.fields.Account.value.fields.Sector__c.value;

			if (sector === 'General Public') {
				this.displayCompanyTab = false;
			} else {
				this.displayCompanyTab = true;
			}
		}
	}*/


	_labels = {
		ISSP_Services,
		CSP_Support,
		ICCS_Profile,
		ISSP_MyProfile,
		CSP_CompanyProfile,
		CSP_Cases,
		CSP_Settings,
		CSP_LogOut,
		PortalName,
		MarkAsRead,
		NotificationCenter,
		ViewDetails,
		NotificationDetail,
		Announcement,
		Tasks,
		AllNotifications,
		ISSP_Reset_Password,
		CSP_You_Dont_Have_Notifications,
		CSP_You_Dont_Have_Announcements,
		CSP_You_Dont_Have_Tasks

	};

	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	//links for images
	logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
	servicesIcon = CSP_PortalPath + 'CSPortal/Images/Icons/service-white.svg';
	supportIcon = CSP_PortalPath + 'CSPortal/Images/Icons/support-white.svg';
	profileIcon = CSP_PortalPath + 'CSPortal/Images/Icons/profile-white.svg';
	profileIconBlue = CSP_PortalPath + 'CSPortal/Images/Icons/profile-blue.svg';
	arrowIcon = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-down-white.svg';
	arrowIconBlue = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-down-blue.svg';
	notificationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/notification-white.svg';
	searchWhiteIcon = CSP_PortalPath + 'CSPortal/Images/Icons/searchWhite.svg';

	//notifications
	@track numberOfNotifications;
	@track openNotifications = false;
	@track notification;

	//notification Center Tab
	@track allNotificationTab;
	@track announcementTab;
	@track taskTab;

	//notification counter
	@track notificationCounter = 0;
	@track taskCounter = 0;

	@track notificationsList;
	@track currentURL;
	@track baseURL;
	@track showBackdrop = false;

	//User Type
	@track userAdmin;

	//style variables for notifications
	@track headerButtonNotificationsContainerStyle;
	@track headerButtonNotificationsCloseIconStyle;
	@track headerButtonNotificationsStyle;
	@track notificationNumberStyle;
	@track openNotificationsStyle;
	@track displayBodyStyle;
	@track displayNotificationStyle;
	//
	@track checkDisplayBodyStyle

	// MODAL
	@track openmodel = false;

	@track mainBackground = 'z-index: 9999;';

	@track buttonServiceStyle = 'slds-m-left_xx-large slds-p-left_x-small headerBarButton buttonService';
	@track buttonSupportStyle = 'slds-m-left_medium slds-p-left_x-small headerBarButton buttonSupport';

	@track trackedIsInOldPortal;

	@api
	get isInOldPortal() {
		return this.trackedIsInOldPortal;
	}
	set isInOldPortal(value) {
		this.trackedIsInOldPortal = value;
	}

	@wire(CurrentPageReference)
	getPageRef() {
		this.handlePageRefChanged();
	}

	connectedCallback() {
		console.log('portalHeader - connectedCallback - INIT' );

		registerListener('fireL3Registration', this.handleMissingData, this);

		isAdmin().then(result => {
			this.userAdmin = result;
		});

		let pageParams = getParamsFromPage();
		if(pageParams !== undefined && pageParams.firstLogin !== undefined){
			if(pageParams.firstLogin == "true"){
				this.firstLogin = true;
				this.displayFirstLogin = true;
			}
		}

		console.log('portalHeader - connectedCallback - Start L3' );
		console.log('portalHeader - connectedCallback - pageParams:' + pageParams);
		console.log('portalHeader - connectedCallback - pageParams.firstLogin:' + pageParams.firstLogin);
		console.log('portalHeader - connectedCallback - pageParams.lms:' + pageParams.lms);
		// FOR LMS L3
		if(pageParams !== undefined &&
			(pageParams.lms !== undefined || pageParams.lmsflow !== undefined ) ){
				console.log('portalHeader - connectedCallback - IF L3' );
			if(pageParams.lms === 'yas'){
				console.log('portalHeader - connectedCallback - IF LMS YAS' );
				if(pageParams.firstLogin == "true"){
					this.thirdLoginLMS = true;
					this.registrationlevel = '3';
					this.displayFirstLogin = true;
				}else{
					console.log('portalHeader - getPortalServiceId - start' );
					getPortalServiceId({ serviceName: 'Training Platform (LMS)' })
						.then(serviceId => {
							console.log('service Id: ' + serviceId);
							verifyCompleteL3Data({serviceId: serviceId})
							.then(result => {
								console.log('verifyCompleteL3Data result: ', result);
								if(result){
									console.log('window.open!! ');
									window.open('https://getyardstick.com');
								}
								else{
									this.thirdLoginLMS = true;
									this.registrationlevel = '3';
									this.displayFirstLogin = true;
								}
								// this.toggleSpinner();
							})
							.catch(error => {
								this.error = error;
							});
						})
						.catch(error => {
							this.error = error;
						});

				}

			}else if(pageParams.lmsflow.indexOf('flow') > -1){
				console.log('portalHeader - connectedCallback - IF LMS FLOW' );
				this.thirdLoginLMS = true;
				this.registrationlevel = '3';
				this.displayFirstLogin = false;
				this.triggerThirdLevelRegistrationLMS();
			}

		}
		console.log('portalHeader - connectedCallback - pageParams.firstLogin:' + pageParams.firstLogin);
		console.log('portalHeader - connectedCallback - pageParams.lms:' + pageParams.lms);
		console.log('portalHeader - connectedCallback - pageParams.lmsflow:' + pageParams.lmsflow);
		console.log('portalHeader - connectedCallback - this.firstLogin:' + this.firstLogin);
		console.log('portalHeader - connectedCallback - this.thirdLoginLMS:' + this.thirdLoginLMS);
		console.log('portalHeader - connectedCallback - this.registrationlevel:' + this.registrationlevel);
		this.redirectChangePassword();

		getNotifications().then(result => {
			this.baseURL = window.location.href;
			let resultsAux = JSON.parse(JSON.stringify(result));

			resultsAux.sort(function (a, b) {
				return new Date(b.createdDate) - new Date(a.createdDate);
			});

			this.notificationsList = resultsAux;

			let notificationCounter = 0;
			let taskCounter = 0;
			resultsAux.forEach(function (element) {
				if (element.type === 'Notification') {
					if (element.viewed === false) {
						notificationCounter++;
					}
				} else {
					taskCounter++;
				}
			});

			this.notificationCounter = notificationCounter;
			this.taskCounter = taskCounter;

			this.announcementTab = this.labels.Announcement + ' (' + notificationCounter + ')';
			this.taskTab = this.labels.Tasks + ' (' + taskCounter + ')';
			this.allNotificationTab = this.labels.AllNotifications + ' (' + (notificationCounter + taskCounter) + ')';
			this.numberOfNotifications = (notificationCounter + taskCounter);

			if (this.numberOfNotifications === "0" || this.numberOfNotifications === 0) {
				this.notificationNumberStyle = 'display: none;';
			}

		});

		getContactInfo().then(result => {
			this.displayCompanyTab = !result.Account.Is_General_Public_Account__c;
		});
	}

	disconnectedCallback() {
		// unsubscribe from inputChangeEvent event
		unregisterAllListeners(this);
	}

	handleMissingData(payload) {
		this.displayThirdLevelRegistrationLMS = true;
		this.serviceid = payload;
		console.log('CHECK payload service Id: ' + this.serviceid);
	}

	redirectChangePassword() {
		redirectChangePassword().then(result => {
			if (result) {
				let location = window.location.href;
				location = String(location);
				let terms = JSON.parse(JSON.stringify(this.displayAcceptTerms));
				if (!location.includes("ISSP_ChangePassword") && terms === true) {
					this.navigateToChangePassword();
				}
			}
		});
	}


	//navigation methods
	navigateToOtherPage(pageNameToNavigate) {
		this[NavigationMixin.Navigate]({
			type: "standard__namedPage",
			attributes: {
				pageName: pageNameToNavigate
			},
		});
	}

	// Check if we are in the Old/New Portal
	navigationCheck(pageNameToNavigate, currentService) {

		if (this.trackedIsInOldPortal) {
			redirectfromPortalHeader({ pageName: currentService }).then(result => {
				window.location.href = result;
			});
		} else {
			this.navigateToOtherPage(pageNameToNavigate);
		}

	}

	navigateToHomePage() {
		this.navigationCheck("home", "");
		//this.navigateToOtherPage("home");
	}

	navigateToServices() {
		this.navigationCheck("services", "services");
		//this.navigateToOtherPage("services");
	}

	navigateToSupport() {
		this.navigationCheck("support", "support");
		//this.navigateToOtherPage("support");
	}

	navigateToMyProfile() {
		this.navigationCheck("my-profile", "my-profile");
	}

	navigateToCompanyProfile() {
		this.navigationCheck("company-profile", "company-profile");
	}

	navigateToCases() {
		this.navigationCheck("cases-list", "cases-list");
	}

	navigateToSettings() {
		//this.navigateToOtherPage("");
	}

	navigateToChangePassword() {
		goToOldChangePassword({}).then(results => {
			window.open(results, "_self");
		});

	}

	navigateToCspChangePassword() {
		this.navigationCheck("changePassword", "changePassword");
	}

	//user logout
	logOut() {
		navigateToPage("/secur/logout.jsp?retUrl=" + CSP_PortalPath + "login");
	}


	//method to change the style when the user clicks on the notifications
	toggleNotifications() {

		this.openNotifications = !this.openNotifications;

		if (this.openNotifications) {
			this.headerButtonNotificationsContainerStyle = 'background-color: #ffffff; z-index: 10000; padding-right: 6px; padding-left: 6px;';
			this.headerButtonNotificationsCloseIconStyle = 'display: flex; align-items: center; justify-content: center;';
			this.headerButtonNotificationsStyle = 'display: none;';
			this.notificationNumberStyle = 'display: none;';
			this.openNotificationsStyle = 'display: block;';
			this.showBackdrop = true;
			this.displayBodyStyle = 'width: 35vw';
			this.displayNotificationStyle = 'width: 100%'
		} else {
			this.headerButtonNotificationsContainerStyle = 'z-index: 100;';
			this.headerButtonNotificationsCloseIconStyle = 'display: none; ';
			this.headerButtonNotificationsStyle = 'display: block;';
			this.notificationNumberStyle = (this.numberOfNotifications === 0 ? 'display: none;' : 'display: block;');
			this.openNotificationsStyle = 'display: none;';
			this.showBackdrop = false;
		}

	}

	onClickAllNotificationsView(event) {
		this.notificationsView(event);
	}

	openmodal(event) {
		this.notificationsView(event);

		this.mainBackground = "z-index: 10004;";
		this.openmodel = true;
	}

	closeModal() {
		this.mainBackground = "z-index: 10000;";
		this.openmodel = false;
	}

	notificationsView(event) {
		let selectedNotificationId = event.target.dataset.item;

		let notificationsListAux = JSON.parse(JSON.stringify(this.notificationsList));

		let notification = notificationsListAux.find(function (element) {
			if (element.id === selectedNotificationId) {
				return element;
			}
			return null;
		});

		this.notification = notification;

		if (notification.type === 'Notification') {
			increaseNotificationView({ id: selectedNotificationId })
				.then(results => {

					if (!notification.viewed) {
						let notificationCounter = this.notificationCounter;
						let taskCounter = this.taskCounter;

						notificationCounter--;
						this.numberOfNotifications = notificationCounter + taskCounter;
						this.announcementTab = this.labels.Announcement + ' (' + notificationCounter + ')';
						this.allNotificationTab = this.labels.AllNotifications + ' (' + (notificationCounter + taskCounter) + ')';
						this.notificationCounter = notificationCounter;

						this.numberOfNotifications = (notificationCounter + taskCounter);
						if (this.numberOfNotifications === "0" || this.numberOfNotifications === 0) {
							this.notificationNumberStyle = 'display: none;';
						}

						notification.viewed = true;
						notification.styles = 'readNotification';
						this.notificationsList = notificationsListAux;
					}

				})
				.catch(error => {
					const showError = new ShowToastEvent({
						title: 'Error',
						message: 'An error has occurred: ' + error.getMessage,
						variant: 'error',
					});
					this.dispatchEvent(showError);

				});
		} else if (notification.type === "Portal Service") {

			let params = {};
			params.serviceId = notification.id;
			this.currentURL = window.location.href;

			if (this.currentURL.includes(this.labels.PortalName)) {
				this[NavigationMixin.GenerateUrl]({
					type: "standard__namedPage",
					attributes: {
						pageName: "manage-service"
					}
				})
					.then(url => navigateToPage(url, params));
			} else {
				goToManageService().then(results => {
					navigateToPage(results, params);
				});
			}
		} else {
			navigateToPage("company-profile?tab=contact&contactName=" + notification.contactName);
		}
	}

	goToAdvancedSearchPage() {
		this.navigationCheck("advanced-search", "advanced-search");
	}

	handlePageRefChanged() {
		let pagename = getPageName();
		if (pagename) {
			getBreadcrumbs({ pageName: pagename })
				.then(results => {
					let breadCrumbs = JSON.parse(JSON.stringify(results));
					if (breadCrumbs && breadCrumbs[1] && (breadCrumbs[1].DeveloperName === 'services' || breadCrumbs[1].DeveloperName === 'support')) {
						if (breadCrumbs[1].DeveloperName === 'services') {
							this.buttonServiceStyle = `${this.buttonServiceStyle} selectedButton`;
							this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
						} else if (breadCrumbs[1].DeveloperName === 'support') {
							this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
							this.buttonSupportStyle = `${this.buttonSupportStyle} selectedButton`;
						}
					} else {
						this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
						this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
					}
				});
		} else {
			this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
			this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
		}
	}

	acceptTerms() {

		const fields = {};
		fields.Id = Id;
		fields.ToU_accepted__c = true;
		fields.Date_ToU_accepted__c = new Date().toISOString();
		const recordInput = { fields };

		updateRecord(recordInput)
			.then(() => {
				this.displayAcceptTerms = true;
				this.redirectChangePassword();
			});

	}

	confirmRegistration() {
		const fields = {};
		fields.Id = Id;
		fields.Portal_Registration_Required__c = false;
		const recordInput = { fields };

		updateRecord(recordInput)
			.then(() => {
				window.location.reload();
				//this.displayRegistrationConfirmation = false;
		});
	}

	close() {
		if (this.openNotifications) {
			this.openNotifications = true;
			this.toggleNotifications();
		}

	}

	hideRegistration() {
		this.displayRegistrationConfirmation = false;
	}

	hideFirstLogin() {
		this.displayFirstLogin = false;
		this.firstLogin = false;
	}

	get totalNotification() {
		let toReturn = true;
		if (this.notificationsList !== undefined) {
			let notList = JSON.parse(JSON.stringify(this.notificationsList));
			if (notList !== undefined && notList.length > 0) {
				notList.forEach(function (element) {
					if (element.type === 'Notification' || element.type === 'Portal Service' || element.type === 'Portal Access')
						toReturn = false;
				});
			}
		}
		return toReturn;
	}

	get announcementNumber() {
		let toReturn = true;
		if (this.notificationsList !== undefined) {
			let notList = JSON.parse(JSON.stringify(this.notificationsList));
			if (notList !== undefined && notList.length > 0) {
				notList.forEach(function (element) {
					if (element.type === 'Notification')
						toReturn = false;
				});
			}
		}
		return toReturn;
	}

	get taskNumber() {
		let toReturn = true;
		if (this.notificationsList !== undefined) {
			let notList = JSON.parse(JSON.stringify(this.notificationsList));
			if (notList !== undefined && notList.length > 0) {
				notList.forEach(function (element) {
					if (element.type === 'Portal Service' || element.type === 'Portal Access')
						toReturn = false;
				});
			}
		}
		return toReturn;
	}

	@track displaySecondLevelRegistration = false;

	triggerSecondLevelRegistration(){
		this.displayFirstLogin = false;
		this.firstLogin = false;
		this.displaySecondLevelRegistration= true;
	}

	closeSecondLevelRegistration(){
		this.displaySecondLevelRegistration = false;
	}

	secondLevelRegistrationCompleted(){
		navigateToPage(CSP_PortalPath,{});
	}

	@track displayThirdLevelRegistrationLMS = false;

	triggerThirdLevelRegistrationLMS(){
		this.displayFirstLogin = false;
		this.firstLogin = false;
		this.displayThirdLevelRegistrationLMS= true;
	}

	closeThirdLevelRegistrationLMS(){
		this.displayThirdLevelRegistrationLMS = false;
	}

	ThirdLevelRegistrationLMSCompleted(){
		navigateToPage(CSP_PortalPath,{});
	}
}
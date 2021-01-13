import { LightningElement, track, api} from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getNotificationsFromUser_ from "@salesforce/apex/CW_NotificationsController.getNotificationsFromUser";
import setDismiss_ from "@salesforce/apex/CW_NotificationsController.setDismissNotifications";
import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";
import labels from "c/cwOneSourceLabels";

const REMOTE = 'remote';
const VALIDATION = 'validation';
const PENDING_APPROVAL = 'pending approval';
const STATION_MANAGER = 'station manager';
const FACILITY_MANAGER = 'facility manager';
const COMPANY_ADMIN = 'company admin';
const AUDIT_SCHEDULE = 'audit schedule';
const STATION_MANAGERS = 'station managers';
const STATION = 'station';
const PENDING_USER_APPROVAL = 'pending user approval';
const MY_REQUESTS = 'my requests';
const PENDING_STATION_APPROVAL = 'pending station approval';
const CONFLICT = 'conflict';
const STATION_CREATION = 'creation';
const APPROVED = 'approved';
const REJECTED = 'rejected';
export default class CwPrivateNotifications extends LightningElement {
	initialized = false;

	icons = resources + "/icons/";
	
	label = labels.labels();

	@track data = [];
	@track showModal = false;
	@track modalMessage = "When you perform an action, this modal appears with extra info.";
	checkedImage = this.icons + 'ic_tic_green.svg';
	ERROR_IMAGE = this.icons + 'error-icon.svg';
	@track modalImage = this.checkedImage;
	

	@api companyAdmins;
	@api companyInfo;
	@api userInfo;
	@api gxaUrl;

	@track viewAll = false;
	registerToShow = 5;

	@api viewAlertsEvents;
	
	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;
			this.viewAlertsEvents = this.viewAlertsEvents === 'true';
			this.getNotificationsFromUser(this.viewAlertsEvents);
		}
	}

	closeModal() {
		this.showModal = false;
	}

	get dataInformed() {
		return this.data.length > 0;
	}
	
	
	get labelNewNotifications(){
		let label="";
		if(this.dataInformed){
			label = this.dataSize + " ";
			label += this.dataSize > 1 ? this.label.icg_news_alerts_of : this.label.new_notification;
		}
		return label;
	}

	get dataSize(){
		return this.dataInformed ? this.data.length : 0;
	}
	

	getNotificationsFromUser(viewAlertsEvents) {
		getNotificationsFromUser_({viewAlertsEvents})
			.then(result => {
				let parseResult = JSON.parse(JSON.stringify(result));
				this.data = JSON.parse(parseResult);
				if(this.data){
					this.checkRedirectionAndDate();
				}
			})
			.catch(err => {
				console.error('Error during fetch of notifications', err);
				this.modalMessage = this.label.icg_error_message;
				this.modalImage = this.ERROR_IMAGE;
				this.showModal = true;
			});
	}

	notificationStationIsDefined(elem) {
		return elem.Station__c != '' && elem.Station__c != undefined;
	}

	descriptionHasValidValue(description) {
		return description.includes(REMOTE) || description.includes(VALIDATION) ||
		description.includes(PENDING_APPROVAL) ||
		description.includes(STATION_MANAGER) ||
		description.includes(FACILITY_MANAGER) ||
		description.includes(COMPANY_ADMIN) ||
		description.includes(AUDIT_SCHEDULE);
	}

	generateNotificationDestiny(elem, description) {

		let destiny; 
		if(description.includes(PENDING_APPROVAL) && this.notificationStationIsDefined(elem)){
			if (elem.CreatedById === this.userInfo.Id || description.includes(STATION)){
				destiny = MY_REQUESTS;
			}
			else{
				destiny = PENDING_USER_APPROVAL;
			}
		}
		else if(description.includes(STATION_CREATION)){
			if (description.includes(APPROVED)){
				destiny = STATION;
			}
			else{
				destiny = MY_REQUESTS;
			}
		}
		else if(description.includes(CONFLICT)){
			destiny = CONFLICT;
		}
		else if(description.includes(PENDING_APPROVAL)){
			destiny = PENDING_USER_APPROVAL;
		}
		else if(description.includes(AUDIT_SCHEDULE)){
			destiny = AUDIT_SCHEDULE;
		}
		else if(description.includes(COMPANY_ADMIN) || description.includes(STATION_MANAGER) || description.includes(FACILITY_MANAGER)){
			destiny = MY_REQUESTS;
		}                
		else if(description.includes(REMOTE) || description.includes(VALIDATION)){
			destiny = STATION;
		}
		else if(this.notificationStationIsDefined(elem)){
			destiny = STATION;
		}

		return destiny;
	}
	
	checkRedirectionAndDate(){
		getUserInfo().then(result => {
			this.userInfo = JSON.parse(result);

			this.data.forEach(elem=>{
				let description = elem.Short_Description__c.toLowerCase();
				elem.isRedirection = this.notificationStationIsDefined(elem) || this.descriptionHasValidValue(description);

				if(elem.isRedirection){
					elem.destiny = this.generateNotificationDestiny(elem, description);
					elem.isOwner = (elem.CreatedById === this.userInfo.Id) ? true : false;					
				}

				//parse Dates
				let parseDate = new Date(elem.CreatedDate);
				let endDate = parseDate.getDate() + '/' + (parseDate.getMonth()+1) + '/' + parseDate.getFullYear();
				elem.CreatedDate = endDate;

			});
		});
	}

	generateUrl(event, destiny) {

		let url;

		if(destiny === STATION){
			url = '#ID:' + event.currentTarget.getAttribute("data-id");
		}
		else if(destiny === PENDING_STATION_APPROVAL){
			url = '#Pending Facility Approvals';
		}
		else if(destiny === PENDING_USER_APPROVAL){
			url = '#Pending User Approvals';
			
		}
		else if(destiny === STATION_MANAGERS){
			url = '#Station Managers';
			
		} 
		else if(destiny === COMPANY_ADMIN){
			url = '#Company Admins';
			
		}
		else if(destiny === AUDIT_SCHEDULE){
			url = '#Schedule Audits';
		}  
		else if(destiny === CONFLICT){
			url = '#' + this.label.capability_management;
		}
		else if(destiny === MY_REQUESTS){
			url = '#My Requests';
			
		}  
		else if(destiny === REMOTE){
			let description = event.currentTarget.getAttribute("data-description").toLowerCase();
			//redirection depend to the action...
			if(description.includes('granted') || description.includes('approved') || description.includes('accepted')){
				url = '#ID:' + event.currentTarget.getAttribute("data-id");
				
			}
			else if(description.includes('expired') || description.includes('rejected')){
				url = '#Remote Validation History';
				
			}
			else{
				url = this.gxaUrl;
				
			}
		}

		return url;

	}

	handleNavigate(event){
		let destiny = event.currentTarget.getAttribute("data-destiny").toLowerCase();
		let isOwner = event.currentTarget.getAttribute("data-is-owner");
		let url = this.generateUrl(event, destiny);

		if(destiny === STATION || destiny === REMOTE){
			window.location.href = url;
			window.location.reload();
		}
		else{
			if(destiny === CONFLICT){
				const selectedItemEvent = new CustomEvent("preselectedstation", {
					detail: event.currentTarget.getAttribute("data-id")
				});
		
				// Dispatches the event.
				this.dispatchEvent(selectedItemEvent);	
			}
			
			const selectedItemEvent = new CustomEvent("menuitemselection", {
				detail: url.replace('#','')
			});
	
			// Dispatches the event.
			this.dispatchEvent(selectedItemEvent);
		}

		if(event.currentTarget.getAttribute("data-read") === 'false'){
			this.setDismissSelected(event);
		}
		
	}

	get dataLimit() {
		let shouldLimitData = this.dataSize > this.registerToShow && !this.viewAlertsEvents && !this.viewAll;
		return shouldLimitData ? this.data.filter((notification, index) => index < this.registerToShow) : this.data;
	}

	setDismiss(notificationList,mode) {
		setDismiss_({notificationList})
			.then(result => {
				let parsedRes = JSON.parse(result);
				if (parsedRes.success) {
					if(mode === 'all'){
						this.modalMessage = "Operation successfull.";
						this.modalImage = this.checkedImage;
						this.showModal = true; 
					}
					
					this.getNotificationsFromUser(this.viewAlertsEvents);
				} else {
					this.modalMessage = parsedRes.message;
					this.modalImage = this.ERROR_IMAGE;
					this.showModal = true; 
				}
				
			})
			.catch(err => {
				console.error('Error', err);
				this.modalMessage = this.label.icg_error_message;
				this.modalImage = this.ERROR_IMAGE;
				this.showModal = true;
			});
	}


	setDismissSelected(event){
		let notificationId = event.target.dataset.key;
		let position = event.target.dataset.position;

		this.dataLimit[position].Read__c = true;
		this.data = this.data.map(element => element.Read__c = element.Id === notificationId);

		let notificationList = [];
		notificationList.push(notificationId);

		this.setDismiss(notificationList, 'selected');

	}

	setDismissAll(event){
		let notificationList = [];
		this.data.forEach(function(row){
			notificationList.push(row.Id);
		});

		this.setDismiss(notificationList,'all');
	}

	setViewAll(event){
		let view = event.target.dataset.view;
		this.viewAll = view;
	}
}
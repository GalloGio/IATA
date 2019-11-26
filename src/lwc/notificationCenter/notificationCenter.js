import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//IMPORTS FROM APEX CLASSES
import getPortalUsers from '@salesforce/apex/UserController.getAllCspCommunityUsers';
import countCspCommunityUsers from '@salesforce/apex/UserController.countCspCommunityUsers';
import getAccountCoutries from '@salesforce/apex/NotificationCenterController.getAccountCoutries';
import getItemsPerPage from '@salesforce/apex/UserController.getItemsPerPage';
import getSiteCompleteUrl from '@salesforce/apex/OneIdUtils.getSiteCompleteUrl';
import getPortalServices from '@salesforce/apex/NotificationCenterController.getPortalServicesName';
import getNotificationTemplates from '@salesforce/apex/NotificationCenterController.getInformationNotificationTemplates';
import sendNotification from '@salesforce/apex/NotificationCenterController.sendNotification';
import sendNotificationToAll from '@salesforce/apex/NotificationCenterController.sendNotificationToAll';



const columns = [
	{ label: 'Name', fieldName: 'Name', type: 'text' },
	{ label: 'Contact', fieldName: 'Link', type: 'url', typeAttributes: { label : { fieldName: 'ContactName' }, target: '_blank' }},
	{ label: 'Sector', fieldName: 'Sector', type: 'text' },
	{ label: 'Category', fieldName: 'Category', type: 'text' },
	{ label: 'Country', fieldName: 'Country', type: 'text'},
	{ label: 'Preferred Language', fieldName: 'PreferredLanguage', type: 'text' },
	{ label: 'Send notification', type: 'button', initialWidth: 130, typeAttributes: {name: 'notify', label: 'Notify', title: 'Notify', variant: 'info' }},
	//{ label: 'Show', type: 'button', initialWidth: 130, typeAttributes: {name: 'show', label: 'show', title: 'show', variant: 'success' }},
];

const ERROR = 'error';
const SUCCESS = 'success';
const INFO = 'info';
const GENERAL_ERROR_MESSAGE = 'Some error occurred while getting the list of users';
const FILTERED = "FILTERED";
const SELECTED = "SELECTED";

let whoToNotify = '';
let sendEmail = false;

export default class NotificationCenter extends LightningElement {

	//Table data
	@track data = [];
	@track columns = columns;
	@track orgUrl = '';

	//Table control variables
	@track ITEMS_PER_PAGE = 50;
	@track totalRecords;
	@track currentPageRecords = [];
	@track auxiliarSelected = [];
	@track selectedRows = [];
	@track page = 1;
	@track previousPage = 1;
	@track maxpage = 1;

	//Table filters
	@track category = '';
	@track sector = '';
	@track countries = [];
	@track AuxCountries = [];
	@track portalService = '';
	@track portalServices = [];
	@track countrylist = [];
	aplyingFilters = false;

	//modal
	@track showModal = false;
	@track notificationTempaltes = [];

	async connectedCallback(){
		try{

			//async calls
			this.ITEMS_PER_PAGE = await getItemsPerPage();
			this.orgUrl = await getSiteCompleteUrl();
			let services = JSON.parse(JSON.stringify(await getPortalServices()));
			let notTemplates = JSON.parse(JSON.stringify(await getNotificationTemplates()));
			let countrylistAux = JSON.parse(JSON.stringify(await getAccountCoutries()));

			//portal services setup
			let aux = [];
			services.forEach( row =>{
				aux.push({label: row.Name, value: row.Name });
			});
			this.portalServices = aux;

			//notifications template setup
			aux = [];
			notTemplates.forEach( row =>{
				aux.push({label: row.Identifier__c, value: row.Name });
			});
			this.notificationTempaltes = aux;

			aux = [];
			countrylistAux.forEach( row => {
				if(row.Name){
					aux.push({label: row.Name, value: row.Name });
				}
			});
			this.countrylist = aux;
		}catch(e){
			this.showToast(ERROR,'Error',GENERAL_ERROR_MESSAGE);
		}
	}

	//#region DATA LOADING

	@wire(countCspCommunityUsers,{category: '$category',sector: '$sector',countries: '$countries',portalService:'$portalService'})
	wiredTotalRecors({error,data}){
		if (data) {
			this.totalRecords = data;
			this.maxPage = Math.ceil(data/this.ITEMS_PER_PAGE);
		} else if (error) {
			this.showToast(ERROR,'Error',GENERAL_ERROR_MESSAGE);
		}
	}

	@wire(getPortalUsers,{category: '$category',sector: '$sector',countries: '$countries',portalService:'$portalService',page:'$page'})
	wiredUsers({error,data}) {
		let currentPageIds = [];
		if (data) {
			data = JSON.parse(JSON.stringify(data));
			data.forEach(row => {
				row.ContactName = row.Contact.Name;
				row.PreferredLanguage = row.Contact.Preferred_Language__c;
				row.Sector = row.Contact.Account.Sector__c;
				row.Category = row.Contact.Account.Category__c;
				row.Country = row.Contact.Account.IATA_ISO_Country__r ? row.Contact.Account.IATA_ISO_Country__r.Name : '';
				row.Link = this.orgUrl + '/' + row.ContactId;
				currentPageIds.push(row.ContactId);
			});
			this.data = data;
			this.selectedRows = this.auxiliarSelected;
			this.currentPageRecords = currentPageIds;
			if (data.length < 1) {
				this.showToast(ERROR,'Note!','There are no users to be displayed');
			}else if(this.aplyingFilters){
				this.showToast(SUCCESS,'Success','filters applied successfully!');
			}
			this.aplyingFilters = false;
		} else if (error) {
			this.page = this.previousPage;
			this.showToast(ERROR,'Error',GENERAL_ERROR_MESSAGE);
		}
	}

	//#endregion

	handleCountrySelection(event){
	   this.AuxCountries = JSON.parse(JSON.stringify(event.detail.value));
	}

	handleFilterTable(){
		//reset navigatiton
		this.page = 1;
		this.previousPage = 1;

		let sector =  this.template.querySelector("[data-filter='sector']").value;
		let category =  this.template.querySelector("[data-filter='category']").value;
		let countryList =  this.template.querySelector(".contryListField").value;
		let portalService = this.template.querySelector(".portalService").value;
		portalService = portalService ? portalService : '';

		let contriesEqual = true;
		if(countryList.length !== this.countries.length){
			contriesEqual = false;
		}else if(countryList.length !== 0){
			for(let i = 0; i < countryList.length; i++){
				if(countryList[i] !== this.countries[i]){
					contriesEqual = false;
					break;
				}
			}
		}

		if(this.category !== category || this.sector !== sector || !contriesEqual  || this.portalService != portalService){
			this.category = category;
			this.sector = sector;
			this.countries = countryList ? countryList : [];
			this.portalService = portalService ? portalService : '';
			this.aplyingFilters = true;
		} else {
			this.showToast(ERROR,'Error','No filter was changed');
		}
	}

	handleClearFilters(){
		this.template.querySelector(".inputSector").value = '';
		this.template.querySelector(".inputCategory").value = '';
		this.template.querySelector(".portalService").value = '';
		this.template.querySelector(".contryListField").value = '';
	}

	handleSubmitForm(event){
		event.preventDefault();
	}

	//#region TABLE NAVIGATION

	handleTableNavigation(event){
		this.auxiliarSelected = this.selectedRows;
		this.selectedRows = [];

		if(event.target.label === 'Next'){
			if(! this.isLastPage){
				this.previousPage = this.page;
				this.page += 1;
			}else{
				this.showToast(ERROR,'Error','There are no Next Page');
			}
		} else if (event.target.label === 'Previous'){
			if(! this.isFirstPage){
				this.previousPage = this.page;
				this.page -= 1;
			}else{
				this.showToast(ERROR,'Error','No are no Previous Page');
			}
		}
	}

	get isFirstPage(){
		return  this.page === 1;
	}

	get isLastPage(){
		return this.page === this.maxPage;
	}

	get offset(){
		return (this.page - 1) * this.ITEMS_PER_PAGE;
	}

	handleRowSelection(event){

		let aux = this.selectedRows;
		let selected = event.detail.selectedRows;

		//remove all records belonging to current page
		aux = aux.filter(elem => {
			return !this.currentPageRecords.includes(elem);
		});

		//add the ones from current page that are selected
		selected.forEach( elem => {
			if(!aux.includes(elem.ContactId)){
				aux.push(elem.ContactId);
			}
		});

		this.selectedRows = aux;
	}

	//#endregion

	handleRowAction(event){
		const row = event.detail.row;
		whoToNotify = row.ContactId;
		sendEmail = false;
		this.showModal = true;
	}

	handleNotifySelected(){
		if(this.selectedRows.length < 1){
			this.showToast(ERROR,'Error!',"There are no selected rows!");
			return;
		}
		whoToNotify = SELECTED;
		sendEmail = false;
		this.showModal = true;
	}

	handleNotifyAll(){
		if(this.currentPageRecords.length  < 1){
			this.showToast(ERROR,'Error!',"There are no one to contact!");
			return;
		}
		whoToNotify = FILTERED;
		sendEmail = false;
		this.showModal = true;
	}

	handleModalClose(){
		this.showModal = false;
		sendEmail = false;
	}

	handleSendEmailChange(event){
		sendEmail = event.target.checked;
	}

	async handlerSendNotification(){
		let notification =  this.template.querySelector(".notificationTemplatePicker").value;
		if(!notification){
			this.showToast(ERROR,'Error!',"You have to select a notification template!");
			return;
		}

		if(whoToNotify === FILTERED || whoToNotify === SELECTED){
			this.showToast(INFO,'Notice!',"This operation might take a while!");
		}

		let contacts =  [];
		let result;

		if( whoToNotify === FILTERED){
			try{
				result = await sendNotificationToAll({notificationTemplate: notification, sendEmail:sendEmail, category: this.category,sector: this.sector ,countries: this.countries,portalService: this.portalService});
			}catch(error){
				this.showToast(ERROR,'Error!',"Some error occurred and no notifications were created!");
			}
		} else {
			if(whoToNotify === SELECTED){
				contacts = JSON.parse(JSON.stringify(this.selectedRows));
			} else {
				contacts.push(whoToNotify);
			}

			try{
				result = await sendNotification({notificationTemplate: notification, sendEmail:sendEmail, contactIds: contacts});
			}catch(error){
				this.showToast(ERROR,'Error!',"Some error occurred and no notifications were created!  ##EXCEPTION");
			}
		}

		if(result === 'TEMPLATE ERROR'){
			this.showToast(ERROR,'Notice!',"The notification template was not found!");
		} else if (result === 'none'){
			this.showToast(ERROR,'Error!',"Some error occurred and no notifications were created! ##NONE##");
		} else if(result === 'all'){
			this.showToast(SUCCESS,'Success!',"All notifications were sent!")
		}else if(result ==='some'){
			this.showToast(ERROR,'Error!',"Some error occurred and only some notifications were created!");
		}else if (result === 'batch'){
			this.showToast(INFO,'Notice!','Due to the number of notification you\'re trying to create this proccess can take a while and the notifications will be created in the next minutes');
		}

		this.sendEmail = false
		this.showModal = false;
	}

	showToast(variant, title, message){
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
	}

	toggleFilters(){
		let elem = this.template.querySelector(".FiltersBox");

		if(elem.hasAttribute('hidden')){
			elem.removeAttribute("hidden");
			this.template.querySelector(".chevDown").setAttribute("hidden", true);
			this.template.querySelector(".chevUp").removeAttribute("hidden");
		}else{
			elem.setAttribute("hidden", true);
			this.template.querySelector(".chevDown").removeAttribute("hidden");
			this.template.querySelector(".chevUp").setAttribute("hidden", true);
		}
	}
}
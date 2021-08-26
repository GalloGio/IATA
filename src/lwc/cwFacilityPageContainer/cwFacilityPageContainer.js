import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import _getResults from "@salesforce/apex/CW_SearchEngine.getInfo";
import getUserRole from "@salesforce/apex/CW_Utilities.getUserRole";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getCompanyAdmins from "@salesforce/apex/CW_Utilities.getCompanyAdminContactsFromAccountId";
import getFacilityManagers from "@salesforce/apex/CW_Utilities.getStationManagersContactRoleDetails";
import becomeFacilityAdmin from "@salesforce/apex/CW_Utilities.becomeFacilityAdmin";
import becomeCompanyAdmin from "@salesforce/apex/CW_Utilities.becomeCompanyAdminFromStation";

import getOpsHierarchyNameFromStationId from '@salesforce/apex/CW_Utilities.getOpsHierarchyNameFromStationId';
import getOpsHierarchyNameFromAccountId from '@salesforce/apex/CW_Utilities.getOpsHierarchyNameFromAccountId';

import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";
import setFacilityInfo_ from "@salesforce/apex/CW_FacilityContactInfoController.setFacilityInfo";
import { refreshApex } from "@salesforce/apex";
import updateFacility_ from "@salesforce/apex/CW_CreateFacilityController.updateFacility";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import labels from "c/cwOneSourceLabels";
import { loadScript } from "lightning/platformResourceLoader";
import { shMenu, sIcons, shButtonUtil, prButton, shareBtn, connectFacebook, connectTwitter, connectLinkedin, sendMail, concatinateFacilityAddress, concatinateAddressString, removeLastCommaAddress, getImageString, getIataSrc, getIataTooltip, areRequiredFieldsFilled } from "c/cwUtilities";
import fetchAirports from "@salesforce/apex/CW_LandingSearchBarController.fetchAirports";
import getOnAirportStations from '@salesforce/apex/CW_CreateFacilityController.getOnAirportStations';
import getNearestAirportForFacility from "@salesforce/apex/CW_CreateFacilityController.getNearestAirportForFacility";

export default class CwFacilityPageContainer extends NavigationMixin(LightningElement) {
	_facilityid;
	label = labels.labels();

	icons = resources + "/icons/";
	CHECKED_IMAGE = this.icons + 'ic_tic_green.svg';
	ERROR_IMAGE = this.icons + 'error-icon.svg';

	@track tooltipObject;
	@track tooltipToDisplay = "";
	
	@api areatype;

	@api
	get facilityid() {
		return this._facilityid;
	}
	_editMode = false;
	@api
	get editMode() {
		return this._editMode;
	}

	set facilityid(value) {
		this._facilityid = value;
		let urlParams = this.getQueryParameters();
		if (urlParams.pending) {
			this.isPendingApproval = urlParams.pending;
		}
		this.getData(this._facilityid);
		this.getUserRoleJS(this._facilityid);
		this.isSaveCapabMangmn=false;
	}
	@track facility;
	@track rawFacility;
	@api saveOnTheFly = false;
	@track facilityToCompare;
	@track detailCertFacility;
	@track results;
	@track validLocation = false;
	@track locations;
	@track zoomLevel = 14;
	@track userRole;
	@track companyAdmins = [];
	@track companyAdminsChecked = false;
	@track hierarchyChecked = false;
	@track sameHierarchyGroup = false;
	@track facilityManagers = [];
	@track userInfo;
	@track showModal = false;
	@track modalMessage = "When you perform an action, this modal appears with extra info.";
	@track modalImage = this.CHECKED_IMAGE;
	@track editAirport = true;
	checkedImage = this.CHECKED_IMAGE;
	@track loaded;
	@track overviewValid = true;
	@track contactInfoValid = true;
	@track editOn = false;
	@track editOnAirport = false;
    @track handlingServicesCpm = {isCreateView: false , isSummary: false};

	//  Params to manage child component cwHandlerDetail
	@track airlineHandlers;
	@track readOnlyHandlersAirline = true;

	@track cargoHandlers = [];
	@track readOnlyHandlersCargo = true;

	@track rampHandlers = [];
	@track readOnlyHandlersRamp = true;
	
	@track airportSearchValue = '';
	@track predictiveValues;
	@track hqSearchValue = '';
	@track selectedAirport;
	@track availableAirports = [];
	airportsFetched = false;
	@track isairportboxfocus;
	
	sendActionToSave = false;
	isEditSectionCapabMangment = false;
	isSaveCapabMangmn = false;
	@track isSaveGeoLocation = false;
	isPendingApproval = false;
	isSendActionToCancel = false;
	listCapabilitiesRow = [];
	logoInfoObject;
	geoLocationInfoObject;
	logoImage;

	icons = resources + "/icons/";

	//icons
	shareblue = this.icons + "ic-share--blue.svg";
	printblue = this.icons + "ic-print--blue.svg";
	twiter = this.icons + "social-twitter.svg";
	facebook = this.icons + "social-facebook.svg";
	linkedin = this.icons + "social-linkedin.svg";
	email = this.icons + "social-email.svg";

	searchbylocation = this.icons + "search-by-location.svg";
	urlResultPage;
	urlSharePage;
	urlStationProfile;
	initialized = false;

	@api spinnerPosition = 'position-fixed';
	@api hideOverlay = false;
	@api overlayColor;

	hiddenCargoStations;
	hiddenRampHandlers;

	

	printpage() {
		this.template.querySelector("c-cw-facility-contact-info").openSectionsOpeningHours();
		setTimeout(() => {
			window.print();
		}, 500);
	}

	rawUserInfo;
	@wire(getUserInfo, {})
	wiredUserInfo(result) {
		this.rawUserInfo = result;
		if (result.data) {
			this.userInfo = JSON.parse(result.data);
		}
	}
	// Injects the page reference that describes the current page
	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;

		if (this.connected) {
			// We need both the currentPageReference, and to be connected before
			// we can use NavigationMixin
			this.generateUrls();
		} else {
			// NavigationMixin doesn't work before connectedCallback, so if we have
			// the currentPageReference, but haven't connected yet, queue it up
			this.generateUrlOnConnected = true;
		}
	}
	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}

	@wire(getURL, { page: "URL_ICG_SocialMediaShare" })
	wiredURLSharePage({ data }) {
		if (data) {
			this.urlSharePage = data;
		}
	}

	@wire(getURL, { page: "URL_ICG_FacilityPage" })
	wiredURLStationProfilePage({ data }) {
		if (data) {
			this.urlStationProfile = data;
		}
	}
	
	connectedCallback() {
		if (window.LZString === undefined) {
			Promise.all([loadScript(this, resources + "/js/lz-string.js")]);
		}
	}

	renderedCallback() {
		if (!this.initialized) {
			
			this.initialized = true;
			let id = this._facilityid;
			if (!id) {
				let urlParams = this.getQueryParameters();
				if (urlParams.pending) {
					this.isPendingApproval = urlParams.pending;
				}

				if (urlParams.eid) {
					id = urlParams.eid.replace(/[^a-zA-Z0-9]/g, "");
					this.getData(id);
					this.getUserRoleJS(id);
				}
			} else {
				this.getUserRoleJS(this._facilityid);
			}
			this.opsHierarchyUser(this._facilityid);
		}
		
		this.addEventListeners();
			
		if(this.availableAirports.length === 0 && !this.airportsFetched){
			fetchAirports().then(data =>{
				this.availableAirports = data;
				this.airportsFetched = true;
			})
		}
	}

	get getStyleListAir() {
		let style = "padding: 0px 0px 5px 5px; width: 30px;";
		if (this.facility) {
			if (this.facility.ListAir_icon) {
				style = style + " display: inline;";
			} else {
				style = style + "display: none;";
			}
		}
		return style;
	}

	get listAirIcon() {
		let iconair = false;
		if (this.facility) {
			if (this.facility.ListAir_icon) {
				iconair = true;
			}
		}
		return iconair;
	}

	get getIATAIcon() {
		if (this.facility) {
			return getIataSrc(this.facility.IATA_icon, this.facility.recordTypeDevName, this.facility.location, this.facility.locationClass, resources);
		}
		return "";
	}

	get getStyleImg() {
		let style = "";
		if (this.facility) {
			if (this.facility.IATA_icon) {
				let image = getIataSrc(this.facility.IATA_icon, this.facility.recordTypeDevName, this.facility.location, this.facility.locationClass, resources);
				let cssClass = " align-middle ml-2";
				if (image.includes("cns-endorsed-agent")) {
					cssClass += " height-20";
				} else if (image.includes("iata-logo-cut")) {
					cssClass += " width-27";
				}

				style = style + cssClass;
			} else {
				style = style + "hidden";
			}
		}
		return style;
	}

	get showListAirlines() {
		return this.facility.recordTypeDevName === "Ramp_Handler" || this.facility.recordTypeDevName === "Cargo_Handling_Facility";
	}

	get showOperatingAirlines() {
		return this.facility.recordTypeDevName === "Airport_Operator";
	}

	get showAirlines(){
		return this.showListAirlines || this.showOperatingAirlines;
	}

	get showOperatingCHFandRampH() {
		return this.facility.recordTypeDevName === "Airport_Operator" || this.facility.recordTypeDevName === "Airline";
	}

	get showHandlingServices(){
		return this.facility.recordTypeDevName === "Ramp_Handler";
	}

	mapresize() {
		let databox = this.template.querySelector(".databox");
		let maincol = this.template.querySelector(".main-col");
		let map = this.template.querySelector(".map-size");

		let heightcol = maincol.offsetHeight;

		map.style.height = heightcol + "px";
	}

	backToURL() {
		let q = window.localStorage.getItem("q1");
		let url = this.urlResultPage;
		if (q) url += "?q=" + q;
		window.open(url, "_self");
	}

	getData(id) {
		this.isSaveCapabMangmn=false;
		this.isSaveGeoLocation = false;

		const searchCriterion = {
			operator: "=",
			value: id,
			obj: "ICG_Account_Role_Detail__c",
			field: "Id",
			fields: ["Id"]
		};

		let searchWrapper = [searchCriterion];

		this.getResults(searchWrapper);
	}

	getResults(searchWrapper) {
		this.dispatchEvent(new CustomEvent('loading'));
		this.loaded = false;
		_getResults({ attributes: JSON.stringify(searchWrapper), getOpeningHours: true, getHandledAirlines: true, orderByOnAirport: false, isPendingApproval: this.isPendingApproval })
			.then(result => {
				this.results = result ? JSON.parse(result) : null;
				if (this.results && this.results.length > 0) {
					this.facility = this.results[0].facility;
					this.facility.lstAvailableCertifications = this.results[0].lstAvailableCertifications;
					this.detailCertFacility = this.results[0].lstAvailableCertifications;
					
					if (this.facility.nearestAirport.name != null && this.facility.nearestAirport.city != null){
						 this.selectedAirport = {value: this.facility.nearestAirport.name, label: this.facility.nearestAirport.city + ' ' +this.facility.nearestAirport.name};
					}
					
					this.cargoHandlers = [];
					this.rampHandlers = [];
					this.airlineHandlers = this.facility.handledAirlines;
					if (this.airlineHandlers.length == 0) {
						this.template.querySelectorAll("c-cw-handler-detail").forEach(element => {
							if(element.handlerType === 'airline'){
								element.setDefaultHandlerData();
							}
						});
					}
					if(this.facility.recordTypeDevName === "Airport_Operator" || this.facility.recordTypeDevName === "Airline"){
						this.facility.onAirportStations.forEach(facility => {
							this.populateOperatingStations(facility);
						});
					}
					else if(this.facility.recordTypeDevName === "Ramp_Handler"){
						
					}
					
					this.updateLocationValid();
					this.getCompanyAdminsFromDB(this.facility.companyId);
					this.getFacilityManagersFromDB(this.facility.Id);
					this.setLoadedStatus();
					
					this.rawFacility = JSON.parse(JSON.stringify(this.facility));
				} else {
					this.setLoadedStatus();
				}
				this.loaded = true;
			})
			.catch(error => {
				this.setLoadedStatus();
			});
	}

	setLoadedStatus(){
		this.loaded = true;
		this.dispatchEvent(new CustomEvent('loaded'));
	}

	getCompanyAdminsFromDB(companyId){
		getCompanyAdmins({ accountId: companyId})
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
		this.companyAdminsChecked = true;
		
	}

	getFacilityManagersFromDB(facilityId){
		getFacilityManagers({ stationId: facilityId })
		.then(fmanagers => {
			if (fmanagers) {
				this.facilityManagers = fmanagers;
			} else {
				this.facilityManagers = [];
			}
		})
		.catch(err => {
			this.facilityManagers = [];
		});
	}

	populateOperatingStations(station){
		switch (station.recordTypeDevName) {
			case "Cargo_Handling_Facility":
				this.cargoHandlers.push(station);
				break;
			case "Ramp_Handler":
				this.rampHandlers.push(station);
				break;
			default:
				break;
		}
	}

	updateLocationValid() {
		if (this.checkIfValidLocation()) {
			this.validLocation = true;
			this.updateLocation();
		}
	}

	checkIfValidLocation() {
		const location = this.facility.location.location;
		return location.Latitude && location.Longitude;
	}

	updateLocation() {
		this.locations = [this.facility.location];
	}

	getQueryParameters() {
		var params = {};
		var search = location.search.substring(1);

		if (search) {
			if (search.substring(search.length - 1) === "=") {
				search = search.substring(0, search.length - 1);
			}
			try {
				params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
					return key === "" ? value : decodeURIComponent(value);
				});
			} catch (error) {
				console.error(error);
			}
		}

		return params;
	}

	get getCompanyTypeImage() {
		let imageString = "";
		if (this.facility) {
			imageString = getImageString(this.facility.recordTypeDevName);
		}
		return resources + "/icons/company_type/" + imageString;
	}

	get getLogoUrl() {
		if (this.facility.logoUrl) {
			return this.facility.logoUrl;
		}

		return resources + "/img/no-image.svg";
	}

	get sharetxt(){
		let txttoshare = this.facility.accountName + ' - ' +  this.facility.name + ", " + this.facility.addressCity + ", " + this.facility.location.location.Country + " - IATA ONE Source";
		return txttoshare;
	}
	

	searchAddress() {
		let address = concatinateAddressString(this.facility.addressStreetNr) + concatinateAddressString(this.facility.secondAddress) + concatinateFacilityAddress(this.facility);
		address = removeLastCommaAddress(address);
		this[NavigationMixin.Navigate](
			{
				type: "standard__webPage",
				attributes: {
					url: "https://www.google.com/maps/search/" + address
				}
			},
			true // Replaces the current page in your browser history with the URL
		);
	}

	getUserRoleJS(facId) {
		getUserRole({ facilityId: facId }).then(data => {
			let tmpEditMode = false;
			if (data) {
				this.userRole = data;
				tmpEditMode = this.userRole === "Company Admin" || this.userRole === "Facility Manager";
			}
			this._editMode = tmpEditMode;
			this.loaded = true;
		})
		.catch(err => {
			this.modalMessage = this.label.icg_error_message;
			this.modalImage = this.ERROR_IMAGE;
			this.showModal = true;
			this.loaded = true;
		});
	}

	becomeFacilityAdminJS(event) {
		this.loaded = false;
		let facilityId = event.target.dataset.facility;
		becomeFacilityAdmin({
			companyId: this.facility.companyId,
			facilityIds: facilityId,
			contactId: this.userInfo.ContactId
		})
			.then(resp => {
				let parsedRes = JSON.parse(resp);
				this.modalMessage = parsedRes.message;
				this.modalImage = this.CHECKED_IMAGE;
				this.refreshInfo();
				this.showModal = true;
			})
			.catch(err => {
				this.modalMessage = this.label.icg_error_message;
				this.modalImage = this.ERROR_IMAGE;
				this.showModal = true;
				this.loaded = true;
			});
	}
	becomeCompanyAdminJS() {
		this.loaded = false;
		becomeCompanyAdmin({ 
			stationId: this.facility.Id,
			companyId: this.userInfo.AccountId,
			contactId: this.userInfo.ContactId
		})
			.then(resp => {
				let parsedRes = JSON.parse(resp);
				if (parsedRes.success) {
					this.modalMessage = this.label.icg_thank_you_iata_contact;
					this.modalImage = this.CHECKED_IMAGE;
					this.refreshInfo();
				} else {
					this.modalMessage = parsedRes.message;
					this.modalImage = this.ERROR_IMAGE;
					this.loaded = true;
				}
				this.showModal = true;
			})
			.catch(err => {
				this.modalMessage = this.label.icg_error_message;
				this.modalImage = this.ERROR_IMAGE;
				this.showModal = true;
				this.loaded = true;
			});
	}
	refreshInfo() {
		refreshApex(this.rawUserInfo);
		this.getUserRoleJS(this.facility.Id);
	}
	closeModal() {
		this.showModal = false;
	}

	get isGuest() {
		return this.userRole === "Guest" || !this.userRole;
	}
	get isCompanyAdmin() {
		return this.userRole === "Company Admin";
	}
	get isFacilityManager() {
		return this.userRole === "Facility Manager";
	}
	get isNotAssigned() {
		return this.userRole === "Not assigned";
	}
	
	get showCompanyAdminsButton() {		
		if(this.companyAdminsChecked === true && this.hierarchyChecked === true){
			let showCompanyBtn = false;
			if (!this.isCompanyAdmin && !this.isFacilityManager && this.companyAdmins.length < 1 && this.sameHierarchyGroup === true){
				showCompanyBtn = true
			}
			return showCompanyBtn;
		}
	}

	get showFacilityManagersButton() {		
		if(this.companyAdminsChecked === true && this.hierarchyChecked === true){
			let showFaciManBtn = false;
			if (!this.isCompanyAdmin && !this.isFacilityManager && this.companyAdmins.length > 0){
				showFaciManBtn = true;
			}
			else if (!this.isCompanyAdmin && !this.isFacilityManager && this.companyAdmins.length < 1 && this.sameHierarchyGroup === false){
				showFaciManBtn = true;
			}
			return showFaciManBtn;
		}
	}

	opsHierarchyUser(faciId){
		getOpsHierarchyNameFromStationId({ stationId: faciId }).then(data => {
			if (data) {
				getOpsHierarchyNameFromAccountId({ accountId: this.userInfo.AccountId }).then(data2 => {
					if (data2) {
						this.hierarchyChecked = true;
						if(data == data2){
							this.sameHierarchyGroup = true;
						}	
					}
				})
				.catch(err => {
					console.error('getOpsHierarchyNameFromAccountId Error : ' +  err);
				});	
			}
		})
		.catch(err => {
			console.error('getOpsHierarchyNameFromStationId Error : ' + err);
		});
	}
	

	get shouldShowBecomeButton(){
		if(this.companyAdminsChecked === true  && this.hierarchyChecked === true){
			return (this.showFacilityManagersButton || this.showCompanyAdminsButton);
		}
	}

	get shouldShowAdminManagerLabels(){
		return (this.isCompanyAdmin || this.isFacilityManager);
	}

	get facilitywidecol() {
		let widecol = "col-md-12 col-no-padding col-lg-9 col-xl-9 col-sm-12 col-xs-12";
		if (this._facilityid) {
			widecol = "col-md-12 col-no-padding-left col-lg-9 col-xl-9 col-sm-12 col-xs-12";
		}
		return widecol;
	}

	get facilitymarginrow() {
		let marginrow = "row mt-3 padding-side-responsive";
		if (this._facilityid) {
			marginrow = "row-no-margin-left mt-3 padding-side-responsive";
		}
		return marginrow;
	}

	get isreadonly() {
		return !this.editMode;
	}

	handleCapabilityDataLoaded(event) {
		this.facilityToCompare = JSON.parse(JSON.stringify(this.facility));
		this.facilityToCompare.capabilities = event.detail.data;
		this.sendActionToSave=false;
	}

	shareButton = false;

	sharemenu() {
		this.shareButton = shMenu(this.shareButton);
	}

	get shareIcons() {
		return sIcons(this.shareButton);
	}

	get shareButton() {
		return shButtonUtil(this.shareButton);
	}

	get printButton() {
		return prButton(this.shareButton);
	}

	get shButton() {
		return shareBtn(this.shareButton);
	}

	get url() {
		return window.location.href;
	}

	get shareUrl(){
		let tmpurl = this.urlSharePage + "?stationid=" + this.facility.Id + "&title="+ this.sharetxt + "&imageUrl="+ this.getLogoUrl;
		tmpurl = tmpurl.replace('/s/','/apex/');
		return tmpurl;
	}

	conFacebook() {
		connectFacebook(encodeURIComponent(this.shareUrl));
	}
	conTwitter() {
		connectTwitter(encodeURIComponent(this.shareUrl), this.sharetxt);
	}
	conLinkedin() {
		connectLinkedin(encodeURIComponent(this.shareUrl));		
	}
	conEmail() {
		sendMail("", "Facility Info " + this.sharetxt, encodeURIComponent(this.url));
	}

	handleSecondAddressChange(event) {
		let name = event.target.name;
		let newValue = event.target.value;
		let oldValue = this.facility[name];

		if (["secondAddress"].includes(name) && oldValue !== newValue) {
			this.setFacilityInfo(this.facility.Id, name, newValue);
		}
		event.currentTarget.blur();
	}

	handleFacilityNameChange(event) {
		let name = event.target.name;
		let newValue = event.target.value;
		let oldValue = this.facility[name];

		if(newValue != ""){
			if (["name"].includes(name) && oldValue !== newValue) {
				this.setFacilityInfo(this.facility.Id, name, newValue);
			}
			event.currentTarget.blur();
		}else{
			this.showToast("Error", "Station name cannot be removed", "error");
			event.target.value = oldValue;
		}
	}




	get facilityAddress() {
		let address = concatinateAddressString(this.facility.addressStreetNr) + concatinateAddressString(this.facility.secondAddress) + concatinateFacilityAddress(this.facility);
		return removeLastCommaAddress(address);
	}

	get facilityStreetNr() {
		return concatinateAddressString(this.facility.addressStreetNr);
	}

	get facilityAdressSecondPart() {
		let address = concatinateFacilityAddress(this.facility);
		return removeLastCommaAddress(address);
	}

	setFacilityInfo(id, key, value) {
		this.loaded = false;
		this.facility = JSON.parse(JSON.stringify(this.facility));
		if (this.saveOnTheFly) {
			setFacilityInfo_({ id, key, value })
				.then(response => {
					if (response.result.status === "OK") {
						this.facility[response.result.key] = response.result.value;
					}
					this.loaded = true;
					this.facility = JSON.parse(JSON.stringify(this.facility));
				})
				.catch(error => {
					this.loaded = true;
				});
		} else {
			this.facility[key] = value;
			this.loaded = true;
			this.facility = JSON.parse(JSON.stringify(this.facility));
		}
	}

	updateFacility(event) {
		this.facility = event.detail;	
	}

	handleSendListRows(event){
		this.listCapabilitiesRow = event.detail.data;
	}

	handleSaveSuccesfull(event){
		this.sendActionToSave = false;
		this.isEditSectionCapabMangment = false;
		this.handleSaveChanges();
	}

	handleSaveAction(event){
		this.isSaveCapabMangmn = event.detail.data;
		this.isEditSectionCapabMangment = event.detail.data;
	}

	get isSaveActionCapabMangemnt(){
		return this.isSaveCapabMangmn === true;
	}

	get isSendActionToSave(){
		let actionSave = {
			isSave: this.sendActionToSave,
			listRow : this.listCapabilitiesRow
		}
		return actionSave;
	}

	get isDirty(){
		let rawFacilityCopy = JSON.stringify(this.rawFacility);
		let facilityCopy = JSON.stringify(this.facility);
		rawFacilityCopy = rawFacilityCopy.replace(/null/g, '""');
		facilityCopy = facilityCopy.replace(/null/g, '""');
		const differencesDetected = rawFacilityCopy != facilityCopy;
		return (this.contactInfoValid && this.overviewValid && differencesDetected && this.isPrivateArea) || this.isSaveActionCapabMangemnt || this.isSaveGeoLocation;
	}
	
	get isPrivateArea() {
		return this.areatype === "private";
	}

	handleSaveChanges() {
		if (this.readOnlyHandlersAirline === false || this.readOnlyHandlersCargo === false || this.readOnlyHandlersRamp === false) {
			this.template.querySelectorAll("c-cw-handler-detail").forEach(element => {
				if (element.handlerType === 'airline' && this.readOnlyHandlersAirline === false){
					element.saveHandlerItems();
				}
				else if (element.handlerType === 'cargo' && this.readOnlyHandlersCargo === false){
					element.saveHandlerItems();
				}
				else if (element.handlerType === 'ramp' && this.readOnlyHandlersRamp === false){
					element.saveHandlerItems();
				}
			});
		} else if(this.isEditSectionCapabMangment === true){
			if(!areRequiredFieldsFilled(this.listCapabilitiesRow)){
				this.showToast("Error", "Complete required fields", "error");
				return;
			}
			this.sendActionToSave = true;
		}
		else{
			let saveBtn = this.template.querySelector('[data-tosca="saveBtn"]');
			if(saveBtn){
				const btnClasses = saveBtn.classList.value;
				if (btnClasses.includes("disabled")) {
					this.showToast("Warning", this.label.icg_facility_invalid_info, "warning");
					return;
				}
			}

			if (this.facility.supportedLanguages && Array.isArray(this.facility.supportedLanguages)) {
				this.facility.supportedLanguages = JSON.parse(JSON.stringify(this.facility.supportedLanguages))
					.sort()
					.join(";");
			}

			let inHouseServices = '';
			let thirdPartyServices = '';

			this.facility.inHouseServices.forEach(item => {
				inHouseServices += item.api +';';
			});

			this.facility.thirdPartyServices.forEach(item => {
				thirdPartyServices += item.api +';';
			});

			let objToSave = {
				Number_of_Employees__c: this.facility.NumberEmployees,
				Overall_Facility_Size_m2__c: this.facility.recordTypeDevName === 'Cargo_Handling_Facility' ? this.facility.FacilitySize : 0,
				Overall_Airport_Size__c: this.facility.recordTypeDevName === 'Airport_Operator' ? this.facility.overallAirportSize : 0,
				Fleet__c: this.facility.fleet,
				Is_On_Airport__c: this.facility.IsOnAirport,
				Is_Direct_Ramp_Access__c: this.facility.DirectRampAccess,
				Road_Feeder_Services__c: this.facility.roadFeederServices,
				Customer_Service_Email__c: this.facility.email,
				Customer_Service_Phone_Number__c: this.facility.phone,
				Website__c: this.facility.website,
				Online_Booking_System_Link__c: this.facility.onlineBooking,
				Opening_Hours__c : JSON.stringify(this.facility.openingHours),
				Available_Languages__c: this.facility.supportedLanguages,
				General_Cargo__c: this.facility.generalCargo,
				Live_Animals__c: this.facility.liveAnimals,
				Dangerous_Goods__c: this.facility.dangerousGoods,
				Airmail__c: this.facility.airmail,
				Perishables__c: this.facility.perishables,
				Pharmaceuticals__c: this.facility.pharmaceuticals,
				Secondary_Address__c: this.facility.secondAddress,
				name: this.facility.name,
				Id: this.facility.Id,
				Pilot_Information__c: this.facility.pilotInformation,
				In_House_Services__c: this.facility.recordTypeDevName == 'Ramp_Handler' ? inHouseServices : '',
				Third_Party_Services__c: this.facility.recordTypeDevName == 'Ramp_Handler' ? thirdPartyServices : ''
			}
				
			if (this.facility.nearestAirportObj != null){
				this.facility.Nearest_Airport__c = this.facility.nearestAirportObj;
				objToSave.Nearest_Airport__c = this.facility.nearestAirportObj;
			}
			
			let jsonInput = JSON.stringify(objToSave);

			this.loaded = false;
			updateFacility_({ jsonInput, logoInfo: JSON.stringify(this.logoInfoObject), geoLocationInfo: JSON.stringify(this.geoLocationInfoObject) })
				.then(response => {
					if (response.result.status == "OK") {
						this.showToast("Success", this.label.icg_successful_save_facility, "success");

						let facilityId = this.facilityid ? this.facilityid : this.facility.Id;
						if(facilityId){
							this.getData(facilityId);
							if(this.logoInfoObject){
								this.editOn = false;
							}
							this.loaded = true;
						}
						else{
							this.loaded = true;
						}
					} else if (response.result.status == "error") {
						this.showToast("Error", this.label.icg_error_update_facility, "error");
						this.loaded = true;
					}
				})
				.catch(error => {
					this.loaded = true;
				});
			this.editOn = false;
			this.editOnAirport = false;

			this.template.querySelectorAll('.cmpEditable').forEach(elem =>{
				elem.editOff();
			})

		}
	}

	manageChildEvent(event) {
		let eventData = event.detail
		if (eventData.error) {
			this.showToast("Error", this.label.icg_error_update_facility, "error");
			return;
		}
		
		if (eventData.name === 'save') {
			this.saveChildEvent(eventData);
		} else if (eventData.name === 'changeReadOnly') {
			this.changeReadOnlyChildEvent(eventData);
		} else if (eventData.name === 'selectItem') {
			this.onSelectItemChildEvent(eventData);
		}
	}
	saveChildEvent(eventData) {
		// Save event
		if (eventData.name === 'save' && eventData.handlerType === 'airline') {
			this.readOnlyHandlersAirline = true;
		}
		if (eventData.name === 'save' && eventData.handlerType === 'cargo') {
			this.readOnlyHandlersCargo = true;
		}
		if (eventData.name === 'save' && eventData.handlerType === 'ramp') {
			this.readOnlyHandlersRamp = true;
		}
		if (eventData.name === 'save' && this.readOnlyHandlersAirline === true && this.readOnlyHandlersCargo === true && this.readOnlyHandlersRamp === true) {
			this.handleSaveChanges();
		}
	}
	changeReadOnlyChildEvent(eventData) {
		// Change read only event
		if (eventData.name === 'changeReadOnly' && eventData.handlerType === 'airline') {
			this.readOnlyHandlersAirline = eventData.isReadOnly;
		}
		if (eventData.name === 'changeReadOnly' && eventData.handlerType === 'cargo') {
			this.readOnlyHandlersCargo = eventData.isReadOnly;
		}
		if (eventData.name === 'changeReadOnly' && eventData.handlerType === 'ramp') {
			this.readOnlyHandlersRamp = eventData.isReadOnly;
		}
	}
	onSelectItemChildEvent(eventData) {
		// On select item event
		if (eventData.name === 'selectItem' && eventData.handlerType === 'airline') {
			this.updateHandlers(this.airlineHandlers, eventData);
			this.setFacilityInfo(this.facility.Id, "handledAirlines", "newSelectedAirlines");
		}
		if (eventData.name === 'selectItem' && (eventData.handlerType === 'cargo' || eventData.handlerType === 'ramp')) {
			if (eventData.handlerType === 'cargo') {
				this.updateHandlers(this.cargoHandlers, eventData);
			} else if (eventData.handlerType === 'ramp') {
				this.updateHandlers(this.rampHandlers, eventData);
			}
			this.setFacilityInfo(
				this.facility.Id, 
				"handled" + eventData.handlerType.charAt(0).toUpperCase() + eventData.handlerType.slice(1) + "Stations", "new" + eventData.handlerType.charAt(0).toUpperCase() + eventData.handlerType.slice(1) + "Stations");
		}
	}

	updateHandlers(handlerData, eventData){
		let found = false;
		for (let cont = 0; cont < handlerData.length && found === false; cont++) {
			if (handlerData[cont].value === eventData.itemSelected.value) {
				handlerData[cont].selected = eventData.itemSelected.selected;
				found = true;
			}
		}
		if (found === false) {
			handlerData.push(eventData.itemSelected);
		}
	}

	hideBarCancelSave(){
		this.isSaveCapabMangmn=false;
		this.isSaveGeoLocation = false;
		this.isSendActionToCancel=true;
		this.geoLocationInfoObject = undefined;
	}

	cancelChanges() {
		this.hideBarCancelSave();	
		refreshApex(this.getData(this._facilityid));
	}

	get saveBtnCss() {
		if (this.contactInfoValid && this.overviewValid) {
			return "btn btn-primary-blue save-btn mr-2";
		}

		return "btn btn-primary-blue save-btn mr-2 disabled-filter";
	}

	updateContactInfoValidData(event) {
		this.contactInfoValid = event.detail;
	}

	updateOverviewValidData(event) {
		this.overviewValid = event.detail;
	}

	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

	tooltipText() {
		if (this.facility && this.label) {
			return getIataTooltip(this.facility.IATA_icon, this.facility.recordTypeDevName, this.facility.location, this.facility.locationClass, this.label, this.facility.typeDevName);
		}

		return "";
	}

	showPopover(event) {
		let item = event.currentTarget.dataset.item;		
		const text = this.tooltipText();
		this.tooltipToDisplay = item;

		let containerDiv = this.template.querySelector('[data-tosca="' + item + '"]');
		let bounds = containerDiv.getBoundingClientRect();
		let marginLeftDivider = (text.indexOf(this.label.icg_cns_endorsed_agent) > -1)? 3 : 5.5;
		const marginLeft = -(bounds.width / marginLeftDivider);
		const marginTop = bounds.height * 1.2;
		let tooltipObject = {
			item: item,
			text: text,
			marginLeft: marginLeft,
			marginTop: marginTop
		}		
		this.tooltipObject = tooltipObject;
	}

	hidePopover() {
		this.tooltipToDisplay = "";
		this.tooltipObject = null;
	}

	get maincolclass(){
		let classmcol="row col-xl-11 col-lg-11 offset-lg-1 offset-xl-1 col-md-12 mt-4";
		if(this.facilityid){
			classmcol="row col-xl-12 col-lg-12 col-md-12 mt-4 row-no-margin-left";
		}
		return classmcol;
	}

	get spinnerOverlay (){
		return !this.hideOverlay;
	}

	showInput(){
		this.editOn = !this.editOn;
	}

	setFileInfo(file, base64Data) {
		let fileInfo = {};
		if (file) {
			fileInfo = {
				fileName: file.name,
				base64Data: base64Data,
				contentType: file.type
			};
		}
		return fileInfo;
	}

	setLogoPreview(event) {
		let logoInput = this.template.querySelector('[id*="logoimage"]');
		//that means we have the input file element
		if (logoInput) {
			if (event){ 
				this.logoImage = logoInput.files;
			}
			else{
				logoInput.files = this.logoImage;
			}
			if (logoInput.files && logoInput.files[0]) {
				let reader = new FileReader();
				reader.onload = e => {
					this.template.querySelector('[id*="logopreview"]').setAttribute("src", e.target.result);
					this.logoInfoObject = this.setFileInfo(logoInput.files[0], e.target.result.match(/,(.*)$/)[1]);
					
				};
				let name = event.target.name;
				this.setFacilityInfo(this.facility.Id, name, 'newlogo');
				reader.readAsDataURL(logoInput.files[0]);

			} else {
				this.template.querySelector('[id*="logopreview"]').setAttribute("src", "");
				this.logoInfoObject = this.setFileInfo(null, null);
			}	
		} else {
			if (this.logoImage && this.logoImage[0]) {
				let reader = new FileReader();
				reader.onload = e => {
					this.template.querySelector('[id*="logopreview"]').setAttribute("src", e.target.result);
				};
				reader.readAsDataURL(this.logoImage[0]);
			}
		}
	}


	showInputAirport(event){
		this.editOnAirport = !this.editOnAirport;
		if(this.editOnAirport){
			this.editAirport = false;
		}else{
			this.editAirport = true;
		}
	}

	setDefaultImg(event){
		event.target.src = resources + "/img/no-image.svg";
	}

	get isAlreadyRequested() {
		return this.userRole === 'Pending Facility Manager' || this.userRole === 'Pending Company Admin'; 
	}

	setGeocoordinates(event) {
		if(!event.detail.initialization){
			let updatedLatitude = event.detail.latitude;
			let updatedLongitude = event.detail.longitude;

			if(this.geoLocationInfoObject && 
				this.geoLocationInfoObject.longitude != updatedLongitude && 
				this.geoLocationInfoObject.latitude != updatedLatitude){
					this.isSaveGeoLocation = true;
				}

			this.geoLocationInfoObject = {
				companyId: this.facility.companyId,
				longitude: updatedLongitude,
				latitude: updatedLatitude
			}
		}
	}

	get addressGeo(){
		return this.facility && this.facility.location && this.facility.location.location ? this.facility.location.location : null;
	}

	setNearestAirport(event){
		event.preventDefault();
		this.selectedAirport = {value: event.detail.item, label: event.detail.value}
		this.getOnAirportStationsJS();

		getNearestAirportForFacility({ nearestAirportCode: event.detail.item}).then(response => {
			this.setFacilityInfo(this.facility.Id, 'nearestAirportObj', response);
		})
		.catch(error => {
			this.showToast("Error", this.label.icg_error_update_facility, "error");
		});
		
		this.airportSearchValue = '';
		this.isairportboxfocus = false;
	}

	getOnAirportStationsJS(){
		this.cargoHandlers = [];
		this.rampHandlers = [];

		getOnAirportStations({
			rtype : this.facility.recordTypeDevName, 
			accountName : this.facility.accountName, 
			airportId : this.selectedAirport.value, 
			accountId : null 
		}).then(res => {
			let parsedRes = JSON.parse(res);
			parsedRes.forEach(station => {
				station.originallySelected = station.selected;
				this.populateOperatingStations(station);
			})
			
			let cmpCHF = this.template.querySelector(".cmpOperatingCHF");
			if (cmpCHF){
				cmpCHF.rawData = this.cargoHandlers;
				cmpCHF.RefreshData();
			}
			
			let cmpRamp = this.template.querySelector(".cmpRampHandlers");
			if (cmpRamp){
				cmpRamp.rawData = this.rampHandlers;
				cmpRamp.RefreshData();
			}
		})
	}

	removeSelectedAirport(event){
		event.preventDefault();
		this.selectedAirport = null;
		this.cargoHandlers = [];
		this.rampHandlers = [];
	}
	
	airportPredictiveSearch(event) {
		this.isairportboxfocus = true;
		this.predictiveValues = [];
		this.airportSearchValue = this.generateValueFromEvent(event, this.airportSearchValue);
		if (this.invalidFilterValue(this.airportSearchValue)) {
			return;
		}

		this.predictiveValues = Object.values(this.availableAirports).filter(entry => {
			return entry.description.toLowerCase().indexOf(this.airportSearchValue.toLowerCase()) > -1 || entry.keyName.toLowerCase().indexOf(this.airportSearchValue.toLowerCase()) > -1;
		})
		.map(element => {
			return {
				value: element.code,
				key: element.code,
				label: element.description,
			}
		});
	}

	invalidFilterValue(value){
		return !value || value.length < 3;
	}

	generateValueFromEvent(event, value){
		return event && event.target ? event.target.value : value ? value : "";
	}
	
	get showNearestAirport() {
		return true;
	}
	
	addEventListeners() {
		//PredictiveBox NearestAiroprt Listener
		let airportbox = this.template.querySelector('[data-tosca="nearestairportinput"]');
		if (airportbox && !this.airportSelectorEventListenersAdded) {
			airportbox.addEventListener("focus", event => {
				this.airportPredictiveSearch();
			});
			airportbox.addEventListener("blur", event => {
				this.isairportboxfocus = false;
			});
			this.airportSelectorEventListenersAdded = true;
		}
	}
}
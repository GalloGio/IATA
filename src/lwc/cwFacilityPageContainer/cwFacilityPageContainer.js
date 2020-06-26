import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import getResults from "@salesforce/apex/CW_SearchEngine.getInfo";
import getUserRole from "@salesforce/apex/CW_Utilities.getUserRole";
import resources from "@salesforce/resourceUrl/ICG_Resources";
// import demoFiles from "@salesforce/resourceUrl/demo_resource";
import getCompanyAdmins from "@salesforce/apex/CW_Utilities.getCompanyadminContactsFromAccountId";
import getFacilityManagers from "@salesforce/apex/CW_Utilities.getStationManagersContactRoleDetails";
import becomeFacilityAdmin from "@salesforce/apex/CW_Utilities.becomeFacilityAdmin";
import becomeCompanyAdmin from "@salesforce/apex/CW_Utilities.becomeCompanyAdmin";
import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";
import saveAirlinesHandled from "@salesforce/apex/CW_HandledAirlinesController.saveAirlinesHandled";
import saveHiddenOperatingStations from "@salesforce/apex/CW_HandledAirlinesController.saveHiddenOperatingStations";
import setFacilityInfo_ from "@salesforce/apex/CW_FacilityContactInfoController.setFacilityInfo";
import { refreshApex } from "@salesforce/apex";
import CHECKED_IMAGE from "@salesforce/resourceUrl/ic_tic_green";
import updateFacility_ from "@salesforce/apex/CW_CreateFacilityController.updateFacility";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import labels from "c/cwOneSourceLabels";

import { shMenu, sIcons, shButtonUtil, prButton, shareBtn, connectFacebook, connectTwitter, connectLinkedin, sendMail, concatinateFacilityAddress, concatinateAddressString, removeLastCommaAddress, getImageString, getIataSrc, getIataTooltip, hideHover } from "c/cwUtilities";

export default class CwFacilityPageContainer extends NavigationMixin(LightningElement) {
	_facilityid;
	label = labels.labels();

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
		this.getData(this._facilityid);
		this.getUserRoleJS(this._facilityid);
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
	@track facilityManagers = [];
	@track userInfo;
	@track showModal = false;
	@track selectedAirlines = [];
	@track onAirportOperatingCHF = [];
	@track onAirportRampH = [];
	@track filterTextAirlines;
	@track filterTextOperatingAirlines;
	@track filterTextOperatingCHF;
	@track filterTextRampH;
	@track modalMessage = "When you perform an action, this modal appears with extra info.";
	@track modalImage = CHECKED_IMAGE;
	@track editAirlines = true;
	@track editCargoHandling = true;
	@track editRampHandlers = true
	checkedImage = CHECKED_IMAGE;
	@track loaded;
	@track overviewValid = true;
	@track contactInfoValid = true;

	//Handled Airlines tracks
	@track toDeleteSelectedAirlines = [];
	@track toAddSelectedAirlines = [];
	@track eventSelectedAirlines = [];
	@track toAddCargoStation = [];
	@track toDeleteCargoStation = [];
	@track toAddRampHandlers = [];
	@track toDeleteRampHandlers = [];
	
	sendActionToSave = false;
	isSaveCapabMangmn = false;
	isPendingApproval = false;
	logoInfoObject;
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

	get getListAirIcon() {
		return resources + "/icons/company_type/cargo_com_airline.jpg";
	}

	get getIATAIcon() {
		if (this.facility) {
			return getIataSrc(this.facility.recordTypeDevName, this.facility.location, this.facility.locationClass, resources);
		}
		return "";
	}

	get getStyleImg() {
		let style = "";
		if (this.facility) {
			if (this.facility.IATA_icon) {
				let image = getIataSrc(this.facility.recordTypeDevName, this.facility.location, this.facility.locationClass, resources);
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
		return this.facility.recordTypeName === "Ramp Handler" || this.facility.recordTypeName === "Cargo Handling Facility";
	}

	get showOperatingAirlines() {
		return this.facility.recordTypeName === "Airport Operator";
	}

	get showAirlines(){
		return this.showListAirlines || this.showOperatingAirlines;
	}

	get showOperatingCHFandRampH() {
		return this.facility.recordTypeName === "Airport Operator" || this.facility.recordTypeName === "Airline";
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
		getResults({ attributes: JSON.stringify(searchWrapper), getOpeningHours: true, getHandledAirlines: true, orderByOnAirport: false, isPendingApproval: this.isPendingApproval })
			.then(result => {
				this.results = result ? JSON.parse(result) : null;
				if (this.results && this.results.length > 0) {
					this.facility = this.results[0].facility;
					this.facility.lstAvailableCertifications = this.results[0].lstAvailableCertifications;
					this.detailCertFacility = this.results[0].lstAvailableCertifications;
					this.selectedAirlines = this.facility.handledAirlines;
					if(this.facility.recordTypeName === "Airport Operator" || this.facility.recordTypeName === "Airline"){
						this.facility.onAirportStations.forEach(facility => {
							this.populateOperatingStations(facility);
						});
					}else{
						this.facility.operatingStations.forEach(facility => {
							this.populateOperatingStations(facility);
						});
					}					
					this.updateLocationValid();
					this.getCompanyAdminsFromDB(this.facility.companyId);
					this.getFacilityManagersFromDB(this.facility.Id);
					this.setLoadedStatus();
					this.rawFacility = JSON.parse(JSON.stringify(this.facility));
				} else {
					this.setLoadedStatus();
				}
				this.isLoading = false;
			})
			.catch(error => {
				console.error("error", error);
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
			console.error("error", err);
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
			console.error("error", err);
			this.facilityManagers = [];
		});
	}

	populateOperatingStations(station){
		switch (station.recordTypeDevName) {
			case "Cargo_Handling_Facility":
				this.onAirportOperatingCHF.push(station);
				break;
			case "Ramp_Handler":
				this.onAirportRampH.push(station);
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
		});
	}

	becomeFacilityAdminJS(event) {
		let facilityId = event.target.dataset.facility;
		becomeFacilityAdmin({
			companyId: this.facility.companyId,
			facilityIds: facilityId,
			contactId: this.userInfo.ContactId
		})
			.then(resp => {
				let parsedRes = JSON.parse(resp);
				if (parsedRes.success) {
					this.modalMessage = "Thank you for your request. IATA will contact you shortly.";
					this.refreshInfo();
				} else {
					this.modalMessage = parsedRes.message;
					this.modalImage = "X";
				}
				this.showModal = true;
			})
			.catch(err => {
				this.modalMessage = err.message;
				this.modalImage = "X";
				this.showModal = true;
			});
	}
	becomeCompanyAdminJS() {
		becomeCompanyAdmin({
			companyId: this.facility.companyId,
			contactId: this.userInfo.ContactId
		})
			.then(resp => {
				let parsedRes = JSON.parse(resp);
				if (parsedRes.success) {
					this.modalMessage = "Thank you for your request. IATA will contact you shortly.";
					this.refreshInfo();
				} else {
					this.modalMessage = parsedRes.message;
					this.modalImage = "X";
				}
				this.showModal = true;
			})
			.catch(err => {
				this.modalMessage = err.message;
				this.modalImage = "X";
				this.showModal = true;
			});
	}
	refreshInfo() {
		refreshApex(this.rawUserInfo);
		this.getUserRoleJS(this.facility.Id);
	}
	closeModal() {
		this.showModal = false;
	}

	setSelectedAirlines(event) {
		if (this.selectedAirlines && event.detail) {
			this.selectedAirlines.forEach(airline => {
				if (!event.detail.find(val => val.value === airline.value)){
					this.toDeleteSelectedAirlines.push(airline.value);
				}
			});
			event.detail.forEach(airline => {
				if (!this.selectedAirlines.find(val => val.value === airline.value)){
					this.toAddSelectedAirlines.push(airline.value);
				}
			});
			this.eventSelectedAirlines = event.detail;
			this.setFacilityInfo(this.facility.Id, 'handledAirlines', 'newSelectedAirlines');
		}
	}
	saveSelectedAirlines(){
		if(this.toAddSelectedAirlines.length > 0 || this.toDeleteSelectedAirlines> 0){
			saveAirlinesHandled({
				addList: JSON.stringify(this.toAddSelectedAirlines),
				deleteList: JSON.stringify(this.toDeleteSelectedAirlines),
				facilityId: this.facility.Id
			})
				.then(result => {
					this.selectedAirlines = this.eventSelectedAirlines;
				})
				.catch(err => {
					this.showToast('Save',"Something went wrong", "error");
				});
		}
	}

	hideCargoStations(event){
		this.hiddenCargoStations = [];
		this.onAirportOperatingCHF.forEach(chf => {
			if (!event.detail.find(val => val.value === chf.value)) {
				this.hiddenCargoStations.push(chf.value);
				if(chf.selected){
					this.toDeleteCargoStation.push(chf.value);
				}
				chf.selected = false;
			}else{
				if(!chf.selected){ 
					this.toAddCargoStation.push(chf.value);
				}
				chf.selected = true;
			}
		});
		this.setFacilityInfo(this.facility.Id, 'handledCargoStations', 'newCargoStations');
	}

	saveCargoStations(){
		if(this.toAddSelectedAirlines.length > 0 || this.toDeleteSelectedAirlines> 0){
			if(this.facility.recordTypeName === 'Airport Operator') {
				this.updateHiddenOperatingStations();
			}
			else if (this.facility.recordTypeName === 'Airline') {
				saveAirlinesHandled({
					addList: JSON.stringify(this.toAddCargoStation),
					deleteList: JSON.stringify(this.toDeleteCargoStation),
					facilityId: this.facility.Id
				})
				.then(result => {
				})
				.catch(err => {
					this.showToast('Save',"Something went wrong saving cargo handling facilities", "error");
				});
			}
		}
	}

	hideRampHandlers(event){
		this.hiddenRampHandlers = [];
		let toRemove = [];
		let toAdd = [];
		this.onAirportRampH.forEach(rmph => {
			if (!event.detail.find(val => val.value === rmph.value)) {
				this.hiddenRampHandlers.push(rmph.value);
				if(rmph.selected){
					this.toDeleteRampHandlers.push(rmph.value);
				}
				rmph.selected = false;
			}else{
				if(!rmph.selected){
					this.toAddRampHandlers.push(rmph.value);
				}
				rmph.selected = true;
			}
		});
		this.setFacilityInfo(this.facility.Id, 'rampHandlers', 'newRampHandlers');
	}
	saveRampHandlers(){
		if(this.toAddRampHandlers.length > 0 || this.toDeleteRampHandlers> 0){
			if(this.facility.recordTypeName === 'Airport Operator') {
				this.updateHiddenOperatingStations();
			}
			else if (this.facility.recordTypeName === 'Airline') {
				saveAirlinesHandled({
					addList: JSON.stringify(this.toAddRampHandlers),
					deleteList: JSON.stringify(this.toDeleteRampHandlers),
					facilityId: this.facility.Id
				})
				.then(result => {
				})
				.catch(err => {
					this.showToast('Save',"Something went wrong saving ramp handlers", "error");
				});
			}
		}
	}

	updateHiddenOperatingStations(){
		let hiddenOperatingStations = this.hiddenCargoStations && this.hiddenCargoStations.length > 0 ? 'OperatingCargo:'+this.hiddenCargoStations.join(',')+'|': '';
		hiddenOperatingStations += this.hiddenRampHandlers && this.hiddenRampHandlers.length > 0 ? 'OperatingRamp:'+this.hiddenRampHandlers.join(',')+'|':'';
		saveHiddenOperatingStations({hiddenOperatingStations : hiddenOperatingStations,facilityId : this.facility.Id}).then(result => {
			if(!result){
				this.showToast("Error", "Something went wrong while updating the facility", "error");
			}
		}).catch(exception => { 
			this.showToast("Error", "Something went wrong while updating the facility", "error");
			console.error(exception);
		});
	}






	filterAirlinesHandled(event) {
		this.filterTextAirlines = event.detail;
	}
	filterOperatingAirlines(event) {
		this.filterTextOperatingAirlines = event.detail;
	}
	filterOperatingCHF(event) {
		this.filterTextOperatingCHF = event.detail;
	}
	filterRampH(event) {
		this.filterTextRampH = event.detail;
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
		if(this.companyAdminsChecked === true){
			let showCompanyBtn = false;
			if (!this.isCompanyAdmin && !this.isFacilityManager && this.companyAdmins.length < 1){
				showCompanyBtn = true
			}
			return showCompanyBtn;
		}
	}

	get showFacilityManagersButton() {		
		if(this.companyAdminsChecked === true){
			let showFaciManBtn = false;
			if (!this.isCompanyAdmin && !this.isFacilityManager && this.companyAdmins.length > 0){
				showFaciManBtn = true;
			}
			return showFaciManBtn;
		}
	}

	get shouldShowBecomeButton(){
		if(this.companyAdminsChecked === true){
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
		this.isLoading = true;
		this.facility = JSON.parse(JSON.stringify(this.facility));
		
		if (this.saveOnTheFly) {
			setFacilityInfo_({ id, key, value })
				.then(response => {
					if (response.result.status === "OK") {
						this.facility[response.result.key] = response.result.value;
					}
					this.isLoading = false;
					this.facility = JSON.parse(JSON.stringify(this.facility));
				})
				.catch(error => {
					this.isLoading = false;
					console.error("error", error);
				});
		} else {
			this.facility[key] = value;
			this.isLoading = false;
			this.facility = JSON.parse(JSON.stringify(this.facility));
		}
	}

	updateFacility(event) {
		this.facility = event.detail;	
	}

	handleSaveAction(event){
		this.isSaveCapabMangmn = event.detail.data;
	}

	get isSaveActionCapabMangemnt(){
		return this.isSaveCapabMangmn === true;
	}

	get isSendActionToSave(){
		return this.sendActionToSave === true;
	}

	get isDirty(){
		let rawFacilityCopy = JSON.stringify(this.rawFacility);
		let facilityCopy = JSON.stringify(this.facility);
		rawFacilityCopy = rawFacilityCopy.replace(/null/g, '""');
		facilityCopy = facilityCopy.replace(/null/g, '""');
		const differencesDetected = rawFacilityCopy != facilityCopy;
		const isPrivateArea = this.areatype === "private";
		return (this.contactInfoValid && this.overviewValid && differencesDetected && isPrivateArea) || this.isSaveActionCapabMangemnt;
	}

	handleSaveChanges() {
		let saveBtn = this.template.querySelector('[data-tosca="saveBtn"]');
		if(saveBtn){
			const btnClasses = saveBtn.classList.value;
			if (btnClasses.includes("disabled")) {
				this.showToast("Warning", "Some information is missing or invalid", "warning");
				return;
			}
		}

		this.sendActionToSave = true;
		if (Array.isArray(this.facility.supportedLanguages)) {
			this.facility.supportedLanguages = JSON.parse(JSON.stringify(this.facility.supportedLanguages))
				.sort()
				.join(";");
		}

		let objToSave = {
			Number_of_Employees__c: this.facility.NumberEmployees,
			Overall_Facility_Size_m2__c: this.facility.FacilitySize,
			Overall_Airport_Size__c: this.facility.overallAirportSize,
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
			second_address__c: this.facility.secondAddress,
			name: this.facility.name,
			Id: this.facility.Id,
			Pilot_Information__c: this.facility.pilotInformation
		}

		let jsonInput = JSON.stringify(objToSave);

		this.isLoading = true;
		updateFacility_({ jsonInput, logoInfo: JSON.stringify(this.logoInfoObject) })
			.then(response => {
				if (response.result.status == "OK") {
					this.showToast("Success", "Facility information successfully saved", "success");
					if(this.facilityid){
						this.getData(this.facilityid);
						if(this.logoInfoObject){
							this.template.querySelectorAll('.editable').forEach(elem =>{
								elem.classList.toggle("hidden");
							})
						}
					}
					else{
						this.isLoading = false;
					}
				} else if (response.result.status == "error") {
					this.showToast("Error", "Something went wrong while updating the facility", "error");
					this.isLoading = false;
				}
			})
			.catch(error => {
				this.isLoading = false;
				console.error("error", error);
			});
		this.saveSelectedAirlines();
		this.saveCargoStations();
		this.saveRampHandlers();
		
	}

	cancelChanges() {
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
			return getIataTooltip(this.facility.recordTypeDevName, this.facility.location, this.facility.locationClass, this.label);
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

	showInput(event){
		let elementName = event.target.dataset.item;
		this.template.querySelectorAll('.'+elementName).forEach(elem =>{
			elem.classList.toggle("hidden");
		})
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

	showInputAirlines(event){
		let elementName = event.target.dataset.item;
		this.template.querySelectorAll('.'+elementName).forEach(elem =>{
			elem.classList.toggle("hidden");
		})
		if(event.target.title == 'Edit'){
			this.editAirlines = false;
		}else{
			this.editAirlines = true;
		}

	}

	showInputCargoHandling(event){
		let elementName = event.target.dataset.item;
		this.template.querySelectorAll('.'+elementName).forEach(elem =>{
			elem.classList.toggle("hidden");
		})
		if(event.target.title == 'Edit'){
			this.editCargoHandling = false;
		}else{
			this.editCargoHandling = true;
		}

	}

	showInputRampHandlers(event){
		let elementName = event.target.dataset.item;
		this.template.querySelectorAll('.'+elementName).forEach(elem =>{
			elem.classList.toggle("hidden");
		})
		if(event.target.title == 'Edit'){
			this.editRampHandlers = false;
		}else{
			this.editRampHandlers = true;
		}

	}
}
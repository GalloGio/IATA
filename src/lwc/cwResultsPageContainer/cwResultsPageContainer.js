import { LightningElement, track, wire, api } from "lwc";
import getResults from "@salesforce/apex/CW_SearchEngine.getInfo";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { loadScript } from "lightning/platformResourceLoader";
import getCertifications from "@salesforce/apex/CW_ResultsPageSearchBarController.getCertifications";
import { checkIfEmptySearch, getQueryParameters, compressQueryParams } from "c/cwUtilities";
import labels from 'c/cwOneSourceLabels';
import pubsub from 'c/cwPubSub';
import getEnvironmentVariables from '@salesforce/apex/CW_Utilities.getEnvironmentVariables';


export default class CwResultsPageContainer extends LightningElement {
	@track recordsPerPage = 20;
	label = labels.labels();
	@track selectedPage = 1;

	@track mapOptions = '{"zoom" : 6,"mapTypeControl": false, "minZoom" : 2, "maxZoom" : 16}';
	@track mapData;
	@track companyTypeFilter;

	openarrow = resources + "/icons/responsive/ic-filters--resposive.svg";
	closearrow = resources + "/icons/responsive/ic-close-filter--responsive.svg";
	collapsearrow = resources + "/icons/ic-collapse-sidebar--blue.svg";

	sortblue = resources + "/icons/responsive/ic-shortby--blue.svg";
	@track filtercount = 0;
	@track titlefilter = "Filters (" + this.filtercount + ")";
	share = resources + "/icons/icon_share.svg";

	MAX_QUERY_LOCAL_STORAGE = 10;
	initialized = false;
	lastQueryEncodedString;
	@track results;
	@track searchList;
	@track initialSearch;
	@track urlICGHomePage;
	@track isLoading = true;
	@track initialLoadPerformed;
	@track certifications;
	urlBaseFacilityPage;

	@track showTypeCombo;
	hybridview = "hybrid";
	condensedview = "condensed";
	detailedview = "detailed";
	@track viewType = this.hybridview;
	@track customLocationFilter;

	mapiconsroute = resources + "/icons/map-icons/";
	cticonsroute = resources + "/icons/company_type/";
	//company types map icons
	airline = this.mapiconsroute + "icmp-airline.svg";
	airportoperator = this.mapiconsroute + "icmp-airport-operator.svg";
	freight = this.mapiconsroute + "icmp-ff.svg";
	trucker = this.mapiconsroute + "icmp-trucker.svg";
	cargohandling = this.mapiconsroute + "icmp-cargo-handling-facility.svg";
	shipper = this.mapiconsroute + "icmp-shipper.svg";
	ramphandler = this.mapiconsroute + "icmp-ramp.svg";
	//company types icons
	airlineCt = this.cticonsroute + "airline.svg";
	airportoperatorCt = this.cticonsroute + "airport-operator.svg";
	freightCt = this.cticonsroute + "freight-forwarder.svg";
	truckerCt = this.cticonsroute + "trucker.svg";
	cargohandlingCt = this.cticonsroute + "cargo-handling-facility.svg";
	shipperCt = this.cticonsroute + "shipper.svg";
	ramphandlerCt = this.cticonsroute + "ramp-handler.svg";

	certIcons = {};

	//The certification icon for the map, when
	//user filters only by one certification
	certimage;

	@wire(getURL, { page: "URL_ICG_Home" })
	wiredHomeUrl({ data }) {
		if (data) {
			this.urlICGHomePage = data;
		}
	}
	@wire(getURL, { page: "URL_ICG_FacilityPage" })
	wiredFacilityUrl({ data }) {
		if (data) {
			this.urlBaseFacilityPage = data;
		}
	}
	@wire(getCertifications, {})
	wiredCertifications({ data }) {
		if (data) {
			data.forEach(cert => {
				this.certIcons[cert.Name] = cert.Image_Filename__c ? cert.Image_Filename__c.substring(0, cert.Image_Filename__c.indexOf(".")) : "";
				
			});
			this.certifications = JSON.parse(JSON.stringify(data));
		}
	}

	@wire(getEnvironmentVariables, {})
	environmentVariables;

	hanldeFilterCountChange(event) {
		this.filtercount = event.detail;
	  }

	responsivefilter() {
		let filterpanel = this.template.querySelector(".filter-panel-hide");
		if (filterpanel) {
			filterpanel.classList.remove("filter-panel-hide");
			this.template.querySelector(".icoresponsivepalfilter").src = this.closearrow;
			this.template.querySelector(".results-filter-panel").classList.add("results-filter-panel-hide");
			this.titlefilter = "Back to results";
		} else {
			this.template.querySelector(".filter-panel").classList.add("filter-panel-hide");
			this.template.querySelector(".icoresponsivepalfilter").src = this.openarrow;
			this.template.querySelector(".results-filter-panel").classList.remove("results-filter-panel-hide");
			this.titlefilter = "Filters (" + this.filtercount + ")";
		}
	}
	connectedCallback() {
		if (window.LZString === undefined) {
			Promise.all([loadScript(this, resources + "/js/lz-string.js")]);
		}
	}
	renderedCallback() {
		if (!this.initialized) {
			let urlParams = getQueryParameters();
			if (urlParams.q) {
				this.lastQueryEncodedString = urlParams.q;
				if (this.lastQueryEncodedString && this.certIcons && Object.keys(this.certIcons).length > 0) {
					this.saveInLocalStorage("q", this.lastQueryEncodedString);
					this.getRecordsFromEngine(null);
					this.initialSearch = this.searchList;
					this.initialized = true;
				}
				if(this.initialSearch){
					this.initialSearch.forEach(elem => {			
						let values = elem.value ? String(elem.value).split(";") : null;
						if (values) {
							this.filtercount = values.length;
							this.titlefilter = "Filters (" + this.filtercount + ")";
						}
					});
				}
			}
			else{
				this.searchList = [];
				this.initialSearch = this.searchList;
				this.lastQueryEncodedString = 'all';
				this.saveInLocalStorage("q", this.lastQueryEncodedString);
				this.getRecordsFromEngine(null);
				this.initialized = true;
			}
		}

	}

	getRecordsFromEngine(event) {
		this.isLoading = true;
		if (!event) {
			if (this.lastQueryEncodedString) {
				try {
					if (this.lastQueryEncodedString === "all") {
						this.searchList = [];
					} else if (this.lastQueryEncodedString.includes("worldwide")) {
						let searchobj = { field: "City_FOR__c", obj: "icg_account_role_detail__c", operator: "LIKE", value: "WORLDWIDE" };
						this.searchList = [searchobj];
						this.setLastQueryEncodedString("all");
					} else {
						this.searchList = JSON.parse(decodeURI(atob(this.lastQueryEncodedString.replace("=", ""))));
						if (checkIfEmptySearch(this.searchList)) {
							this.searchList = [];
						}
					}
				} catch (error) {
					console.error(error);
					this.isLoading = false;
					if (!this.initialLoadPerformed) this.initialLoadPerformed = true;
				}
			}
		} else {
			this.searchList = event.detail;

			//reset this variable to trigger each time is set from the map
			//no matters if the value does not change in the map, as in here it will
			//change from null to something each time user clicks the 'Search This Area'
			this.customLocationFilter = false;
			const lastQueryEncodedStringLocal = checkIfEmptySearch(this.searchList) ? "all" : this.searchList;
			this.setLastQueryEncodedString(lastQueryEncodedStringLocal);

			this.companyTypeFilter = "All";
		}
		if (this.searchList) {
			let orderByOnAirport = this.determineOrderByOnAirport(this.searchList);

			const searchWrapper = this.manageDataSent(this.searchList);
			getResults({ attributes: JSON.stringify(searchWrapper), 
							getOpeningHours: false, 
							getHandledAirlines: false, 
							orderByOnAirport: orderByOnAirport, 
							isPendingApproval: false, 
							limitRecords: this.recordsPerPage,
							isStrongFilter: true
						})
				.then(result => {
					this.results = result ? JSON.parse(result) : null;
					this.selectedPage = 1;
					if (this.results) {
						if (!this.initialLoadPerformed) {
							this.initialLoadPerformed = true;
						}
						this.certimage = null;
						this.generateMapRecords(searchWrapper, orderByOnAirport);

						this.paginateLogic();
					} else {
						this.mapData = null;
						this.numberOfRecordsByTab = {};
						this.updateMapOptions();
						this.isLoading = false;
						if (!this.initialLoadPerformed) {
							this.initialLoadPerformed = true;
						}
						
					}
				})
				.catch(error => {
					//this.error = error;
					this.results = null;
					this.mapData = null;
					this.numberOfRecordsByTab = {};
					this.updateMapOptions();
					this.isLoading = false;
					if (!this.initialLoadPerformed) this.initialLoadPerformed = true;
					console.error("error", error);
				});
		} else {
			this.mapData = null;
			this.numberOfRecordsByTab = {};
			this.updateMapOptions();
			this.isLoading = false;
			if (!this.initialLoadPerformed) this.initialLoadPerformed = true;
		}
	}

	determineOrderByOnAirport(array) {
		let orderByOnAirport = false;

		array.forEach(element => {
			if (element.type && element.type.toLowerCase() === "airport") {
				orderByOnAirport = true;
			}
		});

		return orderByOnAirport;
	}

	generateMapRecords(searchWrapper, orderByOnAirport) {
		return new Promise((resolve, reject) => {
			try {
				getResults({ attributes: JSON.stringify(searchWrapper),
								isMapQuery: true,
								getOpeningHours: false,
								getHandledAirlines: false,
								orderByOnAirport: orderByOnAirport,
								isPendingApproval: false })
					.then(result => {
						let allResults = JSON.parse(result);
						this.mapData = [];
						this.numberOfRecordsByTab = {};
						allResults.forEach(record => {
							let iconurl = this.getIcon(record.facility.recordTypeDevName, searchWrapper);
							let ctypeimg = this.getCTypeImage(record.facility.recordTypeDevName);
							this.mapData.push({
								location: record.facility.location.location,
								name: record.facility.name,
								dataType: record.facility.recordTypeDevName,
								dataTypeLabel: record.facility.recordTypeName,
								icon: iconurl,
								thumbnail: record.facility.logoUrl ? record.facility.logoUrl : resources + "/img/no-image.svg",
								accountName: record.facility.accountName,
								companyTypeImage: ctypeimg,
								recordUrl: this.urlBaseFacilityPage + "?eid=" + record.facility.Id,
								availableCerts: record.lstAvailableCertifications
							});

							if (this.numberOfRecordsByTab['all'] === undefined) {
								this.numberOfRecordsByTab['all'] = 0;
							}
							this.numberOfRecordsByTab['all'] += 1;

							if (this.numberOfRecordsByTab[record.facility.recordTypeName.toLowerCase()] === undefined) {
								this.numberOfRecordsByTab[record.facility.recordTypeName.toLowerCase()] = 0;
							}
							this.numberOfRecordsByTab[record.facility.recordTypeName.toLowerCase()] += 1;
						});
						this.updateMapOptions();
						Array.prototype.certicon = this.certimage;
						resolve();
					})
					.catch(error => {
						this.mapData = null;
						this.numberOfRecordsByTab = {};
						this.updateMapOptions();
						console.error(error);
					});
			} catch (err) {
				reject(err);
			}
		});
	}
	getIcon(facilityType, searchWrapper) {
		//check if user is filtering by one certification
		if (searchWrapper) {
			searchWrapper.forEach(searchobj => {
				//Do something to parameterise the resource name, in order to get the map icon dynamically
				if (searchobj.obj === "ICG_Capability_Assignment_Group__c" && searchobj.value && searchobj.value.indexOf(";") < 0) {
					this.certimage = this.mapiconsroute + "icmp-" + this.certIcons[searchobj.value] + ".svg";
				}
			});
			if (this.certimage) return this.certimage;
		}
		/////////////
		if (facilityType) {
			if (facilityType === "Airline") return this.airline;
			else if (facilityType === "Airport_Operator") return this.airportoperator;
			else if (facilityType === "Freight_Forwarder") return this.freight;
			else if (facilityType === "Trucker") return this.trucker;
			else if (facilityType === "Shipper") return this.shipper;
			else if (facilityType === "Cargo_Handling_Facility") return this.cargohandling;
			else if (facilityType === "Ramp_Handler") return this.ramphandler;
		} else return null;
	}
	getCTypeImage(facilityType) {
		if (facilityType) {
			if (facilityType === "Airline") return this.airlineCt;
			else if (facilityType === "Airport_Operator") return this.airportoperatorCt;
			else if (facilityType === "Freight_Forwarder") return this.freightCt;
			else if (facilityType === "Trucker") return this.truckerCt;
			else if (facilityType === "Shipper") return this.shipperCt;
			else if (facilityType === "Cargo_Handling_Facility") return this.cargohandlingCt;
			else if (facilityType === "Ramp_Handler") return this.ramphandlerCt;
		} else return null;
	}
	manageDataSent() {
		let lstLocat = [];
		let lstCertis = [];
		let lstCoName = [];
		let lstCoType = [];
		let searchWrapper = [];

		for (let i = 0; i < this.searchList.length; i++) {
			this.searchList[i].fields = [this.searchList[i].field];
			switch (this.searchList[i].field.toUpperCase()) {
				case "CITY_FOR__C":
					this.searchList[i].fields = ["Nearest_Airport__r.City__c",
												"Nearest_Airport__r.IATA_ISO_Country__r.Name",
												"Search_By_City__c",
												"Search_By_Country__c", 
												"Nearest_Airport__r.Airport_Name__c",
												"City_For__c"];
					lstLocat.push(this.searchList[i]);
					break;
				case "RECORDTYPE.DEVELOPERNAME":
					lstCoType.push(this.searchList[i]);
					break;
				case "COMPANY_FOR__C":
					this.searchList[i].fields = ["Search_By_Company__c","Name","Company_For__c"];
					lstCoName.push(this.searchList[i]);
					break;
				case "ICG_CERTIFICATION__R.NAME":
					lstCertis.push(this.searchList[i]);
					break;
				default:
					searchWrapper.push(this.searchList[i]);
			}
		}

		if (lstLocat && lstLocat.length) {
			searchWrapper.push(this.mergeListInRow(lstLocat));
		}
		if (lstCoType && lstCoType.length) {
			searchWrapper.push(this.mergeListInRow(lstCoType));
		}
		if (lstCoName && lstCoName.length) {
			searchWrapper.push(this.mergeListInRow(lstCoName));
		}
		if (lstCertis && lstCertis.length) {
			searchWrapper.push(this.mergeListInRow(lstCertis));
		}

		if (this.companyTypeFilter && this.companyTypeFilter !== "All") {
			searchWrapper.push({ obj: "ICG_Account_Role_Detail__c", 
								field: "RecordType.Name", 
								operator: "=", 
								value: this.companyTypeFilter, 
								fields: ["RecordType.Name"] });
		}

		return searchWrapper;
	}
	mergeListInRow(lstRows) {
		let singleRow = JSON.parse(JSON.stringify(lstRows[0]));
		if (lstRows.length > 1) {
			for (let i = 1; i < lstRows.length; i++) {
				singleRow.value += ";" + lstRows[i].value;
			}
		}

		return singleRow;
	}

	setLastQueryEncodedString(srch) {
		const lastQueryEncodedStringLocal = srch === "all" ? srch : btoa(encodeURI(JSON.stringify(srch))).replace("=", "");
		this.lastQueryEncodedString = lastQueryEncodedStringLocal;
		this.saveInLocalStorage("q", this.lastQueryEncodedString);
		this.setUrlSearchParam();
	}
	saveInLocalStorage(key, value) {
		if (key === "q") {
			//move all already saved queries 1 position
			for (let i = this.MAX_QUERY_LOCAL_STORAGE; i > 1; i--) {
				if (window.localStorage.getItem("q" + (i - 1).toString())) {
					window.localStorage.setItem("q" + i.toString(), window.localStorage.getItem("q" + (i - 1).toString()));
					window.localStorage.removeItem("q" + (i - 1).toString());
				}
			}
			for (let i = 1; i <= this.MAX_QUERY_LOCAL_STORAGE; i++) {
				if (key === "q" && !window.localStorage.getItem("q" + i.toString())) {
					key = "q" + i.toString();
				} 
			}
			value = compressQueryParams(value);
		}
		window.localStorage.setItem(key, value);
	}
	

	setUrlSearchParam() {
		if (window.history.pushState) {
			let currentUrl = location.href;
			let newUrl;
			let params = getQueryParameters();
			if (params.q) {
				newUrl = currentUrl.replace(compressQueryParams(params.q), compressQueryParams(this.lastQueryEncodedString.replace("=", "")));
			} else if (Object.keys(params).length > 0 && this.lastQueryEncodedString) {
				newUrl = currentUrl + "&q=" + compressQueryParams(this.lastQueryEncodedString.replace("=", ""));
			} else if (this.lastQueryEncodedString) {
				newUrl = currentUrl + "?q=" + compressQueryParams(this.lastQueryEncodedString.replace("=", ""));
			}
			window.history.pushState({}, null, newUrl);
		}
	}

	closeViewTypeCombo() {
		this.showTypeCombo = false;
		this.isLoading = false;
	}
	openViewTypeCombo() {
		this.showTypeCombo = true;
	}
	setCompanyTypeFilter(event) {
		if (event) {
			if (this.companyTypeFilter !== event.detail) {
				this.companyTypeFilter = event.detail;
				this.selectedPage = 1;
				this.isLoading = true;
				this.paginateLogic();
			}
		}
	}

	get isBetaOrg(){
		return this.environmentVariables && this.environmentVariables.data && this.environmentVariables.data.Is_Beta_Org__c === true;
	}
	
	get isHybrid() {
		return this.viewType === this.hybridview;
	}
	get isCondensed() {
		return this.viewType === this.condensedview;
	}
	get isDetailed() {
		return this.viewType === this.detailedview;
	}

	get notLoadingAndHasValues() {
		return !this.isLoading && Array.isArray(this.results) && this.results.length;
	}

	get renderMap() {
		return this.viewType === this.hybridview;
	}
	get collapseArrowStyle() {
		let style = "";
		if (!this.showTypeCombo) {
			style = "width-8 rotate-90";
		} else {
			style = "width-8 rotate90";
		}
		return style;
	}

	setHybridView() {
		this.viewType = this.hybridview;
		let selct = this.template.querySelector(".bg-yellow");
		let combo = this.template.querySelector(".viewtypecombo-no-map");
		let optcombo = this.template.querySelectorAll(".item-viewtype-bar-no-map");
		if (selct) {
			selct.classList.remove("bg-yellow");
			selct.classList.add("bg-yellow-transparent");
		}
		if (combo) {
			combo.classList.remove("viewtypecombo-no-map");
			combo.classList.add("viewtypecombo");
		}
		if (optcombo) {
			optcombo.forEach(elem => {
				elem.classList.remove("item-viewtype-bar-no-map");
				elem.classList.add("item-viewtype-bar");
			});
		}

		this.closeViewTypeCombo();
	}
	setCondensedView() {
		this.viewType = this.condensedview;
		let selct = this.template.querySelector(".bg-yellow-transparent");
		let combo = this.template.querySelector(".viewtypecombo");
		let optcombo = this.template.querySelectorAll(".item-viewtype-bar");
		if (selct) {
			selct.classList.remove("bg-yellow-transparent");
			selct.classList.add("bg-yellow");
		}
		if (combo) {
			combo.classList.remove("viewtypecombo");
			combo.classList.add("viewtypecombo-no-map");
		}
		if (optcombo) {
			optcombo.forEach(elem => {
				elem.classList.remove("item-viewtype-bar");
				elem.classList.add("item-viewtype-bar-no-map");
			});
		}
		this.closeViewTypeCombo();
	}
	setDetailedView() {
		this.isLoading = true;
		this.viewType = this.detailedview;
		let selct = this.template.querySelector(".bg-yellow-transparent");
		let combo = this.template.querySelector(".viewtypecombo");
		let optcombo = this.template.querySelectorAll(".item-viewtype-bar");
		if (selct) {
			selct.classList.remove("bg-yellow-transparent");
			selct.classList.add("bg-yellow");
		}
		if (combo) {
			combo.classList.remove("viewtypecombo");
			combo.classList.add("viewtypecombo-no-map");
		}
		if (optcombo) {
			optcombo.forEach(elem => {
				elem.classList.remove("item-viewtype-bar");
				elem.classList.add("item-viewtype-bar-no-map");
			});
		}
		this.closeViewTypeCombo();
	}

	get combostyle() {
		let style = "col-3 col-no-padding-left containercombo position-absolute";
		if (!this.renderMap) style = "col-3 col-no-padding-left containercombo";
		return style;
	}

	@track
	numberOfRecordsByTab = {};
	get numberOfPages(){
		if (this.numberOfRecordsByTab[this.companyTypeFilter.toLowerCase()] !== undefined) {
			return Math.ceil(this.numberOfRecordsByTab[this.companyTypeFilter.toLowerCase()] / this.recordsPerPage);
		} else {
			return 1;
		}
	}

	nextpage(event) {
		this.isLoading = true;
		this.selectedPage++;
		this.paginateLogic();
		window.scrollTo(0, 0);
	}
	previouspage(event) {
		this.isLoading = true;
		this.selectedPage--;
		this.paginateLogic();
		window.scrollTo(0, 0);
	}
	gotopage(event) {
		this.isLoading = true;
		this.selectedPage = event.detail;
		this.paginateLogic();
		window.scrollTo(0, 0);
	}

	paginateLogic() {
		if (this.searchList) {
			let orderByOnAirport = this.determineOrderByOnAirport(this.searchList);
			const searchWrapper = this.manageDataSent(this.searchList);
			
			getResults({ attributes: JSON.stringify(searchWrapper),
							getOpeningHours: false,
							getHandledAirlines: false,
							orderByOnAirport: orderByOnAirport,
							isPendingApproval: false,
							limitRecords: this.recordsPerPage,
							offset: this.recordsPerPage * this.selectedPage - this.recordsPerPage,
							isStrongFilter: false
						}).then(result => {
							this.results = result ? JSON.parse(result) : null;
							if (this.results){						
								this.isLoading = false;
							}
						}).catch(error => {
							this.isLoading = false;
							console.error("error", error);
						});			
		}
	}

	filterByLatLong(event) {
		event.preventDefault();
		this.customLocationFilter = JSON.parse(event.detail);
	}

	updateMapOptions() {
		if (!this.mapData || this.mapData.length === 0) {
			this.mapOptions = '{"zoom" : 2,"mapTypeControl": false, "minZoom" : 2, "maxZoom" : 2, "disableDefaultUI": true}';
		} else {
			this.mapOptions = '{"zoom": 6, "mapTypeControl":true, "minZoom" : 2, "maxZoom" : 16, "disableDefaultUI": false}';

		}
	}

	@api
	showJoinNowPopUp(){
	  pubsub.fire("showJoinNowPopUp");
	}
}
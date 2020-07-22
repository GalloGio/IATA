import { LightningElement, track, api, wire } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { shMenu, sIcons, shButtonUtil, prButton, shareBtn, connectFacebook, connectTwitter, connectLinkedin, sendMail } from "c/cwUtilities";
import labels from "c/cwOneSourceLabels";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";


export default class CwSearchResultWrapper extends LightningElement {
	label = labels.labels();
	ctypeimages = resources + "/icons/company_type/";
	//company types
	airline = this.ctypeimages + "airline.svg";
	airportoperator = this.ctypeimages + "airport-operator.svg";
	freight = this.ctypeimages + "freight-forwarder.svg";
	trucker = this.ctypeimages + "trucker.svg";
	cargohandling = this.ctypeimages + "cargo-handling-facility.svg";
	shipper = this.ctypeimages + "shipper.svg";
	ramphandler = this.ctypeimages + "ramp-handler.svg";
	@track urlResultPage;

	icons = resources + "/icons/";
	//icons
	shareblue = this.icons + "ic-share--blue.svg";
	sortblue = this.icons + "ic-shortby--blue.svg";
	twiter = this.icons + "social-twitter.svg";
	facebook = this.icons + "social-facebook.svg";
	linkedin = this.icons + "social-linkedin.svg";
	email = this.icons + "social-email.svg";

	@track stringResponse;
	@track selectedOne;
	@track filteredFacilities;
	@api isDetailed;
	@track _lstResults;
	@api
	get lstResults() {
		return this._lstResults;
	}
	set lstResults(value) {
		this._lstResults = value;
		if (!this.isLoading) this.companyType = "All";
		if(this._lstResults) this.filterFacility();
	}
	//all data showed in map, to count records
	@api mapData;

	@api isLoading;

	initialized = false;
	index = 0;
	@track companyType = 'All';

	renderedCallback() {
		if (!this.initialized) {
			Promise.all([]).then(() => {
				// TODO - will come from google maps´ event
				this.selectedOne = this.lstResults && this.lstResults.length > 0 ? this.lstResults[0] : null;
			});
			this.initialized = true;
		}
	}

	@wire(getURL, { page: "URL_ICG_FacilityPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}

	filterFacility(event) {
		let i, navlinks;
		navlinks = this.template.querySelectorAll(".nav-link");
		for (i = 0; i < navlinks.length; i++) {
			navlinks[i].classList.remove("active");
		}
		if (event) {
			event.currentTarget.classList.add("active");
			this.companyType = event.currentTarget.dataset.tab.replace(/-/gi, " ");
		} else {
			for (i = 0; i < navlinks.length; i++) {
				if (navlinks[i].dataset.tab === this.companyType) navlinks[i].classList.add("active");
			}
		}
		this.dispatchEvent(new CustomEvent("filterctype", { detail: this.companyType }));
		this.calculateFilteredFacilities();
	}

	filterFacilityResp(event) {
		if (event) {
			this.companyType = event.currentTarget.value.replace(/-/gi, " ");
		}
		this.dispatchEvent(new CustomEvent("filterctype", { detail: this.companyType }));
		this.calculateFilteredFacilities();
	}

	calculateFilteredFacilities() {
		this.filteredFacilities = null;
		this.index = 0;
		if (this.companyType) {
			this.filteredFacilities = [];
			if (this.lstResults) {
				this.lstResults.forEach(data => {
					this.index++;
					if (this.lstResults.length > 3) {
						if (this.index === 4) {
							const banner = {
								isBanner: true,
								name: "Banner"
							};
							this.filteredFacilities.push(banner);
						}
					} else {
						if (this.index === this.lstResults.length) {
							const banner = {
								isBanner: true,
								name: "Banner"
							};
							this.filteredFacilities.push(banner);
						}
					}
					if (data && data.facility && (data.facility.recordTypeName === this.companyType || this.companyType === "All")) {
						this.filteredFacilities.push(data);
					}
				});
			}
		}
	}

	get allCount() {
		let count = 0;
		if (this.mapData) {
			count = this.mapData.length;
		}

		return count < 2000 ? count : "+2000";
	}

	get arilineCount() {
		let count = 0;
		if (this.mapData) {
			this.mapData.forEach(data => {
				if (data.dataType === "Airline") {
					count++;
				}
			});
		}

		return count;
	}
	get classAriline() {
		let sum = "nav-link extraWidth";
		if (this.arilineCount === 0 || this.isLoading) {
			sum = "nav-link extraWidth tab-disabled";
		}
		return sum;
	}

	get airportOperatorCount() {
		let count = 0;
		if (this.mapData) {
			this.mapData.forEach(data => {
				if (data.dataType === "Airport Operator") {
					count++;
				}
			});
		}

		return count;
	}
	get classAirportOperator() {
		let sum = "nav-link extraWidth";
		if (this.airportOperatorCount === 0 || this.isLoading) {
			sum = "nav-link extraWidth tab-disabled";
		}
		return sum;
	}

	get freightCount() {
		let count = 0;
		if (this.mapData) {
			this.mapData.forEach(data => {
				if (data.dataType === "Freight Forwarder") {
					count++;
				}
			});
		}

		return count;
	}
	get classFreight() {
		let sum = "nav-link";
		if (this.freightCount === 0 || this.isLoading) {
			sum = "nav-link tab-disabled";
		}
		return sum;
	}

	get truckerCount() {
		let count = 0;
		if (this.mapData) {
			this.mapData.forEach(data => {
				if (data.dataType === "Trucker") {
					count++;
				}
			});
		}

		return count;
	}
	get classTrucker() {
		let sum = "nav-link extraWidth";
		if (this.truckerCount === 0 || this.isLoading) {
			sum = "nav-link extraWidth tab-disabled";
		}
		return sum;
	}

	get cargoHandlingCount() {
		let count = 0;
		if (this.mapData) {
			this.mapData.forEach(data => {
				if (data.dataType === "Cargo Handling Facility") {
					count++;
				}
			});
		}

		return count;
	}
	get classCargoHandling() {
		let sum = "nav-link";
		if (this.cargoHandlingCount === 0 || this.isLoading) {
			sum = "nav-link tab-disabled";
		}
		return sum;
	}

	get shipperCount() {
		let count = 0;
		if (this.mapData) {
			this.mapData.forEach(data => {
				if (data.dataType === "Shipper") {
					count++;
				}
			});
		}

		return count;
	}
	get classShipper() {
		let sum = "nav-link extraWidth";
		if (this.shipperCount === 0 || this.isLoading) {
			sum = "nav-link extraWidth tab-disabled";
		}
		return sum;
	}

	get rampHandlerCount() {
		let count = 0;
		if (this.mapData) {
			this.mapData.forEach(data => {
				if (data.dataType === "Ramp Handler") {
					count++;
				}
			});
		}
		return count;
	}
	Obj = function(name) {
		this.name = name;
	};
	get classRampHandler() {
		let sum = "nav-link";
		if (this.rampHandlerCount === 0 || this.isLoading) {
			sum = "nav-link tab-disabled";
		}
		return sum;
	}

	get searchResults() {
		let lenghtResults = false;
		if (this.initialized) {
			lenghtResults = false;
			if (this.initialized && this.lstResults && this.lstResults.length > 0) {
				lenghtResults = true;
			}
		}
		return lenghtResults;
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

	get sortButton() {
		return prButton(this.shareButton);
	}

	get shButton() {
		return shareBtn(this.shareButton);
	}

	get url() {
		return window.location.href;
	}
	goToPreregister() {
		window.open(this.label.icg_registration_url, "_blank");
	}
	conFacebook() {
		connectFacebook(encodeURIComponent(this.url));
	}

	conTwitter() {
		let textTwitter = "Find all information about this service provider’s infrastructure and capabilities on IATA ONE Source";
		connectTwitter(encodeURIComponent(this.url), textTwitter);
	}

	conLinkedin() {
		connectLinkedin(encodeURIComponent(this.url));
	}

	conEmail() {
		sendMail("", "Facility Search", encodeURIComponent(this.url));
	}
}
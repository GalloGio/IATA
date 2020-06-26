import { LightningElement, api, wire, track } from "lwc";
import { getSObjectValue } from "@salesforce/apex";
import pubsub from "c/cwPubSub";
import getMetadataInfo from "@salesforce/apex/CW_Utilities.getMetadataInfo";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import resources from "@salesforce/resourceUrl/ICG_Resources";

import NAME_FIELD from "@salesforce/schema/ICG_Portal_URL__mdt.MasterLabel";
import URL_FIELD from "@salesforce/schema/ICG_Portal_URL__mdt.Link__c";
import DESCRIPTION_FIELD from "@salesforce/schema/ICG_Portal_URL__mdt.Description__c";
import { concatinateFacilityAddress, concatinateAddressString, removeLastCommaAddress, removeFromComparisonCommon } from "c/cwUtilities";
import labels from 'c/cwOneSourceLabels';

const LOCAL_STORAGE_COMPARE_FIELD = "facilitiesToCompare";
const MIN_ITEMS_TO_COMPARE = 2;

const NOT_ALLOWED_PAGES_TO_SHOW_COMPARISON_BAR = ["facility-compare"];

export default class cwFooter extends LightningElement {
	isRenderedCallback = false;
  label = labels.labels();
	icons = {
		arrow: resources + "/icons/ic-collapse-sidebar--blue.svg",
		close: resources + "/icons/icon-close.svg"
	};

	pagesToShowCompareBar = ['search-results', 'station-profile'];
	@track isComparisonCollapsed = false;

	@track loadedCss = false;
	connectedCallback() {
		this.cssLoadedCallback = this.cssLoaded.bind(this);
		this.comparisonUpdatedCallback = this.comparisonUpdated.bind(this);
		this.register();
	}
	@api
	register() {
		pubsub.register("loadedCss", this.cssLoadedCallback);
		pubsub.register("localstorageupdated", this.comparisonUpdatedCallback);
	}

	get isAllowedComparisonBarInCurrentPage() {
		// NOT_ALLOWED_PAGES_TO_SHOW_COMPARISON_BAR
		return true;
	}
	cssLoadedCallback;
	cssLoaded() {
		this.loadedCss = true;
	}
	// Airlines Magazine
	@wire(getMetadataInfo, { mtdName: "Airlines_magazine" }) metadataAirlines;

	get AirlinesName() {
		return this.metadataAirlines.data ? getSObjectValue(this.metadataAirlines.data, NAME_FIELD) : "";
	}
	get AirlinesURL() {
		return this.metadataAirlines.data ? getSObjectValue(this.metadataAirlines.data, URL_FIELD) : "";
	}

	// Aviation and the Enviroment
	@wire(getMetadataInfo, { mtdName: "Aviation_and_the_enviroment" })
	metadataAviation;

	get AviationName() {
		return this.metadataAviation.data ? getSObjectValue(this.metadataAviation.data, NAME_FIELD) : "";
	}
	get AviationURL() {
		return this.metadataAviation.data ? getSObjectValue(this.metadataAviation.data, URL_FIELD) : "";
	}

	// Twitter
	@wire(getMetadataInfo, { mtdName: "Twitter" }) metadataTwitter;

	get twitterName() {
		return this.metadataTwitter.data ? getSObjectValue(this.metadataTwitter.data, NAME_FIELD) : "";
	}
	get twitterURL() {
		return this.metadataTwitter.data ? getSObjectValue(this.metadataTwitter.data, URL_FIELD) : "";
	}

	// Facebook
	@wire(getMetadataInfo, { mtdName: "Facebook" }) metadataFacebook;

	get FacebookName() {
		return this.metadataFacebook.data ? getSObjectValue(this.metadataFacebook.data, NAME_FIELD) : "";
	}
	get FacebookURL() {
		return this.metadataFacebook.data ? getSObjectValue(this.metadataFacebook.data, URL_FIELD) : "";
	}

	// Linkedin
	@wire(getMetadataInfo, { mtdName: "LinkedIn" }) metadataLinkedIn;

	get LinkedinName() {
		return this.metadataLinkedIn.data ? getSObjectValue(this.metadataLinkedIn.data, NAME_FIELD) : "";
	}
	get LinkedinURL() {
		return this.metadataLinkedIn.data ? getSObjectValue(this.metadataLinkedIn.data, URL_FIELD) : "";
	}

	// Youtube
	@wire(getMetadataInfo, { mtdName: "Youtube" }) metadataYoutube;

	get YoutubeName() {
		return this.metadataYoutube.data ? getSObjectValue(this.metadataYoutube.data, NAME_FIELD) : "";
	}
	get YoutubeURL() {
		return this.metadataYoutube.data ? getSObjectValue(this.metadataYoutube.data, URL_FIELD) : "";
	}

	// RSS
	@wire(getMetadataInfo, { mtdName: "RSS" }) metadataRSS;

	get RSSName() {
		return this.metadataRSS.data ? getSObjectValue(this.metadataRSS.data, NAME_FIELD) : "";
	}
	get RSSURL() {
		return this.metadataRSS.data ? getSObjectValue(this.metadataRSS.data, URL_FIELD) : "";
	}

	// Legal
	@wire(getMetadataInfo, { mtdName: "Legal" }) metadataLegal;

	get LegalName() {
		return this.metadataLegal.data ? getSObjectValue(this.metadataLegal.data, NAME_FIELD) : "";
	}
	get LegalURL() {
		return this.metadataLegal.data ? getSObjectValue(this.metadataLegal.data, URL_FIELD) : "";
	}

	// Legal
	@wire(getMetadataInfo, { mtdName: "Privacy" }) metadataPrivacy;

	get PrivacyName() {
		return this.metadataPrivacy.data ? getSObjectValue(this.metadataPrivacy.data, NAME_FIELD) : "";
	}
	get PrivacyURL() {
		return this.metadataPrivacy.data ? getSObjectValue(this.metadataPrivacy.data, URL_FIELD) : "";
	}

	// Footer Title
	@wire(getMetadataInfo, { mtdName: "Footer_Title" }) metadataFooterTitle;

	get FooterTitleDescription() {
		return this.metadataFooterTitle.data ? getSObjectValue(this.metadataFooterTitle.data, DESCRIPTION_FIELD) : "";
	}

	// Footer Copyright
	@wire(getMetadataInfo, { mtdName: "Footer_Copyright" })
	metadataFooterCopyright;

	get FooterCopyrightDescription() {
		return this.metadataFooterCopyright.data ? getSObjectValue(this.metadataFooterCopyright.data, DESCRIPTION_FIELD) : "";
	}

	logoOther = resources + "/icons/iata-logo-other.svg";
	twitter = resources + "/icons/social-twitter.svg";
	facebook = resources + "/icons/social-facebook.svg";
	linkedin = resources + "/icons/social-linkedin.svg";
	youtube = resources + "/icons/social-youtube.svg";
	rss = resources + "/icons/social-rss.svg";

	renderedCallback() {
		if (!this.isRenderedCallback) {
			this.isRenderedCallback = true;

			this.comparisonUpdated(null);
			Promise.all([]);
		}
	}

	get getContainerType() {
		let container;
		if (window.location.pathname.indexOf(this.urlResultPage >= 0)) {
      container = "container container-search";
    } else {
      container = "container";
    }
    return container;
	}

	@track comparisonItems = [];
	comparisonUpdatedCallback;
	comparisonUpdated(payload) {
		let comparisonHover = this.template.querySelector(".comparison-bar");
		let comparisonHoverShow = this.template.querySelector(".comparison-bar-show");
		let comparisonItems = new Array();

		if (this.facilitiesToCompare.length > 0) {
			this.facilitiesToCompare.forEach(element => {
				if (element.Id) {
					let address = concatinateAddressString(element.addressStreetNr) + concatinateAddressString(element.secondAddress) + concatinateFacilityAddress(element);
					address = removeLastCommaAddress(address);
					comparisonItems.push({
						type: "item",
						id: element.Id,
						name: element.name,
						address: address,
						logoUrl: element.logoUrl,
						recordTypeName: element.recordTypeName,
						recordTypeIcon: element.recordTypeIcon
					});
				}
			});

			let MAX_ITEMS = 3;
			if (comparisonItems.length > 0 && comparisonItems.length < MAX_ITEMS) {
				while (comparisonItems.length < MAX_ITEMS) {
					comparisonItems.push({
						name: "Add More..."
					});
				}
			}

			this.comparisonItems = [];
			this.comparisonItems = comparisonItems.slice(0, 3);
			comparisonHover.classList.remove("force-hidden");
		} else {
			comparisonHover.classList.add("force-hidden");
			comparisonHover.classList.remove("no-collapsed");
			comparisonHover.classList.remove("collapsed");

			comparisonHoverShow.classList.remove("no-collapsed");
			comparisonHoverShow.classList.add("collapsed");
		}
	}

	get facilitiesToCompare() {
		if (window.location.pathname) {
			let pathname = window.location.pathname.split("/");

			if (pathname.length > 0 && NOT_ALLOWED_PAGES_TO_SHOW_COMPARISON_BAR.includes(pathname[pathname.length - 1])) {
				return [];
			}
		}

		let tmpFacilitiesToCompare = JSON.parse(window.localStorage.getItem(LOCAL_STORAGE_COMPARE_FIELD)) || [];

		return tmpFacilitiesToCompare;
	}
	set facilitiesToCompare(value) {
		window.localStorage.setItem(LOCAL_STORAGE_COMPARE_FIELD, JSON.stringify(value));
	}
	handleRemoveItemFromComparison(event) {
		const id = event.currentTarget.getAttribute("data-item-id");
		this.removeFromComparison(id);
	}

	removeFromComparison(idsToRemove) {
		const updatedFacilitiesToCompare = removeFromComparisonCommon(idsToRemove, this.facilitiesToCompare);

		if (updatedFacilitiesToCompare) {
			this.facilitiesToCompare = updatedFacilitiesToCompare;
			this.comparisonUpdated(null);
			this.notifyComparisonUpdated();
		}
	}
  @track urlResultPage;
	handleAddMoreItemToCompare(event) {
		let q = window.localStorage.getItem("q1");
		let url = this.urlResultPage;
		if (q) url += "?q=" + q;
		window.open(url, "_self");
	}
	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}

	@wire(getURL, { page: "URL_ICG_FacilityComparePage" })
	facilityComparePage;

	handleCompare(event) {
		window.open(this.facilityComparePage.data, "_self");
	}

	handleClearComparison(event) {
		this.facilitiesToCompare = [];
		this.notifyComparisonUpdated();
	}

	notifyComparisonUpdated(event) {
		pubsub.fire("localstorageupdated", {
			action: "update",
			localStorageField: LOCAL_STORAGE_COMPARE_FIELD
		});
	}
	handleShowHideComparison(event) {
		this.isComparisonCollapsed = !this.isComparisonCollapsed;

		let comparisonBar = this.template.querySelector(".comparison-bar");
		let comparisonBarShow = this.template.querySelector(".comparison-bar-show");

		if (this.isComparisonCollapsed) {
			comparisonBar.classList.remove("no-collapsed");
			comparisonBar.classList.add("collapsed");

			comparisonBarShow.classList.remove("collapsed");
			comparisonBarShow.classList.add("no-collapsed");
		} else {
			comparisonBar.classList.remove("collapsed");
			comparisonBar.classList.add("no-collapsed");

			comparisonBarShow.classList.remove("no-collapsed");
			comparisonBarShow.classList.add("collapsed");
		}
	}

	get minItemsRequiredToCompare() {
		let counter = 0;

		this.facilitiesToCompare.forEach(facility => {
			if (facility.Id) {
				counter++;
			}
		});

		return counter >= MIN_ITEMS_TO_COMPARE;
	}

	get shouldShowComparisonBar(){
		let location = window.location.pathname;
		let pageShouldShowComparisonBar = false;

		this.pagesToShowCompareBar.forEach(page => {
			if(location.includes(page)){
				pageShouldShowComparisonBar = true;
			}
		})
		
		return this.comparisonItems && pageShouldShowComparisonBar;
	}
}
import { LightningElement, wire, api, track } from "lwc";
import getCertifications from "@salesforce/apex/CW_CertificationSection.getCertifications";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import swipe from "c/cwSwipe";
import { prepareSearchParams } from "c/cwUtilities";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { loadScript } from "lightning/platformResourceLoader";

export default class CwCertificationCarousel extends LightningElement {
	urlResultPage;
	@api title;
	@api label;
	@track selectedCertification = {
		Id: "",
		Name: "",
		imagen: "",
		type: "",
		description: "",
		link: "",
		techOrder: "",
		classes: "clickable-box unselected",
		panelClass: "",
        indicatorClass: "",
        hidden: "",
        tabindex: "",
        position: ""
	};
	@track resultsList;
	@track positionCarousel = 'slds-carousel__panels without-border translate-x-0';
	initializedswipe = false;
	selectedIndex;

	// Filters
	@wire(getCertifications, {
		certificationType: "",
		certificationName: ""
	})
	wiredResults({ data }) {
		if (data) {
			let result = JSON.parse(JSON.stringify(data));
			let certificationList = [];
			let index = 0;
            let panelClass = 'slds-carousel__panel cursor-txt';
            let indicatorClass = 'slds-carousel__indicator-action';

			for (let i = 0; i < result.length; i++) {
				let resObject = result[i];

				let cert = {
					Id: resObject.Id,
					Name: resObject.Name,
					imagen: resObject.Image__c,
					type: resObject.Certification_Type__c,
					description: resObject.Description__c,
					link: resObject.link__c,
					techOrder: resObject.Tech_Order__c,
					classes: index === 0 ? "clickable-box selected" : "clickable-box unselected",				
                    panelClass: index === 0 ? panelClass + ' panelSelected' : panelClass,
                    indicatorClass: index === 0 ? indicatorClass + ' slds-is-active' : indicatorClass,
                    hidden: index === 0 ? true : false,
                    tabindex: index === 0 ? '0' : '-1',
                    position: 'slds-carousel__panels without-border translate-x' + index + '00'

				};
				index++;
				certificationList.push(cert);
			}
			certificationList.sort((a, b) => (a.techOrder > b.techOrder ? 1 : -1));

			this.resultsList = certificationList;
			this.selectedCertification = this.resultsList[0];
			this.initializeSwipe();
		}
	}
	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}

	showCertifiedEntities() {
		let searchList = [];
		let searchObject = { operator: "LIKE", value: this.title };
		searchObject.obj = "ICG_Capability_Assignment_Group__c";
		searchObject.field = "ICG_Certification__r.Name";
		searchObject.relationfield = "ICG_Account_Role_Detail__c";
		searchList.push(searchObject);
		const urlParams = prepareSearchParams(searchList);
		window.location.href = this.urlResultPage + "?q=" + urlParams;
	}

	get isCertificationResults() {
		if (this.resultsList) {
			return this.resultsList.length > 0;
		}

		return "";
	}

	handleAccCertSelected(event) {
		clearInterval(this.interval);
        this.resetInterval();
		const certId = event.target.dataset.item;
		this.selectedCertification = this.resultsList.find(cert => cert.Id === certId);

		this.updateCss(this.selectedCertification.Id);
	}

	findIndex() {
		if (!this.selectedCertification.Id) return -1;

		return this.resultsList.findIndex(result => result.Id === this.selectedCertification.Id);
	}

    resetInterval() {

        this.interval = setInterval(() => {
            this.nextHandler();
        }, 5000);

    }



	previousHandler() {
		clearInterval(this.interval);
        this.resetInterval();
		let index = this.findIndex();
		if (index > -1) {
			if (index === 0) {
				index = this.resultsList.length - 1;
			} else {
				index--;
			}
			this.selectedCertification = this.resultsList[index];
			this.updateCss(this.selectedCertification.Id);
		}
	}

	nextHandler() {
		clearInterval(this.interval);
        this.resetInterval();
		let index = this.findIndex();
		if (index > -1) {
			if (index === this.resultsList.length - 1) {
				index = 0;
			} else {
				index++;
			}
			this.selectedCertification = this.resultsList[index];
			this.updateCss(this.selectedCertification.Id);
		}
	}


	updateCss(Id) {
		this.updateList(Id);

		this.resultsList.forEach(element => {
			if (this.selectedCertification.Id === element.Id) {
				element.classes = "clickable-box selected";
			} else {
				element.classes = "clickable-box unselected";
			}
		});

	}


    updateList(indicatorClicked) {

        this.resultsList.forEach(element => {

            if (element.Id === indicatorClicked) {
                element.indicatorClass = 'slds-carousel__indicator-action slds-is-active';
                element.tabindex = '0';
                element.hidden = 'true';
                element.panelClass = 'slds-carousel__panel panelSelected';
                this.positionCarousel = element.position;
                this.selectedCertification = element;
            } else {
                element.indicatorClass = 'slds-carousel__indicator-action';
                element.tabindex = '-1';
                element.hidden = 'false';
                element.panelClass = 'slds-carousel__panel';
            }
        });

    }

	navigateToUrl() {
		let url = this.selectedCertification.link;

		if (!url.includes("http://") && !url.includes("https://")) {
			url = "http://" + url;
		}

		window.open(url);
	}

	initializeSwipe() {
		if (!this.initializedswipe) {
			let swipedivs = this.template.querySelectorAll(".swipediv");
			if (swipedivs && swipedivs.length > 0) {
				this.initializedswipe = true;
				swipedivs.forEach(swipediv => {
					swipe.swipedetect(swipediv, swipedir => {
						// swipedir contains either "none", "left", "right", "top", or "down"
						if (swipedir === "left") this.nextHandler();
						if (swipedir === "right") this.previousHandler();
					});
				});
			}
		}
	}
	renderedCallback() {
		this.initializeSwipe();
	}
	connectedCallback() {
		if (window.LZString === undefined) {
			Promise.all([loadScript(this, resources + "/js/lz-string.js")]);
		}
	}
}
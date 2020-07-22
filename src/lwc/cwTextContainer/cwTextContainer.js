import { LightningElement, wire, api } from "lwc";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { prepareSearchParams } from "c/cwUtilities";
import { loadScript } from "lightning/platformResourceLoader";

export default class CwTextContainer extends LightningElement {
	@api firstext = false;

	//icons
	icons = {
		close: resources + "/icons/icon-close.svg"
	};

	@api
	title = "Default title";

	@api
	titlecolor = "";
	get getTitleColor() {
		let titleCol = this.titlecolor;
		if(this.backgroundcolor != "bg-blue" && this.firstext){
			titleCol = titleCol + ' m-b-8p';
		}
		return titleCol;
	}

	@api
	underline = "";

	@api
	text = "";

	@api
	text2 = "";

	@api
	text3 = "";

	@api textcolor = "";
	get getTextColor() {
		return this.textcolor;
	}

	@api
	buttonColor = "";
	get getButtonColor() {
		return "text-white mt-0 " + this.buttonColor;
	}

	@api
	buttonText = "";

	@api
	buttonTextTwo = "";

	@api
	closeButton = "";

	@api
	buttonUrl = "";

	@api
	passButtonClick = false;

	@api
	buttonClick;

	@api
	buttonTarget = "_blank";

	@api
	buttonPosition = "left";

	@api
	backgroundcolor = "";

	urlResultPage;
	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}

	get getMainStyle() {
		let mStyle;
		if (this.backgroundcolor === "bg-blue") {
			mStyle = this.backgroundcolor + " padding-25";
		} else {
			if (!this.firstext) {
				mStyle = this.backgroundcolor + " padding-0-20";
			} else {
				mStyle = this.backgroundcolor + " padding-0-20-0";
			}
		}

		return mStyle;
	}

	get textSpecialPadding() {
		let mStyle = "";
		if (this.backgroundcolor === "bg-blue" && this.firstext) {
			mStyle = "first-blue";
		}
		return mStyle;
	}

	connectedCallback() {
		if (window.LZString === undefined) {
			Promise.all([loadScript(this, resources + "/js/lz-string.js")]);
		}
	}

	renderedCallback() {
		Promise.all([]);
	}

	closeTextContainer() {
		this.dispatchEvent(new CustomEvent("closetextcontainer"));
	}

	navigateToUrl() {
        if (!this.passButtonClick){
            let url;

            if (this.buttonUrl && this.buttonUrl.indexOf("http://") < 0 && this.buttonUrl.indexOf("https://") < 0) {
                url = "http://" + this.buttonUrl;
            } else {
                url = this.buttonUrl;
            }
            if (!this.buttonTarget || this.buttonTarget != "_self") window.open(url);
            else window.location.href = url;
        }
		else{
            this.buttonClick();
        }
	}

	showCertifiedEntities() {
		let searchList = [];
		let searchValue = this.title && this.title.toLowerCase() === "ienva" ? this.title + ";IEnvA Stage 2" : this.title;
		let searchObject = { operator: "LIKE", value: searchValue };
		searchObject.obj = "ICG_Capability_Assignment_Group__c";
		searchObject.field = "ICG_Certification__r.Name";
		searchObject.relationfield = "ICG_Account_Role_Detail__c";
		searchList.push(searchObject);
		const urlParams = prepareSearchParams(searchList);
		window.open(this.urlResultPage + "?q=" + urlParams);
	}

	get showButton() {
		return this.buttonText !== "";
	}

	get showUnderline() {
		return this.underline !== "";
	}

	get showButtonTwo() {
		return this.buttonTextTwo !== "";
	}

	get showCloseButton() {
		return this.closeButton !== "";
	}

	get showp1() {
		return this.text !== "";
	}
	get showp2() {
		return this.text2 !== "";
	}
	get showp3() {
		return this.text3 !== "";
	}
}
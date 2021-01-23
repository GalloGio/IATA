import { LightningElement, api, track } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { getImageString, getIataSrc, getIataTooltip } from "c/cwUtilities";
import labels from "c/cwOneSourceLabels";

export default class CwCompanyCard extends LightningElement {
	@api input;
	@api label;
	label = labels.labels();
	@track shouldDisplayTooltip = false;

	@track tooltipObject;
	@track tooltipToDisplay = "";

	@api containerType = "";
	get isFacilityComparisonPageType() {
		return this.containerType === "facility-compare-page";
	}

	get cssRecordTypeNameContainer() {
		if (this.isFacilityComparisonPageType) {
			return "col-10 col-no-padding-left text-truncate";
		} else {
			return "col-10 col-no-padding-left";
		}
	}
	get titleRecordTypeNameContainer() {
		if (this.isFacilityComparisonPageType) {
			return this.input.recordTypeName;
		} else {
			return "";
		}
	}

	get getCompanyTypeImage() {
		let imageString = "";
		if (this.input) {
			imageString = getImageString(this.input.recordTypeDevName);
		}
		return resources + "/icons/company_type/" + imageString;
	}

	get getIATAIcon() {
		return getIataSrc(this.input.recordTypeDevName, this.input.location, this.input.locationClass, resources);
	}

	get getIATAIconCss() {
		let image = getIataSrc(this.input.recordTypeDevName, this.input.location, this.input.locationClass, resources);
		let cssClass = "align-middle ml-2";
		if (image.includes("cns-endorsed-agent")) {
			cssClass += " height-20";
		} else if (image.includes("iata-logo-cut")) {
			cssClass += " width-27";
		}

		return cssClass;
	}

	get getShowImg() {
		let style = false;
		if (this.input && this.input.IATA_icon) {
			style = true;
		}
		return style;
	}

	get getLogoUrl() {
		if (this.input.logoUrl) {
			return this.input.logoUrl;
		}

		return resources + "/img/no-image.svg";
	}

	tooltipText() {
		if (this.input && this.label) {
			return getIataTooltip(this.input.recordTypeDevName, this.input.location, this.input.locationClass, this.label);
		}

		return "";
	}

	showPopover(event) {
		let item = event.currentTarget.dataset.item;		
		const text = this.tooltipText();
		this.tooltipToDisplay = item;

		let containerDiv = this.template.querySelector('[data-tosca="' + item + '"]');
		let bounds = containerDiv.getBoundingClientRect();
		let marginLeftDivider = (text.indexOf(this.label.icg_cns_endorsed_agent) > -1)? 3.4 : 6.8;
		const marginLeft = -(bounds.width / marginLeftDivider);
		const marginTop = bounds.height * 1.5;
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

	setDefaultImg(event){
		event.target.src = resources + "/img/no-image.svg";
	}
}
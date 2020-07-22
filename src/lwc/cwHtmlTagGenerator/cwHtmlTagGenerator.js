import { LightningElement, api, track } from "lwc";
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";
import { hideHover } from "c/cwUtilities";

export default class CwHtmlTagGenerator extends LightningElement {
	defaultcheckedIconFilename = "ic-tic-green.svg";
	@api label;
	@api checkedIconFilename = "";
	icons = {
		thermometer: ICG_RESOURCES + "/icons/thermometer.svg",
		checkDefault: ICG_RESOURCES + "/icons/ic-tic-green.svg",
		checkCustom: ICG_RESOURCES + "/icons/" + this.checkedIconFilename
	};

	@track tooltipToDisplay = "";
	@track tooltipObject;
	@track selectedOption;

	@api isHeader = false;

	_item = "";

	@api
	get item(){
		return this._item;
	}

	set item(value){
		this._item = value;
		const element = this.template.querySelector('[data-tosca="conflict-actions"]');

		if(element){
			element.disabled = this.item.selectedReplacedBy;
		}

		if(this.item.options && this.item.options.length === 1 && this.item.options[0].value.includes("STATUS_TO_BE_REPLACED_BY")){	
			this.selectedOption = this.item.options[0].value;
		}
	}

	@api propertyName = "";
	@api rowIndex = "0";

	@api maxCharacters = "0";
	@api auxType = "";

	@api viewType = "";

	get isComparisonFacilityView() {
		return this.viewType === "comparison-facility-view";
	}

	get getValue() {
		if(this.isTypeTrueFalse){
			return this.item[this.propertyName];
		}
		
		let value = this.item[this.propertyName]
			? this.item[this.propertyName].toString()
			: "-";

		let maxChars = isNaN(Number(this.maxCharacters))
			? 0
			: Number(this.maxCharacters);

		if (maxChars > 0 && value.length > maxChars) {
			return value.substring(0, maxChars) + "...";
		}

		return value;
	}

	get getValueNumber() {
		let value = this.item[this.propertyName]
			? this.item[this.propertyName].toString()
			: false;
		let rltvalue;
		if(value){
			rltvalue = true;
		}else{
			rltvalue = false;
		}

		return rltvalue;
	}

	getTooltip() {
		let forceShowTooltip = false;
		let value = this.item[this.propertyName]
			? this.item[this.propertyName].toString()
			: "";

		if (this.item.tooltips && this.propertyName in this.item.tooltips) {
			forceShowTooltip = true;
			value = this.item.tooltips[this.propertyName];
		}

		let maxChars = isNaN(Number(this.maxCharacters))
			? 0
			: Number(this.maxCharacters);

		if ((maxChars > 0 && value.length > maxChars) || forceShowTooltip) {
			return value;
		}

		return "";
	}

	get checkIcon() {
		return this.checkedIconFilename === ""
			? this.icons.checkDefault
			: this.icons.checkCustom;
	}

	get getRowIndex() {
		return this.rowIndex;
	}
	get getRowIndexAddOne() {
		return this.rowIndex + 1;
	}
	get isAuxTypeDefined() {
		return (
			this.isAuxTypeStandardTemperatureRanges ||
			this.isAuxTypeCustomTemperatureRanges ||
			this.isAuxTypeTemperatureControlledGroundServiceEq
		);
	}
	get isAuxTypeStandardTemperatureRanges() {
		return this.auxType === "standard_temperature_ranges";
	}
	get isAuxTypeCustomTemperatureRanges() {
		return this.auxType === "custom_temperature_ranges";
	}
	get isAuxTypeTemperatureControlledGroundServiceEq() {
		return this.auxType === "temperature_controlled_ground_service_eq";
	}
	get isAuxFieldDefined() {
		return this.isTchaTemperatureRangeField;
	}
	get isTchaTemperatureRangeField() {
		return this.propertyName.toLowerCase() === "tcha_temperature_range__c";
	}
	get isTypeDefined() {
		return this.isTypeNumber || this.isTypeTrueFalse || this.isTypeHttp || this.isCombobox;
	}
	get isCombobox(){
		return this.item[this.propertyName] === "actions";
	}
	get isTypeNumber() {
		return !isNaN(this.item[this.propertyName]);
	}
	get isTypeTrueFalse() {
		return typeof this.item[this.propertyName] === 'boolean';
	}
	get isTypeHttp() {
		let httpUrl = (this.item[this.propertyName]);
		let httpString;
		let isHttp = false;
		if (httpUrl) {
			httpString = httpUrl.toString();
			if (httpString.indexOf("www") > -1 || httpString.indexOf("https") > -1) {
				isHttp = true;
			}
		}
		return isHttp;
	}
	get getHref() {
		let httpUrl = (this.item[this.propertyName]);
		let httpString = httpUrl.toString();
		if (httpString.indexOf("https") > -1) {
			return httpString;
		}
		else {
			return "https://" + httpString;
		 }
	}

	showPopover(event) {
		let item = event.currentTarget.dataset.item;
		this.tooltipToDisplay = item;

		const text = this.getTooltip();
		let tooltipObject = {
			item: item,
			text: text,
			marginLeft: -50,
			marginTop: 32
		}

		this.tooltipObject = tooltipObject;

	}

	hidePopover() {
		this.tooltipToDisplay = "";
		this.tooltipObject = null;
	}

	get getCssClass(){
		return this.item && this.item.isNew ? "content yellow" : "content blue"; 
	}

	get getCssClassNew(){
		return this.item && this.item.isNew && this.item.isInvolvedInConflictProcess ? "content yellow" : "content";
	}

	handleConflictActionChanged(event){
		let actionToHandleConflict = event.target.value;
		this.selectedOption = event.target.value;

		let itemCopy = JSON.parse(JSON.stringify(this.item));
		itemCopy.selectedConflictAction = actionToHandleConflict;
		let targetValue;
		if(actionToHandleConflict.includes("STATUS_REPLACE")){
			let splittedValue = actionToHandleConflict.split("_");
			targetValue = splittedValue[splittedValue.length - 1];
			itemCopy.oldTarget = targetValue;
		}

		itemCopy.selectedConflictTarget = targetValue;



		this.item = JSON.parse(JSON.stringify(itemCopy));
		const newEvent = new CustomEvent("conflictactiontaken", {
			detail: {
				data: this.item
			}
		});

		this.dispatchEvent(newEvent);
	}

	get generateLabel(){
		if(!this.item.isInvolvedInConflictProcess){
			return this.getValue;
		}

		if(this.item && this.item.conflictLabel){
			return this.item.conflictLabel;
		}

		if(this.isAuxTypeStandardTemperatureRanges || this.isAuxTypeCustomTemperatureRanges){
			return this.label.room + " " + this.getRowIndexAddOne;
		}

		if(this.isAuxTypeTemperatureControlledGroundServiceEq){
			return this.label.dolly_truck + " " + this.getRowIndexAddOne;
		}

		return this.getValue + " " + this.getRowIndexAddOne;
	}
	
}
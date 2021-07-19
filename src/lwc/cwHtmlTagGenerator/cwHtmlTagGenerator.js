import { LightningElement, api, track } from "lwc";
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";
import { hideHover } from "c/cwUtilities";
import getDateExtraData from "@salesforce/apex/CW_FacilityCapabilitiesController.getDateExtraData";

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
	toolTipsDates;
	activeToolTipExtraData = "Contract_Management__c;Quality_Control_Compliance__c;Screeners_Performance__c;Security_Equipment__c;System_Assurance__c;";

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

		if (this.item && this.item.id){
			getDateExtraData({capabilityId: this.item.id}).then(result => {
				if (result){
					this.toolTipsDates = JSON.parse(result);
				}
			})
			.catch(err => console.error(err));
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
	get getValueAsText() {
		if (this.propertyName.toLowerCase() === 'year_of_manufacture__c'){
			return this.item[this.propertyName].toString();
		} else {
			return '-';
		}
	}
	get getValue() {
		if(this.isTypeTrueFalse){
			return this.item[this.propertyName];
		}
		
		let value = this.item[this.propertyName]
			? this.item[this.propertyName].toString()
			: "-";

		return value;
	}
	
	get getValueSubTitle(){
		return this.auxType === '' ? '' : this.getValue;
	}

	get getValueNumber() {
		if (this.propertyName.toLowerCase() === 'year_of_manufacture__c'){
			return false;
		}
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

		let value = this.item[this.propertyName] ? this.item[this.propertyName].toString() : "";

		// tooltip date 
		if (this.activeToolTipExtraData.split(';').indexOf(this.propertyName)){
			if (!this.toolTipsDates || this.isCommunity == false){
				return "";
			}

			if (this.item.tooltips && this.propertyName in this.item.tooltips) {
				forceShowTooltip = true;
				value = this.item.tooltips[this.propertyName];

				if (value.indexOf('{') > 0 && value.indexOf('}') > 0){
					let valueToBeReplaced = value.split('{')[1].split('}')[0];

					if (value && this.toolTipsDates){
						let dates = JSON.parse(JSON.stringify(this.toolTipsDates));

						var date;
						if (valueToBeReplaced === 'Contract_Management_Date__c'){
							date = dates.Contract_Management_Date;
						}
						else if (valueToBeReplaced === 'Quality_Control_Compliance_Date__c'){
							date = dates.Quality_Control_Compliance_Date;
						}
						else if (valueToBeReplaced === 'Screeners_Performance_Date__c'){
							date = dates.Screeners_Performance_Date;
						}
						else if (valueToBeReplaced === 'Security_Equipment_Date__c'){
							date = dates.Security_Equipment_Date;
						}
						else if (valueToBeReplaced === 'System_Assurance_Date__c'){
							date = dates.System_Assurance_Date;
						}

						if (date){
							value = value.split('{')[0] + date + value.split('}')[1];
							return value;
						}
						else{
							return "";
						}
					}
				}
			}
		}

		if (this.item.tooltips && this.propertyName in this.item.tooltips) {
			forceShowTooltip = true;
			value = this.item.tooltips[this.propertyName];
		}
		else{
			for (let property in this.item.tooltips) {
				if (property == (this.propertyName + '#' + this.item[this.propertyName].toLowerCase().replace(' ','_').replaceAll('.',''))) {
					forceShowTooltip = true;
					value = this.item.tooltips[this.propertyName + '#' + this.item[this.propertyName].toLowerCase().replace(' ','_').replaceAll('.','')];
				}
			}

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

	get containsManufacturerField(){
		return this.item['sc_manufacturer__c'] ? true : false;
	}
	
	get isAuxTypeDefined() {
		return (
			this.isAuxTypeStandardTemperatureRanges ||
			this.isAuxTypeCustomTemperatureRanges ||
			this.isAuxTypeTemperatureControlledGroundServiceEq ||
			this.isAuxTypeHandlingEquipmentInfrastructure
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
	get isAuxTypeHandlingEquipmentInfrastructure(){
		return this.auxType === "handling_equipment_infrastructure";
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
			marginLeft: (text.length > 20) ? -220 : -100,
			marginTop: 20
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
		return this.item && this.item.isNew && this.item.isInvolvedInConflictProcess && this.propertyname === 'equipment__c'? "content yellow" : "content";
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
		if(!this.item.isInvolvedInConflictProcess || this.propertyName !== 'equipment__c'){
			return this.getValue;
		}

		if(this.item && this.item.conflictLabel){
			return this.item.conflictLabel;
		}

		return this.getValue;
	}
	
	get generateLabelTemperature(){

		if(this.item && this.item.conflictLabel && this.item.isInvolvedInConflictProcess){
			return this.item.conflictLabel;
		}

		if(this.isAuxTypeStandardTemperatureRanges || this.isAuxTypeCustomTemperatureRanges){
			if (this.item.sc_manufacturer__c) {
				return this.item.sc_manufacturer__c;
			} else {
				return this.label.room + " " + this.getRowIndexAddOne;
			}
		}

		if(this.isAuxTypeTemperatureControlledGroundServiceEq){
			return this.label.dolly_truck + " " + this.getRowIndexAddOne;
		}

		return this.getValue + " " + this.getRowIndexAddOne;
	}
}
import { LightningElement, api, track } from "lwc";
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";
import getDateExtraData from "@salesforce/apex/CW_FacilityCapabilitiesController.getDateExtraData";

export default class CwCapabilitiesManagerInputs extends LightningElement {
	defaultcheckedIconFilename = "ic-tic-green.svg";
	initialized = false;
	categoriesStepDecimal = ["servicing_height_min__c","servicing_height_max__c","max_lifting_capacity_or_weight_limit__c","max_load_width_between_safety_rails__c"];

	@api checkedIconFilename = "";
	icons = {
		thermometer: ICG_RESOURCES + "/icons/thermometer.svg",
		checkDefault: ICG_RESOURCES + "/icons/ic-tic-green.svg",
		checkCustom: ICG_RESOURCES + "/icons/" + this.checkedIconFilename
	};

	@api isHeader = false;
	@api editMode;
	@api isCommunity = false;
	@api item = "";
	@api propertyName = "";
	@api rowIndex = "0";
	@api categoryIndex = "0";

	@api maxCharacters = "0";
	@api auxType = "";
	@api type = "";
	@api values =[];
	@api viewType = "";
	
	@track tooltipToDisplay = "";
	@track tooltipObject;
	toolTipsDates;

	rangeFrom;
	rangeTo;

	consData = {
		equipment:"",
		field: "",
		value: "",
		type:""
	};

	renderedCallback(){
		if(!this.initialized)
		{
			this.initialized = true;
			if(this.propertyName === 'equipment__c'){
				this.type = 'STRING';
			}
		}
		
		if(this.propertyName === 'tcha_temperature_range__c'){
			let value = this.item[this.propertyName]
			? this.item[this.propertyName].toString()
			: "";
			if(value != ""){
				var valueParse = value.toString().split("to");
				if(valueParse[0].toString().includes('ºC')){
					valueParse[0] = valueParse[0].toString().replace('ºC','');
				}
				if(valueParse[1].toString().includes('ºC')){
					valueParse[1] = valueParse[1].toString().replace('ºC','');
				}
				this.rangeFrom = valueParse[0];	
				this.rangeTo = valueParse[1];
			}else{
				this.rangeFrom = '';	
				this.rangeTo = '';
			}
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

	get getPropertyName(){
		return this.propertyName;
	}

	get isComparisonFacilityView() {
		return this.viewType === "comparison-facility-view";
	}

	get getValue() {
		let value;
		if(this.isTypeTrueFalse)
		{
			value = this.item[this.propertyName];
		}
		else
		{
			if(this.isTypeNumber){
				value = this.item[this.propertyName] > 0 ? this.item[this.propertyName] : "";
			}
			else{
				value = this.item[this.propertyName]
				? this.item[this.propertyName].toString()
				: "";
				if(this.isMultiPicklist){
					var valueParse = value.toString().split(",");
					value = valueParse;	
				}
			}
			
			return value;			
		}
		

		return value;
	}

	get getFrom(){
		return this.rangeFrom;
	}

	get getTo(){
		return this.rangeTo;
	}

	get getTooltip() {
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

	get getcategoryIndex(){
		return this.categoryIndex;
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
		return this.isTypeNumber || this.isTypeTrueFalse;
	}
	get isTypeNumber() {
		return this.type === 'DOUBLE' || this.type === 'INTEGER' || this.type === 'DECIMAL';
	}
	get isTypeDecimalorInt() {
		let isDecimalStep = this.categoriesStepDecimal.indexOf(this.propertyName)>-1;
		return ((this.type === 'INTEGER') || ((this.type === 'DOUBLE' ||  this.type === 'DECIMAL') && !isDecimalStep));
	}
	get isTypeDecimalWithStep() {
		let isDecimalStep = this.categoriesStepDecimal.indexOf(this.propertyName)>-1;
		return ((this.type === 'DOUBLE' ||  this.type === 'DECIMAL') && isDecimalStep);
	}
	get isTypeTrueFalse() {
		return this.type === 'BOOLEAN'; 
	}

	get isText(){
		return this.type === 'STRING' || this.type === 'URL';
	}

	get isEmail(){
		return this.type === 'EMAIL';
	}

	get isDate(){
		return this.type === 'DATE';
	}

	get isTextArea(){
		return this.type === 'TEXTAREA';
	}

	get isPicklist(){
		return this.type === 'PICKLIST';
	}

	get isMultiPicklist(){
		return this.type === 'MULTIPICKLIST';
	}

	get getOptions(){
		return this.values;
	}

	get getCssClass(){
		if (this.isPicklist || this.isMultiPicklist) {
			return 'picklist-scroll';
		}
		else if (this.isDate) {
			return 'capDatePicker';
		} else {
			return (this.editMode && this.propertyName !== 'equipment__c') ? 'disable-content' : '';
		}
	}

	setValue(event){
		let value = event.target.value;
		let type = event.target.type;
		let name = event.target.name;
		if(!this.editMode)
		{
			this.consData.rowIndex = this.getRowIndex.toString();
			this.consData.equipment = this.item["equipment"];
			this.consData.field = this.propertyName;
			
			if(type === "checkbox")
			{
				this.consData.value = event.target.checked;
			}
			else
			{
				if(this.isTchaTemperatureRangeField){
					value = value.toString().trim();
					if(value.includes('ºC')){
						value = value.replace('ºC','');
					}
					
					if(name === "From"){
						this.rangeFrom = value;
					}
					if(name === "To"){
						this.rangeTo = value;
					}

					let finalRange = this.rangeFrom + "ºC to " + this.rangeTo + "ºC";
					this.consData.value = finalRange;
				}
				else if(this.isTypeDefined)
				{
					this.consData.value = value != '' ? Number(value) : '';
				}
				else{					
					if(this.isMultiPicklist && value.toString().includes(',')){
						var valueParse = value.toString().replace(",",";");
						this.consData.value = valueParse;	
					}
					else{
						this.consData.value = value.toString();	
					}		
				}
			}

			const newEvent = new CustomEvent("fieldupdated", {
				detail: {
					data: this.consData
				}
			});
			this.dispatchEvent(newEvent);
		}
	}

	getTooltipMetaData() {
		let forceShowTooltip = false;
		let value = this.item[this.propertyName] ? this.item[this.propertyName].toString() : "";

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
		else{
			for (let property in this.item.tooltips) {
				if (property == (this.propertyName + '#' + this.item[this.propertyName].toLowerCase().replace(' ','_').replaceAll('.',''))) {
					forceShowTooltip = true;
					value = this.item.tooltips[this.propertyName + '#' + this.item[this.propertyName].toLowerCase().replace(' ','_').replaceAll('.','')];
				}
			}
		}

		let maxChars = isNaN(Number(this.maxCharacters)) ? 0 : Number(this.maxCharacters);
		if ((maxChars > 0 && value.length > maxChars) || forceShowTooltip) {
			return value;
		}

		return "";
	}

	showPopover(event) {
		let item = event.currentTarget.dataset.item;
		this.tooltipToDisplay = item;

		const text = this.getTooltipMetaData();
		let tooltipObject = {
			item: item,
			text: text,
			marginLeft: (text.length > 20) ? -75 : -25,
			marginTop: 0
		}
		
		this.tooltipObject = tooltipObject;
	}

	hidePopover() {
		this.tooltipToDisplay = "";
		this.tooltipObject = null;
	}
}
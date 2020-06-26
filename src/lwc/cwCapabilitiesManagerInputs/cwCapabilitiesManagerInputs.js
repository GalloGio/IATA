import { LightningElement, api } from "lwc";
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";

export default class CwCapabilitiesManagerInputs extends LightningElement {
	defaultcheckedIconFilename = "ic-tic-green.svg";
	initialized = false;

	@api checkedIconFilename = "";
	icons = {
		thermometer: ICG_RESOURCES + "/icons/thermometer.svg",
		checkDefault: ICG_RESOURCES + "/icons/ic-tic-green.svg",
		checkCustom: ICG_RESOURCES + "/icons/" + this.checkedIconFilename
	};

    @api isHeader = false;
    @api editMode;
	@api item = "";
	@api propertyName = "";
	@api rowIndex = "0";
	@api categoryIndex = "0";

	@api maxCharacters = "0";
	@api auxType = "";
	@api type = "";
	@api values =[];
	@api viewType = "";

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
			//this.consData = JSON.parse(JSON.stringify(this.item));
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
			value = this.item[this.propertyName]
			? this.item[this.propertyName].toString()
			: "";
			if(this.isMultiPicklist){
				var valueParse = value.toString().split(",");
				value = valueParse;	
			}
			return value;			
		}
		

		return value;
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
		return this.isTypeNumber || this.isTypeTrueFalse;
	}
	get isTypeNumber() {
		return this.type === 'DOUBLE' || this.type === 'INTEGER' || this.type === 'DECIMAL';
	}
	get isTypeTrueFalse() {
		return this.type === 'BOOLEAN'; 
	}

	get isText(){
		return this.type === 'STRING' || this.type === 'URL';
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

	setValue(event){
		let value = event.target.value;
		let type = event.target.type;

		if(!this.editMode)
		{
			
			this.consData.rowIndex = this.getRowIndex.toString();
			this.consData.equipment = this.item["equipment_value"];
			this.consData.field = this.propertyName;
			
			if(type === "checkbox")
			{
				this.consData.value = event.target.checked;
			}
			else
			{
				if(this.isTypeDefined)
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

			// if(type === "checkbox" || (type !== "checkbox" && value)){
			// 	const newEvent = new CustomEvent("fieldupdated", {
			// 		detail: {
			// 			data: this.consData
			// 		}
			// 	});
			// 	this.dispatchEvent(newEvent);
			// }
		}
	}

}
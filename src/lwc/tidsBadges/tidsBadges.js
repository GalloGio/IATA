import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from 'c/tidsPubSub';

export default class TidsBadges extends LightningElement {
	
	@api options;
	@api question;
	@api maximum = 1;
	@api fieldName;
	@api rule = {
		visible: false,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_japanese:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};
	

	@track optionsSelected = [];  
	@track optionsError;
	@track values = [];
	@track defaultClass = 'row items-badges';
	@track disableClass = 'row items-badges cmp-disabled';
	@track cmpClass;

	@wire(CurrentPageReference) pageRef;

	@api 
	get values() {
		return this.values;
	}

	set values(props) {
		this.values = props;
	}

	connectedCallback() {
		this.optionsError = false;
		this.values = JSON.parse(JSON.stringify(this.options));
		this.cmpClass = this.disabled ? this.disableClass : this.defaultClass
		this.values.forEach(item => {
			if(item.isSelected) {
				this.optionsSelected.push({label: item.label, value: item.value});
			}
		});
	}

	handleOnClick(event) {
		event.preventDefault();
		let oSelected = event.target.dataset.option;

		let optionIndex = this.values.findIndex(x => x.value === oSelected);
		let indexpos = this.optionsSelected.findIndex(x => x.value === oSelected);

		if(indexpos !== -1){
			this.optionsError = false;
			this.values[optionIndex].isSelected = !this.values[optionIndex].isSelected;
			this.optionsSelected.splice(indexpos,1);
		} else if(this.optionsSelected.length < this.maximum){
			this.optionsError = false;
			this.values[optionIndex].isSelected = !this.values[optionIndex].isSelected;
			this.optionsSelected.push({label: this.values[optionIndex].label, value: this.values[optionIndex].value});
		} else {
			this.optionsError = true;
		}
		
		let result = {
			fieldName: this.fieldName, 
			valid: Number(this.optionsSelected.length) === Number(this.maximum) ? true: false,
			values: this.optionsSelected
		}

		fireEvent(this.pageRef,'badgeListener',result);

	}
}
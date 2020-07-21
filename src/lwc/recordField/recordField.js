import { LightningElement, api, track } from 'lwc';

export default class RecordField extends LightningElement {
	@api properties;
	@api record;
    @api recordIndex;
	@api records;
    @track _value;
    _recordFieldClass = 'slds-col record-field';
//    _defaultValue = null;

	/** Comes from record collection */
	@api variant = 'base';

	@api get value(){
        //console.log('getting value', this.properties.targetField, this._value, this.record[this.properties.targetField]);
		return !this.variant.includes('table-column') ?
				(this._value === undefined || this._value === null ?
                	(this.record !== undefined && this.record !== null && this.record[this.properties.targetField] !== undefined ? 
                    	this.record[this.properties.targetField] 
                    	: null ) 
					: this._value ):
				this.calculatedColumn;
    }

    set value(v){
        this._value = v;
        this.record[this.properties.targetField] = v;
	}

	get calculatedColumn() {
		let result = 0;

		if(this.variant.includes('total')){
			if(this.properties.type !== 'number'){
				return NaN;
			}
			this.records.forEach(currentRecord => {
				result += parseFloat(currentRecord[this.properties.targetField]);
			});
		}
		
		return result;
	}

/*    @api
    get defaultValue(){
        return this._defaultValue;
    }
    set defaultValue(v){
        this._defaultValue = v;
    }*/

    get disabled(){
        if(this.properties.disabled === undefined){
            return false;
        }
        else if(typeof this.properties.disabled === "function"){
            return this.properties.disabled(this.record, this.recordIndex, this.records);
        }
        return eval(this.properties.disabled);
	}
	
	get readonly(){
		return this.variant.includes('table');
	}

    get display(){
        if(this.properties.display === undefined){
            return true;
        }
        else if(typeof this.properties.display === "function"){
            return this.properties.display(this.record, this.recordIndex, this.records);
        }
        return eval(this.properties.display);
    }

    get required(){
        return this.properties.required;
	}
	
	get inputVariant(){
		return this.variant.includes('table') || this.recordIndex > 0 ? 'label-hidden' : 'standard';
	}

    get min(){
        return this.properties.min;
    }

    get max(){
        return this.properties.max;
    }

    get rangeOverFlowMessage(){
        return this.properties.rangeOverFlowMessage;
    }

    get rangeUnderflowMessage(){
        return this.properties.rangeUnderflowMessage;
    }

    get recordFieldClass(){
		return this._recordFieldClass + 
				(!this.display ? ' record-field__hidden' : '') +
				(this.variant === 'table' ? ' record-field__table-cell' : '');
    }

    get label(){
		return this.variant.includes('table') ?
				this.properties.label :
				this.recordIndex === 0 ? 
					this.properties.label :
					null;
    }

    get locked(){
        return this.properties.type === "locked";
    }

    get hidden(){
        return this.properties.type === "hidden";
    }

    get picklist(){
        return this.properties.type === "picklist";
    }

    get text(){
        return this.properties.type === "text";
    }

    get number(){
        return this.properties.type === "number";
    }

    get percent(){
        return this.properties.type === "percent";
    }

    get currency(){
        return this.properties.type === "currency";
    }

    get isTable() {
		return this.variant.indexOf("table") > -1;
	}

	get title() {
		return this.properties.displayTitleAsValue ?
			this.value :
			this.properties.displayTitleAsLabel ?
				this.label :
				null;
	}

	get infotext() {
		if(this.properties.info === undefined){
            return false;
        }
        else if(typeof this.properties.info === "function"){
            return this.properties.info(this.record, this.recordIndex, this.records);
		}
        return this.properties.info;
	}

	get infoStyle() {
		if(this.properties.infoStyle === undefined) {
			return null;
		}
		return this.properties.infoStyle;
	}

    connectedCallback(){
        //console.log(JSON.parse(JSON.stringify(this.properties)));
    }

    handleChange(e){
        //console.log(e);
        this.dispatchEvent(
            new CustomEvent(
                'recordfieldupdate', 
                {
                    detail: {
                        field: this.properties,
                        value: e.currentTarget.value,
                        oldValue: this.value,
                        label: this.properties.type === 'picklist' ? this.properties.options.filter(o => {return o.value === e.currentTarget.value;})[0].label : '',
                        recordIndex: this.recordIndex
                    }
                }
            )
        );
    }

    @api checkValidity(){
        let combobox = this.template.querySelectorAll('lightning-combobox');
        let inputs = this.template.querySelectorAll('lightning-input');
        let allFields = [...inputs, ...combobox];
        
        let allValid = allFields.reduce((validSoFar, inputCmp) => {
            if(!this.display || this.disabled){
                return validSoFar && true;
            }
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    @api reportValidity(){
        let combobox = this.template.querySelectorAll('lightning-combobox');
        let inputs = this.template.querySelectorAll('lightning-input');
        let allFields = [...inputs, ...combobox];
        console.log(allFields)
        let allValid = allFields.reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

}
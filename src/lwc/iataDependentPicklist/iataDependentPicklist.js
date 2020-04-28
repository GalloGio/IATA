import { LightningElement, api, track } from 'lwc';

export default class IataDependentPicklist extends LightningElement {
	
	@track _fields = [];
	@track _fieldList = [];
	initialized = false;
	parentTracker = [];
	
	@api parent = null;
	/**variant: cols | rows */
	@api variant = 'cols';
	@api colSize = 3;

	@api
	get fields() {
		return this._fields;
	}

	set fields(incomingFields) {
		this._fields = incomingFields;
		if(this.initialized) {
			this.initialize();
		}
	}

	@api get fieldList() {
		return this._fieldList
	}

	connectedCallback() {
		this.initialize();
	}

	initialize() {
		let fieldset = JSON.parse(JSON.stringify(this.fields));
		fieldset = this.computeFields(fieldset, null);
		//fieldset = this.updateVisibility(fieldset, this.parent);
		//this.fields = fieldset;
		fieldset = this.flattenFields(fieldset);
		this._fieldList = fieldset;
        this.updateVisibility();
		this.initialized = true;
	}

	flatten(treeObj, idAttr, parentAttr, childrenAttr, levelAttr) {
		if (!idAttr) idAttr = 'id';
		if (!parentAttr) parentAttr = 'parent';
		if (!childrenAttr) childrenAttr = 'children';
		if (!levelAttr) levelAttr = 'level';
	
		function flattenChild(childObj, parentId, level) {
			var array = []; 
	
			//var childCopy = Object.assign({}, childObj);
			childObj[levelAttr] = level;
			childObj[parentAttr] = parentId;
			//delete childObj[childrenAttr];
			array.push(childObj);
	
			array = array.concat(processChildren(childObj, level));
	
			return array;
		};
	
		function processChildren(obj, level) {
			if (!level) level = 0;
			var array = [];
			if(obj[childrenAttr]){
				obj[childrenAttr].forEach(function(childObj) {
					array = array.concat(flattenChild(childObj, obj, level+1));
				});
			}
			delete obj[childrenAttr];
			return array;
		};
	
		var result = processChildren(treeObj);
		return result;
	};

    flattenFields(fieldset){
		let globalList = [];
		fieldset.forEach(field => {
            let currentList = {id: field.name, fields: []};
            currentList.fields.push(field);
            currentList.fields = currentList.fields.concat(this.flatten(field, 'name', 'parent', 'dependent', null));
            globalList.push(currentList);
		})
		console.log('fields', globalList);
		return globalList;
    }

	computeFields(currentSet, parent){
		let c = 0;
		currentSet.forEach(field => {
			if(field.dependent !== undefined && field.dependent !== null && field.dependent.length > 0){
				field.dependent = this.computeFields(field.dependent, field);
			}

            this.parentTracker = Object.assign(this.parentTracker, { [field.name] : parent});
			field['_key'] = field.name + '_' + c;
			field['_isPicklist'] = 'picklist' === field.type || 'multiselectpicklist' === field.type;
			field['_isMultiSelectPicklist'] = 'multiselectpicklist' === field.type;
			field['_isDualListbox'] = 'dualistbox' === field.type;
			field['_isPopupForm'] = 'popupform' === field.type;
			field['_isRadioGroup'] = 'radiogroup' === field.type;
			field['_isCheckbox'] = 'checkbox' === field.type;
			field['_isButton'] = 'button' === field.type;
			field['_isOpenInput'] = !field._isPicklist 
										&& !field._isDualListbox
										&& !field._isPopupForm
										&& !field._isRadioGroup
										&& !field._isCheckbox
										&& !field._isButton;
			field['_colSize'] = this.getInnerColsSize(field);
            if(field.dependency !== 'options'){
				field['_options'] = field.options;
			}
			if(field.options !== undefined && field.options !== null && field.options.length > 0){
				let selectedItems = field.options.filter(o => {return o.selected === true});
				if(selectedItems.length > 0){
					field.value = selectedItems[0].value;
				}
			}
			field['_padding'] = 'slds-var-p-' + field.padding.replace("-", "_");
			field['_visible'] = true;

			c++;
		});
		return currentSet;
	}

	updateVisibility(updatedField = null){
		this.fieldList.forEach(fieldset => {
            fieldset.fields.forEach(field => {
                field['_visible'] = 
                    (field.parent === undefined 
                        || field.parent === null 
                        || (field.dependency === 'options' && field.parent._visible)
						|| (field.dependency === 'visibility' && field.masterValue === field.parent.value));
                if(field.dependency === 'options' && ( updatedField === null || this.isParent(field, updatedField) ) ) {
                    field['_options'] = field.options.filter(o => { 
						return Array.isArray(o.masterValue) ?
							o.masterValue.indexOf(field.parent.value) > -1 :
							o.masterValue === field.parent.value; } );
                }
                if(field.parent !== undefined && field.parent !== null && field.disabledOnEmptyOptions){
                    field.disabled = field._options === undefined || field._options === null || field._options.length === 0;
				}
				if(this.isParent(field, updatedField)){
					if(field._isMultiSelectPicklist || field._isPopupForm || field._isDualListbox){
						field.value = [];
					}
					else {
						field.value = null;
					}
					
					this.dispatchEvent(
						new CustomEvent("change", {detail: {value: field.value, name: field.value, rootField: updatedField}} )
					);
				}
		    });
        });
	}

	isParent(field, parentName){
		return field.parent !== undefined && field.parent !== null && (field.parent.name === parentName || this.isParent(field.parent, parentName)); 
	}

	@api
	setValue(fieldName, fieldValue) {
		this.handleChange({target: {name: fieldName, value: fieldValue}});
	}

	handleChange(e) {
		let sourceField = e.target;
		this.fieldList.forEach(fieldset => {
            fieldset.fields.forEach(field => {
                if(field.name === sourceField.name){
                    field.value = sourceField.value;
                }
            });
        });
        this.updateVisibility(sourceField.name);
		
		this.dispatchEvent(
            new CustomEvent("change", {detail: {value: e.target.value, name: e.target.name}} )
		);
	}

	handleClick(e) {
		e.preventDefault();
		this.dispatchEvent(
			new CustomEvent("click", {detail: {name: e.target.name, label: e.target.label}})
		);
	}

	handlepicklistopen(e){
		e.preventDefault();
		this.dispatchEvent(
			new CustomEvent("picklistopen", {detail: {name: e.target.name, label: e.target.label, top: e.target.offsetTop}})
		);
	}

	get displayInCols() {
		return 'cols' === this.variant;
	}

	get displayInRows() {
		return 'rows' === this.variant;
	}

	get isRoot() {
		return this.parent === undefined || this.parent === null;
	}

	get outerColsSize() {
		return this.displayInRows ? '12' : Math.floor(12/this.fields.length);
	}

    getInnerColsSize(field) {
		return field.colSize ?
				field.colSize :
				this.displayInRows ? 
        		    field._isDualListbox || field.pillFilters ?
                		this.colSize * 2 :
                		this.colSize :
            			12;
    }

    get innerComponentClass() {
		return 'slds-col';
	}
}
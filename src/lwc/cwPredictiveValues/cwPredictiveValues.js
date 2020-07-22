import { LightningElement, api, track } from "lwc";
import { translationTextJS, translationUmlauteTextJS } from "c/cwUtilities";


export default class CwPredictiveValues extends LightningElement {
	@api customstyle;
	@api eventnameinput;

	@track _displayBox;
	@track isPredictiveFocused;
	@track _hideBottomSection = false;
	@track _predictiveList;
	@track firstRow;

	@api
	get predictivevalues() {
		return this._predictiveList;
	}
	set predictivevalues(value) {
		this._predictiveList = value;
	}

	@api
	get firstRowWritten() {
		return this.firstRow;
	}
	set firstRowWritten(value) {
		this.firstRow = value;
		this.firstRowInitialized = false;
	}

	@api
	get hideBottomSection() {
		return this._hideBottomSection;
	}
	set hideBottomSection(value) {
		this._hideBottomSection = value;
	}

	@api
	get displayTheBox() {
		return this._displayBox;
	}
	set displayTheBox(value) {
		if (value) {
			this._displayBox = value;
		} else {
			setTimeout(() => {
				this._displayBox = value;
			}, 150);
		}
	}

	initialized = false;
	firstRowInitialized = false;

	renderedCallback() {
		if(this.firstRow && !this.firstRowInitialized && this.firstRow.length > 2) {
			this._prepareWrittingRow();
		}

		if (this.initialized) {
			return;
		}
		this.isPredictiveFocused = false;
		this.initialized = true;
	}

	_prepareWrittingRow() {
		this.firstRowInitialized = true;
	
		const firstRowWrapper = {
			key: "Results",
			techkey: "",
			searchValues: "",
			value: "*",
			label: this.firstRow,
			type: "firstrow",
			icon: "",//"icon-search-by-location-ico",
			description: "",
			code: null
		}

		let newListPredictive = JSON.parse(JSON.stringify(this._predictiveList));
		newListPredictive.unshift(firstRowWrapper);
		this._predictiveList = newListPredictive;

		this._countValuesInput(firstRowWrapper, this._predictiveList);
	}

	_countValuesInput(inputWrapper, listWrappers) {
		let rowInput = JSON.parse(JSON.stringify(inputWrapper));
		rowInput.value = 0;
		let stationsIdsChecked = [];
		listWrappers.filter(entry => {

			const hasSearchValues = entry.searchValues
			&& (entry.searchValues.toLowerCase().indexOf(translationTextJS(rowInput.label) > -1)
				|| entry.searchValues.toLowerCase().indexOf(translationUmlauteTextJS(rowInput.label)) > -1);

			if (hasSearchValues || entry.stationsIds) {
				if(entry.stationsIds) {
					let counter = 0;
					entry.stationsIds.split('#').forEach(stid => {
						if(stid && stid != 'null' && !stationsIdsChecked.includes(stid)) {
							counter++;
							stationsIdsChecked.push(stid);
						}
					})
					rowInput.value+=counter;
				}
				else{
					rowInput.value += entry.value;
				}
			} 
			
		});

		let newListPredictive = JSON.parse(JSON.stringify(this._predictiveList));
		newListPredictive.splice(0, 1, rowInput);
		this._predictiveList = newListPredictive;
	}

	getlivalue(event) {
		if (!event || !event.currentTarget.dataset.tosca) {
			return;
		}
		const key = event.currentTarget.dataset.tosca;
		const basekey = event.currentTarget.dataset.basekey;
		const infoDescription = event.currentTarget.dataset.description;
		const countvalues = event.currentTarget.dataset.value;
		const name = event.currentTarget.dataset.label;
		const type = event.currentTarget.dataset.type;
		const code = event.currentTarget.dataset.code;
		const icon = event.currentTarget.dataset.icon;
		this.dispatchEvent(
			new CustomEvent(this._getNameCustomEvent(), {
				detail: {
					value: name,
					item: key,
					description: infoDescription,
					code: code,
					countValues: countvalues,
					type: type,
					icon: icon,
					basekey : basekey
				}
			})
		);
	}

	_getNameCustomEvent() {
		return this.eventnameinput ? this.eventnameinput : "predictivevalueselected";
	}

	get displayClasses() {
		let baseClass = "text-left bg-white pos-absolute top-index width-100 ul-predictive ";
		baseClass += this.customstyle ? this._addCustomStyles() : "";
		return baseClass;
	}

	_addCustomStyles() {
		let styles = "";
		switch (this.customstyle) {
			case "resultpage":
				styles = "content-width-resultsPage";
				break;
			case "advancedsearch":
				styles = "content-width-resultsPage";
				break;
			case "landing":
				// styles = 'content-width-resultsPage';
				break;
			case "wizard":
				styles = "display-contents";
				break;
			default:
		}
		return styles;
	}
}
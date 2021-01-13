import { LightningElement, track, api, wire } from "lwc";
import getAllAirlines from "@salesforce/apex/CW_HandledAirlinesController.getAllAirlines";
import icons from "@salesforce/resourceUrl/ICG_Resources";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";

export default class CwHandledAirlines extends LightningElement {
	tickSelection = icons + "/icons/ic-tic-blue.svg";
	initialized;
	urlsAdded;
	@track pageSelected = 1;
	@track letterSelected;
	@track showOnlySelected = false;
	localSelectedAirlines;
	@api recordType;
	@api label;
	@api facilityId;
	@track offSetNum = 0;
	@track airlines = [];
	@api create = false;

	filter;
	@api
	get filterText() {
		return this.filter;
	}
	set filterText(val) {
		this.filter = val;
		if (this.letterSelected) this.unselectLetter();
	}
	_rawData;
	@api
	get rawData() {
		return this._rawData;
	}
	set rawData(value) {
		this._rawData = value;
		this.addAirlineHandledHeadersJS(this.rawData);
		this.addUrlToRecords();
	}
	readonly;
	@api
	get isreadonly() {
		return this.readonly;
	}
	set isreadonly(val) {
		this.readonly = val;
		this.showOnlySelected = val;
	}
	@api
	get preselectedAirlines() {
		return this.localSelectedAirlines;
	}
	set preselectedAirlines(values) {
		this.localSelectedAirlines = values;
		if (this.airlines) {
			this.airlines = this.manageSelected();
		}
	}
	urlBaseFacilityPage;

	@wire(getURL, { page: "URL_ICG_FacilityPage" })
	wiredFacilityUrl({ data }) {
		if (data) {
			this.urlBaseFacilityPage = data;
			this.addUrlToRecords();
		}
	}
	addUrlToRecords() {
		if (this.urlBaseFacilityPage && this.airlines && !this.urlsAdded) {
			this.airlines.forEach(airline => {
				if (airline.value && airline.value.indexOf("001") !== 0) {
					airline.url = this.urlBaseFacilityPage + "?eid=" + airline.value;
				}
			});
			this.urlsAdded = true;
		}
	}

	addAirlineHandledHeaders(airlinesdata) {
		return new Promise((resolve, reject) => {
			let prevLetter;
			let prevChar;
			let airlinesDummy = [];
			try {
				airlinesdata.forEach(airline => {
					let airlineInfo = this.generateAirlineInfoObj(airline);

					let character = airlineInfo.label.charAt(0);

					if (character.match(/[a-z]/i)) {
						if (!prevLetter || prevLetter != character.toUpperCase()) {
							this.airlines.push({ label: character.toUpperCase(), isHeader: true });
						}
						prevLetter = character.toUpperCase();
						this.airlines.push(airlineInfo);
					} else {
						if (!prevChar || prevChar != character.toUpperCase()) {
							airlinesDummy.push({ label: character.toUpperCase(), isHeader: true });
						}
						prevChar = character.toUpperCase();
						airlinesDummy.push(airlineInfo);
					}
				});
				resolve(airlinesDummy);
			} catch (err) {
				reject(err);
			}
		});
	}

	generateAirlineInfoObj(airline) {
		let airlineInfo;
		if (!airline.label) {
			airlineInfo = {
				value: airline.Id,
				label: airline.Name,
				selected: false,
				clickable: true
			};
		} else {
			airlineInfo = JSON.parse(JSON.stringify(airline));
		}

		if (airline.Airline_designator__c) {
			airlineInfo.label += " [" + airline.Airline_designator__c + "]";
		}

		return airlineInfo;
	}

	selectAirline(event) {
		event.preventDefault();
		if (this.isreadonly === true) return;
		let eTarget = event.currentTarget;
		eTarget.classList.add("itemSelectedPrivate");
		this.airlines.forEach(elem => {
			if (elem.value === eTarget.dataset.name) {
				elem.selected = !elem.selected;
			}
		});
		this.dispatchEvent(new CustomEvent("selectairlines", { detail: this.allSelectedAirlines }));
	}

	showHideSelectedAirlines() {
		this.unselectLetter();
		this.showOnlySelected = !this.showOnlySelected;
	}

	selectLetter(event) {
		this.pageSelected = 1;
		this.letterSelected = event.currentTarget.dataset.letter;
		this.template.querySelectorAll(".letterSelected").forEach(elem => {
			elem.classList.remove("letterSelected");
		});

		this.template.querySelector('[data-letter="' + this.letterSelected + '"]').classList.add("letterSelected");
	}
	unselectLetter() {
		this.pageSelected = 1;
		this.letterSelected = null;
		this.template.querySelectorAll(".letterSelected").forEach(elem => {
			elem.classList.remove("letterSelected");
		});
		this.template.querySelector('[data-letter="ALL"]').classList.add("letterSelected");
	}
	next() {
		this.pageSelected++;
	}
	back() {
		this.pageSelected--;
	}

	get allAirlinesToShow() {
		let firstAirlines = this.generateAirlinesToShow(0, 5);
		let secondAirlines = this.generateAirlinesToShow(5, 10);
		let thirdAirlines = this.generateAirlinesToShow(10, 15);

		let allAirlines = [];
		allAirlines.push({
			label: "first",
			value: firstAirlines
		});
		allAirlines.push({
			label: "second",
			value: secondAirlines
		});
		allAirlines.push({
			label: "third",
			value: thirdAirlines
		});
		return allAirlines;
	}

	generateAirlinesToShow(numberAirlineSum, numberAirlineLoopSum) {
		let airlinesToLoop = this.showOnlySelected ? this.selectedAirlines : this.filteredAirlines;
		if (airlinesToLoop && airlinesToLoop.length >= this.pageSelected + numberAirlineSum) {
			return airlinesToLoop.slice((this.pageSelected - 1) * 15 + numberAirlineSum, (this.pageSelected - 1) * 15 + numberAirlineLoopSum);
		}
		return [];
	}

	get selectedAirlines() {
		
		let selectedAirlines = [];
		let prevIsHeader = true;
		this.filteredAirlines.forEach(airline => {
			if (airline.isHeader || airline.selected) {
				if (selectedAirlines.length > 0 && prevIsHeader && airline.label.charAt(0).toLowerCase() != selectedAirlines[selectedAirlines.length - 1].label.toLowerCase()) selectedAirlines.pop();
				prevIsHeader = airline.isHeader;

				selectedAirlines.push(airline);
			}
		});
		if (selectedAirlines.length > 0 && selectedAirlines[selectedAirlines.length - 1].isHeader) {
			selectedAirlines.pop();
		}
		return selectedAirlines;
	}
	get allSelectedAirlines() {
		return this.airlines.filter(airline => airline.selected === true);
	}

	/****************************************************************************
	 * @Method			: allSelectedAirlinesFiltered
	 * @Created			: 08/01/2020
	 * @Description		: get all the related airlines filtered by record type for the facility
	 * @Returns			: all airlines filtered by record type
	 ****************************************************************************/
	get allSelectedAirlinesFiltered() {
		return this.airlinesFiltered.filter(airline => airline.selected === true || airline.isHeader === true);
	}

	/****************************************************************************
	 * @Method			: selectedAirlinesFiltered
	 * @Created			: 08/01/2020
	 * @Description		: get all the related airlines filtered by record type for the facility for one letter
	 * @Returns			: all airlines filtered by record type for one letter
	 ****************************************************************************/
	get selectedAirlinesFiltered() {
		let selectedAirlines = [];
		let prevIsHeader = true;
		this.filteredAirlines.forEach(airline => {
			if (this.facilityRelationShips.find(facility => facility === airline.value)) {
				airline.selected = true;
			}
			if (airline.isHeader || airline.selected) {
				if (selectedAirlines.length > 0 && prevIsHeader && airline.label.charAt(0).toLowerCase() != selectedAirlines[selectedAirlines.length - 1].label.toLowerCase()) selectedAirlines.pop();
				prevIsHeader = airline.isHeader;

				selectedAirlines.push(airline);
			}
		});
		if (selectedAirlines.length > 0 && selectedAirlines[selectedAirlines.length - 1].isHeader) selectedAirlines.pop();
		return selectedAirlines;
	}

	//First filter - By Letter
	get letterFilteredAirlines() {
		if (!this.letterSelected) {
			return this.airlines;
		} else {
			let filteredAirlines = [];
			this.airlines.forEach(airline => {
				if ((airline.isHeader && airline.label.toLowerCase() === this.letterSelected.toLowerCase()) || this.letterSelected.toLowerCase() === airline.label.charAt(0).toLowerCase()) filteredAirlines.push(airline);
			});
			return filteredAirlines;
		}
		/*}*/
	}

	//Last Filter - Sum of all filters
	get filteredAirlines() {
		if (!this.filterText) {
			return this.letterFilteredAirlines;
		} else {
			let filteredAirlines = [];
			let prevIsHeader = true;
			this.letterFilteredAirlines.forEach(airline => {
				if (airline.isHeader || airline.label.toLowerCase().indexOf(this.filterText.toLowerCase()) > -1) {
					if (filteredAirlines.length > 0 && prevIsHeader && airline.label.charAt(0).toLowerCase() != filteredAirlines[filteredAirlines.length - 1].label.toLowerCase()) filteredAirlines.pop();
					prevIsHeader = airline.isHeader;
					filteredAirlines.push(airline);
				}
			});
			if (filteredAirlines.length > 0 && filteredAirlines[filteredAirlines.length - 1].isHeader) filteredAirlines.pop();
			return filteredAirlines;
		}
	}

	get showHideSelectedAirlinesButtonText() {
		return this.showOnlySelected ? this.label.icg_show_all : this.label.icg_show_selected;
	}

	get showBackButton() {
		return this.pageSelected > 1;
	}
	get showNextButton() {
		let list = this.showOnlySelected ? this.selectedAirlines : this.filteredAirlines;
		let listSize = list ? list.length : 15;
		return (this.pageSelected - 1) * 15 + 15 < listSize;
	}
	get readonlystyle() {
		return this.isreadonly ? "itemBase itemUnselected text-truncate cursor-default" : "itemBase itemUnselected text-truncate";
	}

	get adminmodeUnselected() {
		return "itemBase itemUnselected text-truncate cursor-default";
	}

	get adminmodeSelected() {
		return "itemBase itemSelectedPrivate text-truncate cursor-default";
	}

	renderedCallback() {
		this.LoadData();
	}
	
	LoadData(){
		if (!this.initialized) {
			if (!this.rawData) {
				getAllAirlines().then(data => {
					if (data) {
						data = JSON.parse(data);
						this.addAirlineHandledHeadersJS(data);
					}
				});
			}
			this.initialized = true;
		}
	}

	addAirlineHandledHeadersJS(data) {
		this.airlines = [];
		this.addAirlineHandledHeaders(data).then(airlinesAndHeaders => {
			this.airlines.push(...airlinesAndHeaders);
			if (this.preselectedAirlines) {
				this.airlines = this.manageSelected();
			}else if(this.create){
				this.airlines = this.unSelectedAirlines();
			}
		});
	}

	manageSelected() {
		return this.airlines.map(airline => {
			airline.selected = this.preselectedAirlines.some(preselected => airline.value === preselected.value);
			return airline;
		});
	}

	unSelectedAirlines() {
		return this.airlines.map(airline => {
			airline.selected = false;
			return airline;
		});
	}
	
	@api RefreshData(){
		this.initialized = false;
		this.LoadData();
	}
}

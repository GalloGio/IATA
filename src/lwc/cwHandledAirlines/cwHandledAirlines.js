import { LightningElement, track, api,wire } from "lwc";
import getAllAirlines from "@salesforce/apex/CW_HandledAirlinesController.getAllAirlines";
//import getAirlinesByRT from "@salesforce/apex/CW_HandledAirlinesController.getAirlinesByRT";
//import getRelatedAirlinesByRT from "@salesforce/apex/CW_HandledAirlinesController.getRelatedAirlinesByRT";
import icons from "@salesforce/resourceUrl/ICG_Resources";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";

export default class CwHandledAirlines extends LightningElement {
	tickSelection = icons + "/icons/ic-tic-blue.svg";
	initialized;
	urlsAdded;
	@track pageSelected = 1;
	@track letterSelected;
	@track showOnlySelected = false;
	_preselectedAirlines;
	@api recordType;
	@api label;
	@api facilityId;
	@track offSetNum = 0;
	@track _filterText;
	@api
	get filterText() {
		return this._filterText;
	}
	set filterText(val) {
		this._filterText = val;
		if (this.letterSelected) this.unselectLetter();
	}
	@api rawData;
	@track _isreadonly;
	@api
	get isreadonly() {
		return this._isreadonly;
	}
	set isreadonly(val) {
		if (val === true) {
			this._isreadonly = true;
			this.showOnlySelected = true;
		} else {
			this._isreadonly = false;
			this.showOnlySelected = false;
		}
	}
	@api
	get preselectedAirlines() {
		return this._preselectedAirlines;
	}
	set preselectedAirlines(values) {
		this._preselectedAirlines = values;
		if (this.airlines) {
			this.airlines.forEach(airline => {
				this._preselectedAirlines.forEach(preselected => {
					if (airline.value === preselected.value) airline.selected = true;
					//else airline.selected = false;
				});
			});
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
	addUrlToRecords(){
		if(this.urlBaseFacilityPage && this.airlines && !this.urlsAdded){
			this.airlines.forEach(airline => {
				if(airline.value && airline.value.indexOf('001') !== 0) airline.url = this.urlBaseFacilityPage+'?eid='+airline.value;
			});
			this.urlsAdded = true;
		}
	}

	@track airlines = [];
	addAirlineHandledHeaders(airlinesdata) {
		return new Promise((resolve, reject) => {
			let prevLetter;
			let prevChar;
			let airlinesDummy = [];
			try {
				airlinesdata.forEach(airline => {
					let airlineInfo;
					if(!airline.label){
						airlineInfo = {
							value: airline.Id,
							label: airline.Name,
							selected: false,
							clickable: true
						};
					}else{
						airlineInfo = JSON.parse(JSON.stringify(airline));
					}
					
					if (airline.Airline_designator__c) airlineInfo.label += " [" + airline.Airline_designator__c + "]";
					if (airlineInfo.label.charAt(0).match(/[a-z]/i)) {
						if (!prevLetter || prevLetter != airlineInfo.label.charAt(0).toUpperCase()) {
							this.airlines.push({ label: airlineInfo.label.charAt(0).toUpperCase(), isHeader: true });
						}
						prevLetter = airlineInfo.label.charAt(0).toUpperCase();
						this.airlines.push(airlineInfo);
					} else {
						if (!prevChar || prevChar != airlineInfo.label.charAt(0).toUpperCase()) {
							airlinesDummy.push({ label: airlineInfo.label.charAt(0).toUpperCase(), isHeader: true });
						}
						prevChar = airlineInfo.label.charAt(0).toUpperCase();
						airlinesDummy.push(airlineInfo);
					}
				});
				resolve(airlinesDummy);
			} catch (err) {
				reject(err);
			}
		});
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
		let firstAirlines = this.airlinesFirst();
		let secondAirlines = this.airlinesSecond();
		let thirdAirlines = this.airlinesThird();
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

	airlinesFirst() {
		let dummyAirlines = [];
		let airlinesToLoop;
		if (this.showOnlySelected) airlinesToLoop = this.selectedAirlines;
		else airlinesToLoop = this.filteredAirlines;
		if (airlinesToLoop && airlinesToLoop.length >= this.pageSelected) return airlinesToLoop.slice((this.pageSelected - 1) * 15, (this.pageSelected - 1) * 15 + 5);
		return dummyAirlines;
	}

	airlinesSecond() {
		let dummyAirlines = [];
		let airlinesToLoop;
		if (this.showOnlySelected) airlinesToLoop = this.selectedAirlines;
		else airlinesToLoop = this.filteredAirlines;
		if (airlinesToLoop && airlinesToLoop.length >= this.pageSelected + 5) return airlinesToLoop.slice((this.pageSelected - 1) * 15 + 5, (this.pageSelected - 1) * 15 + 10);
		return dummyAirlines;
	}

	airlinesThird() {
		let dummyAirlines = [];
		let airlinesToLoop;
		if (this.showOnlySelected) airlinesToLoop = this.selectedAirlines;
		else airlinesToLoop = this.filteredAirlines;
		if (airlinesToLoop && airlinesToLoop.length >= this.pageSelected + 10) return airlinesToLoop.slice((this.pageSelected - 1) * 15 + 10, (this.pageSelected - 1) * 15 + 15);
		return dummyAirlines;
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
		if (selectedAirlines.length > 0 && selectedAirlines[selectedAirlines.length - 1].isHeader) selectedAirlines.pop();
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
		if (this.showOnlySelected) return this.label.icg_show_all;
		return this.label.icg_show_selected;
	}

	get showBackButton() {
		return this.pageSelected > 1;
	}
	get showNextButton() {
		if (this.showOnlySelected) return (this.pageSelected - 1) * 15 + 15 < this.selectedAirlines.length;
		else return (this.pageSelected - 1) * 15 + 15 < this.filteredAirlines.length;
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

	renderedCallback(){
	if(!this.initialized){
		if(!this.rawData){
			getAllAirlines().then(data => {
				if (data) {
					this.airlines = [];

					data = JSON.parse(data);
					this.addAirlineHandledHeaders(data)
						.then(airlinesAndHeaders => {
							this.airlines.push(...airlinesAndHeaders);
							if (this.preselectedAirlines) {
								this.airlines.forEach(airline => {
									this._preselectedAirlines.forEach(preselected => {
										if (airline.value === preselected.value) airline.selected = true;
									});
								});
							}
						})

				}
			})
		}else{
			this.airlines = [];
			this.addAirlineHandledHeaders(this.rawData)
						.then(airlinesAndHeaders => {
							this.airlines.push(...airlinesAndHeaders);
							if (this.preselectedAirlines) {
								this.airlines.forEach(airline => {
									this._preselectedAirlines.forEach(preselected => {
										if (airline.value === preselected.value) airline.selected = true;
									});
								});
							}
						})
						this.addUrlToRecords();
					}
		this.initialized = true;
		}
		
	}

}
import { LightningElement, api, track } from "lwc";

import setHour_ from "@salesforce/apex/CW_FacilityContactInfoController.setHour";
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";

export default class cwOpeningHours extends LightningElement {
	plusIcon = ICG_RESOURCES + "/icons/icon-plus.svg";
	minusIcon = ICG_RESOURCES + "/icons/icon-minus.svg";
	checkedIcon = ICG_RESOURCES + "/icons/ic-tic-green.svg";
	uncheckedIcon = ICG_RESOURCES + "/icons/ic-tic-closed.svg";
	chevrondown = ICG_RESOURCES + "/icons/chevrondown.svg";
	chevronup = ICG_RESOURCES + "/icons/chevronup.svg";
	@api label

	initialized = false;

	@track isLoading = false;
	@track timeValues = [];

	@api recordId = ""; // if set recordId, save on the fly
	@api title = ""; // title
	_days;
	@api 
	get days (){
		return this._days || [];
	}// json input with data
	set days(value){
		this._days = JSON.parse(JSON.stringify(value));
		if (this._days && this._days.length) {
			this._days.forEach((day) => {
				let currentStartAt = day.startAt.split(":");
				let currentEndAt = day.endAt.split(":");
				day.startAtPretty =
					("0" + currentStartAt[0]).slice(-2) +
					":" +
					("0" + currentStartAt[1]).slice(-2);
					day.endAtPretty =
					("0" + currentEndAt[0]).slice(-2) +
					":" +
					("0" + currentEndAt[1]).slice(-2);
			});
		}
	}
	@track showContent = true; // show/hide content
	@api expandible = false; // show/hide content
	@api editMode = false; // Set on/off edit mode
	@api hideExpandibleButton = false; // Set on/off edit mode
	@api closedColor = false; // Set on/off edit mode
	@api underline = "yellow-underline ml-4";
	@api saveOnTheFly = false;

	@api
	forceShowContent() {
		this.showContent = true;
	}

	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;
			if (!this.showContent && (this.editMode || this.hideExpandibleButton)) {
				this.showContent = true;
			}
			this.timeValues = this.generateTimeValues();

			

		}
	}

	generateTimeValues() {
		let timeValues = new Array();
		for (let hour = 0; hour < 24; hour++) {
			for (let mins = 0; mins < 60; mins += 15) {
				let hourStr = ("0" + hour).slice(-2);
				let minstr = ("0" + mins).slice(-2);

				timeValues.push({
					label: hourStr + ":" + minstr,
					value: hourStr + ":" + minstr + ":00.000Z"
				});
			}
		}
		return timeValues;
	}

	showHideContent() {
		this.showContent = !this.showContent;
	}

	setHour(id, key, value) {
		this.isLoading = true;
		if(this.saveOnTheFly){
			if (!id) {
				this.updateDays(key, value);
				this.isLoading = false;
			} else {
				setHour_({ id, key, value })
					.then(response => {
						if (response.result.status === "OK") {
							this.updateDays(response.result.key, response.result.value);
						}
					})
					.finally(() => {
						this.isLoading = false;
					});
			}
		}else{
			
			this.isLoading = false;
			this.updateDays(key, value);

		}
	}

	updateDays(key, value) {
		this.days = JSON.parse(JSON.stringify(this.days));
		let ctrlIds = key.split("_");
		if (this.days && this.days.length) {
			this.days.forEach(function (element) {
				if (element.name === ctrlIds[1]) {
					if (ctrlIds[2] === "open") {
						element[ctrlIds[2]] = JSON.parse(value);
					} else if (ctrlIds[2] === "startAt" || ctrlIds[2] === "endAt") {
						let valueArr = value.split(":");
						element[ctrlIds[2]] = value;
						
						element[ctrlIds[2] + "Pretty"] =
							("0" + valueArr[0]).slice(-2) + ":" + ("0" + valueArr[1]).slice(-2);
					}
				}
			}, this);
		}


		this.timeValues = this.generateTimeValues();
		let daysToSave = [];
		this.days.forEach( day => {
			day.empty = false;
			delete day['startAtPretty'];
			delete day['endAtPretty'];

		})
		// Creates the event with the data and dispatches.
		const updatedEvent = new CustomEvent("updated", {
			detail: {
				days: this.days,//this.days,
				key: key,
				value: value
			}
		});
		this.dispatchEvent(updatedEvent);
	}

	handleChangeHour(event) {
		let key = event.detail.target.name;
		let value = event.detail.target.value;

		this.setHour(this.recordId, key, value);
		event.currentTarget.blur();
	}

	handleChangeOpenCloseDay(event) {
		let key = event.target.dataset.key;
		let value = event.target.dataset.value;

		this.setHour(this.recordId, key, value);
		event.currentTarget.blur();
	}

	get underlineClass() {
		return this.underline;
	}

	get closedColorClass() {
		let closeclass = "col-6 font-size-sm txt-center";
		if (this.closedColor) {
			closeclass = closeclass + " text-red";
		}
		return closeclass;
	}
}
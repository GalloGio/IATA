import { LightningElement, track, api, wire } from 'lwc';
import getProductSmartFacilityRemoteValidation from "@salesforce/apex/CW_RemoteValidationsController.getProductSmartFacilityRemoteValidation";
import availablerecordtypes from "@salesforce/label/c.icg_available_rv_recordtypes";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getIECSettingVariables from '@salesforce/apex/CW_Utilities.getIECSettingVariables';
import getEcommerceUrlBase from '@salesforce/apex/CW_Utilities.getEcommerceUrlBase';

export default class CwPurchaseRemoteValidation extends LightningElement {
	initialized = false;

	@track xlsHeader = []; // store all the headers of the the tables
	@track xlsData = []; // store all tables data
	@track filename = "purchase_remote_validation.xlsx"; // Name of the file

	icons = resources + "/icons/";
	exportExcel;

	@track mapRemValAlreadyPurchased;
	@track stationsWithOpenRemoteValidations;
	@track facilitiesToPurchase;
	@api textFilter = '';
	
	@track lstProductsRemoteVal;
	@api isProduction;
	@api label;

	@wire(getProductSmartFacilityRemoteValidation, {})
	wiredProductRemoteValidation({ data }) {
		if (data) {
			this.lstProductsRemoteVal = JSON.parse(data);
			this._setListToPurchase();
		}
	}

	@wire(getIECSettingVariables, {})
	IECSettingVariables;

	@track _userManagedFacilities = [];
	@api
	get userManagedFacilities() {
		return this.facilitiesToPurchase;
	}
	set userManagedFacilities(value) {
		this._userManagedFacilities = value;
		this._setListToPurchase();
	}
	
	
	@api
	get remoteValidations() {
		return Object.values(this.mapRemValAlreadyPurchased)
	}
	set remoteValidations(value) {
		if (value) {
			this.mapRemValAlreadyPurchased = new Map();
			this.stationsWithOpenRemoteValidations = [];
			value.forEach(remVal => {
				if (remVal.Order.Remote_Validation_Status__c === "RV_Complete" || remVal.Order.Remote_Validation_Status__c === "Cancelled") {
					this.mapRemValAlreadyPurchased.set(remVal.Station__c, remVal);
				}
				if (remVal.Order.Remote_Validation_Status__c !== "RV_Complete" && remVal.Order.Remote_Validation_Status__c !== "Cancelled") {
					this.stationsWithOpenRemoteValidations.push(remVal.Station__r.Id);
				}
			});
		}
		this._setListToPurchase();
	}
	
	get hasItem() {
		if (this.facilitiesToPurchaseList){
			return this.facilitiesToPurchaseList.length > 0;
		}
	}

	get facilitiesToPurchaseList() {
		if (this.textFilter && this.facilitiesToPurchase) {
			return this.facilitiesToPurchase.filter(rem => {
				return rem.Name.toLowerCase().indexOf(this.textFilter.toLowerCase()) > -1;
			});
		} 
		return this.facilitiesToPurchase;
	}
	
	filterFacilitiesToPurchase(event) {
		this.textFilter = event.target.value;
		initialized = false;
		this._setListToPurchase();
	}

	renderedCallback() {
		this.exportExcel = this.icons + this.label.xlsx_icon;
		if(this.initialized) {
			return;
		}
		this._setListToPurchase();
	}

	_setListToPurchase() {
		this.facilitiesToPurchase = [];
		let allowedRt = (availablerecordtypes) ? availablerecordtypes.split(',') : [];
		let rvProduct = (this.lstProductsRemoteVal && this.lstProductsRemoteVal[0]) ? this.lstProductsRemoteVal[0] : undefined;

		if(allowedRt.length > 0 && rvProduct && this._userManagedFacilities && this.stationsWithOpenRemoteValidations) {
			let items = [];
			let ecommerceUrlRequired = (this.stationsWithOpenRemoteValidations.length == 0);

			this._userManagedFacilities.forEach(currentRecord => {
				if (currentRecord.isApproved__c === true && allowedRt.includes(currentRecord.RecordType.DeveloperName)) {
						let newItem = JSON.parse(JSON.stringify(currentRecord));
						newItem.openRemoteValidations = (this.stationsWithOpenRemoteValidations.indexOf(currentRecord.Id) > -1);
						if (!ecommerceUrlRequired) {
							ecommerceUrlRequired = newItem.openRemoteValidations;
						}
						items.push(newItem);
				}
			});
			
			if (ecommerceUrlRequired) {
				getEcommerceUrlBase({})
					.then(ecommerceUrlBase => {
						items.forEach(currentItem => {
							if (!currentItem.openRemoteValidations) {
								currentItem.linkToPurchase = rvProduct.SAP_Material_Number__c
								? ecommerceUrlBase + '/IEC_ProductDetails?id=' + rvProduct.SAP_Material_Number__c + '&fid=' + currentItem.Id
								: 'Product not available';
							}
							this.facilitiesToPurchase.push(currentItem);
						});
						this.initialized = true;
					});
			} else {
				this.initialized = true;
			}
		} else {
			this.initialized = true;
		}
	}

	get prepareToExcel(){
		let prepareToExcel = [];
		if(this.facilitiesToPurchaseList){
			this.facilitiesToPurchaseList.forEach(function(elem) {
				let station = elem.Name;
				let address = elem.Street_Nr_FOR__c + "," + elem.Postal_Code_FOR__c + "," + elem.City_FOR__c + "," +elem.State_Province_FOR__c;
				let date = elem.CreatedDateDateFormat;
				let status = elem.Status__c;
			  
				prepareToExcel.push({
					station: station,
					address: address,
					date: date,
					status: status
				});
				
			});
		}
		return prepareToExcel;
	}

	excelFormat(){
		if(this.prepareToExcel){
			this.xlsFormatter(this.prepareToExcel);
		}
	}

	xlsFormatter(data) {
		let Header = Object.keys(data[0]);
		this.xlsHeader.push(Header);
		this.xlsData.push(data);
		this.downloadExcel();
	}
	
	downloadExcel() {
		this.template.querySelector("c-cw-xlsx-main").download();
	}
	goToFacilityPage(event) {
		let idStation = event.target.getAttribute("id-station");

		const selectedFacilityEvent = new CustomEvent("stationclicked", {
			detail: idStation
		});
		this.dispatchEvent(selectedFacilityEvent);
	}
	goTo(event){
		const selectedItemEvent = new CustomEvent("menuitemselection", {
			detail: event.currentTarget.dataset.action
		});
		this.dispatchEvent(selectedItemEvent);
	}
}
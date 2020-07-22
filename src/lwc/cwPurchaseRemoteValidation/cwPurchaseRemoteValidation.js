import { LightningElement, track, api, wire } from 'lwc';
import getProductSmartFacilityRemoteValidation from "@salesforce/apex/CW_RemoteValidationsController.getProductSmartFacilityRemoteValidation";
import availablerecordtypes from "@salesforce/label/c.icg_available_rv_recordtypes";
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwPurchaseRemoteValidation extends LightningElement {
	initialized = false;

	@track xlsHeader = []; // store all the headers of the the tables
    @track xlsData = []; // store all tables data
	@track filename = "purchase_remote_validation.xlsx"; // Name of the file

	icons = resources + "/icons/";
    exportExcel = this.icons + "export-to-excel.png";

	@track mapRemValAlreadyPurchased;
	@track facilitiesToPurchase;
	@api textFilter = '';
	prodOrg = 'https://store.iata.org/IEC_ProductDetails';
	preprodOrg = 'https://preprod-customer-portal-iata.cs109.force.com/iec/';
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
			value.forEach(remVal => {
				if (remVal.Order.Remote_Validation_Status__c === "RV_Complete" || remVal.Order.Remote_Validation_Status__c === "Cancelled") {
					this.mapRemValAlreadyPurchased.set(remVal.Station__c, remVal);
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
		if(this.initialized) {
			return;
		}
		this._setListToPurchase();
	}

	_setListToPurchase() {
		if(this.lstProductsRemoteVal && this._userManagedFacilities && !this.facilitiesToPurchase && this.mapRemValAlreadyPurchased) {
			this.facilitiesToPurchase = [];
			
			this._userManagedFacilities.forEach(potPurchase => {
				if(potPurchase.isApproved__c === true && !this.mapRemValAlreadyPurchased.has(potPurchase.Id) && availablerecordtypes && availablerecordtypes.split(',').includes(potPurchase.RecordType.DeveloperName) && this.lstProductsRemoteVal[0]) {
					const domain = this.isProdsandbox ? this.prodOrg : this.preprodOrg;
					let potPur = JSON.parse(JSON.stringify(potPurchase));
					potPur.linkToPurchase = this.lstProductsRemoteVal[0].SAP_Material_Number__c
											? domain 
												+ '?IEC_ProductDetails=' + this.lstProductsRemoteVal[0].SAP_Material_Number__c
												+ '&fid=' + potPurchase.Id
											: 'Product not available';
					this.facilitiesToPurchase.push(potPur);
				}
			})
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
}
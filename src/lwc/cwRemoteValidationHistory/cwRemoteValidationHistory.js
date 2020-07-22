import { LightningElement, track, api } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwRemoteValidationHistory extends LightningElement {

	icons = resources + "/icons/";
	exportExcel = this.icons + "export-to-excel.png";
	
	@track xlsHeader = []; // store all the headers of the the tables
    @track xlsData = []; // store all tables data
	@track filename = "remote_validation_history.xlsx"; // Name of the file

	@track pastRemoteValidationsList = [];
	@api textFilter = "";
	@api label;
	@api
	get remoteValidations() {
		return this.pastRemoteValidationsList;
	}
	set remoteValidations(value) {
		if (value) {
			value.forEach(remval => {
				if (remval.Order.Remote_Validation_Status__c === "RV_Complete" || remval.Order.Remote_Validation_Status__c === "Cancelled") {
					this.pastRemoteValidationsList.push(remval);
				}
			});
		}
	}

	filterRemoteValidations(event) {
		this.textFilter = event.target.value;
	}

	goToFacilityPage(event) {
		let idStation = event.target.getAttribute("id-station");

		const selectedFacilityEvent = new CustomEvent("stationclicked", {
			detail: idStation
		});
		this.dispatchEvent(selectedFacilityEvent);
	}
    
    get hasItem() {
        if (this.pastRemoteValidations){
            return this.pastRemoteValidations.length > 0;
        }
    }

	get pastRemoteValidations() {
		if (this.textFilter && this.pastRemoteValidationsList)
			return this.pastRemoteValidationsList.filter(rem => {
				return rem.Station__r.Name.toLowerCase().indexOf(this.textFilter.toLowerCase()) > -1;
			});
		return this.pastRemoteValidationsList;
	}


	get prepareToExcel(){
        let prepareToExcel = [];
        if(this.pastRemoteValidations){
            this.pastRemoteValidations.forEach(function(elem) {
                let station = elem.Station__r.Name;
                let address = elem.Station__r.Street_Nr_FOR__c + "," + elem.Station__r.Postal_Code_FOR__c + "," + elem.Station__r.City_FOR__c + "," +elem.Station__r.State_Province_FOR__c;
				let date = elem.Order.EffectiveDate;
				let requestBy = elem.Order.CreatedBy.Name;
                let status = elem.Order.Remote_Validation_Status__c;
              
				prepareToExcel.push({
					station: station,
					address: address,
					date: date,
					requestBy: requestBy,
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
}
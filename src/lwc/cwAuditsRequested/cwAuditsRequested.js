import { LightningElement, api, track } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwAuditRequested extends LightningElement {

	@track xlsHeader = []; // store all the headers of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "pending_station_approvals.xlsx"; // Name of the file
    
    icons = resources + "/icons/";
    exportExcel = this.icons + "export-to-excel.png";
	
	@api textFilter = '';
	@api 
	auditRequestedList;

	@api
	label;

	filterRequestedAudits(event){
		this.textFilter = event.target.value;
	}

	get requestedAuditsFormat(){
		if(this.textFilter) return this.auditRequestedList.filter(aud => {return aud.Station__r.Name.toLowerCase().indexOf(this.textFilter.toLowerCase())>-1});
		return this.auditRequestedList;
    }
    
    get requestedAudits(){
		let requestedAuditsFormatted = [];
        if(this.requestedAuditsFormat){
            this.requestedAuditsFormat.forEach(function(elem) {
                let station = elem.Station__c ?elem.Station__r.Name:'';
                let address = elem.Station__c ?elem.Station__r.Formatted_Address__c:'';
                let dateRequested = elem.CreatedDate?(elem.CreatedDate.split("-")[2]).split('T')[0] + "-" + elem.CreatedDate.split("-")[1] + "-" + elem.CreatedDate.split("-")[0]:'';
                let certification = elem.ICG_Certification__c ? elem.ICG_Certification__r.Name:'';
                let preferableAuditDate = elem.Preferable_Audit_Date__c?(elem.Preferable_Audit_Date__c.split("-")[2]).split('T')[0] + "-" + elem.Preferable_Audit_Date__c.split("-")[1] + "-" + elem.Preferable_Audit_Date__c.split("-")[0]:'';
				let status = elem.Status__c ? elem.Status__c:'';
				let contactName = elem.Contact_Name__c ? elem.Contact_Name__c:'';
				let contactEmail = elem.Contact_Email__c ? elem.Contact_Email__c:'';
				let contactPhone = elem.Contact_Phone__c ? elem.Contact_Phone__c:'';
				requestedAuditsFormatted.push({
					station: station,
					address: address,
					dateRequested: dateRequested,
					certification: certification,
					preferableAuditDate: preferableAuditDate,
					status: status,
					contactName: contactName,
					contactEmail: contactEmail,
					contactPhone: contactPhone
				});
                
			});
        }
        return requestedAuditsFormatted;
	}

    get hasItem() {
        if (this.requestedAudits){
            return this.requestedAudits.length > 0;
        }
    }

    excelFormat(){
        if(this.requestedAudits){
            this.xlsFormatter(this.requestedAudits);
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
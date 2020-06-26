import { LightningElement, api, track, wire} from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwPendingFacilityApprovals extends LightningElement {
    @track xlsHeader = []; // store all the headers of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "pending_station_approvals.xlsx"; // Name of the file
       
    icons = resources + "/icons/";
    exportExcel = this.icons + "export-to-excel.png";

    @api userManagedFacilities; 
    @api label;
    @track filterValue;
    @track openConfirm;
    action;
    stid;   

    initialized = false;
    renderedCallback() {
        if (!this.initialized) {
            this.initialized = true;
        }
    }

    handleMoreInfo(event) {
        let url = window.location.pathname + '?pending=true#ID:' +
            event.currentTarget.getAttribute("data-id");
        window.open(url, "_blank");
    }

    setFilterValue(event){
        this.filterValue = event.target.value;
    }

    searchFacility(value, element){
        value = value ? value.toUpperCase() : '';
        const nameMatches = element.Name ? element.Name.toUpperCase().includes(value) : false;
        const addressMatches = element.address.toUpperCase().includes(value);
        const statusMatches = element.Status__c ? element.Status__c.toUpperCase().includes(value) : false;
        return nameMatches || addressMatches || statusMatches;
    }
    
    get hasItem() {
        if (this.filteredFacilities){
            return this.filteredFacilities.length > 0;
        }
    }

    get filteredFacilities() {
        let filteredFacilities = [];
        if(this.userManagedFacilities){
            filteredFacilities = this.userManagedFacilities.filter(station => {
                return !this.filterValue || this.searchFacility(this.filterValue, station);
            })
            .slice().sort(function(a,b){

                let dateASplit = a.CreatedDateDateFormat.split("-");
                let dateBSplit = b.CreatedDateDateFormat.split("-");

                if (dateASplit.length < 2 || dateBSplit.length < 2){
                    return -1;
                }
                else{
                    let dateA = new Date(Number(dateASplit[2]), Number(dateASplit[1]), Number(dateASplit[0]));
                    let dateB = new Date(Number(dateBSplit[2]), Number(dateBSplit[1]), Number(dateBSplit[0]));
                
                    return dateB.getTime()-dateA.getTime();
                }
            });
        } 
		
		return filteredFacilities;
    }

    get prepareToExcel(){
        let prepareToExcel = [];
        if(this.filteredFacilities){
            this.filteredFacilities.forEach(function(elem) {
                let facilityName = elem.Name;
                let facilityRecordType = elem.RecordType.Name;
                let facilityGroup = elem.groupName;
                let facilityAddress = elem.address;
                let facilityStatus = elem.Status__c;
                let facilityCreatedDateDateFormat = elem.CreatedDateDateFormat;
                if(elem.isPendingApproval__c == true){
                    prepareToExcel.push({
                        Name: facilityName,
                        Type: facilityRecordType,
                        OperationalHierarchy: facilityGroup,
                        Address: facilityAddress,
                        Status: facilityStatus,
                        RequestDate: facilityCreatedDateDateFormat
                    });
                }
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


    
    approveStation(){
        this.dispatchEvent(new CustomEvent('approve', { detail: this.stid }));
    }
    rejectStation(){
        this.dispatchEvent(new CustomEvent('reject', { detail: this.stid }));
    }

    confirmApproval(event){
        this.action = event.target.dataset.action;
        this.stid = event.target.dataset.stid;
        if (this.action === 'approve') {
            this.openConfirm = true;
        } else if (this.action === 'reject') {
            this.rejectStation();
        }
    }
    handleCancel(){
        this.action = '';
        this.stid='';
        this.openConfirm = false;
    }

    handleConfirmDialogYes(){
        this.openConfirm = false;
        if (this.action === 'approve'){
            this.approveStation();
        }
        else if (this.action === 'reject'){
            this.rejectStation();
        }
    }
}
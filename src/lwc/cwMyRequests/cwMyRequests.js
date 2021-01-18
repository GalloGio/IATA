import { LightningElement, api, track, wire } from 'lwc';
import getFacilityManagerContactRolesFromStationListByUser from '@salesforce/apex/CW_Utilities.getFacilityManagerContactRolesFromStationListByUser';
import getFacilityHistoryByUser from '@salesforce/apex/CW_Utilities.getFacilityHistoryByUser';
import resources from '@salesforce/resourceUrl/ICG_Resources';
import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";
import { getCompanyTypeImage } from "c/cwUtilities";

export default class CwMyRequests extends LightningElement {
	@track xlsHeader = []; // store all the headers of the the tables
	@track xlsData = []; // store all tables data
	@track filename = "my_requests.xlsx"; // Name of the file

	facilityList;
	userManagedFacilityList;
	user;

	@track filterValue;
	@track filteredList = [];;

	@api label;
	@track requesting;
	@track showModal = false;
	@track modalMessage = 'When you perform an action, this modal appears with extra info.';
	icons = resources + "/icons/";
	exportExcel;
	CHECKED_IMAGE = this.icons + 'ic-tic-green.svg';
	ERROR_IMAGE = this.icons + 'error-icon.svg';
	@track modalImage = this.CHECKED_IMAGE;

	@track adminRequest = [];
	@track stationManagerRequest = [];
	@track stationCreationRequest = [];
	facilitymanagercrinitialized = false;


	@api 
	get userInfo(){
		return this.user;
	}

	set userInfo(value){
		if (value != null){
			this.user = value;
			this.setUserManagerRequests();
		}
	}
	
	@api 
	get userFacilities(){
		return this.facilityList;
	}
	
	set userFacilities(value){
		this.adminRequest = [];
		this.facilityList = value;
	}
	
	@api 
	get userManagedFacilities(){
		return this.userManagedFacilityList;
	}
	
	set userManagedFacilities(value){
		this.userManagedFacilityList = value;
	}

	get getStationManagerRequest(){
		return this.stationManagerRequest;
	}

	renderedCallback(){
		this.exportExcel = this.icons + this.label.xlsx_icon;
	}

	setUserManagerRequests(){
		if (this.user != null && this.stationManagerRequest != null 
			&& (this.stationManagerRequest.length === 0 || !this.stationManagerRequest) 
			&& !this.facilitymanagercrinitialized){
			 
			this.stationManagerRequest = [];
			getFacilityHistoryByUser({userId : this.user.Id}).then(conRoles =>{
				this.facilitymanagercrinitialized = true;
				conRoles.forEach(item => {
                        var company = ''; 
                        var station = ''; 
                        var stationId = ''; 
                        var recordTypeName = ''; 

                        if (item.Type !== 'Station Creation Requests'){
                            company = (item.ICG_Contact_Role_DetailR.Account_Contact_Role__r.Account__r != null) ? item.ICG_Contact_Role_DetailR.Account_Contact_Role__r.Account__r.Name : '';
                            station = (item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r != null) ? item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r.Name : '';
                            stationId = (item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r != null) ? item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r.Id : '';
                            recordTypeName = (item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r != null && item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r.RecordType != null) ? item.ICG_Contact_Role_DetailR.ICG_Account_Role_Detail__r.RecordType.Name : '';
                        }
                        else {
                            company = (item.ICG_Account_Role_DetailR != null && item.ICG_Account_Role_DetailR.Name.split(';').length > 0) ? item.ICG_Account_Role_DetailR.Name.split(';')[1] : '';
                            station = (item.ICG_Account_Role_DetailR != null && item.ICG_Account_Role_DetailR.Name.split(';').length > 0) ? item.ICG_Account_Role_DetailR.Name.split(';')[0] : '';
                            stationId = (item.ICG_Account_Role_DetailR != null) ? item.ICG_Account_Role_DetailR.Id : '';
                            recordTypeName = (item.ICG_Account_Role_DetailR != null && item.ICG_Account_Role_DetailR.RecordType != null) ? item.ICG_Account_Role_DetailR.RecordType.Name : '';
                        }
                    
						let itemDTO = { 
							Type: item.Type, 
							Status: item.Status,
							Company: company,
							Station: station, 
							StationType: recordTypeName,
							ctypeimage: resources + getCompanyTypeImage(recordTypeName),
							HasStation: true, 
							CreatedDateDateFormat: (item.LastModifiedDate.split("-")[2]).split('T')[0] + "-" + item.LastModifiedDate.split("-")[1] + "-" + item.LastModifiedDate.split("-")[0],
							RequestedDate: item.LastModifiedDate,
							Id: stationId
						};
						this.stationManagerRequest.push(itemDTO);
						this.filteredList.push(itemDTO);
				});
			});
		}
	}

	setStationManagersFilterValue(event){
		this.filterValue = event.target.value;
	}

	
	get hasItem() {
		if (this.getFilteredList){
			return this.getFilteredList.length > 0;
		}
	}

	get getFilteredList() {
		let filtered = [];
		if(this.filteredList){
		filtered = this.filteredList.filter(item => {
				return this.searchContactRole(this.filterValue, item);
			})
			.slice().sort(function(a,b){
				return new Date(b.RequestedDate).getTime()-new Date(a.RequestedDate).getTime();
			});
		} 
		
		return filtered;
	}
	
	searchContactRole(value, element){
		value = value ? value.toUpperCase() : '';
		let type;
		let company;
		let station;
		let status;
		let date;
		type = element.Type ? element.Type.toUpperCase().includes(value) : false;
		company = element.Company ? element.Company.toUpperCase().includes(value) : false;
		station = element.Station ? element.Station.toUpperCase().includes(value) : false;
		status = element.Status ? element.Status.toUpperCase().includes(value) : false;
		date = element.CreatedDateDateFormat ? element.CreatedDateDateFormat.toUpperCase().includes(value) : false;
		
		return type || company || station || status || date;
	}

	get prepareToExcel(){
		let prepareToExcel = [];
		if(this.getFilteredList){
			this.getFilteredList.forEach(function(element) {
				prepareToExcel.push({
					Type: element.Type,
					Company: element.Company,
					Station: element.Station,
					Status: element.Status,
					RequestDate: element.CreatedDateDateFormat,
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

	handleMoreInfo(event) {
		let url = '#ID:' + event.currentTarget.getAttribute("data-id");
		window.location.href = url;
		window.location.reload();
	}
}
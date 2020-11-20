import { LightningElement, api, track, wire } from 'lwc';
import getFacilityManagerContactRolesFromStationListByUser from '@salesforce/apex/CW_Utilities.getFacilityManagerContactRolesFromStationListByUser';
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
			this.setUserManagedFacilitiesJS();
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
		if (value){
			this.facilityList.forEach(item =>{
				if (item.isPendingCompanyAdmin){
					let itemDTO = { 
						Type: 'Admin Requests', 
						Status: item.status,
						Company: item.groupName, 
						Station: '', 
						HasStation: false, 
						StationType: '',
						CreatedDateDateFormat: item.createdDateDateFormat,
						RequestedDate: item.createdDate,
						Id: item.accountRoleDetailId
					}; 
					this.adminRequest.push(itemDTO);
					this.filteredList.push(itemDTO);
				}
			});
		}
	}
	
	@api 
	get userManagedFacilities(){
		return this.userManagedFacilityList;
	}
	
	set userManagedFacilities(value){
		this.userManagedFacilityList = value;
		this.setUserManagedFacilitiesJS();
	}

	get getStationManagerRequest(){
		return this.stationManagerRequest;
	}

	renderedCallback(){
		this.exportExcel = this.icons + this.label.xlsx_icon;
	}

	setUserManagedFacilitiesJS(){
		if (this.user != null && this.userManagedFacilityList != null){

			this.stationCreationRequest = [];
			this.userManagedFacilityList.forEach(item =>{
				if (item.isPendingApproval__c && item.CreatedById == this.user.Id){
					let itemDTO = { 
						Type: 'Station Creation Requests', 
						Status: item.Status__c,
						Company: item.groupName, 
						Station: item.Name,  
						HasStation: true, 
						StationType: item.RecordType.Name,
						ctypeimage: item.ctypeimage,
						CreatedDateDateFormat: item.CreatedDateDateFormat,
						RequestedDate: item.CreatedDate,
						Id: item.Id
					}; 
					this.stationCreationRequest.push(itemDTO);
					this.filteredList.push(itemDTO);
				}
			});
		}
	}

	setUserManagerRequests(){
		if (this.user != null && this.stationManagerRequest != null 
			&& (this.stationManagerRequest.length === 0 || !this.stationManagerRequest) 
			&& !this.facilitymanagercrinitialized){
			 
			this.stationManagerRequest = [];
			getFacilityManagerContactRolesFromStationListByUser({userId : this.user.Id}).then(conRoles =>{
				this.facilitymanagercrinitialized = true;
				conRoles.forEach(item => {
					if (item.isPendingApproval__c || (item.Status__c === 'Pending for Removal' && item.LastModifiedById === this.user.Id)){
						var company = (item.Account_Contact_Role__r.Account__r != null) ? item.Account_Contact_Role__r.Account__r.Name : '';
						var station = (item.ICG_Account_Role_Detail__r != null) ? item.ICG_Account_Role_Detail__r.Name : '';
						var stationId = (item.ICG_Account_Role_Detail__r != null) ? item.ICG_Account_Role_Detail__r.Id : '';
						var recordTypeName = (item.ICG_Account_Role_Detail__r != null && item.ICG_Account_Role_Detail__r.RecordType != null) ? item.ICG_Account_Role_Detail__r.RecordType.Name : '';

						let itemDTO = { 
							Type: 'Station Manager Requests', 
							Status: item.Status__c,
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
					}
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
		var type = event.currentTarget.getAttribute("data-type");
		var pending = (type === 'Station Manager Requests') ? '#' : '?pending=true#';

        let url =  window.location.pathname + pending + 'ID:' + event.currentTarget.getAttribute("data-id");
		window.location.href = url;
		window.location.reload();
    }
}
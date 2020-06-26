import { LightningElement, api, track, wire } from 'lwc';
import getFacilityManagerContactRolesFromStationListByUser from '@salesforce/apex/CW_Utilities.getFacilityManagerContactRolesFromStationListByUser';
import resources from '@salesforce/resourceUrl/ICG_Resources';
import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";

export default class CwMyRequests extends LightningElement {
    @track xlsHeader = []; // store all the headers of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "my_requests.xlsx"; // Name of the file

    _userFacilities;
    _userManagedFacilities;
    _userInfo;

	@track filterValue;
    @track filteredList = [];;

    @api label;
    @track requesting;
    @track showModal = false;
    @track modalMessage = 'When you perform an action, this modal appears with extra info.';
    icons = resources + "/icons/";
    exportExcel = this.icons + "export-to-excel.png";
    CHECKED_IMAGE = this.icons + 'ic-tic-green.svg';
    ERROR_IMAGE = this.icons + 'error-icon.svg';
    @track modalImage = this.CHECKED_IMAGE;

    @track adminRequest = [];
    @track stationManagerRequest = [];
    @track stationCreationRequest = [];
    facilitymanagercrinitialized = false;


    @api 
	get userInfo(){
		return this._userInfo;
    }

    set userInfo(value){
        if (value != null){
            this._userInfo = value;
            this.setUserManagedFacilitiesJS();
            this.setUserManagerRequests();
        }
    }
    
    @api 
	get userFacilities(){
		return this._userFacilities;
    }
    
    set userFacilities(value){
        console.log('userFacilities');
        this.adminRequest = [];
		this._userFacilities = value;
		this._userFacilities.forEach(item =>{
            if (item.isPendingCompanyAdmin){
                let itemDTO = { 
                    Type: 'Admin Requests', 
                    Status: item.status,
                    Company: item.groupName, 
                    Station: '', 
                    CreatedDateDateFormat: item.createdDateDateFormat,
                    RequestedDate: item.createdDate,
                    Id: item.accountRoleDetailId
                }; 
                this.adminRequest.push(itemDTO);
                this.filteredList.push(itemDTO);
            }
        });
    }
    
    @api 
	get userManagedFacilities(){
		return this._userManagedFacilities;
    }
    
    set userManagedFacilities(value){
        console.log('userManagedFacilities');
        this._userManagedFacilities = value;
        this.setUserManagedFacilitiesJS();
    }

	get getStationManagerRequest(){
        return this.stationManagerRequest;
    }

    setUserManagedFacilitiesJS(){
        if (this._userInfo != null && this._userManagedFacilities != null){

            this.stationCreationRequest = [];
            this._userManagedFacilities.forEach(item =>{
                if (item.isPendingApproval__c && item.CreatedById == this._userInfo.Id){
                    let itemDTO = { 
                        Type: 'Station Creation Requests', 
                        Status: item.Status__c,
                        Company: item.groupName, 
                        Station: item.Name,  
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
        if (this._userInfo != null && this.stationManagerRequest != null 
            && (this.stationManagerRequest.length === 0 || !this.stationManagerRequest) 
            && !this.facilitymanagercrinitialized){
             
            this.stationManagerRequest = [];
            getFacilityManagerContactRolesFromStationListByUser({userId : this._userInfo.Id}).then(conRoles =>{
                this.facilitymanagercrinitialized = true;
                conRoles.forEach(item => {
                    if (item.isPendingApproval__c){
                        var company = (item.Account_Contact_Role__r.Account__r != null) ? item.Account_Contact_Role__r.Account__r.Name : '';
                        var station = (item.ICG_Account_Role_Detail__r != null) ? item.ICG_Account_Role_Detail__r.Name : '';

                        let itemDTO = { 
                            Type: 'Station Manager Requests', 
                            Status: item.Status__c,
                            Company: company,
                            Station: station, 
                            CreatedDateDateFormat: (item.CreatedDate.split("-")[2]).split('T')[0] + "-" + item.CreatedDate.split("-")[1] + "-" + item.CreatedDate.split("-")[0],
                            RequestedDate: item.CreatedDate
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
}
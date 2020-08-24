import { LightningElement, api, track, wire} from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getFacilityManagerApprovedOrRemovedByUser from '@salesforce/apex/CW_Utilities.getFacilityManagerApprovedOrRemovedByUser';
import getOpsHierarchyNameFromStationId from '@salesforce/apex/CW_Utilities.getOpsHierarchyNameFromStationId';
import getOpsHierarchyNameFromAccountId from '@salesforce/apex/CW_Utilities.getOpsHierarchyNameFromAccountId';

export default class CwManagerUserPermission extends LightningElement {
    @track xlsHeader = []; // store all the headers of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "pending_station_approvals.xlsx"; // Name of the file
       
    icons = resources + "/icons/";
    exportExcel;

    @api label;
	@track filterValue;
    @track filteredList = [];;
    
    _userInfo;
    @track stationManagerRequest = [];
    facilitymanagercrinitialized = false;

    @api 
	get userInfo(){
		return this._userInfo;
    }

    set userInfo(value){
        if (value != null){
            this._userInfo = value;
            this.setUserManagerRequests();
        }
    }

    renderedCallback(){
        this.exportExcel = this.icons + this.label.xlsx_icon;
    }

    setUserManagerRequests(){
        if (this._userInfo != null && this.stationManagerRequest != null 
            && (this.stationManagerRequest.length === 0 || !this.stationManagerRequest) 
            && !this.facilitymanagercrinitialized){
             
            let items = new Map(); 
            let stationsMap = new Map();    
            let stations = [];
            this.stationManagerRequest = [];
            getFacilityManagerApprovedOrRemovedByUser({userId : this._userInfo.Id}).then(conRoles =>{
                this.facilitymanagercrinitialized = true;
                conRoles.forEach(item => {
                    var accountId = (item.Account_Contact_Role__r.Account__c != null) ? item.Account_Contact_Role__r.Account__c : '';
                    var company = (item.Account_Contact_Role__r.Account__r != null) ? item.Account_Contact_Role__r.Account__r.Name : '';
                    var station = (item.ICG_Account_Role_Detail__r != null) ? item.ICG_Account_Role_Detail__r.Name : '';
                    var stationId = (item.ICG_Account_Role_Detail__c != null) ? item.ICG_Account_Role_Detail__c : '';
                    let lastDate = (item.LastModifiedDate.split("-")[2]).split('T')[0] + "-" + item.LastModifiedDate.split("-")[1] + "-" + item.LastModifiedDate.split("-")[0];// + ' ' + item.LastModifiedDate.split("T")[1].split('.')[0];
                    let itemDTO = { 
                        Id: item.Id,
                        Type: item.ICG_Role__c,
                        User: item.Account_Contact_Role__r.Contact__r.Name,
                        AccountId: accountId,
                        Status: item.Status__c,
                        Company: company,
                        StationId: stationId, 
                        Station: station, 
                        Date: lastDate,
                        RequestedDate: item.LastModifiedDate,
                        LastModifiedByName: item.LastModifiedBy.Name
                    };

                    let key = itemDTO.User + '_' +itemDTO.Type + '_' +itemDTO.Station + '_' +itemDTO.Date + '_' +itemDTO.Status + '_' +itemDTO.LastModifiedByName + '_'; 
                    if (!items.has(key)){
                        items.set(key, itemDTO);
                        
                        this.stationManagerRequest.push(itemDTO);
                        this.filteredList.push(itemDTO);
                    }

                    if (itemDTO.StationId != '' && !stationsMap.has(itemDTO.StationId)){
                        stationsMap.set(itemDTO.StationId, itemDTO.Station);
                        stations.push(itemDTO.StationId);
                    }
                });

                stations.forEach(stationItem => {
                    getOpsHierarchyNameFromStationId({stationId : stationItem}).then(conRoles =>{
                        this.stationManagerRequest.forEach(item => {
                            if (item.StationId === stationItem){
                                item.Company = conRoles;
                            }
                        });
                    });
                });

                this.stationManagerRequest.forEach(item => {
                    if (item.StationId === ''){
                        getOpsHierarchyNameFromAccountId({accountId : item.AccountId}).then(conRoles =>{
                            if (conRoles !== ''){
                                item.Company = conRoles;
                            }
                        });
                    }
                });
            });
        }
    }

    setFilterValue(event){
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
		let user;
		let company;
		let type;
		let station;
		let status;
		let lastModfiedByName;
        let date;
        user = element.User ? element.User.toUpperCase().includes(value) : false;
        company = element.Company ? element.Company.toUpperCase().includes(value) : false;
        type = element.Type ? element.Type.toUpperCase().includes(value) : false;
        station = element.Station ? element.Station.toUpperCase().includes(value) : false;
        status = element.Status ? element.Status.toUpperCase().includes(value) : false;
        lastModfiedByName = element.LastModifiedByName ? element.LastModifiedByName.toUpperCase().includes(value) : false;
        date = element.Date ? element.Date.toUpperCase().includes(value) : false;
		
        return user || type || company || station || status || lastModfiedByName || date;
    }

    get prepareToExcel(){
        let prepareToExcel = [];
        if(this.getFilteredList){
            this.getFilteredList.forEach(function(element) {
                prepareToExcel.push({
                    User: element.User,
                    Company: element.Company,
                    Station: element.Station,
                    Status: element.Status,
                    RequestDate: element.Date
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
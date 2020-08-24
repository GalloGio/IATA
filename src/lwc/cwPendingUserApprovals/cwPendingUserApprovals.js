import { LightningElement, api, track } from 'lwc';
import getPendingCompanyAdminContactRolesFromGroupName from  "@salesforce/apex/CW_Utilities.getPendingCompanyAdminContactRolesFromGroupName";
import getFacilityManagerContactRolesFromStationListByStatus from  "@salesforce/apex/CW_Utilities.getFacilityManagerContactRolesFromStationListByStatus";
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwPendingUserApprovals extends LightningElement {

	facilityList;
	userManagedFacilityList;
	icons = resources + "/icons/";
	exportExcel;
	@track xlsHeader = []; // store all the headers of the the tables
	@track xlsData = []; // store all tables data
	@track filename = "pending_user_approvals.xlsx"; // Name of the file
	
	@track groupsAndAdmins = [];
	@track pendingStationsWithContactRoles = [];
	@api stationManagerFilterValue;
	@track openConfirm;
	action;
	conroleid;
	type;
	@api label;
	@api 
	get userFacilities(){
		return this.facilityList;
	}
	set userFacilities(value){
		this.facilityList = value;
		this.fillPendingForApprovalContactRoles();
	}
	handleMoreInfo(event) {
		let url = window.location.pathname + '?#ID:' +
			event.currentTarget.getAttribute("data-id");
		window.open(url, "_blank");
	}

	setStationManagersFilterValue(event){
		this.stationManagerFilterValue = event.target.value;
	}

	@api 
	get userManagedFacilities(){
		return this.userManagedFacilityList;
	}
	set userManagedFacilities(value){
		this.userManagedFacilityList = JSON.parse(JSON.stringify(value));
		this.fillPendingForApprovalContactRoles();
	}

	renderedCallback(){
        this.exportExcel = this.icons + this.label.xlsx_icon;
    }

	searchContactRole(value, element){
		value = value ? value.toUpperCase() : '';
		let nameMatches;
		let addressMatches;
		let contactFirstNameMatches;
		let contactLastNameMatches;
		let contactEmailMatches;
		let contactPhoneMatches;
		if(element.contactRole){
			nameMatches = element.Name ? element.Name.toUpperCase().includes(value) : false;
			addressMatches = element.address.toUpperCase().includes(value);
			contactFirstNameMatches = element.contactRole.Account_Contact_Role__r.Contact__r.FirstName ? element.contactRole.Account_Contact_Role__r.Contact__r.FirstName.toUpperCase().includes(value) : false;
			contactLastNameMatches = element.contactRole.Account_Contact_Role__r.Contact__r.LastName ? element.contactRole.Account_Contact_Role__r.Contact__r.LastName.toUpperCase().includes(value) : false;
			contactEmailMatches = element.contactRole.Account_Contact_Role__r.Contact__r.Email ? element.contactRole.Account_Contact_Role__r.Contact__r.Email.toUpperCase().includes(value) : false;
			contactPhoneMatches = element.contactRole.Account_Contact_Role__r.Contact__r.Phone ? element.contactRole.Account_Contact_Role__r.Contact__r.Phone.toUpperCase().includes(value) : false;
		}else{
			contactFirstNameMatches = element.Account_Contact_Role__r.Contact__r.FirstName ? element.Account_Contact_Role__r.Contact__r.FirstName.toUpperCase().includes(value) : false;
			contactLastNameMatches = element.Account_Contact_Role__r.Contact__r.LastName ? element.Account_Contact_Role__r.Contact__r.LastName.toUpperCase().includes(value) : false;
			contactEmailMatches = element.Account_Contact_Role__r.Contact__r.Email ? element.Account_Contact_Role__r.Contact__r.Email.toUpperCase().includes(value) : false;
			contactPhoneMatches = element.Account_Contact_Role__r.Contact__r.Phone ? element.Account_Contact_Role__r.Contact__r.Phone.toUpperCase().includes(value) : false;
		}
		return nameMatches || addressMatches || contactFirstNameMatches || contactLastNameMatches || contactEmailMatches || contactPhoneMatches;
	}
	
	get filteredFacilities() {
		let filteredFacilities = [];
		if(this.pendingStationsWithContactRoles){
			filteredFacilities = this.pendingStationsWithContactRoles.filter(station => {
				return !this.stationManagerFilterValue || this.searchContactRole(this.stationManagerFilterValue, station);
			})
		} 
		return filteredFacilities;
	}
	
	get hasItem() {
		if (this.filteredFacilities){
			return this.filteredFacilities.length > 0;
		}
	}
	
	approveCrd(){
		this.dispatchEvent(new CustomEvent('approve', { detail: this.conroleid }));
	}
	rejectCrd(){
		this.dispatchEvent(new CustomEvent('reject', { detail: this.conroleid }));
	}
	
	approveOrRejectRemoval(approvedRemoval){
		let event = new CustomEvent('handlecontactroleremoval', { 
			detail: {
				Id: this.conroleid,
				approvedRemoval: approvedRemoval
			} 
		}); 

		this.dispatchEvent(event);
	}

	confirmApproval(event){
		this.action = event.target.dataset.action;
		this.conroleid = event.target.dataset.conroleid;
		this.type = event.target.dataset.type;
		if (this.action === 'approve') {
			this.openConfirm = true;
		} else if (this.action === 'reject') {
			if(this.type === 'Pending for Removal'){
				this.approveOrRejectRemoval(false);
			}
			else{
				this.rejectCrd();
			}
		}
	}

	handleCancel(){
		this.action = '';
		this.conroleid='';
		this.type = '';
		this.openConfirm = false;
	}

	handleConfirmDialogYes(){
		this.openConfirm = false;
		if (this.action === 'approve'){
			if(this.type === 'Pending for Removal'){
				this.approveOrRejectRemoval(true);
			}
			else{
				this.approveCrd();
			}
			
			this.fillPendingForApprovalContactRoles();
		}
		else if (this.action === 'reject'){
			if(this.type === 'Pending for Removal'){
				this.approveOrRejectRemoval(false);
			}
			else{
				this.rejectCrd();
			}
		}
	}
	
	get showGroupSection(){
		return this.groupsAndAdmins && this.groupsAndAdmins.length > 0;
	}



	get prepareToExcel(){
		let prepareToExcel = [];
		if(this.filteredFacilities){
			this.filteredFacilities.forEach(function(elem) {
				let firstname = elem.contactRole.Account_Contact_Role__r.Contact__r.FirstName;
				let lastname = elem.contactRole.Account_Contact_Role__r.Contact__r.LastName;
				let email = elem.contactRole.Account_Contact_Role__r.Contact__r.Email;
				let phone = elem.contactRole.Account_Contact_Role__r.Contact__r.Phone;
				let requestDate = elem.contactRole.CreatedDateDateFormat;
				let stationName = elem.Name;
				let stationType = elem.RecordType.Name;
				let operationalHierarchy = elem.groupName;
				let address = elem.address;
				if(elem.isPendingApproval__c === false){
					prepareToExcel.push({
						firstname: firstname,
						lastname: lastname,
						email: email,
						phone: phone,
						requestDate: requestDate,
						stationName: stationName,
						stationType: stationType,
						operationalHierarchy: operationalHierarchy,
						address: address
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
	
	fillPendingForApprovalContactRoles(){
		if(this.facilityList){
			let groups = [];
			this.facilityList.forEach(grp =>{
				if(grp.isCompanyAdmin) groups.push(grp.groupName);
			})
			groups.forEach(grname =>{
				let group = {groupName : grname, companyAdmins : []};
				getPendingCompanyAdminContactRolesFromGroupName({groupName : grname}).then(conRoles =>{
					this.groupsAndAdmins = [];
					group.companyAdmins = conRoles;
					group.hasItemCompanyAdmin = conRoles && conRoles.length > 0;
					group.companyAdmins.forEach(conrole => {
						conrole.CreatedDateDateFormat = (conrole.CreatedDate.split("-")[2]).split('T')[0] + "-" + conrole.CreatedDate.split("-")[1] + "-" + conrole.CreatedDate.split("-")[0];
					})
				}).finally(()=>{
					if(group.companyAdmins.length > 0) this.groupsAndAdmins.push(group);
				});
			});
		}
		if(this.userManagedFacilityList){
			let stations = [];
		
			this.userManagedFacilityList.forEach(station =>{
				if(station.isApproved__c) stations.push(station.Id);
			})

			let statusList = ['Pending for Approval', 'Pending for Removal'];

			getFacilityManagerContactRolesFromStationListByStatus({stationIds : stations, statusList: statusList}).then(conRoles =>{
				this.pendingStationsWithContactRoles = [];
				conRoles.forEach(conrole => {
					let stationsfound = this.userManagedFacilityList.filter(st =>{
						return st.Id === conrole.ICG_Account_Role_Detail__c;
					});
					if (stationsfound.length > 0){
						conrole = JSON.parse(JSON.stringify(conrole));
						conrole.CreatedDateDateFormat = (conrole.CreatedDate.split("-")[2]).split('T')[0] + "-" + conrole.CreatedDate.split("-")[1] + "-" + conrole.CreatedDate.split("-")[0];
						stationsfound.forEach(stf =>{
							stf.contactRole = conrole;
							this.pendingStationsWithContactRoles.push(stf);
						})
					}
				});
			})
		}
	}
}
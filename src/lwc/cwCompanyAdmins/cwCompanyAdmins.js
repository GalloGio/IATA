import { LightningElement,api,track } from 'lwc';
import getCompanyAdminsContactsFromGroupName from "@salesforce/apex/CW_Utilities.getCompanyAdminContactsFromGroupName";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwCompanyAdmins extends LightningElement {
	facilityList;

	@track xlsHeader = [];
    @track xlsData = [];
	@track filename = "Company_Admins.xlsx";

	icons = resources + "/icons/";
    exportExcel;
	
	@track groupsAndAdmins = [];
	@api label;
	@api 
	get userFacilities(){
		return this.facilityList;
	}
	set userFacilities(value){
		this.facilityList = value;
		let groups = [];
		if(this.facilityList){
			this.facilityList.forEach(grp =>{
				groups.push(grp.groupName);
			})
		}
		groups.forEach(grname =>{
			let group = {groupName : grname, companyAdmins : [], hasItem: false};
			getCompanyAdminsContactsFromGroupName({groupName : grname}).then(contacts =>{
                group.companyAdmins = contacts;
                group.hasItem = (group.companyAdmins.length > 0)
			}).finally(()=>{
				this.groupsAndAdmins.push(group);
			});
		});
	}
	renderedCallback(){
        this.exportExcel = this.icons + this.label.xlsx_icon;
    }
	excelFormat(event){
        this.xlsHeaderAllValidations = [];
        this.xlsDataAllValidations = [];
        let dataGroupName = event.currentTarget.getAttribute("data-name");
        let prepareToExcel = [];
        try{
            if(this.groupsAndAdmins){          
                this.groupsAndAdmins.forEach(function(gro) {
                    if(gro.groupName === dataGroupName)
                    {
						if(gro.companyAdmins){
                        	gro.companyAdmins.forEach(function(elem) {
								let firstname = elem.FirstName;
								let lastname = elem.LastName;
								let email = elem.Email;
								let phone = elem.Phone;
								let title = elem.Title;
    
								prepareToExcel.push({
									firstname: firstname,
									lastname: lastname,
									email: email,
									phone: phone,
									title: title
								});  
								
                            }); 
						}
                    }        
                });

                this.xlsFormatter(prepareToExcel); 
            }
        }catch(err){
            this.showToast('Export',"Something went wrong", "error");
        }
    }
    xlsFormatter(data) {       
        let Header = Object.keys(data[0]);
        this.xlsHeader.push(Header);
        this.xlsData.push(data)
        this.downloadExcelAll();
    }
    downloadExcelAll() {
		this.template.querySelector("c-cw-xlsx-main").download();
	}

	showToast(title,message, variant) {
        const event = new ShowToastEvent({
            title: title,
			message: message,
			variant: variant
        });
        this.dispatchEvent(event);
	}	
	
	

}
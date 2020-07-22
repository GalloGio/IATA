import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwDetailedList extends LightningElement {
    
    @api label;
    @api isLoading;
    @api urlResultPage;

    icons = resources + "/icons/";
    exportExcel = this.icons + "export-to-excel.png";

    @track xlsHeaderAllValidations;
    @track xlsDataAllValidations;
    @track filename = "DetailedListSearchResults.xlsx"; // Name of the file
    downloadExcel = false;

    _facilities = [];
    @api 
    get facilities(){
        return this._facilities;
    }
    set facilities(value){
        this._facilities = value;
        this.isLoading = false;
    }

    renderedCallback(){
        if(this.downloadExcel){
            this.downloadExcel=false;
            this.downloadExcelSheet();
        }
    }

    goToPreregister() {
		window.open(this.label.icg_registration_url, "_blank");
    }
    
    handleMoreInfo(event) {
        let currentId = event.target.dataset.id;
        let url = this.urlResultPage + "?eid=" + currentId;
        window.open(url, "_blank");
    }
    
    excelFormatAll(event){
        this.xlsHeaderAllValidations = [];
        this.xlsDataAllValidations = [];
        let prepareToExcel = [];
        try{
            if(this.facilities){          
                this.facilities.forEach(function(elem) {      
                    if(elem.facility){
                        let name = elem.facility.name;
                        let type = elem.facility.recordTypeName;
                        let address = elem.facility.formattedAddress;
                        let certifications = '';
    
                        elem.facility.listAccCert.forEach(cert => {
                            certifications += cert.ICG_Certification__r.Name + ";";
                        })
    
                        if(certifications.length > 0){
                            certifications = certifications.substring(0, certifications.length-1);
                        }
    
     
                        prepareToExcel.push({
                            Name: name,
                            Type: type,
                            Address: address,
                            Certifications: certifications
                        });  
                    }
                });    
            
                this.xlsFormatterAllValidations(prepareToExcel);     
            }
        }catch(err){
            this.showToast('Export',"Something went wrong", "error");
        }
    }
    xlsFormatterAllValidations(data) {       
        let Header = Object.keys(data[0]);
        this.xlsHeaderAllValidations.push(Header);
        this.xlsDataAllValidations.push(data)
        this.downloadExcel = true;
        
    }

    downloadExcelSheet() {
        let element = this.template.querySelector(".xlsxallvalidations");
        if(element){
            element.download();
        }
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
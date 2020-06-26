import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from "lightning/platformResourceLoader";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getCertifications from "@salesforce/apex/CW_ResultsPageSearchBarController.getCertifications";

export default class CwValidationHistory extends LightningElement {

    /*Excel vars*/
    @track xlsHeader = []; // store all the headers of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "ValidationHistory.xlsx"; // Name of the file

    icons = resources + "/icons/";
    @track certificationHistory;
    @api preSelectedFacility;
    @track selectedFacility;
    @track selectedCertification = "";
    @track isCEIV;
    @track nearestAirport;
    @api label;
    firstTime = false;
    //icons
    tickSelection = this.icons + "ic-gsearch--selected.svg";
    exportExcel = this.icons + "export-to-excel.png";
    availableCertifications;
    @api userFacilities;
    _userManagedFacilities;
    @api 
    get userManagedFacilities(){
        return this._userManagedFacilities;
    }
    set userManagedFacilities(value){
        this._userManagedFacilities = JSON.parse(JSON.stringify(value));
    }
    @track allCertifications;
    @wire(getCertifications, {})
    wiredCertifications({ data }) {
        if (data) {
            this.allCertifications = JSON.parse(JSON.stringify(data));
        }
    }


    @track _certifications;
    certifications() {
        let availableCerts = [];
        let noctypeselected = true;
        if (this.allCertifications) {
            this.allCertifications.forEach(
                cert => {
                    if (noctypeselected) {
                        availableCerts.push(cert);
                    } else if (cert.Applicable_to__c && this.companyTypes) {
                        let added = false;
                        this.companyTypes.forEach(ctype => {
                            if (!added && ctype.selected && cert.Applicable_to__c.toLowerCase().indexOf(ctype.name.toLowerCase()) > -1) {
                                availableCerts.push(cert);
                                added = true;
                            }

                        });

                    }
                }
            );
            if (this._certifications && this._certifications.length > 0) {
                availableCerts.forEach(cert => {
                    this._certifications.forEach(prevcert => {
                        if (prevcert.selected && prevcert.Name === cert.Name) cert.selected = prevcert.selected;
                    });
                });
            }
        }
        this._certifications = JSON.parse(JSON.stringify(availableCerts));
        return this._certifications;
    }

    renderedCallback() {
        if (this.preSelectedFacility && !this.firstTime) {
            this.selectedFacility = this.preSelectedFacility;
            this.firstTime = true;
            this.history();
            this.certifications();
        }
    }
    history() {
        this.certificationHistory = [];
        this.availableCertifications = new Set();
        if (this.userManagedFacilities) {
            this.userManagedFacilities.forEach(facility => {
                if (facility.ICG_Capability_Assignment_Groups__r && facility.Id === this.selectedFacility) {
                    facility.ICG_Capability_Assignment_Groups__r.records.forEach(certificationRelationship => {
                        this.availableCertifications.add(certificationRelationship.ICG_Certification__r.Name);
                        if (this.selectedCertification === "" || this.selectedCertification === certificationRelationship.ICG_Certification__r.Name) {
                            let dateToUse = certificationRelationship.CreatedDate.split("T")[0];
                            const certName = certificationRelationship.ICG_Certification__r.Name;
                            this.facilityName = certificationRelationship.ICG_Account_Role_Detail__r.Name;
                            if (certName.indexOf("CEIV") > -1) {
                                this.isCEIV = true;
                            }
                            this.nearestAirport = facility.Nearest_Airport__r.Code__c;
                            certificationRelationship.CreatedDate = dateToUse;
                            if (certificationRelationship.SFOC_Scope__c) {
                                let scope = certificationRelationship.SFOC_Scope__c.toString().split(';').join('\n');
                                certificationRelationship.SFOC_Scope__c = scope;
                            }
                            if (certificationRelationship.CEIV_Scope_List__c) {
                                let scope = certificationRelationship.CEIV_Scope_List__c.toString().split(';').join('\n');
                                certificationRelationship.CEIV_Scope_List__c = scope;
                            }
                            this.certificationHistory.push(certificationRelationship);
                        }
                    });
                }
            });

        }
    }
    
    get hasItem() {
        if (this.certificationHistory){
            return this.certificationHistory.length > 0;
        }
    }

    get filteredCertifications() {
        let certs = [...this.availableCertifications];
        return certs;
    }

    onClickItem(event) {
        let eTarget = event.currentTarget;
        eTarget.classList.toggle('itemUnselected');
        eTarget.classList.toggle('itemSelected');
    }

    selectFacility(event) {
        this.selectedFacility = event.detail.data;
        this.history();
    }
    selectCertification(event) {
        this.selectedCertification = event.target.value;
        this.history();
    }

    /*Excel functions*/
    get prepareToExcel(){
        let prepareToExcel = [];
            if(this.certificationHistory){
                this.certificationHistory.forEach(function(elem) {
                    let certId = elem.Certification_Id__c;
                    let statyionName = elem.ICG_Account_Role_Detail__r.Name;
                    let certificationName = elem.ICG_Certification__r.Name;
                    let sticker = elem.StickerID__c;
                    let issuingDate = elem.Issue_Date__c;
                    let expirationDate = elem.Expiration_Date__c;
                    let certScope ="-";
                    if(elem.CEIV_Scope_List__c){
                        certScope = elem.CEIV_Scope_List__c;
                    }else if(elem.SFOC_Scope__c){
                        certScope = elem.SFOC_Scope__c;
                    }
                    let certStatus = elem.Status__c;
                    prepareToExcel.push({
                        CertificationId: certId,
                        StationName: statyionName,
                        Certification: certificationName,
                        StickerId: sticker,
                        IssuingDate: issuingDate,
                        ExpirationDate: expirationDate,
                        Scope: certScope,
                        Status: certStatus
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
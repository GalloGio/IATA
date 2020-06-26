import { LightningElement, api, wire, track } from 'lwc';
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { prepareExcelRow } from "c/cwUtilities";

export default class CwUserStats extends LightningElement {
    
    
    downloadExcelAllValidations;
    @track xlsHeaderAllValidations = [];
    @track xlsDataAllValidations = [];
    @track filenameAllValidations = "";

    icons = resources + "/icons/";
    @api userFacilities = [];
    @api userInfo;
    @api activeCertifications;
    @api userManagedFacilities = [];
    @api label;

    urlResultPage;
    renderedCallback(){
        if(this.downloadExcelAllValidations){
            this.downloadExcelAllValidations=false;
            this.template.querySelector(".xlsxallvalidations").download();
        }
    }
    @wire(getURL, { page: 'URL_ICG_FacilityPage' })
    wiredURLResultPage({ data }) {
        if (data) {
            this.urlResultPage = data;
        }
    }

    @api environmentVariables;
    tabarrow = this.icons + "ic-dashboard-tab--arrows.svg";
	exportExcel = this.icons + "export-to-excel.png";

    get companyFacilities() {

        let companyFacilities = [];

        let userFacilitiesCopy = JSON.parse(JSON.stringify(this.userFacilities));

        userFacilitiesCopy.forEach(userFac => {
            let stations = [];
            userFac.companyList.forEach(company => {
                if(company.stations){
                    let stationsCopy = JSON.parse(JSON.stringify(company.stations));
                    let filteredList = stationsCopy.filter(fac => { return fac.isApproved__c});
                    stations.push(...filteredList);
                }
            })
            userFac.stations = stations;
            companyFacilities.push(userFac);

        })
        return companyFacilities;
    }

    get filteredUserManagedFacilities() {
        return this.userManagedFacilities.filter(fac => { return fac.isApproved__c});
    }

    get userManagedCertifiedFacilities() {
        return this.filteredUserManagedFacilities.filter(fac => { return fac.ICG_Capability_Assignment_Groups__r && fac.ICG_Capability_Assignment_Groups__r.totalSize > 0});
    }

    get myExpiringValidations() {
        return this.prepareValidationList('Certification');
    }

    get myExpiringRemoteValidations(){
        return this.prepareValidationList('Remote_Validation');
    }

    prepareValidationList(recordType){
        let validations = [];
        let daysForExpiringValidations = this.environmentVariables && this.environmentVariables.data ? this.environmentVariables.data.EXPIRING_VALIDATION_DAYS__c : 60;

        this.userManagedCertifiedFacilities.forEach(
            facility => {
                let added = false;
                facility.ICG_Capability_Assignment_Groups__r.records.forEach(
                    cert => {
                        let isExpiring = cert.Expiration_Date__c && (new Date(cert.Expiration_Date__c).getTime() - (new Date()).getTime()) < (daysForExpiringValidations * 1000 * 60 * 60 * 24);
                        let isCorrectType = cert.RecordType.DeveloperName === recordType;
                        if (isExpiring && isCorrectType && !added) {
                            added = true;
                            validations.push(facility);
                        }
                    }
                );
            }
        );
        return validations;
    }

    get numberOfMyFacilities() {
        return this.filteredUserManagedFacilities.length;
    }
    get numberOfMyValidatedFacilities() {
        return this.userManagedCertifiedFacilities.length;
    }
    get validatedPercentage() {
        let validatedPercentage = '0%';
        if (this.userFacilities && this.numberOfMyFacilities > 0 && this.userManagedCertifiedFacilities) {
            let totalPossibleCertif = 0;
            let allMyCerts = 0;
            this.userManagedFacilities.forEach(station => {
                if(station.isApproved__c && station.allCerts){
                    station.allCerts.forEach(cert =>{
                        if (cert.available) totalPossibleCertif++;
                        //Here we do not check for expired ones... only if the facility has been certified.
                        if (cert.expDate !== '-' && cert.expDate !=='N/A') allMyCerts++;
                    })
                }                
            })
            validatedPercentage = (Math.round(allMyCerts / totalPossibleCertif * 100));
            if (!validatedPercentage) validatedPercentage = '0';
            validatedPercentage += '%';
        }
        return validatedPercentage;
    }
    get numberOfMyExpiringValidations() {
        return this.myExpiringValidations.length;
    }
    get numberOfExpiringRemoteValidations() {
        return this.myExpiringRemoteValidations.length;
    }

    openTab(event) {
        // Declare all variables
        let i, tabcontent, navlinks;
        navlinks = this.template.querySelectorAll(".nav-link");
        for (i = 0; i < navlinks.length; i++) {
            navlinks[i].classList.remove("active");
        }

        // Get all elements with class="tabcontent" and hide them
        tabcontent = this.template.querySelectorAll(".tabcontent");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].style.display = "none";
        }

        // Show the current tab, and add an "active" class to the button that opened the tab
        this.template.querySelector('[data-tosca*="' + event.currentTarget.dataset.tab + '"]').style.display = "block";

        event.currentTarget.classList.add('active');
    }



    get allStationsCount (){
        return this.companyFacilities.reduce((acc, userFac) => {
            return acc + (userFac.stations ? userFac.stations.length : 0);
        }, 0);
    }

    excelFormat(event){
        let dataGroupName = event.currentTarget.dataset.name;
        let prepareToExcelAllValidations = [];
        this.xlsHeaderAllValidations = [];
        this.xlsDataAllValidations = [];

        this.companyFacilities.forEach(function(gro) {
            if(gro.groupName === dataGroupName)
            {
                gro.stations.forEach(function(elem) {
                    let row = prepareExcelRow(elem, true, false);
                    prepareToExcelAllValidations.push(row);
                });
            }        
        });
    
        
        let xlsxname=dataGroupName.replace(" ","_");
        this.filenameAllValidations = xlsxname + ".xlsx";
        this.xlsFormatterAllValidations(prepareToExcelAllValidations);
    }
    xlsFormatterAllValidations(data) {       
        let Header = Object.keys(data[0]);
        this.xlsHeaderAllValidations.push(Header);
        this.xlsDataAllValidations.push(data)
        this.downloadExcelAllValidations=true;

    }

}
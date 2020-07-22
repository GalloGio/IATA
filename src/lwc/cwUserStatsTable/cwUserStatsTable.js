import { LightningElement, api, track } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { prepareExcelRow } from "c/cwUtilities";

export default class CwUserStatsTable extends LightningElement {
    @api label;
    icons = resources + "/icons/";
    exportExcel = this.icons + "export-to-excel.png";
    remoteValidationIcon = this.icons + "remote_validation_icon.svg";

    @api activeCertifications = [];
    @api displayCertifications = false;
    @api displayRemoteValidations = false;
    @api hideExcelBtn = false;
    @api isExpiringTab = false;
    @api environmentVariables;

    @track xlsHeader = [];
    @track xlsData = [];
    @api filename;

    _listItems = []; 

    @api
    get listItems(){
        return this._listItems;
    }

    set listItems(value){

        let environmentVariables = this.environmentVariables;

        if(value) {

            if(this.isExpiringTab){
                let transformToTime = 1000 * 60 * 60 * 24;
                let daysForExpiringValidations = environmentVariables && environmentVariables.data ? environmentVariables.data.EXPIRING_VALIDATION_DAYS__c : 60;
                let timeLimitUpper = daysForExpiringValidations * transformToTime;
                let timeLimitLower = 30 * transformToTime;
                let valueCopy = JSON.parse(JSON.stringify(value));
                let handledValues = valueCopy.map(obj => {
                    let objCopy = JSON.parse(JSON.stringify(obj));
                    objCopy.ICG_Capability_Assignment_Groups__r.records.sort((a, b) => (a.Expiration_Date__c > b.Expiration_Date__c ? 1 : -1));
                    let cert = objCopy.ICG_Capability_Assignment_Groups__r.records[0];
                    let objTimeUntilExpiration = new Date(cert.Expiration_Date__c).getTime() - (new Date()).getTime();

                    if(objTimeUntilExpiration < timeLimitLower){
                        objCopy.classes = "text-red";
                    }
                    else if(objTimeUntilExpiration >= timeLimitLower && objTimeUntilExpiration <= timeLimitUpper){
                        objCopy.classes = "text-orange";
                    }

                    return objCopy;
                });

                

                this._listItems = handledValues;
            }
            else {
                this._listItems = value;
            }

        }
    }
    
    get hasListItems(){
        return this.listItems.length > 0;
    }

    handleMoreInfo(event) {
        let url = '#ID:' + event.currentTarget.getAttribute("data-id");
        window.open(url, "_blank");
    }

    prepareToExcelList(){
        let displayCertifications = this.displayCertifications;
        let displayRemoteValidations = this.displayRemoteValidations;
        return this.listItems.map(elem => {
            return prepareExcelRow(elem, displayCertifications, displayRemoteValidations);
        })

    } 
    excelFormat(){
        let excelList = this.prepareToExcelList();
        if(excelList){
            this.xlsFormatter(excelList);
        }
    }
    xlsFormatter(data) {
        let Header = Object.keys(data[0]);
        this.xlsHeader.push(Header);
        this.xlsData.push(data);
        this.template.querySelector(".xlsdownload").download();
    }
}
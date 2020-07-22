import { LightningElement, api, track, wire } from 'lwc';
import resources from '@salesforce/resourceUrl/ICG_Resources';
import scheduleAudit from "@salesforce/apex/CW_ScheduleAuditsController.saveAudit";
import getCertifications from "@salesforce/apex/CW_ResultsPageSearchBarController.getCertifications";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CwScheduleAudits extends LightningElement {
    @api preSelectedFacility;
    @api
    userManagedFacilities;
    @api label;
    @track selectedFacility;
    @track saving = false;
    selectedFacilityRecord;
    _userInfo;
    @api
    get userInfo() {
        return this._userInfo;
    }
    set userInfo(value) {
        this._userInfo = value;
        this.contactData = {
            name: this.userInfo.Name || '',
            email: this.userInfo.Email || '',
            phone: '',
            date: ''
        }
    }
    @api userFacilities;

    @track contactData;
    checkedImage = resources + '/icons/ic-tic-green.svg';
    tickSelection = resources + "/icons/ic-gsearch--selected.svg";
    @track showModal = false;
    @track modalMessage = 'When you perform an action, this modal appears with extra info.';
    @track modalImage = this.checkedImage;
    auditData;
    selectedCertifications;

    @track allCertifications;
    @wire(getCertifications, {})
    wiredCertifications({ data }) {
        if (data) {
            this.allCertifications = data;
        }
    }
    firstTime = false;

    renderedCallback() {
        if (this.preSelectedFacility && !this.firstTime) {
            this.selectedFacility = this.preSelectedFacility;
            this.firstTime = true;
            this.alignSelectedFacilityRecord();
        }
    }

    get certifications() {
        let availableCerts = [];
        if (this.allCertifications) {
            this.allCertifications.forEach(
                cert => {
                    if (cert.Applicable_to__c && this.selectedFacilityRecord && cert.Applicable_to__c.indexOf(this.selectedFacilityRecord.RecordType.Name) > -1) availableCerts.push(cert);
                }
            );
        }
        return availableCerts;
    }
    selectFacility(event) {
        if (this.checkFormFields()) {
            this.selectedFacility = event.detail.data;
            this.alignSelectedFacilityRecord();
        }
    }
    removeFacility() {
        this.selectedFacility = null;
    }
    checkFormFields() {
        const inputValid = [...this.template.querySelectorAll('input')]
            .reduce((validSoFar, inputCmp) => {
                if (validSoFar) inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const selectValid = [...this.template.querySelectorAll('select')]
            .reduce((validSoFar, inputCmp) => {
                if (validSoFar) inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return inputValid && selectValid;
    }
    bookAudits() {
        if (this.checkFormFields() && this.template.querySelectorAll('input:checked') && this.template.querySelectorAll('input:checked').length > 0) {
            this.getFormData();
            this.saving = true;
            scheduleAudit({icgNotificationObj: JSON.stringify(this.auditData), certificationList: JSON.stringify(this.selectedCertifications)}).then(resp => {
                this.modalMessage = 'Thank you for your request. IATA will contact you shortly.';
                this.modalImage = this.checkedImage;
                this.showModal = true;
                this.saving = false;
            }).catch(err => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Something went wrong',
                    message: 'Please, contact IATA support if error continues.',
                    variant: 'error',
                }));
                this.saving=false;
            });
            
        }else{
            if(!this.template.querySelectorAll('input:checked') || this.template.querySelectorAll('input:checked').length < 1){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Select your validation programs',
                    message: 'At least one validation program is required to continue',
                    variant: 'error',
                }));
            }
        }
    }
    getFormData() {
        let allTextInputs = this.template.querySelectorAll(".form-control");
        this.auditData = {}
        allTextInputs.forEach(inpt => {
            this.auditData[inpt.name] = inpt.value;    
        });

        let dateinpt = this.template.querySelector('[data-name="preferable-audit-date"]');
        this.auditData[dateinpt.name] = dateinpt.value;
        
        this.auditData.Station__c = this.selectedFacility;
        this.auditData.Target_Contact__c = this.userInfo.ContactId;
        this.selectedCertifications = [];
        this.template.querySelectorAll('input:checked').forEach(elem =>{
            this.selectedCertifications.push({id: elem.dataset.id, name: elem.dataset.name});
        })
        
	}
    closeModal(event) {
        //this.showModal = false;
        if (event) event.preventDefault();
        this.dispatchEvent(new CustomEvent('completed'));
    }
    clickCertif(event) {
        event.preventDefault();
        let eTarget = event.currentTarget;
        eTarget.classList.toggle('itemUnselected');
        eTarget.classList.toggle('itemSelected');
        eTarget.selected = eTarget.selected === true ? false : true;

        let inputs = this.template.querySelectorAll("[data-name='" + eTarget.getAttribute("data-name") + "']");
        inputs.forEach(element => {
            if (element.type === "checkbox") {
                element.checked = element.checked === true ? false : true;
            }
        })
    }
    alignSelectedFacilityRecord() {
        if (this.userManagedFacilities) {
            this.userManagedFacilities.forEach(fac => {
                if (fac.Id === this.selectedFacility) this.selectedFacilityRecord = fac;
            });
        }
    }
    get getLogoUrl() {
        if (this.selectedFacilityRecord && this.selectedFacilityRecord.logoUrl__c) {
            return this.selectedFacilityRecord.logoUrl__c;
        }

        return resources + "/img/no-image.svg";
    }

    get companyData() {
        let cdata = '';
        if (this.selectedFacilityRecord) {
            if (this.selectedFacilityRecord.Name) cdata += '<b>' + this.selectedFacilityRecord.Name.toUpperCase() + '</b>,';
            if (this.selectedFacilityRecord.Street_Nr_FOR__c) cdata += this.selectedFacilityRecord.Street_Nr_FOR__c + ',';
            if (this.selectedFacilityRecord.City__c) cdata += this.selectedFacilityRecord.City__c + ',';
            if (this.selectedFacilityRecord.IATA_ISO_Country__c) cdata += this.selectedFacilityRecord.IATA_ISO_Country__r.Name + ',';
            cdata = cdata.slice(0, -1);
        }
        return cdata;
    }
}
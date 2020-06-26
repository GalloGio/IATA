import { LightningElement, api, track,wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import renewCertification_ from "@salesforce/apex/CW_CertificationsManagerController.renewCertification";
import getDeprecatedCert from "@salesforce/apex/CW_CertificationsManagerController.getFacilityDeprecatedCertifications";
import updateFieldEdited_ from "@salesforce/apex/CW_CertificationsManagerController.updateFieldEdited";
import getNextCertificationID from '@salesforce/apex/CW_CertificationsManagerController.getNextCertificationID';
import {refreshApex} from '@salesforce/apex';
export default class CwCertificationManager extends LightningElement {
	@api recordId;
	@api certificationInfo;
	@api lstCertifications;
	@api availableCertifications;
	@api sfocScope = [];
	@api ceivScope = [];
	@api label;

	@track isRenewMode = false;
	@track isEditMode = false;
	@track showModal = false;
	@track showHistory = false;
	@track showScope = false;

	@track formatedIssuedDate;
	@track formatedExpireDate;
	@track newCertId;
	@track selectedScope ='';
	@track scope = [];
	@track scopeToUse;

	@track deprecatedCerts = [];

	mapForCertifiID;

	@track showConfirmationModal = false;
	@track headerModal = 'Edit Capabilities Certification';
	@track messageModal = 'Are you sure ?';

	initialized = false;

	@wire(getNextCertificationID, {})
    wiredCertificationID({ data }) {
        if (data) {
			this.mapForCertifiID = JSON.parse(JSON.parse(JSON.stringify(data)));
        }
	}

	get hideButton() {

		let availableButton = this.availableCertifications ? this.availableCertifications.filter(elem  => {
			return elem.value === this.certificationInfo.value
			}) : [];
		return availableButton.length < 1;
	}

	get disableField(){
		return this.isEditMode === false;
	}

	get isSFOCScope(){
		return this.scopeToUse === "SFOC_Scope__c" || this.certificationInfo.scopeToUse === "SFOC_Scope__c";
	}

	get isCEIVcope(){
		return this.scopeToUse === "CEIV_Scope_List__c" || this.certificationInfo.scopeToUse === "CEIV_Scope_List__c";
	}

	get isIEnvAcope(){
		return this.scopeToUse === "IEnvA_Scope__c" || this.certificationInfo.scopeToUse === "IEnvA_Scope__c";
	}

	get isCanSave(){
		return this.selectedScope === '';
	}



	renderedCallback(){
		if(!this.initialized){
			this.initialized = true;
			console.log(this.certificationInfo);
			this.newCertId = this.certificationInfo.certificationId;
		}
	}
	
	handleEditCertification() {
		this.isRenewMode = false;
		this.isEditMode = !this.isEditMode;
	}

	handleRenew() {
		let today = new Date();
		let dd = String(today.getDate()).padStart(2, "0");
		let mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
		let yyyy = today.getFullYear();
		let todayDate = yyyy + "-" + mm + "-" + dd;
		this.formatedIssuedDate = todayDate;
		this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,this.certificationInfo.expirationPeriod);
		this.showScope = true;
		this.scope = this.certificationInfo.listScope;
		this.newCertId = this.mapForCertifiID[0][this.certificationInfo.name];
		this.showModal = true;
		this.isRenewMode = true;
		this.isEditMode = false;
	}
	closeModal() {
		this.isRenewMode = false;
		this.isEditMode = false;
		this.showModal = false;
	}
	closeConfirmationModal(){
		this.showConfirmationModal = false;
	}
	acceptConfirmationModal(){
		this.closeConfirmationModal();
		this.dispatchEvent(
			new CustomEvent("editonlycapabilitiesbycerti", {
				detail: { certificationId: this.certificationInfo.id }
			})
		);
	}
	getExpirationDateByCertification(issueDate, expirationPeriod){
		var parseIssue = new Date(issueDate);
		var year = parseIssue.getFullYear();
		var month = parseIssue.getMonth();
		var day = parseIssue.getDate();
		var newExpiration = (year + Number(expirationPeriod)) + '-' + (month+1) + '-' + day;
		return newExpiration;
	}
	handleChangeEditMode(event){
		let name = event.target.dataset.name;
		let value = event.detail.value;
		let fieldToUpdate = {};
		if(name === 'scope-edition'){
			if(this.certificationInfo.scopeToUse === "CEIV_Scope_List__c"){
				fieldToUpdate = {
					Id: this.certificationInfo.id,
					CEIV_Scope_List__c: value				
				};
			}
			if(this.certificationInfo.scopeToUse === "SFOC_Scope__c"){
				fieldToUpdate = {
					Id: this.certificationInfo.id,
					SFOC_Scope__c : value					
				};
			}	
			if(this.certificationInfo.scopeToUse === "IEnvA_Scope__c"){
				fieldToUpdate = {
					Id: this.certificationInfo.id,
					IEnvA_Scope__c : value					
				};
			}				
		}
		if(name === 'issuing-edition'){
				fieldToUpdate = {
					Id: this.certificationInfo.id,				
					Issue_Date__c : value			
				};
		}
		if(name === 'expiriation-edition'){
			fieldToUpdate = {
				Id: this.certificationInfo.id,				
				Expiration_Date__c : value			
			};
		}
		let jsonGroup = JSON.stringify(fieldToUpdate);
		this.updateFieldEdited(jsonGroup);
	}
	updateFieldEdited(jsonGroup){
		updateFieldEdited_({jsonGroup})
		.then(() => {
			this.isEditMode=false;
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Success',
					message: 'Record updated',
					variant: 'success'
				})
			);

		})
		.catch(error => {
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error updating record',
					message: error.body.message,
					variant: 'error'
				})
			);
		});
	}
	handleIssuedDateChange(event) {
		this.formatedIssuedDate = event.target.value;
		this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,this.certificationInfo.expirationPeriod);
	}
	handleExpireDateChange(event) {
		this.formatedExpireDate = event.target.value;
	}
	handleCertIdChange(event) {
		this.newCertId = event.target.value;
	}
	handleScopeChange(event) {
		let value = event.detail.value;
		this.selectedScope = value.join(';');
	}
	handleModalAccept() {
		if (this.isEditMode) {
			//this.deleteCertification(this.certificationInfo);
			this.showModal = false;
			this.isEditMode = false;
		} else if (this.isRenewMode) {
			this.renewCertification();
			this.showModal = false;
			this.isRenewMode = false;
		}
	}
	handleEditCapabilities(){
		this.showConfirmationModal = true;
	}
	deleteCertification(certification) {
		let certificationId = certification.id;
		deleteCertification_({ certificationId })
			.then(response => {
				if (response) {
					this.dispatchEvent(
						new CustomEvent("certificationdelete", {
							detail: { certification: certification }
						})
					);
					this.showToast(this.certificationInfo.name,"Certification deleted", "success");
				}
			})
			.catch(error => {
				this.showToast(this.certificationInfo.name,"Something went wrong", "error");
			});
	}
	renewCertification() {
		const certificationId = this.certificationInfo.id;
		const issuedDate = this.formatedIssuedDate;
		const expirationDate = this.formatedExpireDate;
		const newCertificationId = this.newCertId;
		const scopeValue = this.selectedScope;
		renewCertification_({
			certificationId,
			issuedDate,
			expirationDate,
			newCertificationId,
			scopeValue
		}).then(response => {
			if (response) {
				this.dispatchEvent(
					new CustomEvent("certificationrenewed", {
						detail: { certificationId: certificationId }
					})
				);
				this.showToast(this.certificationInfo.name,"Certification renewed", "success");
				this.getDeprecatedCertifications();
				this.refreshApex(this.mapForCertifiID);
			}
		});
		
	}
	handleHistory() {
		this.showHistory = !this.showHistory;
		if (this.showHistory) {
			this.getDeprecatedCertifications();
		}
	}
	getDeprecatedCertifications() {
		const facilityId = this.recordId;
		const certificationId = this.certificationInfo.value;
		getDeprecatedCert({ facilityId, certificationId }).then(response => {
			if (response) {
				this.deprecatedCerts = [];
				let dataParsed = JSON.parse(response);
				dataParsed.forEach(certification => {
					let scope;
					
					if(certification.ICG_Certification__r.Name.includes("CEIV")){
						scope = certification.CEIV_Scope_List__c;
					} else if(certification.ICG_Certification__r.Name === "Smart Facility Operational Capacity"){						
						scope = certification.SFOC_Scope__c;
					} 
					else if(certification.ICG_Certification__r.Name.includes("IEnvA")){						
						scope = certification.IEnvA_Scope__c;
					} else {
						scope = null;
					}
					let certInfo = {
						id: certification.Id,
						value: certification.ICG_Certification__c,
						certificationId: certification.Certification_Id__c,
						name: certification.ICG_Certification__r.Name,
						creationDate: this.dateFormat(
							certification.ICG_Certification__r.CreatedDate
						),
						issuingDate: this.dateFormat(certification.Issue_Date__c),
						expirationDate: this.dateFormat(certification.Expiration_Date__c),
						scope: scope,
						status: certification.Status__c
					};
					this.deprecatedCerts.push(certInfo);
				});
				if (this.deprecatedCerts.length === 0) {
					this.showHistory = false;
				}
			}
		});
	}
	dateFormat(date) {
		date = date.split("T");
		date = date[0].split("-");
		let dateFormated = date[2] + "/" + date[1] + "/" + date[0];
		return dateFormated;
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
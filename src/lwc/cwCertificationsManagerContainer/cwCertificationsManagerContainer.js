import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import RECORDTYPE_NAME_FIELD from '@salesforce/schema/ICG_Account_Role_Detail__c.RecordType.Name';
import RECORDTYPE_DEVELOPER_NAME_FIELD from '@salesforce/schema/ICG_Account_Role_Detail__c.RecordType.DeveloperName';
import getFacilityCertifications_ from '@salesforce/apex/CW_CertificationsManagerController.getFacilityCertifications';
import refreshFacilityCertifications from '@salesforce/apex/CW_CertificationsManagerController.refreshFacilityCertifications';
import getAllCertifications from '@salesforce/apex/CW_CertificationsManagerController.getAllCertifications';
import getScopeByCertificationAndStation from '@salesforce/apex/CW_CertificationsManagerController.getScopeByCertificationAndStation';
import getNextCertificationID from '@salesforce/apex/CW_CertificationsManagerController.getNextCertificationID';
import createCertification_ from '@salesforce/apex/CW_CertificationsManagerController.createCertification';
import getPicklistValues from '@salesforce/apex/CW_Utilities.getPicklistValues';
import labels from 'c/cwOneSourceLabels';
export default class CwCertificationsManagerContainer extends LightningElement {
	@api recordId;
	label = labels.labels();
	@track certifications = [];
	@track showModal = false;
	@track showScope = false;

	@wire(getRecord, { recordId: "$recordId", fields: [RECORDTYPE_NAME_FIELD , RECORDTYPE_DEVELOPER_NAME_FIELD]})
    facility;

	@track certificationsUsed = [];
	@track certificationsRemaining = [];
	@track certificationDropdowOptions = [];
	@track allcertificationDropdowOptions = [];
	@track ceivScope = [];
	@track sofcScope = [];
	@track ienvaScope = [];
	@track mapScopeByCertStation;
	@track scope = [];
	@track scopeToUse = '';
	@track selectedCert = '';
	@track selectedScope;
	@track formatedIssuedDate;
	@track formatedExpireDate;
	@track newCertificationId;
	initialized=false;

	mapForCertifiID;

	@wire(getScopeByCertificationAndStation, {})
    wiredScopes({ data }) {
        if (data) {
            this.mapScopeByCertStation = JSON.parse(JSON.parse(JSON.stringify(data)));
        }
	}

	@wire(getNextCertificationID, {})
    wiredCertificationID({ data }) {
        if (data) {
			this.mapForCertifiID = JSON.parse(JSON.parse(JSON.stringify(data)));
        }
	}
	
	
	renderedCallback(){
		if(!this.initialized){
			this.loading=true;
			this.initialized = true;
			this.getValuesPicklistScope();			
		}
	}

	getValuesPicklistScope(){
		let objectApi = "ICG_Capability_Assignment_Group__c";
		let fieldApi = "CEIV_Scope_List__c";
		getPicklistValues({objectApi,fieldApi}).then(responseCeiv =>{
			if(responseCeiv){
				let dataParsed = JSON.parse(responseCeiv);
				let tempDataScope = [];
				dataParsed.forEach(pck => {
					let newPck = {
						label : pck.label,
						value : pck.api
					}
					tempDataScope.push(newPck);
				});
				this.ceivScope = tempDataScope;
			}
		});
		fieldApi = "IEnvA_Scope__c";
		getPicklistValues({objectApi,fieldApi}).then(responseCeiv =>{
			if(responseCeiv){
				let dataParsed = JSON.parse(responseCeiv);
				let tempDataScope = [];
				dataParsed.forEach(pck => {
					let newPck = {
						label : pck.label,
						value : pck.api
					}
					tempDataScope.push(newPck);
				});
				this.ienvaScope = tempDataScope;
			}
		});
		fieldApi = "SFOC_Scope__c";
		getPicklistValues({objectApi,fieldApi}).then(responseSfoc =>{
			if(responseSfoc){
				let dataParsed = JSON.parse(responseSfoc);
				let tempDataScope = [];
				dataParsed.forEach(pck => {
					let newPck = {
						label : pck.label,
						value : pck.api
					}
					tempDataScope.push(newPck);
				});
				this.sofcScope = tempDataScope;

				this.getFacilityCertifications(this.recordId);
			}
		
		});
	}

	getFacilityCertifications(recordId){
		getFacilityCertifications_({ facilityId: recordId }).then(data =>{
			if(data){
				let dataParsed = JSON.parse(data);
				this.filteredScopesByStation(dataParsed);
			}
		})
		.finally(() => {
			this.loading = false;
		});	
	}
	
	loading=true;
	get isLoading(){
		return this.loading;
	}

	get labelStationType() {
        return getFieldValue(this.facility.data, RECORDTYPE_NAME_FIELD);
	}

	get valueStationType() {
        return getFieldValue(this.facility.data, RECORDTYPE_DEVELOPER_NAME_FIELD);
	}
	
	get isSFOCScope(){
		return this.scopeToUse === "SFOC_Scope__c";
	}

	get isCEIVcope(){
		return this.scopeToUse === "CEIV_Scope_List__c";
	}

	get isIEnvAcope(){
		return this.scopeToUse === "IEnvA_Scope__c";
	}

	get isCanSave(){
		return this.selectedCert === '' ? true : false || this.scopeToUse === '' ? true : false ;
	}

	filteredScopesByStation(dataParsed){
		let ceivScopeFiltered = [];
		this.mapScopeByCertStation[this.valueStationType].forEach(elem=>{
			let scopeValue = this.ceivScope.filter(
				currentScope => currentScope.value === elem.value
			);
			if (scopeValue && scopeValue.length > 0) {
				ceivScopeFiltered.push(scopeValue[0]);
			}
		})
		this.ceivScope = ceivScopeFiltered;
		this.refreshCertifications(dataParsed);
	}

	checkRemainingCertifications(){
		getAllCertifications({}).then(response =>{
			if(response){
				this.certificationsRemaining = [];
				this.certificationDropdowOptions = [];
				this.allcertificationDropdowOptions = [];
				let dataParsed = JSON.parse(response);
				dataParsed.forEach(cert =>{
					let usedCert = [];
					let valueItems = {
						label : cert.Name,
						value : cert.Id
					}
					this.allcertificationDropdowOptions.push(valueItems);
					//check used cert
					usedCert = this.certificationsUsed.filter(certification =>cert.Id === certification.id );

					//check certi availables for station
					let availableList=[];
					let isAvailable=false;
					if(cert.Applicable_to__c != undefined && cert.Applicable_to__c != null){
						availableList = cert.Applicable_to__c.split(';');
						isAvailable = availableList.includes(this.labelStationType);
					}					
					
					if(usedCert.length === 0 && isAvailable){
						this.certificationsRemaining.push(cert);
						let option = {
							label : cert.Name,
							value : cert.Id
						}
						this.certificationDropdowOptions.push(option);
					}
				})
			}
			this.initialized = true;
		})
	}
	handleIssuedDateChange(event){
		this.formatedIssuedDate = event.target.value;
		let selectedCertification = this.certificationsRemaining.filter(cert => cert.Id === this.selectedCert);
		this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
	}
	handleExpireDateChange(event){
		this.formatedExpireDate = event.target.value;
	}
	handleCertIdChange(event){
		this.newCertificationId = event.target.value;
	}
	changeCertification(event){
		this.selectedCert = event.detail.value;
		let selectedCertification = this.certificationsRemaining.filter(cert => cert.Id === this.selectedCert);
		if(selectedCertification){
			if(selectedCertification[0].Name === "Smart Facility Operational Capacity"){
				this.scope = this.sofcScope;
				this.showScope = true;
				this.scopeToUse = "SFOC_Scope__c";
				this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
			}
			else if(selectedCertification[0].Name.includes("CEIV")){
				this.scope = this.ceivScope;
				this.showScope = true;
				this.scopeToUse = "CEIV_Scope_List__c";
				this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
			}
			else if(selectedCertification[0].Name.includes("IEnvA")){
				this.scope = this.ienvaScope;
				this.showScope = true;
				this.scopeToUse = "IEnvA_Scope__c";
				this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
			}
			else{
				this.scope = [];
				this.showScope = false;
			}
			this.newCertificationId = this.mapForCertifiID[0][selectedCertification[0].Name];
		}
	}
	getExpirationDateByCertification(issueDate, expirationPeriod){
		var parseIssue = new Date(issueDate);
		var year = parseIssue.getFullYear();
		var month = parseIssue.getMonth()+1;
		var day = parseIssue.getDate();
		var newExpiration = (year + Number(expirationPeriod)) + '-' + month + '-' + day;
		return newExpiration;
	}
	createCertification(){
		this.showModal = false;
		let newCertification;
		if(this.scopeToUse === "CEIV_Scope_List__c"){
			newCertification = {
				ICG_Account_Role_Detail__c : this.recordId,
				ICG_Certification__c : this.selectedCert,
				Certification_Id__c : this.newCertificationId,
				Issue_Date__c : this.formatedIssuedDate,
				Expiration_Date__c : this.formatedExpireDate,
				CEIV_Scope_List__c : this.selectedScope
			}
		}
		else if(this.scopeToUse === "SFOC_Scope__c"){
			newCertification = {
				ICG_Account_Role_Detail__c : this.recordId,
				ICG_Certification__c : this.selectedCert,
				Certification_Id__c : this.newCertificationId,
				Issue_Date__c : this.formatedIssuedDate,
				Expiration_Date__c : this.formatedExpireDate,
				SFOC_Scope__c : this.selectedScope
			}
		}
		else if(this.scopeToUse === "IEnvA_Scope__c"){
			newCertification = {
				ICG_Account_Role_Detail__c : this.recordId,
				ICG_Certification__c : this.selectedCert,
				Certification_Id__c : this.newCertificationId,
				Issue_Date__c : this.formatedIssuedDate,
				Expiration_Date__c : this.formatedExpireDate,
				IEnvA_Scope__c : this.selectedScope
			}
		}
		else{
			newCertification = {
				ICG_Account_Role_Detail__c : this.recordId,
				ICG_Certification__c : this.selectedCert,
				Certification_Id__c : this.newCertificationId,
				Issue_Date__c : this.formatedIssuedDate,
				Expiration_Date__c : this.formatedExpireDate,
				SFOC_Scope__c : this.selectedScope
			}
		}
		let jsonCertification = JSON.stringify(newCertification);
		createCertification_({jsonCertification}).then(response =>{
			if(response){
				let ardCert = response;
				this.refreshCertificationsRenewed();
                this.openModal = false;
				this.showToast('Create Certification:',"Certification created", "success");
				this.dispatchEvent(new CustomEvent('viewcapabilities',{detail : {ardCert}}));
			}
			else{
				this.showToast('Error:',"To create certification", "error");
			}
		})
	}
	changeScope(event){
		let value = event.detail.value;
		this.selectedScope = value.join(';');		
	}
	changeCurrency(event){
		this.selectedCurrency = event.detail.value;
	}
	refreshCertificationsAfterDelete(event){
		this.certifications = this.certifications.filter(cert => cert.id !== event.detail.certification.id);
		this.certificationsUsed = this.certificationsUsed.filter(cert => cert.id !== event.detail.certification.value );
		this.checkRemainingCertifications();
	}
	renewCertification(event){
		let ardCert = event.detail.certificationId;
		this.refreshCertificationsRenewed();
		this.dispatchEvent(new CustomEvent('viewcapabilities',{detail : {ardCert}}));
	}
	editOnlyCapabilitiesByCerti(event){
		let ardCert = event.detail.certificationId;
		let isCapabCertiMode = true;
		this.dispatchEvent(new CustomEvent('viewcapabilities',{detail : {ardCert, isCapabCertiMode}}));
	}
	refreshCertificationsRenewed(){
		const facilityId = this.recordId;
		refreshFacilityCertifications({facilityId}).then(response =>{
			if(response){
				let dataParsed = JSON.parse(response);
				this.refreshCertifications(dataParsed);
			}
		})

	}

	refreshCertifications(dataParsed){
		this.certifications = [];
		this.usedCert = [];
		this.certificationsUsed = [];
		
		dataParsed.forEach(certification => {
			let scope;
			let listScope = [];
			let scopeToUse;
			if(certification.ICG_Certification__r.Name.includes("CEIV")){
				scopeToUse = "CEIV_Scope_List__c";
				listScope = this.ceivScope;
				let scopeValue = this.ceivScope.filter(
					currentScope => currentScope.label === certification.CEIV_Scope_List__c
				);
				if (scopeValue && scopeValue.length > 0) {
					scope = scopeValue[0].value;
				}
			}
			else if(certification.ICG_Certification__r.Name === "Smart Facility Operational Capacity"){
				scopeToUse = "SFOC_Scope__c";
				listScope = this.sofcScope;
				
				scope = certification.SFOC_Scope__c;
				
			}
			else if(certification.ICG_Certification__r.Name.includes("IEnvA")){
				scopeToUse = "IEnvA_Scope__c";
				listScope = this.ienvaScope;
				
				scope = certification.IEnvA_Scope__c;
			}
			else{
				scope = null;
			}
			let certInfo = {
				id : certification.Id,
				value : certification.ICG_Certification__c,
				certificationId : certification.Certification_Id__c,
				name : certification.ICG_Certification__r.Name,
				creationDate : this.dateFormat(certification.ICG_Certification__r.CreatedDate),
				issuingDate: this.dateFormat(certification.Issue_Date__c),
				expirationDate: this.dateFormat(certification.Expiration_Date__c),
				type : certification.ICG_Certification__r.Certification_Type__c,
				scope : scope,
				listScope : listScope,
				scopeToUse : scopeToUse,
				status : certification.Status__c,
				expirationPeriod : certification.ICG_Certification__r.Expiration_Period__c
			}
			let usedCert = {
				id : certification.ICG_Certification__c,
				name : certification.ICG_Certification__r.Name,
				type : certification.ICG_Certification__r.Certification_Type__c
			}
			this.certifications.push(certInfo);
			this.certificationsUsed.push(usedCert);
		});
		this.checkRemainingCertifications();
	}
	dateFormat(date){
		date = date.split("T");
		date = date[0].split("-");
		//let dateFormated = date[2]+"/"+date[1]+"/"+date[0];
		let dateFormated = date[0]+"/"+date[1]+"/"+date[2];
		return dateFormated;
	}
	viewCapabilities(certificationId){
		this.scopeToUse = '';
		this.dispatchEvent(new CustomEvent('viewcapabilities',{detail : certificationId}));
	}
	openModal(){
		this.showModal = true;
		let today = new Date();
		let dd = String(today.getDate()).padStart(2, '0');
		let mm = String(today.getMonth()+1).padStart(2, '0'); //January is 0!
		let yyyy = today.getFullYear();
		let todayDate = yyyy+'-'+mm+'-'+dd;
		this.formatedIssuedDate = todayDate;
		this.formatedExpireDate = todayDate;
		this.selectedCert = '';
		this.selectedScope = '';
		this.newCertificationId = '';
	}
	closeModal(){
		this.showModal = false;
		this.scopeToUse = '';
		this.showScope = false;
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
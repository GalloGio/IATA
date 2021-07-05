import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import RECORDTYPE_NAME_FIELD from '@salesforce/schema/ICG_Account_Role_Detail__c.RecordType.Name';
import RECORDTYPE_DEVELOPER_NAME_FIELD from '@salesforce/schema/ICG_Account_Role_Detail__c.RecordType.DeveloperName';
import getPermissionToEdit from "@salesforce/apex/CW_Utilities.getPermissionToEdit";
import getFacilityCertifications_ from '@salesforce/apex/CW_CertificationsManagerController.getFacilityCertifications';
import refreshFacilityCertifications from '@salesforce/apex/CW_CertificationsManagerController.refreshFacilityCertifications';
import getAllCertifications from '@salesforce/apex/CW_CertificationsManagerController.getAllCertifications';
import getScopeByCertificationAndStation from '@salesforce/apex/CW_CertificationsManagerController.getScopeByCertificationAndStation';
import getNextCertificationID from '@salesforce/apex/CW_CertificationsManagerController.getNextCertificationID';
import createCertification_ from '@salesforce/apex/CW_CertificationsManagerController.createCertification';
import renewCertification_ from "@salesforce/apex/CW_CertificationsManagerController.renewCertification";
import getPicklistValues from '@salesforce/apex/CW_Utilities.getPicklistValues';
import getCertificationWithoutCapabilities from '@salesforce/apex/CW_CertificationsManagerController.getCertificationWithoutCapabilities';
import labels from 'c/cwOneSourceLabels';
import pubsub from 'c/cwPubSub';
export default class CwCertificationsManagerContainer extends LightningElement {
	@api recordId;
	@api validationPrograms;
	label = labels.labels();
	@track editMode=false;
	@track certifications = [];
	@track showModal = false;
	@track showScope = false;
	@track showCapabilities = false;
	@track showCertifications = true;

	@api
	register(){
		pubsub.register('certificationupdate', this.certificationUpdateCallback); 
	} 

	@wire(getRecord, { recordId: "$recordId", fields: [RECORDTYPE_NAME_FIELD , RECORDTYPE_DEVELOPER_NAME_FIELD]})
	facility;

	@track certificationsUsed = [];
	@track certificationsRemaining = [];
	@track certificationDropdowOptions = [];
	@track allcertificationDropdowOptions = [];
	@track certificationsAllowedList;
	@track ceivScope = [];
	@track sofcScope = [];
	@track ienvaScope = [];
	@track mapScopeByCertStation;
	@track scope = [];
	@track scopeToUse = '';
	@track selectedCert = '';
	@track selectedScope = '';
	@track formatedIssuedDate;
	@track formatedExpireDate;
	@track newCertificationId;
	@track groupId;
	@track isCapabCertiMode=false;
	@track renewMode=false;
	@track jsonCertification = '';
	initialized=false;
	byPassScope=false;

	@track certificationsWithoutCapab;
	certificationName;

	connectedCallback(){
		this.certificationUpdateCallback = this.certificationUpdate.bind(this);
		this.register();
	}

	certificationUpdateCallback;
	certificationUpdate(payload) {
		this.refreshAllComponent();
	}
	
	renderedCallback(){
		if(!this.initialized){
			this.loading=true;
			this.initialized = true;

			getPermissionToEdit({})
			.then(result => {
				this.editMode = result;
				if(this.editMode){
					getScopeByCertificationAndStation({}).then(data =>{
						if(data){
							this.mapScopeByCertStation = JSON.parse(JSON.parse(JSON.stringify(data)));
							let recordId = this.recordId;
							let validationPrograms = this.validationPrograms;
							getCertificationWithoutCapabilities({recordId,validationPrograms})
							.then(result => {
								if (result) {
									this.certificationsWithoutCapab = result;
									this.getValuesPicklistScope();
								}						
							})
							.catch(error => {
								this.dispatchEvent(
									new ShowToastEvent({
										title: 'Error reading certifications without capabilities',
										message: error,
										variant: 'error'
									})
								);
							});	
						}				
					});
				}	
				else{
					this.loading=false;
				}			
			})		
		}
	}

	getNextCertificationID(certiSelected, recordId){
		getNextCertificationID({certiSelected,recordId})
			.then(result => {
				if (result) {
					this.changeCertification(result);
				}						
			});				
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
		fieldApi = "IENVA_Scope__c";
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

				this.getFacilityCertifications(this.recordId,this.valueStationType);
			}
		
		});
	}

	getFacilityCertifications(recordId,stationRT){
		const validationPrograms = this.validationPrograms;

		getFacilityCertifications_({ facilityId: recordId, stationRT: stationRT, validationPrograms: validationPrograms }).then(data =>{
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
		return this.scopeToUse === "IENVA_Scope__c";
	}

	get isCanSave(){
		return (this.selectedScope === '' && !this.byPassScope) ? true : false;
	}

	get getCertificationName(){
		return this.certificationName;
	}

	actionToRefresh;
	get getActionToRefresh(){
		return this.actionToRefresh === true;
	}

	filteredScopesByStation(dataParsed){
		let ceivScopeFiltered = [];

		if(this.mapScopeByCertStation[this.valueStationType] != undefined && this.mapScopeByCertStation[this.valueStationType] != null){
			this.mapScopeByCertStation[this.valueStationType].forEach(elem=>{
				let scopeValue = this.ceivScope.filter(
					currentScope => currentScope.value === elem.value
				);
				if (scopeValue && scopeValue.length > 0) {
					ceivScopeFiltered.push(scopeValue[0]);
				}
			})
		}
		this.ceivScope = ceivScopeFiltered;
		
		this.refreshCertifications(dataParsed);
		
	}

	checkRemainingCertifications(){
		let stationRT = this.valueStationType;
		let validationPrograms = this.validationPrograms;
		getAllCertifications({stationRT,validationPrograms}).then(response =>{
			if(response){
				this.certificationsRemaining = [];
				this.certificationDropdowOptions = [];
				this.allcertificationDropdowOptions = [];
				let certificationsAllowedList = [];
				let dataParsed = JSON.parse(response);
				dataParsed.forEach(cert =>{
					let usedCert = [];
					let valueItems = {
						label : cert.Label__c,
						value : cert.Id,
						validationProgram : cert.ValidationPrograms__c
					}
					this.allcertificationDropdowOptions.push(valueItems);
					//check used cert
					usedCert = this.certificationsUsed.filter(certification =>cert.Id === certification.id );

					//check certi availables for station
					let availableList=[];
					let isAvailable=false;
					if(cert.Applicable_to__c != undefined && cert.Applicable_to__c != null){
						availableList = cert.Applicable_to__c.split(';');
						isAvailable = availableList.includes(this.valueStationType);
					}					
					
					if(usedCert.length === 0 && isAvailable){
						this.certificationsRemaining.push(cert);
						let option = {
							label : cert.Label__c,
							value : cert.Id,
							validationProgram : cert.ValidationPrograms__c
						}
						this.certificationDropdowOptions.push(option);
					}

					certificationsAllowedList.push(valueItems);
				})
				this.certificationsAllowedList = certificationsAllowedList;
			}
			this.initialized = true;
		});
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
	handleChangeCertification(event){
		this.selectedCert = event.detail.value;
		this.getNextCertificationID(event.detail.value,this.recordId);
	}
	changeCertification(nextCertiID){
		let selectedCertification = this.certificationsRemaining.filter(cert => cert.Id === this.selectedCert);
		if(selectedCertification){
			if(selectedCertification[0].Name.toLowerCase() === "smart_facility_operational_capacity"){
				this.scope = this.sofcScope;
				this.showScope = true;
				this.scopeToUse = "SFOC_Scope__c";
				this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
				this.byPassScope = false;
			}
			else if(selectedCertification[0].Name.toLowerCase().includes("ceiv_")){
				this.scope = this.ceivScope;
				this.showScope = true;
				this.scopeToUse = "CEIV_Scope_List__c";
				this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
				this.byPassScope = false;
			}
			else if(selectedCertification[0].Name.toLowerCase().includes("ienva_stage_")){
				this.scope = this.ienvaScope;
				this.showScope = true;
				this.scopeToUse = "IENVA_Scope__c";
				this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
				this.byPassScope = false;
			}
			else if(selectedCertification[0].Name.toLowerCase() === "united_for_wildlife"){
				this.scope = this.ienvaScope;
				this.showScope = true;
				this.scopeToUse = "IENVA_Scope__c";
				this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate,selectedCertification[0].Expiration_Period__c);
				this.byPassScope = false;
			}
			else{
				this.showScope = true;
				this.byPassScope = true;
			}
			this.newCertificationId = nextCertiID;
			this.certificationName = selectedCertification[0].Label__c;
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
		this.groupId='';
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
		else if(this.scopeToUse === "IENVA_Scope__c"){
			newCertification = {
				ICG_Account_Role_Detail__c : this.recordId,
				ICG_Certification__c : this.selectedCert,
				Certification_Id__c : this.newCertificationId,
				Issue_Date__c : this.formatedIssuedDate,
				Expiration_Date__c : this.formatedExpireDate,
				IENVA_Scope__c : this.selectedScope
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
		this.jsonCertification = JSON.stringify(newCertification);

		let jsonCertification = this.jsonCertification;

		this.openModal = false;
		this.scopeToUse = '';
		this.showScope = false;
		this.isCapabCertiMode = false;
		this.renewMode = false;
		let includeCapabilities = this.certificationsWithoutCapab.filter(cert => cert.Id === this.selectedCert);
		if(includeCapabilities.length === 0){
			this.changeViewCapabilitiesCertifications();
		}
		else{
			createCertification_({jsonCertification}).then(response =>{
				if(response){
					this.refreshCertificationsRenewed();
				}
				else{
					this.showToast('Error:',"To create certification", "error");
				}
			})
			.catch(error =>{ 
				
			});
		}

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
		let newCertification = JSON.parse(event.detail.newCertification);
		let scopeToUse = event.detail.scopeToUse;
		this.groupId = event.detail.groupId;
		let certId = newCertification.ICG_Certification__c;
		this.isCapabCertiMode = false;
		this.renewMode = true;
		let selectedCertification = this.certificationsUsed.filter(cert => cert.id === certId);
		this.certificationName = selectedCertification[0].label;
		this.refreshCertificationsRenewed();

		this.jsonCertification = JSON.stringify(newCertification);

		let includeCapabilities = this.certificationsWithoutCapab.filter(cert => cert.Id === certId);
		if(includeCapabilities.length === 0){
			this.changeViewCapabilitiesCertifications();
		}
		else{
			const certificationId = this.groupId;
			const issuedDate = newCertification.Issue_Date__c;
			const expirationDate = newCertification.Expiration_Date__c;
			const newCertificationId = newCertification.Certification_Id__c;
			let scopeValue;
			if(scopeToUse === "CEIV_Scope_List__c"){
				scopeValue = newCertification.CEIV_Scope_List__c;
			}
			else if(scopeValue === "SFOC_Scope__c"){
				scopeValue = newCertification.SFOC_Scope__c;
			}
			else if(scopeValue === "IENVA_Scope__c"){
				scopeValue = newCertification.IENVA_Scope__c;
			}
			else{
				scopeValue = newCertification.SFOC_Scope__c;
			}
			
			renewCertification_({
				certificationId,
				issuedDate,
				expirationDate,
				newCertificationId,
				scopeValue
			}).then(response => {
				if (response) {
					this.refreshAllComponent();
				}
				else{
					this.showToast('Error:',"To create certification", "error");
				}
			});
		}
		this.scopeToUse = '';
		this.showScope = false;
	}
	editOnlyCapabilitiesByCerti(event){
		this.groupId = event.detail.certificationId;
		let certId = event.detail.certId;
		this.isCapabCertiMode = true;
		this.renewMode = false;
		let selectedCertification = this.certificationsUsed.filter(cert => cert.id === certId);
		this.certificationName = selectedCertification[0].label;

		let newCertification = {
			ICG_Account_Role_Detail__c : this.recordId,
			ICG_Certification__c : certId,
			Certification_Id__c : this.newCertificationId,
			Issue_Date__c : this.formatedIssuedDate,
			Expiration_Date__c : this.formatedExpireDate
		}
	
		this.jsonCertification = JSON.stringify(newCertification);

		this.changeViewCapabilitiesCertifications();
	}
	refreshCertificationsRenewed(){
		const facilityId = this.recordId;
		const stationRT = this.valueStationType;
		const validationPrograms = this.validationPrograms;
		refreshFacilityCertifications({facilityId,stationRT,validationPrograms}).then(response =>{
			if(response){
				let dataParsed = JSON.parse(response);
				this.refreshCertifications(dataParsed);
			}
		})

	}

	refreshAllComponent(){
		this.initialized = false;
		this.refreshCertificationsRenewed();
	}

	refreshCertifications(dataParsed){
		this.certifications = [];
		this.usedCert = [];
		this.certificationsUsed = [];
		
		dataParsed.forEach(certification => {
			let scope;
			let scopeLabel='';
			let listScope = [];
			let scopeInput=[];
			let scopeToUse;
			if(certification.ICG_Certification__r.Name.toLowerCase().includes("ceiv_")){
				scopeToUse = "CEIV_Scope_List__c";
				listScope = this.ceivScope;
				
				let scopeList = [];
				if(certification.CEIV_Scope_List__c){
					scopeList = certification.CEIV_Scope_List__c.split(';');
				}
				scopeList.forEach(elem=>{
					let scopeValue = this.ceivScope.filter(
						currentScope => currentScope.label === elem
					);
					if (scopeValue && scopeValue.length > 0) {
						scopeInput.push(scopeValue[0].value);	
						scopeLabel += scopeValue[0].label +';';					
					}
				})
				scope = scopeInput;
				scopeLabel = scopeLabel.substring(0, scopeLabel.length - 1);
				this.byPassScope = false;
			}
			else if(certification.ICG_Certification__r.Name.toLowerCase() === "smart_facility_operational_capacity"){
				scopeToUse = "SFOC_Scope__c";
				listScope = this.sofcScope;
				
				let scopeList = [];
				if(certification.SFOC_Scope__c){
					scopeList = certification.SFOC_Scope__c.split(';');
				}
				scopeList.forEach(elem=>{
					let scopeValue = this.sofcScope.filter(
						currentScope => currentScope.label === elem
					);
					if (scopeValue && scopeValue.length > 0) {
						scopeInput.push(scopeValue[0].value);
						scopeLabel += scopeValue[0].label +';';
					}
				})
				scope = scopeInput;
				scopeLabel = scopeLabel.substring(0, scopeLabel.length - 1);
				this.byPassScope = false;
			}
			else if(certification.ICG_Certification__r.Name.toLowerCase().includes("ienva_stage_") || (certification.ICG_Certification__r.Name.toLowerCase() === "united_for_wildlife")){
				scopeToUse = "IENVA_Scope__c";
				listScope = this.ienvaScope;
				
				let scopeList = [];
				if(certification.IENVA_Scope__c){
					scopeList = certification.IENVA_Scope__c.split(';');
				}
				scopeList.forEach(elem=>{
					let scopeValue = this.ienvaScope.filter(
						currentScope => currentScope.label === elem
					);
					if (scopeValue && scopeValue.length > 0) {
						scopeInput.push(scopeValue[0].value);
						scopeLabel += scopeValue[0].label +';';							
					}
				})
				scope = scopeInput;
				scopeLabel = scopeLabel.substring(0, scopeLabel.length - 1);
				this.byPassScope = false;
			}			
			else{
				scope = null;
				this.byPassScope = true;
			}
			let certInfo = {
				id : certification.Id,
				value : certification.ICG_Certification__c,
				certificationId : certification.Certification_Id__c,
				name : certification.ICG_Certification__r.Name,
				label : certification.ICG_Certification__r.Label__c,
				creationDate : this.dateFormat(certification.ICG_Certification__r.CreatedDate),
				issuingDate: this.dateFormat(certification.Issue_Date__c),
				expirationDate: this.dateFormat(certification.Expiration_Date__c),
				type : certification.ICG_Certification__r.Certification_Type__c,
				scope : scope,
				scopeLabel: scopeLabel,
				listScope : listScope,
				scopeToUse : scopeToUse,
				status : certification.Status__c,
				expirationPeriod : certification.ICG_Certification__r.Expiration_Period__c,
				booked : certification.Is_Booked__c,
				byPassScope : this.byPassScope
			}
			let usedCert = {
				id : certification.ICG_Certification__c,
				name : certification.ICG_Certification__r.Name,
				label : certification.ICG_Certification__r.Label__c,
				type : certification.ICG_Certification__r.Certification_Type__c
			}
			this.certifications.push(certInfo);
			this.certificationsUsed.push(usedCert);
		});
		this.actionToRefresh=true;
		this.checkRemainingCertifications();
	}
	dateFormat(date){
		date = date.split("T");
		date = date[0].split("-");
		//let dateFormated = date[2]+"/"+date[1]+"/"+date[0];
		let dateFormated = date[0]+"-"+date[1]+"-"+date[2];
		return dateFormated;
	}
	changeViewCapabilitiesCertifications(){
		this.showCapabilities=!this.showCapabilities;
		this.showCertifications=!this.showCertifications;
	}
	openModal(){
		if(this.certificationDropdowOptions.length > 0){
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
		else{
			this.showToast('Info:',this.label.icg_gridEmptyMessage, "info");
		}
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
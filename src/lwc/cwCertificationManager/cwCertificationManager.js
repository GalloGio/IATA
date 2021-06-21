import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getNotActiveCertifications from "@salesforce/apex/CW_CertificationsManagerController.getFacilityNotActiveCertifications";
import updateFieldEdited_ from "@salesforce/apex/CW_CertificationsManagerController.updateFieldEdited";
import getNextCertificationID from "@salesforce/apex/CW_CertificationsManagerController.getNextCertificationID";
export default class CwCertificationManager extends LightningElement {
	@api recordId;
	@api certificationInfo;
	@api lstCertificationsAllowed;
	@api availableCertifications;
	@api sfocScope = [];
	@api ceivScope = [];
	@api ienvaScope = [];
	@api label;
	@api certificationsWithoutCapab;
	@api stationRT;
	@api validationPrograms;

	@track isRenewMode = false;
	@track isEditMode = false;
	@track showModal = false;
	@track showHistory = false;
	@track showScope = false;
	@track showUpcoming = true;

	@track formatedIssuedDate;
	@track formatedExpireDate;
	@track newCertId;
	@track selectedScope = "";
	@track scope = [];
	@track scopeToUse;
	_labelScope;
	_valuesScope = [];
	_issuingDate;
	_expirationDate;
	byPassScope = false;

	@track deprecatedCerts = [];
	@track upcomingCerts = [];
	deprecatedCertsClone = [];
	upcomingCertsClone = [];
	jsonGroup = [];
	mapForCertifiID;

	@track showConfirmationModal = false;
	@track headerModal = "";
	@track messageModal = "";
	messageModalConfirm = "";
	messageModalActivate = "";

	actionToExecute = {
		action: "",
		result: false
	};

	initialized = false;

	groupSelectedToEdit;
	isUpcomingGroup = false;
	fieldToUpdate = {};
	listGroupToUpdate = [];

	_refreshData;
	@api
	get refreshData() {
		return this._refreshData;
	}
	set refreshData(value) {
		this._refreshData = value;
	}

	get hideButton() {
			let availableButton = this.availableCertifications
				? this.availableCertifications.filter(elem => {
						return elem.value === this.certificationInfo.value;
				})
				: [];
			return availableButton.length < 1;
	}

	get disableField() {
		return this.isEditMode === false;
	}

	get isSFOCScope() {
		return this.scopeToUse === "SFOC_Scope__c" || this.certificationInfo.scopeToUse === "SFOC_Scope__c";
	}

	get isCEIVcope() {
		return this.scopeToUse === "CEIV_Scope_List__c" || this.certificationInfo.scopeToUse === "CEIV_Scope_List__c";
	}

	get isIEnvAcope() {
		return this.scopeToUse === "IENVA_Scope__c" || this.certificationInfo.scopeToUse === "IENVA_Scope__c";
	}

	get disableButtonEditCapab() {
		let isValidationProgramNoneExpired = false;
		if (this.certificationInfo.status === 'Expired'){
			if (this.lstCertificationsAllowed != undefined && this.lstCertificationsAllowed != null) {
				let noneCapability = this.lstCertificationsAllowed.filter(cert => cert.value === this.certificationInfo.value && cert.validationProgram === 'NONE');
				isValidationProgramNoneExpired = (noneCapability.length !== 0);
			}
		} 
		
		if (this.certificationsWithoutCapab != undefined && this.certificationsWithoutCapab != null) {
			let includeCapabilities = this.certificationsWithoutCapab.filter(cert => cert.Id === this.certificationInfo.value);
			if ((includeCapabilities.length !== 0  || this.disableCertiNotAllowed) 
				|| this.certificationInfo.status === 'Active' 
				|| isValidationProgramNoneExpired) {
				return false;
			} else {
				return true;
			}
		}
	}

	get showActivateButton() {
		if (this.certificationInfo.status !== "Expired" && this.certificationInfo.status !== "Active") {
			return true;
		} else {
			return false;
		}
	}

	get disableCertiNotAllowed(){
		if (this.lstCertificationsAllowed != undefined && this.lstCertificationsAllowed != null) {
			let includeCapabilities = this.lstCertificationsAllowed.filter(cert => cert.value === this.certificationInfo.value);
			if (includeCapabilities.length === 0) {
				return true;
			} else {
				return false;
			}
		}
	}

	get getLabelScope() {
		return this._labelScope;
	}

	get getValuesScope() {
		return this._valuesScope;
	}

	get issuingDate() {
		return this._issuingDate;
	}
	set issuingDate(value) {
		this._issuingDate = value;
	}

	get expirationDate() {
		return this._expirationDate;
	}
	set expirationDate(value) {
		this._expirationDate = value;
	}

	get isCanSave() {
		return (this.selectedScope === '' && !this.byPassScope) ? true : false;
	}

	renderedCallback() {
		if (!this.initialized) {
			this.headerModal = this.label.edit_capabilities_certification;
			this.messageModalConfirm = this.label.are_you_sure + "?";
			this.messageModalActivate = this.label.are_your_sure_you_want_replace_current_certification + "?";

			this.listGroupToUpdate = [];
			this.refreshData = false;
			this.initialized = true;
			this.newCertId = this.certificationInfo.certificationId;
			this._labelScope = this.certificationInfo.scopeLabel;
			this._valuesScope = this.certificationInfo.scope;
			this.issuingDate = this.certificationInfo.issuingDate;
			this.expirationDate = this.certificationInfo.expirationDate;

			this.refreshDatePicker();
			this.getNotActiveCertifications("'Upcoming'",this.stationRT,null);
		}
	}

	getNextCertificationID(certiSelected, recordId) {
		getNextCertificationID({ certiSelected, recordId })
			.then(result => {
				if (result) {
					this.handleRenew(result);
				}
			})
			.catch(error => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: this.label.error_reading_certification_id_to_assign,
						message: error,
						variant: "error"
					})
				);
			});
	}

	handleRenewCertification() {
		this.getNextCertificationID(this.certificationInfo.value, this.recordId);
	}

	handleEditCertification(event) {
		let originCerti = event.target.dataset.origin;
		let groupId = event.target.dataset.id;
		this.actionToExecute.result = true;
		if (groupId != null && groupId != undefined) {
			this.groupSelectedToEdit = groupId;
		}
		if (originCerti === "Active-Cert") {
			this.isRenewMode = false;
			this.isEditMode = !this.isEditMode;
		}
		if (originCerti === "Upcoming-Cert") {
			this.actionToExecute.action = "edit-cert-upcoming";
			this.upcomingCerts.forEach(elem => {
				if (elem.id === groupId) {
					elem.disabled = !elem.disabled;
				}
			});
		}
		if (originCerti === "Rest-Cert") {
			this.actionToExecute.action = "edit-cert-rest";
			this.deprecatedCerts.forEach(elem => {
				if (elem.id === groupId) {
					elem.disabled = !elem.disabled;
				}
			});
		}
	}

	handleCancelEditCertification(event) {
		let groupId = event.target.dataset.id;
		let originCerti = event.target.dataset.origin;
		this.removeGroupToList(groupId);
		if (originCerti === "Active-Cert") {
			this._labelScope = this.certificationInfo.scopeLabel;
			this._valuesScope = this.certificationInfo.scope;
			this.issuingDate = this.dateFormatToDatePicker(this.certificationInfo.issuingDate);
			this.expirationDate = this.dateFormatToDatePicker(this.certificationInfo.expirationDate);
			this.refreshDatePicker("Active-Cert", groupId);
			this.jsonGroup = [];
			this.groupSelectedToEdit = null;
			this.isEditMode = false;
		} else if (originCerti === "Upcoming-Cert") {
			let issuing;
			let expiration;

			let selectGroup = this.upcomingCertsClone.filter(group => group.id === groupId);

			this.upcomingCerts.forEach(elem => {
				if (elem.id === groupId) {
					elem.disabled = selectGroup[0].disabled;
					elem.scopeLabel = selectGroup[0].scopeLabel;
					elem.scope = selectGroup[0].scope;
					elem.issuingDate = selectGroup[0].issuingDate;
					elem.expirationDate = selectGroup[0].expirationDate;
					issuing = selectGroup[0].issuingDate;
					expiration = selectGroup[0].expirationDate;
				}
			});
			this.refreshDatePicker(originCerti, groupId, issuing, expiration);
		} else if (originCerti === "Rest-Cert") {
			let issuing;
			let expiration;

			let selectGroup = this.deprecatedCertsClone.filter(group => group.id === groupId);

			this.deprecatedCerts.forEach(elem => {
				if (elem.id === groupId) {
					elem.disabled = selectGroup[0].disabled;
					elem.scopeLabel = selectGroup[0].scopeLabel;
					elem.scope = selectGroup[0].scope;
					elem.issuingDate = selectGroup[0].issuingDate;
					elem.expirationDate = selectGroup[0].expirationDate;
					issuing = selectGroup[0].issuingDate;
					expiration = selectGroup[0].expirationDate;
				}
			});
			this.refreshDatePicker(originCerti, groupId, issuing, expiration);
		}
		this.jsonGroup = [];
		this.groupSelectedToEdit = null;
	}

	refreshDatePicker(originCerti, groupId, issuingDate, expirationDate) {
		if (originCerti === "Active-Cert") {
			let datePickerIssuing = this.template.querySelector(".issuing-class");
			if (datePickerIssuing != undefined && datePickerIssuing) {
				datePickerIssuing.value = this.issuingDate;
			}
			let datePickerExpiration = this.template.querySelector(".expiration-class");
			if (datePickerExpiration != undefined && datePickerExpiration) {
				datePickerExpiration.value = this.expirationDate;
			}
		} else {
			let datePickerIssuing = this.template.querySelector(".issuing-" + groupId);
			if (datePickerIssuing != undefined && datePickerIssuing) {
				datePickerIssuing.value = issuingDate;
			}
			let datePickerExpiration = this.template.querySelector(".expiration-" + groupId);
			if (datePickerExpiration != undefined && datePickerExpiration) {
				datePickerExpiration.value = expirationDate;
			}
		}
	}

	handleSaveEditMode(event) {
		let requiredScope=false;
		let groupId = event.target.dataset.id;
		let scopeToUse = event.target.dataset.scopeused;
		let findGroup = this.listGroupToUpdate.filter(group => group.Id === groupId);

		if (findGroup.length > 0) {
			if(scopeToUse === 'SFOC_Scope__c'){
				if(findGroup[0].SFOC_Scope__c === ""){
					requiredScope = true;
				}
			}
			if(scopeToUse === 'CEIV_Scope_List__c'){
				if(findGroup[0].CEIV_Scope_List__c === ""){
					requiredScope = true;
				}
			}
			if(scopeToUse === 'IENVA_Scope__c'){
				if(findGroup[0].IENVA_Scope__c === ""){
					requiredScope = true;
				}
			}

			if (requiredScope) {
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error",
						message: "Required scope field",
						variant: "error"
					})
				);
			} else {
				let jsonGroup = JSON.stringify(findGroup[0]);
				this.jsonGroup.push(jsonGroup);
				this.updateFieldEdited(this.jsonGroup, false);
			}
		}
	}

	handleActivateGroup(event) {
		this.messageModal = this.messageModalActivate;
		this.showConfirmationModal = true;
		this.groupSelectedToEdit = event.target.dataset.id;
		this.actionToExecute.action = "activate-group";
		this.actionToExecute.result = true;
	}

	handleActivateGroupSelected() {
		this.jsonGroup = [];
		this.fieldToUpdate.Id = this.groupSelectedToEdit;
		this.fieldToUpdate.Is_Active__c = true;
		let jsonGroup = JSON.stringify(this.fieldToUpdate);
		this.jsonGroup.push(jsonGroup);
		this.updateFieldEdited(this.jsonGroup, true);
	}

	handleRenew(nextCertiId) {
		let today = new Date();
		let dd = String(today.getDate()).padStart(2, "0");
		let mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
		let yyyy = today.getFullYear();
		let todayDate = yyyy + "-" + mm + "-" + dd;
		this.formatedIssuedDate = todayDate;
		this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate, this.certificationInfo.expirationPeriod);
		this.showScope = true;
		this.scope = this.certificationInfo.listScope;
		this.newCertId = nextCertiId;
		this.showModal = true;
		this.isRenewMode = true;
		this.isEditMode = false;
		if(this.certificationInfo.byPassScope){
			this.byPassScope = true;
		}
	}
	closeModal() {
		this.isRenewMode = false;
		this.isEditMode = false;
		this.showModal = false;
		this.actionToExecute.action = "";
		this.actionToExecute.result = false;
		this.selectedScope = "";
	}
	closeConfirmationModal() {
		this.showConfirmationModal = false;
	}
	acceptConfirmationModal() {
		this.closeConfirmationModal();

		if (this.actionToExecute.action === "activate-group" && this.actionToExecute.result === true) {
			this.actionToExecute.action = "";
			this.handleActivateGroupSelected();
		} else if (this.actionToExecute.action === "edit-capab-active" || this.actionToExecute.action === "edit-capab-rest") {
			let groupToEdit = this.certificationInfo.id;

			if (this.actionToExecute.action === "edit-capab-rest") {
				groupToEdit = this.groupSelectedToEdit;
				this.actionToExecute.action = "";
			} else {
				this.actionToExecute.action = "";
			}
			this.dispatchEvent(
				new CustomEvent("editonlycapabilitiesbycerti", {
					detail: {
						certificationId: groupToEdit,
						certId: this.certificationInfo.value
					}
				})
			);
		}
	}
	getExpirationDateByCertification(issueDate, expirationPeriod) {
		var parseIssue = new Date(issueDate);
		var year = parseIssue.getFullYear();
		var month = parseIssue.getMonth();
		var day = parseIssue.getDate();
		var newExpiration = year + Number(expirationPeriod) + "-" + (month + 1) + "-" + day;
		return newExpiration;
	}
	handleChangeEditMode(event) {
		let groupId = event.target.dataset.id;
		let name = event.target.dataset.name;
		let origin = event.target.dataset.origin;
		let scopeToUse;

		let value;
		let label;
		this.jsonGroup = [];

		let selectGroup = {};
		let findGroup = this.listGroupToUpdate.filter(group => group.Id === groupId);
		if (findGroup.length === 0) {
			selectGroup.Id = groupId;
		} else {
			selectGroup = findGroup[0];
		}

		if (name === "Scope") {
			scopeToUse = event.target.dataset.scopeused;
			label = event.target.value.join(";");
			value = event.target.value;

			if (scopeToUse === "CEIV_Scope_List__c") {
				selectGroup.CEIV_Scope_List__c = label;
			}
			if (scopeToUse === "SFOC_Scope__c") {
				selectGroup.SFOC_Scope__c = label;
			}
			if (scopeToUse === "IENVA_Scope__c") {
				selectGroup.IENVA_Scope__c = label;
			}

			if (origin === "Active-Cert") {
				this._labelScope = label;
				this._valuesScope = value;
			} else if (origin === "Upcoming-Cert") {
				this.upcomingCerts.forEach(elem => {
					if (elem.id === groupId) {
						elem.scopeLabel = label;
						elem.scope = value;
					}
				});
			} else if (origin === "Rest-Cert") {
				this.deprecatedCerts.forEach(elem => {
					if (elem.id === groupId) {
						elem.scopeLabel = label;
						elem.scope = value;
					}
				});
			}
		} else if (name === "Issue_Date__c") {
			value = event.detail.value;
			selectGroup.Issue_Date__c = value;
		} else if (name === "Expiration_Date__c") {
			value = event.detail.value;
			selectGroup.Expiration_Date__c = value;
		} else if (name === "booked") {
			value = event.target.checked;
			selectGroup.Is_Booked__c = value;
		}

		this.removeGroupToList(groupId);
		this.listGroupToUpdate.push(selectGroup);
	}
	removeGroupToList(groupId) {
		let index = 0;
		let exist = false;
		this.listGroupToUpdate.forEach(function(elem, n) {
			if (elem.Id === groupId) {
				index = n;
				exist = true;
			}
		});
		if (exist) {
			this.listGroupToUpdate.splice(index, 1);
		}
	}
	updateFieldEdited(jsonGroup, activateGorup) {
		updateFieldEdited_({ jsonGroup })
			.then(() => {
				this.isEditMode = false;
				let messageToShow;
				this.jsonGroup = [];
				if (activateGorup) {
					messageToShow = this.label.record_activated;
				} else {
					messageToShow = this.label.record_updated;
				}
				this.dispatchEvent(
					new ShowToastEvent({
						title: this.label.success,
						message: messageToShow,
						variant: "success"
					})
				);
				if (activateGorup) {
					this.showHistory = false;
				}
				this.dispatchEvent(new CustomEvent("certificationactivated", {}));
			})
			.catch(error => {
				this.jsonGroup = [];
				this.dispatchEvent(
					new ShowToastEvent({
						title: this.label.error_updating_record,
						message: error.body.message,
						variant: "error"
					})
				);
			});
	}
	handleIssuedDateChange(event) {
		this.formatedIssuedDate = event.target.value;
		this.formatedExpireDate = this.getExpirationDateByCertification(this.formatedIssuedDate, this.certificationInfo.expirationPeriod);
	}
	handleExpireDateChange(event) {
		this.formatedExpireDate = event.target.value;
	}
	handleCertIdChange(event) {
		this.newCertId = event.target.value;
	}
	handleScopeChange(event) {
		let value = event.detail.value;
		this.selectedScope = value.join(";");
	}
	handleModalAccept() {
		if (this.isEditMode) {
			this.showModal = false;
			this.isEditMode = false;
		} else if (this.isRenewMode) {
			this.renewCertification();
			this.showModal = false;
			this.isRenewMode = false;
		}
	}

	handleEditCapabilities() {
		this.actionToExecute.action = "edit-capab-active";
		this.actionToExecute.result = true;
		this.messageModal = this.messageModalConfirm;
		this.showConfirmationModal = true;
	}
	handleEditCapabilitiesCertificationRest(event) {
		this.actionToExecute.action = "edit-capab-rest";
		this.actionToExecute.result = true;
		let groupId = event.target.dataset.id;
		if (groupId != null && groupId != undefined) {
			this.groupSelectedToEdit = groupId;
		}
		this.messageModal = this.messageModalConfirm;
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
					this.showToast(this.certificationInfo.label, this.label.certification_deleted, "success");
				}
			})
			.catch(error => {
				this.showToast(this.certificationInfo.label, this.label.something_went_wrong, "error");
			});
	}
	renewCertification() {
		let newCertification;
		if (this.certificationInfo.scopeToUse === "CEIV_Scope_List__c") {
			newCertification = {
				ICG_Account_Role_Detail__c: this.recordId,
				ICG_Certification__c: this.certificationInfo.value,
				Certification_Id__c: this.newCertId,
				Issue_Date__c: this.formatedIssuedDate,
				Expiration_Date__c: this.formatedExpireDate,
				CEIV_Scope_List__c: this.selectedScope
			};
		} else if (this.certificationInfo.scopeToUse === "SFOC_Scope__c") {
			newCertification = {
				ICG_Account_Role_Detail__c: this.recordId,
				ICG_Certification__c: this.certificationInfo.value,
				Certification_Id__c: this.newCertId,
				Issue_Date__c: this.formatedIssuedDate,
				Expiration_Date__c: this.formatedExpireDate,
				SFOC_Scope__c: this.selectedScope
			};
		} else if (this.certificationInfo.scopeToUse === "IENVA_Scope__c") {
			newCertification = {
				ICG_Account_Role_Detail__c: this.recordId,
				ICG_Certification__c: this.certificationInfo.value,
				Certification_Id__c: this.newCertId,
				Issue_Date__c: this.formatedIssuedDate,
				Expiration_Date__c: this.formatedExpireDate,
				IENVA_Scope__c: this.selectedScope
			};
		} else {
			newCertification = {
				ICG_Account_Role_Detail__c: this.recordId,
				ICG_Certification__c: this.certificationInfo.value,
				Certification_Id__c: this.newCertId,
				Issue_Date__c: this.formatedIssuedDate,
				Expiration_Date__c: this.formatedExpireDate,
				CEIV_Scope_List__c: this.selectedScope
			};
		}

		let jsonCertification = JSON.stringify(newCertification);

		this.dispatchEvent(
			new CustomEvent("certificationrenewed", {
				detail: { newCertification: jsonCertification, scopeToUse: this.certificationInfo.scopeToUse, groupId: this.certificationInfo.id }
			})
		);
		this.showToast(this.certificationInfo.label, this.label.certification_renewed, "success");
	}
	handleHistory(event) {
		let origin = event.target.dataset.origin;
		this.showHistory = !this.showHistory;
		this.getNotActiveCertifications("'Expired','Inactive'",this.stationRT,origin);
	}

	getNotActiveCertifications(statusInput,stationRT,origin) {
		const facilityId = this.recordId;
		const certificationId = this.certificationInfo.value;
		const groupId = this.certificationInfo.id;
		const validationPrograms = this.validationPrograms;

		getNotActiveCertifications({ facilityId, certificationId, groupId, statusInput,stationRT,validationPrograms }).then(response => {
			if (response) {
				this.deprecatedCerts = [];
				let dataParsed = JSON.parse(response);
				if(dataParsed.length > 0){
				dataParsed.forEach(certification => {
					let scope;
					let scopeLabel = "";
					let scopeInput = [];
					let scopeToUse = "";
					if (certification.ICG_Certification__r.Name.toLowerCase().includes("ceiv_")) {
						let scopeList = [];
						scopeToUse = "CEIV_Scope_List__c";
						if (certification.CEIV_Scope_List__c) {
							scopeList = certification.CEIV_Scope_List__c.split(";");
						}
						scopeList.forEach(elem => {
							if (this.ceivScope != undefined) {
								let scopeValue = this.ceivScope.filter(currentScope => currentScope.label === elem);
								if (scopeValue && scopeValue.length > 0) {
									scopeInput.push(scopeValue[0].value);
									scopeLabel += scopeValue[0].label + ";";
								}
							}
						});
						scope = scopeInput;
						scopeLabel = scopeLabel.substring(0, scopeLabel.length - 1);
					} else if (certification.ICG_Certification__r.Name.toLowerCase() === "smart_facility_operational_capacity") {
						let scopeList = [];
						scopeToUse = "SFOC_Scope__c";
						if (certification.SFOC_Scope__c) {
							scopeList = certification.SFOC_Scope__c.split(";");
						}
						scopeList.forEach(elem => {
							if (this.sfocScope != undefined) {
								let scopeValue = this.sfocScope.filter(currentScope => currentScope.label === elem);
								if (scopeValue && scopeValue.length > 0) {
									scopeInput.push(scopeValue[0].value);
									scopeLabel += scopeValue[0].label + ";";
								}
							}
						});
						scope = scopeInput;
						scopeLabel = scopeLabel.substring(0, scopeLabel.length - 1);
					} else if (certification.ICG_Certification__r.Name.toLowerCase().includes("ienva_stage_") || certification.ICG_Certification__r.Name.toLowerCase() === "united_for_wildlife") {
						let scopeList = [];
						scopeToUse = "IENVA_Scope__c";
						if (certification.IENVA_Scope__c) {
							scopeList = certification.IENVA_Scope__c.split(";");
						}
						scopeList.forEach(elem => {
							if (this.ienvaScope != undefined) {
								let scopeValue = this.ienvaScope.filter(currentScope => currentScope.label === elem);
								if (scopeValue && scopeValue.length > 0) {
									scopeInput.push(scopeValue[0].value);
									scopeLabel += scopeValue[0].label + ";";
								}
							}
						});
						scope = scopeInput;
						scopeLabel = scopeLabel.substring(0, scopeLabel.length - 1);
					} else {
						scopeLabel = null;
					}
					let certInfo = {
						id: certification.Id,
						value: certification.ICG_Certification__c,
						certificationId: certification.Certification_Id__c,
						name: certification.ICG_Certification__r.Name,
						label: certification.ICG_Certification__r.Label__c,
						creationDate: this.dateFormat(certification.ICG_Certification__r.CreatedDate),
						issuingDate: this.dateFormat(certification.Issue_Date__c),
						expirationDate: this.dateFormat(certification.Expiration_Date__c),
						issuingClass: "issuing-" + certification.Id,
						expirationClass: "expiration-" + certification.Id,
						scope: scope,
						status: certification.Status__c,
						isStatusToActivate: certification.Status__c !== "Expired",
						scopeLabel: scopeLabel,
						scopeToUse: scopeToUse,
						disabled: true
					};
					if (statusInput === "'Upcoming'") {
						this.upcomingCerts.push(certInfo);
					} else {
						this.deprecatedCerts.push(certInfo);
					}
					});
					this.deprecatedCertsClone = this.deprecatedCerts.map(a => Object.assign({}, a));
					this.upcomingCertsClone = this.upcomingCerts.map(a => Object.assign({}, a));
				}
				else{
					if(origin === 'Active-Cert'){
						this.showToast('Info:',this.label.icg_gridEmptyMessage, "info");
					}
				}
			}
		});
	}

	dateFormat(date) {
		date = date.split("T");
		date = date[0].split("-");
		//let dateFormated = date[2] + "-" + date[1] + "-" + date[0];
		let dateFormated = date[0] + "-" + date[1] + "-" + date[2];
		return dateFormated;
	}
	dateFormatToDatePicker(date) {
		let inputDate = date.split("/");
		let dateFormated = inputDate[0] + "-" + inputDate[1] + "-" + inputDate[2];
		return dateFormated;
	}
	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}
}
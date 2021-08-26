import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getPermissionToEdit from "@salesforce/apex/CW_Utilities.getPermissionToEdit";
import getPublicLinkToFiles_ from "@salesforce/apex/CW_CapabilitiesManagerController.getPublicLinkToFiles";
import getCapabilitiesForFacilityCertificationId from "@salesforce/apex/CW_CapabilitiesManagerController.getCapabilitiesForFacilityCertificationId";
import setSummaryDetailCheckJSON_ from "@salesforce/apex/CW_FacilityCapabilitiesController.setSummaryDetailCheckJSON";
import createRelationshipsForNewCapabilities_ from "@salesforce/apex/CW_CapabilitiesManagerController.createRelationshipsForNewCapabilities";
import updateCapabilitiesEdited_ from "@salesforce/apex/CW_CapabilitiesManagerController.updateCapabilitiesEdited";
import editAllCapabilitiesFromStation_ from "@salesforce/apex/CW_CapabilitiesManagerController.editAllCapabilitiesFromStation";
import labels from "c/cwOneSourceLabels";
import pubsub from "c/cwPubSub";
import { requiredFieldsMissingResult } from "c/cwUtilities";
import { loadStyle } from "lightning/platformResourceLoader";

export default class CwCapabilitiesManagerContainer extends LightningElement {
	initialized = false;
	loading = true;

	icons = resources + "/icons/";

	checkedGreenIcon = this.icons + "ic-tic-green.svg";
	checkedBlueIcon = this.icons + "ic-tic-blue.svg";
	summaryIcon = this.icons + "ic-summary.svg";
	detailIcon = this.icons + "ic-detail.svg";
	infoIcon = this.icons + "ic-info.svg";
	rotate = this.icons + "rotate-black.gif";
	download = this.icons + "icg-document-download.png";

	chevrondown = this.icons + "chevrondown.svg";
	chevronup = this.icons + "chevronup.svg";

	@api
	register(){
		pubsub.register('capabilitiesupdate', this.capabilitiesUpdateCallback); 
	}

	connectedCallback(){
		this.capabilitiesUpdateCallback = this.capabilitiesUpdate.bind(this);
		this.register();
	}

	capabilitiesUpdateCallback;
	capabilitiesUpdate(payload) {
		this.getCapabilitiesFromCertification(this.recordId, null, null);
	}


	@api recordId = "";
	@api certificationMode = false;
	@api certificationName = "";
	@api groupId = "";
	@api renewMode = false;
	@api validationPrograms = "";

	newCertification = {};
	@api
	get jsonCertification() {
		return this.newCertification;
	}
	set jsonCertification(value) {
		this.newCertification = JSON.parse(value);
	}

	_isCapabCertiMode;
	@api
	get isCapabCertiMode() {
		return this._isCapabCertiMode;
	}
	set isCapabCertiMode(value) {
		this._isCapabCertiMode = value;
	}

	get isRenewMode() {
		return this.renewMode;
	}

	label = labels.labels();

	@api editMode = false;
	@track data = null;
	@track modalEditPhotos = false;
	@track filesRow;
	@track fieldSelected;
	@track photos = null;
	@track photosAvailable = null;
	@track dataHoverInfoStamp = null;
	@track showModal = false;
	@track headerCapabManagement ='';
	@track headerDeletePhoto='';
	@track headerRemoveCertification='';
	@track messageToShow='';
	actionToExecute = {
		action: "",
		result: false
	};
	@track downloadImage = this.download;

	@track showFileUploadCarousel = false;
	@track labelButtonAddRowsToList = "Maintain previous capabilities";
	@track existsRows;
	@track rowSelected = "";
	@track listAddedRows = [];
	@track isMultiValidated = false;
	@track certiAvailablesRow = [];
	listPreviuosRows = [];
	addAllRowsPrevious = false;
	listPositionsRow = [];
	rowIndexSelected;
	equipmentSelected;
	@track equipmentSelectedLabel;
	listDeleteRows = [];
	listDataRow = [];

	//for notification toast
	_title = "";
	_message = "";
	_variant = "";
	variantOptions = [
		{ label: "error", value: "error" },
		{ label: "warning", value: "warning" },
		{ label: "success", value: "success" },
		{ label: "info", value: "info" }
	];

	titleChange(event) {
		this._title = event.target.value;
	}

	messageChange(event) {
		this.message = event.target.value;
	}

	variantChange(event) {
		this.variant = event.target.value;
	}

	showNotification() {
		const evt = new ShowToastEvent({
			title: this._title,
			message: this._message,
			variant: this._variant
		});
		this.dispatchEvent(evt);
	}
	//end notification toast
	
	get isCommunity() {
		return false;
	}

	get dataInformed() {
		return this.data != null ? true : false;
	}

	get getCertificationMode() {
		return this.certificationMode === "true" ? true : false;
	}

	get getCertificationName() {
		return this.certificationName;
	}

	get getStatusEditMode() {
		return this.addAllRowsPrevious === true;
	}

	get isSaveOption() {
		return this.getStatusEditMode;
	}

	get isNotEditable() {
		return this.isSaveOption === false;
	}

	getexistsRows() {
		let containsData = false;
		if (this.dataInformed) {
			if (this.data.superCategories.length > 0) {
				this.data.superCategories.forEach(superC => {
					if (superC.containsData || superC.containsData === true) {
						containsData = true;
					}
				});
			}
		}
		return containsData;
	}

	get getisCapabCertiMode() {
		return this.isCapabCertiMode;
	}

	get isLoading() {
		return this.loading || !this.dataInformed;
	}

	get acceptedFormats() {
		return [".pdf", ".png", ".jpg"];
	}

	setSummaryDetailCheckJSON(icgAccountRoleDetailId, jsonData) {
		setSummaryDetailCheckJSON_({ icgAccountRoleDetailId, jsonData });
	}

	setRowClicked(event) {
		let superCategoriesIndex = event.currentTarget.dataset.superCategoriesIndex;
		let sectionIndex = event.currentTarget.dataset.sectionIndex;
		let capabilityIndex = event.currentTarget.dataset.capabilityIndex;
		let categoryIndex = event.currentTarget.dataset.categoryIndex;
		let rowIndex = event.currentTarget.dataset.rowIndex;

		this.columnsToRowSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].columns;
		this.rowSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex];

		this.rowIndexSelected = rowIndex;
		this.equipmentSelected = this.rowSelected.equipment;
		this.equipmentSelectedLabel = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex].equipment__c;
	}

	photoToDelete;
	deletePhotoCarousel(event) {
		let position = event.target.dataset.position;
		this.photoToDelete = position;
		this.actionToExecute.action = "delete";
		this.actionToExecute.result = true;
		this.openModal(this.headerDeletePhoto);
	}

	setFilesValue(value,field) {
		this.listAddedRows.forEach(element => {
			if (element.position.toString() === this.rowIndexSelected && element.equipment === this.equipmentSelected) {
				let fileFound = false;
				element.fields.forEach(f => {
					if (f.field === field) {
						f.value = value;
						fileFound = true;
					}
				});
				if (!fileFound) {
					let newField = {
						field: field,
						value: value,
						label: field === 'photos__c' ? "Photos" : "Documents",
						required: false
					};
					element.fields.push(newField);
				}
			}
		});
	}

	restPhotosValue() {
		let position = this.photoToDelete;
		if(this.fieldSelected === 'photos'){
			this.rowSelected.photos.splice(Number(position), 1);
			if (this.rowSelected.photos.length > 0) {
				this.setFilesValue(JSON.stringify(this.rowSelected.photos),'photos__c');
			} else {
				this.rowSelected.photosAvailable = false;
				this.setFilesValue("",'photos__c');
			}
		}
		if(this.fieldSelected === 'documents'){
			this.rowSelected.documents.splice(Number(position), 1);
			if (this.rowSelected.documents.length > 0) {
				this.setFilesValue(JSON.stringify(this.rowSelected.documents),'more_info_document__c');
			} else {
				this.rowSelected.documentsAvailable = false;
				this.setFilesValue("",'more_info_document__c');
			}
		}
	}

	handleUploadFinished(event) {
		// Get the list of uploaded photos
		const uploadedFiles = event.detail.files;
		let fileName = this.equipmentSelectedLabel + "-";
		let indexFileName = this.rowSelected.photos.length;

		if (uploadedFiles.length > 0) {
			let listPhoto = [];

			uploadedFiles.forEach(function(file, i) {
				let photo = {
					visible: true,
					url: "",
					label: fileName + indexFileName,
					internalExtension: file.name,
					id: file.documentId
				};
				listPhoto.push(photo);
				indexFileName++;
			});
			this.getPublicLinkToFiles(listPhoto, 'photos__c');
		}
	}

	handleUploadDocumentFinished(event) {
		// Get the list of uploaded documents
		const uploadedFiles = event.detail.files;

		if (uploadedFiles.length > 0) {
			let listDocument = [];

			uploadedFiles.forEach(function(file, i) {
				let document = {
					visible: true,
					url: "",
					label: file.name,
					internalExtension: file.name,
					id: file.documentId
				};
				listDocument.push(document);
			});
			this.getPublicLinkToFiles(listDocument,'more_info_document__c');
		}
	}
	

	getPublicLinkToFiles(listPhoto,field) {
		this.loading = true;
		getPublicLinkToFiles_({ listPhoto })
			.then(res => {
				let result = JSON.parse(res);
				if (result.success) {
					let filesToUpsert = result.message;
					let currentFileList = JSON.parse(JSON.stringify(result.message));
					let currentFileListParse = JSON.parse(currentFileList);

					currentFileListParse.forEach(file => {
						file.downloadDocument = file.url;
					});

					let previousFileList = [];
					if(field === 'photos__c'){
						this.rowSelected.photos.forEach(photo => {
							photo.url = photo.downloadDocument;
						});
						previousFileList = this.rowSelected.photos;
					}
					if(field === 'more_info_document__c'){
						this.rowSelected.documents.forEach(document => {
							document.url = document.downloadDocument;
						});
						previousFileList = this.rowSelected.documents;
					}
					
					if (previousFileList.length > 0) {
						currentFileListParse.forEach(photo => {
							photo.url = photo.downloadDocument;
							previousFileList.push(photo);
						});
						filesToUpsert = JSON.stringify(previousFileList);
					} else {
						previousFileList = currentFileListParse;
					}

					if(field === 'photos__c'){
						this.rowSelected.photos = previousFileList;
						this.rowSelected.photosAvailable = true;
					}
					if(field === 'more_info_document__c'){
						this.rowSelected.documents = previousFileList;
						this.rowSelected.documentsAvailable = true;
					}
					
					this.setFilesValue(filesToUpsert,field);
				} else {
					this._title = "Error";
					this._message = result.message;
					this._variant = "error";

					this.showNotification();
				}
			})
			.finally(() => {
				this.loading = false;
			});
	}

	handleChangeChecks(event) {
		let updatedCapabilitie = event.currentTarget.dataset.key;
		let summaryChecked = true;
		let detailChecked = true;
		let htmlAlert = "will not be displayed on public profile";
		let item1 = {};
		let item2 = {};
		this.data.superCategories.forEach(sectionAux => {
			sectionAux.sections.forEach(capabilitieAuxSe => {
				capabilitieAuxSe.capabilities.forEach(capabilitieAux => {
					var item0 = {};
					if (event.currentTarget.name === "Summary") {
						if (capabilitieAux.name === updatedCapabilitie) {
							capabilitieAux.first_load_check = false;
							item0.summary = event.detail.checked;
							if (!item0.summary) {
								item0.detail = false;
								capabilitieAux.check_detail = false;
							} else item0.detail = capabilitieAux.check_detail;
							capabilitieAux.check_summary = event.detail.checked;
						} else {
							item0.summary = capabilitieAux.check_summary;
							item0.detail = capabilitieAux.check_detail;
						}
					} else {
						if (capabilitieAux.name === updatedCapabilitie) {
							capabilitieAux.first_load_check = false;
							item0.detail = event.detail.checked;
							if (item0.detail) {
								item0.summary = true;
								capabilitieAux.check_summary = true;
							} else item0.summary = capabilitieAux.check_summary;
							capabilitieAux.check_detail = event.detail.checked;
						} else {
							item0.detail = capabilitieAux.check_detail;
							item0.summary = capabilitieAux.check_summary;
						}
					}
					if (capabilitieAux.name === updatedCapabilitie) {
						if (!capabilitieAux.check_detail) {
							detailChecked = false;
						}
						if (!capabilitieAux.check_summary) {
							summaryChecked = false;
						}
					}
					item1[capabilitieAux.name] = item0;
				});
			});
		});
		item2.capabilitiesMap = item1;
		this.setSummaryDetailCheckJSON(this.recordId, JSON.stringify(item2));
	}

	calculateSpacesSticky() {
		let editingBtn = this.template.querySelectorAll(".width-150");
		let certheaders = this.template.querySelectorAll(".cert-colum-head");
		if (certheaders && certheaders.length > 0) {
			certheaders.forEach(certheader => {
				if (editingBtn.length > 0) {
					certheader.style.right = "150px";
					certheader.classList.add('border-right-table');
				} else {
					certheader.style.right = "0px";
					certheader.classList.remove('border-right-table');
				}
			});
		}

		let photoheaders = this.template.querySelectorAll(".photo-colum-head");
		if (photoheaders && photoheaders.length > 0) {
			photoheaders.forEach(photoheader => {
				let certheader = photoheader.nextElementSibling;
				let widthcertheader = certheader != null ? certheader.clientWidth : [];
				if (editingBtn.length > 0) {
					photoheader.style.right = widthcertheader + 150 + "px";
				} else {
					photoheader.style.right = widthcertheader + "px";
				}
			});
		}
		let photocells = this.template.querySelectorAll(".photo-colum");
		if (photocells && photocells.length > 0) {
			photocells.forEach(photocell => {
				let certcell = photocell.nextElementSibling;
				let widthcertcell = certcell != null ? certcell.clientWidth : [];
				if (editingBtn.length > 0) {
					photocell.style.right = widthcertcell + 150 + "px";
				} else {
					photocell.style.right = widthcertcell + "px";
				}
			});
		}
		let certcells = this.template.querySelectorAll(".cert-colum");
		if (certcells && certcells.length > 0) {
			certcells.forEach(certcell => {
				if (editingBtn.length > 0) {
					certcell.style.right = "150px";
				} else {
					certcell.style.right = "0px";
				}
			});
		}
	}

	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;

			this.headerCapabManagement = this.label.icg_header_capab_management;
			this.headerDeletePhoto = this.label.icg_header_delete_photo;
			this.headerRemoveCertification = this.label.icg_header_remove_certi;
			this.messageToShow = this.label.icg_capab_message_to_show;

			getPermissionToEdit({}).then(result => {
				let edit = false;
				if (result) {
					edit = result;
				}
				this.editMode = edit;
				this.checkCapabilities();
			});
		}
		this.calculateSpacesSticky();
	}

	checkCapabilities() {
		if (this.editMode === true) {
			this.labelButtonAddRowsToList = this.isRenewMode ? this.label.icg_reset_capabilities_button : this.getisCapabCertiMode || !this.getCertificationMode ? this.label.icg_capab_magmnt_edit_capab : this.label.icg_capab_magmnt_mantain_prev;
			if (this.getCertificationMode) {
				this.getCapabilitiesFromCertification(this.recordId, this.newCertification.ICG_Certification__c, this.groupId);
			} else {
				this.getCapabilitiesFromCertification(this.recordId, null, null);
			}

			Promise.all([loadStyle(this, resources + "/css/internal.css")]);
		} else {
			this.messageToShow = "You cannot manage capabilities";
			this.data = [];
			this.loading = false;
		}
	}

	getCapabilitiesFromCertification(id, certiId, groupId,validationPrograms) {
		getCapabilitiesForFacilityCertificationId({ id, certiId, groupId,validationPrograms })
			.then(result => {
				this.data = result;
				this.existsRows = this.getexistsRows();
				this.getURLDownload();
				if (this.isRenewMode) {
					this.addPreviuosCapabilities();
				}
				// Creates the event with the data and dispatches.
				const newEvent = new CustomEvent("dataloaded", {
					detail: {
						data: this.data
					}
				});
				this.dispatchEvent(newEvent);
			})
			.catch(err => console.error(err))
			.finally(() => {
				this.loading = false;
			});
	}

	getURLDownload(){
		this.data.superCategories.forEach(function(superCategory, i) {
			superCategory.sections.forEach(function(section, j) {
				section.capabilities.forEach(function(capability, k) {
					capability.categories.forEach(function(category, l) {
						category.rows.forEach(function(row, m) {
							row.photos.forEach(function(pht, n) {
								pht.downloadDocument = pht.url;
							});
							row.documents.forEach(function(doc, n) {
								doc.downloadDocument = doc.url;
							});
						});
					});
				});
			});
		});
	}

	openModalEditPhotos(event) {
		let superCategoriesIndex = event.target.dataset.superCategoriesIndex;
		let sectionIndex = event.target.dataset.sectionIndex;
		let capabilityIndex = event.target.dataset.capabilityIndex;
		let categoryIndex = event.target.dataset.categoryIndex;
		let rowIndex = event.target.dataset.rowIndex;
		let currentEquipmentPhoto = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex].equipment__c;
		let filesRow = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex];

		this.fieldSelected = event.target.dataset.field;
		let indexFileName = 1;
		let listFiles = [];
		if(this.fieldSelected === 'photos'){
			listFiles = filesRow.photos;
		}
		if(this.fieldSelected === 'documents'){
			listFiles = filesRow.documents;
		}
		listFiles.forEach(element => {
			if(element.extension.toLowerCase().includes("pdf")){
				element.url = this.download;
			}
			else{
				element.label = currentEquipmentPhoto + "-" + indexFileName;
			}
			indexFileName++;
		});
		this.filesRow = listFiles;
		this.modalEditPhotos = true;
	}

	evaluatePhotoAction(event){
		let urlImage = event.target.dataset.url;
		let extension = event.target.dataset.extension;
		if(extension === "pdf"){
			window.open(urlImage,'_blank');
		}
	}

	showHideStampHover(event) {
		let stampPopover = this.template.querySelector(`section[data-name="stamp-popover"]`);

		if (event.type === "mouseover" || event.type === "mousemove") {
			this.dataHoverInfoStamp = {
				name: event.target.dataset.name,
				issueDate: event.target.dataset.issueDate,
				expirationDate: event.target.dataset.expirationDate
			};

			stampPopover.classList.remove("slds-hidden");
			let bounds = event.target.getBoundingClientRect();
			let popupBounds = stampPopover.getBoundingClientRect();
			stampPopover.style.left = bounds.left - popupBounds.width + 40 + "px";
			stampPopover.style.top = bounds.top + 40 + "px";
		} else {
			this.dataHoverInfoStamp = null;
			stampPopover.classList.add("slds-hidden");
		}
	}

	addFieldToList(event) {
		let detail = JSON.parse(JSON.stringify(event.detail));
		let data = detail.data;

		let auxFields = {
			field: "",
			value: ""
		};
		let containField = false;
		//update list to update
		this.listAddedRows.forEach(function(element) {
			if (element.equipment === data.equipment && element.position.toString() === data.rowIndex) {
				element.fields.forEach(field => {
					if (field.field === data.field) {
						field.value = data.value;
						containField = true;
					}
				});
				if (containField === false) {
					auxFields.field = data.field;
					auxFields.value = data.value;

					element.fields.push(auxFields);
				}
			}
		});
		
		//update child control
        if (this.columnsToRowSelected){
            let columns = this.columnsToRowSelected;
            let fieldsByColumns = columns[columns.length - 1];
            fieldsByColumns.forEach(element => {
                if(element.name != 'equipment__c' && !element.isformula){
                    this.rowSelected[data.field] = data.value;
                }
            });
        }

	}

	addPreviuosCapabilities() {
		this.addAllRowsPrevious = !this.addAllRowsPrevious;
		this.loading = true;
		if (this.addAllRowsPrevious === true) {
			let listPositionsRow = [];
			let groupId = this.groupId;
			let isTabEditCapabilities = this.getCertificationMode;
			this.data.superCategories.forEach(function(superCategory, i) {
				superCategory.sections.forEach(function(section, j) {
					section.capabilities.forEach(function(capability, k) {
						capability.categories.forEach(function(category, l) {
							category.rows.forEach(function(row, m) {
								if(row.isEditableRecordType && row.isAssigned && row.isPermissionByDepartment && !isTabEditCapabilities){
									let positionRow = {
										superCategoriesIndex: i,
										sectionIndex: j,
										capabilityIndex: k,
										categoryIndex: l,
										rowIndex: m
									};
									let toFind = listPositionsRow.filter(row => row.superCategoriesIndex === positionRow.superCategoriesIndex && row.sectionIndex === positionRow.sectionIndex && row.capabilityIndex === positionRow.capabilityIndex && row.categoryIndex === positionRow.categoryIndex && row.rowIndex === positionRow.rowIndex);
									if (toFind.length === 0) {
										listPositionsRow.push(positionRow);
									}
								}
								else{
									row.certifications.forEach(function(cert, n) {
										if ((row.isAssigned && row.isPeviouslyCertified === true && row.isPermissionByDepartment === true && cert.id === groupId) || (row.isAssigned && row.isPeviouslyCertified && row.isPermissionByDepartment && !isTabEditCapabilities)) {											
											let positionRow = {
												superCategoriesIndex: i,
												sectionIndex: j,
												capabilityIndex: k,
												categoryIndex: l,
												rowIndex: m
											};

											let toFind = listPositionsRow.filter(row => row.superCategoriesIndex === positionRow.superCategoriesIndex && row.sectionIndex === positionRow.sectionIndex && row.capabilityIndex === positionRow.capabilityIndex && row.categoryIndex === positionRow.categoryIndex && row.rowIndex === positionRow.rowIndex);
											if (toFind.length === 0) {
												listPositionsRow.push(positionRow);
											}
										}
									});

									let toFindCert = row.certifications.filter(cert => cert.id === groupId);
									if (toFindCert.length === 0) {
										row.isAssigned = false;
									}
								}
							});
						});
					});
				});
			});
			this.listPositionsRow = listPositionsRow;
			this.operationCapabilities("assign");
		} else {
			this.operationCapabilities("deallocate");
		}

		this.calculateSpacesSticky();
	}

	resetAllCapabilities() {
		if (this.isRenewMode) {
			this.listPositionsRow.forEach(elem => {
				let row = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].rows[elem.rowIndex];
				row.isAssigned = false;
				row.isNotEditable = true;
				row.customClass = "";

				let columns = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].columns;
				let fieldsByColumns = columns[columns.length - 1];

				fieldsByColumns.forEach(element => {
					if (element.type === "BOOLEAN") {
						row[element.name] = false;
					} else {
						if (element.name !== "equipment__c" && element.name !== "equipment") {
							row[element.name] = null;
						}
					}
				});

				let index = 0;
				this.listAddedRows.forEach(element => {
					if (element.equipment === row.equipment) {
						this.listAddedRows.splice(index, 1);
					}
					index++;
				});
			});
		}
	}

	operationCapabilities(action) {
		if (action === "assign") {
			this.listPositionsRow.forEach(elem => {
				let listDataRow = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].rows;

				let row = listDataRow[elem.rowIndex];
				row.isNotEditable = false;
				row.isAssigned = true;
				row.customClass = "row-assigned";

				let newCapabilityRow = {
					id: row.id,
					position: elem.rowIndex.toString(),
					rtypeId: this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].rtypeId,
					category: this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].value,
					equipment: row.equipment,
					equipment_label: row.equipment__c,
					fields: []
				};

				let columns = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].columns;
				let fieldsByColumns = columns[columns.length - 1];

				fieldsByColumns.forEach(element => {
					let newField = {
						field: element.name,
						value: this.transformValue(row, element),
						label: element.label,
						required: row.requiredFields.includes(element.name)
					};
					newCapabilityRow.fields.push(newField);
				});

				//For photo__c field
				if(row.photos.length>0){
					let newField = {
						field: 'photos__c',
						value: JSON.stringify(row.photos),
						label: "Photos",
						required: false
					}
					newCapabilityRow.fields.push(newField);
				}

				this.listAddedRows.push(newCapabilityRow);
			});
			this.listPreviuosRows = this.listAddedRows.map(x => x);
		}

		if (action === "deallocate") {
			this.listPositionsRow.forEach(elem => {
				let row = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].rows[elem.rowIndex];

				//row.isAssigned = false;
				row.isNotEditable = true;
				row.customClass = "";

				let index = 0;
				this.listAddedRows.forEach(element => {
					if (element.equipment === row.equipment) {
						this.listAddedRows.splice(index, 1);
					}
					index++;
				});
			});
		}
		this.loading = false;
	}

	transformValue(rowData, element) {
		let newValue = "";
		if (rowData[element.name] && element.type === "MULTIPICKLIST") {
			newValue = rowData[element.name].join(";");
		}
		else if (rowData[element.name] && element.type === "DOUBLE") {
			newValue = Number(rowData[element.name]);
		}
		else if (rowData[element.name] && rowData[element.name] != null) {
			newValue = rowData[element.name];
		}
		return newValue;
	}

	assigntCapability(event) {
		let action = event.target.dataset.action;
		let superCategoriesIndex = event.target.dataset.superCategoriesIndex;
		let sectionIndex = event.target.dataset.sectionIndex;
		let capabilityIndex = event.target.dataset.capabilityIndex;
		let categoryIndex = event.target.dataset.categoryIndex;

		this.listDataRow = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows;

		if (action === "Add") {
			let existsAddRow = false;
			this.listDataRow.forEach(element => {
				if (element.isAditional === true && element.isAssigned === false) {
					existsAddRow = true;
				}
			});
			let rowTeplateSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].templateFields;

			if (existsAddRow === false) {
				var newRecord = Object.assign({}, rowTeplateSelected);
				newRecord.certifications = [];
				newRecord.isAssigned = false;
				newRecord.isNotEditable = true;
				newRecord.isAditional = true;
				newRecord.isTemplateMultirecord = false;

				this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows.push(newRecord);
			}
		} else {
			let rowIndex = event.target.dataset.rowIndex;
			this.columnsToRowSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].columns;
			this.rowSelected = this.listDataRow[rowIndex];

			let newCapabilityRow = {
				position: rowIndex.toString(),
				id: this.rowSelected.id,
				rtypeId: this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].rtypeId,
				category: this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].value,
				equipment: this.rowSelected.equipment,
				equipment_label: this.rowSelected.equipment__c,
				fields: []
			};

			if (action === "Certify") {
				this.rowSelected.isAssigned = true;
				this.rowSelected.isNotEditable = false;
				this.rowSelected.customClass = "row-assigned";

				let columns = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].columns;
				let fieldsByColumns = columns[columns.length - 1];

				fieldsByColumns.forEach(element => {
					let newField = {
						field: element.name,
						value: this.transformValue(this.rowSelected, element),
						label: element.label,
						required: this.rowSelected.requiredFields.includes(element.name)
					};
					newCapabilityRow.fields.push(newField);
				});

				this.listAddedRows.push(newCapabilityRow);

				if (this.isRenewMode) {
					let positionRow = {
						superCategoriesIndex: superCategoriesIndex,
						sectionIndex: sectionIndex,
						capabilityIndex: capabilityIndex,
						categoryIndex: categoryIndex,
						rowIndex: rowIndex
					};

					let toFind = this.listPositionsRow.filter(row => row.superCategoriesIndex === superCategoriesIndex && row.sectionIndex === sectionIndex && row.capabilityIndex === capabilityIndex && row.categoryIndex === categoryIndex && row.rowIndex === rowIndex);
					if (toFind.length === 0) {
						this.listPositionsRow.push(positionRow);
					}
				}

				if(!this.getCertificationMode){
					let capabilityId = this.rowSelected.id;
					let toFind = this.listDeleteRows.filter(row => row.Account_Role_Detail_Capability__c === capabilityId);
					if (toFind.length > 0) {
						let index;
						this.listDeleteRows.forEach(function(row,n){
							if(row.Account_Role_Detail_Capability__c === capabilityId){
								index = n;
							}
						});
						this.listDeleteRows.splice(index,1);
					}

					this.rowSelected.certifications.forEach(elem => {
						elem.isDeleted = false;
					});

				}
			}

			if (action === "Remove") {
				this.removeRowToListAddedRows(this.rowSelected, rowIndex.toString());
			}
		}

	}

	removeCapabilities(event) {
		let superCategoriesIndex = event.target.dataset.superCategoriesIndex;
		let sectionIndex = event.target.dataset.sectionIndex;
		let capabilityIndex = event.target.dataset.capabilityIndex;
		let categoryIndex = event.target.dataset.categoryIndex;
		let rowIndex = event.target.dataset.rowIndex;

		this.columnsToRowSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].columns;
		this.rowSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex];
		this.rowIndexSelected = rowIndex;
		let certificationsAvailables = this.rowSelected.certifications;

		if(this.rowSelected.isEditableRecordType){
			this.addRowToRemoveList();
		}
		else{
			if (certificationsAvailables.length > 1) {
				this.isMultiValidated = true;
	
				this.certiAvailablesRow = certificationsAvailables;
				this.openModal(this.headerRemoveCertification);
			} else {
				this.addRowToRemoveList(this.rowSelected.certifications[0].id);
			}
		}		
		this.removeRowToListAddedRows(this.rowSelected, this.rowIndexSelected.toString());

	}

	certiSelectedToRemove(event) {
		this.closeModal();

		let certName = event.target.dataset.name;

		let toFind = this.certiAvailablesRow.filter(row => row.name === certName);
		if (toFind.length > 0) {
			toFind[0].isDeleted = true;
		}

		let isAllDeleted = true;
		this.certiAvailablesRow.forEach(elem => {
			if (!elem.isDeleted) {
				isAllDeleted = false;
			}
		});

		this.addRowToRemoveList(toFind[0].id);

		if (isAllDeleted) {
			this.removeRowToListAddedRows(this.rowSelected, this.rowIndexSelected.toString());
		}
	}

	addRowToRemoveList(groupId){
		if(!this.getCertificationMode){
			let rowToDelete = {
				ICG_Capability_Assignment_Group__c: groupId,
				Account_Role_Detail_Capability__c: this.rowSelected.id
			};

			let toFind = this.listDeleteRows.filter(row => row.ICG_Capability_Assignment_Group__c === groupId && row.Account_Role_Detail_Capability__c === this.rowSelected.id);
			if (toFind.length === 0) {
				this.listDeleteRows.push(rowToDelete);
			}
		}

	}

	removeRowToListAddedRows(rowSelected, rowIndex) {
		this.rowSelected.isAssigned = false;
		this.rowSelected.isNotEditable = true;
		this.rowSelected.customClass = "";

		let columns = this.columnsToRowSelected;
		let fieldsByColumns = columns[columns.length - 1];

		fieldsByColumns.forEach(element => {
			if(element.name != 'equipment__c' && !element.isformula){
				if (typeof this.rowSelected[element.name] !== 'boolean'){
					this.rowSelected[element.name] = '';
				}
				else{
					this.rowSelected[element.name] = false;
				}
			}
		});

		if (this.rowSelected.isAditional === true) {
			this.listDataRow.splice(rowIndex, 1);
		}
		let index = 0;
		this.listAddedRows.forEach(element => {
			if (element.equipment === rowSelected.equipment && element.position === rowIndex){
				this.listAddedRows.splice(index, 1);
			}
			index++;
		});
		
	}

	saveCapabilities() {
		this.actionToExecute.action = "save";
		this.actionToExecute.result = true;

		let listFieldByEquipments = requiredFieldsMissingResult(this.listAddedRows);
		let result = listFieldByEquipments.length > 0 ? false : true;
		if (result === "false" || result === false) {
			if (listFieldByEquipments.length > 0) {
				listFieldByEquipments.forEach(elem => {
					let message = 'The Equipment: "' + elem.equipment + '" required the Fields: ';
					message += elem.fields.join(', ');
					this._title = "Error";
					this._message = message;
					this._variant = "error";
					this.showNotification();
				});
			}
		} else {
			this.openModal(this.headerCapabManagement);
		}
	}

	cancelCapabilities() {
		this.actionToExecute.action = "cancel";
		this.actionToExecute.result = true;
		this.openModal(this.headerCapabManagement);
	}

	closeCapabilitiesTab() {
		let p1 = new Promise(function(resolve, reject) {
			resolve(pubsub.fire("certificationupdate"));
		});
		let p2 = new Promise(function(resolve, reject) {
			resolve(pubsub.fire("capabilitiesupdate"));
		});
		this.dispatchEvent(new CustomEvent("closecapabilitiestab", {}));
	}

	closeModalEditPhotos() {
		this.capabilityPhotoId = null;
		this.modalEditPhotos = false;
	}

	openModal(headerToShow) {
		this.headerToShow = headerToShow;
		this.showModal = true;
	}
	closeModal() {
		this.showModal = false;
		this.isMultiValidated = false;
	}

	createRelationshipsForNewCapabilities(accRoleDet, certiId, listAddedRows, jsonCertification) {
		createRelationshipsForNewCapabilities_({ accRoleDet, certiId, listAddedRows, jsonCertification })
			.then(res => {
				let result = JSON.parse(res);
				if (result.success) {
					this._title = "Success";
					this._message = "Successful operation";
					this._variant = "success";

					this.closeCapabilitiesTab();
				} else {
					this._title = "Error";
					this._message = result.message;
					this._variant = "error";
				}
				this.showNotification();
			})
			.finally(() => {
				this.loading = false;
			});
	}

	updateCapabilitiesEdited(accRoleDet, groupId, listAddedRows) {
		updateCapabilitiesEdited_({ accRoleDet, groupId, listAddedRows })
			.then(res => {
				let result = JSON.parse(res);
				if (result.success) {
					this._title = "Success";
					this._message = "Successful operation";
					this._variant = "success";

					this.closeCapabilitiesTab();
				} else {
					this._title = "Error";
					this._message = result.message;
					this._variant = "error";
				}
				this.showNotification();
			})
			.finally(() => {
				this.loading = false;
			});
	}

	editAllCapabilitiesFromStation(accRoleDet,listAddedRows,listDeleteRows)
	{
		editAllCapabilitiesFromStation_({accRoleDet,listAddedRows,listDeleteRows})
		.then(res => {
			let result = JSON.parse(res);
			if(result.success)
			{
				this._title = 'Success';
				this._message = "Successful operation";
				this._variant = 'success';

				this.rollbackCapabilitiesComponent();
			}
			else
			{
				this._title = 'Error';
				this._message = result.message;
				this._variant = 'error';
			}
			this.showNotification();
		})
		.finally(() => {
			this.loading = false;
		});
	}

	makeAction() {
		this.closeModal();
		if (this.actionToExecute.action === "save" && this.actionToExecute.result) {
			this.loading = true;
			//Option Edit Capabilities in Capabilities Tab
			if (!this.getCertificationMode) {
				// this.updateCapabilitiesEdited(this.recordId, null, this.listAddedRows);
				this.editAllCapabilitiesFromStation(this.recordId,this.listAddedRows,this.listDeleteRows);
			} else {
				//Option Edit Capabilities
				if (this.getisCapabCertiMode) {
					this.updateCapabilitiesEdited(this.recordId, this.groupId, this.listAddedRows);
				} else {
					//Option Create o Renew
					this.createRelationshipsForNewCapabilities(this.recordId, this.newCertification.ICG_Certification__c, this.listAddedRows, JSON.stringify(this.jsonCertification));
				}
			}
		}
		if (this.actionToExecute.action === "delete" && this.actionToExecute.result) {
			this.modalEditPhotos = false;
			this.restPhotosValue();
		}
		if (this.actionToExecute.action === "cancel" && this.actionToExecute.result) {
			
			if(this.getCertificationMode){
				this.closeCapabilitiesTab();
			}
			else{
				this.rollbackCapabilitiesComponent();
			}
		}
		if (this.actionToExecute.action === "remove" && this.actionToExecute.result) {
			this.addRowToRemove();
		}
	}

	rollbackCapabilitiesComponent(){
		this.resetCapabilitiesMultiValidated();
		this.refreshCapabilitiesTab();
	}

	resetCapabilitiesMultiValidated(){
		this.certiAvailablesRow.forEach(elem => {
			elem.isDeleted = false;
		});
	}

	refreshCapabilitiesTab(){
		this.getCapabilitiesFromCertification(this.recordId,null,null);

		if (this.getStatusEditMode) {
			this.listAddedRows = [];
			this.listDeleteRows = [];
			this.addPreviuosCapabilities();
		}
	}
}
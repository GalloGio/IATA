import { LightningElement, api, track } from "lwc";

import resources from "@salesforce/resourceUrl/ICG_Resources";

import getCapabilitiesFromAccountRoleDetailId_ from "@salesforce/apex/CW_FacilityCapabilitiesController.getCapabilitiesFromAccountRoleDetailId";
import setSummaryDetailCheckJSON_ from "@salesforce/apex/CW_FacilityCapabilitiesController.setSummaryDetailCheckJSON";
import setVisibilityPhotos_ from "@salesforce/apex/CW_FacilityCapabilitiesController.setVisibilityPhotos";
import getPublicLinkToFiles_ from "@salesforce/apex/CW_CapabilitiesManagerController.getPublicLinkToFiles";
import createRelationshipsForNewCapabilities_ from "@salesforce/apex/CW_FacilityCapabilitiesController.createRelationshipsForNewCapabilities";
import { createKey } from "c/cwUtilities";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CwFacilityCapabilities extends LightningElement {
	initialized = false;
	isLoading = false;

	@api label;

	@track tooltipObject;
	@track tooltipToDisplay = "";
	icons = resources + "/icons/";

	checkedGreenIcon = this.icons + "ic-tic-green.svg";
	checkedBlueIcon = this.icons + "ic-tic-blue.svg";
	summaryIcon = this.icons + "ic-summary.svg";
	detailIcon = this.icons + "ic-detail.svg";
	infoIcon = this.icons + "ic-info.svg";
	rotate = this.icons + "rotate-black.gif";
	warning = this.icons + "warning.svg";
	plus = this.icons  + "icon-plus.svg";

	chevrondown = this.icons + "chevrondown.svg";
	chevronup = this.icons + "chevronup.svg";

	remoteValidationIcon = this.icons + "ic-remote-validation-icon.svg";

	_recordId = "";
	_actionSave= false;
	_actionCancel = false;
	@api facility = null;
	@api userRole;
	@api areatype;

	isChangeFacility;

	@track data = null;
	@api editMode = false;
	@track modalEditPhotos = false;
	@track photos = null;
	@track photosAvailable = null;
	@track dataHoverInfoStamp = null;
	@track firstSeccionToogled = false;

	@track rowSelected="";
	@track listAddedRows = [];
	rowIndexPhotoSelected;
	equipmentPhotoSelected;
	disableOptions=true;
	isEditableRecordType=false;

	@api
	get recordId(){
		return this._recordId;
	}
	set recordId(value){
	if(this._recordId != value){
		this._recordId = value;
		this.getCapabilitiesFromAccountRoleDetailId(value);
		}
	}

	@api
	get actionSave(){
		return this._actionSave;
	}
	set actionSave(data){
		let saveListRow = JSON.parse(JSON.stringify(data));
		this._actionSave = saveListRow.isSave;
		if(this._actionSave === true){
			this.handleSaveChanges(saveListRow.listRow);
		}	
		
	}
	
	@api
	get actionCancel(){
		return this._actionCancel;
	}
	set actionCancel(value){
		this._actionCancel = value;
		if(this._actionCancel === true){
			this.disableOptions=true;
		}	
		
	}

	get cargoHandlingCss() {
		return "cursor-pt";
	}

	get cargoHandlingCapabilitiesCss() {
		return "ml-1 alert text-truncate";
	}

	get isRecordTypeEditable(){
		return this.isEditableRecordType;
	}

	get collapsedOrnot(){
		if(this.isRecordTypeEditable && this.isPrivateArea && this.isStationManager){
			return "col-12 no-collapsed mb-4";
		}
		else{
			return "col-12 collapsed mb-4";
		}
	}

	get acceptedDocumentsFormats() {
        return ['.pdf'];
	}

	get acceptedPhotoFormats() {
        return ['.png', '.ico', '.jpg'];
	}
	
	get showSpinner(){
		return this.isLoading;
	}

	get disableOptions(){
		return this.disableOptions;
	}

	get saveBtnCss() {
		if (this.disableOptions === false) {
			return "btn btn-primary-blue save-btn mr-2";
		}

		return "btn btn-primary-blue save-btn mr-2 disabled-filter";
	}

	get isStationManager(){
		return this.userRole === "Facility Manager" || this.userRole === "Company Admin";
	}

	get isPrivateArea(){
		return this.areatype === "private";
	}
	
	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

	setRowClicked(event){
		
		let superCategoriesIndex = event.currentTarget.dataset.superCategoriesIndex;
		let sectionIndex = event.currentTarget.dataset.sectionIndex;
		let capabilityIndex = event.currentTarget.dataset.capabilityIndex;
		let categoryIndex = event.currentTarget.dataset.categoryIndex;
		let rowIndex = event.currentTarget.dataset.rowIndex;

		this.rowSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex];

		this.rowIndexPhotoSelected = rowIndex;
		this.equipmentPhotoSelected = this.rowSelected.equipment_value;
	}

	handleUploadDocumentFinished(event) {
		this.isLoading=true;
        // Get the list of uploaded files
		const uploadedFiles = event.detail.files;

		if(uploadedFiles.length > 0){
			let listDocument = [];

			uploadedFiles.forEach(file => {				
				let document = {
					visible: true,
					url: file.documentId,
					label: file.name
				}
				listDocument.push(document);
			
			});

			this.getPublicLinkToFiles(listDocument, 'more_info_document__c');
		}
		
	}

	handleUploadPhotoFinished(event) {
		this.isLoading=true;
        // Get the list of uploaded files
		const uploadedFiles = event.detail.files;

		if(uploadedFiles.length > 0){
			let listPhoto = [];

			uploadedFiles.forEach(file => {				
				let photo = {
					visible: true,
					url: file.documentId,
					label: file.name
				}
				listPhoto.push(photo);
			
			});

			this.getPublicLinkToFiles(listPhoto, 'photos__c');
		}
		
	}

	getPublicLinkToFiles(listPhoto, fieldToInsert){
		
		getPublicLinkToFiles_({listPhoto})
			.then(res => {				
					let result = JSON.parse(res);
					if(result.success)
					{
						let auxField = {
							field: fieldToInsert,
							value: result.message,
							required: false
						}

						this.listAddedRows.forEach(element => {
							if(element.position === this.rowIndexPhotoSelected && element.equipment === this.equipmentPhotoSelected){
								element.fields.push(auxField);
							}
						});
		
						this.rowSelected.photos = result.message;
					}	
					else{
						this.showToast("Error", result.message, "error");
					}					

			})
			.finally(() => {
				this.isLoading = false;
			});
		
	}

	getCapabilitiesFromAccountRoleDetailId(id) {
		this.isLoading = true;
		getCapabilitiesFromAccountRoleDetailId_({ id })
			.then(result => {
				this.data = result;
				this.isEditableRecordType = this.data && this.data.superCategories && this.data.superCategories[0] && this.data.superCategories[0].sections[0].capabilities[0].isEditableRecordType;
				this.data.superCategories.forEach(superCategory => {
					superCategory.key = createKey(superCategory.label);
					superCategory.sections.forEach(section => {
						section.key = createKey(section.label);
						if(this.isStationManager === false){
							section.capabilities.forEach(capability=>{
								capability.categories.forEach(category=>{
									let existNotAssigned=false;
									while(existNotAssigned === false){
										category.rows.forEach(row=>{
											if(row.isAssigned === false && row.isEditableRecordType === true){
												category.rows.splice(category.rows.indexOf(row),1);
												existNotAssigned=true;
											}
																											
										});
										if(existNotAssigned === true){
											existNotAssigned=false;
										}	
										else{
											existNotAssigned=true;
										}								
									}
									
								});
							});
						}
										
					});
				});
				//Selected Detail by default
				if(this.isStationManager){
					this.executeToggleContent(this.data.superCategories[0].sections[0].capabilities[0].name,'detail');
				}
				// Creates the event with the data and dispatches.
				const newEvent = new CustomEvent("dataloaded", {
					detail: {
						data: this.data
					}
				});
				this.dispatchEvent(newEvent);
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	setSummaryDetailCheckJSON(icgAccountRoleDetailId, jsonData) {
		setSummaryDetailCheckJSON_({ icgAccountRoleDetailId, jsonData });
	}

	setVisibilityPhotos(id, photos) {
		setVisibilityPhotos_({ id, photos })
			.then(result => {
				this.photosRow.photos = result;
			})
			.finally(() => {
				this.isLoading = false;
			});
	}

	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;
			this.getCapabilitiesFromAccountRoleDetailId(this.recordId);
		}	

		//no collapsed first section
		let nodes = this.template.querySelectorAll('img[data-section="content"]');	
		if(nodes[0] && !this.firstSeccionToogled){
			this.firstSeccionToogled = true;
			let nodesContent = this.template.querySelectorAll('.collapsed');
			nodes[0].src = this.chevronup;
			nodesContent[0].classList.replace("collapsed", "no-collapsed");		
		}
	}

	get dataInformed() {
		return this.data != null ? true : false;
	}

	openModalEditPhotos(event) {
		let superCategoryIndex = event.target.dataset.superCategoryIndex;
		let sectionIndex = event.target.dataset.sectionIndex;
		let capabilityIndex = event.target.dataset.capabilityIndex;
		let categoryIndex = event.target.dataset.categoryIndex;
		let rowIndex = event.target.dataset.rowIndex;

		this.photosRow = this.data.superCategories[superCategoryIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex];

		this.modalEditPhotos = true;
	}

	closeModalEditPhotos() {
		this.capabilityPhotoId = null;
		this.modalEditPhotos = false;
	}

	toggleSection(event) {
		let key = event.currentTarget.dataset.key;
		let section = event.currentTarget.dataset.section;

		let btnTrigger = this.template.querySelector(`img[data-section="${section}"][data-key="${key}"]`);
		let containerToShow = this.template.querySelector(`div[data-section="${section}"][data-key="${key}"]`);

		if (containerToShow.classList.contains("collapsed")) {
			containerToShow.classList.replace("collapsed", "no-collapsed");
			btnTrigger.src = this.chevronup;
		} else {
			containerToShow.classList.replace("no-collapsed", "collapsed");
			btnTrigger.src = this.chevrondown;
		}
	}

	toggleFlipDevice() {
		let adviceFlipDevice = this.template.querySelector(".flip-device");
		adviceFlipDevice.classList.remove("hidden");
		setTimeout(function() {
			adviceFlipDevice.classList.add("hidden");
		}, 3000);
	}

	toggleContent(event) {
		let section = event.target.dataset.section;
		let action = event.target.dataset.action;
		this.executeToggleContent(section,action);
	}

	executeToggleContent(section,action){
		let btnTrigger = this.template.querySelectorAll(`button[data-section="${section}"][data-action="${action}"]`);
		let btnOther = this.template.querySelector(`button[data-section="${section}"]:not([data-action="${action}"])`);

		let containerToShow = this.template.querySelector(`div[data-section="${section}"][data-action="${action}"]`);
		let containerToHide = this.template.querySelector(`div[data-section="${section}"]:not([data-action="${action}"])`);

		if (containerToShow) {
			if (containerToShow.classList.contains("collapsed")) {
				containerToShow.classList.replace("collapsed", "no-collapsed");
				btnTrigger.forEach(elem => {
					elem.classList.replace("collapsed-button", "no-collapsed-button");
				});
			} else {
				containerToShow.classList.replace("no-collapsed", "collapsed");
				btnTrigger.forEach(elem => {
					elem.classList.replace("no-collapsed-button", "collapsed-button");
				});
			}
		}

		if (containerToHide) {
			containerToHide.classList.replace("no-collapsed", "collapsed");
		}
		if (btnOther) {
			btnOther.classList.replace("no-collapsed-button", "collapsed-button");
		}

		let photoheaders = this.template.querySelectorAll('.photo-colum-head');
		if (photoheaders && photoheaders.length > 0) {
			photoheaders.forEach(photoheader => {
				let certheader = photoheader.nextElementSibling;
				let widthcertheader = certheader.clientWidth;
				photoheader.style.right = (widthcertheader + 4) + "px";
			});
		}

		let photocells = this.template.querySelectorAll('.photo-colum');
		if (photocells && photocells.length > 0) {
			photocells.forEach(photocell => {
				let certcell = photocell.nextElementSibling;
				let widthcertcell = certcell.clientWidth;
				photocell.style.right = (widthcertcell + 4) + "px";
			});
		}
	}

	toggleVisibilityPhoto(event) {
		this.isLoading = true;
		let src = event.target.dataset.src;
		let capabilityId = null;
		let photosAvailable = false;

		this.photosRow.photos.forEach(element => {
			if (element.url === src) {
				capabilityId = element.id;
				element.visible = !element.visible;

				if (!photosAvailable && element.visible) {
					photosAvailable = true;
				}
			}
		});
		this.photosRow.photosAvailable = photosAvailable;

		this.setVisibilityPhotos(capabilityId, JSON.stringify(this.photosRow.photos));
	}

	showHideStampHover(event) {
		let stampPopover = this.template.querySelector(`section[data-name="stamp-popover"]`);
		let issueDateFormatted = event.target.dataset.issueDate;
		let expirationDateFormatted = event.target.dataset.expirationDate;
		issueDateFormatted = issueDateFormatted.split("-")[2] + "-" + issueDateFormatted.split("-")[1] + "-" + issueDateFormatted.split("-")[0];	
		expirationDateFormatted = expirationDateFormatted.split("-")[2] + "-" + expirationDateFormatted.split("-")[1] + "-" + expirationDateFormatted.split("-")[0];
		if (event.type === "mouseover" || event.type === "mousemove") {
			this.dataHoverInfoStamp = {
				name: event.target.dataset.name,
				issueDate: issueDateFormatted,
				expirationDate: expirationDateFormatted
			};
			let windowWidth = window.innerWidth;
			stampPopover.classList.remove("hidden");
			let popupBounds = stampPopover.getBoundingClientRect();
			if(windowWidth > 1199 && windowWidth < 1681){
				stampPopover.style.top = ((event.clientY * 1.25) + 25) + "px";
				stampPopover.style.left = (((event.clientX * 1.25) - popupBounds.width)+20) + "px";
			}else{
				
				stampPopover.style.top = (event.clientY + 25) + "px";
				stampPopover.style.left = ((event.clientX - popupBounds.width)+20) + "px";
			}
		} else {
			this.dataHoverInfoStamp = null;
			stampPopover.classList.add("hidden");
		}
	}

	handleChangeChecks(event) {
		let updatedCapabilitie = event.currentTarget.dataset.key;
		let summaryChecked = true;
		let detailChecked = true;
		let htmlAlert = "will not be displayed on public profile";
		let item1 = {};
		let item2 = {};
		this.data.superCategories.forEach((sectionAux)=> {
			sectionAux.sections.forEach((capabilitieAuxSe)=> {
				capabilitieAuxSe.capabilities.forEach((capabilitieAux)=> {
					var item0 = {};
					if (event.currentTarget.name === "Summary") {
						if (capabilitieAux.name === updatedCapabilitie) {
							capabilitieAux.first_load_check = false;
							item0.summary = event.detail.checked;
							if(!item0.summary){
								item0.detail = false;
								capabilitieAux.check_detail = false;
							} 
							else item0.detail = capabilitieAux.check_detail;
							capabilitieAux.check_summary = event.detail.checked;
						} else {
							item0.summary = capabilitieAux.check_summary;
							item0.detail = capabilitieAux.check_detail;
						}
					} else {
						if (capabilitieAux.name === updatedCapabilitie) {
							capabilitieAux.first_load_check = false;
							item0.detail = event.detail.checked;
							if(item0.detail) {
								item0.summary = true;
								capabilitieAux.check_summary = true;
							}
							else item0.summary = capabilitieAux.check_summary;
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

		let alertp = event.currentTarget.nextElementSibling;
		if (!alertp.classList.contains("alert")) {
			alertp = alertp.nextElementSibling;
		}
		if (!summaryChecked || !detailChecked) {
			if (!summaryChecked && !detailChecked) {
				htmlAlert = " <b>Entire section " + htmlAlert + "</b>";
			} else {
				alertp.classList.remove("alert-danger");
				if (summaryChecked) {
					htmlAlert = "Detail button " + htmlAlert;
				} else {
					htmlAlert = "Summary button " + htmlAlert;
				}
			}
			alertp.classList.remove("hidden");
			alertp.innerHTML = "<img src= " + this.warning + " class='width-15 pb-1' /> " + htmlAlert;
		} else {
			if (!alertp.classList.contains("hidden")) {
				alertp.classList.add("hidden");
			}
		}
		item2.capabilitiesMap = item1;
		this.setSummaryDetailCheckJSON(this.recordId, JSON.stringify(item2));
	}

	enableOptions(event){
		if(event != undefined)
		{
			this.toggleContent(event);
		}		
		this.disableOptions = !this.disableOptions;
			let isDisabled = this.disableOptions;
			let tempAddedRows=[];
			this.data.superCategories.forEach(superCategory => {
				superCategory.key = createKey(superCategory.label);
				superCategory.sections.forEach(section => {
					section.key = createKey(section.label);
						section.capabilities.forEach(capability=>{
							capability.categories.forEach(category=>{
									category.rows.forEach(function(row,m){
										if(row.isAssigned){
											row.isNotEditable = isDisabled;
										}
										if(row.isPeviouslyCertified && !isDisabled){
											
											let newCapabilityRow = {
												position: m.toString(),
												rtypeId: capability.rtypeId,
												category: category.value,
												equipment: row.equipment_value,
												fields:[]
											};
								
											row.isAssigned=true;				
											row.isNotEditable=false;
								
											let columns = category.columns;
											let fieldsByColumns = columns[columns.length-1];
							
											fieldsByColumns.forEach(element => {
							
												let newField = {
													field: element.name,
													value: (row[element.name] != '' && row[element.name] != null && row[element.name] != undefined) ? row[element.name] : '',
													required: row.requiredFields.includes(element.name)
												}
												newCapabilityRow.fields.push(newField);
											});
							
											tempAddedRows.push(newCapabilityRow);		
												
										}																			
									});
							});
						});
									
				});
			});
			if(isDisabled){
				this.listAddedRows = [];
			}
			else{
				this.listAddedRows = tempAddedRows;
			}
			// Show or not save and cancel bar.
			const newEvent = new CustomEvent("saveaction", {
				detail: {
					data: !isDisabled
				}
			});
			this.dispatchEvent(newEvent);
			
	}

	addFieldToList(event){
		let detail = JSON.parse(JSON.stringify(event.detail));
		let data = detail.data;
		
		let auxFields = {
			field:"",
			value:""
		};
		let containField=false;
		this.listAddedRows.forEach(function(element) {
			if(element.equipment === data.equipment && element.position === data.rowIndex){ 
				element.fields.forEach(field => {
					if(field.field === data.field){
						field.value = data.value;
						containField = true;
					}
				});	
				if(containField === false){
					auxFields.field = data.field;
					auxFields.value = data.value;
		
					element.fields.push(auxFields);
				}
			}			
		});

		// Show or not save and cancel bar.
		const newEvent = new CustomEvent("sendlistrows", {
			detail: {
				data: this.listAddedRows
			}
		});
		this.dispatchEvent(newEvent);
	}

	actionsCapability(event){
		let action = event.target.dataset.action;
		let superCategoriesIndex = event.target.dataset.superCategoriesIndex;
		let sectionIndex = event.target.dataset.sectionIndex;
		let capabilityIndex = event.target.dataset.capabilityIndex;
		let categoryIndex = event.target.dataset.categoryIndex;

		let listDataRow = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows;
		
		//Add new record for multirecord
		if(action === "Add"){
			
			let existsAddRow = false;
			listDataRow.forEach(element => {
				if(element.isAditional === true && element.isAssigned === false){
					existsAddRow = true;
				}
				
			});		
			let rowTeplateSelected = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].templateFields;	
			
			if(existsAddRow === false){

				var newRecord = Object.assign({},rowTeplateSelected);
				newRecord.certifications = [];
				newRecord.isAssigned= false;
				newRecord.isNotEditable= true;
				newRecord.isAditional= true;
				newRecord.isTemplateMultirecord = false;

				this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows.push(newRecord);
			}
			
		}
		else{
			let rowIndex = event.target.dataset.rowIndex;
			this.rowSelected = listDataRow[rowIndex];

			let newCapabilityRow = {
				position: rowIndex,
				rtypeId: this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].rtypeId,
				category: this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].value,
				equipment: this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex].equipment_value,
				fields:[]
			};

			//Add to list
			if(action === "Certify"){
				this.editMode=true;
				this.rowSelected.isAssigned=true;				
				this.rowSelected.isNotEditable=false;

				let columns = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].columns;
				let fieldsByColumns = columns[columns.length-1];

				fieldsByColumns.forEach(element => {

					let newField = {
						field: element.name,
						value: (this.rowSelected[element.name] != '' && this.rowSelected[element.name] != null && this.rowSelected[element.name] != undefined) ? this.rowSelected[element.name] : '',
						required: this.rowSelected.requiredFields.includes(element.name)
					}
					newCapabilityRow.fields.push(newField);
				});

				this.listAddedRows.push(newCapabilityRow);			
				
			}

			if(action === "Remove"){
				this.rowSelected.isNotEditable= true;

				this.rowSelected.isAssigned=false;

				if(this.rowSelected.isAditional === true){
					listDataRow.splice(rowIndex,1);
				}

				let index = 0;
				this.listAddedRows.forEach(element => {
					if(element.equipment === newCapabilityRow.equipment){
						this.listAddedRows.splice(index,1);
					}	
					index++;			
				});		
				
				if(this.listAddedRows.length === 0){
					this.editMode=true;
				}
			}
		}
	}

	get checkRequiredFields(){
		let returnValue=true;
		this.listAddedRows.forEach(element => {
			element.fields.forEach(field => {
				if(field.required.toString() === "true" ){
					if(field.value === ''){
						returnValue = false;
					}					
				}
			});
						
		});	
		return returnValue;
	}

	handleSaveChanges(listAddedRows){
		if(listAddedRows.length > 0){
			if(this.checkRequiredFields === true){
				this.isLoading = true;
				this.createRelationshipsForNewCapabilities(this.recordId,listAddedRows);
			}
			else{
				this.showToast("Error", "Complete required fields", "error");
				this._actionSave=false;
			}
			
		}
	}

	createRelationshipsForNewCapabilities(accRoleDet, listAddedRows)
	{
		createRelationshipsForNewCapabilities_({accRoleDet, listAddedRows})
		.then(res => {
			let result = JSON.parse(res);
			if(result.success)
			{				
				this.getCapabilitiesFromAccountRoleDetailId(this.recordId);
			}
			else
			{
				this.showToast("Error", result.message, "error");
			}

			this._actionSave=false;
			// Set to false save action.
			const newEvent = new CustomEvent("savesuccessful", {
				detail: {
					data: false
				}
			});
			this.dispatchEvent(newEvent);
			
		})
		.finally(() => {
			this.isLoading = false;
		});
	}
}
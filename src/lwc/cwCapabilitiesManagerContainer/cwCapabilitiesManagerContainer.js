import { LightningElement, api, track,wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getPermissionToEdit from "@salesforce/apex/CW_Utilities.getPermissionToEdit";
import getPublicLinkToFiles_ from "@salesforce/apex/CW_CapabilitiesManagerController.getPublicLinkToFiles";
import getCapabilitiesForFacilityCertificationId from "@salesforce/apex/CW_CapabilitiesManagerController.getCapabilitiesForFacilityCertificationId";
import setSummaryDetailCheckJSON_ from "@salesforce/apex/CW_FacilityCapabilitiesController.setSummaryDetailCheckJSON";
import createRelationshipsForNewCapabilities_ from "@salesforce/apex/CW_CapabilitiesManagerController.createRelationshipsForNewCapabilities";
import updateCapabilitiesEdited_ from "@salesforce/apex/CW_CapabilitiesManagerController.updateCapabilitiesEdited";
import labels from 'c/cwOneSourceLabels';
import { loadStyle } from 'lightning/platformResourceLoader';

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

	chevrondown = this.icons + "chevrondown.svg";
	chevronup = this.icons + "chevronup.svg";

	@api recordId = "";
	@api certificationMode = false;
	@api ardCertId;
	@api isCapabCertiMode = false;

	label = labels.labels();

	@api editMode = false;
	@track data = null;	
	@track modalEditPhotos = false;
	@track photosRow;
	@track photos = null;
	@track photosAvailable = null;
	@track dataHoverInfoStamp = null;
	@track showModal = false;
	@track headerCapabManagement = 'Capabilities management';
	@track headerDeletePhoto = 'Delete photo';
	@track messageToShow = 'There are not capabilities to edit';
	actionToExecute = {
		action:'',
		result: false
	}

	@track showFileUploadCarousel=false;
	@track labelButtonAddRowsToList = "Maintain previous capabilities";
	@track existsRows;
	@track rowSelected="";
	@track listAddedRows = [];
	addAllRowsPrevious = false;
	listPositionsRow = [];
	rowIndexPhotoSelected;
	equipmentPhotoSelected;
	isKeepPhotos=false;
	
	//for notification toast
    _title = '';
    _message = '';
    _variant = '';
    variantOptions = [
        { label: 'error', value: 'error' },
        { label: 'warning', value: 'warning' },
        { label: 'success', value: 'success' },
        { label: 'info', value: 'info' },
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
            variant: this._variant,
        });
        this.dispatchEvent(evt);
	}
	//end notification toast

	get dataInformed() {
		return this.data != null ? true : false;
	}

	get isSaveOption(){
		return this.editMode === true && (this.certificationMode || this.getexistsRows()) ? true : false;
	}

	getexistsRows()
	{
		let containsData=false;
		if(this.dataInformed){
			if(this.data.superCategories.length > 0){			
				this.data.superCategories.forEach(superC=>{
					if(superC.containsData || superC.containsData === true){
						containsData = true;
					}
				});						
			}	
		}
		return containsData;	
	}

	get getisCapabCertiMode(){
		return this.isCapabCertiMode === 'true' ||  this.isCapabCertiMode === true;
	}

	get isLoading(){
		return this.loading || !this.dataInformed;
	}

	get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
    }

	setSummaryDetailCheckJSON(icgAccountRoleDetailId, jsonData) {
		setSummaryDetailCheckJSON_({ icgAccountRoleDetailId, jsonData });
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
		this.rowSelected.isKeepPhotos = this.rowSelected.photosAvailable;
	}

	photoToDelete;
	deletePhotoCarousel(event){
		let position = event.target.dataset.position;
		this.photoToDelete = position;
		this.actionToExecute.action = 'delete';		
		this.actionToExecute.result = true;
		this.openModal(this.headerDeletePhoto);
	}

	setPhotosValue(value){
		this.listAddedRows.forEach(element => {
			if(element.position.toString() === this.rowIndexPhotoSelected && element.equipment_value === this.equipmentPhotoSelected){
				let photoFound=false;
				element.fields.forEach(f=>{
					if(f.field === 'Photos__c'){
						f.value = value;
						photoFound=true;
					}
				})
				if(!photoFound){
					let newField = {
						field: 'Photos__c',
						value: value,
						label: 'Photos',
						required: false
					}
					element.fields.push(newField);
				}			
			}			
		});
		
	}

	restPhotosValue(){
		let position = this.photoToDelete;
		this.rowSelected.photos.splice(Number(position),1);
		if(this.rowSelected.photos.length >0){
			this.setPhotosValue(JSON.stringify(this.rowSelected.photos));	
			this.modalEditPhotos=true;		
		}
		else{			
			this.rowSelected.photosAvailable=false;
			this.setPhotosValue('');
		}
		
	}

	handleUploadFinished(event) {

        // Get the list of uploaded files
		const uploadedFiles = event.detail.files;

		if(uploadedFiles.length > 0){
			let listPhoto = [];

			uploadedFiles.forEach(file => {				
				let photo = {
					visible: true,
					url: '',
					label: file.name,
					id: file.documentId
				}
				listPhoto.push(photo);			
			});
			this.getPublicLinkToFiles(listPhoto);
		}
		
	}

	getPublicLinkToFiles(listPhoto){
		this.loading = true;
		getPublicLinkToFiles_({listPhoto})
			.then(res => {				
					let result = JSON.parse(res);
					if(result.success)
					{
						let photosToUpsert = result.message;
						let currentPhotoList = JSON.parse(JSON.stringify(result.message));
						let currentPhotoListParse = JSON.parse(currentPhotoList);
						this.rowSelected.newphotos = currentPhotoListParse;
												
						let previousPhotoList = this.rowSelected.photos;
						if(previousPhotoList.length > 0){
							currentPhotoListParse.forEach(photo=>{
								previousPhotoList.push(photo);
							});
							photosToUpsert = JSON.stringify(previousPhotoList);
						}
						this.rowSelected.photos = previousPhotoList;
						this.rowSelected.photosAvailable=true;

						this.setPhotosValue(photosToUpsert);

					}	
					else{
						this._title = 'Error';
						this._message = result.message;
						this._variant = 'error';
			
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
		item2.capabilitiesMap = item1;
		this.setSummaryDetailCheckJSON(this.recordId, JSON.stringify(item2));
	}

	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;

			getPermissionToEdit({})
			.then(result => {
				let edit = false;
				if(result){
					edit = result;
				}
				this.editMode = edit;			
				this.checkCapabilities();
			})			
		}
	}
	
	checkCapabilities(){
		if(this.editMode === true){
			if (this.certificationMode === true) {								
				this.labelButtonAddRowsToList = this.getisCapabCertiMode || this.certificationMode === false ? 'Edit capabilities' : "Maintain previous capabilities";
				this.getCapabilitiesFromCertification(this.recordId, this.ardCertId, this.getisCapabCertiMode);
			}
			else { 
				this.getCapabilitiesFromCertification(this.recordId, null, this.getisCapabCertiMode);
			}
			
			Promise.all([
				loadStyle(this, resources + "/css/internal.css")
			]);
		}
		else{
			this.messageToShow = 'You cannot manage capabilities';
			this.data = [];
			this.loading = false;
		}
	}

	getCapabilitiesFromCertification(id, ardCertId , isCapabCertiMode) { 
		getCapabilitiesForFacilityCertificationId({id,ardCertId, isCapabCertiMode}).then(result => {
			this.data = result;
			this.existsRows = this.getexistsRows();
			// Creates the event with the data and dispatches.
			const newEvent = new CustomEvent("dataloaded", {
				detail: {
					data: this.data
				}
			});
			this.dispatchEvent(newEvent);
		})
		.finally(() => {
			this.loading = false;
		});
	}

	openModalEditPhotos(event) {
		let superCategoriesIndex = event.target.dataset.superCategoriesIndex;
		let sectionIndex = event.target.dataset.sectionIndex;
		let capabilityIndex = event.target.dataset.capabilityIndex;
		let categoryIndex = event.target.dataset.categoryIndex;
		let rowIndex = event.target.dataset.rowIndex;

		this.photosRow = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows[rowIndex];
		
		this.modalEditPhotos = true;
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

	addFieldToList(event){
		let detail = JSON.parse(JSON.stringify(event.detail));
		let data = detail.data;
		
		let auxFields = {
			field:"",
			value:""
		};
		let containField=false;
		this.listAddedRows.forEach(function(element) {
			if(element.equipment_value === data.equipment && element.position.toString() === data.rowIndex){ 
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
	}


	addPreviuosCapabilities(event){
		this.addAllRowsPrevious = !this.addAllRowsPrevious;
		this.loading=true;
		if(this.addAllRowsPrevious === true){
			let listPositionsRow = [];
			this.data.superCategories.forEach(function(superCategory,i) {
				superCategory.sections.forEach(function(section,j) {
						section.capabilities.forEach(function(capability,k){
							capability.categories.forEach(function(category,l){
									category.rows.forEach(function(row,m){
										if(row.isAssigned === false && row.isPeviouslyCertified === true){
											
											let positionRow = {
												superCategoriesIndex: i,
												sectionIndex: j,
												capabilityIndex: k,
												categoryIndex: l,
												rowIndex:m
											}
											listPositionsRow.push(positionRow);
										}																									
									});
							});
					});							
				});
			});
			this.listPositionsRow = listPositionsRow;
			this.operationCapabilities('assign');
		}
		else{
			this.operationCapabilities('deallocate');
		}
		
	}


	operationCapabilities(action){
		
		if(action === 'assign'){
			this.listPositionsRow.forEach(elem =>{
				let listDataRow = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].rows;

				let row = listDataRow[elem.rowIndex];
				row.isNotEditable = false;
				row.isAssigned = true;
				row.customClass='row-assigned';

				let newCapabilityRow = {
					id: row.id,
					position: elem.rowIndex,
					rtypeId: this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].rtypeId,
					category: this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].value,
					equipment_value: row.equipment_value,
					equipment_label: row.equipment__c,
					fields:[]
				};

				let columns = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].columns;
				let fieldsByColumns = columns[columns.length-1];

					fieldsByColumns.forEach(element => {
						let newField = {
							field: element.name,
							value: (row[element.name] != '' && row[element.name] != null && row[element.name] != undefined) ? row[element.name] : '',
							label: element.label,
							required: row.requiredFields.includes(element.name)
						}
						newCapabilityRow.fields.push(newField);
					});
						this.listAddedRows.push(newCapabilityRow);	
					
			});
		}

		if(action === 'deallocate'){
			this.listPositionsRow.forEach(elem=>{
				let row = this.data.superCategories[elem.superCategoriesIndex].sections[elem.sectionIndex].capabilities[elem.capabilityIndex].categories[elem.categoryIndex].rows[elem.rowIndex];

				row.isAssigned=false;
				row.isNotEditable= true;
				row.customClass='';

				let index = 0;
				this.listAddedRows.forEach(element => {
					if(element.equipment_value === row.equipment_value){
						this.listAddedRows.splice(index,1);
					}	
					index++;			
				});		
			
			});

		}
		this.loading=false;

	}

	assigntCapability(event){
		let action = event.target.dataset.action;
		let superCategoriesIndex = event.target.dataset.superCategoriesIndex;
		let sectionIndex = event.target.dataset.sectionIndex;
		let capabilityIndex = event.target.dataset.capabilityIndex;
		let categoryIndex = event.target.dataset.categoryIndex;
		
		let listDataRow = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].rows;

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
				id: this.rowSelected.id,
				rtypeId: this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].rtypeId,
				category: this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].value,
				equipment_value: this.rowSelected.equipment_value,
				equipment_label: this.rowSelected.equipment__c,
				fields:[]
			};

			if(action === "Certify"){
				this.rowSelected.isAssigned=true;
				this.rowSelected.isNotEditable=false;
				this.rowSelected.customClass='row-assigned';

				let columns = this.data.superCategories[superCategoriesIndex].sections[sectionIndex].capabilities[capabilityIndex].categories[categoryIndex].columns;
				let fieldsByColumns = columns[columns.length-1];

				fieldsByColumns.forEach(element => {
					let newField = {
						field: element.name,
						value: (this.rowSelected[element.name] != '' && this.rowSelected[element.name] != null && this.rowSelected[element.name] != undefined) ? this.rowSelected[element.name] : '',
						label: element.label,
						required: this.rowSelected.requiredFields.includes(element.name)
					}
					newCapabilityRow.fields.push(newField);
					
				});

				this.listAddedRows.push(newCapabilityRow);			
				
			}

			if(action === "Remove"){
				this.rowSelected.isAssigned=false;
				this.rowSelected.isNotEditable= true;
				this.rowSelected.customClass='';

				if(this.rowSelected.isAditional === true){
					listDataRow.splice(rowIndex,1);
				}
				let index = 0;

				this.listAddedRows.forEach(element => {
					if(element.equipment_value === newCapabilityRow.equipment_value){
						this.listAddedRows.splice(index,1);
					}	
					index++;			
				});		
				
			}
		}
	}

	get checkRequiredFields(){
		let listFieldByEquipments = [];
		let returnValue=true;
		this.listAddedRows.forEach(element => {
			let fieldByEquipmentRequired = {
				equipment: '',
				fields: []
			};
			element.fields.forEach(field => {
				if(field.required.toString() === "true" && field.field != 'equipment__c'){
					if(field.value === ''){
						returnValue = false;
						fieldByEquipmentRequired.equipment = element.equipment_label;
						fieldByEquipmentRequired.fields.push(field.label);
					}					
				}
			});
			if(returnValue === false){
				listFieldByEquipments.push(fieldByEquipmentRequired);
			}
		});	
		
		return listFieldByEquipments;
	}
	
	saveCapabilities(){
		this.actionToExecute.action = 'save';
		this.actionToExecute.result = true;

		let listFieldByEquipments = this.checkRequiredFields;
		let result = listFieldByEquipments.length > 0 ? false : true;
		if(result === "false" || result === false){

			if(listFieldByEquipments.length > 0){
				listFieldByEquipments.forEach(elem=>{
					let message = 'The Equipment: "'+ elem.equipment +'" required the Fields: ';
					elem.fields.forEach(f=>{
						message+= f +' ,';
					});
					this._title = 'Error';
					this._message = message;
					this._variant = 'error';			
					this.showNotification();
				});
			}
			
		}
		else{
			this.openModal(this.headerCapabManagement);
		}
		
	}
	
	cancelCapabilities(){
		this.actionToExecute.action = 'cancel';
		this.actionToExecute.result = true;
		this.openModal(this.headerCapabManagement);
	}

	closeCapabilitiesTab(){
		var close = true;
		const closeclickedevt = new CustomEvent('closecapabilitiestab', {
			detail: { close },
		});
		 this.dispatchEvent(closeclickedevt);
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
	}

	createRelationshipsForNewCapabilities(accRoleDet,ardCertId, listAddedRows)
	{
		createRelationshipsForNewCapabilities_({accRoleDet, ardCertId , listAddedRows})
		.then(res => {
			let result = JSON.parse(res);
			if(result.success)
			{				
				this._title = 'Success';
				this._message = "Successful operation";
				this._variant = 'success';
				
				this.closeCapabilitiesTab();
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

	updateCapabilitiesEdited(listAddedRows)
	{
		updateCapabilitiesEdited_({listAddedRows})
		.then(res => {
			let result = JSON.parse(res);
			if(result.success)
			{				
				this._title = 'Success';
				this._message = "Successful operation";
				this._variant = 'success';
				
				this.closeCapabilitiesTab();
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
		
		if(this.actionToExecute.action === 'save' && this.actionToExecute.result)
		{
			if(this.listAddedRows.length>0){
				this.loading = true;
				if(this.getisCapabCertiMode || this.certificationMode === false){
					this.updateCapabilitiesEdited(this.listAddedRows);
				}
				else{
					this.createRelationshipsForNewCapabilities(this.recordId,this.ardCertId,this.listAddedRows);
				}				
			}
			else{
				this.closeCapabilitiesTab();
			}
		}
		if(this.actionToExecute.action === 'delete' && this.actionToExecute.result){
			this.modalEditPhotos=false;
			this.restPhotosValue();
		}
		if(this.actionToExecute.action === 'cancel' && this.actionToExecute.result)
		{
			if(!this.getisCapabCertiMode && this.certificationMode === true){
				deleteRecord(this.ardCertId)
				.then(() => {
					this.closeCapabilitiesTab();
				})
			}
			else{
				this.closeCapabilitiesTab();
			}	
		}
		
	}

}
//supporting document
import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
import { 
	getLocationType,
	getSectionInfo, 
	getUserType, 
	getCase, 
	sectionDecision, 
	sectionNavigation, 
	getApplicationType, 
	displaySaveAndQuitButton, 
	SECTION_CONFIRMED,
	NEW_BRANCH,
  	NEW_VIRTUAL_BRANCH,
  	CHG_NAME_COMPANY 
} from "c/tidsUserInfo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveFile from "@salesforce/apex/TIDSUtil.saveFile";
import relatedFiles from "@salesforce/apex/TIDSUtil.relatedFiles";
import deleteFiles from "@salesforce/apex/TIDSUtil.deleteFiles";
import getTermsAndConditions from "@salesforce/apex/TIDSUtil.getTermsAndConditions";

export default class TidsSupportingDocuments extends LightningElement {
	@api tidsUserInfo;
	// Array of JavaScript File objects to upload Salesforce Case
	@track documents = [];
	// Array to display the information from Salesforce or Added for the user
	@track documentsView = [];
	@track vettingMode;
	@track tidsCase;
	@wire(CurrentPageReference) pageRef;
	@track cmpName = "supporting-documents";
	@track disableButton;
	// File upload accept format
	@track acceptFormat = "image/png, image/jpg, .pdf, .xls, .doc, .docx"
	@track isSaveAndQuit = false;  
	// Vetting Modal - Errors
	@track sectionHasErrors = false;
	@track fieldErrorSelected = {};
	// Modal
	@track openModal = false;
	@track modalDefaultMessage = true;
	@track modalAction = "FIELD";
	// Vetting errors
	@track vettingErrorOptions = false;
	@track vettingErrors = [];
	@track documentsError = {
		fieldLabel: "Documents",
		fieldName: "documentsError",
		show: false,
		description: ""
	};
	@track filedocuments = []
	@track documentindex = 0;
	@track file;
	@track fileContents;
	@track fileReader;
	@track content;
	@track MAX_FILE_SIZE = 25000000;
	@track showSpinner = false;
	@track totalDocuments = 0;
	// New branch
	@track showSaveAndQuitButton = false;
	// Disable report errors and proceed
	@track reportErrorButtonDisabled;
	@track documentid;
	@track documentfilepath;
	@track transactiontype;
  

	connectedCallback() {
		// Vetting menu
		registerListener("vettingMenuListener", this.vettingMenuListener, this);
		 // Vetting modal listener
		registerListener("modalProceedListener", this.modalProceedListener, this);
		registerListener("modalCloseListener", this.modalCloseListener, this);
		registerListener("modalDeleteAllErrorsListener",this.modalDeleteAllErrorsListener,this);
		this.getTidsTermsAndConditions();
		this.reportErrorButtonDisabled = true;
		this.tidsCase = getCase();
		let userType = getUserType();
		this.vettingMode = userType === "vetting" ? true : false;
		let savedInfo = getSectionInfo(this.cmpName);
		this.getRelatedFiles();
		if (savedInfo) {
			if (
				this.vettingMode &&
				savedInfo.errors !== undefined &&
				savedInfo.errors.length > 0
			) {
				let er = JSON.parse(JSON.stringify(savedInfo.errors));
				er.forEach(el => {
					if (el.fieldName === "documentsError") {
						this.documentsError = el;
					}
				});
				this.vettingErrorOptions = true;
				this.sectionHasErrors = this.noFormErrors();
				this.notifySectionHasError();
			}
		}
		this.nextButtonDisabled();
		this.showSaveAndQuitButton = displaySaveAndQuitButton({payload:{applicationType: getApplicationType()}});
		this.setFormText();
	}

	@track istext1=false
	@track istext2=false;
	@track istext3=false;
	@track istext4=false;
	setFormText() {
		let type = getLocationType();
		let apptype=getApplicationType();
		this.istext1=true;
		this.istext2=false;
		this.istext3=false;
	
		if (apptype=== NEW_BRANCH) {
			this.istext1=false;
			this.istext2=true;
			this.istext3=false;					
		}
		
		if (apptype === NEW_VIRTUAL_BRANCH) {
			this.istext1=false;
			this.istext2=false;
			this.istext3=true;
		}		
	
		if (apptype=== CHG_NAME_COMPANY){
		  	if (type==='HO') {
				this.istext1=false;
				this.istext2=false;
				this.istext3=false;
				this.istext4=true;
			}
		}
	}

	notifySectionHasError() {
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
				fireEvent(this.pageRef, "sectionErrorListener", this.sectionHasErrors);
			},
			1,
			this
		);
	}
 
	handleNextSection(event) {
		event.preventDefault();
		let option = event.target.dataset.name;
		this.transactiontype=option;
		this.showSpinner = true;
		this.handleSave();
	}

	vettingMenuListener(props) {
		this.modalAction = "ALL";
		if (this.sectionHasErrors) {
			this.modalDefaultMessage = true;
			this.openModal = true;
		} else {
			this.openModal = false;
			this.vettingErrorOptions = props;
		}
	}

	handleUploadFiles(event) {
		Array.from(event.target.files).forEach(file => {
			this.documentsView.push(this.mappingFile(file));
		});
		this.totalDocuments = this.documentsView.length;
		this.nextButtonDisabled();
	}

	handleSave() {
		if (this.documentsView.length > 0) {
			this.documentindex = 0;
			this.uploadHelper();
		} else {
			this.upsertSupportingDocs();  
		}
	}

	uploadHelper() {
		this.nextButtonDisabled();
		if (this.documentindex === this.documentsView.length) {
			this.documents = [];
			return;
		}
		this.file = this.documentsView[this.documentindex].document;
		if (this.file.size > this.MAX_FILE_SIZE) {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "File size error",
					message: "File size exceeds 25mb for file name:"+this.file.name,
					variant: "error"
				})
			);
			this.showSpinner = false;
			return;
		}
		this.showLoadingSpinner = true;
		// create a FileReader object
		this.fileReader = new FileReader();
		// set onload function of FileReader object
		this.fileReader.onloadend = () => {
			this.fileContents = this.fileReader.result;
			let base64 = "base64,";
			this.content = this.fileContents.indexOf(base64) + base64.length;
			//remove string with base64 occurence
			this.fileContents = this.fileContents.substring(this.content);
			// call the uploadProcess method
			this.saveToFile();
		};
		this.fileReader.addEventListener('progress', (event) => {
			if (event.loaded && event.total) {
				const percent = (event.loaded / event.total) * 100;
			}
		});
		this.fileReader.readAsDataURL(this.file);
	}

	mappingFile(props) {
		let newFile = {document: props, name: props.name, contentType: props.type, size: props.size, iconName: this.iconFile(props), sizeConversion: this.formatBytes(props.size)};
		return newFile;
	}

	mappingFileFromSF(props) {
		let newFile = {id: props.Id,
			name: props.Name,
			contentType: props.ContentType,
			iconName: this.iconFile({type:props.ContentType})
		};
		return newFile;
	}

	formatBytes(bytes, decimals = 2) {
		if (bytes === 0) return '0 Bytes';
		const k = 1024;
		const dm = decimals < 0 ? 0 : decimals;
		const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
		const i = Math.floor(Math.log(bytes) / Math.log(k));
		return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
	}

	iconFile(props){
		let iconClassName = '';
		switch(props.type){
			case 'image/png':
			case 'image/jpeg':
			case 'image/gif':
				iconClassName = 'doctype:image';
				break;
			case 'text/csv':
				iconClassName = 'doctype:csv';
				break;
			case 'application/pdf':
				iconClassName = 'doctype:pdf';
				break;
			case 'application/msword':
			case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
				iconClassName = 'doctype:word';
				break;
			case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
				iconClassName = 'doctype:excel';
				break;
			default: 
				iconClassName = 'doctype:unknown';
				break;
		}
		return iconClassName
	}
	// Calling apex class to insert the file
	//base64data: encodeURIComponent(this.fileContents),   
	saveToFile() {
		saveFile({
			parentid: this.tidsCase.Id,
			filename: this.file.name,
			fileType: this.file.type,
			base64data: this.fileContents,
			isUnique: true
		})
			.then(result => {
				this.documentindex++;
				// Showing Success message after file insert
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Success!!",
						message: this.file.name + " - Uploaded Successfully!!!",
						variant: "success"
					})
				);
				if(this.documentindex < this.totalDocuments) {
					this.uploadHelper();
				} else {
					this.showSpinner = false;
					setTimeout(()=>{
						this.upsertSupportingDocs();
					},1000, this);
				}        
			})
			.catch(error => {
				this.showSpinner = false;
				console.log('error', JSON.stringify(error.body));
				// Showing errors if any while inserting the files
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error while uploading File",
						message: error.body.message,
						variant: "error"
					})
				);
			});
	}
	upsertSupportingDocs() {
		let documentsValues;
		let option= this.transactiontype;
		if (option === "next-section" || option === "save-quit") {
			documentsValues = this.infoToBeSave();
			if(this.isSaveAndQuit){
				this.isSaveAndQuit = false;
				documentsValues.target = 'save-quit';
				documentsValues.action = 'SaveAndQuit';
			} 
		}else if (option === "report-errors-and-proceed") {
			this.updateErrors();
			documentsValues = this.infoToBeSave();
		} else if(option === 'confirm-review-status'){
			documentsValues = this.infoToBeSave();
			documentsValues.sectionDecision = SECTION_CONFIRMED;
		}
		fireEvent(this.pageRef, "tidsUserInfoUpdate", documentsValues);
	}
	//Read all the attachments and update documents
	// Getting releated files of the current record
	getRelatedFiles() {
		relatedFiles({ parentid: this.tidsCase.Id })
			.then(data => {
				let sfAttachments = JSON.parse(JSON.stringify(data));
				if(sfAttachments !== undefined){
					if (sfAttachments.isError===0){
						sfAttachments.documents.forEach(item => {
							this.filedocuments.push(this.mappingFileFromSF(item));
						});
					}
					this.nextButtonDisabled();
				}
			})
			.catch(error => {
				console.log('error',JSON.stringify(error));
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error!!",
						message: error.body.message,
						variant: "error"
					})
				);
			});
	}

	//
	handleUploadRemove(event) {
		let fileselected = event.target.dataset.name;
		let index = this.documentsView.findIndex(x => x.name === fileselected);
		this.documentsView.splice(index,1);
		this.nextButtonDisabled();
	}

	handleUploadFileRemove(event) {
		let currentDocument = null;
		let fileselected = event.target.dataset.name;
		let index = this.filedocuments.findIndex(i => i.id === fileselected);
		currentDocument = this.filedocuments[index];
		this.filedocuments.splice(index,1);
		this.showSpinner = true;
		this.nextButtonDisabled();
		deleteFiles({ attachmentid: fileselected })
		.then(result => {
			this.showSpinner = false;
			// Showing Success message after file insert
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Success!!",
					message: currentDocument.name + " - deleted Successfully!!!",
					variant: "success"
				})
			);			
		})
		.catch(error => {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error!!",
					message: error.message,
					variant: "error"
				})
			);
		});
	}

	// Next button disabled
	nextButtonDisabled() {
		let documentsValid = this.documentsView.length > 0 ? true : false;
		let filesValid = this.filedocuments.length > 0 ? true : false;
		if (documentsValid || filesValid) {
			this.disableButton = false;
		} else {
			this.disableButton = true;
		}
	}

	//Vetting errors
	handleError(event) {
		event.preventDefault();
		let errorField = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (errorField) {
			case "error-documents":
				if (this.documentsError.show && this.documentsError.description !== "") {
					this.fieldErrorSelected = this.documentsError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.documentsError.show = !this.documentsError.show;
				}
				break;
			default:
				break;
		}
	}

	changeErrorFields(event) {
		let field = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (field) {
			case "error-documents-desc":
				this.documentsError.description = event.target.value;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	handleProceed(event) {
		event.preventDefault();
		let option = event.target.dataset.name;
		this.transactiontype=option;
		this.showSpinner = true;
		this.handleSave();
	}

	updateErrors() {
		if (this.documentsError.show && this.documentsError.description !== "") {
			this.addVettingError(this.documentsError);
		}
	}

	addVettingError(props) {
		let index = this.vettingErrors.findIndex(
			error => error.fieldName === props.fieldName
		);
		if (index === -1) {
			this.vettingErrors.push(props);
		} else {
			this.vettingErrors.splice(index, 1);
			this.vettingErrors.push(props);
		}
	}

	handleSaveAndQuit(event) {
		event.preventDefault();
		let option = event.target.dataset.name;
		this.transactiontype=option;
		this.showSpinner = true;
		this.isSaveAndQuit = true;  
		this.handleSave();
		//fireEvent(this.pageRef, "tidsUserInfoUpdate", documentsError);
	}

	// Modal Listeners
	modalProceedListener(props) {
		this.updateinfoErrors(props);
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	updateinfoErrors(props) {
		if (props.fieldName === "documentsError") {
			this.documentsError = props;
		}
	}

	modalCloseListener(props) {
		this.openModal = props;
		if(this.modalAction === 'ALL') {
			fireEvent(this.pageRef, "sectionErrorListener", true);
		}
	}

	modalDeleteAllErrorsListener(props) {
		// Reset Values
		this.documentsError.show = false;
		this.documentsError.description = "";
		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();
		this.openModal = false;
		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

	// Section business logic Save
	infoToBeSave() {
		let sectionNav = JSON.parse(
			JSON.stringify(sectionNavigation(this.cmpName))
		);
		let documentsValues = {
			cmpName: this.cmpName,
			target: sectionNav.next,
			sectionDecision: sectionDecision(this.sectionHasErrors),
			values: this.documents,
			vettingErrors: this.vettingErrors
		};
		return documentsValues;
	}

	noFormErrors() {
		let documentsValid =this.documentsError.show && this.documentsError.description !== "" ? true : false;
		this.reportErrorButtonDisabled = documentsValid ? false : true;
		return documentsValid;
	}
	getTidsTermsAndConditions() {
		getTermsAndConditions()
		.then(response => {
			if (response!=null){
				this.documentid=response.Id;
				this.documentfilepath='/servlet/servlet.FileDownload?file='+response.Id;
			}
		});
	}
}
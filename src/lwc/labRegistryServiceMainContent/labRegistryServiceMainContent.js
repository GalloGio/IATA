import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage} from'c/navigationUtils';

//Static Resources
import getCSVTemplateFile from  '@salesforce/apex/LabRegistry_helper.getCSVTemplateFile';



//Labels
import CSP_LabReg_CompleteDetails		from '@salesforce/label/c.CSP_LabReg_CompleteDetails';
import CSP_LabReg_Download_CSV			from '@salesforce/label/c.CSP_LabReg_Download_CSV';
import CSP_LabReg_UploadDetails			from '@salesforce/label/c.CSP_LabReg_UploadDetails';
import CSP_LabReg_UploadFilledCSV		from '@salesforce/label/c.CSP_LabReg_UploadFilledCSV';
import CSP_LabReg_UploadCSVBtn		from '@salesforce/label/c.CSP_LabReg_UploadCSVBtn';
import IDCard_Confirm_Replacement from '@salesforce/label/c.IDCard_Confirm_Replacement';
import Button_Cancel from '@salesforce/label/c.Button_Cancel';
import CSP_PortalPath						from '@salesforce/label/c.CSP_PortalPath';


export default class labRegistryServiceMainContent extends NavigationMixin(LightningElement) {
	@track labels = {
		CSP_LabReg_CompleteDetails
		,CSP_LabReg_Download_CSV
		,CSP_LabReg_UploadDetails
		,CSP_LabReg_UploadFilledCSV
		,CSP_LabReg_UploadCSVBtn
		,IDCard_Confirm_Replacement
		,Button_Cancel
	}
	connectedCallback() {
		this.fetchCSVId();
	}

	downloadTemplate(){
		navigateToPage(this.csvURL,{});
	}
	

	openUploadModal(){
		this.showUploadModal = true;
	}

	closeUploadModal(){
		this.showUploadModal = false;
	}

	handleSubmitRequest(){
		alert('Processing file upload');
	}

	@track showUploadModal = false;
	@track disableConfirm = true;
	@track acceptedFormats = ['.xlsm'];

	csvId = 0;

	@track fileColumns=[
		{ label: 'Filename', fieldName: 'name'},
		{ label: 'Size', fieldName: 'sizeConversion'},
		{ type: 'button-icon', initialWidth: 50, typeAttributes: {iconName: 'utility:close', name: 'removeFile', variant:'container'}}
	];

	handleUploadFinished(event){
		this.csvId = this.csvId + 1;
		Array.from(event.target.files).forEach(file => {


			//this.uploadedCSV.push(this.mappingFile(file));

			this.uploadedCSV.push({
				id : this.csvId
				,document: file
				, name: file.name
				, contentType: file.type
				, size: file.size
				, sizeConversion: this.formatBytes(file.size)
			});
		});

		this.disableConfirm = false;

		// Get the list of uploaded files
		//let lstUploadedFiles = event.target.files;
		//this.csvId = this.csvId + 1;
		//lstUploadedFiles.forEach(fileIterator => this.uploadedCSV.push({'Id':this.csvId, 'fileName':fileIterator.name, 'fileSize':Math.round(fileIterator.size/1024) + 'Kb'}));
		this.uploadedCSV = [...this.uploadedCSV];


		//alert("No. of files uploaded : " + uploadedFiles.length);
	}

	mappingFile(props) {
		let newFile = {document: props, name: props.name, contentType: props.type, size: props.size, sizeConversion: this.formatBytes(props.size)};
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

	@track uploadedCSV = [];

	removeFile(event) {
		const action = event.detail.action;
		const row = event.detail.row;
		switch (action.name) {
			case 'removeFile':
				let indexFound = this.uploadedCSV.findIndex(ar => ar.Id == row.Id);
				this.uploadedCSV.splice(indexFound, 1);
				this.uploadedCSV = [...this.uploadedCSV];
 		}	
	}

	@track csvFilePath;
	fetchCSVId() {
		getCSVTemplateFile()
		.then(response => {
			if (response!=null){
				this.csvFilePath='/servlet/servlet.FileDownload?file='+response.Id;
			}
		});
	}
	
}
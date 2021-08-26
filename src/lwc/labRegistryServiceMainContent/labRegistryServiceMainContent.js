import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

//Static Resources
import getAttachmentFromPortalService from  '@salesforce/apex/LabRegistry_helper.getAttachmentFromPortalService';
import getPortalServiceId from '@salesforce/apex/ServiceTermsAndConditionsUtils.getPortalServiceId';

import checkLatestTermsAndConditionsAccepted from '@salesforce/apex/ServiceTermsAndConditionsUtils.checkLatestTermsAndConditionsAccepted';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import postFileToMulesoft from '@salesforce/apex/LabRegistry_helper.postFileToMulesoft';
import CreateCase from '@salesforce/apex/LabRegistry_helper.CreateCase';

//Labels
import CSP_LabReg_CompleteDetails		from '@salesforce/label/c.CSP_LabReg_CompleteDetails';
import CSP_LabReg_Download_CSV			from '@salesforce/label/c.CSP_LabReg_Download_CSV';
import CSP_LabReg_UploadDetails			from '@salesforce/label/c.CSP_LabReg_UploadDetails';
import CSP_LabReg_UploadFilledCSV		from '@salesforce/label/c.CSP_LabReg_UploadFilledCSV';
import IDCard_Confirm_Replacement		from '@salesforce/label/c.IDCard_Confirm_Replacement';
import CSP_LabReg_UploadCSVBtn		from '@salesforce/label/c.CSP_LabReg_UploadCSVBtn';
import CSP_LabReg_UploadCompleted from '@salesforce/label/c.CSP_LabReg_UploadCompleted';
import CSP_LabRegistry_LabDetails from '@salesforce/label/c.CSP_LabRegistry_LabDetails';
import CSP_LabReg_DownloadTemplate from '@salesforce/label/c.CSP_LabReg_DownloadTemplate';
import CSP_LabReg_Download_Instructions from '@salesforce/label/c.CSP_LabReg_Download_Instructions';
import CSP_LabReg_UploadHere from '@salesforce/label/c.CSP_LabReg_UploadHere';
import CSP_LabReg_UploadFileHelpText from '@salesforce/label/c.CSP_LabReg_UploadFileHelpText';


import ISSP_RD_UploadFile from '@salesforce/label/c.ISSP_RD_UploadFile';
import ISSP_RD_OK_Action from '@salesforce/label/c.ISSP_RD_OK_Action';
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
		,CSP_LabReg_UploadCompleted
		,CSP_LabRegistry_LabDetails
		,CSP_LabReg_DownloadTemplate
		,CSP_LabReg_Download_Instructions
		,CSP_LabReg_UploadHere
		,ISSP_RD_UploadFile
		,ISSP_RD_OK_Action
		,Button_Cancel
		,CSP_LabReg_UploadFileHelpText
	}

	successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';
	@track isLoading = false;

	connectedCallback() {
		this.fetchCSVId();
		this.fetchInstructionFile();

		getPortalServiceId({portalServiceName:'IATA Lab Network'}).then( result => {
			this.serviceId = result;

			getLoggedUser().then(userResult => {
				let loggedUser = JSON.parse(JSON.stringify(userResult));
	
				if (loggedUser.Contact != null && loggedUser.Contact.AccountId != null) {
					this.contactId = loggedUser.ContactId;
				}

				checkLatestTermsAndConditionsAccepted({portalServiceId: this.serviceId, contactId: this.contactId}).then(result2 => {
					let isLatestAccepted = JSON.parse(JSON.stringify(result2));
					this.isLatestAccepted = isLatestAccepted;
					if(!this.isLatestAccepted){
						this.displayAcceptTerms = true;
					}
				});
			});
		});

	}

	downloadTemplate(){
		navigateToPage(this.csvURL,{});
	}
	

	openUploadModal(){
		this.showUploadModal = true;
		this.uploadedCSV = [];
	}

	closeUploadModal(){
		this.showUploadModal = false;
	}

	@track openSuccessModal = false;
	
	//THIS IS WHERE THE CALLOUT TO MULESOFT IS DONE!
	handleSubmitRequest(){
		this.isLoading = true;
		CreateCase({
			reason:'New file upload'
		}).then(result => {
			if(result==null || result == undefined || result == ''){}
			else{
				let caseNum = result.CaseNumber;
				let i =0;
				this.uploadedCSV.forEach(theFile => {
					i = i+1;
					let fileName = caseNum + '_' + i + '_' + theFile.name;
					postFileToMulesoft({filename:fileName, fileContent:theFile.VersionData, fileDataContentType:theFile.contentType}).then(result2 => {
						this.uploadedCSV = [];
						this.isLoading = false;
						this.showUploadModal = false;
						this.openSuccessModal = true;
					}).catch(error => {
						//this.errorModalMessage = error;
						//this.openErrorModal = true; 
						this.isLoading = false;
					});
				});
			}
		}).catch(error => {
			//this.errorModalMessage = error;
			//this.openErrorModal = true; 
			this.isLoading = false;
		});
	}

	closeConfirmationModal(){
		this.openSuccessModal = false;
	}

	@track showUploadModal = false;
	@track disableConfirm = true;
	@track acceptedFormats = ['.csv'];

	csvId = 0;

	@track fileColumns=[
		{ label: 'Filename', fieldName: 'name'},
		{ label: 'Size', fieldName: 'sizeConversion'},
		{ type: 'button-icon', initialWidth: 50, typeAttributes: {iconName: 'utility:close', name: 'removeFile', variant:'container'}}
	];

	handleUploadFinished(event){
		this.csvId = this.csvId + 1;

		if (event.target.files.length > 0) {
            let files = [];
            for(var i=0; i< event.target.files.length; i++){
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);


                    this.uploadedCSV.push({
								name: file.name
								, VersionData: fileContents
								, contentType: file.type
								, size: file.size
								, sizeConversion: this.formatBytes(file.size)});
					
					if(this.uploadedCSV.length>0){
									this.uploadedCSV = [...this.uploadedCSV];
									this.disableConfirm = false;
								}
                };
                reader.readAsDataURL(file);
            }

			
        }
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

		if(this.uploadedCSV.length<1)  this.disableConfirm = true;
	}

	@track csvFilePath;
	fetchCSVId() {
		getAttachmentFromPortalService({filename:'Lab Information Template.xlsm'})
		.then(response => {
			if (response!=null){
				this.csvFilePath='/servlet/servlet.FileDownload?file='+response.Id;
			}
		});
	}

	@track instructionFilePath;
	fetchInstructionFile() {
		getAttachmentFromPortalService({filename:'IATA Lab Network Data Form Instructions.pdf'})
		.then(response => {
			if (response!=null){
				this.instructionFilePath='/servlet/servlet.FileDownload?file='+response.Id;
			}
		});
	}
	

	//TERMS AND CONDITIONS
	@track isLatestAccepted = false;
	@track displayAcceptTerms = false;
	@track serviceId;
	@track contactId;

	goToHome(){
		navigateToPage(CSP_PortalPath,{});
	}
	
	acceptTerms(){
		this.displayAcceptTerms = false;
		this.isLatestAccepted = true;
	}
}
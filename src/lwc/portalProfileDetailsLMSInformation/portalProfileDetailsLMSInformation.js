import { LightningElement,track,api } from 'lwc';

//custom labels
import CSP_L2_Business_Address_Information from '@salesforce/label/c.CSP_L2_Business_Address_Information_LMS';
import CSP_L2_Create_New_Account from '@salesforce/label/c.CSP_L2_Create_New_Account';
import CSP_L2_Company_Information_Message from '@salesforce/label/c.CSP_L2_Company_Information_Message';
import CSP_L2_Company_Information from '@salesforce/label/c.CSP_L2_Company_Information';
import ISSP_MyProfile_SECTOR from '@salesforce/label/c.ISSP_MyProfile_SECTOR';
import ISSP_MyProfile_CATEGORY from '@salesforce/label/c.ISSP_MyProfile_CATEGORY';
import CSP_L2_Legal_Name from '@salesforce/label/c.CSP_L2_Legal_Name';
import CSP_L2_Trade_Name from '@salesforce/label/c.CSP_L2_Trade_Name';
import CSP_L2_Phone_Number from '@salesforce/label/c.CSP_L2_Phone_Number';
import CSP_L2_Email_Address from '@salesforce/label/c.CSP_L2_Email_Address';
import CSP_L2_Website from '@salesforce/label/c.CSP_L2_Website';
import CSP_L2_Business_Address_Information_Message from '@salesforce/label/c.CSP_L2_Business_Address_Information_Message_LMS';
import CSP_L2_Back_to_Company_Information from '@salesforce/label/c.CSP_L2_Back_to_Company_Information';
import CSP_L2_Next_Confirmation from '@salesforce/label/c.CSP_L2_Next_Confirmation';
import CSP_Next_LMS from '@salesforce/label/c.CSP_Next_LMS';
import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';

export default class PortalRegistrationAddressInformationLMS extends LightningElement {

	// inputs
	@api address;
	@api countryId;
	@api recordId;
	
	@track localAddress;
	@track isSaving = false;

	// flag to enable/disable the "Next Step / Confirmation" button
	@track isConfirmationButtonDisabled;

	// labels
	_labels = {
		CSP_L2_Business_Address_Information,
		CSP_L2_Create_New_Account,
		CSP_L2_Company_Information_Message,
		CSP_L2_Company_Information,
		ISSP_MyProfile_SECTOR,
		ISSP_MyProfile_CATEGORY,
		CSP_L2_Legal_Name,
		CSP_L2_Trade_Name,
		CSP_L2_Phone_Number,
		CSP_L2_Email_Address,
		CSP_L2_Website,
		CSP_L2_Business_Address_Information_Message,
		CSP_L2_Back_to_Company_Information,
		CSP_L2_Next_Confirmation,
		CSP_Next_LMS,
		SaveLabel,
		CancelLabel
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback() {
		this.localAddress = JSON.parse(JSON.stringify(this.address));
		this.dispatchEvent(new CustomEvent('scrolltotop'));
	}

	toCompanyInformation(){
		this.dispatchEvent(new CustomEvent('gotostep', {detail:'1'}));
	}

	toConfirmation(){
		this.dispatchEvent(new CustomEvent('gotostep', {detail:'2'}));
	}

	next(){
		this.dispatchEvent(new CustomEvent('next'));
	}

	setValidationStatus(event){
		let res = this.template.querySelector('c-portal-address-form-l-m-s').getAddressInformation();
			
		this.localAddress = JSON.parse(JSON.stringify(res));
		
		if(this.localAddress.countryId !== '' && this.localAddress.cityName !== '' && (this.localAddress.street !== '' || this.localAddress.PO_Box_Address__c !== '') ){
			this.isConfirmationButtonDisabled = false;
		}else if(this.isConfirmationButtonDisabled !== !event.detail){
			this.isConfirmationButtonDisabled = !event.detail;
			this.dispatchEvent(new CustomEvent('completionstatus',{detail : event.detail}));
		}
	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}

	stopLoading(){
		this.dispatchEvent(new CustomEvent('stoploading'));
	}

	@api
	getAddressInformation(){
		let resAddressInformation = this.template.querySelector('c-portal-address-form-l-m-s').getAddressInformation();
		console.log('resAddressInformation:', resAddressInformation);
		this.localAddress = JSON.parse(JSON.stringify(resAddressInformation));
		return this.localAddress;
	}

	closeModal() { 
		console.log('closeModal!!');
		this.dispatchEvent(new CustomEvent('closemodal'));
	}

	handleSubmit(event) {
		console.log('handleSubmit!!');
		this.isSaving = true;
		
		this.localAddress = JSON.parse(JSON.stringify(this.getAddressInformation() ));
		console.log('this.localAddress:', this.localAddress);
		let addressSubmit = {
			'PO_Box_Address__c':'',
			'Country_Reference__c':'',
			'countryCode':'',
			'Country__c':'',
			'State_Reference__c':'',
			'State_Name__c':'',
			'City_Reference__c':'',
			'City_Name__c':'',
			'Street__c':'',
			'Street2__c':'',
			'Postal_Code__c':''
		};

		addressSubmit.Country_Reference__c = this.localAddress.countryId; 
		addressSubmit.Country__c = this.localAddress.countryName;
		addressSubmit.State_Reference__c = this.localAddress.stateId;
		addressSubmit.State_Name__c = this.localAddress.stateName;
		addressSubmit.City_Reference__c = this.localAddress.cityId;
		addressSubmit.City_Name__c = this.localAddress.cityName;
		addressSubmit.Street__c = this.localAddress.isPoBox === false ? this.localAddress.street : '';
		addressSubmit.Street2__c = this.localAddress.street2;
		addressSubmit.Postal_Code__c = this.localAddress.zip;
		addressSubmit.PO_Box_Address__c = this.localAddress.isPoBox === true ? this.localAddress.PO_Box_Address__c : '';
		console.log('addressSubmit:', addressSubmit);
		this.template.querySelector('lightning-record-edit-form').submit(addressSubmit);
		console.log('handleSubmit END!!');
	}
	
	handleSucess(event) {
		console.log('handleSucess!!');
		this.isSaving = false;
		this.closeModal();
		console.log('handleSucess END!!');
    }

    handleError(event) {
		this.isSaving = false;
		console.log('handleError - event: ', event);
    }

    onRecordSubmit(event) {
		this.isSaving = true;
    }
}
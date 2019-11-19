/**
 * Created by ukaya01 on 10/09/2019.
 */

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track, wire, api }     from 'lwc';
import { navigateToPage, getParamsFromPage } from'c/navigationUtils';
import { getRecord }                         from 'lightning/uiRecordApi';
import userId                                from '@salesforce/user/Id';
import getContactInfo                        from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import CSP_First_Login_Title                 from '@salesforce/label/c.CSP_First_Login_Title';
import CSP_First_Login_Desc                  from '@salesforce/label/c.CSP_First_Login_Desc';
import CSP_Skip                              from '@salesforce/label/c.CSP_Skip';
import CSP_Complete_Profile                  from '@salesforce/label/c.CSP_Complete_Profile';
import CSP_PortalPath                        from '@salesforce/label/c.CSP_PortalPath';

export default class PortalFirstLogin extends LightningElement {

	/* ==============================================================================================================*/
	/* Attributes
	/* ==============================================================================================================*/
	successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/success.png';
	@track isLoading = false;
	@track userName = "";
	@track isFirstLevelUser;

	@api registrationlevel; //FOR LMS L3

	_labels = {
		CSP_First_Login_Title,
		CSP_First_Login_Desc,
		CSP_Skip,
		CSP_Complete_Profile,
		CSP_PortalPath
	}

	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback(){

		console.log('PortalFirstLogin - connectedCallback - this.registrationlevel - ', this.registrationlevel);

		getContactInfo()
			.then(result => {
				this.isFirstLevelUser = result.Account.Is_General_Public_Account__c;
			});
	}

	@wire(getRecord, { recordId: userId, fields: ['User.Name'] })
	WireGetUserRecord(result) {
		console.log('result: ', result);
		if (result.data) {
			let user = JSON.parse(JSON.stringify(result.data));
			let userName = user.fields.Name.value;
			this.userName = userName;
		}
	}

	handleCloseModal(){
		console.log('closefirstloginpopup');
		this.dispatchEvent(new CustomEvent('closefirstloginpopup'));
	}

	handleAccept(){
		//Changes to accomodate LMS L3

		console.log('PortalFirstLogin - handleAccept this.registrationlevel - ', this.registrationlevel);
		if(this.registrationlevel !== undefined && this.registrationlevel === '3'){
			console.log('triggerthirdlevelregistrationlms');
			this.dispatchEvent(new CustomEvent('triggerthirdlevelregistrationlms'));
		}else{
			console.log('closefirstloginpopup');
			this.dispatchEvent(new CustomEvent('closefirstloginpopup'));
			navigateToPage(CSP_PortalPath + 'registrationsecondlevel',{});
		}
	}
}
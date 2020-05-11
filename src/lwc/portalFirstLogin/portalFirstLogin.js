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
import CSP_First_Login_Desc_LMS				 from '@salesforce/label/c.CSP_First_Login_Desc_LMS';
import CSP_Complete_Profile_LMS				 from '@salesforce/label/c.CSP_Complete_Profile_LMS';
import CSP_LogOut 							 from '@salesforce/label/c.CSP_LogOut';
import CSP_First_Login_Title_IE 			 from '@salesforce/label/c.CSP_First_Login_Title_IE';
import CSP_First_Login_Desc_LMS_IE 			 from '@salesforce/label/c.CSP_First_Login_Desc_LMS_IE';

export default class PortalFirstLogin extends LightningElement {

	/* ==============================================================================================================*/
	/* Attributes
	/* ==============================================================================================================*/
	successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/success.png';
	@track isLoading = false;
	@track userName = "";
	@track isFirstLevelUser;
	@track isL3Registration = false;
	@track isIEBrowser = false;

	@api registrationlevel; //FOR LMS L3

	_labels = {
		CSP_First_Login_Title,
		CSP_First_Login_Desc,
		CSP_Skip,
		CSP_Complete_Profile,
		CSP_PortalPath,
		CSP_First_Login_Desc_LMS,
		CSP_Complete_Profile_LMS,
		CSP_LogOut,
		CSP_First_Login_Title_IE,
		CSP_First_Login_Desc_LMS_IE
	}

	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback(){

        let browser = this.browserType();
		this.isIEBrowser = browser.indexOf('IE') >= 0 ? true : false;

		if(this.registrationlevel !== undefined && this.registrationlevel === '3'){
			this.isL3Registration = true;
		}

		getContactInfo()
			.then(result => {
				this.isFirstLevelUser = result.Account.Is_General_Public_Account__c;
			});
	}

	@wire(getRecord, { recordId: userId, fields: ['User.Name'] })
	WireGetUserRecord(result) {
		if (result.data) {
			let user = JSON.parse(JSON.stringify(result.data));
			let userName = user.fields.Name.value;
			this.userName = userName;
		}
	}

	handleCloseModal(){
		this.dispatchEvent(new CustomEvent('closefirstloginpopup'));
	}

	handleAccept(){
		//Changes to accomodate LMS L3
	if(this.registrationlevel !== undefined && this.registrationlevel === '3'){
			this.dispatchEvent(new CustomEvent('triggerthirdlevelregistrationlms'));
		}else{
			if(this.isFirstLevelUser){
				this.dispatchEvent(new CustomEvent('triggersecondlevelregistration'));
			}
		}
	}

	handleLogOut(){
		navigateToPage('/secur/logout.jsp?retUrl=' + CSP_PortalPath + 'login');
    }
    
    browserType(){
		let ua= navigator.userAgent;
		let tem;
		let M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];

		if(/trident/i.test(M[1])){
			tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
			return 'IE '+(tem[1] || '');
		}
		if(M[1]=== 'Chrome'){
			tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
			if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
		}
		M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
		if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
		return M.join(' ');
	}	
}
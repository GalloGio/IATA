import { LightningElement, api } from 'lwc';
import { navigateToPage, getParamsFromPage } from 'c/navigationUtils';
import getInitialConfig                      from '@salesforce/apex/PortalForgotPasswordController.getInitialConfig';
import CSP_PortalPath                        from '@salesforce/label/c.CSP_PortalPath';
import successLabel                          from '@salesforce/label/c.CSP_Success';
import loginNowLabel                         from '@salesforce/label/c.CSP_Login_Now';
import message1Label                         from '@salesforce/label/c.CSP_Reset_Password_Success_Msg_1';
import message2Label                         from '@salesforce/label/c.CSP_Reset_Password_Success_Msg_2';

export default class PortalResetPasswordSuccess extends LightningElement {

    successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/success.png';
	loginUrl = CSP_PortalPath + 'login';
	pageParams;

    labels = {
        successLabel,
        loginNowLabel,
        message1Label,
        message2Label
	}

	connectedCallback(){
		this.pageParams = getParamsFromPage();
		delete this.pageParams.c;

		getInitialConfig().then(result => {
			this.loginUrl = result.loginUrl.substring(result.loginUrl.indexOf(CSP_PortalPath));
		});
	}

	handleLogin() {
		navigateToPage(this.loginUrl, this.pageParams);
	}
}
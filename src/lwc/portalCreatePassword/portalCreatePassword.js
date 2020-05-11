import { LightningElement,track }            from 'lwc';
import { navigateToPage, getParamsFromPage } from 'c/navigationUtils';
import RegistrationUtils                     from 'c/registrationUtils';
import emailLabel                            from '@salesforce/label/c.CSP_Email';
import passwordLabel                         from '@salesforce/label/c.CSP_Password'
import CSP_PortalPath                        from '@salesforce/label/c.CSP_PortalPath';
import confirmPasswordLabel                  from '@salesforce/label/c.Confirm_password';
import createPasswordLabel                   from '@salesforce/label/c.CSP_Create_Password';
import passwordRule1Label                    from '@salesforce/label/c.CSP_Password_Rule_1';
import passwordRule2Label                    from '@salesforce/label/c.CSP_Password_Rule_2';
import passwordRule3Label                    from '@salesforce/label/c.CSP_Password_Rule_3';
import passwordRule4Label                    from '@salesforce/label/c.CSP_Password_Rule_4';
import saveLoginLabel                        from '@salesforce/label/c.CSP_Save_Login';
import changePasswordInfoLabel               from '@salesforce/label/c.CSP_Reset_Password_Info_1';
import changePasswordInfo2Label              from '@salesforce/label/c.CSP_Reset_Password_Info_2';
import errorMessageLabel                     from '@salesforce/label/c.CSP_Create_Password_Error';
import getParameters                         from '@salesforce/apex/PortalCreatePasswordController.getParameters';
import createUser                            from '@salesforce/apex/PortalCreatePasswordController.createUserAndSetPassword';

export default class PortalCreatePassword extends LightningElement {
	@track email             = "";
	@track password          = "";
	@track isExpired         = false;
	@track isLoading         = true;
	@track confirmPassword   = "";
	@track passwordFormat    = false;
	@track buttonDisabled    = true;
	@track emailDisabled     = true;
	@track showErrorMessage  = false;
	@track passwordInputType = "password";

	@track message;
	@track registrationParams;

	@track pageParams;
	_startUrl; //need to persist for after promise

	logoIcon        = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
	cancelIcon      = CSP_PortalPath + 'CSPortal/Images/Icons/cancel_white.svg';
	exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_mark_white.svg';

	labels = {
		emailLabel,
		passwordLabel,
		saveLoginLabel,
		passwordRule1Label,
		passwordRule2Label,
		passwordRule3Label,
		passwordRule4Label,
		createPasswordLabel,
		confirmPasswordLabel,
		changePasswordInfoLabel,
		changePasswordInfo2Label
	};

	get svgURL(){
		return CSP_PortalPath + 'CSPortal/Images/Icons/show_blue.png';
	}

	get isPasswordIconDisabled(){
		return this.password.length > 0 ? false : true;
	}

	connectedCallback() {
		this.pageParams = getParamsFromPage();

		const util = new RegistrationUtils();
		util.getUserLocation().then(result=> {
			if(result.isRestricted){
				navigateToPage(CSP_PortalPath + "restricted-login");
			}
			else{
				util.checkUserIsSystemAdmin().then(result=> {
					//if the use is admin, it means it's already logged. Just send them to the start page
					if(result) this.navigateToStart();
					else{
						//send the encoded part from the URL to the controller. Need to reencode in JS
						//because the getParamsFromPage method decodes it
						getParameters({ encoded : encodeURIComponent(this.pageParams.c) }).then(r => {
							delete this.pageParams.c;
							this.registrationParams = JSON.parse(r.registrationParameters);
							if(r.isUserExist == true){
								this.navigateToStart();
							}
							else if(this.registrationParams['email']){
								this.email     = this.registrationParams['email'];
								this.isExpired = r.isExpired;
								this.changeIsLoading();
							}
						})
					}
				});
			}
		});
	}

	navigateToStart(){
		let startUrl = this.pageParams.startURL;
		delete this.pageParams.startURL;
		navigateToPage(startUrl ? startUrl : CSP_PortalPath,this.pageParams);
	}

	handleShowPassword(){
		if(this.passwordInputType == "password"){
			this.passwordInputType = "text";
		}else{
			this.passwordInputType = "password";
		}
	}

	setButtonDisabled(){
		var submitBtn = this.template.querySelector('[data-id="submitButton"]');
		submitBtn.classList.remove('containedButtonLogin');
		submitBtn.classList.add('containedButtonDisabled');
		this.buttonDisabled = true;
	}

	checkButtonVisibility(){
		var submitBtn        = this.template.querySelector('[data-id="submitButton"]');
		var confirmPassword  = this.template.querySelector('[data-id="confirmPasswordDiv"]');
		if(this.password.length > 0 && this.confirmPassword.length > 0 && this.confirmPassword == this.password && this.passwordFormat == true){
			submitBtn.classList.remove('containedButtonDisabled');
			submitBtn.classList.add('containedButtonLogin');
			this.buttonDisabled = false;
			confirmPassword.classList.remove('slds-has-error');
		}
		else if(this.password.length > 0 && this.confirmPassword.length > 0 && this.confirmPassword != this.password){
			confirmPassword.classList.add('slds-has-error');
		}
		else{
			this.setButtonDisabled();
			confirmPassword.classList.remove('slds-has-error');
		}
	}

	handleConfirmPasswordChange(event){
		this.setButtonDisabled();
		this.confirmPassword = event.target.value;
		this.checkButtonVisibility();
	}

	handlePasswordChange(event){
		this.setButtonDisabled();
		this.password = event.target.value;
		if(this.password.length > 0){
			this.template.querySelector('[data-id="passwordIcon"]').classList.remove('showPasswordIconDisabled');
		}else{
			this.template.querySelector('[data-id="passwordIcon"]').classList.add('showPasswordIconDisabled');
		}

		if (this.password.length >= 10){
			this.template.querySelector('[data-id="chars"]').classList.add("checked");
			this.template.querySelector('[data-id="checkCircleInputChars"]').checked = true;
		} else {
			this.template.querySelector('[data-id="chars"]').classList.remove("checked");
			this.template.querySelector('[data-id="checkCircleInputChars"]').checked = false;
		}

		if (/[A-Z]/.test(this.password)) {
			this.template.querySelector('[data-id="letter"]').classList.add("checked");
			this.template.querySelector('[data-id="checkCircleInputLetter"]').checked = true;
		} else {
			this.template.querySelector('[data-id="letter"]').classList.remove("checked");
			this.template.querySelector('[data-id="checkCircleInputLetter"]').checked = false;
		}

		if (/\d/.test(this.password)) {
			this.template.querySelector('[data-id="number"]').classList.add("checked");
			this.template.querySelector('[data-id="checkCircleInputNumber"]').checked = true;
		} else {
			this.template.querySelector('[data-id="number"]').classList.remove("checked");
			this.template.querySelector('[data-id="checkCircleInputNumber"]').checked = false;
		}

		if (/[\W_]/.test(this.password)) {
			this.template.querySelector('[data-id="symbol"]').classList.add("checked");
			this.template.querySelector('[data-id="checkCircleInputSymbol"]').checked = true;
		} else {
			this.template.querySelector('[data-id="symbol"]').classList.remove("checked");
			this.template.querySelector('[data-id="checkCircleInputSymbol"]').checked = false;
		}

		if(this.password.length >= 10 && /[A-Z]/.test(this.password) && /\d/.test(this.password) && /[\W_]/.test(this.password)) {
			this.passwordFormat = true;
		} else {
			this.passwordFormat = false;
		}

		this.checkButtonVisibility();
	}

	handleSavePassword(){
		this.changeIsLoading();
		if(this.buttonDisabled == false){
			this._startUrl = this.pageParams.startURL;
			//delete the param because, in case of sucess we redirect without this param.
			delete this.pageParams.startURL;
			createUser({
				paramStr : JSON.stringify(this.registrationParams),
				password : this.password,
				landingPage : this._startUrl,
				urlParams : this.pageParams
			}).then(result => {
				if(result.isSuccess){
					navigateToPage(result.message, {});
				}
				else{
					this.pageParams.startURL = this._startUrl; //need to include again so that the resend email can use.
					this.message = errorMessageLabel;
					this.showErrorMessage = true;
				}
			})
			.catch(() => {
				this.message = errorMessageLabel;
				this.showErrorMessage = true;
			});
		}
	}

	handleFormKeyPress(event) {
		if(event.keyCode === 13){
			if(this.buttonDisabled == false){
				this.handleSavePassword();
			}
		}
	}

	changeIsLoading(){
		this.isLoading = !this.isLoading;
	}

	handleSnackbarCancel() {
		this.showErrorMessage = false;
	}

}
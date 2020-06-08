/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track, wire}         from 'lwc';
import { navigateToPage, getParamsFromPage }    from 'c/navigationUtils';
import { getUserInfo }                          from 'c/ipInfo';
import { loadScript, loadStyle }                from 'lightning/platformResourceLoader';
import RegistrationUtils                        from 'c/registrationUtils';

import getConfig                                from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getConfig';
import getUserInformationFromEmail              from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail';
import register                                 from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.simulateRegister';
import getCustomerTypePicklists                 from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists';
import getMetadataCustomerType                  from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getMetadataCustomerType';
import isRestricted                             from '@salesforce/apex/IpInfo.isLocationRestricted';
import isGuest                                  from '@salesforce/user/isGuest';
import getGCSServiceId                          from '@salesforce/apex/ServiceTermsAndConditionsUtils.getPortalServiceId';
import getWrappedTermsAndConditions				from '@salesforce/apex/ServiceTermsAndConditionsUtils.getWrappedTermsAndConditions';

/* ==============================================================================================================*/
/* External Resources
/* ==============================================================================================================*/
import PhoneFormatter16                         from '@salesforce/resourceUrl/PhoneFormatter16';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import Login                                    from '@salesforce/label/c.Login';
import CSP_Email                                from '@salesforce/label/c.CSP_Email';
import CSP_Registration_Description             from '@salesforce/label/c.CSP_Registration_Description';
import CSP_Change_Email                         from '@salesforce/label/c.CSP_Change_Email';
import CSP_Invalid_Email                        from '@salesforce/label/c.CSP_Invalid_Email';
import CSP_Next                                 from '@salesforce/label/c.CSP_Next';
import CSP_User_Creation                        from '@salesforce/label/c.CSP_User_Creation';
import CSP_Registration_Existing_User_Message   from '@salesforce/label/c.CSP_Registration_Existing_User_Message';
import CSP_Privacy_Policy                       from '@salesforce/label/c.CSP_Privacy_Policy';
import CSP_Check_Email                          from '@salesforce/label/c.CSP_Check_Email';
import CSP_Registration_Disabled_Message        from '@salesforce/label/c.CSP_Registration_Disabled_Message';
import CSP_Submit                               from '@salesforce/label/c.CSP_Submit';
import CSP_Success                              from '@salesforce/label/c.CSP_Success';
import CSP_Forgot_Password_Retry_Title          from '@salesforce/label/c.CSP_Forgot_Password_Retry_Title';
import CSP_Registration_Retry_Message           from '@salesforce/label/c.CSP_Registration_Retry_Message';
import CSP_Try_Again                            from '@salesforce/label/c.CSP_Try_Again';
import CSP_Troubleshooting_Info                 from '@salesforce/label/c.CSP_Troubleshooting_Info';
import CSP_Troubleshooting                      from '@salesforce/label/c.CSP_Troubleshooting';
import CSP_Unexcepted_Error                     from '@salesforce/label/c.CSP_Unexcepted_Error';
import CSP_PortalPath                           from '@salesforce/label/c.CSP_PortalPath';
import CSP_L2_Title								from '@salesforce/label/c.CSP_L2_Title';
import ISSP_Registration_MR						from '@salesforce/label/c.ISSP_Registration_MR';
import ISSP_Registration_MRS					from '@salesforce/label/c.ISSP_Registration_MRS';
import ISSP_Registration_MS						from '@salesforce/label/c.ISSP_Registration_MS';
import CSP_L2_Country                           from '@salesforce/label/c.CSP_L2_Country';
import CSP_L1_First_Name                        from '@salesforce/label/c.CSP_L1_First_Name';
import CSP_L1_Last_Name                         from '@salesforce/label/c.CSP_L1_Last_Name';


export default class PortalRegistrationFirstLevel extends LightningElement {

	/* ==============================================================================================================*/
	/* Attributes
	/* ==============================================================================================================*/

	@track isSelfRegistrationEnabled = false;
	@track isRegistrationComplete = false;
	@track displayContactForm = false;
	@track displayTermsAndUsage = false;
	@track userCountry = "";
	@track userCountryCode = "";
	@track selectedCountryFlag = "";
	@track isSanctioned = false;
	@track isLoading = true;
	@track config = {};
	@track userInfo = {}
	@track registrationForm = {
		"email" : "",
		"salutation" : "",
		"firstName" : "",
		"lastName" : "",
		"country" : "",
		"phone" : "",
		"sector" : "",
		"category" : "",
		"extraChoice" : "",
		"language" : "",
		"selectedCustomerType" : "",
		"termsAndUsage" : false,
		"termsAndUsageIds" : "",
		"lmsRedirectFrom" : "",
		"lmsCourse" : ""
	};
	@track errorMessage = "";
	@track displayError = false;
	@track displaySubmitError = false;
	@track isEmailFieldReadOnly = false;
	@track isFrozen = false;
	@track countryOptions = [];
	@track languageOptions = [];
	@track isSelfRegistrationDisabled = false;
	@track salutation = { label : "", options : [], display : false };
	@track sector = { label : "", options : [], display : false };
	@track category = { label : "", options : [], display : false };
	@track extraQuestion = { label : "", options : [], display : false };
	exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_mark_white.svg';
	successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/success.png';
	cancelIcon = CSP_PortalPath + 'CSPortal/Images/Icons/cancel_white.svg';
	@track jsLoaded = false;
	phoneRegExp = /^\(?[+]\)?([()\d]*)$/
	@track rerender = false;
	@track gcsPortalServiceId;


	tcAcceptanceChanged(event){
		var detail = event.detail;
		this.registrationForm.termsAndUsage = detail;
		this._checkForMissingFields();
	}

	_labels = {
		Login,
		CSP_Email,
		CSP_Registration_Description,
		CSP_Change_Email,
		CSP_Invalid_Email,
		CSP_Next,
		CSP_User_Creation,
		CSP_Registration_Existing_User_Message,
		CSP_Privacy_Policy,
		CSP_Check_Email,
		CSP_Registration_Disabled_Message,
		CSP_Submit,
		CSP_Success,
		CSP_Forgot_Password_Retry_Title,
		CSP_Registration_Retry_Message,
		CSP_Try_Again,
		CSP_Troubleshooting_Info,
		CSP_Troubleshooting,
		CSP_Unexcepted_Error,
		CSP_PortalPath,
		CSP_L2_Title,
		ISSP_Registration_MR,
		ISSP_Registration_MRS,
		ISSP_Registration_MS,
		CSP_L2_Country,
		CSP_L1_First_Name,
		CSP_L1_Last_Name
	}

	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	get displayToU(){
		return (this.displayContactForm || this.displayTermsAndUsage);
	}

	@track selectedCustomerType = null;

	@track selectedMetadataCustomerType = {};

	@wire(getCustomerTypePicklists, {leaf:'$selectedCustomerType'})
	getPickLists({ error, data }){
		if (data) {
			let result = JSON.parse(JSON.stringify(data));

			let that = this;

			this.sector = { label : "", options : [], display : false};
			this.category = { label : "", options : [], display : false};
			this.extraQuestion = { label : "", options : [], display : false};

			result.forEach(function (data) {

				let opts = [];
				let obj = {};

				data.picklistOptions.forEach(function (data) {
						opts.push({ 'label': data.label, 'value': data.key });
				});

				obj.label = data.picklistLabel;
				obj.options = opts;
				obj.display = true;

				if(data.picklistName == "Sector"){
					that.sector = obj;
				}else if(data.picklistName == "Category"){
					that.category = obj;
				}else{
					that.extraQuestion = obj;
				}

			});
		} else if (error) {
			console.error('error: ', JSON.parse(JSON.stringify(error)));
		}
		this.isLoading = false;
	}

	@wire(getMetadataCustomerType, {customerTypeKey:'$selectedCustomerType'})
	getCustomerType({ error, data }) {
		if (data) {
			let result = JSON.parse(JSON.stringify(data));
			this.selectedMetadataCustomerType = result;

		} else if (error) {
			console.error('error: ', error);
		}
	}

	/* ==============================================================================================================*/
	/* Lifecycle Hooks
	/* ==============================================================================================================*/

	connectedCallback() {

		// get user IP and Location from ipinfo.io
		// check if country or region is restricted
		// and redirect to sanction country page if it is
		getUserInfo()
		.then(locationData => {
			this.userCountryCode = locationData.country; //used later on the _initializePhoneInput
			return isRestricted({ location : locationData });
		})
		.then(restricted => {
			if(restricted) navigateToPage(CSP_PortalPath + 'restricted-login');
		});
		//no need to catch because nothing happens if it fails

		this._pageParams = getParamsFromPage();

		const utils = new RegistrationUtils();

		utils.checkUserIsSystemAdmin().then(result=> {
			if(!result && !isGuest){
				let startUrl = this._pageParams.startURL;
				delete this._pageParams.startURL;
				navigateToPage(startUrl ? startUrl : CSP_PortalPath,this._pageParams);
			}
		});

		let salutationList = [];
		salutationList.push({ label: '', value: '' });
		salutationList.push({ label: this.labels.ISSP_Registration_MR, value: 'Mr.' });
		salutationList.push({ label: this.labels.ISSP_Registration_MRS, value: 'Mrs.' });
		salutationList.push({ label: this.labels.ISSP_Registration_MS, value: 'Ms.' });
		this.salutation.options = salutationList;
		this.salutation.label = this.labels.CSP_L2_Title;

		Promise.all([
			loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
			loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css')
		]).then(function(){
			this.jsLoaded = true;

			//getConfig
			getConfig().then(result => {
				let config = JSON.parse(JSON.stringify(result));

				this.config = config;
				this._formatCountryOptions(config.countryInfo.countryList);
				this.languageOptions = config.languageList;
				this.isSelfRegistrationEnabled = config.isSelfRegistrationEnabled;
				if(this.isSelfRegistrationEnabled == false){
					this.isSelfRegistrationDisabled = true;
					this.isLoading = false;
				}else{
					//check localStorage
					if (localStorage != undefined && localStorage.length > 0) {
						this._restoreState();
					}else{

						if(this._pageParams){
							if(this._pageParams.language){
								this.registrationForm.language = this._pageParams.language.toLowerCase();;
							}

							getGCSServiceId({portalServiceName:'Login T&C Checker'}).then(result => {
								var gcsPortalServiceId = JSON.parse(JSON.stringify(result));
								this.gcsPortalServiceId = gcsPortalServiceId;

								getWrappedTermsAndConditions({portalServiceId: gcsPortalServiceId, language: this.registrationForm.language}).then(result2 => {
									var tcs = JSON.parse(JSON.stringify(result2));

									var tcIds = [];

									for(let i = 0; i < tcs.length; i++){
										tcIds.push(tcs[i].id);
									}
									this.registrationForm.termsAndUsageIds = tcIds.join();
								});
							});

							if(this._pageParams.email !== undefined){
								this.registrationForm.email = decodeURIComponent(this._pageParams.email);
								this.handleNext();
							}
						}
						if(this._pageParams.startURL){

							let sURL = this._pageParams.startURL;
							console.info('sURL: '+sURL);
							let prmstr = sURL.substring(sURL.lastIndexOf('?') + 1);

							let	paramsMap = prmstr ? decodeURIComponent('{"' + prmstr.replace(new RegExp('&', 'g'), '","').replace(new RegExp('=', 'g'),'":"') + '"}') : '{}';
							let paramsReturn = JSON.parse(paramsMap);

							if(paramsReturn.lms){
								this.registrationForm.lmsRedirectFrom = paramsReturn.lms;
								this.registrationForm.lmsCourse = paramsReturn.RelayState;
								this.registrationForm.lmsCourse = this.registrationForm.lmsCourse.replace(new RegExp('&', 'g'), '@_@').replace(new RegExp('%26', 'g'), '@_@').replace(new RegExp('%2526', 'g'), '@_@');
							}
						}
					}
				}
			})
			.catch(error => {
				console.error('Error: ', error);
				this.isLoading = false;
			});
		}.bind(this));
	}

	/* ==============================================================================================================*/
	/* Event Handlers
	/* ==============================================================================================================*/

	handleFormKeyPress(event){
		if(event.keyCode === 13){
			let submitButton = this.template.querySelector('[data-id="submitButton"]');
			if(submitButton){
				if(submitButton.disabled == false){
					this.handleSubmit();
				}
			}
		}
	}

	handleNavigateToLogin() {

		if(this.userInfo.hasExistingUser && this.registrationForm.email){
			this._pageParams.email = this.registrationForm.email;
			this._pageParams.redirect = 1;
		}

		navigateToPage(CSP_PortalPath + 'login', this._pageParams);
	}

	handleChangeEmail(){
		this.isEmailFieldReadOnly = false;
		this.displayContactForm = false;
		this.displayTermsAndUsage = false;
		this._clearForm(this.registrationForm.email);
		this._showSubmitError(false,"");
	}

	handleEmailChange(event) {
		this.registrationForm.email = event.target.value;
		let nextBtn = this.template.querySelector('[data-id="nextButton"]');
		this._showEmailValidationError(false, "");

		if (this.registrationForm.email !== '' && this.registrationForm.email !== null && this.registrationForm.email.length > 0) {
			nextBtn.classList.remove('containedButtonDisabled');
			nextBtn.classList.add('containedButtonLogin');
			nextBtn.disabled = false;
		} else {
			nextBtn.classList.remove('containedButtonLogin');
			nextBtn.classList.add('containedButtonDisabled');
			nextBtn.disabled = true;
		}

		if(event.keyCode === 13 && !nextBtn.disabled){
			this.handleNext();
		}

	}


	handleNext(){

		this.isLoading = true;
		const RegistrationUtilsJs = new RegistrationUtils();

		RegistrationUtilsJs.checkEmailIsValid(`${this.registrationForm.email}`).then(result=> {

			if(!result){
				this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
				this.isLoading = false;
			}else{
				let anonymousEmail = 'iata' + this.registrationForm.email.substring(this.registrationForm.email.indexOf('@'));
				RegistrationUtilsJs.checkEmailIsDisposable(`${anonymousEmail}`).then(result=> {

					if(result == 'true'){
						//disposable email alert!
						this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
						this.isLoading = false;
					}else{
						//check if the email address is associated to a contact and/or a user
						//1) If there is an existing contact & user with that email -> The user is redirected to the login page,
						//but the "E-Mail" field is pre-populated and, by default, not editable.
						//The user can click a Change E-Mail link to empty the E-Mail field and set it editable again.
						//2) If there is an existing contact but not a user with that email -> Terms and conditions and submit
						//button is displayed on the form.
						getUserInformationFromEmail({ email : this.registrationForm.email, LMSRedirectFrom: this.registrationForm.lmsRedirectFrom}).then(result => {
							let userInfo = JSON.parse(JSON.stringify(result));

							this.userInfo = userInfo;
							if(userInfo.hasExistingContact){
								if(userInfo.hasExistingUser){
									//display message of existing user
									this._showEmailValidationError(true, this.labels.CSP_Registration_Existing_User_Message);
									this.isLoading = false;
								}else{
									//show Terms and Usage field to proceed submit
									this.displayTermsAndUsage = true;
									this.isEmailFieldReadOnly = true;
									this.isLoading = false;
								}
							}else{
								if(userInfo.hasExistingUser){
									//display message of existing user
									this._showEmailValidationError(true, this.labels.CSP_Registration_Existing_User_Message);
									this.isLoading = false;
								}else{
									if(userInfo.isEmailAddressAvailable){
											//show form
										if(this.userCountry){
											this.registrationForm.country = this.userCountry;
										}

										this.displayContactForm = true;
										this.isEmailFieldReadOnly = true;
										this.isLoading = false;
										this._initializePhoneInput();

									}else{
											//inform user to pick another email
										this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
										this.isLoading = false;
									}
								}
							}
						})
						.catch(error => {
							console.error('Error: ', error);
							this.isLoading = false;
						});
					}
				});
			}
		});
	}

	handleSubmit(){

		this.isLoading = true;
		if(this.registrationForm.phone.length < 5){
			this.registrationForm.phone = "";
		}

		let contactId = this.userInfo.contactId;
		let accountId = this.userInfo.accountId;

		register({
			registrationForm : JSON.stringify(this.registrationForm),
			customerType : JSON.stringify(this.selectedMetadataCustomerType),
			contactId : contactId,
			accountId : accountId,
			userInfo : JSON.stringify(this.userInfo),
			urlParams : this._pageParams
		}).then(result => {
			let dataAux = JSON.parse(JSON.stringify(result));

			if(dataAux.isSuccess == true){
				//todo: show success message
				this.isRegistrationComplete = true;
			}else{
				this._showSubmitError(true, 'Error Creating User');
			}

			this.isLoading = false;
		})
		.catch(() => {
			this._showSubmitError(true, 'Error Creating User');
			this.isLoading = false;
		});

	}

	handleCountryChange(event){
		this.registrationForm.country = event.detail.value;
		this._checkForMissingFields();
	}

	handleInputValueChange(event){
		//todo: dynamic input change checker
		let inputName = event.target.name;
		let inputValue = event.target.value;
		this.registrationForm[inputName] = inputValue;
		//todo: if input is required => clear submit error message
		this.template.querySelector('[data-id="' + inputName + 'Div"]').classList.remove('slds-has-error');
		if(this.displaySubmitError){
			if(event.target.required){
				this._showSubmitError(false,"");
			}
		}

		this._checkForMissingFields();

	}

	handlePhoneInputChange(event){
		this.rerender = false;
		let inputValue = event.target.value;
		if(inputValue == ""){
			inputValue = this.selectedCountryFlag;
		}
		let isValid = this.phoneRegExp.test(inputValue);
		if(isValid == false){
			inputValue = inputValue.replace(/[^0-9()+]|(?!^)\+/g, '');
		}
		this.registrationForm.phone = inputValue;
		this.selectedCountryFlag = this.selectedCountryFlag;
		this.rerender = true;
	}

	handlePhoneInputCountryChange(){
		let input = this.template.querySelector('[data-id="phone"]');
		let iti = window.intlTelInputGlobals.getInstance(input);
		let selectedCountry = iti.getSelectedCountryData();
		let countryCode = "";

		if(selectedCountry.dialCode !== undefined){
			countryCode = "+" + selectedCountry.dialCode;
		}else{
			countryCode = this.selectedCountryFlag;
		}
		let inputValue = this.registrationForm.phone;
		let currentPhoneValue = this.registrationForm.phone;
		//check if previous flag selection exists to prevent overriding phone value on page refresh due to language change
		let newPhoneValue = "";
		if(this.selectedCountryFlag){
			if(currentPhoneValue.includes(this.selectedCountryFlag)){
				newPhoneValue = currentPhoneValue.replace(this.selectedCountryFlag, countryCode);
			}else{
				newPhoneValue = countryCode;
			}
		}else{
			newPhoneValue = countryCode;
		}
		this.selectedCountryFlag = countryCode;
		this.registrationForm.phone = newPhoneValue;
	}

	handleSalutationChange(event){
		this.registrationForm.salutation = event.target.value;
		this._checkForMissingFields();
	}


	handleSectorChange(event){

		if(this.selectedCustomerType == event.target.value){
			this._checkForMissingFields();
			this.isLoading = false;
			return;
		}

		this.selectedCustomerType = event.target.value;
		if(this.selectedCustomerType != null){
			//clear error messages
			if(this.displaySubmitError){
				if(event.target.required){
					this._showSubmitError(false,"");
				}
			}
			this.registrationForm.sector = this.selectedCustomerType;
		}else{
			this.registrationForm.sector = "";
		}

		this.registrationForm.selectedCustomerType = this.selectedCustomerType;
		this.registrationForm.category = "";
		this.registrationForm.extraChoice = "";

		this._checkForMissingFields();
	}

	handleCategoryChange(event){

		if(event.target.value == null){
			this.registrationForm.category = "";
			this._checkForMissingFields();
			return;
		}

		if(this.selectedCustomerType == event.target.value){
			this.registrationForm.category = this.selectedCustomerType;
			this._checkForMissingFields();
			return;
		}

		this.selectedCustomerType = event.target.value;
		if(this.selectedCustomerType != null){
			//clear error messages
			if(this.displaySubmitError){
				if(event.target.required){
					this._showSubmitError(false,"");
				}
			}
		}

		this.registrationForm.selectedCustomerType = this.selectedCustomerType;
		this.registrationForm.category = this.selectedCustomerType;

		this._checkForMissingFields();
	}

	handleExtraChoiceChange(event){
		this.isLoading = true;

		if(event.target.value == null){
			this.selectedCustomerType = this.registrationForm.sector;
			this.registrationForm.selectedCustomerType = this.registrationForm.sector;
			this.registrationForm.extraChoice = "";
			this.registrationForm.category = "";
			//this.category = {};
			this.isLoading = false;
			this._checkForMissingFields();
			return;
		}

		if(this.selectedCustomerType == event.target.value){
			this._checkForMissingFields();
			this.isLoading = false;
			return;
		}

		this.selectedCustomerType = event.target.value;
		if(this.selectedCustomerType != null){
			//clear error messages
			if(this.displaySubmitError){
				if(event.target.required){
					this._showSubmitError(false,"");
				}
			}
		}

		this.registrationForm.selectedCustomerType = this.selectedCustomerType;
		this.registrationForm.extraChoice = this.selectedCustomerType;
		this.registrationForm.category = "";

		this._checkForMissingFields();
	}

	handleCustomerTypeChange(event) {

		this.selectedCustomerType = event.target.value;
		if(this.selectedCustomerType == '- Select -'){
			this.selectedCustomerType = null;
		}else{
			if(this.displaySubmitError){
				if(event.target.required){
					this._showSubmitError(false,"");
				}
			}
		}

		this.registrationForm.selectedCustomerType = this.selectedCustomerType;

	}

	handlePreferredLanguageChange(event){
		this.registrationForm.language = event.target.value;
	}

	handleLanguageChange(event){

		this.isLoading = true;
		this.registrationForm.language = event.detail;
		let search = location.search;
		let param = new RegExp('language=[^&$]*', 'i');
		if(~search.indexOf('language')){
			search = search.replace(param, 'language=' + this.registrationForm.language );
		}else{
			if(search.length > 0) search += '&';
			search += 'language='+this.registrationForm.language;
		}
		//todo save current state on local session & refresh page
		if(this.registrationForm.email.length > 0){
			let registrationState = {
				registrationForm : this.registrationForm,
				isEmailFieldReadOnly : this.isEmailFieldReadOnly,
				displayContactForm : this.displayContactForm,
				displayTermsAndUsage : this.displayTermsAndUsage,
				sector : this.sector,
				category : this.category,
				extraQuestion : this.extraQuestion,
				selectedCustomerType : this.selectedCustomerType,
				selectedMetadataCustomerType : this.selectedMetadataCustomerType,
				userCountry : this.userCountry,
				userCountryCode : this.userCountryCode,
				selectedCountryFlag : this.selectedCountryFlag,
				isRegistrationComplete : this.isRegistrationComplete,
				userInfo : this.userInfo
			};

			localStorage.setItem("registrationState", JSON.stringify(registrationState));
		}
		location.search = search;
	}

	handleSnackbarCancel(){
		this.errorMessage = "";
		this.displaySubmitError = false;
	}


	/* ==============================================================================================================*/
	/* Helper Methods
	/* ==============================================================================================================*/

	_showEmailValidationError(state, message){
		let emailDiv = this.template.querySelector('[data-id="emailDiv"]');
		this.errorMessage = message;
		this.displayError = state;

		if(state == true){
			emailDiv.classList.add('slds-has-error');
		}else{
			emailDiv.classList.remove('slds-has-error');
		}
	}

	_showSubmitError(state, message){
		this.errorMessage = message;
		this.displaySubmitError = state;

		if(state == true){
			let scrollobjective = this.template.querySelector('[data-id="snackbar"]');
			scrollobjective.scrollIntoView({ behavior: 'smooth' });
		}
	}

	_formatCountryOptions(options){
		let dataList = JSON.parse(JSON.stringify(options));
		let optionList = [];
		//optionList.push({ 'label': '', 'value': '' });
		dataList.forEach(function (data) {
			optionList.push({ 'label': data.Name, 'value': data.Id });
		});
		this.countryOptions = optionList;
	}

	_clearForm(email){

		if(email == null ){
			email = "";
		}

		this.registrationForm = {
			"email" : email,
			"firstName" : "",
			"lastName" : "",
			"country" : "",
			"phone" : "",
			"sector" : "",
			"category" : "",
			"extraChoice" : "",
			"language" : this.registrationForm.language,
			"selectedCustomerType" : "",
			"termsAndUsage" : false,
			"termsAndUsageIds" : ""
		};

		this.selectedCustomerType = null;
		this.selectedMetadataCustomerType = null;

	}

	_restoreState(){
		let registrationState = JSON.parse(localStorage.getItem("registrationState"));
		localStorage.removeItem("registrationState");

		this.registrationForm = registrationState.registrationForm;
		this.isEmailFieldReadOnly = registrationState.isEmailFieldReadOnly;
		this.displayContactForm = registrationState.displayContactForm;
		this.displayTermsAndUsage = registrationState.displayTermsAndUsage;
		this.selectedCustomerType = registrationState.selectedCustomerType;
		//this.sector = registrationState.sector;
		//this.category = registrationState.category;
		//this.extraQuestion = registrationState.extraQuestion;
		this.selectedMetadataCustomerType = registrationState.selectedMetadataCustomerType;
		this.userCountry = registrationState.userCountry;
		this.userCountryCode = registrationState.userCountryCode;
		this.selectedCountryFlag = registrationState.selectedCountryFlag;
		this.isRegistrationComplete = registrationState.isRegistrationComplete;
		this.userInfo = registrationState.userInfo;
		if(this.isRegistrationComplete == false){
			this._checkForMissingFields();
		}
		this.isLoading = false;

		if(this.displayContactForm){
			this._initializePhoneInput();
		}

	}

	async _checkForMissingFields(){

		let isValid = true;
		let form = this.registrationForm;
		if(this.userInfo.hasExistingContact == true){
			if(form.email.length < 1 || form.termsAndUsage != true){
				isValid = false;
			}
		}else{
			if(form.email.length < 1 || form.firstName.length < 1 || form.lastName.length < 1 || form.language.length < 1
				|| form.termsAndUsage != true || form.sector.length < 1 || form.salutation.length < 1){
					isValid = false;
			}

			if(form.sector == 'General_Public_Sector' && form.extraChoice.length < 1){
				isValid = false;
			}

		}

		await (this.template.querySelector('[data-id="submitButton"]'));
		let submitButton = this.template.querySelector('[data-id="submitButton"]');
		if(isValid == true){
			if(submitButton.disabled == true){
				submitButton.classList.remove('containedButtonDisabled');
				submitButton.classList.add('containedButtonLogin');
				submitButton.disabled = false;
			}
		}else{
			submitButton.classList.remove('containedButtonLogin');
			submitButton.classList.add('containedButtonDisabled');
			submitButton.disabled = true;
		}

	}
	/*
	async _renderSubmitButton(state){
		await (this.template.querySelector('[data-id="submitButton"]'));
		let submitButton = this.template.querySelector('[data-id="submitButton"]');
		if(state == true){
			submitButton.classList.remove('containedButtonDisabled');
			submitButton.classList.add('containedButtonLogin');
			submitButton.disabled = false;
		}else{
			submitButton.classList.remove('containedButtonLogin');
			submitButton.classList.add('containedButtonDisabled');
			submitButton.disabled = true;
		}
		if(this.displayContactForm){
			this._initializePhoneInput();
		}
	}
	*/

	async _initializePhoneInput(){

		await(this.jsLoaded);
		await(this.template.querySelector('[data-id="phone"]'));

		let input = this.template.querySelector('[data-id="phone"]');
		let countryCode = this.userCountryCode;

		let iti = window.intlTelInput(input,{
			initialCountry: countryCode,
			preferredCountries: [countryCode],
			placeholderNumberType : "FIXED_LINE",
			//utilsScript: this.utilsPath,
			/*autoPlaceholder : "aggressive"*/
		});

		let selectedCountryData = iti.getSelectedCountryData();

		if(!this.selectedCountryFlag){
			this.selectedCountryFlag = "+" + selectedCountryData.dialCode;
			this.registrationForm.phone = "+" + selectedCountryData.dialCode;
		}

		input.addEventListener("countrychange", this.handlePhoneInputCountryChange.bind(this));
	}

}
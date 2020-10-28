import { LightningElement,track,wire } from 'lwc';

import getCountries                             from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getISOCountries';
import submitCase                             from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.submitTroubleshootingCase';

import { NavigationMixin } from 'lightning/navigation';

import { navigateToPage } from'c/navigationUtils';
import CSP_PortalPath                           from '@salesforce/label/c.CSP_PortalPath';
import CSP_L2_Country                           from '@salesforce/label/c.CSP_L2_Country';
import CSP_L1_First_Name                        from '@salesforce/label/c.CSP_L1_First_Name';
import CSP_L1_Last_Name                         from '@salesforce/label/c.CSP_L1_Last_Name';
import CSP_Email                                from '@salesforce/label/c.CSP_Email';
import CSP_LeadCreator_AfterSubmitMessage       from '@salesforce/label/c.CSP_LeadCreator_AfterSubmitMessage';
import CSP_LeadCreator_ContactPreference_label  from '@salesforce/label/c.CSP_LeadCreator_ContactPreference_label';
import CSP_LeadCreator_SubTitle                 from '@salesforce/label/c.CSP_LeadCreator_SubTitle';
import CSP_LeadCreator_ThankYou                 from '@salesforce/label/c.CSP_LeadCreator_ThankYou';
import CSP_LeadCreator_Title                    from '@salesforce/label/c.CSP_LeadCreator_Title';
import Phone                                    from '@salesforce/label/c.Phone';
import csp_CaseCreatedSuccess                   from '@salesforce/label/c.csp_CaseCreatedSuccess';
import csp_CaseBeingWorked                      from '@salesforce/label/c.csp_CaseBeingWorked';
import csp_CaseResponseGuarantee                from '@salesforce/label/c.csp_CaseResponseGuarantee';
import CSP_CaseNumber                           from '@salesforce/label/c.CSP_CaseNumber';
import csp_CaseTracking                         from '@salesforce/label/c.csp_CaseTracking';
import CSP_TroubleshootingForm                  from '@salesforce/label/c.CSP_TroubleshootingForm';
import CSP_TroubleshootingFormSubtitle          from '@salesforce/label/c.CSP_TroubleshootingSbtitle';
import CSP_TroubleshootingType                  from '@salesforce/label/c.CSP_TroubleshootingType';
import CSP_TroubleshootingDesc                  from '@salesforce/label/c.CSP_TroubleshootingDesc';
import CSP_Password                             from '@salesforce/label/c.CSP_Password';
import CSP_Login                                from '@salesforce/label/c.CSP_Login';
import CSP_Registration                         from '@salesforce/label/c.CSP_Registration';
import CSP_Go_to_FAQ                            from '@salesforce/label/c.CSP_Go_to_FAQ';
import CSP_Submit                               from '@salesforce/label/c.CSP_Submit';

import PhoneFormatter16                         from '@salesforce/resourceUrl/PhoneFormatter16';
import { loadScript, loadStyle }                from 'lightning/platformResourceLoader';
import RegistrationUtils                        from 'c/registrationUtils';


 
export default class PortalTroubleshootingForm extends NavigationMixin(LightningElement) {

    @track labels={
        CSP_L2_Country,
        CSP_LeadCreator_AfterSubmitMessage,
        CSP_LeadCreator_ContactPreference_label,
        CSP_LeadCreator_SubTitle,
        CSP_LeadCreator_ThankYou,
        CSP_LeadCreator_Title,
        CSP_L1_First_Name,
        CSP_L1_Last_Name,
        CSP_Email,
        csp_CaseCreatedSuccess,
        csp_CaseBeingWorked,
        csp_CaseResponseGuarantee,
        CSP_CaseNumber,
        csp_CaseTracking,
        CSP_TroubleshootingForm,
        CSP_TroubleshootingFormSubtitle,
        Phone,
        CSP_TroubleshootingType,
        CSP_TroubleshootingDesc,
        CSP_Password,
        CSP_Login,
        CSP_Registration,
        CSP_Go_to_FAQ,
        CSP_Submit
    }

    @track form={
        firstName:'',
        lastName:'',
        email:'',
        phone:'',
        country:'',
        type:'',
        descr:''
    };

    @track caseNumber='';
    @track showConfirmBox=false;

    
    @track issueTypeOptions=[{
        value:'Login',
        label: this.labels.CSP_Login+'/'+this.labels.CSP_Password
    },{
        value:'Registration',
        label:this.labels.CSP_Registration
    }];
    
    
    numberValid=false;  
    isLoading=false;  
    phoneRegExp = /^\(?[+]\)?([()\d]*)$/;
    
    @wire(getCountries,{})
    countryData(result){
        
        if(result.data){
            let optionList = [];
            result.data.countryList.forEach(function (data) {
                optionList.push({ 'label': data.Name, 'value': data.Name });
            });
            this.countryOptions = optionList;
        }
    }

    @track showForm=false;



    connectedCallback(){
        const RegistrationUtilsJs = new RegistrationUtils();

        Promise.all([
            loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
            loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css')
        ]).then(function(){			

            RegistrationUtilsJs.getUserLocation().then(result=> {				
                this.userCountryCode = result.countryCode;
                this.userCountry = result.countryId;
                
            });

        }.bind(this));   
    }

    handlePhoneInputChange(event){
        let inputValue = event.target.value;
        if(inputValue == ""){
            inputValue = this.selectedCountryFlag;
        }
        let isValid = this.phoneRegExp.test(inputValue);
        if(isValid == false){
            inputValue = inputValue.replace(/[^0-9()+]|(?!^)\+/g, '');
        }
        
        this.form.phone = inputValue;
        this.selectedCountryFlag = this.selectedCountryFlag;

        this.numberValid=this.selectedCountryFlag!=this.form.phone;
        event.target.value=inputValue;
        this.handleInputValueChange(event);
        event.preventDefault();
        event.stopPropagation();
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

        let currentPhoneValue = this.form.phone;
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
        this.form.phone = newPhoneValue;
    }

    async _initializePhoneInput(){

		await(this.jsLoaded == true);
		await(this.template.querySelector('[data-id="phone"]'));

		let input = this.template.querySelector('[data-id="phone"]');
		let countryCode = this.userCountryCode;

        let iti = window.intlTelInput(input,{
			initialCountry: countryCode,
			preferredCountries: [countryCode],
			placeholderNumberType : "FIXED_LINE"
		});

        let selectedCountryData = iti.getSelectedCountryData();

        if(!this.selectedCountryFlag){
            this.selectedCountryFlag = "+" + selectedCountryData.dialCode;
            this.form.phone = "+" + selectedCountryData.dialCode;
        }
        
        input.addEventListener("countrychange", this.handlePhoneInputCountryChange.bind(this));
    }

    toggleForm(){
        this.template.querySelector("[data-arrow]").classList.toggle('rotateIcon180Deg');
        this.template.querySelector("[data-form]").classList.toggle('slds-hide');
        this.showForm=!this.showForm;
        if(this.showForm){
            let offset= window.pageYOffset+this.template.querySelector("[data-form]").getBoundingClientRect().top;
            window.scrollTo(0,offset);
            this._initializePhoneInput();
        }
    } 

    handleInputValueChange(event){
        let inputName = event.target.name;
        let inputValue = event.target.value;
        this.form[inputName] = inputValue;       

        this._checkForMissingFields();

    }
    
    _checkForMissingFields(){
        let isValid = true;
        if( this.form.firstName.length < 1 || this.form.lastName.length < 1
            || this.form.descr.length < 1 ||  this.form.country.length < 1|| this.form.type.length < 1 || this.form.email.length < 1 || !this.numberValid){
                isValid = false;
        }
      
       
        let submitbtn=this.template.querySelector('[data-submitbtn]');

        if(isValid){
            submitbtn.classList.add('containedButtonLogin');
            submitbtn.classList.remove('containedButtonDisabled');
            submitbtn.disabled = false;
            submitbtn.title='';
        }else{
            submitbtn.classList.remove('containedButtonLogin');
            submitbtn.classList.add('containedButtonDisabled');
            submitbtn.disabled = true;
            submitbtn.title='Please select fill in all fields.';

        }
		

    }

    handleSubmit(){       
        let param=JSON.stringify(this.form);
        this.isLoading=true;
        submitCase({CaseInfo:param})
        .then(result=>{
            this.caseNumber=result;
            this.showConfirmBox=true;
            this.isLoading=false;

        })
    }

    navigateToPkb(event){

        let params = {};
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: 'home'
            }})
        .then(url => navigateToPage(url, params));
    }



}
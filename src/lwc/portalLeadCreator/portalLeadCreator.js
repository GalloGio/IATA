import { LightningElement,track,wire } from 'lwc';

import getCountries                             from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getISOCountries';
import handleContactRequest                     from '@salesforce/apex/PortalLeadCreatorController.handleContactRequest';
import getCurrentUserInfo                            from '@salesforce/apex/CSP_Utils.getCurrentUserInfo';
import getRecomendationDetails                  from '@salesforce/apex/PortalRecommendationCtrl.getRecomendationDetails';
 
import PhoneFormatter16                         from '@salesforce/resourceUrl/PhoneFormatter16';
import { loadScript, loadStyle }                from 'lightning/platformResourceLoader';
import { getUserInfo }                          from 'c/ipInfo';


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
import Company                                  from '@salesforce/label/c.csp_My_Profile_Company';
import Phone                                    from '@salesforce/label/c.Phone';


export default class PortalLeadCreator extends LightningElement {

     constructor() {
        super();
        let self = this;
        window.addEventListener('scroll', function (e) { 
            let elem=self.template.querySelector("[data-form]");
            let boudingClient=elem?elem.getBoundingClientRect():elem;
            if(boudingClient){
                
                let topPos=boudingClient.top;
                let botPos=boudingClient.bottom;

                if(window.pageYOffset/document.documentElement.offsetHeight>0.2){
                    self.renderMin=true;
                }
                if(self.renderMin){

                    if(topPos<200 && botPos>200){
                        self.template.querySelector("[data-section='btn']").classList.add('slds-hide');
                        
                    }else{
                        self.template.querySelector("[data-section='btn']").classList.remove('slds-hide');
                    }
                }
            }
        
        }); 
    } 

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
        Phone,
        Company
    }


  renderMin=false;
    @track countryOptions=[];
    @track contactMethodOptions=[{
        value:'Phone',
        label:'Phone'
    },{
        value:'Email',
        label:'Email'
    }];
    firstName='';
    @track lastName='';
    @track phone='';
    @track email='';
    @track method='';
    @track tc=false;
    @track userCountryCode;
    @track userCountry;
    @track selectedCountryFlag;
    @track submitted=false;
    @track isLoading=false;
    @track renderCmp=false;
    @track serviceId;
    phoneRegExp = /^\(?[+]\)?([()\d]*)$/;
    
   

    @track form={
        firstName:'',
        lastName:'',
        email:'',
        company:'',
        phone:'',
        country:'',
        method:'Phone',
        recommendation:''
    };
   
    numberValid=false;   

    @track callIcon=  CSP_PortalPath + 'CSPortal/Images/Icons/call.svg';


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

    connectedCallback(){
        this.form.recommendation=window.location.pathname.substring(location.pathname.lastIndexOf("/") + 1);


        getRecomendationDetails({urlName:this.form.recommendation}).then(val=>{
            this.serviceId=val.PortalService__c;
            this.renderCmp=val.Is_Contact_Request_Visible__c;


            Promise.all([
                loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
                loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css')
            ]).then(function(){			
    
                getUserInfo().then(result=> {				
                    this.userCountryCode = result.country;//used later on the _initializePhoneInput
                    this._initializePhoneInput();
                });
    
            }.bind(this));    
        });
		

        getCurrentUserInfo()
        .then(val=>{
            if(val!=null){

                this.form.firstName=val.Contact.FirstName?val.Contact.FirstName:'';
                this.form.lastName=val.Contact.LastName?val.Contact.LastName:'';            
                this.form.email=val.Contact.Email?val.Contact.Email:'';
                this.form.country=val.Contact.ISO_Country_Formula__c?val.Contact.ISO_Country_Formula__c:'';
                this.form.company=val.Contact.Account.Name?val.Contact.Account.Name:'';
                this.handlePhoneInputCountryChange();
            }
        })
        .catch(error=>{
           
        });   
    }


    gotoSection(){
        let offset= window.pageYOffset+this.template.querySelector("[data-form]").getBoundingClientRect().top;
        window.scrollTo(0,offset);
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

    handleInputValueChange(event){
        let inputName = event.target.name;
        let inputValue = event.target.value;
        this.form[inputName] = inputValue;       

        this._checkForMissingFields();

	}

    

    changeContactMethod(e){
        e.stopPropagation();
        this.form['Preferred_Form_of_Contact__c']=e.target.value;
        this._checkForMissingFields();
    }

    changeTerms(e){
        e.preventDefault();
        this.tc=e.detail;
        this._checkForMissingFields();

    }


    
    _checkForMissingFields(){
        let isValid = true;
        if( this.form.firstName.length < 1 || this.form.lastName.length < 1 || this.form.company.length <1
            || this.tc != true ||  this.form.country.length < 1|| this.form.method.length < 1 || this.form.email.length < 1){
                isValid = false;
        }

        if(this.form.method =='Phone' && !this.numberValid){
            isValid=false;
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
        this.isLoading=true;
        if(!this.numberValid){
            this.form.phone=' ';
        }
        handleContactRequest({params:JSON.stringify(this.form)})
        .then(val=>{


            this.submitted=true;
            this.isLoading=false;
        }).catch(error=>{
            this.isLoading=false;

        });
    }

    
    
}
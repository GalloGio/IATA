import { LightningElement, api, track } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';
import { getParamsFromPage } from 'c/navigationUtils';

import isTidsAccount from '@salesforce/apex/PortalProfileCtrl.isTidsAccount';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';
import goToPrivacyPortal from '@salesforce/apex/PortalProfileCtrl.goToPrivacyPortal';
import getAccountDomains from '@salesforce/apex/PortalProfileCtrl.getAccountDomains';
import checkIfIsAirlineUser from '@salesforce/apex/CSP_Utils.isAirlineUser';
import checkHasAccessToAccred from '@salesforce/apex/DAL_WithoutSharing.hasAccessToService'; // check if user has access to IATA Accreditation and changes
import getMapHierarchyAccounts from '@salesforce/apex/PortalProfileCtrl.getMapHierarchyAccounts';
import getPhotoFromAPI from '@salesforce/apex/PortalProfileCtrl.getPhotoFromAPI';
import isCountryEligibleForPaymentLink from '@salesforce/apex/PortalProfileCtrl.isCountryEligibleForPaymentLink'; //WMO-699 - ACAMBAS
import paymentLinkRedirect from '@salesforce/apex/PortalServicesCtrl.paymentLinkRedirect'; //WMO-699 - ACAMBAS
import hasAccessToSIS from '@salesforce/apex/DAL_WithoutSharing.hasAccessToService'; //WMO-736 - ACAMBAS
import getPortalServiceDetails from '@salesforce/apex/PortalServicesCtrl.getPortalServiceDetails'; //WMO-736 - ACAMBAS

import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';
import MembershipFunction from '@salesforce/label/c.csp_MembershipFunction';
import Area from '@salesforce/label/c.csp_WorkingAreas';
import ServicesTitle from '@salesforce/label/c.CSP_Services_Title';
import InvalidValue from '@salesforce/label/c.csp_InvalidPhoneValue';
import CompleteField from '@salesforce/label/c.csp_CompleteField';
import RelocateAccount from '@salesforce/label/c.ISSP_Relocate_Contact';
import CSP_Technology from '@salesforce/label/c.CSP_Technology';
import CSP_FocusAreas from '@salesforce/label/c.CSP_FocusAreas';
import CSP_Categories from '@salesforce/label/c.CSP_Categories';
import CSP_ForMoreInfo from '@salesforce/label/c.CSP_ForMoreInfo';
import Edit from '@salesforce/label/c.Edit';
import CSP_EditTrainingDetails from '@salesforce/label/c.CSP_EditTrainingDetails';

import IdCard from '@salesforce/label/c.CSP_Id_Card';
import IdCardNumber from '@salesforce/label/c.CSP_IDCard_Ver_Number';
import IdCardValidTo from '@salesforce/label/c.CSP_IDCard_Valid_To';
import IdCardPhoto from '@salesforce/label/c.CSP_IDCard_Photo';
import IdCardPhotoTitle from '@salesforce/label/c.CSP_IDCard_Photo_Title';
import IdCardName from '@salesforce/label/c.CSP_IDCard_Name';
import IdCardStatus from '@salesforce/label/c.CSP_IDCard_Status';
import CSP_Error_Message_Mandatory_Fields_Contact from '@salesforce/label/c.CSP_Error_Message_Mandatory_Fields_Contact';
import LastLoginDate from '@salesforce/label/c.csp_LastLoginDate';
import CompanyInformation_EMADOMVAL_Title from '@salesforce/label/c.ISSP_CompanyInformation_EMADOMVAL_Title';

import remove from '@salesforce/label/c.Button_Remove';
import contact from '@salesforce/label/c.ISSP_Contact';

import CompanyInformation from '@salesforce/label/c.ISSP_CompanyInformation';
import CSP_CompanyAdministration_Link from '@salesforce/label/c.CSP_CompanyAdministration_Link';
import CSP_Travel_Agent_Accreditation_Changes_Access from '@salesforce/label/c.CSP_Travel_Agent_Accreditation_Changes_Access';
import CSP_Travel_Agent_Accreditation_Changes_Request from '@salesforce/label/c.CSP_Travel_Agent_Accreditation_Changes_Request';
import CSP_Airline_Changes_Access from '@salesforce/label/c.CSP_Airline_Changes_Access';
import See_Bank_Account_Details from '@salesforce/label/c.See_Bank_Account_Details'; //WMO-699 - ACAMBAS
import Credit_Card_Payment_Link from '@salesforce/label/c.Credit_Card_Payment_Link'; //WMO-699 - ACAMBAS

// GCSDI
import CSP_L2_Business_Address_Information_LMS from '@salesforce/label/c.CSP_L2_Business_Address_Information_LMS';
import CSP_L2_Country from '@salesforce/label/c.CSP_L2_Country';
import CSP_L2_State from '@salesforce/label/c.CSP_L2_State';
import CSP_L2_City from '@salesforce/label/c.CSP_L2_City';
import CSP_L2_Postal_Code from '@salesforce/label/c.CSP_L2_Postal_Code';
import CSP_L2_PO_Box_Number from '@salesforce/label/c.CSP_L2_PO_Box_Number';
import CSP_L2_Street from '@salesforce/label/c.CSP_L2_Street';
import CSP_L3_PersonalEmail_LMS from '@salesforce/label/c.CSP_L3_PersonalEmail_LMS';
import CSP_L_WorkPhone_LMS from '@salesforce/label/c.CSP_L_WorkPhone_LMS';

// TIDS
import TIDS_Redirect_Message from '@salesforce/label/c.TIDS_Redirect_Message';
import TIDS_Redirect_Link from '@salesforce/label/c.TIDS_Redirect_Link';


export default class PortalRecordFormWrapper extends NavigationMixin(LightningElement) {
    
    @api sectionClass;
    @api headerClass;
    @api sectionTitle;
    @api sectionName;
    @api editBasics;
    @api editIdcard;
    @api idCardRedirectionUrl;
    @api allowContactDelete=false;

    @api editFields;
    @api recordId;
    @api objectName;
    @api showEditModal = false;
    @api isLoading;
    @api showarea;
    @api services;
    @api showfunction;

    @api relatedAccounts = [];

    @api isForEdit = false;

    @track isLoading = true;
    @track isLoadingEdit = true;
    @track isSaving = false;
    @track areasOptions = [];
    @track selectedvalues = [];
    @track accessibilityText = '';
    @track functionOptions = [];
    @track selectedValuesFunction = [];
    @track fieldsValid = true;
    @track fieldsLocal;
    @track staticFieldsLocal;
    @track jobFunctions;
    @track showEditTrack;
    @track removeContact = false;
    @track idCardErrorPopup = false;
    @track photoURL;
    @track photoPopUp = false;
    @track isEligibleForPaymentLink; //WMO-699 - ACAMBAS
    @track paymentLinkURL; //WMO-699 - ACAMBAS
    @track hasAccessToSISPortal = false; //WMO-736 - ACAMBAS
    @track SISPortalLink; //WMO-736 - ACAMBAS
    @track firstEntry = false;
    @track initialList = [];
    @track isSuccess = false;
    @track iconUrl;
    @track sisPage;
    @track additionalEmail;
    @track otherPhone;
    @track providerId;
    @track logoId;
    @track SHListFields;

    timeout = null;

    @track listSelected = [];
    @track contactTypeStatus = [];

    @track changeUserPortalStatus = false;
    @track openRelocateAccount = false;

    @track hasError = false;
    @track accountEmailDomains = [];
    @track emailDomain = false;
    @track canRelocate = true;
    @api
    get fields(){ return this.fieldsLocal;}
    set fields(value){ this.fieldsLocal = value;}

    @api
    get staticFields(){ return this.staticFieldsLocal;}
    set staticFields(value){
        this.staticFieldsLocal = value;
        if(!this.isTrainingPageLoaded){
            this.connectedCallback();
        }
    }

    _labels = {
        TIDS_Redirect_Link,
        TIDS_Redirect_Message,
        SaveLabel,
        CancelLabel,
        MembershipFunction,
        Area,
        ServicesTitle,
        InvalidValue,
        CompleteField,
        IdCardNumber,
        IdCardValidTo,
        remove,
        contact,
        CSP_Error_Message_Mandatory_Fields_Contact,
        LastLoginDate,
        RelocateAccount,
        CompanyInformation_EMADOMVAL_Title,
        CompanyInformation,
        CSP_Travel_Agent_Accreditation_Changes_Access,
        CSP_Travel_Agent_Accreditation_Changes_Request,
        CSP_Airline_Changes_Access,
        CSP_CompanyAdministration_Link,
        CSP_Technology,
        CSP_FocusAreas,
        CSP_Categories,
        CSP_ForMoreInfo,
        Edit,
        CSP_EditTrainingDetails,
        IdCardName,
        IdCardPhoto,
        IdCardStatus,
        IdCard,
        IdCardPhotoTitle,
        See_Bank_Account_Details,
        Credit_Card_Payment_Link,
        CSP_L2_Business_Address_Information_LMS,
        CSP_L2_Country,
        CSP_L2_State,
        CSP_L2_City,
        CSP_L2_Postal_Code,
        CSP_L2_PO_Box_Number,
        CSP_L2_Street,
        CSP_L3_PersonalEmail_LMS,
        CSP_L_WorkPhone_LMS
    };

    @api tabName;
    @track isTids = false;
    @track isAdminUser = false;
    @track isAirline=false;
    @track linkToDoChanges='';
    
    // GCSDI
    @track isTrainingPageLoaded=false;
    @track isTrainingInfo=false;
    @track trainingId
    @track isPOBox = false;
    selectedCountryId;
    address = {
        'isPoBox':false,
        'countryId':'',
        'countryCode':'',
        'countryName':'',
        'stateId':'',
        'stateName':'',
        'cityId':'',
        'cityName':'',
        'street':'',
        'street2':'',
        'zip':'',
        'validationStatus':0,
        'addressSuggestions':[]
    };

    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }
    
    @api 
    get showEdit(){
        return this.showEditTrack;
    }
    set showEdit(val){
        this.showEditTrack=val;
    }

    emptyStaticServices = 'emptyStaticServices';
    emptyServices = 'emptyServices';

    connectedCallback() {

        let pageParams = getParamsFromPage();
        if(pageParams !== undefined){
            if(pageParams.providerId !== undefined){
                this.providerId = pageParams.providerId;
            }
        }

        if (this.isContact) {
            getPickListValues({ sobj: 'Contact', field: 'Area__c' }).then(result => {
                let options = JSON.parse(JSON.stringify(result));
                let contact1 = JSON.parse(JSON.stringify(this.staticFieldsLocal));
                let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));

                if (contact1.Area__c != null) {

                    let values = contact1.Area__c.split(";");
                    values.forEach(function (value) {
                        options.forEach(function (option) {
                            if (option.label === value) { option.checked = true; selectedV.push(option.value); }
                        });
                    });

                    this.selectedvalues = selectedV;
                }


                this.areasOptions = options;
            });

            //Get membership function values
            getPickListValues({ sobj: 'Contact', field: 'Membership_Function__c' }).then(result => {
                let options = JSON.parse(JSON.stringify(result));
                let contact2 = JSON.parse(JSON.stringify(this.staticFieldsLocal));
                let selectedV = JSON.parse(JSON.stringify(this.selectedValuesFunction));
                let functions = [];

                if (contact2.Membership_Function__c != null) {

                    let userMemFunct = contact2.Membership_Function__c;
                    for(let i=0;i<options.length;i++){
                        if (userMemFunct.indexOf(options[i].value)!=-1){ 
                            options[i].checked = true; 
                            selectedV.push(options[i].value);
                            functions.push(options[i].label);
                        }
                    }
                    this.selectedValuesFunction = selectedV;
                }

                functions.sort();

                this.jobFunctions = functions;
                this.functionOptions = options;
            });

            // GCSDI
            if(this.sectionTitle === 'Training Details'){
                this.isTrainingInfo = true;

                if(this.staticFieldsLocal !== undefined){
                    this.isTrainingPageLoaded = true;
                    let contact3 = JSON.parse(JSON.stringify(this.staticFieldsLocal));
                    this.trainingId = contact3.trainingId;
                    this.selectedCountryId = contact3.shippingCountryRef;
                    this.address.countryId = contact3.shippingCountryRef;
                    this.address.countryName = contact3.shippingCountry;
                    this.additionalEmail = contact3.Additional_Email__c;
                    this.otherPhone = contact3.OtherPhone;



                    // this.address.stateId = this.contactInfo.Shipping_Address__r.State_Reference__c;
                    if(contact3.shippingStateRef !== null &&
                        contact3.shippingStateRef !== undefined &&
                        contact3.shippingStateRef !== '' &&
                        contact3.shippingStateRef.iso_code__c !== null &&
                        contact3.shippingStateRef.iso_code__c !== undefined &&
                        contact3.shippingStateRef.iso_code__c !== ''){

                        this.address.stateId = contact3.shippingStateRef.iso_code__c;
                    }else{
                        this.address.stateId = contact3.shippingState !== undefined? contact3.shippingState : '';
                    }

                    this.address.stateName = contact3.shippingState !== undefined? contact3.shippingState : '';
                    this.address.cityId = contact3.shippingCityRef !== undefined? contact3.shippingCityRef : '';
                    this.address.cityName = contact3.shippingCity !== undefined? contact3.shippingCity : '';

                    this.address.isPoBox = contact3.shippingPOBoxAddress === undefined || contact3.shippingPOBoxAddress === ''? false : true;

                    if(this.address.isPoBox){
                        this.isPOBox = true;
                        this.address.street = contact3.shippingPOBoxAddress !== undefined? contact3.shippingPOBoxAddress : false;
                    }else{
                        this.isPOBox = false;
                        this.address.street = contact3.shippingStreet1 !== undefined? contact3.shippingStreet1 : '';
                    }

                    this.address.street2 = contact3.shippingStreet2 !== undefined? contact3.shippingStreet2 : '';
                    this.address.zip = contact3.shippingPostalCode !== undefined? contact3.shippingPostalCode : '';
                }
            }

        }
        this.isTids=false;
        isTidsAccount().then(result =>{
            this.isTids=result;
        });
        isAdmin().then(result => {
            this.showEditTrack = result && this.showEditTrack;
            if (this.tabName && this._labels.CompanyInformation.trim() === this.tabName.trim()){	
                this.isAdminUser = result;
                this.showEditTrack = true;
                this.editBasics = true;
            }
        });
        checkIfIsAirlineUser().then(result=>{
            this.isAirline = result;
            if(!result){
                
                checkHasAccessToAccred({
                    str:'IATA%Acc%',
                    conId:null
                }).then(result=>{
                    if(result)
                        this.linkToDoChanges =this._labels.CSP_Travel_Agent_Accreditation_Changes_Access;
                    else
                        this.linkToDoChanges =this._labels.CSP_Travel_Agent_Accreditation_Changes_Request;					
                });
            }

        });

        //WMO-699 - ACAMBAS: Begin
        isCountryEligibleForPaymentLink().then(result => {
            this.isEligibleForPaymentLink = result;
        });


        paymentLinkRedirect().then(result => {
            let myUrl;
            if (result !== undefined && result !== '') {
                myUrl = result;
                if (!myUrl.startsWith('http')) {
                    myUrl = window.location.protocol + '//' + myUrl;
                }
            }
            this.paymentLinkURL = myUrl;

            let creditCardPaymentLink = Credit_Card_Payment_Link.replace('{1}', this.paymentLinkURL);
            this._labels.Credit_Card_Payment_Link = creditCardPaymentLink;
        });
        //WMO-699 - ACAMBAS: End

        if(this.isCustomerInvoice){
            //WMO-736 - ACAMBAS: Begin
            let SISPortalService = 'SIS';

            hasAccessToSIS({ str: SISPortalService }).then(result => {
                this.hasAccessToSISPortal = result;

                if(this.hasAccessToSISPortal) {
                    getPortalServiceDetails({ serviceName: SISPortalService }).then(result => {
                        let portalService = JSON.parse(JSON.stringify(result));
                        if (portalService !== undefined && portalService !== '' && portalService.recordService !== undefined && portalService.recordService !== '') {
                            this.iconUrl = portalService.recordService.Application_icon_URL__c;
                            this.sisPage = portalService.recordService.Application_URL__c;
                        }
                    });
                }
            });
            //WMO-736 - ACAMBAS: End
        }

        this.getAccountEmailDomains();
    }
    get showHelpText(){
        return this.isAdminUser;
    }

    get accessibilityGetter() {
        let contactTypeStatus = [];
        let contactType = [];
        let fieldsToIterate = JSON.parse(JSON.stringify(this.fields));
        
        if(!this.firstEntry){
            this.initialList = fieldsToIterate;
            this.firstEntry = true;
        }

        if (fieldsToIterate) {
        fieldsToIterate.forEach(function (item) {
            if (item.isAccessibility) {
                contactType = item.accessibilityList;
                item.accessibilityList.forEach(function (acc) {
                    if (acc.checked) {
                        contactTypeStatus.push(acc.label);
                    }
                });
            }
        });
        }

        this.accessibilityText = contactTypeStatus.join(', ');
        this.contactTypeStatus = contactType;
        this.listSelected = contactTypeStatus;

        return this.accessibilityText;
    }

    openModal() { this.showEditModal = true; }
    
    closeModal() { 
        if(this.sectionName === 'Portal Accessibility' && !this.isSuccess){
            this.fields = this.initialList;
        }
        this.isSuccess = false;
        this.showEditModal = false; 
    }


    closeModalAddress() {

        this.showEditModal = false;
        eval("$A.get('e.force:refreshView').fire();");
    }

    loaded(event) {
        this.isLoading = false;
        let fields = JSON.parse(JSON.stringify(event.detail.objectInfos.Contact.fields));

        if(this.sectionTitle === this._labels.IdCard){
            this.template.querySelector('[data-id="sectionId"]').classList.add('grayBackgroundSection');
        }
    }

    loadedEdit() {
        this.isLoadingEdit = false;
        this.styleInputs();
    }

    handleSucess(event) {
        this.isSaving = false;
        
        if(this.sectionName === 'Portal Accessibility'){
            this.isSuccess = true;
            this.initialList = JSON.parse(JSON.stringify(this.fields));
        }
        
        this.dispatchEvent(new CustomEvent('refreshview'));
        this.closeModal();
        this.updateMembershipFunctions(event.detail);
    }

    handleError(event) {
        if(this.sectionName === 'Portal Accessibility'){
            this.isSuccess = false;       
        }
        this.isSaving = false;
    }

    onRecordSubmit(event) {
        this.isSaving = true;
    }

    get haveEditFields() {
        return this.editFields != null;
    }

    get isContact() {
        return this.objectName != null && this.objectName.toLowerCase() == 'contact';
    }

    get isIHUB() {
        return window.location.pathname.includes('service-startuphotlist');
    }

    //WMO-699 - ACAMBAS: Begin
    get isCustomerInvoice() {
        return this.objectName != null && this.objectName.toLowerCase() == 'customer_invoice__c';
    }

    get displayPaymentLinkLabel() {
        let isCustomerInvoiceObject = this.objectName != null && this.objectName.toLowerCase() == 'customer_invoice__c';
        return this.isEligibleForPaymentLink && isCustomerInvoiceObject;
    }

    get getPaymentLinkURL() {
        return this.paymentLinkURL;
    }
    //WMO-699 - ACAMBAS: End

    get showAreas() {
        return this.showarea;
    }

    get showMembershipFunction() {
        return this.showfunction;
    }

    get removeContactLabel(){
        return this.labels.remove +' '+this.labels.contact;
    }

    removeUser(){
        this.removeContact = true;
        this.changeUserPortalStatus = true;
        this.showEditModal = false;
    }

    updateMembershipFunctions(eventDetail) {
        if(eventDetail.fields.hasOwnProperty('Membership_Function__c')) {
            let functions = [];
            if(eventDetail.fields.Membership_Function__c) {
                const userMemFunct = eventDetail.fields.Membership_Function__c.value;
                let options=this.functionOptions;

                for(let i=0;i<options.length;i++){
                    if (userMemFunct.indexOf(options[i].value)!=-1){                         
                        functions.push(options[i].label);
                    }
                }
            }
            functions.sort();            
            this.jobFunctions = functions;            
        }
    }

    styleInputs() {
        let inputs = this.template.querySelectorAll('lightning-input-field');
        let phoneRegex = /[^0-9+]|(?!^)\+/g;

        let haveEditFields = this.haveEditFields;

        let fields = haveEditFields ? JSON.parse(JSON.stringify(this.editFields)) : JSON.parse(JSON.stringify(this.fields));
        let fieldsChanged = false;
        let numberFields = ['Phone','MobilePhone','Phone_Number__c'];
        let requiredFields = [];
        let skipValidation = false;

        if (inputs) {
            if (inputs.length) {
                for (let i = 0; i < inputs.length; i++) {
                    if (!inputs[i].disabled) {
                        if (inputs[i].value == null || inputs[i].value.length == 0) {

                            if (inputs[i].classList) {
                                inputs[i].classList.add('whiteBackgroundInput');
                            } else {
                                inputs[i].classList = ['whiteBackgroundInput'];
                            }
                        } else {
                            if (inputs[i].classList) {
                                inputs[i].classList.remove('whiteBackgroundInput');
                            }
                        }
                    }
                }
            } else {
                if (!inputs.disabled) {
                    if (inputs.value == null || inputs.value.length == 0) {
                        if (inputs.classList) {
                            inputs.classList.add('whiteBackgroundInput');
                        } else {
                            inputs.classList = ['whiteBackgroundInput'];
                        }
                    } else {
                        if (inputs.classList) {
                            inputs.classList.remove('whiteBackgroundInput');
                        }
                    }
                }
            }
        }
    }

    handleSubmit(event) {
        this.isSaving = true;
        if (this.isContact) {
            event.preventDefault();
            let canSave = true;
            let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));
            let selected = '';
            selectedV.forEach(function (item) { selected += item + ';'; });

            let selectedFunction = JSON.parse(JSON.stringify(this.selectedValuesFunction));
            let selectedF = '';
            selectedFunction.forEach(function (item) { selectedF += item + ';'; });

            let fields = JSON.parse(JSON.stringify(event.detail.fields));
            fields.accountId = this.accountId;

            let contact = JSON.parse(JSON.stringify(this.staticFields));
            if(this.sectionName=='Basics' && contact.ID_Card_Holder__c && (fields.FirstName != contact.FirstName || fields.LastName != contact.LastName || (fields.Birthdate != contact.Birthdate && contact.Birthdate))){
                this.isSaving = false;
                this.closeModal();
                this.idCardErrorPopup = true;
                return;
            }
            else if(contact.ID_Card_Holder__c && !contact.Birthdate && fields.Birthdate){
                contact.Birthdate = fields.Birthdate;
                this.staticFieldsLocal = contact;
            }

            if (selected.length > 0) {
                fields.Area__c = selected;
            }

            fields.Membership_Function__c = selectedF;


            let hasFunctionLocal = this.showfunction;

            if (hasFunctionLocal) {
                if (selectedF.length > 0) {
                    this.hasError = false;
                    this.template.querySelector('.workingAreas').classList.remove('workingAreasError');

                    let inputs = this.template.querySelectorAll('.workingAreasChangeOnError');
                    for (let i = 0; i < inputs.length; i++) {
                        inputs[i].classList.remove('errorOnCheckBox');
                    }

                } else {
                    canSave = false;
                    this.hasError = true;
                    this.template.querySelector('.workingAreas').classList.add('workingAreasError');

                    let inputs = this.template.querySelectorAll('.workingAreasChangeOnError');
                    for (let i = 0; i < inputs.length; i++) {
                        inputs[i].classList.add('errorOnCheckBox');
                    }
                }
            }

            let listSelected = JSON.parse(JSON.stringify(this.listSelected));
            let contactTypeStatusLocal = JSON.parse(JSON.stringify(this.contactTypeStatus));
                
                contactTypeStatusLocal.forEach(function (item) {
                    if (listSelected.includes(item.label)) {
                        fields[item.APINAME] = true;
                        item.checked = true;
                    } else {
                        fields[item.APINAME] = false;
                        item.checked = false;
                    }
                });

                // Update accessibility fields
                this.fields.forEach(function (item) {
                    if (item.isAccessibility) {
                        item.accessibilityList = contactTypeStatusLocal;
                    }
                });

            if (canSave) {
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            } else {
                this.isSaving = false;
            }
        }
    }

    getValueSelected(event) {
        let selected = event.target.dataset.item;
        let type = event.target.dataset.type;
        let isArea = (type == 'Area__c');

        let options = isArea ? JSON.parse(JSON.stringify(this.areasOptions)) : JSON.parse(JSON.stringify(this.functionOptions));
        let selectedV = isArea ? JSON.parse(JSON.stringify(this.selectedvalues)) : JSON.parse(JSON.stringify(this.selectedValuesFunction));

        if (!selectedV.includes(selected)) {
            selectedV.push(selected);
            for (let i = 0; i < options.length; i++) {
                if (options[i].value == selected) {
                    options[i].checked = true; 
                }
            }
            
        } else {
            let index = selectedV.indexOf(selected);
            if (index > -1) {
                selectedV.splice(index, 1);
                for (let i = 0; i < options.length; i++) {
                    if (options[i].value == selected) {
                        options[i].checked = false; 
                    }
                }
            }
        }

        if (isArea) {
            this.areasOptions = options;
            this.selectedvalues = selectedV;
        } else {
            this.functionOptions = options;
            this.selectedValuesFunction = selectedV;
        }
    }

    navigateTo(event) {
        let serviceId = event.target.dataset.id;

        let params = {};
        params.serviceId = serviceId;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "manage-service"
            }
        })
            .then(url => navigateToPage(url, params));

    }

    getValueSelectedTypeStatus(event) {

        let selected = event.target.dataset.item;

        let fieldValue = JSON.parse(JSON.stringify(this.listSelected)); 
        let fieldsToIterate = JSON.parse(JSON.stringify(this.fields)); 
        let contactStatus = [];

        contactStatus = fieldValue;

        if (!fieldValue.includes(selected)) { 
            fieldValue.push(selected);
            fieldsToIterate[1].accessibilityList.forEach(function (option) {
                if (option.label == selected) {      
                    option.checked = true;

                }
            });
         } else {
                for (let i = fieldValue.length - 1; i >= 0; i--) {
                    if (fieldValue[i] === selected) {
                        fieldValue.splice(i, 1);
                        fieldsToIterate[1].accessibilityList.forEach(function (option) {
                            if (option.label == selected) { 
                                option.checked = false;

                            }
                        });
                    }
                }
            }

        this.contactTypeStatus = fieldsToIterate[1].accessibilityList;
        this.listSelected = fieldValue;
        this.contactStatus = fieldValue;
        this.accessibilityText = contactStatus.join(', ');
        this.fields = fieldsToIterate;

    }
    
    opensRelocateAccount() {
        this.checkCanRelocate();
    }
    
    openChangeUserPortalStatus() {
        this.changeUserPortalStatus = true;
    }

    closePortalChangeUserStatus() {
        this.removeContact = false;
        this.changeUserPortalStatus = false;
        this.openRelocateAccount = false;
    }

    closePortalChangeUserStatusWithRefresh() {
        this.dispatchEvent(new CustomEvent('refreshview'));
        this.removeContact = false;
        this.changeUserPortalStatus = false;
        this.openRelocateAccount = false;
    }

    get canSave() {
        return !this.fieldsValid || this.isSaving;
    }

    get canEditBasics() {
        let isRestrictedSection = this.sectionName == 'Basics' || this.sectionName == 'Branch Contact';
        return (this.editBasics && isRestrictedSection && this.showEditTrack) || (!isRestrictedSection && this.showEditTrack);
    }

    get hasIdCard() {
        return (this.staticFieldsLocal !== undefined && this.staticFieldsLocal.cardNumber !== undefined);
    }

    get hasFunction() {
        return this.jobFunctions !== undefined && this.jobFunctions.length > 0;
    }

    get hasServices() {
        return this.services !== undefined && this.services.length > 0;
    }

    get hasStaticServices() {
        return this.staticFieldsLocal !== undefined && this.staticFieldsLocal.services !== undefined && this.staticFieldsLocal.services.length > 0;
    }

    get hasTrainingData() {
        return (this.staticFieldsLocal !== undefined && this.staticFieldsLocal.trainingUserId !== undefined);
    }

    get canEditTraining() {
        return (this.canEditBasics && this.isTrainingInfo) || (!isRestrictedSection && this.showEdit);
    }


    navigateToPrivacyPortal() {
        goToPrivacyPortal({})
            .then(results => {
                window.open(results);
            });
    }

    get accountDomains() {
        return this.accountEmailDomains;
    }

    getAccountEmailDomains() {
        getAccountDomains({ accountId: this.recordId }).then(result => {
            this.accountEmailDomains = result;
        });
    }

    openEmailDomain() {
        this.emailDomain = true;
    }

    closeEmailDomain() {
        this.getAccountEmailDomains();
        this.emailDomain = false;
    }

    checkCanRelocate() {
        let contactId = this.recordId;
        getMapHierarchyAccounts({ contactId: contactId })
        .then(result => {
            this.isLoading = false;
            this.openRelocateAccount = true;
            this.relatedAccounts = JSON.parse(JSON.stringify(result));
        });
    }

    hideIdCardErrorPopup() {
        this.idCardErrorPopup = false;
    }

    redirectToIdCardPortal() {
        if(this.idCardRedirectionUrl  != ''){
           window.location.href = this.idCardRedirectionUrl;
        }
    }

    openPhotoPopUp() {
        if(this.staticFieldsLocal.cardPhoto != ''){
           getPhotoFromAPI({ photoName : this.staticFieldsLocal.cardPhoto})
           .then(result => {
              this.photoURL = result;
              this.photoPopUp = true;
           });
        }
    }

    hideIdCardPhotoPopup() {
        this.photoPopUp = false;
    }

}
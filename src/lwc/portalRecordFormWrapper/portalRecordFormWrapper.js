/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement, api, track } from 'lwc';


//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

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
import goToOldPortalService from '@salesforce/apex/PortalServicesCtrl.goToOldPortalService'; //WMO-736 - ACAMBAS

import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';
import MembershipFunction from '@salesforce/label/c.csp_MembershipFunction';
import Area from '@salesforce/label/c.csp_WorkingAreas';
import ServicesTitle from '@salesforce/label/c.CSP_Services_Title';
import InvalidValue from '@salesforce/label/c.csp_InvalidPhoneValue';
import CompleteField from '@salesforce/label/c.csp_CompleteField';
import RelocateAccount from '@salesforce/label/c.ISSP_Relocate_Contact';

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
import Link_To_SIS from '@salesforce/label/c.Link_To_SIS'; //WMO-736 - ACAMBAS


export default class PortalRecordFormWrapper extends NavigationMixin(LightningElement) {
    
    @api sectionClass;
    @api headerClass;
    @api sectionTitle;
	@api sectionName;
    @api showEdit;
    @api editBasics;
    @api editIdcard;
    @api idCardRedirectionUrl;
    @api allowContactDelete=false;

    @api editFields;
    @api recordId;
    @api objectName;
    @api showEditModal = false;
    @api isLoading;
    @api staticFields;
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
    @track jobFunctions;
    @track removeContact = false;
    @track firstEntry = false;
    @track initialList = [];
    @track isSuccess = false;
    @track idCardErrorPopup = false;
    @track photoURL;
    @track photoPopUp = false;
    @track isEligibleForPaymentLink; //WMO-699 - ACAMBAS
    @track paymentLinkURL; //WMO-699 - ACAMBAS
    @track hasAccessToSISPortal; //WMO-736 - ACAMBAS
    @track SISPortalLink; //WMO-736 - ACAMBAS

    @track iconUrl;
    @track sisPage;


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

    _labels = {
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
        IdCardName,
        IdCardPhoto,
        IdCardStatus,
        IdCard,
        IdCardPhotoTitle,
        See_Bank_Account_Details,
        Credit_Card_Payment_Link
    };

    @api tabName = '';
	@track isAdminUser = false;
	@track isAirline=false;
	@track linkToDoChanges='';
    
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }

    emptyStaticServices = 'emptyStaticServices';
    emptyServices = 'emptyServices';

    connectedCallback() {

        if (this.isContact) {
            getPickListValues({ sobj: 'Contact', field: 'Area__c' }).then(result => {
                let options = JSON.parse(JSON.stringify(result));
                let contact = JSON.parse(JSON.stringify(this.staticFields));
                let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));

                if (contact.Area__c != null) {

                    let values = contact.Area__c.split(";");
                    values.forEach(function (value) {
                        options.forEach(function (option) {
                            if (option.label == value) { option.checked = true; selectedV.push(option.value); }
                        });
                    });

                    this.selectedvalues = selectedV;
                }


                this.areasOptions = options;
            });

            //Get membership function values
            getPickListValues({ sobj: 'Contact', field: 'Membership_Function__c' }).then(result => {
                let options = JSON.parse(JSON.stringify(result));
                let contact = JSON.parse(JSON.stringify(this.staticFields));
                let selectedV = JSON.parse(JSON.stringify(this.selectedValuesFunction));
                let functions = [];

                if (contact.Membership_Function__c != null) {

                    let values = contact.Membership_Function__c.split(";");
                    values.forEach(function (value) {
                        functions.push(value);
                        options.forEach(function (option) {
                            if (option.label == value) { option.checked = true; selectedV.push(option.value); }
                        });
                    });

                    this.selectedValuesFunction = selectedV;
                }

                functions.sort();

                this.jobFunctions = functions;
                this.functionOptions = options;
            });

        }
        
        isAdmin().then(result => {
            this.showEdit = result && this.showEdit;
            if (this._labels.CompanyInformation.trim() === this.tabName.trim()){
				this.isAdminUser = result;
                this.showEdit = true;
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

        //WMO-736 - ACAMBAS: Begin
        let SISPortalService = 'SIS';

        hasAccessToSIS({ str: SISPortalService }).then(result => {
            this.hasAccessToSISPortal = result;

            if(this.hasAccessToSISPortal) {
                getPortalServiceDetails({ serviceName: SISPortalService }).then(result => {
                    let portalService = JSON.parse(JSON.stringify(result));

                    if (portalService !== undefined && portalService !== '') {
                        //let SISIconHTML = portalService.recordService.Application_icon__c;
                        let SISPortalURL = portalService.recordService.Application_URL__c;
                        this.iconUrl = portalService.recordService.Application_icon_URL__c;
                        goToOldPortalService({ myurl: SISPortalURL }).then(result => {
                            //this.SISPortalLink = Link_To_SIS.replace('{1}', SISIconHTML);
                            //this.SISPortalLink = this.SISPortalLink.replace('{2}', result);
                            this.sisPage = result;
                        })
                    }
                });
            }
        });
        //WMO-736 - ACAMBAS: End

        this.getAccountEmailDomains();
    }
	get showHelpText(){
		return this.isAdminUser;
	}

    get accessibilityGetter() {

        let accessibilityTextLocal = '';
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

        accessibilityTextLocal = contactTypeStatus.join(', ');
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
                const values = eventDetail.fields.Membership_Function__c.value.split(";");
                values.forEach( (value) => { functions.push(value); });
            }
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

        /*
        for(let f=0;f<fields.length;f++){
            if(fields[f].isRequired !== undefined && fields[f].isRequired == true){
                requiredFields.push(fields[f].fieldName);
            }
        }

        let fieldsValid = true;

        */

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
                    /*
                    if(requiredFields.includes(inputs[i].fieldName)){
                        if(inputs[i].value === undefined || inputs[i].value.length == 0){
                            skipValidation = true;
                            for(let f = 0;f<fields.length;f++){
                                if(fields[f].fieldName == inputs[i].fieldName){
                                    if(fields[f].missing == null || fields[f].missing == false){
                                        fields[f].missing = true;
                                        fieldsChanged = true;
                                        fieldsValid = false;
                                    }
                                }
                            }
                            inputs[i].classList.add('invalidValue');
                        }else{
                            for(let f = 0;f<fields.length;f++){
                                if(fields[f].fieldName == inputs[i].fieldName){
                                    if(fields[f].missing != null && fields[f].missing == true){
                                        fields[f].missing = false;
                                        fieldsChanged = true;
                                    }
                                    inputs[i].classList.remove('invalidValue');
                                }
                            }
                        }
                    }

                    if(!skipValidation){
                        if(numberFields.includes(inputs[i].fieldName)){
                            if(inputs[i].value != null){
                                let inputValue = inputs[i].value.replace(/ /g,'');
                                let isNotPhone = phoneRegex.test(inputValue);
                                if(isNotPhone){
                                    inputs[i].classList.add('invalidValue');
                                    fieldsValid = false;

                                    for(let f = 0;f<fields.length;f++){
                                        if(fields[f].fieldName == inputs[i].fieldName){
                                            if(fields[f].invalid == null || fields[f].invalid == false){
                                                fields[f].invalid = true;
                                                fieldsChanged = true;
                                            }
                                        }
                                    }

                                }else{
                                    for(let f = 0;f<fields.length;f++){
                                        if(fields[f].fieldName == inputs[i].fieldName){
                                            if(fields[f].invalid != null && fields[f].invalid == true){
                                                fields[f].invalid = false;
                                                fieldsChanged = true;
                                            }
                                        }
                                    }
                                    inputs[i].classList.remove('invalidValue');
                                }
                            }
                        }
                        
                    }*/

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

        /*
        if(fieldsChanged){
            clearTimeout(this.timeout);
            this.timeout = setTimeout(() => {
                if(haveEditFields){
                    this.editFields = fields;
                }else{
                    this.fields = fields;
                }
            },400,this);
        }
        this.fieldsValid = fieldsValid;
        */
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

            let fields = event.detail.fields;
            fields.accountId = this.accountId;

            let contact = JSON.parse(JSON.stringify(this.staticFields));
            if(contact.ID_Card_Holder__c && (fields.FirstName != contact.FirstName || fields.LastName != contact.LastName || (fields.Birthdate != contact.Birthdate && contact.Birthdate))){
                this.isSaving = false;
                this.closeModal();
                this.idCardErrorPopup = true;
                return;
            }
            else if(contact.ID_Card_Holder__c && !contact.Birthdate && fields.Birthdate){
                contact.Birthdate = fields.Birthdate;
                this.staticFields = contact;
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
            options.forEach(function (option) {
                if (option.value == selected) { option.checked = true; }
            });
        } else {
            let index = selectedV.indexOf(selected);
            if (index > -1) {
                selectedV.splice(index, 1);
                options.forEach(function (option) {
                    if (option.value == selected) { option.checked = false; }
                });
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
        return (this.editBasics && isRestrictedSection && this.showEdit) || (!isRestrictedSection && this.showEdit);
    }

    get hasIdCard() {
        return (this.staticFields !== undefined && this.staticFields.cardNumber !== undefined);
    }

    get hasFunction() {
        return this.jobFunctions !== undefined && this.jobFunctions.length > 0;
    }

    get hasServices() {
        return this.services !== undefined && this.services.length > 0;
    }

    get hasStaticServices() {
        return this.staticFields !== undefined && this.staticFields.services !== undefined && this.staticFields.services.length > 0;
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
        if(this.staticFields.cardPhoto != ''){
           getPhotoFromAPI({ photoName : this.staticFields.cardPhoto})
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

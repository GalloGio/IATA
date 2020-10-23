import { LightningElement, track, api, wire } from "lwc";

import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";

import { getSectionInfo, 
  getUserType, 
  sectionNavigation, 
  sectionDecision, 
  displaySaveAndQuitButton, 
  getApplicationType, 
  getPreferedLanguages, 
  specialCharsValidation, 
  emailValidation,
  websiteValidation, 
  getSectionRules,
  getSfTidsInfo,
  CHG_ADDRESS_CONTACT,
  SECTION_CONFIRMED 
} from "c/tidsUserInfo";

export default class TidsContact extends LightningElement {
  @wire(CurrentPageReference) pageRef;

  cmpName = "contact";

  @api tidsUserInfo;
  @track vettingMode;

  @track languages = [];
  @track isSpecialCharacters = false;

  @track preferedLanguage = "ENG";
  @track phone;
  @track phoneCounter = 0;

  @track fax;
  @track faxCounter = 0;

  @track businessEmail;
  @track businessEmailCounter = 0;

  @track webSite;
  @track webSiteCounter = 0;

  @track omFirstName;
  @track omFirstNameCounter = 0;

  @track omLastName;
  @track omLastNameCounter = 0;

  // Vetting Modal - Errors
  @track sectionHasErrors = false;
  @track fieldErrorSelected = {};

  // Modal
  @track openModal = false;
  @track modalDefaultMessage = true;
  @track modalAction = "FIELD";

  // Vetting errors
  @track vettingErrorOptions = false;
  @track vettingErrors = [];

  @track phoneError = {
    show: false,
    description: "",
    fieldName: "phone",
    fieldLabel: "Phone Number"
  };

  @track faxError = {
    show: false,
    description: "",
    fieldName: "fax",
    fieldLabel: "Fax Number"
  };

  @track businessEmailError = {
    show: false,
    description: "",
    fieldName: "businessEmail",
    fieldLabel: "Business Email address"
  };

  @track websiteError = {
    show: false,
    description: "",
    fieldName: "website",
    fieldLabel: "Web Site"
  };

  @track omFirstNameError = {
    show: false,
    description: "",
    fieldName: "omFirstName",
    fieldLabel: "Office Manager - First Name"
  };

  @track omLastNameError = {
    show: false,
    description: "",
    fieldName: "omLastName",
    fieldLabel: "Office Manager - Last Name"
  };

  @track preferedLanguageError = {
    show: false,
    description: "",
    fieldName: "preferedLanguage",
    fieldLabel: "Prefered language of correspondance"
  };

  // New Branch
  @track showSaveAndQuitButton = false;

  // Section fields rules
  @track phoneRules = {
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  }

  @track faxRules = {
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  }

  @track businessEmailRules = {
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  }

  @track websiteRules = {
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  }

  @track omFirstNameRules  = {
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  }

  @track omLastNameRules = {
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  }

  @track preferedLanguageRules = {
    visible: false,
    disabled: false,
    required: false,
    regex:'',
    name:'',
    translation_english:'',
    translation_japanese:'',
    translation_spanish:'',
    translation_portuguese:'',
    translation_french:'',
    translation_chinese:''
  }

  // Const fields API name
  PHONE = 'phone';
  FAX = 'fax';
  BUSINESS_EMAIL = 'businessEmail';
  WEBSITE = 'website';
  OM_FIRST_NAME = 'omFirstName';
  OM_LAST_NAME = 'omLastName';
  PREFERED_LANGUAGE = 'preferedLanguage';

  // Disable report errors and proceed
  @track reportErrorButtonDisabled;

  // Report Changes
  @track preferedLanguageChanges = {
    display: false,
    sfValue: null
  }
  @track phoneChanges = {
    display: false,
    sfValue: null
  }
  @track faxChanges = {
    display: false,
    sfValue: null
  }
  @track businessEmailChanges = {
    display: false,
    sfValue: null
  }
  @track webSiteChanges = {
    display: false,
    sfValue: null
  }
  @track omFirstNameChanges = {
    display: false,
    sfValue: null
  }
  @track omLastNameChanges = {
    display: false,
    sfValue: null
  }

  connectedCallback() {
    // Vetting menu
    registerListener("vettingMenuListener", this.vettingMenuListener, this);
    // Vetting modal listener
    registerListener("modalProceedListener", this.modalProceedListener, this);
    registerListener("modalCloseListener", this.modalCloseListener, this);
    registerListener(
      "modalDeleteAllErrorsListener",
      this.modalDeleteAllErrorsListener,
      this
    );

    this.reportErrorButtonDisabled = true;
    
    let sectionRules = getSectionRules(this.cmpName);
    this.mappingRules(sectionRules);

    this.languages = getPreferedLanguages();

    let userType = getUserType();
    this.vettingMode = userType === "vetting" ? true : false;

    let contactInfo = getSectionInfo(this.cmpName);

    if (contactInfo) {
      this.preferedLanguage = contactInfo.values.preferedLanguage;
      this.phone = contactInfo.values.phone;
      this.fax = contactInfo.values.fax;
      this.businessEmail = contactInfo.values.businessEmail;
      this.webSite = contactInfo.values.webSite;
      this.omFirstName = contactInfo.values.omFirstName;
      this.omLastName = contactInfo.values.omLastName;
      
      this.fieldsCounter();

      this.reportChanges();

      if (
        this.vettingMode &&
        contactInfo.errors !== undefined &&
        contactInfo.errors &&
        contactInfo.errors.length > 0
      ) {
        let er = JSON.parse(JSON.stringify(contactInfo.errors));
        er.forEach(el => {
          this.updateinfoErrors(el);
        });
        this.vettingErrorOptions = true;
        this.sectionHasErrors = this.noFormErrors();
        this.notifySectionHasError();
      }

      this.nextButtonDisabled();
    }

    this.showSaveAndQuitButton = displaySaveAndQuitButton({payload:{applicationType: getApplicationType()}});
  }

  reportChanges() {
    let applicationType = getApplicationType();

    if(applicationType === CHG_ADDRESS_CONTACT && this.vettingMode){
      let sfInfo = getSfTidsInfo();

      if (this.preferedLanguage !== sfInfo.preferredLanguage) {
        this.preferedLanguageChanges.display = true;
        let previousLanguage = this.languages.find(item => item.value === sfInfo.preferredLanguage);
        this.preferedLanguageChanges.sfValue = previousLanguage.label;
      }
      if (this.phone !== sfInfo.phone) {
        this.phoneChanges.display = true;
        this.phoneChanges.sfValue = sfInfo.phone;
      }

      if (this.fax !== sfInfo.fax) {
        this.faxChanges.display = true;
        this.faxChanges.sfValue = sfInfo.fax;
      }

      if (this.businessEmail !== sfInfo.email) {
        this.businessEmailChanges.display = true;
        this.businessEmailChanges.sfValue = sfInfo.email;
      }
      if (this.webSite !== sfInfo.website) {
        this.webSiteChanges.display = true;
        this.webSiteChanges.sfValue = sfInfo.website;
      }
      if (this.omFirstName !== sfInfo.managerFirstName) {
        this.omFirstNameChanges.display = true;
        this.omFirstNameChanges.sfValue = sfInfo.managerFirstName;
      }
      if (this.omLastName !== sfInfo.managerLastName) {
        this.omLastNameChanges.display = true;
        this.omLastNameChanges.sfValue = sfInfo.managerLastName;
      }
    }
  }

  mappingRules(sectionRules) {
    let hasFieldsToValidate;
    sectionRules.forEach(element => {
      if(hasFieldsToValidate === undefined && element.required) {
        hasFieldsToValidate = true;
      }
      switch(element.apiName) {
        case this.PHONE: 
          this.phoneRules = element;
          break;
        case this.FAX: 
          this.faxRules = element;
          break;
        case this.BUSINESS_EMAIL: 
          this.businessEmailRules = element;
          break;
        case this.WEBSITE: 
          this.websiteRules = element;
          break;
        case this.OM_FIRST_NAME: 
          this.omFirstNameRules = element;
          break;
        case this.OM_LAST_NAME: 
          this.omLastNameRules = element;
          break;
        case this.PREFERED_LANGUAGE: 
          this.preferedLanguageRules = element;
          break;
        default: break;
      }
    });
  //  this.disableButton = hasFieldsToValidate === undefined ? false : true;
  }

  vettingMenuListener(props) {
    this.modalAction = "ALL";
    if (this.sectionHasErrors) {
      this.modalDefaultMessage = true;
      this.openModal = true;
    } else {
      this.openModal = false;
      this.vettingErrorOptions = props;
    }
  }

  nextButtonDisabled() {
    let isFormValid = this.fieldsValidation();
    this.disableButton = !isFormValid;
    return isFormValid;
  }
  
  changeField(event) {
    this.isSpecialCharacters = specialCharsValidation(event.target.value);

    if (event.target.name === "preferedLanguage") {
      this.preferedLanguage = event.target.value;
    } else if (event.target.name === "phone") {
      this.phone = event.target.value;
    } else if (event.target.name === "fax") {
      this.fax = event.target.value;
    } else if (event.target.name === "businessEmail") {
      this.businessEmail = event.target.value;
      if(emailValidation(event.target.value)) {
        this.businessEmail = event.target.value;
      }
    } else if (event.target.name === "website") {
      this.webSite = event.target.value;
      if(websiteValidation(event.target.value)) {
        this.webSite = event.target.value;
      }
    } else if (event.target.name === "omFirstName") {
      this.omFirstName = event.target.value;
    } else if (event.target.name === "omLastName") {
      this.omLastName = event.target.value;
    }
    this.fieldsCounter();
  //  this.fieldsValidation();
    if(this.isSpecialCharacters) {
      this.resetValues(event.target.name);
      this.disableButton = true;
    } else {
      this.nextButtonDisabled();
    }
  }

  fieldsCounter() {
    this.phoneCounter = this.phone ? this.phone.length : 0;
    this.faxCounter = this.fax ? this.fax.length : 0;
    this.businessEmailCounter = this.businessEmail ? this.businessEmail.length : 0;
    this.webSiteCounter = this.webSite ? this.webSite.length : 0;
    this.omFirstNameCounter = this.omFirstName ?  this.omFirstName.length : 0;
    this.omLastNameCounter = this.omLastName ? this.omLastName.length : 0;
  }

  resetValues(fieldName) {
    switch(fieldName) {
      case "preferedLanguage":
        this.preferedLanguage = "";
        break;
      case "phone":
        this.phone = "";
        break;
      case "fax":
        this.fax = "";
        break;
      case "businessEmail":
        this.businessEmail = "";
        break;
      case "website":
        this.webSite = "";
        break;
      case "omFirstName":
        this.omFirstName = "";
        break;
      case "omLastName":
        this.omLastName = "";
        break;
      default: break;
    }
  }

  // Fields validation
  fieldsValidation() {
    let result = true;
    // Phone
    if(this.phoneRules.required) {
      result = result && this.phoneValid();
    }

    if(this.faxRules.required) {
      result = result && this.faxValid();
    }

    if(this.businessEmailRules.required) {
      result = result && this.businessEmailValid();
    }

    if(this.websiteRules.required) {
      result = result && this.websiteValid();
    }

    if(this.omFirstNameRules.required) {
      result = result && this.omFirstNameValid();
    }

    if(this.omLastNameRules.required) {
      result = result && this.omLastNameValid();
    }

    if(this.preferedLanguageRules.required) {
      result = result && this.preferedLanguageValid();
    }

    return result;
  }

  phoneValid() {
    let cmpField = this.template.querySelector("[data-name='"+ this.PHONE +"']");
    let isValid = false;
    if(this.phoneRules.required && cmpField) {
      isValid = cmpField.validity.valid;
    } else if(this.phoneRules.required && this.phone){
      isValid = true;
    }
    return isValid;
  }

  faxValid() {
    let cmpField = this.template.querySelector("[data-name='"+this.FAX+"']");
    let isValid = false;
    if(this.faxRules.required && cmpField) {
      isValid = cmpField.validity.valid;
    } else if(this.faxRules.required && this.fax){
      isValid = true;
    }
    return isValid;
  }

  businessEmailValid() {
    let cmpField = this.template.querySelector("[data-name='" + this.BUSINESS_EMAIL +"']");
    let isValid = false;
    if(this.businessEmailRules.required && cmpField) {
      isValid = cmpField.validity.valid;
    } else if(this.businessEmailRules.required && this.businessEmail){
      isValid = true;
    }
    return isValid;
  }

  websiteValid() {
    let cmpField = this.template.querySelector("[data-name='" + this.WEBSITE + "']");
    let isValid = false;
    if(this.websiteRules.required && cmpField) {
      isValid = cmpField.validity.valid;
    } else if(this.websiteRules.required && this.webSite){
      isValid = true;
    }
    return isValid;
  }

  omFirstNameValid() {
    let cmpField = this.template.querySelector("[data-name='"+this.OM_FIRST_NAME +"']");
    let isValid = false;
    if(this.omFirstNameRules.required && cmpField) {
      isValid = cmpField.validity.valid;
    } else if(this.omFirstNameRules.required && this.omFirstName){
      isValid = true;
    }
    return isValid;
  }

  omLastNameValid() {
    let cmpField = this.template.querySelector("[data-name='" + this.OM_LAST_NAME + "']");
    let isValid = false;
    if(this.omLastNameRules.required && cmpField) {
      isValid = cmpField.validity.valid;
    } else if(this.omLastNameRules.required && this.omLastName){
      isValid = true;
    }
    return isValid;
  }

  preferedLanguageValid() {
    let cmpField = this.template.querySelector("[data-name='" + this.PREFERED_LANGUAGE + "']");
    let isValid = false;
    if(this.preferedLanguageRules.required && cmpField) {
      isValid = cmpField.validity.valid;
    } else if(this.preferedLanguageRules.required && this.preferedLanguage){
      isValid = true;
    }
    return isValid;
  }

  handleNextSection(event) {
    event.preventDefault();
    
    if (this.nextButtonDisabled()) {
      let contactValues = this.infoToBeSave();
      window.scrollTo(0,0);
      fireEvent(this.pageRef, "tidsUserInfoUpdate", contactValues);
    }
  }

  // Vetting errors
  handleError(event) {
    event.preventDefault();
    let errorField = event.target.dataset.name;
    this.modalAction = "FIELD";
    switch (errorField) {
      case "error-phone":
        if (this.phoneError.show && this.phoneError.description !== "") {
          this.fieldErrorSelected = this.phoneError;
          this.modalDefaultMessage = false;
          this.openModal = true;
        } else {
          this.phoneError.show = !this.phoneError.show;
        }
        break;
      case "error-fax":
        if (this.faxError.show && this.faxError.description !== "") {
          this.fieldErrorSelected = this.faxError;
          this.modalDefaultMessage = false;
          this.openModal = true;
        } else {
          this.faxError.show = !this.faxError.show;
        }
        break;
      case "error-business-email":
        if (
          this.businessEmailError.show &&
          this.businessEmailError.description !== ""
        ) {
          this.fieldErrorSelected = this.businessEmailError;
          this.modalDefaultMessage = false;
          this.openModal = true;
        } else {
          this.businessEmailError.show = !this.businessEmailError.show;
        }
        break;
      case "error-website":
        if (this.websiteError.show && this.websiteError.description !== "") {
          this.fieldErrorSelected = this.websiteError;
          this.modalDefaultMessage = false;
          this.openModal = true;
        } else {
          this.websiteError.show = !this.websiteError.show;
        }

        break;
      case "error-om-firstname":
        if (
          this.omFirstNameError.show &&
          this.omFirstNameError.description !== ""
        ) {
          this.fieldErrorSelected = this.omFirstNameError;
          this.modalDefaultMessage = false;
          this.openModal = true;
        } else {
          this.omFirstNameError.show = !this.omFirstNameError.show;
        }
        break;
      case "error-om-lastname":
        if (
          this.omLastNameError.show &&
          this.omLastNameError.description !== ""
        ) {
          this.fieldErrorSelected = this.omLastNameError;
          this.modalDefaultMessage = false;
          this.openModal = true;
        } else {
          this.omLastNameError.show = !this.omLastNameError.show;
        }
        break;
      case "error-prefered-language":
        if (
          this.preferedLanguageError.show &&
          this.preferedLanguageError.description !== ""
        ) {
          this.fieldErrorSelected = this.preferedLanguageError;
          this.modalDefaultMessage = false;
          this.openModal = true;
        } else {
          this.preferedLanguageError.show = !this.preferedLanguageError.show;
        }
        break;
      default:
        break;
    }
  }

  changeErrorFields(event) {
    let field = event.target.dataset.name;
    this.modalAction = "FIELD";
    switch (field) {
      case "error-phone-desc":
        this.phoneError.description = event.target.value;
        break;
      case "error-fax-desc":
        this.faxError.description = event.target.value;
        break;
      case "error-business-email-desc":
        this.businessEmailError.description = event.target.value;
        break;
      case "error-website-desc":
        this.websiteError.description = event.target.value;
        break;
      case "error-om-firstname-desc":
        this.omFirstNameError.description = event.target.value;
        break;
      case "error-om-lastname-desc":
        this.omLastNameError.description = event.target.value;
        break;
      case "error-prefered-language-desc":
        this.preferedLanguageError.description = event.target.value;
        break;
      default:
        break;
    }
    this.sectionHasErrors = this.noFormErrors();
  }

  handleProceed(event) {
    event.preventDefault();
    let option = event.target.dataset.name;
    let contactValues;

    if (option === "report-errors-and-proceed") {
      this.updateErrors();
      contactValues = this.infoToBeSave();
    } else if(option === 'confirm-review-status'){
      contactValues = this.infoToBeSave();
      contactValues.sectionDecision = SECTION_CONFIRMED;
    }

    fireEvent(this.pageRef, "tidsUserInfoUpdate", contactValues);
  }

  updateErrors() {
    if (this.phoneError.show && this.phoneError.description !== "") {
      this.addVettingError(this.phoneError);
    }
    if (this.faxError.show && this.faxError.description !== "") {
      this.addVettingError(this.faxError);
    }
    if (
      this.businessEmailError.show &&
      this.businessEmailError.description !== ""
    ) {
      this.addVettingError(this.businessEmailError);
    }
    if (this.websiteError.show && this.websiteError.description !== "") {
      this.addVettingError(this.websiteError);
    }
    if (
      this.omFirstNameError.show &&
      this.omFirstNameError.description !== ""
    ) {
      this.addVettingError(this.omFirstNameError);
    }
    if (
      this.omLastNameError.show &&
      this.omLastNameError.description !== ""
    ) {
      this.addVettingError(this.omLastNameError);
    }
    if (
      this.preferedLanguageError.show &&
      this.preferedLanguageError.description !== ""
    ) {
      this.addVettingError(this.preferedLanguageError);
    }
  }

  addVettingError(props) {
    let index = this.vettingErrors.findIndex(
      error => error.fieldName === props.fieldName
    );
    if (index === -1) {
      this.vettingErrors.push(props);
    } else {
      this.vettingErrors.splice(index, 1);
      this.vettingErrors.push(props);
    }
  }

  handleSaveAndQuit(event) {
    event.preventDefault();
    let option = event.target.dataset.next;
    let contactValues = this.infoToBeSave();
    contactValues.target = option;
    contactValues.action = 'SaveAndQuit';
    fireEvent(this.pageRef, "tidsUserInfoUpdate", contactValues);
  }

  // Modal Listeners
  modalProceedListener(props) {
    this.updateinfoErrors(props);
    this.sectionHasErrors = this.noFormErrors();
    this.openModal = false;
  }

  updateinfoErrors(props) {
    if (props.fieldName === "phone") {
      this.phoneError = props;
    } else if (props.fieldName === "fax") {
      this.faxError = props;
    } else if (props.fieldName === "businessEmail") {
      this.businessEmailError = props;
    } else if (props.fieldName === "website") {
      this.websiteError = props;
    } else if (props.fieldName === "omFirstName") {
      this.omFirstNameError = props;
    } else if (props.fieldName === "omLastName") {
      this.omLastNameError = props;
    } else if (props.fieldName === "preferedLanguage") {
      this.preferedLanguageError = props;
    }
  }

  modalCloseListener(props) {
    this.openModal = props;
    if(this.modalAction === 'ALL') {
      fireEvent(this.pageRef, "sectionErrorListener", true);
    }
  }

  modalDeleteAllErrorsListener(props) {
    // Reset Values
    this.phoneError.show = false;
    this.phoneError.description = "";
    this.faxError.show = false;
    this.faxError.description = "";
    this.businessEmailError.show = false;
    this.businessEmailError.description = "";
    this.websiteError.show = false;
    this.websiteError.description = "";
    this.omFirstNameError.show = false;
    this.omFirstNameError.description = "";
    this.omLastNameError.show = false;
    this.omLastNameError.description = "";
    this.preferedLanguageError.show = false;
    this.preferedLanguageError.description = "";

    this.sectionHasErrors = this.noFormErrors();
    this.vettingErrorOptions = this.noFormErrors();
    this.openModal = false;
    fireEvent(this.pageRef, "sectionErrorListener", false);
  }

  // Section business logic Save
  infoToBeSave() {
    let sectionNav = JSON.parse(
      JSON.stringify(sectionNavigation(this.cmpName))
    );

    let contactValues = {
      cmpName: this.cmpName,
      target: sectionNav.next,
      sectionDecision: sectionDecision(this.sectionHasErrors),
      values: {
        preferedLanguage: this.preferedLanguage,
        phone: this.phone,
        fax: this.fax,
        businessEmail: this.businessEmail,
        webSite: this.webSite,
        omFirstName: this.omFirstName,
        omLastName: this.omLastName
      },
      vettingErrors: this.vettingErrors
    };

    return contactValues;
  }
  
  noFormErrors() {
    let phoneValid =
      this.phoneError.show && this.phoneError.description !== "" ? true : false;
    let faxValid =
      this.faxError.show && this.faxError.description !== "" ? true : false;
    let businessEmailValid =
      this.businessEmailError.show && this.businessEmailError.description !== ""
        ? true
        : false;
    let websiteValid =
      this.websiteError.show && this.websiteError.description !== ""
        ? true
        : false;
    let omFirstNameValid =
      this.omFirstNameError.show && this.omFirstNameError.description !== ""
        ? true
        : false;
    let omLastNameValid =
      this.omLastNameError.show && this.omLastNameError.description !== ""
        ? true
        : false;
    let preferedLanguageValid =
      this.preferedLanguageError.show &&
      this.preferedLanguageError.description !== ""
        ? true
        : false;
    let result =
      phoneValid ||
      faxValid ||
      businessEmailValid ||
      websiteValid ||
      omFirstNameValid ||
      omLastNameValid ||
      preferedLanguageValid;
    this.reportErrorButtonDisabled = result ? false : true;
    return result;
  }

  notifySectionHasError() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(
      () => {
        fireEvent(this.pageRef, "sectionErrorListener", this.sectionHasErrors);
      },
      1,
      this
    );
  }
}
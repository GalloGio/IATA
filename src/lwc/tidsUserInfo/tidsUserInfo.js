const CLIENT_MODE = "client";
const VETTING_MODE = "vetting";
const NOT_STARTED = "Not_Started";
const SECTION_CONFIRMED = "Section_Confirmed";
const SECTION_ERROR_REPORTED = "Error_Reported";
const APPLICATION_APPROVED = "Application_Approved";
const APPLICATION_REJECTED = "Application_Rejected";
const APPLICATION_ERRORS = "Application_Errors";
const NEW_BRANCH = "NEW_BR";
const NEW_VIRTUAL_BRANCH = "NEW_VB";
const NEW_HEAD_OFFICE = "NEW_HO";
const CHG_NAME_COMPANY = "chg-name-company";
const CHG_ADDRESS_CONTACT = "chg-address-contact";
const CHG_BUSINESS_PROFILE_SPECIALIZATION ="chg-business-profile-specialization";
let mainActivities = [];
let principalDestinations = [];
let salesVolume = [];
let mainMarketSpecialization = [];
let gds = [];
let numberOfEmployees = [];
let focusValues = [];
let preferedLanguages = [];
let countries = [];
let mailingCountries = [];
let headOfficeInfo = {};
let companyTypes = [];
let tidsInfoInit = {
  userType: null,
  applicationType: NEW_HEAD_OFFICE,
  userInfo: null,
  businessRules: null,
  tidsCase: null,
  sections: {
    Welcome: {},
    AgencyLegalStatus: {},
    ShareholderDetails: {},
    Address: {},
    Mailing: {},
    Contact: {},
    BusinessProfile: {},
    BusinessSpecialization: {},
    SupportingDocuments: {}
  },
  sectionsDone: []
};
let tidsInfo = tidsInfoInit;
let optionsMenu = [];
let tidsConfiguration = [];
let picklistReportChanges = [
  {
    label: "Change of Name or Company Details",
    value: "chg-name-company"
  },
  {
    label: "Change of Address or Contact Details",
    value: "chg-address-contact"
  },
  {
    label: "Change of Business Profile or Specialization",
    value: "chg-business-profile-specialization"
  }
];

let isHeadOffice = false;
// Dashboard
let accountSelected = {};
// Report Changes
let sfTidsInfo = null;
const setSfTidsInfo = (info) => {
  sfTidsInfo = info;
};

const getSfTidsInfo = () => {
  return sfTidsInfo;
};

const getAccountSelected = () => {
  return accountSelected;
};

const setAccountSelected = (account) => {
  accountSelected = account;
};

const setConfiguration = (configuration) => {
  tidsConfiguration = configuration;
};

const getReportChangesOption = () => {
  return picklistReportChanges;
};
const initializeTidsInfo = () =>{
  tidsInfo = tidsInfoInit;
}

const getSectionRules = (sectionName) => {
  let menuName = null;
  console.log('getSectionRules:tidsInfo', JSON.stringify(tidsInfo));
  let functioname="";
  switch (tidsInfo.applicationType) {
    case NEW_HEAD_OFFICE:
      menuName = "new-applicant-ho";
        //tidsInfo.userType === "client"
        //  ? "new-applicant-ho"
        //  : "new-applicant-ho";
      break;
    case NEW_BRANCH:
      menuName ="new-applicant-br";
        //tidsInfo.userType === "client"
        //  ? "new-applicant-br"
        //  : "new-applicant-br";
      break;
    case CHG_NAME_COMPANY:
      functioname = "-ho";
      if (tidsInfo.userInfo.tidsAccount.Location_Type!='HO'){
        functioname='-br';
      }
      menuName = CHG_NAME_COMPANY + functioname;
      break;
    case CHG_ADDRESS_CONTACT:
      if (tidsInfo.userInfo.tidsAccount.Location_Type=='VB'){
        functioname='-vb';
      }
      menuName = CHG_ADDRESS_CONTACT + functioname;
      break;
    case CHG_BUSINESS_PROFILE_SPECIALIZATION:
      functioname = "-ho";
      if (tidsInfo.userInfo.tidsAccount.Location_Type!='HO'){
        functioname='-br';
      }
      menuName = CHG_BUSINESS_PROFILE_SPECIALIZATION + functioname;
      break;
    case NEW_VIRTUAL_BRANCH:
      menuName = "new-virtual-branch";
      break;
    default:
      break;
  }
  console.log('getSectionRules:menuName', menuName);
  let c = tidsConfiguration.find((e) => e.apiName === menuName);
  let ops = null;
  if (tidsInfo.userType === "client") {
    ops = c.options.client.find((el) => el.apiSectionName === sectionName);
  } else if (tidsInfo.userType === "vetting") {
    ops = c.options.vetting.find((el) => el.apiSectionName === sectionName);
  }
  return ops.fields;
};

const getConfiguration = () => {
  return tidsConfiguration;
};

const setApplicationType = (props) => {
  tidsInfo.applicationType = props;
};

const getApplicationType = () => {
  return tidsInfo.applicationType;
};

const setWelcome = (props) => {
  tidsInfo.sections.Welcome = props;
};

const getWelcome = () => {
  return tidsInfo.sections.Welcome;
};

const setAgencyLegalStatus = (props) => {
  tidsInfo.sections.AgencyLegalStatus = props;
};

const getAgencyLegalStatus = () => {
  return tidsInfo.sections.AgencyLegalStatus;
};

const setShareholderDetails = (props) => {
  tidsInfo.sections.ShareholderDetails = props;
};

const getShareholderDetails = () => {
  return tidsInfo.sections.ShareholderDetails;
};

const setAddress = (props) => {
  tidsInfo.sections.Address = props;
};

const getAddress = () => {
  return tidsInfo.sections.Address;
};

const setMailing = (props) => {
  tidsInfo.sections.Mailing = props;
};

const getMailing = () => {
  return tidsInfo.sections.Mailing;
};

const setContact = (props) => {
  tidsInfo.sections.Contact = props;
};

const getContact = () => {
  return tidsInfo.sections.Contact;
};
const setLocationType= (props) => {
  tidsInfo.userInfo.tidsAccount.Location_Type = props;
};
const getLocationType= () => {
  return tidsInfo.userInfo.tidsAccount.Location_Type;
};
const setBusinessProfile = (props) => {
  tidsInfo.sections.BusinessProfile = props;
};

const getBusinessProfile = () => {
  return tidsInfo.sections.BusinessProfile;
};

const setBusinessSpecialization = (props) => {
  tidsInfo.sections.BusinessSpecialization = props;
};

const getBusinessSpecialization = () => {
  return tidsInfo.sections.BusinessSpecialization;
};

const setSupportingDocuments = (props) => {
  tidsInfo.sections.SupportingDocuments = props;
};

const getSupportingDocuments = () => {
  return tidsInfo.sections.SupportingDocuments;
};

const getUserInfo = () => {
  return tidsInfo.userInfo;
};

const setUserInfo = (props) => {
  console.log('role',JSON.stringify(props.profile));
  let userData = JSON.parse(JSON.stringify(props.currentUser));
  let accountData = JSON.parse(JSON.stringify(userData.Account));
  let recordTypeData = JSON.parse(JSON.stringify(accountData.RecordType));
  let locationtype =userData.locationtype;
  tidsInfo.userInfo = {
    UserName: userData.Name,
    UserId: userData.Id,
    ContactId: userData.ContactId,
    role:props.profile.Access_Status_Reason__c,
    tidsAccount: {
      Location_Type:locationtype,
      Id: accountData.Id,
      Country_ISO_Code: accountData.Country_ISO_Code__c,
      RecordType: {
        Name: recordTypeData.Name,
        Id: recordTypeData.Id
      }
    }
  };
};

const setUserInfoIata = (props) => {
  tidsInfo.userInfo = {
    UserName: props.Name,
    UserId: props.Id,
    ContactId: props.ContactId,
    role:props.role,
    tidsAccount: {
      Location_Type:props.locationtype,
      Id: props.AccountId,
      Country_ISO_Code: props.Country_ISO_Code,
      RecordType: {
        Name: null,
        Id: null
      }
    }
  };
};

const updateTidsUserInfo = (props) => {
  tidsInfo.userInfo = {
    tidsAccount: {
      Location_Type:'HO',
      Id: props.Id
    }
  } 
}

const getTidsInfo = () => {
  return tidsInfo;
};

const getBusinessrules = () => {
  return tidsInfo.businessRules;
};

const setBusinessrules = (props) => {
  let businessRulesData = JSON.parse(JSON.stringify(props));
  tidsInfo.businessRules = {
    Name: businessRulesData.Name,
    Id: businessRulesData.Id,
    TIDS_Total_Ownership_Minimum: businessRulesData.TIDS_Total_Ownership_Minimum__c.toString(),
    TIDS_Total_Ownership_Maximum: businessRulesData.TIDS_Total_Ownership_Maximum__c.toString()
  };
};

const sectionNavigation = (props) => {
  let sections = [];
  console.log('tidsInfo',JSON.stringify(tidsInfo));
  let locationtype=getLocationType();
  console.log('locationtype',locationtype);
  let apptype=tidsInfo.applicationType;
  let option='';
  let isvetting = tidsInfo.userType === "vetting" ? true:false;
  if (apptype === NEW_HEAD_OFFICE) {
    option = "new-applicant-ho";
  } else if (apptype === NEW_HEAD_OFFICE && isvetting) {
    option = "new-applicant-ho";
  } else if (apptype === NEW_BRANCH && !isvetting) {
    option = "new-applicant-br";
  } else if (apptype === NEW_BRANCH && isvetting) {
    option = "new-applicant-br";
  } else if (apptype === CHG_NAME_COMPANY && isAccountHeadOffice()) {
    option = "chg-name-company-ho";
  } else if (apptype === CHG_NAME_COMPANY && !isAccountHeadOffice()) {
    option = "chg-name-company-br";
  } else if (apptype === CHG_ADDRESS_CONTACT) {
    option = "chg-address-contact";
  } else if (apptype === NEW_VIRTUAL_BRANCH) {
    option = "new-virtual-branch";
  } else if (apptype === CHG_BUSINESS_PROFILE_SPECIALIZATION && isAccountHeadOffice()) {
    option = "chg-business-profile-specialization-ho";
  } else if (apptype === CHG_BUSINESS_PROFILE_SPECIALIZATION && !isAccountHeadOffice()) {
    option = "chg-business-profile-specialization-br";
  }
  console.log('option',option);
  sections = getMenuOptions({ name: option, type: "navigation" });
  return sections.find((item) => item.sectionName === props);
};

const getSectionName = (props) => {
  let sections = [
    { cmpName: "new-applicant", sectionName: "Welcome" },
    { cmpName: "agency-legal-status", sectionName: "Agency Legal Status" },
    { cmpName: "shareholder-details", sectionName: "Ownership Details" },
    { cmpName: "address", sectionName: "Address" },
    { cmpName: "mailing", sectionName: "Mailing" },
    { cmpName: "contact", sectionName: "Contact" },
    { cmpName: "business-profile", sectionName: "Business Profile" },
    {
      cmpName: "business-specialization",
      sectionName: "Business Specialization"
    },
    { cmpName: "supporting-documents", sectionName: "Supporting Documents" },
    { cmpName: "submit-application", sectionName: "Submit Application" }
  ];
  return sections.find((section) => section.cmpName === props);
};

const updateInfo = (props) => {
  let sectionName = props.cmpName;
  let sectionInfo = getSectionName(sectionName);
  let sectionValues = {
    sectionName: sectionInfo.sectionName,
    cmpName: sectionName,
    values: props.values,
    sectionDecision: props.sectionDecision,
    errors: props.vettingErrors
  };

  switch (sectionName) {
    case "new-applicant":
      setWelcome(sectionValues);
      break;
    case "agency-legal-status":
      setAgencyLegalStatus(sectionValues);
      break;
    case "shareholder-details":
      setShareholderDetails(sectionValues);
      break;
    case "address":
      setAddress(sectionValues);
      break;
    case "mailing":
      setMailing(sectionValues);
      break;
    case "contact":
      setContact(sectionValues);
      break;
    case "business-profile":
      setBusinessProfile(sectionValues);
      break;
    case "business-specialization":
      setBusinessSpecialization(sectionValues);
      break;
    case "supporting-documents":
      setSupportingDocuments(sectionValues);
      break;
    default:
      break;
  }

  if (props.action !== "SaveAndQuit") {
    let sectionDoneIndex = tidsInfo.sectionsDone.findIndex(
      (item) => item.sectionName === sectionName
    );

    if (sectionDoneIndex === -1) {
      let sectionDone = sectionNavigation(sectionName);
      tidsInfo.sectionsDone.push(sectionDone);
    } else {
      tidsInfo.sectionsDone.splice(
        sectionDoneIndex,
        1,
        sectionNavigation(sectionName)
      );
    }
  }
};

const updateSections = (props) => {
  tidsInfo.sections = props;
};

const setUserType = (props) => {
  tidsInfo.userType = props ? VETTING_MODE : CLIENT_MODE;
};

const getSectionInfo = (cmpName) => {
  let result;
  switch (cmpName) {
    case "new-applicant":
      result = getWelcome();
      break;
    case "account-info":
      result = tidsInfo;
      break;
    case "agency-legal-status":
      result = getAgencyLegalStatus();
      break;
    case "shareholder-details":
      result = getShareholderDetails();
      break;
    case "address":
      result = getAddress();
      break;
    case "mailing":
      result = getMailing();
      break;
    case "contact":
      result = getContact();
      break;
    case "business-profile":
      result = getBusinessProfile();
      break;
    case "business-specialization":
      result = getBusinessSpecialization();
      break;
    case "supporting-documents":
      result = getSupportingDocuments();
      break;
    default:
      break;
  }

  if (Object.keys(result).length === 0) {
    result = null;
  }

  return result;
};

const getUserType = () => {
  return tidsInfo.userType;
};

const setSectionsDone = (props) => {
  tidsInfo.sectionsDone = props;
};

const getSectionsDone = () => {
  return tidsInfo.sectionsDone;
};

const sectionDecision = (props) => {
  let decision = NOT_STARTED;
  if (props) {
    decision = SECTION_ERROR_REPORTED;
  }
  return decision;
};

const setCase = (props) => {
  tidsInfo.tidsCase = props;
};

const getCase = () => {
  return tidsInfo.tidsCase;
};

const setMainActivities = (props) => {
  mainActivities = props;
};

const getMainActivities = () => {
  return mainActivities;
};

const setPrincipalDestinations = (props) => {
  principalDestinations = props;
};

const getPrincipalDestinations = () => {
  return principalDestinations;
};

const setSalesVolume = (props) => {
  salesVolume = props;
};

const getSalesVolume = () => {
  return salesVolume;
};

const setMainMarketSpecialization = (props) => {
  mainMarketSpecialization = props;
};

const getMainMarketSpecialization = () => {
  return mainMarketSpecialization;
};

const setGDSValues = (props) => {
  gds = props;
};

const getGDSValues = () => {
  return gds;
};

const setNumberOfEmployees = (props) => {
  numberOfEmployees = props;
};

const getNumberOfEmployees = () => {
  return numberOfEmployees;
};

const setPreferedLanguages = (props) => {
  preferedLanguages = props;
};

const getPreferedLanguages = () => {
  return preferedLanguages;
};

const setFocusValues = (props) => {
  focusValues = props;
};

const getFocusValues = () => {
  return focusValues;
};

const setCountries = (props) => {
  countries = props;
};

const getCountries = () => {
  return countries;
};

const setMailingCountries = (props) => {
  mailingCountries = props;
};

const getMailingCountries = () => {
  return mailingCountries;
};

const mappingSelectedValues = (items, itemselected) => {
  items.forEach((item) => {
    item.isSelected = false;
    itemselected.forEach((item2) => {
      if (item.label === item2.label) {
        item.isSelected = true;
      }
    });
  });
  return items;
};

const setHeadOfficeInfo = (payload) => {
  headOfficeInfo = payload;
};

const getHeadOfficeInfo = () => {
  return headOfficeInfo;
};

const displaySaveAndQuitButton = (action) => {
  let result = true;
  if (action.payload.applicationType === NEW_VIRTUAL_BRANCH ||
    action.payload.applicationType === NEW_BRANCH ||
    action.payload.applicationType.startsWith("chg-")) {
    result = false;
  }
  return result;
};

const iconFile = (props) => {
  let iconClassName = "";
  switch (props.type) {
    case "image/png":
    case "image/jpeg":
    case "image/gif":
      iconClassName = "doctype:image";
      break;
    case "text/csv":
      iconClassName = "doctype:csv";
      break;
    case "application/pdf":
      iconClassName = "doctype:pdf";
      break;
    case "application/msword":
    case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
      iconClassName = "doctype:word";
      break;
    case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
      iconClassName = "doctype:excel";
      break;
    default:
      iconClassName = "doctype:unknown";
      break;
  }
  return iconClassName;
};

const specialCharsValidation = (value) => {
  return false;
  //let regexp = new RegExp("^$|^[a-zA-Z0-9\\,\\.\\-\\_\\@ ]+$");
  //let result = value.match(regexp);
  //return result ? false : true;
};

const emailValidation = (value) => {
  return true;
  //return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
};

const websiteValidation = (value) => {
  return true;
  //return /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\\.-]+)+[\w\\-\\._~:/?#[\]@!\\$&'\\(\\)\\*\\+,;=.]+$/.test(
  //  value
  //);
};

const sum = (props) => {
  let total = 0;
  for (let i = 0; i < props.values.length; i++) {
    if (props.values[i].value !== null) {
      total += props.values[i].value;
    }
  }
  return total;
};

// Head office logic
const mappingHeadOfficeInformation = (props) => {};

// Tids Configuration Menu
const mappingMenu = (menu, formType) => {
  let displayMenu = [];
  let label = null;

  let count = 1;
  let isDisabled = formType === "client" ? true : false;

  menu.forEach((e, index) => {
    if (e.display) {
      let visible = e.display;
      if (e.apiSectionName === "new-applicant" && formType === "client") {
        label = e.sectionName;
        visible = false;
      } else {
        label = `${count}. ${e.sectionName}`;
        count++;
      }

      displayMenu.push({
        name: e.apiSectionName,
        class: "menu-item",
        label: label,
        visible: visible,
        errorIcon: false,
        approved: false,
        isDisabled: isDisabled
      });
    }
  });

  return displayMenu;
};

const mappingNavigation = (options) => {
  let optionsSize = options.length - 1;
  let res = [];
  options.forEach((o, index) => {
    let next = null;
    if (index < optionsSize) {
      next =
        options[index + 1].name === "application-decision"
          ? "submit-application"
          : options[index + 1].name;
    } else {
      next = o.name === "application-decision" ? "submit-application" : o.name;
    }
    let val = {
      id: index,
      sectionName: o.name,
      next: next
    };
    res.push(val);
  });

  return res;
};

const createClientMenu = (menu) => {
  let values = JSON.parse(JSON.stringify(menu.options.client));
  return mappingMenu(values, "client");
};

const createVettingMenu = (menu) => {
  let values = JSON.parse(JSON.stringify(menu.options.vetting));
  return mappingMenu(values, "vetting");
};

const clientMenu = (menu) => {
  let item = {
    menuName: menu.apiName,
    formType: "client",
    values: []
  };

  item.values = createClientMenu(menu);
  item.navigation = mappingNavigation(item.values);

  return item;
};

const vettingMenu = (menu) => {
  let vetting = {
    menuName: menu.apiName,
    formType: "vetting"
  };

  vetting.values = createVettingMenu(menu);
  vetting.navigation = mappingNavigation(vetting.values);

  return vetting;
};

const createMenu = (menus) => {
  //console.log('createMenu:menus',JSON.stringify(menus));
  //console.log('createMenu:optionsMenu',JSON.stringify(optionsMenu));
  menus.forEach((menu) => {
    let client = clientMenu(menu);
    let vetting = vettingMenu(menu);
    optionsMenu.push(client);
    optionsMenu.push(vetting);
  });
  //console.log('createMenu:optionsMenu',JSON.stringify(optionsMenu));
};

const resetUserInfo = () => {
  tidsInfo = {
    userType: null,
    applicationType: NEW_HEAD_OFFICE,
    userInfo: null,
    businessRules: null,
    tidsCase: null,
    sections: {
      Welcome: {},
      AgencyLegalStatus: {},
      ShareholderDetails: {},
      Address: {},
      Mailing: {},
      Contact: {},
      BusinessProfile: {},
      BusinessSpecialization: {},
      SupportingDocuments: {}
    },
    sectionsDone: []
  };
};

// TIDS Get Menu Options
const getMenuOptions = (payload) => {
  let formType = tidsInfo.userType;

  let optionSelected = optionsMenu.find(
    (element) =>
      element.menuName === payload.name && element.formType === formType
  );

  if (payload.type === "menu") {
    return optionSelected.values;
  } else if (payload.type === "navigation") {
    return optionSelected.navigation;
  }
};

const validateEmail = (email) => {
  return true;
  //let re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  //return re.test(email);
};

const isAccountHeadOffice = () => {
  return isHeadOffice;
};

const setIsAccountHeadOffice = (props) => {
  isHeadOffice = props;
};

const setCompanyTypes = (values) => {
  companyTypes = values;
};

const getCompanyTypes = () => {
  return companyTypes;
};

export {
  initializeTidsInfo,
  getLocationType,
  setLocationType,
  getTidsInfo,
  setApplicationType,
  getApplicationType,
  getUserInfo,
  setUserInfo,
  updateInfo,
  updateSections,
  getSectionInfo,
  setBusinessrules,
  getBusinessrules,
  setUserType,
  getUserType,
  getSectionsDone,
  setSectionsDone,
  sectionNavigation,
  sectionDecision,
  setCase,
  setContact,
  getCase,
  setMainActivities,
  getMainActivities,
  setPrincipalDestinations,
  getPrincipalDestinations,
  setSalesVolume,
  getSalesVolume,
  setMainMarketSpecialization,
  getMainMarketSpecialization,
  setGDSValues,
  getGDSValues,
  setNumberOfEmployees,
  getNumberOfEmployees,
  setFocusValues,
  getFocusValues,
  setCountries,
  getCountries,
  setHeadOfficeInfo,
  getHeadOfficeInfo,
  mappingSelectedValues,
  setAgencyLegalStatus,
  setAddress,
  setBusinessProfile,
  setBusinessSpecialization,
  setShareholderDetails,
  displaySaveAndQuitButton,
  setMailing,
  setMailingCountries,
  getMailingCountries,
  setPreferedLanguages,
  getPreferedLanguages,
  setWelcome,
  getWelcome,
  setUserInfoIata,
  iconFile,
  emailValidation,
  websiteValidation,
  specialCharsValidation,
  sum,
  mappingHeadOfficeInformation,
  setConfiguration,
  getConfiguration,
  createMenu,
  getMenuOptions,
  getSectionRules,
  validateEmail,
  getReportChangesOption,
  resetUserInfo,
  isAccountHeadOffice,
  setIsAccountHeadOffice,
  getAccountSelected,
  setAccountSelected,
  setSfTidsInfo,
  getSfTidsInfo,
  setCompanyTypes,
  getCompanyTypes,
  updateTidsUserInfo,
  SECTION_CONFIRMED,
  SECTION_ERROR_REPORTED,
  APPLICATION_APPROVED,
  APPLICATION_REJECTED,
  APPLICATION_ERRORS,
  NOT_STARTED,
  NEW_HEAD_OFFICE,
  NEW_BRANCH,
  NEW_VIRTUAL_BRANCH,
  CHG_NAME_COMPANY,
  CHG_ADDRESS_CONTACT,
  CHG_BUSINESS_PROFILE_SPECIALIZATION
};
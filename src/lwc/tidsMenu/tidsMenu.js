import { LightningElement, wire, track, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
import {
  getTidsInfo,
  getLocationType,
  getSectionsDone,
  getMenuOptions,
  isAccountHeadOffice,
  SECTION_CONFIRMED,
  SECTION_ERROR_REPORTED,
  NEW_BRANCH,
  NEW_VIRTUAL_BRANCH,
  NEW_HEAD_OFFICE,
  CHG_NAME_COMPANY,
  CHG_ADDRESS_CONTACT,
  CHG_BUSINESS_PROFILE_SPECIALIZATION
} from "c/tidsUserInfo";

export default class TidsMenu extends LightningElement {
  @track tidsInfo;
  @wire(CurrentPageReference) pageRef;
  @track currentUserType;
  @track vettingMode = false;
  @track inactiveLink = "inactiveLink";
  @track sectionsDone = [];
  @track items = [];

  //@api get items() {
  //  return this.items;
  //}

  @track isAccountAHeadOffice = false;

  connectedCallback() {
    registerListener("buttonClicked", this.handleButtonClicked, this);
    this.buildMenuItem();
  }
  buildMenuItem(){ 
    this.tidsInfo = JSON.parse(JSON.stringify(getTidsInfo()));
    this.vettingMode = this.vetting();
    this.isAccountAHeadOffice = isAccountHeadOffice();

    this.mappingMenuOptions();
    this.sectionsDone = getSectionsDone();
    console.log('this.sectionsDone',JSON.stringify(this.sectionsDone));
    if (this.vettingMode) {
      // eslint-disable-next-line guard-for-in
      for (let ind in this.tidsInfo.sections) {
        let index = this.items.findIndex(
          option => option.name === this.tidsInfo.sections[ind].cmpName
        );
        if (index >= 0){
          let section = this.tidsInfo.sections[ind].sectionDecision;
          if (section === SECTION_ERROR_REPORTED) {
            this.items[index].errorIcon = true;
          } else if (section === SECTION_CONFIRMED) {
            this.items[index].approved = true;
          }
        }
      }
      this.items.forEach(function(element) {
        element.isDisabled = false;
      });
    } else if (this.sectionsDone !== undefined && this.sectionsDone.length > 0) {
      console.log('this.sectionsDone else if',JSON.stringify(this.sectionsDone));
      this.sectionsDone.forEach(item => {
        this.allowMenuOptions(item.sectionName);
      });
      let nextSection = this.sectionsDone[this.sectionsDone.length - 1].next;
      this.displayMenuOptionSelected(nextSection);
    }
    console.log('items',JSON.stringify(this.items));
  }

  vetting() {
    return this.tidsInfo.userType === "vetting" ? true : false;
  }

  mappingMenuOptions() {
    let type = getLocationType();
    let apptype=this.tidsInfo.applicationType;
    let option='';
    console.log('type',type,JSON.stringify(this.tidsInfo));
    
    if (apptype === NEW_HEAD_OFFICE) {
      option='new-applicant-ho';
    }

    if (apptype=== NEW_BRANCH) {
      option='new-applicant-br';
    }

    if (apptype=== NEW_VIRTUAL_BRANCH) {
      option='new-virtual-branch';
    }

    if (apptype=== CHG_NAME_COMPANY){
      if (type==='HO') {
        option='chg-name-company-ho';
      }else if (type==='BR' || type==='VB'){
        option='chg-name-company-br';
      }
    } 

    if (apptype === CHG_ADDRESS_CONTACT){
       if (type==='HO') {
          option='chg-address-contact';
       }else if (type==='BR') {
          option='chg-address-contact';
       }else if (type==='VB') {
          option='chg-address-contact-vb';
       }
    }

    if (apptype=== CHG_BUSINESS_PROFILE_SPECIALIZATION){
       if (type==='HO') {
          option='chg-business-profile-specialization-ho';
        }else if (type==='BR' || type==='VB') {
          option='chg-business-profile-specialization-br';
        }
    }
    console.log('option',option);
   
    this.items = getMenuOptions({name: option,type: "menu"});
  }

  handleMenuSelect(event) {
    event.preventDefault();
    let selected = event.target.name;
    this.allowMenuOptions(selected);
    fireEvent(this.pageRef, "menuOptionSelected", selected);
  }

  handleButtonClicked(option) {
    if (this.vettingMode) {
      this.iconUpdate(option);
    }
    this.allowMenuOptions(option.target);
  }
  /*
  isSectionDone(sectionName) {
    let result = false;
    let section = this.sectionsDone.find(
      item => item.sectionName === sectionName
    );
    if (section !== undefined) {
      result = true;
    }
    return result;
  }*/

  allowMenuOptions(selected) {
    this.items.forEach(function(element) {
      if (element.name === selected) {
        element.class = "menu-item selected";
        element.isDisabled = false;
      } else {
        element.class = "menu-item";
      }
    });

    if (!this.vettingMode) {
      this.sectionsDone.forEach(section => {
        this.items.forEach(item => {
          if (item.name === section.sectionName) {
            item.isDisabled = false;
            item.approved = true;
          }
        });
      });
    }
  }

  displayMenuOptionSelected(selected) {
    this.allowMenuOptions(selected);
    fireEvent(this.pageRef, "menuOptionSelected", selected);
  }

  iconUpdate(props) {
    let index = this.items.findIndex(option => option.name === props.cmpName);
    if (index>=0){
      let section =props.sectionDecision;
      if (section === SECTION_ERROR_REPORTED) {
         this.items[index].approved = false;
         this.items[index].errorIcon = true;
       } else if (section === SECTION_CONFIRMED) {
         this.items[index].errorIcon = false;
         this.items[index].approved = true;
       }
    }
  }
}
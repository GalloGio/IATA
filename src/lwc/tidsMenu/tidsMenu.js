import { LightningElement, wire, track, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
import {
	setSectionsDone,
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

	@track isAccountAHeadOffice = false;

	connectedCallback() {
		registerListener("buttonClicked", this.handleButtonClicked, this);
		this.buildMenuItem();
	}
	buildMenuItem(){ 
		let tidsinformation = JSON.stringify(getTidsInfo());
		this.tidsInfo = JSON.parse(tidsinformation);
		this.vettingMode = this.vetting();
		this.isAccountAHeadOffice = isAccountHeadOffice();
		if (this.vettingMode) {
			this.mappingMenuOptions();
			this.sectionsDone = getSectionsDone();
			let selected='new-applicant';
			let firstsection;
			let lastsection;
			let isselected=false;
			for (let ind in this.tidsInfo.sections) {
				let index = this.items.findIndex(
					option => option.name === this.tidsInfo.sections[ind].cmpName
				);
				if (index >= 0){
					let section = this.tidsInfo.sections[ind].sectionDecision;
					if (firstsection===undefined){
						firstsection= this.tidsInfo.sections[ind].cmpName;
					}
					lastsection= this.tidsInfo.sections[ind].cmpName;
					
					if (section === SECTION_ERROR_REPORTED) {
						this.items[index].errorIcon = true;
					} else if (section === SECTION_CONFIRMED) {
						this.items[index].approved = true;
					} else{
						if (!isselected &&  this.tidsInfo.sections[ind].target!='NA') {
							//exception for the VB change of address-contact
							//the address section cshould not be counted as not processed
							isselected=true;
							selected= this.tidsInfo.sections[ind].cmpName;
						}
					}
				}
			}
			this.items.forEach(function(element) {
				element.isDisabled = false;
			});
			if (!isselected) {
				if (lastsection===firstsection){
					selected=firstsection;
				}else{
					selected='submit-application';
				}
			}
			this.displayMenuOptionSelected(selected);
		}else if (this.tidsInfo.applicationType==='NEW_HO' && this.tidsInfo.tidsCase!=null){
			this.mappingMenuOptions();
			this.sectionsDone = getSectionsDone();
			let selected=undefined;
			this.sectionsDone.forEach(item => {
				selected=item.next;
				this.allowMenuOptions(item.sectionName);
			});
			this.displayMenuOptionSelected(selected);		
		}else{	
			setSectionsDone([]);
			this.mappingMenuOptions();
			this.sectionsDone = getSectionsDone();
			let selected=undefined;
			this.items.forEach(item => {
				if (selected==undefined){
					selected=item.name;
					item.isDisabled=false;
				}else{
					item.isDisabled=true;
				}
				item.approved=false;				
			});
			this.displayMenuOptionSelected(selected);
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
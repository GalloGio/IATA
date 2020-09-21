import { LightningElement, track, api, wire } from 'lwc';
// Pubsub libraries
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/tidsPubSub";
// import { getReportChangesOption, getAccountSelected, setCase, updateTidsUserInfo, isAccountHeadOffice } from 'c/tidsUserInfo';
import getBusinessProfileSpecialization from "@salesforce/apex/TIDSReportChanges.getBusinessProfileSpecialization";
import getNameCompanyDetails from '@salesforce/apex/TIDSReportChanges.getNameCompanyDetails';
import getAddressContactDetails from '@salesforce/apex/TIDSReportChanges.getAddressContactDetails';
export default class TidsAllInformation extends LightningElement {
	@track cmpName = 'AllInformation';

	@wire(CurrentPageReference) pageRef;

	@api accountInfo;
	@track branchSelected;
	@track vbSelected;
	@track modalAction;
	@track isagency=false;
	@track isprofile=false;
	@track isRequestExist=false;
	@track showConfimationModal=false;
	@track modalDefaultMessage='';

	@track tidsAccount;
	@track agency;
	@track profile;
	@track company;
	@track iscompany=false;
	@track destinations='n/a';
	@track fmarkets=[];
	@track percentages=[];

	@track noffices='n/a';
	@track nemployees='n/a';
	@track smarkets='n/a';
	@track gds='n/a';
	@track sales=[];
	@track travels='n/a';
	@track pactivities=[];
	@track ownership=[];
	@track vat1='n/a';
	@track vat2='n/a';
	@track license='n/a';


	@track tradename='n/a';
	@track manager='n/a';
	@track companytype='n/a';
	@track inoperation='n/a';
	@track email='n/a';
	@track phone='n/a';
	@track fax='n/a';
	@track website='n/a';
	@track preferredlanguage ='n/a';
	
	connectedCallback() {
		// this.changeTypeOptions = this.getChangeTypeOptions();
		this.setInitialValues();
		this.getCompanyContactInfo();
	}
	setInitialValues(){ 
		this.tidsAccount = this.accountInfo;
		this.branchSelected=false;
		this.vbSelected=false;
		if (this.accountInfo.Location_Type__c==='BR'){
			this.branchSelected=true;
			this.vbSelected=false;
		}else if (this.accountInfo.Location_Type__c==='VB'){
			this.branchSelected=true;
			this.vbSelected=true;
		}
		this.vat1=this.setNone(this.tidsAccount.VAT_Number__c);
		this.vat2=this.setNone(this.tidsAccount.VAT_Number_2__c);
		this.license=this.setNone(this.tidsAccount.License_Number__c);
		this.tradename=this.setNone(this.tidsAccount.TradeName__c);
		this.manager = this.tidsAccount.Manager_First_Name__c + ' ' + this.tidsAccount.Manager_Last_Name__c;
		if (this.setNone(this.tidsAccount.Manager_First_Name__c)==='n/a' && this.setNone(this.tidsAccount.Manager_Last_Name__c)==='n/a'){
			 this.manager ='n/a';
		}else{
			if (this.setNone(this.tidsAccount.Manager_First_Name__c)==='n/a'){
				this.manager =this.tidsAccount.Manager_Last_Name__c;
			}else if (this.setNone(this.tidsAccount.Manager_Last_Name__c)==='n/a'){
				this.manager =this.tidsAccount.Manager_First_Name__c;
			}
		}
	}
	setNone(value){
		if (value==='' || value===null || value===undefined) {
			 value='n/a';
		}
		return value;
	}
	@track activeSections = ['name-company'];

	handleContactInfoToggle(event){
		console.log('event.detail.openSections',event.detail.openSections);
		this.activeSections = event.detail.openSections;
		console.log('this.activeSections',JSON.stringify(this.activeSections));
		if (this.activeSections.length === 0) {
				//nothing to show
				console.log('this.activeSections is empty');
		} else {
			const opensection=this.activeSections;
			console.log('opensection',JSON.stringify(opensection));
			for(var i=0; i<this.activeSections.length; i++){
				var item=this.activeSections[i];
				console.log('item',item);
				if (!this.isagency && item==='address-contact') {this.getAddressContactInfo();}
				if (!this.isprofile && item==='business-profile-specialization' ) {this.getProfileContactInfo();}
			};        
		}
	}

	getCompanyContactInfo(){
		console.log('this.accountInfo',JSON.stringify(this.accountInfo));
		fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
		getNameCompanyDetails({
				 accountId: this.accountInfo.Id,
				 isLabel:true
		})
		.then(result => {
			this.company=result;
			this.ownership = result.accountRoles;
			this.companytype=this.setNone(this.company.companyType);
			this.inoperation=this.setNone(this.company.inOperationsSince);
			this.iscompany=true;
			console.log('getCompanyContactInfo:result',JSON.stringify(result));
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		})
		.catch(error => {
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
			console.log('getCompanyContactInfo:error',error);
			this.modalDefaultMessage='Oops! something happened, please retry.'
			this.modalAction='OK';
			this.showConfimationModal=true;
		});
	}

	//result {"address":"15 Rue Papineau West","city":"Montréal","citygeonameId":"aCX4E00000001rEWAQ","country":{"Id":"a0n4E000001Ql2zQAC","label":"Canada","value":"CA"},"email":"lorem@ipsum.com","mailingAddress":"33 Expedia Avenue","mailingCity":"Seattle","mailingcitygeonameId":"aCX4E00000001rJWAQ","mailingCountry":{"Id":"a0n4E0000018PutQAE","label":"United States","value":"US"},"mailingPostalCode":"98888","mailingStateProvince":{"Id":"a444E000000DQzpQAG","label":"Washington","value":"US-WA"},"managerFirstName":"Lorem","managerLastName":"Ipsum","name":"Bottas Racing Inc.","phone":"15148740202","postalCode":"H2V4T8","preferredLanguage":"ENG","stateProvince":{"Id":"a444E000000IsvnQAC","label":"Quebec","value":"CA-QC"},"website":"www.loremipsum.com"}
	getAddressContactInfo(){
		console.log('this.accountInfo',JSON.stringify(this.accountInfo));
		fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
		getAddressContactDetails({
				 accountId: this.accountInfo.Id
		})
		.then(result => {
			this.agency=result;
			this.email=this.setNone(this.agency.email);
			this.phone=this.setNone(this.agency.phone);
			this.fax=this.setNone(this.agency.fax);
			this.website=this.setNone(this.agency.website);
			this.preferredlanguage = this.setlanguage(this.agency.preferredLanguage);
			this.isagency=true;
			console.log('getAddressContactInfo:result',JSON.stringify(result));
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		})
		.catch(error => {
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
			console.log('getAddressContactInfo:error',error);
			this.modalDefaultMessage='Oops! something happened, please retry.'
			this.modalAction='OK';
			this.showConfimationModal=true;
		});
	}

	setlanguage(value){
		if (value==='ENG') {return 'English';}
		if (value==='FRE') {return 'French';}
		if (value==='SPA') {return 'Spanish';}
		return 'n/a';
	}
	
	joinList(xlist){
			let rlist='';
			xlist.forEach(function(item){
				 if (rlist===''){
						 rlist +=item.label;
				 }else{
						 rlist +=', '+item.label;
				 }
			});
			return rlist;
	}
	getProfileContactInfo(){
		console.log('this.accountInfo',JSON.stringify(this.accountInfo));
		fireEvent(this.pageRef,'spinnerListener', {payload:{show:true}});
		getBusinessProfileSpecialization({
				 accountId: this.accountInfo.Id,
				 isLabel: true
		})
		.then(result => {
			this.profile=result;
			
			this.gds = this.joinList(result.businessProfile.values.gds.values);
			
			this.noffices = result.businessProfile.values.numberOffices.values;
			this.nemployees = result.businessProfile.values.numberEmployees.values;
			this.fmarkets=result.businessProfile.values.marketFocus.values;
			this.sales=result.businessProfile.values.salesMix.values;
			this.travels=result.businessProfile.values.travelSales.values;
			this.pactivities =result.businessProfile.values.principalActivities.values;
			this.destinations = this.joinList(result.businessSpecialization.values.destinationSpecialties.values);
			this.smarkets = this.joinList(result.businessSpecialization.values.marketSpecialties.values);
			this.percentages=result.businessSpecialization.values.percentageBreakdown.values;
			
			this.noffices=this.setNone(this.noffices);
			this.nemployees=this.setNone(this.nemployees);
			this.gds=this.setNone(this.gds);
			
			this.travels=this.setNone(this.travels);
			this.smarkets=this.setNone(this.smarkets);
			this.destinations=this.setNone(this.destinations);
			
			this.isprofile=true;
			console.log('getProfileContactInfo:result',JSON.stringify(result));
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
		})
		.catch(error => {
			fireEvent(this.pageRef,'spinnerListener', {payload:{show:false}});
			console.log('getAddressContactInfo:error',error);
			this.modalDefaultMessage='Oops! something happened, please retry.'
			this.modalAction='OK';
			this.showConfimationModal=true;
		});
	}
 
	handleBackToHOClick(event){
		// Prevents the anchor element from navigating to a URL.
		event.preventDefault();
		window.scrollTo(0,0);
		//when selecting a branch the top must become the branch 
		fireEvent(this.pageRef,'manageMenuListener', {type:'SELECT_CANCEL',payload:{detail: null }});
	}

}
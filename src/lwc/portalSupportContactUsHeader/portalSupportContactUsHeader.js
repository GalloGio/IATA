import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLiveAgentButton from '@salesforce/apex/PortalSupportReachUsCtrl.getLiveAgentButton';
import getContactInfo from '@salesforce/apex/PortalSupportReachUsCtrl.getContactInfo';
import getCountryList from '@salesforce/apex/PortalSupportReachUsCtrl.getCountryList';
import getEmergencyDependencies from '@salesforce/apex/PortalSupportReachUsCtrl.getEmergencyDependencies';
import getCaseTypeAndCountry from '@salesforce/apex/PortalSupportReachUsCtrl.getCaseTypeAndCountry';
import getCallUsPhoneNumber from '@salesforce/apex/PortalSupportReachUsCtrl.getCallUsPhoneNumber';

//import getAllPickListValues from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';
import getTopicValues from '@salesforce/apex/PortalSupportReachUsCtrl.getTopicsWithL2Dep';
import getL2Topics from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getL2Topics';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage, getParamsFromPage } from 'c/navigationUtils';


// Import custom labels
import csp_SupportReachUs_IntentionOnThisPage from '@salesforce/label/c.csp_IntentionOnThisPage';
import csp_SupportReachUs_ChooseOption from '@salesforce/label/c.csp_ChooseOption';
import csp_SupportReachUs_Ask_Label from '@salesforce/label/c.csp_SupportReachUs_AskTile';
import csp_SupportReachUs_Concern_Label from '@salesforce/label/c.csp_Concern_Label';
import csp_SupportReachUs_Compliment_Label from '@salesforce/label/c.csp_Compliment_Label';
import csp_SupportReachUs_Suggest_Label from '@salesforce/label/c.csp_Suggest_Label';
import csp_SupportReachUs_SupportCategoriesInfo from '@salesforce/label/c.csp_SupportCategoriesInfo';
import csp_SupportReachUs_ActionIndicator from '@salesforce/label/c.csp_ActionIndicator';
import csp_SupportReachUs_Topic_Label from '@salesforce/label/c.ISSP_F2CTopic';
import csp_SupportReachUs_ActionForCategoryPicklist from '@salesforce/label/c.csp_ActionForCategoryPicklist';
import csp_SupportReachUs_ActionForTopicPicklist from '@salesforce/label/c.csp_ActionForTopicPicklist';
import csp_SupportReachUs_Sub_Topic_Label from '@salesforce/label/c.csp_Sub_Topic_Label';
import csp_SupportReachUs_toSelectSubTopicPicklist from '@salesforce/label/c.csp_toSelectSubTopic';
import csp_SupportReachUs_Country_Label from '@salesforce/label/c.Country';
import csp_SupportReachUs_CountryOrRegionIndicator from '@salesforce/label/c.csp_CountryOrRegionIndicator';
import csp_SupportReachUs_IsEmergency from '@salesforce/label/c.csp_IsEmergency';
import csp_SupportReachUs_btn_Support_Label from '@salesforce/label/c.csp_btn_Support_Label';
import csp_SupportReachUs_Support_Label from '@salesforce/label/c.csp_Support_Label';
import csp_SupportReachUs_Options_Label from '@salesforce/label/c.csp_Options_Label';
import csp_SupportReachUs_Suggestion_label from '@salesforce/label/c.csp_Suggestion_label';
import csp_SupportReachUs_Case_Panel_label from '@salesforce/label/c.csp_Case_Panel_label';
import csp_SupportReachUs_Case_Panel_sub_label from '@salesforce/label/c.csp_Case_Panel_sub_label';
import csp_SupportReachUs_Chat_Panel_label from '@salesforce/label/c.csp_Chat_Panel_label';
import csp_SupportReachUs_Chat_Panel_sub_label from '@salesforce/label/c.csp_Chat_Panel_sub_label';
import csp_SupportReachUs_Call_Panel_label from '@salesforce/label/c.csp_Call_Panel_label';
import csp_SupportReachUs_Call_Panel_sub_label from '@salesforce/label/c.csp_Call_Panel_sub_label';
import csp_SupportReachUs_Chat_With_Us from '@salesforce/label/c.LVA_ChatWithUs';
import csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL from '@salesforce/label/c.ISSP_Topics_To_Exclude_Country_PL';
import csp_SupportReachUs_Category from '@salesforce/label/c.csp_SupportReachUs_Category';
import csp_SupportReachUs_GoToHomepage from '@salesforce/label/c.csp_GoToHomepage';
import csp_SupportReachUs_GoToSupport from '@salesforce/label/c.csp_GoToSupport';
import csp_SupportReachUs_ComplimentInfo from '@salesforce/label/c.csp_ComplimentInfo';
import csp_SupportReachUs_Compliment from '@salesforce/label/c.csp_Compliment';
import IDCard_FillAllFields from '@salesforce/label/c.IDCard_FillAllFields';
import CSP_L2_Requested_Modal_Title from '@salesforce/label/c.CSP_L2_Requested_Modal_Title';
import CSP_L2_Requested_Modal_Message from '@salesforce/label/c.CSP_L2_Requested_Modal_Message';
import CSP_L2_Requested_Modal_Complete from '@salesforce/label/c.CSP_L2_Requested_Modal_Complete';
import CSP_L2_Requested_Modal_Cancel from '@salesforce/label/c.CSP_L2_Requested_Modal_Cancel';

import CSP_Emergency_Selected_Reason1 from '@salesforce/label/c.CSP_Emergency_Selected_Reason1';
import CSP_Emergency_Selected_Reason4 from '@salesforce/label/c.CSP_Emergency_Selected_Reason4';
import CSP_Emergency_Selected_Reason3 from '@salesforce/label/c.CSP_Emergency_Selected_Reason3';
import CSP_Emergency_Selected_Reason2 from '@salesforce/label/c.CSP_Emergency_Selected_Reason2';
import CSP_Emergency_Selected_Message from '@salesforce/label/c.CSP_Emergency_Selected_Message';
import CSP_Call_Tile_SubLabel from '@salesforce/label/c.CSP_Call_Tile_SubLabel';
import LVA_CallUsDial from '@salesforce/label/c.LVA_CallUsDial';
import LVA_CallUsAvailableHours from '@salesforce/label/c.LVA_CallUsAvailableHours';

// Import standard salesforce labels
import csp_caseNumber from '@salesforce/schema/Case.CaseNumber';
import csp_caseSubject from '@salesforce/schema/Case.Subject';
import csp_caseDescription from '@salesforce/schema/Case.Description';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalSupportReachUs extends NavigationMixin(LightningElement) {
	alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';

	//track variables
	@track isLoaded = true;
	@track caseDetails;
	@track categoryOptions = [];
	@track category;
	@track topic;
	@track topicOptions = [];
	@track recentTopicOptions = [];
	@track subTopic;
	@track topicCB = false;
	@track countryCB = false;
	@track optionsButton = false;
	@track supOptionsPanel = false;
	@track countryValue = '';
	@track compliment_countryValue = '';
	@track emergencyButton = false;
	@track isEmergency = false;
	@track isQuestion = true;
	@track isCompliment = false;
	@track question_selected;
	@track question_unselected;
	@track concern_selected;
	@track concern_unselected;
	@track compliment_selected;
	@track compliment_unselected;
	@track showModal = false;
	@track callUsPhoneNumberConfigs = [];
	@track phoneNumber = '';

	@track showRecentCasesList = true;
	@track isCaseOpt = true;
	@track isChatOpt = false;
	@track isCallOpt = false;
	@track ignoreCountry = false;
	//@track suggestion;

	//global variables
	pageParams;
	liveAgentButtonInfo;
	myResult;
	contact;
	@track userInfo;
	allData = {};
	categorization = {};
	emergencyCategories = [];
	recordTypeAndCountry;
	myliveAgentButtonInfo;
	l2topics = [];
	topicEN;
	
	// Level 2 registration variables
	@track isFirstLevelUser;
	@track displaySecondLevelRegistrationPopup = false;
	@track displaySecondLevelRegistration = false;
	level2RegistrationTrigger = 'topic';

	//label construct
	@track label = {
		csp_SupportReachUs_IntentionOnThisPage,
		csp_SupportReachUs_ChooseOption,
		csp_SupportReachUs_Ask_Label,
		csp_SupportReachUs_Concern_Label,
		csp_SupportReachUs_Compliment_Label,
		csp_SupportReachUs_Suggest_Label,
		csp_SupportReachUs_SupportCategoriesInfo,
		csp_SupportReachUs_ActionIndicator,
		csp_SupportReachUs_Topic_Label,
		csp_SupportReachUs_ActionForCategoryPicklist,
		csp_SupportReachUs_ActionForTopicPicklist,
		csp_SupportReachUs_Sub_Topic_Label,
		csp_SupportReachUs_toSelectSubTopicPicklist,
		csp_SupportReachUs_Country_Label,
		csp_SupportReachUs_CountryOrRegionIndicator,
		csp_SupportReachUs_IsEmergency,
		csp_SupportReachUs_btn_Support_Label,
		csp_SupportReachUs_Support_Label,
		csp_SupportReachUs_Options_Label,
		csp_SupportReachUs_Suggestion_label,
		csp_SupportReachUs_Case_Panel_label,
		csp_SupportReachUs_Case_Panel_sub_label,
		csp_SupportReachUs_Chat_Panel_label,
		csp_SupportReachUs_Chat_Panel_sub_label,
		csp_SupportReachUs_Call_Panel_label,
		csp_SupportReachUs_Call_Panel_sub_label,
		csp_SupportReachUs_Chat_With_Us,
		csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL,
		csp_SupportReachUs_Category,
		csp_SupportReachUs_GoToHomepage,
		csp_SupportReachUs_GoToSupport,
		csp_SupportReachUs_ComplimentInfo,
		csp_SupportReachUs_Compliment,
		csp_caseNumber,
		csp_caseSubject,
		csp_caseDescription,
		IDCard_FillAllFields,
		CSP_L2_Requested_Modal_Title,
		CSP_L2_Requested_Modal_Message,
		CSP_L2_Requested_Modal_Complete,
		CSP_L2_Requested_Modal_Cancel,
		CSP_Emergency_Selected_Reason1,
		CSP_Emergency_Selected_Reason4,
		CSP_Emergency_Selected_Reason3,
		CSP_Emergency_Selected_Reason2,
		CSP_Emergency_Selected_Message,
		CSP_Call_Tile_SubLabel,
		LVA_CallUsDial,
		LVA_CallUsAvailableHours
	}

	//links for images
	@track caseIcon_selected = CSP_PortalPath + 'CSPortal/Images/Icons/caseIcon_checked.svg';
	@track caseIcon_unselected = CSP_PortalPath + 'CSPortal/Images/Icons/caseIcon_unchecked.svg';
	@track chatIcon_selected = CSP_PortalPath + 'CSPortal/Images/Icons/chatIcon_checked.svg';
	@track chatIcon_unselected = CSP_PortalPath + 'CSPortal/Images/Icons/chatIcon_unchecked.svg';
	@track callIcon_selected = CSP_PortalPath + 'CSPortal/Images/Icons/callIcon_checked.svg';
	@track callIcon_unselected = CSP_PortalPath + 'CSPortal/Images/Icons/callIcon_unchecked.svg';

	@track rendered = false;

	get l2topicsList() {
		if (this.l2topics.length == 0) {
			
			//gets the list of topics that require L2 registration
			getL2Topics()
				.then(result => {
					var list = JSON.parse(JSON.stringify(result));

					this.l2topics = new Set();
					for (let i = 0; i < list.length; i++) {
						this.l2topics.add(list[i].DataTopicName__c);
					}
					return this.l2topics;

				})
		} else {
			return this.l2topics;
		}

	}

	//gets Country for picklist
	@wire(getCountryList, {})
	wiredCountryList(results) {
		if (results.data) {
			let myResult = JSON.parse(JSON.stringify(results.data));

			//first element on the picklist
			let myCountryOptions = [];
			let auxmyCountryOptions = [];
			//ex: {label: My Topic, value: my_topic__c}
			Object.keys(myResult).forEach(function (el) {
				auxmyCountryOptions.push({ label: myResult[el], value: el });
			});

			//used to order alphabetically
			auxmyCountryOptions.sort((a, b) => { return (a.label).localeCompare(b.label) });

			myCountryOptions = myCountryOptions.concat(auxmyCountryOptions);

			//set global with the options for later use
			this.countryOptions = myCountryOptions;
		}
	}




	//old doInit() in aura. Fires once the component is loaded.
	connectedCallback() {

		let getTopicList = new Promise((resolve, reject) => {
			getTopicValues()
				.then(result => {
					this.myResult = JSON.parse(result);

					//Array to consume category options
					let myTopicsList = [];

					//Set first value on the list
					for (const item of this.myResult) {						
						myTopicsList.push({
							label: item.topicLabel,
							value: item.topicName,
							reqL2: item.reqL2 === 'true',
							labelEn: item.topicLabelEN,
							title: item.topicLabel,
							isRecentTopic :item.recentTopic==='true'
						});

					}
					//used to order alphabetically

					myTopicsList.sort(function (a, b) {
						var textA = a.label.toUpperCase();
						var textB = b.label.toUpperCase();
						return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
					});

					this.topicOptions = myTopicsList;
					this.recentTopicOptions=this.topicOptions.filter(item => {
						return item.isRecentTopic===true;
					});
				

					resolve();
				})
				.catch(error => {
					//throws error
					this.error = error;
					this.toggleSpinner();
					console.log('Error: ', error);
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Error',
							message: JSON.parse(JSON.stringify(error)).body.message,
							variant: 'error',
							mode: 'pester'
						})
					);
					reject();
				})


		});

		let getContactInformation = new Promise((resolve, reject) => {
			//Get contact information from the logged user
			getContactInfo()
				.then(result => {
					this.userInfo=result;
					this.contact = result.Contact;
					this.showRecentCasesList = result.Profile.Name.search('Airline') == -1; // In case airline user, hide recent List
					this.isFirstLevelUser = this.contact.Account.Is_General_Public_Account__c;
					resolve();
				});
		});
		Promise.all([
			getTopicList,
			getContactInformation]).then(result => {
				this.rendered = true;
				let pageParams = getParamsFromPage();

				if (pageParams.countryISO === undefined || pageParams.countryISO === '') {
					this.countryValue = this.contact.ISO_Country__r!== undefined?this.contact.Account.Country_ISO_Code__c:null;
				} else {
					this.countryValue = pageParams.countryISO;
				}
				if ('topic' in pageParams && pageParams.topic !== '') {
					const checkTopic = obj => obj.value === pageParams.topic;
					if (!this.topicOptions.some(checkTopic)) {
						this.toggleSpinner();
						return; // if the user doesn't have access to the topic, stays on page without doing any action
					}
				}

				this.topic = pageParams.topic;
				let isEmergency = pageParams.emergency === 'true';
				if (this.isFirstLevelUser && this.topic !== undefined && this.topic !== '') {
					if (this.requiresL2(this.topic)) {
						this.displaySecondLevelRegistrationPopup = true;
						this.toggleSpinner();
						return;
					}
					let even = { target: { value: this.topic, isEmergency: isEmergency } };
					this.toggleSpinner();
					this.topicHandler(even);
				}
				else if (this.topic !== undefined && this.topic !== '') {
					let even = { target: { value: this.topic, isEmergency: isEmergency } };
					this.toggleSpinner();
					this.topicHandler(even);
				}
				else {
					this.toggleSpinner();
				}
			});

	}

	//checks if selected topic requires L2 registration
	requiresL2(topic) {
		return this.topicOptions.some(obj => obj.value === topic && obj.reqL2 === true);
	}

	handleTopicSelection(event){
		
		let even = { target: {value : event.detail.value }};
		this.topicHandler(even);
	}
	//handles topic selection
	topicHandler(event) {
		//set topic globally
		this.toggleSpinner();		
		this.topic = event.target.value;
		this.topicEN=this.topicOptions.filter(obj => {return obj.value === this.topic})[0].labelEn;
		this.isEmergency = event.target.isEmergency ? event.target.isEmergency : false;

		if (this.isFirstLevelUser && this.requiresL2(this.topic)) {
			this.displaySecondLevelRegistrationPopup = true;
			this.toggleSpinner();
			return;
		}

		//if emergency Categories are not loaded yet
		if (this.emergencyCategories.length == 0) {

			getEmergencyDependencies()
				.then(result => {
					this.emergencyCategories = JSON.parse(JSON.stringify(result));
					this.emergencyButton = this.emergencyCategories.some(obj => obj.Name === this.topic + ('__c'));
					this.toggleSpinner();
					this.supportOptionsHandler();
				});
		} else {
			this.emergencyButton = this.emergencyCategories.some(obj => obj.Name === this.topic + ('__c'));

			this.updateTile('001');//select case by default
			this.toggleSpinner();
			this.supportOptionsHandler();
		}

		let divToTop = this.template.querySelectorAll('.topic')[0].offsetTop;
		window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });

	}

	//handles country selection
	countryHandler(event) {
		this.countryValue = event.target.value;
		this.supportOptionsHandler();
		this.template.querySelector('[data-name="countryselection"]').classList.remove('slds-has-error');
	}
	handleMissingCountry(event){
		this.template.querySelector('[data-name="countryselection"]').classList.add('slds-has-error');
	}


	//handles the support button click 
	supportOptionsHandler() {
		//fire event to activate spinner on Aura Wrapper       
		this.toggleSpinner();

		let getCaseCountrRT = new Promise((resolve, reject) => {
			getCaseTypeAndCountry({ contactInfo: this.contact, country: this.countryValue })
				.then(result => {
					this.recordTypeAndCountry = JSON.parse(JSON.stringify(result));
					resolve();

				}).catch(() => {
					reject();
				});
		});

		//Gets all live agent information depending on the selected data
		let getLvaInfo = new Promise((resolve, reject) => {

			getLiveAgentButton({ topicName: this.topic, country: this.countryValue, contactInfo: this.contact, isEmergency: this.isEmergency })
				.then(result => {
					this.myliveAgentButtonInfo = JSON.parse(JSON.stringify(result));
					resolve();
				}).catch(() => {
					reject();
				});
		});

		Promise.all([
			getCaseCountrRT,
			getLvaInfo]).then(() => {
				this.sendDataForLiveAgent();
				this.supOptionsPanel = true;
				this.toggleSpinner();
			});

		this.getPhoneNumber();
	}


	//Sends all data selected to Live Agent so call can be performed
	sendDataForLiveAgent() {
		let allData = {};

		//retrieves data and sends through an event to wrapper aura component.

		allData.myliveAgentButtonInfo = this.myliveAgentButtonInfo;
		allData.recordTypeAndCountry = this.recordTypeAndCountry;
		allData.CountryISO = this.countryValue;
		allData.Emergency = this.isEmergency;
		allData.Contact = this.contact;
		allData.Topic = this.topic;
		allData.IsFirstLevelUser = this.isFirstLevelUser;
		allData.TopicEN = this.topicEN;
		allData.UserInfo = this.userInfo;
		//test
		allData.showChat = this.isChatOpt && this.myliveAgentButtonInfo && this.myliveAgentButtonInfo.length > 0;

		// Fire the custom event
		const allDataChange = new CustomEvent('alldatachange', {
			detail: { allData }
		});
		// Fire the custom event
		this.dispatchEvent(allDataChange);
	}

	//method to execute spinner on aura wrapper
	toggleSpinner() {
		const toggleSpinner = new CustomEvent('toggleSpinner');
		// Fire the custom event
		this.dispatchEvent(toggleSpinner);
	}

	//clickhandler for the panels
	tileClickHandler(event) {
		//grabs every panel
		let tileId = event.target.attributes.getNamedItem('data-id') ? event.target.attributes.getNamedItem('data-id').value : '001';
		this.updateTile(tileId);

		this.sendDataForLiveAgent();

	}

	updateTile(tileId) {
		let tileList = this.template.querySelectorAll('[data-option-tile]');

		//paints every panel of the default white color
		for (let i = 0; i < tileList.length; i++) {
			tileList[i].classList.remove('active_panel');
			tileList[i].classList.add('default_panel');
			tileList[i].querySelector('[data-checked-icn]').classList.add('slds-hide');
			tileList[i].querySelector('[data-unchecked-icn]').classList.remove('slds-hide');

		}

		if (tileId === '001') {
			this.isCaseOpt = true;
			this.isChatOpt = false;
			this.isCallOpt = false;
		}
		else if (tileId === '002') {
			this.isCaseOpt = false;
			this.isChatOpt = true;
			this.isCallOpt = false;
		}
		else if (tileId === '003') {
			this.isCaseOpt = false;
			this.isChatOpt = false;
			this.isCallOpt = true;
		}

		//grabs the clicked panel and paints with blue color. Identified by it's data-id.
		let mod = this.template.querySelector('[data-id="' + tileId + '" ]');
		mod.classList.remove('default_panel');
		mod.classList.add('active_panel');
		mod.querySelector('[data-checked-icn]').classList.remove('slds-hide');
		mod.querySelector('[data-unchecked-icn]').classList.add('slds-hide');
	}

	handleIsEmergency(event) {
		this.isEmergency = event.detail.value;
		this.supportOptionsHandler();
	}

	//navigates to homepage
	navigateToHomepage() {
		this[NavigationMixin.GenerateUrl]({
			type: "standard__namedPage",
			attributes: {
				pageName: "home"
			}
		}).then(
			url => navigateToPage(url, {})
		);
	}

	//navigates to support reach us
	navigateToSupport() {
		navigateToPage("support-reach-us");
	}

	getCallUsPhoneNumber() {
		this.toggleSpinner();
		getCallUsPhoneNumber()
			.then(result => {
				this.toggleSpinner();
				this.callUsPhoneNumberConfigs = JSON.parse(JSON.stringify(result));
				this.getPhoneNumber();
			});
	}

	getPhoneNumber() {

		if (this.callUsPhoneNumberConfigs.length == 0) {
			//lazy loading records upon need
			this.getCallUsPhoneNumber();
		}
		else {
			let sector;
			if (this.topic === 'E_F') {
				sector = 'All';
			} else {
				sector = this.contact.Account.Sector__c;
			}

			let countryExclusion = this.label.csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL.split(',');
			let countrySel = countryExclusion.includes(this.topic + '__c') ? null : this.countryValue;

			let numberMatches = this.callUsPhoneNumberConfigs.filter(item => {
				//captures the one value we need based on the conditions bellow
				//We have a list of PhoneNumberConfigs from the custom meta data type with the same name and we extract one value from it.

				return (item.Topic
					&& item.Topic === (this.topic + '__c')
					&& (item.Sector === sector)
					&& (item.IsoCountry === countrySel)) // ---- First Condition ------//

					|| (item.Topic
						&& item.Topic === (this.topic + '__c')
						&& item.Sector === sector
						&& (item.IsoCountry === 'All' || item.IsoCountry === '' || item.IsoCountry === undefined)) // ---- Second Condition ------//

					|| (item.Topic
						&& item.Topic === (this.topic + '__c')
						&& (item.Sector === 'All' || item.Sector === '' || item.Sector === undefined)
						&& item.IsoCountry === countrySel) // ---- Third Condition ------//

					|| (item.Topic
						&& item.Topic === (this.topic + '__c')
						&& (item.Sector === 'All' || item.Sector === '' || item.Sector === undefined)
						&& (item.IsoCountry === 'All' || item.IsoCountry === '' || item.IsoCountry === undefined)) // ---- Fourth Condition ------//

					|| (item.Sector
						&& (item.Topic === '' || item.Topic === undefined)
						&& (item.Sector === sector)
						&& (item.IsoCountry === countrySel)) // ---- Fifth Condition ------//

					|| (item.Sector
						&& (item.Topic === '' || item.Topic === undefined)
						&& (item.Sector === sector)
						&& (item.IsoCountry === 'All' || item.IsoCountry === '' || item.IsoCountry === undefined)) // ---- Sixth Condition ------//

					|| (item.DeveloperName
						&& item.DeveloperName === 'LVA_CallUs_GEN'); // ---- Seventh Condition ------//
			});
			this.phoneNumber = numberMatches.length > 0 ? numberMatches[0] : null;
		}
	}

	get showCallUs() {
		return this.phoneNumber != null;
	}

	hideRecentCasesList() {
		this.showRecentCasesList = false;
	}

	// Level 2 registration methods
	secondLevelRegistrationCompletedAction1() {
		navigateToPage(CSP_PortalPath, {});
	}

	secondLevelRegistrationCompletedAction2() {
		let page = "support-reach-us?topic=" + this.topic;

		navigateToPage(page);
	}

	cancelSecondLevelRegistration() {
		let page = "support-reach-us";

		navigateToPage(page);
	}

	showSecondLevelRegistration() {
		this.displaySecondLevelRegistrationPopup = false;
		this.displaySecondLevelRegistration = true;
	}
}
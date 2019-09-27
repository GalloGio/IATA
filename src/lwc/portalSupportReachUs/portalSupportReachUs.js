import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLiveAgentButton from '@salesforce/apex/PortalSupportReachUsCtrl.getLiveAgentButton';
import getContactInfo from '@salesforce/apex/PortalSupportReachUsCtrl.getContactInfo';
import getCountryList from '@salesforce/apex/PortalSupportReachUsCtrl.getCountryList';
import getEmergencyDependencies from '@salesforce/apex/PortalSupportReachUsCtrl.getEmergencyDependencies';
import getCaseTypeAndCountry from '@salesforce/apex/PortalSupportReachUsCtrl.getCaseTypeAndCountry';
import insertCase from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.insertCase';
import createCase from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.createCase';
import getCallUsPhoneNumber from '@salesforce/apex/PortalSupportReachUsCtrl.getCallUsPhoneNumber';

import getAllPickListValues from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';

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

// Import standard salesforce labels
import csp_caseNumber from '@salesforce/schema/Case.CaseNumber';
import csp_caseSubject from '@salesforce/schema/Case.Subject';
import csp_caseDescription from '@salesforce/schema/Case.Description';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalSupportReachUs extends NavigationMixin(LightningElement) {
    //track variables
    @track isLoaded = true;
    @track caseDetails;
    @track categoryOptions = [];
    @track category;
    @track topic;
    @track topicOptions = [];
    @track subTopicOptions = [];
    @track subTopic;
    @track topicCB = false;
    @track subTopicCB = false;
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
    @track callUsPhoneNumberConfigs;
    @track phoneNumber = [];

    @track showHideRecentCasesList = false;
    //@track suggestion;

    //global variables
    pageParams;
    liveAgentButtonInfo;
    myResult;
    contact;
    allData = {};
    categorization = {};
    emergencyCategories = [];
    recordTypeAndCountry;
    myliveAgentButtonInfo;
    caseInitiated;

    //label construct
    label = {
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
        IDCard_FillAllFields
    }

    //links for images
    iconsBaseLink = CSP_PortalPath + 'CSPortal/Images/Support/';
    iconsExtension = '.svg';



    //old doInit() in aura. Fires once the component is loaded.
    connectedCallback() {

        //Data Pickup methods

        this.getCountryList();

        this.getAllPickListValues();

        this.getEmergencyDependencies();

        this.getContact();

        this.getCallUsPhoneNumber();

        //visual aspect for tiles
        this.question_selected = this.iconsBaseLink + 'question_selected' + this.iconsExtension;
        this.question_unselected = this.iconsBaseLink + 'question_unselected' + this.iconsExtension;
        this.concern_selected = this.iconsBaseLink + 'concern_selected' + this.iconsExtension;
        this.concern_unselected = this.iconsBaseLink + 'concern_unselected' + this.iconsExtension;
        this.compliment_selected = this.iconsBaseLink + 'compliment_selected' + this.iconsExtension;
        this.compliment_unselected = this.iconsBaseLink + 'compliment_unselected' + this.iconsExtension;
        //this.suggestion = this.iconsBaseLink + 'suggestion_unselected' + this.iconsExtension;
    }

    //get the Topic Values for picklist
    getAllPickListValues() {
        //returns object
        getAllPickListValues()
            .then(result => {
                this.myResult = JSON.parse(JSON.stringify(result));
                //Auxiliary Map
                const map = new Map();

                //Array to consume category options
                let myCategoryOptions = [];

               //Set first value on the list
               // let auxmyCategoryOptions = [];
               for (const item of this.myResult) {
                   if (!map.has(item.categoryLabel) && item.categoryLabel !== 'All') {
                       map.set(item.categoryLabel, true);
                       myCategoryOptions.push({
                           label: item.categoryLabel,
                           value: item.categoryName
                       });
                   }
               }
               //used to order alphabetically

               this.categoryOptions = myCategoryOptions;
              

                //Set the category if in URL
                this.pageParams = getParamsFromPage();
                if ('category' in this.pageParams && this.pageParams.category !== '') {
                    const checkCategory = obj => obj.value === this.pageParams.category;
                    if (this.categoryOptions.some(checkCategory)) {
                        this.category = this.pageParams.category;
                        this.topicCB = true;
                        this.topicValuesGetter();
                    } else {
                        this.topicCB = false;
                        this.subTopicCB = false;
                        this.pageParams.category = '';
                        this.pageParams.topic = '';
                        this.pageParams.subtopic = '';
                    }
                }
                this.toggleSpinner();
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
            })
    }

    getEmergencyDependencies() {
        this.toggleSpinner();

        getEmergencyDependencies()
            .then(result => {
                this.toggleSpinner();

                this.emergencyCategories = JSON.parse(JSON.stringify(result));
            });
    }

    //gets Country for picklist
    getCountryList() {
        this.toggleSpinner();
        getCountryList()
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));

                //first element on the picklist
                let myCountryOptions = [];
                let auxmyCountryOptions = [];
                //ex: {label: My Topic, value: my_topic__c}
                Object.keys(myResult).forEach(function (el) {
                    auxmyCountryOptions.push({ label: myResult[el], value: el });
                });
                this.toggleSpinner();

                //used to order alphabetically
                auxmyCountryOptions.sort((a, b) => { return (a.label).localeCompare(b.label) });

                myCountryOptions = myCountryOptions.concat(auxmyCountryOptions);

                //set global with the options for later use
                this.countryOptions = myCountryOptions;


            })
            .catch(error => {
                //throws error
                this.error = error;
                this.toggleSpinner();
                console.log('Error: ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.parse(JSON.stringify(error)),
                        variant: 'error',
                        mode: 'pester'
                    })
                );
            });
    }

    //gets Contact Info
    getContact() {
        this.toggleSpinner();
        getContactInfo()
            .then(result => {
                this.toggleSpinner();
                this.contact = JSON.parse(JSON.stringify(result));
            });
    }

    categoryHandler(event) {
        //set category global value
        this.category = event.target.value;
        if (this.category !== "") {
            //Show subTopic Picklist/Combobox
            this.topicCB = true;
            //Set inital value topic Picklist/Combobox
            this.topic = '';
            //Set inital value subTopic Picklist/Combobox
            this.subTopic = '';
            //Remove Parameters. Reload is necessary

            //Set inital value country Picklist/Combobox
            this.countryValue = '';

            let divToTop = this.template.querySelectorAll('.category')[0].offsetTop;
            window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });

        } else {
            //Hide Topic Picklist/Combobox
            this.topicCB = false;
        }
        //Event to close the options area (on aura wrapper)
        this.closeOptionsPanel();

        //Hide Subtopic Picklist/Combobox
        this.subTopicCB = false;

        //Hide Options Button
        this.optionsButton = false;
        //Hide Options Panel
        this.supOptionsPanel = false;
        //Hide Country Picklist/Combobox
        this.countryCB = false;
        //sets emergency to the default value
        this.emergencyButton = false;
        this.isEmergency = false;

        //get topics
        this.topicValuesGetter();
    }

    //Set the topic values
    topicValuesGetter() {

        //Auxiliary Map
        const map = new Map();
        //Array to consume the Topic options
        let myTopicOptions = [];

        //first element on the picklist
        // let auxmyTopicOptions = [];
        for (const item of this.myResult) {
            if (!map.has(item.topicLabel) && item.categoryName === this.category) {
                map.set(item.topicLabel, true);
                myTopicOptions.push({
                    label: item.topicLabel,
                    value: item.topicName
                });
            }
        }

        //used to order alphabetically
        //set the options of picklist
        this.topicOptions = myTopicOptions;

        //set Topic value if included in URL
        if ('topic' in this.pageParams && this.pageParams.topic !== '') {
            const checkTopic = obj => obj.value === this.pageParams.topic;
            if (this.topicOptions.some(checkTopic)) {

                this.topic = this.pageParams.topic;
                this.subTopicCB = true;
                this.subTopicValuesGetter();
            } else {
                this.subTopicCB = false;
                this.pageParams.subtopic = '';
            }
        } else {
            this.pageParams.subtopic = '';
        }
    }

    //handles topic selection
    topicHandler(event) {
        //set topic globally
        this.topic = event.target.value;
        if (this.topic !== "") {
            //Show subTopic Picklist/Combobox
            this.subTopicCB = true;
            //Set inital value subTopic Picklist/Combobox
            this.subTopic = '';
            //Set inital value country Picklist/Combobox
            this.countryValue = '';

            let divToTop = this.template.querySelectorAll('.topic')[0].offsetTop;
            window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });
        } else {
            //Hide subTopic Picklist/Combobox
            this.subTopicCB = false;
        }

        //Close the options area (on aura wrapper)
        this.closeOptionsPanel();

        //Hide Options Button
        this.optionsButton = false;
        //Hide Options Panel
        this.supOptionsPanel = false;
        //Hide Country Picklist/Combobox
        this.countryCB = false;
        //Hide Emergency button
        this.emergencyButton = false;
        this.isEmergency = false;
        //get subtopics
        this.subTopicValuesGetter();

    }

    //Set the subtopic values 
    subTopicValuesGetter() {

        //Auxiliary Map
        const map = new Map();
        //Array to consume SubTopic Options
        let mySubTopicOptions = [];
        let mySubTopicOptionsAux = [];

        //first element on the picklist
        for (const item of this.myResult) {
            if (!map.has(item.childs) && item.topicName === this.topic && item.categoryName === this.category) {
                Object.keys(item.childs).forEach(function (el) {
                    mySubTopicOptionsAux.push({
                        label: el, value: item.childs[el]
                    });
                })
            }
        }

        //set the options
        this.subTopicOptions = mySubTopicOptions.concat(mySubTopicOptionsAux.reverse());

        //set value of Subtopic if in URL
        if ('subtopic' in this.pageParams && this.pageParams.subtopic !== '') {
            const checkSubTopic = obj => obj.value === this.pageParams.subtopic;
            if (this.subTopicOptions.some(checkSubTopic)) {
                this.subTopic = this.pageParams.subtopic;

                //Excluded country list. 
                let countryExclusion = this.label.csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL.split(',');

                this.countryCB = true;
                if (countryExclusion.includes(this.topic + '__c')) {
                    this.countryCB = false;
                    this.optionsButton = true;
                    if (this.emergencyCategories.some(obj => obj.value === this.topic + ('__c'))
                        && this.emergencyCategories.some(obj => obj.value.includes(this.subTopic + '__c'))) {
                            if(this.isQuestion){
                                this.emergencyButton = true;
                            }
                    }
                }
            } else {
                this.countryCB = false;
                this.pageParams.subtopic = '';
            }
        }
    }

    //handles sub-topic selection (ᵔᴥᵔ)
    subTopicHandler(event) {
        this.subTopic = event.target.value;
        if (this.subTopic !== "") {
            this.optionsButton = false;
            this.countryValue = '';
            this.countryCB = true;
            this.emergencyButton = false;
            this.isEmergency = false;

            let divToTopCountry = this.template.querySelectorAll('.subtopic')[0].offsetTop;
            window.scrollTo({ top: divToTopCountry, left: 0, behavior: 'smooth' });
            //required to not show the country picklist if the selected value is included here
            let countryExclusion = this.label.csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL.split(',');
            if (countryExclusion.includes(this.topic + '__c')) {
                this.countryCB = false;
                this.optionsButton = true;

                if (this.emergencyCategories.find(obj => obj.Name === this.topic + ('__c'))
                    && this.emergencyCategories.find(obj => obj.Subtopic__c.includes(this.subTopic + '__c'))) {
                        if(this.isQuestion){
                            this.emergencyButton = true;
                        }
                }
            }
        } else {
            this.optionsButton = false;
            this.supOptionsPanel = false;
        }
        this.closeOptionsPanel();

    }

    //handles country selection
    countryHandler(event) {
        this.countryValue = event.target.value;
        if (this.countryValue !== "") {
            this.optionsButton = true;
            let divToTop = this.template.querySelectorAll('.country')[0].offsetTop;
            window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });
            if (this.emergencyCategories.find(obj => obj.Name === this.topic + ('__c'))
                && this.emergencyCategories.find(obj => obj.Subtopic__c.includes(this.subTopic + '__c'))) {
                    if(this.isQuestion){
                        this.emergencyButton = true;
                    }
            }
        } else {
            this.optionsButton = false;
            this.emergencyButton = false;
        }
        this.supOptionsPanel = false;

        this.closeOptionsPanel();
    }

    //handles emergency attribution
    handleEmergency() {
        this.isEmergency = !this.isEmergency;
        this.closeOptionsPanel();
    }

    //handles the support button click 
    supportOptionsHandler() {
        //fire event to activate spinner on Aura Wrapper
        this.toggleSpinner();

        getCaseTypeAndCountry({ contactInfo: this.contact, country: this.countryValue })
            .then(result => {
                this.recordTypeAndCountry = JSON.parse(JSON.stringify(result));
                this.getLiveAgentButtonInfo();
            }).catch(error => {
                //throws error
                this.error = error;
                this.toggleSpinner();
                // eslint-disable-next-line no-console
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.parse(JSON.stringify(error)),
                        variant: 'error',
                        mode: 'pester'
                    })
                );
            });
    }

    //Gets all live agent information depending on the selected data
    getLiveAgentButtonInfo() {
        getLiveAgentButton({ topicName: this.topic, country: this.countryValue, contactInfo: this.contact, isEmergency: this.isEmergency })
            .then(result => {
                this.myliveAgentButtonInfo = JSON.parse(JSON.stringify(result));
                this.sendDataForLiveAgent();
                //fire event to activate spinner on Aura Wrapper
                this.toggleSpinner();
            });
    }

    //Sends all data selected to Live Agent so call can be performed
    sendDataForLiveAgent() {

        let allData = {};
        let categorization = {};
        let recordTypeAndCountry = this.recordTypeAndCountry;
        let myliveAgentButtonInfo = this.myliveAgentButtonInfo;
        let contact = this.contact;

        //Shows Options Panel
        let showOptionsPanel = new Promise((resolve, reject) => {
            const showoptions = new CustomEvent('showoptions');
            // Fire the custom event
            this.dispatchEvent(showoptions);

            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        //receive topic and subtopic
        let provideTopic_SubTopic = new Promise((resolve, reject) => {

            categorization.Topic = this.topic;
            categorization.SubTopic = this.subTopic;
            categorization.Category = this.category;

            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        //retrieves data and sends through an event to wrapper aura component.
        let provideAllDataToWrapper = new Promise((resolve, reject) => {
            allData.myliveAgentButtonInfo = myliveAgentButtonInfo;
            allData.recordTypeAndCountry = recordTypeAndCountry;
            allData.CountryISO = this.countryValue;
            allData.categorization = categorization;
            allData.Emergency = this.isEmergency;
            allData.Question = this.isQuestion;
            allData.Contact = contact;

            this.getPhoneNumber();
            if (JSON.parse(JSON.stringify(this.phoneNumber)).length > 0) {
                allData.PhoneNumber = JSON.parse(JSON.stringify(this.phoneNumber))[0];
            } else {
                allData.PhoneNumber = '';
            }

            // Fire the custom event
            const allDataChange = new CustomEvent('alldatachange', {
                detail: { allData },
            });
            // Fire the custom event
            this.dispatchEvent(allDataChange);

            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        //Performs a document scroll down.
        let scrollWindowDown = new Promise((resolve, reject) => {

            let divToTop = this.template.querySelectorAll('.endOfReachUs')[0].offsetTop;
            window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });

            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        let willScrollDown = function () {
            //Show Spinner, Show Options Panel, Get Live Agent, Scroll window down, Hide Spinner
            Promise.all([
                showOptionsPanel,
                provideTopic_SubTopic,
                provideAllDataToWrapper,
                scrollWindowDown]);
        }

        //Execute async actions
        willScrollDown();
    }

    //method to execute spinner on aura wrapper
    toggleSpinner() {
        const toggleSpinner = new CustomEvent('toggleSpinner');
        // Fire the custom event
        this.dispatchEvent(toggleSpinner);
    }

    //method to close options panel on aura wrapper
    closeOptionsPanel() {
        const closeOptions = new CustomEvent('closeoptions');
        // Fire the custom event
        this.dispatchEvent(closeOptions);
    }

    //clickhandler for the panels
    tileClickHandler(event) {
        //grabs every panel
        let elem = [
            this.template.querySelector('[data-id="001"]'),
            this.template.querySelector('[data-id="002"]'),
            this.template.querySelector('[data-id="003"]'),
            //this.template.querySelector('[data-id="004"]')
        ];

        //paints every panel of the default white color
        for (let i = 0; i < elem.length; i++) {
            elem[i].classList.remove('active_panel');
            elem[i].classList.add('default_panel');
        }

        if (event.target.attributes.getNamedItem('data-id').value === '001') {
            this.isQuestion = true;
            this.isConcern = false;
            this.isCompliment = false;
            this.closeOptionsPanel();
            this.resetData();
        }
        else if (event.target.attributes.getNamedItem('data-id').value === '002') {
            this.isQuestion = false;
            this.isConcern = true;
            this.isCompliment = false;
            this.closeOptionsPanel();
            this.resetData();
        }
        else if (event.target.attributes.getNamedItem('data-id').value === '003') {
            this.isQuestion = false;
            this.isConcern = false;
            this.isCompliment = true;
            this.closeOptionsPanel();
            this.resetData();
        }

        //grabs the clicked panel and paints with blue color. Identified by it's data-id.
        let mod = this.template.querySelector('[data-id="' + event.target.attributes.getNamedItem('data-id').value + '" ]');
        mod.classList.remove('default_panel');
        mod.classList.add('active_panel');

    }

    //on changing tabs resets all the data to default values
    resetData() {
        this.category = ''
        this.topic = ''
        this.subTopic = ''
        this.countryValue = ''
        this.topicCB = false;
        this.subTopicCB = false;
        this.subTopicCB = false;
        this.countryCB = false;
        this.optionsButton = false;
        this.emergencyButton = false;
        this.isEmergency = false;
    }

    /*################# COMPLIMENT JS ########################*/

    //handles compliment country selection
    compliment_countryHandler(event) {
        this.compliment_countryValue = event.target.value;
    }

    //grabs subject
    handleSubject(event) {
        this.subject = event.target.value;
    }

    //grabs description
    handleDescription(event) {
        this.description = event.target.value;
    }

    //submits the compliment
    submitCompliment() {
        this.toggleSpinner();

        if (this.compliment_countryValue !== undefined && this.subject !== undefined && this.description !== undefined &&
            this.compliment_countryValue.trim() !== '' && this.subject.trim() !== '' && this.description.trim() !== '') {

            createCase({ countryiso: this.compliment_countryValue, isConcernCase: false, topic: '', subtopic: '' })
                .then(createCaseResult => {
                    this.caseInitiated = JSON.parse(JSON.stringify(createCaseResult));
                    const record = { 'sobjectType': 'Case' };
                    record.RecordTypeId = this.caseInitiated.RecordTypeId;
                    record.Subject = this.subject;
                    record.Compliment__c = true;
                    record.Description = this.description + '\n-COMPLIMENT-';
                    record.BSPCountry__c = this.caseInitiated.Country_concerned_by_the_query__c;

                    insertCase({ caseToInsert: record, recipientsToAdd: [] })
                        .then(() => {
                            this.showModal = true;
                            this.toggleSpinner();
                        })
                        .catch(error => {

                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error creating case',
                                    message: JSON.parse(JSON.stringify(error)).body.message,
                                    variant: 'error',
                                    mode: 'pester'
                                })
                            );
                        });
                });
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.IDCard_FillAllFields,
                    variant: 'error',
                    mode: 'pester'
                })
            );
        }
    }


    //navigates to homepage
    navigateToHomepage() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        })
            .then(url => navigateToPage(url, {}));
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
            });
    }

    getPhoneNumber() {
        if (this.callUsPhoneNumberConfigs.length > 0) {
            let sector;
            if (this.topic === 'E_F') {
                sector = 'All';
            } else {
                sector = this.contact.Account.Sector__c;
            }
            this.phoneNumber = this.callUsPhoneNumberConfigs.filter(item => {
                //This magical function brought about from an ancient civilization performs beautifully to capture the one value we need based on the conditions bellow
                //We have a list of PhoneNumberConfigs from the custom meta data type with the same name and we extract one value from it.

                return (item.Topic
                    && item.Topic === (this.topic + '__c')
                    && (item.Sector === sector)
                    && (item.IsoCountry === this.countryValue)) // ---- First Condition ------//

                    || (item.Topic
                        && item.Topic === (this.topic + '__c')
                        && item.Sector === sector
                        && (item.IsoCountry === 'All' || item.IsoCountry === '' || item.IsoCountry === undefined)) // ---- Second Condition ------//

                    || (item.Topic
                        && item.Topic === (this.topic + '__c')
                        && (item.Sector === 'All' || item.Sector === '' || item.Sector === undefined)
                        && item.IsoCountry === this.countryValue) // ---- Third Condition ------//

                    || (item.Topic
                        && item.Topic === (this.topic + '__c')
                        && (item.Sector === 'All' || item.Sector === '' || item.Sector === undefined)
                        && (item.IsoCountry === 'All' || item.IsoCountry === '' || item.IsoCountry === undefined)) // ---- Fourth Condition ------//

                    || (item.Sector
                        && (item.Topic === '' || item.Topic === undefined)
                        && (item.Sector === sector)
                        && (item.IsoCountry === this.countryValue)) // ---- Fifth Condition ------//

                    || (item.Sector
                        && (item.Topic === '' || item.Topic === undefined)
                        && (item.Sector === sector)
                        && (item.IsoCountry === 'All' || item.IsoCountry === '' || item.IsoCountry === undefined)) // ---- Sixth Condition ------//

                    || (item.DeveloperName
                        && item.DeveloperName === 'LVA_CallUs_GEN'); // ---- Seventh Condition ------//
            });
        }
    }

    hideRecentCasesList() {
        this.showHideRecentCasesList = true;
    }
}
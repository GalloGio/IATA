import { LightningElement, track } from 'lwc';
import getTopicPickListValues from '@salesforce/apex/PortalSupportReachUsCtrl.getTopicPickListValues';
import getSubTopicPickListValues from '@salesforce/apex/PortalSupportReachUsCtrl.getSubTopicPickListValues';
import getCountryList from '@salesforce/apex/PortalSupportReachUsCtrl.getCountryList';
import { getParamsFromPage } from 'c/navigationUtils';

// Import custom labels
import csp_SupportReachUs_IntentionOnThisPage from '@salesforce/label/c.csp_IntentionOnThisPage';
import csp_SupportReachUs_ChooseOption from '@salesforce/label/c.csp_ChooseOption';
import csp_SupportReachUs_Ask_Label from '@salesforce/label/c.PKB2_Ask_Button';
import csp_SupportReachUs_Concern_Label from '@salesforce/label/c.csp_Concern_Label';
import csp_SupportReachUs_Compliment_Label from '@salesforce/label/c.csp_Compliment_Label';
import csp_SupportReachUs_Suggest_Label from '@salesforce/label/c.csp_Suggest_Label';
import csp_SupportReachUs_SupportCategoriesInfo from '@salesforce/label/c.csp_SupportCategoriesInfo';
import csp_SupportReachUs_ActionIndicator from '@salesforce/label/c.csp_ActionIndicator';
import csp_SupportReachUs_Topic_Label from '@salesforce/label/c.ISSP_F2CTopic';
import csp_SupportReachUs_ActionForCategoryPicklist from '@salesforce/label/c.csp_ActionForCategoryPicklist';
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
import csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL from '@salesforce/label/c.ISSP_Topics_To_Exclude_Country_PL';



export default class PortalSupportReachUs extends LightningElement {
    //track variables
    @track isLoaded = true;
    @track caseDetails;
    @track topic;
    @track topicoptions;
    @track subTopicOptions;
    @track subTopic;
    @track subTopicCB = false;
    @track optionsButton = false;
    @track supOptionsPanel = false;
    @track countryCB = false;
    @track countryValue;

    //global variables
    pageParams;

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
        csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL
    }

    //old doInit() in aura. Fires once the component is loaded.
    connectedCallback() {

        this.getTopicPickListValues();

        this.getCountryList();
    }

    //get the Topic Values for picklist ฅ/ᐠ｡ᆽ｡ᐟ\ 
    getTopicPickListValues() {

        getTopicPickListValues()
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));

                // eslint-disable-next-line no-console
                console.log('Topics: ', myResult);

                //first element on the picklist
                let myTopicOptions = [{ label: 'Select Topic', value: '' }];

                //ex: {label: My Topic, value: my_topic__c}
                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el], value: el });
                });

                //set global with the options for later use
                this.topicoptions = myTopicOptions;

                //gets parameters from URL if any
                this.pageParams = getParamsFromPage();
                if ('T' in this.pageParams) {
                    if (this.pageParams.T in myResult) {
                        this.topic = this.pageParams.T;
                        this.subTopicCB = true;
                        this.subTopicValuesGetter();
                    } else {
                        this.subTopicCB = false;
                        this.pageParams.ST = '';
                    }
                }
                //stop the spinner.
                this.toggleSpinner();
            })
            .catch(error => {
                //throws error
                this.error = error;
                // eslint-disable-next-line no-console
                console.log('Error: ', error);
            })
    }

    //gets Country for picklist ʕ •ᴥ•ʔ
    getCountryList() {

        getCountryList()
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));

                //first element on the picklist
                let myTopicOptions = [{ label: 'Select Country', value: '' }];

                //ex: {label: My Topic, value: my_topic__c}
                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el], value: el });
                });

                //set global with the options for later use
                this.countryOptions = myTopicOptions;
            })
            .catch(error => {
                //throws error
                this.error = error;
                // eslint-disable-next-line no-console
                console.log('Error: ', error);
            });
    }

    //handles topic selection ᘛ⁐̤ᕐᐷ
    topicHandler(event) {
        this.topic = event.target.value;
        if (this.topic !== "") {
            //Show subTopic Picklist/Combobox
            this.subTopicCB = true;
            //Set inital value subTopic Picklist/Combobox
            this.subTopic = '';
            //Remove Parameters. Reload is necessary
            this.pageParams.ST = '';
            //Set inital value country Picklist/Combobox
            this.countryValue = '';
        } else {
            //Hide subTopic Picklist/Combobox
            this.subTopicCB = false;
        }

        //Hide Options Button
        this.optionsButton = false;
        //Hide Options Panel
        this.supOptionsPanel = false;
        //Hide Country Picklist/Combobox
        this.countryCB = false;

        //go get subtopics! ▼・ᴥ・▼
        this.subTopicValuesGetter();
    }

    //Good boy! Fetch the subtopic values ▼・ᴥ・▼
    subTopicValuesGetter() {
        getSubTopicPickListValues({ topicValue: this.topic })
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));
                // eslint-disable-next-line no-console
                console.log('Sub-Topics: ', myResult);

                //first element on the picklist
                let myTopicOptions = [{ label: 'Select Sub-Topic', value: '' }];

                //ex: {label: My SubTopic, value: my_subtopic__c}
                Object.keys(myResult).forEach(function (el) {
                    myTopicOptions.push({ label: myResult[el], value: el });
                });

                //set the options
                this.subTopicOptions = myTopicOptions;

                //set value according to the url parameters
                if ('ST' in this.pageParams) {

                    if (this.pageParams.ST in myResult) {
                        this.subTopic = this.pageParams.ST;
                        let countryExclusion = this.label.csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL.split(',');

                        this.countryCB = true;
                        if (countryExclusion.includes(this.topic)) {
                            this.countryCB = false;
                            this.optionsButton = true;
                        }
                    } else {
                        this.optionsButton = false;
                        this.supOptionsPanel = false;
                    }
                }

            });
    }

    //handles sub-topic selection (ᵔᴥᵔ)
    subTopicHandler(event) {
        this.subTopic = event.target.value;
        if (this.subTopic !== "") {
            this.optionsButton = false;
            this.countryValue = '';
            this.countryCB = true;

            //required to not show the country picklist if the selected value is included here
            let countryExclusion = this.label.csp_SupportReachUs_ISSP_Topics_To_Exclude_Country_PL.split(',');
            if (countryExclusion.includes(this.topic)) {
                this.countryCB = false;
                this.optionsButton = true;
            }
        } else {
            this.optionsButton = false;
            this.supOptionsPanel = false;
        }
    }

    //handles country selection (ᵔᴥᵔ)
    countryHandler(event) {
        this.countryValue = event.target.value;
        if (this.countryValue !== "") {
            this.optionsButton = true;
        } else {
            this.optionsButton = false;
        }
        this.supOptionsPanel = false;
    }

    //handles the support button click [include new functionality here]
    supportOptionsHandler() {

        //equivalent to document.
        let myTemplate = this.template;

        //promise for async execution. check JS documentation
        let willShowPanel = new Promise((resolve, reject) => {
            this.supOptionsPanel = true;

            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        let willScrollDown = function () {
            //execute this, then when it finishes execute scroll action. Good for DOM!
            willShowPanel
                .then(() => {
                    window.scrollTo({ top: myTemplate.lastChild.scrollHeight, left: 0, behavior: 'smooth' });
                });
        }

        //do it NOW! ᕦ(ò_óˇ)ᕤ
        willScrollDown();
    }

    //method that controls the loading spinner action
    toggleSpinner() {
        this.isLoaded = !this.isLoaded;
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

        //grabs the clicked panel and paints with blue color. Identified by it's data-id.
        let mod = this.template.querySelector('[data-id="' + event.target.attributes.getNamedItem('data-id').value + '" ]');
        mod.classList.remove('default_panel');
        mod.classList.add('active_panel');
    }



}
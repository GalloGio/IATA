import { LightningElement, api, track } from 'lwc';

//import apex methods
import isAirlineAdmin from '@salesforce/apex/PortalCasesCtrl.isAirlineAdmin';
import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';
import typeOfCasePortalCustomPicklist from '@salesforce/apex/PortalCasesCtrl.typeOfCasePortalCustomPicklist';
import getAllPickListValues from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';
import typeOfProfilePortalCustomPicklist from '@salesforce/apex/PortalProfileCtrl.typeOfProfilePortalCustomPicklist';
import userPortalStatusCustomPicklist from '@salesforce/apex/PortalProfileCtrl.userPortalStatusCustomPicklist';
import getCountryList from '@salesforce/apex/PortalSupportReachUsCtrl.getCountryList';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';

//import custom labels
import CSP_Cases from '@salesforce/label/c.CSP_Cases';
import CSP_Documents from '@salesforce/label/c.CSP_Documents';
import CSP_FAQs_Title from '@salesforce/label/c.CSP_FAQs_Title';
import CSP_Services_Title from '@salesforce/label/c.CSP_Services_Title';
import CSP_Search_TopResults from '@salesforce/label/c.CSP_Search_TopResults';
import ICCS_Profile from '@salesforce/label/c.ICCS_Profile';

import CSP_Search_Case_Type from '@salesforce/label/c.CSP_Search_Case_Type';
import CSP_Search_Case_Country from '@salesforce/label/c.CSP_Search_Case_Country';
import CSP_Search_FAQ_Category from '@salesforce/label/c.CSP_Search_FAQ_Category';
import CSP_Search_FAQ_Topic from '@salesforce/label/c.CSP_Search_FAQ_Topic';
import CSP_Search_FAQ_Subtopic from '@salesforce/label/c.CSP_Search_FAQ_Subtopic';
import CSP_Search_Documents_Category from '@salesforce/label/c.CSP_Search_Documents_Category';
import CSP_Search_Documents_ProdType from '@salesforce/label/c.CSP_Search_Documents_ProdType';
import CSP_Search_Documents_PubCountry from '@salesforce/label/c.CSP_Search_Documents_PubCountry';
import CSP_Status from '@salesforce/label/c.CSP_Status';
import ISSP_All from '@salesforce/label/c.ISSP_All';

export default class PortalSearchFilters extends LightningElement {

    label = {
        CSP_Cases,
        CSP_Documents,
        CSP_FAQs_Title,
        CSP_Services_Title,
        CSP_Search_TopResults,
        CSP_Search_Case_Type,
        CSP_Search_Case_Country,
        CSP_Search_FAQ_Category,
        CSP_Search_FAQ_Topic,
        CSP_Search_FAQ_Subtopic,
        CSP_Search_Documents_Category,
        CSP_Search_Documents_ProdType,
        CSP_Search_Documents_PubCountry,
        ICCS_Profile,
        CSP_Status,
        ISSP_All
    };

    @api
    get filteringObject() {
        return this._filteringObject;
    }
    set filteringObject(value) {
        this._filteringObject = value;
    }

    @track _filteringObject;

    //attributes for cases filtering
    @track isAdmin = false;
    @track caseTypeOptions = [];
    @track caseCountryOptions = [];


    //attributes for faqs filtering
    faqsMapForPick = [];

    //attributes for documents filtering
    @track documentCategoryOptions = [];
    @track documentProductCategoryOptions = [];
    @track documentCountryOptions = [];


    //attributes for profile filtering
    @track profileTypeOptions = [];
    @track profileCountryOptions = [];
    @track profileContactStatusOptions = [];
    @track typeIsContact = false;

    //is this a portal Admin?
    @track isPortalAdmin = false;

    connectedCallback(){
        // get the picklists in here 
        
        //SERVICES
        //no picks for services

        //check if is a portal admin
        isAdmin()
        .then(result => {
            this.isPortalAdmin = result;
        });

        //CASES
        isAirlineAdmin({})
        .then(result => {
            this.isAdmin = result;
        });
        typeOfCasePortalCustomPicklist({})
        .then(result => {
            this.caseTypeOptions = this.getPickWithAllValue(result);
        });
        getPickListValues({ sobj : 'Case', field : 'Country_concerned_by_the_query__c' })
        .then(result => {
            this.caseCountryOptions = this.getPickWithAllValue(result);
        });

        //FAQS
        getAllPickListValues({})
        .then(result => {
            let resultAux = JSON.parse(JSON.stringify(result));

            let faqsListPick = [];
            for(let item of resultAux){
                if (item.categoryLabel !== 'All') {
                    let found = -1;
                    for(let i = 0; i < faqsListPick.length; i++){
                        if(faqsListPick[i].categoryName === item.categoryName){
                            found = i;
                            break;
                        }
                    }
                    let childsAux = [];
                    Object.keys(item.childs).forEach(function (el) {
                        childsAux.push({
                            subtopicLabel: el, 
                            subtopicName: item.childs[el], 
                            checked: false
                        });
                    });
                    if(found === -1){
                        faqsListPick.push({categoryName : item.categoryName, 
                                            categoryLabel : item.categoryLabel, 
                                            topics : [{ topicLabel : item.topicLabel, topicName : item.topicName, subtopics : childsAux}]});
                    }else{
                        faqsListPick[found].topics.push({ topicLabel : item.topicLabel, topicName : item.topicName, subtopics : childsAux});
                    }
                }
            }
            this.faqsMapForPick = faqsListPick;
        });

        //DOCUMENTS
        getPickListValues({ sobj : 'ContentVersion', field : 'Document_Category__c' })
        .then(result => {
            this.documentCategoryOptions = this.getPickWithAllValue(result);
        });
        getPickListValues({ sobj : 'ContentVersion', field : 'Product_Category__c' })
        .then(result => {
            this.documentProductCategoryOptions = this.getPickWithAllValue(result);
        });
        getPickListValues({ sobj : 'ContentVersion', field : 'Country_of_publication__c' })
        .then(result => {
            this.documentCountryOptions = this.getPickWithAllValue(result);
        });

        //PROFILE
        typeOfProfilePortalCustomPicklist({})
        .then(result =>{
            this.profileTypeOptions = this.getPickWithAllValue(result);
        });
        getCountryList()
            .then(result => {
                let auxmyCountryOptions = [];

                Object.keys(result).forEach(function (el) {
                    auxmyCountryOptions.push({ checked: false, label: result[el], value: el });
                });
                this.profileCountryOptions = this.getPickWithAllValue(auxmyCountryOptions);
            });
        userPortalStatusCustomPicklist({})
        .then(result =>{
            this.profileContactStatusOptions = this.getPickWithAllValue(result);
        });
    }

    getPickWithAllValue(picklist){
        let picklistAux = [{checked: false, label: this.label.ISSP_All, value: ""}];
        return picklistAux.concat(picklist);
    }

    handleTopResultsClick(event){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        if(filteringObjectAux.highlightTopResults === false){
            filteringObjectAux.highlightTopResults = true;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.profileComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = true;
            filteringObjectAux.casesComponent.show = true;
            filteringObjectAux.faqsComponent.show = true;
            filteringObjectAux.documentsComponent.show = true;
            filteringObjectAux.profileComponent.show = true;
            this.typeIsContact = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }
    get getClassForTopResults(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let classToReturn = 'slds-p-around_medium background-anotherGray cursorPointer';
        if(filteringObjectAux.highlightTopResults === true){
            classToReturn = 'slds-p-around_medium background-white';
        }
        return classToReturn;
    }

    handleServicesClick(event){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        if(filteringObjectAux.servicesComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = true;
            filteringObjectAux.servicesComponent.show = true;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            filteringObjectAux.profileComponent.show = false;
            filteringObjectAux.profileComponent.highlight = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }
    get getClassForServices(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let classToReturn = 'slds-p-around_medium background-anotherGray cursorPointer';
        if(filteringObjectAux.servicesComponent.highlight === true){
            classToReturn = 'slds-p-around_medium background-white customLightShadow';
        }
        return classToReturn;
    }
    get getServicesresultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.servicesComponent.nrResults <= 10){
            returnText = filteringObjectAux.servicesComponent.nrResults;
        }else{
            if(filteringObjectAux.servicesComponent.highlight === true){
                returnText = filteringObjectAux.servicesComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }



    handleCasesClick(event){ 
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        if(filteringObjectAux.casesComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = true;
            filteringObjectAux.casesComponent.show = true;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            filteringObjectAux.profileComponent.show = false;
            filteringObjectAux.profileComponent.highlight = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }
    get getClassForCases(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let classToReturn = 'slds-p-around_medium background-anotherGray cursorPointer';
        if(filteringObjectAux.casesComponent.highlight === true){
            classToReturn = 'slds-p-around_medium background-white customLightShadow';
        }
        return classToReturn;
    }
    get getCasesresultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.casesComponent.nrResults <= 10){
            returnText = filteringObjectAux.casesComponent.nrResults;
        }else{
            if(filteringObjectAux.casesComponent.highlight === true){
                returnText = filteringObjectAux.casesComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }
    handleCasesTypePickChange(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.casesComponent.caseTypeFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }
    handleCasesCountryPickChange(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.casesComponent.caseCountryFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }

    handleFaqsClick(event){ 
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        if(filteringObjectAux.faqsComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = true;
            filteringObjectAux.faqsComponent.show = true;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            filteringObjectAux.profileComponent.show = false;
            filteringObjectAux.profileComponent.highlight = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }
    get getClassForFAQs(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let classToReturn = 'slds-p-around_medium background-anotherGray cursorPointer';
        if(filteringObjectAux.faqsComponent.highlight === true){
            classToReturn = 'slds-p-around_medium background-white customLightShadow';
        }
        return classToReturn;
    }
    get getFAQsresultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.faqsComponent.nrResults <= 10){
            returnText = filteringObjectAux.faqsComponent.nrResults;
        }else{
            if(filteringObjectAux.faqsComponent.highlight === true){
                returnText = filteringObjectAux.faqsComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }
    get faqCategoryPickValues(){
        let myCategoryOptions = [];

        for (let item of this.faqsMapForPick) {
            myCategoryOptions.push({
                label: item.categoryLabel,
                value: item.categoryName,
                checked: false
            });
        }

        return this.getPickWithAllValue(myCategoryOptions);
    }
    get faqTopicPickValues(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let myTopicOptions = [];

        for (let item of this.faqsMapForPick) {
            if(filteringObjectAux.faqsComponent.faqCategoryFilter !== ''){
                if(filteringObjectAux.faqsComponent.faqCategoryFilter === item.categoryName){
                    for(let topic of item.topics){
                        myTopicOptions.push({
                            label: topic.topicLabel,
                            value: topic.topicName,
                            checked: false
                        });
                    }
                    break;
                }
            }else{
                for(let topic of item.topics){
                    myTopicOptions.push({
                        label: topic.topicLabel,
                        value: topic.topicName,
                        checked: false
                    });
                }
            }
        }
        
        return this.getPickWithAllValue(myTopicOptions);
    }
    get faqSubtopicPickValues(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let mySubTopicOptions = [];

        for (let item of this.faqsMapForPick) {
            if(filteringObjectAux.faqsComponent.faqCategoryFilter !== '' || filteringObjectAux.faqsComponent.faqTopicFilter !== ''){
                if(filteringObjectAux.faqsComponent.faqCategoryFilter === item.categoryName){
                    for(let topic of item.topics){
                        if(filteringObjectAux.faqsComponent.faqTopicFilter === topic.topicName || filteringObjectAux.faqsComponent.faqTopicFilter === '' ){
                            for(let subtopic of topic.subtopics){
                                mySubTopicOptions.push({
                                    label: subtopic.subtopicLabel,
                                    value: subtopic.subtopicName,
                                    checked: false
                                });
                            }
                        }
                    }
                    break;
                }
            }else{
                for(let topic of item.topics){
                    for(let subtopic of topic.subtopics){
                        mySubTopicOptions.push({
                            label: subtopic.subtopicLabel,
                            value: subtopic.subtopicName,
                            checked: false
                        });
                    }
                }
            }
        }


        return this.getPickWithAllValue(mySubTopicOptions);
    }
    handleFAQCategoryPickValues(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.faqsComponent.faqCategoryFilter = selectedValue;
        filteringObjectAux.faqsComponent.faqTopicFilter = '';
        filteringObjectAux.faqsComponent.faqSubtopicFilter = '';

        this._filteringObject = filteringObjectAux;

        filteringObjectAux.faqsComponent.faqSubtopicsList = this.handleFillSubtopicsList(filteringObjectAux);

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }
    handleFAQTopicPickValues(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.faqsComponent.faqTopicFilter = selectedValue;

        if(selectedValue !== ''){
            for (let category of this.faqsMapForPick) {
                for(let topic of category.topics){
                    if(topic.topicName === selectedValue){
                        filteringObjectAux.faqsComponent.faqCategoryFilter = category.categoryName;
                        break;
                    }
                }
                        
            }
        }
        filteringObjectAux.faqsComponent.faqSubtopicFilter = '';

        filteringObjectAux.faqsComponent.faqSubtopicsList = this.handleFillSubtopicsList(filteringObjectAux);

        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }
    handleFAQSubtopicPickValues(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.faqsComponent.faqSubtopicFilter = selectedValue;
        if(selectedValue !== ''){
            for (let category of this.faqsMapForPick) {
                for(let topic of category.topics){
                    for(let subtopic of topic.subtopics){
                        if(subtopic.subtopicName === selectedValue){
                            filteringObjectAux.faqsComponent.faqCategoryFilter = category.categoryName;
                            filteringObjectAux.faqsComponent.faqTopicFilter = topic.topicName;
                            break;
                        }
                    }
                }     
            }
        }

        filteringObjectAux.faqsComponent.faqSubtopicsList = this.handleFillSubtopicsList(filteringObjectAux);

        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }
    handleFillSubtopicsList(filteringObjectAux){
        let returnLst = [];
        
        if(filteringObjectAux.faqsComponent.faqSubtopicFilter !== ''){
            for (let category of this.faqsMapForPick) {
                for(let topic of category.topics){
                    for(let subtopic of topic.subtopics){
                        if(subtopic.subtopicName === filteringObjectAux.faqsComponent.faqSubtopicFilter){
                            returnLst.push(subtopic.subtopicName);
                        }
                    }
                }     
            }

        }else{
            if(filteringObjectAux.faqsComponent.faqTopicFilter !== ''){
                //get all the subtopics from the selected topic
                for (let category of this.faqsMapForPick) {
                    for(let topic of category.topics){
                        if(topic.topicName === filteringObjectAux.faqsComponent.faqTopicFilter){
                            for(let subtopic of topic.subtopics){
                                returnLst.push(subtopic.subtopicName);
                            }
                        }
                    }     
                }

            }else{
                if(filteringObjectAux.faqsComponent.faqCategoryFilter !== ''){
                    //get all the subtopics from the selected category
                    for (let category of this.faqsMapForPick) {
                        if(category.categoryName === filteringObjectAux.faqsComponent.faqCategoryFilter){
                            for(let topic of category.topics){
                                for(let subtopic of topic.subtopics){
                                    returnLst.push(subtopic.subtopicName);
                                }
                            }
                        }
                    }
                    
                }else{
                    //if nothing is selected, then get all the subtopics from all topics from all categories
                    for (let category of this.faqsMapForPick) {
                        for(let topic of category.topics){
                            for(let subtopic of topic.subtopics){
                                returnLst.push(subtopic.subtopicName);
                            }
                        }     
                    }
                }
            }
        }

        return returnLst;
    }

    


    handleDocumentsClick(event){ 
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        if(filteringObjectAux.documentsComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = true;
            filteringObjectAux.documentsComponent.show = true;
            filteringObjectAux.profileComponent.show = false;
            filteringObjectAux.profileComponent.highlight = false;

            // Creates the event with the contact ID data.
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
    }
    get getClassForDocuments(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let classToReturn = 'slds-p-around_medium background-anotherGray cursorPointer';
        if(filteringObjectAux.documentsComponent.highlight === true){
            classToReturn = 'slds-p-around_medium background-white customLightShadow';
        }
        return classToReturn;
    }
    get getDocumentsresultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.documentsComponent.nrResults <= 10){
            returnText = filteringObjectAux.documentsComponent.nrResults;
        }else{
            if(filteringObjectAux.documentsComponent.highlight === true){
                returnText = filteringObjectAux.documentsComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }
    handleDocumentCategoryPickValues(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.documentsComponent.documentCategoryFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }
    handleDocumentProductCategoryPickValues(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.documentsComponent.documentProductCategoryFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }
    handleDocumentCountryPickValues(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.documentsComponent.documentCountryFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }


    //only shows the profile component.
    handleProfileClick(event){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        if(filteringObjectAux.servicesComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            filteringObjectAux.profileComponent.show = true;
            filteringObjectAux.profileComponent.highlight = true;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }

    handleProfileTypePickChange(event){
        let selectedValue = event.detail.value;

        if (this.isPortalAdmin) {
            this.typeIsContact = event.detail.value === 'Contact';
        }

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.profileComponent.profileStatusFilter = '';
        filteringObjectAux.profileComponent.profileTypeFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }

    handleProfileCountryPickChange(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.profileComponent.profileCountryFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }

    handleContactStatusPickChange(event){
        let selectedValue = event.detail.value;

        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        filteringObjectAux.profileComponent.profileStatusFilter = selectedValue;
        this._filteringObject = filteringObjectAux;

        //fire the event to update the component
        const selectedEvent = new CustomEvent('picklistfilterchanged', { detail: filteringObjectAux });
        this.dispatchEvent(selectedEvent);
    }

    get getClassForProfiles(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this._filteringObject));
        let classToReturn = 'slds-p-around_medium background-anotherGray cursorPointer';
        if(filteringObjectAux.profileComponent.highlight === true){
            classToReturn = 'slds-p-around_medium background-white customLightShadow';
        }
        return classToReturn;
    }

    get getProfileResultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.profileComponent.nrResults <= 10){
            returnText = filteringObjectAux.profileComponent.nrResults;
        }else{
            if(filteringObjectAux.profileComponent.highlight === true){
                returnText = filteringObjectAux.profileComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }

    

}

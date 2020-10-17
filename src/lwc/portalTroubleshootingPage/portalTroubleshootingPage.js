import { LightningElement,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage,navigateToPage } from'c/navigationUtils';
import getTroubleshootingArticle from '@salesforce/apex/PortalFAQsCtrl.getTroubleshootingArticle';

import getCommunityAvailableLanguages from '@salesforce/apex/CSP_Utils.getCommunityAvailableLanguages';

import CSP_TroubleshootingMsg         from '@salesforce/label/c.CSP_TroubleshootingMSG';
import CSP_TroubleshootingTitle       from '@salesforce/label/c.CSP_TroubleshootingTitle';

export default class PortalTroubleshootingPage extends NavigationMixin(LightningElement) {

    paramstr='';

    @track language ='en_US';
    @track articleValue;    
    @track langOptions = [];

    @track labels={
        CSP_TroubleshootingMsg,
        CSP_TroubleshootingTitle
    }
    
 
    @wire(getTroubleshootingArticle,{ lang : '$language'})
    wiredArticleResult(results){
        if (results.data) {
            this.articleValue =  results.data.records[0].Answer__c;
        }
    }

    @wire(getCommunityAvailableLanguages,{ })
    wiredLanguageResult(results){
        if(results.data) {
            this.langOptions = results.data;                    
        }
    }

    connectedCallback(){
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.language !== undefined) {              
            this.language = pageParams.language;
        }
        
        this.paramstr=JSON.stringify(this.paramsObj);

    }
    

    handleChangeLang(event) {
        let lang = event.detail.value;

        let params = {};
        params.language = lang; 
        this.selectedLang = lang;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: 'troubleshooting'
            }})
        .then(url => navigateToPage(url, params));
        
    } 
}
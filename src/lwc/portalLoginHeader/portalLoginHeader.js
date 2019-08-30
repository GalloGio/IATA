/**
 * Created by ukaya01 on 11/07/2019.
 */

import { LightningElement, track, api } from 'lwc';
import getCommunityAvailableLanguages from '@salesforce/apex/CSP_Utils.getCommunityAvailableLanguages';
import changeUserLanguage from '@salesforce/apex/CSP_Utils.changeUserLanguage';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalLoginHeader extends LightningElement {

    @track selectedLang = 'en_US';
    @track langOptions = [];
    @track loadingLangs = true;
    @api preventrefresh = false;

    connectedCallback(){
        var pageParams = getParamsFromPage();
        if(pageParams !== undefined && pageParams.language !== undefined){
            this.selectedLang = pageParams.language.toLowerCase();;
        }
        this.getLanguagesOptions();

    }

    getLanguagesOptions() {
        this.loadingLangs = true;
        getCommunityAvailableLanguages().then(result => {
            if (result) {
                var lowerCaseLangOpts = result.map(function(a) {
                     a.value = a.value.toLowerCase();
                     return a;
                 });

                this.langOptions = lowerCaseLangOpts;
            }
            this.loadingLangs = false;
        }).catch(error => {
            this.loadingLangs = false;
        });
    }

    handleChangeLang(event){
        this.selectedLang = event.target.value;
        var search = location.search;
        var param = new RegExp('language=[^&$]*', 'i');
        if(~search.indexOf('language')){
            search = search.replace(param, 'language=' + this.selectedLang );
        }else{
            if(search.length > 0) search += '&';
            search += 'language='+this.selectedLang;
        }

        if(this.preventrefresh == "false" || this.preventrefresh == false){
            location.search = search;
        }else{
            this.dispatchEvent(new CustomEvent('languagechange',{detail : this.selectedLang}));
        }

    }


}
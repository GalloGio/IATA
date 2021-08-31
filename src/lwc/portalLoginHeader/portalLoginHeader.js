/**
 * Created by ukaya01 on 11/07/2019.
 */

import { LightningElement, track, api } from 'lwc';
import getCommunityAvailableLanguages from '@salesforce/apex/CSP_Utils.getCommunityAvailableLanguages';
import { navigateToPage } from'c/navigationUtils';
import changeUserLanguage from '@salesforce/apex/CSP_Utils.changeUserLanguage';
import { getParamsFromPage } from'c/navigationUtils';
import CSP_PortalPath                   from '@salesforce/label/c.CSP_PortalPath';


export default class PortalLoginHeader extends LightningElement {

    @track selectedLang = 'en_us';
    @track langOptions = [];
    @track loadingLangs = true;
    @api preventrefresh = false;

    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';

    connectedCallback(){
        var pageParams = getParamsFromPage();
        if(pageParams !== undefined && pageParams.language !== undefined){
            this.selectedLang = pageParams.language.toLowerCase();
        }else if(pageParams.retURL !== undefined){
            let languageResult = pageParams.retURL.match(/language=(.*)&/g);
            if(languageResult){
                this.selectedLang = languageResult[0].replace('language=', '').replace('&', '').toLowerCase();
            }else{
                languageResult = pageParams.retURL.match(/language=(.*)/g);
                if (languageResult) {
                    this.selectedLang = languageResult[0].replace('language=', '').toLowerCase();
                }else{
                    this.selectedLang = 'en_US';
                }
            }
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
            if (search.includes('retURL')) {
                param = new RegExp('language%3D[^&$]*', 'i');
                search = search.replace(param, 'language%3D' + this.selectedLang);
            }else{
                search = search.replace(param, 'language=' + this.selectedLang );
            }
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

    handleNavigateToLogin(){
        navigateToPage(CSP_PortalPath);
    }
}
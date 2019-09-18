import { LightningElement, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage, navigateToPage } from'c/navigationUtils';

import isGuestUser from '@salesforce/apex/CSP_Utils.isGuestUser';
import getCommunityAvailableLanguages from '@salesforce/apex/CSP_Utils.getCommunityAvailableLanguages';

//import labels
import CSP_Search_Support_Placeholder from '@salesforce/label/c.CSP_Search_Support_Placeholder';
import CSP_Support_HeaderTitle from '@salesforce/label/c.CSP_Support_HeaderTitle';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalSupportPageHeader extends NavigationMixin(LightningElement) {

    label = {
        CSP_Search_Support_Placeholder,
        CSP_Support_HeaderTitle
    };

    // both are necessary to avoid wrong renderization before the page is completed loaded.
    @track internalUser = false;
    @track guestUser = false;

    @track loadingLangs = true;
    @track language = 'en_US';

    //links for images
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/FAQsBackground.jpg';
    backgroundPublicKB = CSP_PortalPath + 'CSPortal/Images/Backgrounds/PublicKnowledgeBackground.jpg';

    @track backgroundStyle;

    get getBackgroundClass() {
        if(this.guestUser) return 'background-image: url("' + this.backgroundPublicKB + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:230px;'
        if(this.internalUser) return 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:230px;'
    }

    connectedCallback() {
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.language !== undefined) {              
            this.language = pageParams.language;
        }

        isGuestUser().then(results => { 
            this.internalUser = !results;
            this.guestUser = results;
        });

        getCommunityAvailableLanguages()
            .then(result => {
                if(result) {
                    this.langOptions = result;
                }
                this.loadingLangs = false;
            }).catch(error => {
                this.loadingLangs = false;
        });
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
                pageName: 'faq'
            }})
        .then(url => navigateToPage(url, params));
        
    }

}
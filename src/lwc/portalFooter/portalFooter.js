import { LightningElement, track, wire } from 'lwc';

import { navigateToPage } from'c/navigationUtils';

import userId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

import getCommunityAvailableLanguages from '@salesforce/apex/CSP_Utils.getCommunityAvailableLanguages';
import changeUserLanguage from '@salesforce/apex/CSP_Utils.changeUserLanguage';

import FooterLeadMessage from '@salesforce/label/c.FooterLeadMessage';
import CSP_Breadcrumb_Support_Title from '@salesforce/label/c.CSP_Breadcrumb_Support_Title';
import CSP_Breadcrumb_Services_Title from '@salesforce/label/c.CSP_Breadcrumb_Services_Title';
import csp_Footer_IATA_Store from '@salesforce/label/c.csp_Footer_IATA_Store';
import ISSP_Registration_Privacy from '@salesforce/label/c.ISSP_Registration_Privacy';
import ISSP_Registration_Legal from '@salesforce/label/c.ISSP_Registration_Legal';

export default class PortalFooter extends LightningElement {
    @track selectedLang = '';
    @track langOptions = [];
    @track chagingLang = false;
    @track loadingLangs = true;
    @track userId = userId;

    @wire(getRecord, { recordId: "$userId", fields: ['User.LanguageLocaleKey'] })
    getUserLang(result) {
        if (result.data) {
            let data = JSON.parse(JSON.stringify(result.data));
            if (data.fields) {
                this.selectedLang = data.fields.LanguageLocaleKey.value;
            }
        }
    }

    _labels = {
        FooterLeadMessage,
        CSP_Breadcrumb_Support_Title,
        CSP_Breadcrumb_Services_Title,
        csp_Footer_IATA_Store,
        ISSP_Registration_Privacy,
        ISSP_Registration_Legal
        };

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value;
    }

    connectedCallback() {
        this.getLanguagesOptions();
    }

    handleChangeLang(event) {
        this.chagingLang = true;
        let lang = event.detail.value;
        changeUserLanguage({lang}).then(() => {
            window.location.reload(); // Review this
        }).catch(error => {
            console.error('Error changeUserLanguage', error);
            this.chagingLang = false;
        });
    }

    getLanguagesOptions() {
        this.loadingLangs = true;
        getCommunityAvailableLanguages().then(result => {
            if (result) {
                this.langOptions = result;
            }
            this.loadingLangs = false;
        }).catch(error => {
            console.error('Error getCommunityAvailableLanguages', error);
            this.loadingLangs = false;
        });
    }

    navigateToSupport() {
        navigateToPage("/csportal/s/support");
    }

    navigateToServices() {
        navigateToPage("/csportal/s/services");
    }

    navigateToIataStore() {
        window.open("https://www.iata.org");
    }

    navigateToPrivacy() {
        window.open("https://www.iata.org/Pages/privacy.aspx");
    }

    navigateToLegal() {
        window.open("https://www.iata.org/Pages/terms.aspx");
    }

    navigateToFacebook() {
        window.open("https://www.facebook.com/iata.org");
    }

    navigateToTwitter() {
        window.open("https://twitter.com/iata");
    }

    navigateToLinkedin() {
        window.open("https://www.linkedin.com/company/international-air-transport-association-iata");
    }

    navigateToYoutube() {
        window.open("https://www.youtube.com/iatatv");
    }
}
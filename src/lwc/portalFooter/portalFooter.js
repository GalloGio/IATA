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

import csp_Footer_Facebook_URL from '@salesforce/label/c.csp_Footer_Facebook_URL';
import csp_Footer_Twitter_URL from '@salesforce/label/c.csp_Footer_Twitter_URL';
import csp_Footer_Linkedin_URL from '@salesforce/label/c.csp_Footer_Linkedin_URL';
import csp_Footer_Youtube_URL from '@salesforce/label/c.csp_Footer_Youtube_URL';
import csp_Footer_Legal_URL from '@salesforce/label/c.csp_Footer_Legal_URL';
import csp_Footer_Privacy_URL from '@salesforce/label/c.csp_Footer_Privacy_URL';
import csp_Footer_IataStore_URL from '@salesforce/label/c.csp_Footer_IataStore_URL';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalFooter extends LightningElement {
    @track selectedLang = 'en_US';
    @track langOptions = [];
    @track chagingLang = false;
    @track loadingLangs = true;
    @track userId = userId;

    iataLogo = CSP_PortalPath + 'CSPortal/Images/Logo/logo-group-white.svg';
    facebookIcon = CSP_PortalPath + 'CSPortal/Images/Icons/facebook-icon.svg';
    twitterIcon = CSP_PortalPath + 'CSPortal/Images/Icons/twitter-icon.svg';
    linkedinIcon = CSP_PortalPath + 'CSPortal/Images/Icons/linkedin-icon.svg';
    youtubeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youtube-icon.svg';

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

    _urls = {
        csp_Footer_Facebook_URL, 
        csp_Footer_Twitter_URL,
        csp_Footer_Linkedin_URL,
        csp_Footer_Youtube_URL,
        csp_Footer_Legal_URL,
        csp_Footer_Privacy_URL,
        csp_Footer_IataStore_URL
    };

    get urls() {
        return this._urls;
    }

    set urls(value) {
        this._urls = value;
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
        navigateToPage(CSP_PortalPath + "support");
    }

    navigateToServices() {
        navigateToPage(CSP_PortalPath +"services");
    }

    navigateToIataStore() {
        window.open(this.urls.csp_Footer_IataStore_URL);
    }

    navigateToPrivacy() {
        window.open(this.urls.csp_Footer_Privacy_URL);
    }

    navigateToLegal() {
        window.open(this.urls.csp_Footer_Legal_URL);
    }

    navigateToFacebook() {
        window.open(this.urls.csp_Footer_Facebook_URL);
    }

    navigateToTwitter() {
        window.open(this.urls.csp_Footer_Twitter_URL);
    }

    navigateToLinkedin() {
        window.open(this.urls.csp_Footer_Linkedin_URL);
    }

    navigateToYoutube() {
        window.open(this.urls.csp_Footer_Youtube_URL);
    }
}
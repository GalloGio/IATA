import { LightningElement, track } from 'lwc';

import { getParamsFromPage, navigateToPage } from'c/navigationUtils';

//Contact Apex Methods
import getProviderHeaderFields from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderHeaderFields';

//Import custom labels
import ISSP_CompanyName from '@salesforce/label/c.ISSP_CompanyName';
import ISSP_Contact from '@salesforce/label/c.ISSP_Contact';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_Service_InnovationHub_Title from '@salesforce/label/c.CSP_Service_InnovationHub_Title';

export default class PortalServicesInnovationHubDetailHeader extends LightningElement {

    @track backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/ServiceInnovationHubBackground.jpg';
    
    webIcon = CSP_PortalPath + 'CSPortal/Images/Icons/web_60x60.png';
    facebookIcon = CSP_PortalPath + 'CSPortal/Images/Icons/facebook_60x60.png';
    instagramIcon = CSP_PortalPath + 'CSPortal/Images/Icons/instagram_60x60.png';
    twitterIcon = CSP_PortalPath + 'CSPortal/Images/Icons/twitter_60x60.png';
    linkedInIcon = CSP_PortalPath + 'CSPortal/Images/Icons/linkedin_60x60.png';
    gitHubIcon = CSP_PortalPath + 'CSPortal/Images/Icons/github_60x60.png';
    telegramIcon = CSP_PortalPath + 'CSPortal/Images/Icons/telegram_60x60.png';

    //Loading && Error
    @track loading = false;
    @track loadingContent = false;
    @track viewPublishedRecord = false;
    @track backgroundStyle;
    @track profileDivStyle;
    @track iconLink;
    @track contact = {};
    @track providerId;
    @track headerFields = {};
    @track websiteUrl = '';
    @track facebookUrl = '';
    @track instagramUrl = '';
    @track twitterUrl = '';
    @track linkedInUrl = '';
    @track gitHubUrl = '';
    @track telegramUrl = '';

    _labels = {
        ISSP_CompanyName,
        ISSP_Contact,
        CSP_Service_InnovationHub_Title
    };

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value;
    }

    get providerAndPublishedRecord(){
        return this.headerFields != null && this.headerFields.Published__c && this.headerFields.Status__c == 'Approved';
    }

    get hasWebsite() {
        return this.websiteUrl != '' && this.websiteUrl != undefined;
    }

    get hasFB() {
        return this.facebookUrl != '' && this.facebookUrl != undefined;
    }

    get hasInstagram() {
        return this.instagramUrl != '' && this.instagramUrl != undefined;
    }

    get hasTwitter() {
        return this.twitterUrl != '' && this.twitterUrl != undefined;
    }

    get hasLinkedIn() {
        return this.linkedInUrl != '' && this.linkedInUrl != undefined;
    }

    get hasGitHub() {
        return this.gitHubUrl != '' && this.gitHubUrl != undefined;
    }

    get hasTelegram() {
        return this.telegramUrl != '' && this.telegramUrl != undefined;
    }

    connectedCallback() {
        this.loadingContent = true;
        let pageParams = getParamsFromPage();
        if(pageParams !== undefined){
            if(pageParams.providerId !== undefined){
                this.providerId = pageParams.providerId;
            }
        }

        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px;'
        this.profileDivStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px; width: 196px; height: 196px; position: absolute; top: 72px; left: 32px; border-radius: 50%;  box-shadow: 0px 1px 12px 0px #827f7f; background-color:white;';
        
        getProviderHeaderFields({ providerId: this.providerId}).then(result => {
            this.headerFields = result;

            if(this.headerFields != null){
                this.websiteUrl = this.headerFields.Website__c;
                this.facebookUrl  = this.headerFields.Facebook__c;
                this.instagramUrl = this.headerFields.Instagram__c;
                this.twitterUrl   = this.headerFields.Twitter__c;
                this.linkedInUrl  = this.headerFields.LinkedIn__c;
                this.gitHubUrl    = this.headerFields.GitHub__c;
                this.telegramUrl  = this.headerFields.Telegram__c;
            }

            this.loadingContent = false;

        });
        

    }

}
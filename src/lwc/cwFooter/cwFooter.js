import { LightningElement, wire } from 'lwc';
import file from '@salesforce/resourceUrl/IATA_CSS_guidelines_v1';
import { getSObjectValue } from '@salesforce/apex';
import getMetadataInfo from '@salesforce/apex/CW_Utilities.getMetadataInfo';

import NAME_FIELD from '@salesforce/schema/Portal_Identity_Data__mdt.MasterLabel';
import URL_FIELD from '@salesforce/schema/Portal_Identity_Data__mdt.Link__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Portal_Identity_Data__mdt.Description__c';


export default class cwFooter extends LightningElement {

    // Airlines Magazine
    @wire(getMetadataInfo, { mtdName: 'Airlines_magazine' }) metadataAirlines;

    get AirlinesName() {
        return this.metadataAirlines.data ? getSObjectValue(this.metadataAirlines.data, NAME_FIELD) : '';
    }
    get AirlinesURL() {
        return this.metadataAirlines.data ? getSObjectValue(this.metadataAirlines.data, URL_FIELD) : '';
    }

    // Aviation and the Enviroment
    @wire(getMetadataInfo, { mtdName: 'Aviation_and_the_enviroment' }) metadataAviation;

    get AviationName() {
        return this.metadataAviation.data ? getSObjectValue(this.metadataAviation.data, NAME_FIELD) : '';
    }
    get AviationURL() {
        return this.metadataAviation.data ? getSObjectValue(this.metadataAviation.data, URL_FIELD) : '';
    }

    // Twitter
    @wire(getMetadataInfo, { mtdName: 'Twitter' }) metadataTwitter;

    get twitterName() {
        return this.metadataTwitter.data ? getSObjectValue(this.metadataTwitter.data, NAME_FIELD) : '';
    }
    get twitterURL() {
        return this.metadataTwitter.data ? getSObjectValue(this.metadataTwitter.data, URL_FIELD) : '';
    }

    // Facebook
    @wire(getMetadataInfo, { mtdName: 'Facebook' }) metadataFacebook;

    get FacebookName() {
        return this.metadataFacebook.data ? getSObjectValue(this.metadataFacebook.data, NAME_FIELD) : '';
    }
    get FacebookURL() {
        return this.metadataFacebook.data ? getSObjectValue(this.metadataFacebook.data, URL_FIELD) : '';
    }

    // Linkedin
    @wire(getMetadataInfo, { mtdName: 'LinkedIn' }) metadataLinkedIn;

    get LinkedinName() {
        return this.metadataLinkedIn.data ? getSObjectValue(this.metadataLinkedIn.data, NAME_FIELD) : '';
    }
    get LinkedinURL() {
        return this.metadataLinkedIn.data ? getSObjectValue(this.metadataLinkedIn.data, URL_FIELD) : '';
    }

    // Youtube
    @wire(getMetadataInfo, { mtdName: 'Youtube' }) metadataYoutube;

    get YoutubeName() {
        return this.metadataYoutube.data ? getSObjectValue(this.metadataYoutube.data, NAME_FIELD) : '';
    }
    get YoutubeURL() {
        return this.metadataYoutube.data ? getSObjectValue(this.metadataYoutube.data, URL_FIELD) : '';
    }

    // RSS
    @wire(getMetadataInfo, { mtdName: 'RSS' }) metadataRSS;

    get RSSName() {
        return this.metadataRSS.data ? getSObjectValue(this.metadataRSS.data, NAME_FIELD) : '';
    }
    get RSSURL() {
        return this.metadataRSS.data ? getSObjectValue(this.metadataRSS.data, URL_FIELD) : '';
    }

    // Legal
    @wire(getMetadataInfo, { mtdName: 'Legal' }) metadataLegal;

    get LegalName() {
        return this.metadataLegal.data ? getSObjectValue(this.metadataLegal.data, NAME_FIELD) : '';
    }
    get LegalURL() {
        return this.metadataLegal.data ? getSObjectValue(this.metadataLegal.data, URL_FIELD) : '';
    }

    // Legal
    @wire(getMetadataInfo, { mtdName: 'Privacy' }) metadataPrivacy;

    get PrivacyName() {
        return this.metadataPrivacy.data ? getSObjectValue(this.metadataPrivacy.data, NAME_FIELD) : '';
    }
    get PrivacyURL() {
        return this.metadataPrivacy.data ? getSObjectValue(this.metadataPrivacy.data, URL_FIELD) : '';
    }

    // Footer Title
    @wire(getMetadataInfo, { mtdName: 'Footer_Title' }) metadataFooterTitle;

    get FooterTitleDescription() {
        return this.metadataFooterTitle.data ? getSObjectValue(this.metadataFooterTitle.data, DESCRIPTION_FIELD) : '';
    }

    // Footer Copyright
    @wire(getMetadataInfo, { mtdName: 'Footer_Copyright' }) metadataFooterCopyright;

    get FooterCopyrightDescription() {
        return this.metadataFooterCopyright.data ? getSObjectValue(this.metadataFooterCopyright.data, DESCRIPTION_FIELD) : '';
    }



    logoOther = file + '/IATA-CSS-guidelines-v1/assets/iata-logo-other.svg';
    twitter = file + '/IATA-CSS-guidelines-v1/assets/social-twitter.svg';
    facebook = file + '/IATA-CSS-guidelines-v1/assets/social-facebook.svg';
    linkedin = file + '/IATA-CSS-guidelines-v1/assets/social-linkedin.svg';
    youtube = file + '/IATA-CSS-guidelines-v1/assets/social-youtube.svg';
    rss = file + '/IATA-CSS-guidelines-v1/assets/social-rss.svg';

    renderedCallback() {

        Promise.all([])

    }

}
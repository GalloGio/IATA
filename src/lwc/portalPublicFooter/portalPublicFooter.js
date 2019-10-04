import { LightningElement, track } from 'lwc';
import IATALogoWhite from '@salesforce/resourceUrl/IATALogoWhite';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalPublicFooter extends LightningElement {
    @track iataLogoWhite = IATALogoWhite;

    iataLogo = CSP_PortalPath + 'CSPortal/Images/Logo/logo-group-white.svg';
    facebookIcon = CSP_PortalPath + 'CSPortal/Images/Icons/facebook-icon-kb.svg';
    twitterIcon = CSP_PortalPath + 'CSPortal/Images/Icons/twitter-icon-kb.svg';
    linkedinIcon = CSP_PortalPath + 'CSPortal/Images/Icons/linkedin-icon-kb.svg';
    youtubeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youtube-icon-kb.svg';
    rssIcon = CSP_PortalPath + 'CSPortal/Images/Icons/rss_icon.svg';
}
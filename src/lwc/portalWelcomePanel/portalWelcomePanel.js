/**
 * Created by ukaya01 on 09/08/2019.
 */


/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track } from 'lwc';
import { navigateToPage } from'c/navigationUtils';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import CSP_Welcome_Title                from '@salesforce/label/c.CSP_Welcome_Title';
import CSP_Welcome_Panel_Info           from '@salesforce/label/c.CSP_Welcome_Panel_Info';
import CSP_Welcome_Panel_Bullet_1_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_1_Title';
import CSP_Welcome_Panel_Bullet_1_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_1_Desc';
import CSP_Welcome_Panel_Bullet_2_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_2_Title';
import CSP_Welcome_Panel_Bullet_2_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_2_Desc';
import CSP_Welcome_Panel_Bullet_3_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_3_Title';
import CSP_Welcome_Panel_Bullet_3_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_3_Desc';
import CSP_Welcome_Panel_Bullet_4_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_4_Title';
import CSP_Welcome_Panel_Bullet_4_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_4_Desc';
import CSP_FAQ_Label                    from '@salesforce/label/c.CSP_FAQ_Label';
import CSP_PortalPath                   from '@salesforce/label/c.CSP_PortalPath';

export default class PortalWelcomePanel extends LightningElement {

    _labels = {
        CSP_Welcome_Title,
        CSP_Welcome_Panel_Info,
        CSP_Welcome_Panel_Bullet_1_Title,
        CSP_Welcome_Panel_Bullet_1_Desc,
        CSP_Welcome_Panel_Bullet_2_Title,
        CSP_Welcome_Panel_Bullet_2_Desc,
        CSP_Welcome_Panel_Bullet_3_Title,
        CSP_Welcome_Panel_Bullet_3_Desc,
        CSP_Welcome_Panel_Bullet_4_Title,
        CSP_Welcome_Panel_Bullet_4_Desc,
        CSP_FAQ_Label,
        CSP_PortalPath
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
    serviceIcon = CSP_PortalPath + 'CSPortal/Images/Icons/service_recolor.png';
    uptodateIcon = CSP_PortalPath + 'CSPortal/Images/Icons/uptodate_recolor.png';
    offerIcon = CSP_PortalPath + 'CSPortal/Images/Icons/offer_recolor.png';
    supportIcon = CSP_PortalPath + 'CSPortal/Images/Icons/support_recolor.png';
    arrowIcon = CSP_PortalPath + 'CSPortal/Images/Icons/arrow_right_recolor.png';
    bgImage = CSP_PortalPath + 'CSPortal/Images/Backgrounds/WelcomePanelBackground.jpg';
    @track backgroundStyle;

    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.bgImage + '"); background-position: center; background-repeat: no-repeat; background-size: cover;';
    }

    handleNavigateToFAQ(){
        navigateToPage('https://portal.iata.org/faq/');
    }

}
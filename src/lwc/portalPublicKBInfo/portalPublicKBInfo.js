import { LightningElement } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import CSP_Welcome_Panel_Bullet_1_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_1_Title';
import CSP_Welcome_Panel_Bullet_1_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_1_Desc';
import CSP_Welcome_Panel_Bullet_2_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_2_Title';
import CSP_Welcome_Panel_Bullet_2_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_2_Desc';
import CSP_Welcome_Panel_Bullet_3_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_3_Title';
import CSP_Welcome_Panel_Bullet_3_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_3_Desc';
import CSP_Welcome_Panel_Bullet_4_Title from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_4_Title';
import CSP_Welcome_Panel_Bullet_4_Desc  from '@salesforce/label/c.CSP_Welcome_Panel_Bullet_4_Desc';
import CSP_PortalPath                   from '@salesforce/label/c.CSP_PortalPath';

export default class PortalPublicKBInfo extends NavigationMixin(LightningElement) {
    _labels = {
        CSP_Welcome_Panel_Bullet_1_Title,
        CSP_Welcome_Panel_Bullet_1_Desc,
        CSP_Welcome_Panel_Bullet_2_Title,
        CSP_Welcome_Panel_Bullet_2_Desc,
        CSP_Welcome_Panel_Bullet_3_Title,
        CSP_Welcome_Panel_Bullet_3_Desc,
        CSP_Welcome_Panel_Bullet_4_Title,
        CSP_Welcome_Panel_Bullet_4_Desc,
        CSP_PortalPath
    }

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value; 
    }

    serviceIcon = CSP_PortalPath + 'CSPortal/Images/Icons/service_recolor.png';
    uptodateIcon = CSP_PortalPath + 'CSPortal/Images/Icons/uptodate_recolor.png';
    offerIcon = CSP_PortalPath + 'CSPortal/Images/Icons/offer_recolor.png';
    supportIcon = CSP_PortalPath + 'CSPortal/Images/Icons/support_recolor.png';
    arrowIcon = CSP_PortalPath + 'CSPortal/Images/Icons/arrow_right_recolor.png';

    handleNavigateToLogin() {
        this[NavigationMixin.GenerateUrl]({
            type: "comm__loginPage",
            attributes: {
                actionName: 'login'
            }})
        .then(url => navigateToPage(url, {}));
    }

    handleNavigateToSignUp() {
        this[NavigationMixin.GenerateUrl]({
            type: "comm__loginPage",
            attributes: {
                actionName: 'login'
            }})
        .then(url => navigateToPage(url, {}));
    }
}
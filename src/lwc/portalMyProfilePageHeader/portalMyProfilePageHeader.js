import { LightningElement, track } from 'lwc';

//Contact Apex Methods
import getContactDetails from '@salesforce/apex/PortalMyProfileCtrl.getContactInfo';

//Import custom labels
import csp_My_Profile_Job_Title from '@salesforce/label/c.csp_My_Profile_Job_Title';
import csp_My_Profile_Company from '@salesforce/label/c.csp_My_Profile_Company';
import csp_My_Profile_Email from '@salesforce/label/c.csp_My_Profile_Email';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalProfilePageHeader extends LightningElement {

    @track backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/MyProfileBackground.jpg';

    //Loading && Error
    @track loading = false;
    @track backgroundStyle;
    @track profileDivStyle;
    @track iconLink;
    @track error;

    @track contact = {};

    _labels = {
        csp_My_Profile_Job_Title,
        csp_My_Profile_Company,
        csp_My_Profile_Email
        };

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value;
    }


    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px;'
        this.profileDivStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px; width: 196px; height: 196px; position: absolute; top: 72px; left: 32px; border-radius: 50%;  box-shadow: 0px 1px 12px 0px #827f7f; background-color:white;';

        getContactDetails().then(result => {
            //because proxy..
            this.contact = result.contact;
            this.loading = false;
        })
        
    }

}
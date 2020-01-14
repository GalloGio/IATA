import { LightningElement, track } from 'lwc';

import { getParamsFromPage, navigateToPage } from'c/navigationUtils';

//Contact Apex Methods
import getContactDetails from '@salesforce/apex/PortalMyProfileCtrl.getContactInfo';
import getContactInfo from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';

//Import custom labels
import csp_My_Profile_Job_Title from '@salesforce/label/c.csp_My_Profile_Job_Title';
import csp_My_Profile_Company from '@salesforce/label/c.csp_My_Profile_Company';
import csp_My_Profile_Email from '@salesforce/label/c.csp_My_Profile_Email';
import CSP_L2_Already_L2_Title from '@salesforce/label/c.CSP_L2_Already_L2_Title';
import CSP_L2_Already_L2_Message from '@salesforce/label/c.CSP_L2_Already_L2_Message';
import CSP_L2_Go_To_Homepage from '@salesforce/label/c.CSP_L2_Go_To_Homepage';
import CSP_L2_Edit_Company_Information from '@salesforce/label/c.CSP_L2_Edit_Company_Information';
import CSP_L2_Edit_Company_Information_Message from '@salesforce/label/c.CSP_L2_Edit_Company_Information_Message';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalProfilePageHeader extends LightningElement {

    @track backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/MyProfileBackground.jpg';
    @track alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';
    successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';
    emptyString = '';

    //Loading && Error
    @track loading = false;
    @track backgroundStyle;
    @track profileDivStyle;
    @track iconLink;
    @track error;

    @track contact = {};

    // level 2 registration variables
    @track isFirstLevelUser;
    level2RegistrationTrigger = 'profile';
    isTriggeredByRequest = false;
    @track displaySecondLevelRegistration = false;
    @track displayAlreadyL2Popup = false;

    _labels = {
        csp_My_Profile_Job_Title,
        csp_My_Profile_Company,
        csp_My_Profile_Email,
        CSP_L2_Already_L2_Title,
        CSP_L2_Already_L2_Message,
        CSP_L2_Go_To_Homepage,
        CSP_L2_Edit_Company_Information,
        CSP_L2_Edit_Company_Information_Message
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
        });
        
        getContactInfo().then(result => {
            this.isFirstLevelUser = result.Account.Is_General_Public_Account__c;

            this.pageParams = getParamsFromPage();
            if(this.pageParams.triggerL2 !== undefined && this.pageParams.triggerL2 === 'true'){
                if(this.isFirstLevelUser){
                    this.showSecondLevelRegistration();
                }
                else{
                    this.openAlreadyL2Popup();
                }
            }
        });
        

    }

    openAlreadyL2Popup(){
        this.displayAlreadyL2Popup = true;
    }

    closeAlreadyL2Popup(){
        navigateToPage(CSP_PortalPath,{});
    }

    showSecondLevelRegistration(){
        this.displaySecondLevelRegistration = true;
    }

    cancelSecondLevelRegistration(){
        this.displaySecondLevelRegistration = false;
    }

    secondLevelRegistrationCompletedAction1(){
        navigateToPage(CSP_PortalPath,{});
    }

    secondLevelRegistrationCompletedAction2(){
        navigateToPage("my-profile");        
    }
}
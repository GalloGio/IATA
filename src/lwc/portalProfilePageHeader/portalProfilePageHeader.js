/**
 * Created by pvavruska on 5/23/2019.
 */

import { LightningElement, track } from 'lwc';

//User and company details
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import getCompanyInfo from '@salesforce/apex/PortalProfileCtrl.getCompanyInfo';

//Import custom labels
import csp_Profile_CompanyEmail from '@salesforce/label/c.csp_Profile_CompanyEmail';
import csp_Profile_IATACode from '@salesforce/label/c.csp_Profile_IATACode';
import csp_Profile_Website from '@salesforce/label/c.csp_Profile_Website';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';


export default class PortalProfilePageHeader extends LightningElement {

    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/CompanyProfileBackground.jpg';

        //Loading && Error
        @track loading = true;
        @track noAccount = false;

        @track backgroundStyle;
        @track profileDivStyle;
        @track profilePhotoStyle;
        @track error;

        //Account fields
        @track userAccount;
        @track loggedUser;


        _labels = {
            csp_Profile_CompanyEmail,
            csp_Profile_IATACode,
            csp_Profile_Website
            };

        get labels() {
            return this._labels;
        }

        set labels(value) {
            this._labels = value;
        }

        get emptyCode(){
            let isPending = this.userAccount === undefined || this.userAccount.Status__c == undefined || this.userAccount.Status__c.toLowerCase() == 'new application pending';
            return (isPending || this.userAccount === undefined || this.userAccount.IATACode__c === undefined || this.userAccount.IATACode__c.length == 0);
        }

        connectedCallback() {

            getLoggedUser().then(result => {
                this.loggedUser = JSON.parse(JSON.stringify(result));

                let user = this.loggedUser;
                if(user.Contact != null && user.Contact.AccountId != null){

                    getCompanyInfo({accountId : user.Contact.AccountId}).then(result => {
                        this.userAccount = JSON.parse(JSON.stringify(result));
                        let acc = this.userAccount;

                        if(acc.Website != null){
                        this.accountWeb = this.getPrettyLink(acc.Website);
                        this.accountHref = acc.Website;
                        }

                        if(acc.Logo_File_ID__c != null){
                            let imgurl = acc.Logo_File_ID__c;
                            this.profileDivStyle = 'background-image: url("' + imgurl + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px; width: 196px; height: 196px; position: absolute; top: 72px; left: 32px; border-radius: 50%; box-shadow: 0px 1px 12px 0px #827f7f; background-color:white;';
                        }
                        this.loading = false;
                    });

                }else{
                    this.noAccount = true;
                    this.loading = false;
                }

            });

            this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px;'
            this.profileDivStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:170px; width: 196px; height: 196px; position: absolute; top: 72px; left: 32px; border-radius: 50%;  box-shadow: 0px 1px 12px 0px #827f7f; background-color:white;';
        }

        getPrettyLink(url){
            let pretty;

            if(url != null && url.length > 0){
                pretty = url.replace(/((^\w+:|^)\/\/)/, '');
                return pretty;
            }
            return '';
        }
}
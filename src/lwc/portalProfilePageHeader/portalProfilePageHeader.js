/**
 * Created by pvavruska on 5/23/2019.
 */

import { LightningElement, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';
import { getRecord} from 'lightning/uiRecordApi';

//User and company details
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import getCompanyInfo from '@salesforce/apex/PortalProfileCtrl.getCompanyInfo';
import getCategoryTiles from '@salesforce/apex/PortalFAQsCtrl.getCategoryTiles';


//Import custom labels
import csp_Profile_CompanyEmail from '@salesforce/label/c.csp_Profile_CompanyEmail';
import csp_Profile_IATACode from '@salesforce/label/c.csp_Profile_IATACode';
import csp_Profile_Website from '@salesforce/label/c.csp_Profile_Website';



export default class PortalProfilePageHeader extends LightningElement {

    backgroundIcon = '/csportal/s/CSPortal/Images/Backgrounds/ControlTower.jpg';

        //Loading && Error
        @track loading = true;
        @track noAccount = false;

        @track backgroundStyle;
        @track profileDivStyle;
        @track category = '';
        @track profilePhotoStyle
        @track portalImg;
        @track iconLink;
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
            return (this.accountCode == null || this.accountCode.length == 0);
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

            //get the parameters for this page
            this.pageParams = getParamsFromPage();

            if(this.pageParams.category !== undefined && this.pageParams.category !== ''){
                //this.category = this.pageParams.category;
                getCategoryTiles({})
                .then(results => {
                    //because proxy.......
                    let resultsAux = JSON.parse(JSON.stringify(results));

                    if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                        let i;
                        for(i = 0; i < resultsAux.length; i++){
                            if(resultsAux[i].categoryName === this.pageParams.category){
                                this.category = resultsAux[i].categoryLabel;
                                this.iconLink = '/csportal/s/CSPortal/Images/FAQ/' + this.pageParams.category + '.svg';
                                break;
                            }
                        }
                        this.lstTiles = resultsAux;
                    }
                })
                .catch(error => {
                    console.log('PortalFAQPageHeader connectedCallback getCategoryTiles error: ' , error);
                });
            }
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
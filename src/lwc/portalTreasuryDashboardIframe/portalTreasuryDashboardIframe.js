import { LightningElement, track, api } from 'lwc';

import getAccessToken from '@salesforce/apex/PowerBiCtrl.getAccessToken';
import getReportDetails from '@salesforce/apex/PowerBiCtrl.getReportsDetails';
import getDatasetDetail from '@salesforce/apex/PowerBiCtrl.getDataset';
import getEmbedToken from '@salesforce/apex/PowerBiCtrl.getEmbedToken';
import getReportConfigDetails from '@salesforce/apex/PowerBiCtrl.getReportConfigDetails';
import newPremiumAccessRequest from '@salesforce/apex/TreasuryDashboardCtrl.premiumAccessRequest';

//labels
import ISSP_Access_Requested from '@salesforce/label/c.ISSP_Access_Requested';
import ISSP_Thanks_for_request from '@salesforce/label/c.ISSP_Thanks_for_request';
import standardDashboard from '@salesforce/label/c.Treasury_Dashboard_Standard_Dashboard';
import premiumDashboard from '@salesforce/label/c.Treasury_Dashboard_Premium_Dashboard';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalTreasuryDashboardIframe extends LightningElement {


    expandIcon = CSP_PortalPath + 'arrow-expand.png';
    collapseIcon = CSP_PortalPath + 'arrow-collapse.png';
    collapseExpandIcon = CSP_PortalPath + 'arrow-collapse-expand.png';

    labels = {
        ISSP_Access_Requested,
        ISSP_Thanks_for_request,
        standardDashboard,
        premiumDashboard
    }



    @api userId;
    @api contactId;
    @api isResponsive;
    @api applicationName;
    @api reportName;
    @api shrink;
    @api isPremiumUser;


    @track powerBiSource;
    @track loading = true;
    @track style = 'width:100%; border:none;';
    @track showModal = false;
    @track reportLabel;

    //request premium access
    @api tdPremiumService;
    @track showRequestAccess;
    @track accessModalHeader;
    @track accessModalBody;
    premiumApplicationId;
    @track requestingAccess = false;

    @track showSuccessModal;

    @track showCollapse;
    @track showEnlarge;

    @track ShowTDModal = false;

    isCloned = false;
    groupId;
    reportId;
    accessToken;
    datasetId;
    identityNeeded;
    embedToken;

    connectedCallback() {

        if(this.reportName.includes('Premium')) {
            this.reportLabel = this.labels.premiumDashboard;
        }else{
            this.reportLabel = this.labels.standardDashboard;
        }

        if(this.tdPremiumService) {
            this.accessModalHeader = this.tdPremiumService.Name;
            this.accessModalBody = this.tdPremiumService.Confirm_Text__c;
            this.premiumApplicationId = this.tdPremiumService.Id;
        }

        /*console.log('user id: ', this.userId);
        console.log('contact id: ', this.contactId);
        console.log('application name: ', this.applicationName);
        console.log('report name: ', this.reportName);
        console.log('is premium user: ', this.isPremiumUser);*/



        this.showCollapse = this.shrink;
        this.showEnlarge = !this.shrink || this.isPremiumUser;

        getReportConfigDetails({reportName: this.reportName})
            .then(result => {
                this.reportId = result.reportId;
                this.groupId = result.groupId;

                //console.log('lwc getConfigDetails result: ', JSON.stringify(result));

                if(this.reportId != undefined && this.groupId != undefined) {

                    getAccessToken({ applicationName: this.applicationName})
                        .then(result => {
                            //console.log('lwc getAccessToken result: ', JSON.stringify(result));

                            this.accessToken = result.access_token;
                            //console.log('lwc access token: ', this.accessToken);

                            if(this.accessToken) {

                                getReportDetails({ accessToken: this.accessToken, reportId: this.reportId})
                                    .then(result => {
                                        //console.log('lwc getReportDetails result: ', JSON.stringify(result));
                                        this.datasetId = result.datasetId;
                                        //console.log('lwc getReportDetails datasetId: ', this.datasetId);

                                        if(this.datasetId) {

                                            getDatasetDetail({accessToken: this.accessToken, datasetId: this.datasetId})
                                                .then(result => {
                                                    //console.log('lwc getDatasetDetail result: ', JSON.stringify(result));
                                                    this.identityNeeded = result.isEffectiveIdentityRequired;

                                                    if(this.identityNeeded) {
                                                        let tokenType = 'Aad';

                                                        //identity not needed
                                                        if(this.identityNeeded == 'false') {
                                                            this.createSrcAddress(this.reportId, this.groupId, this.accessToken, this.reportId, tokenType);
                                                        }


                                                        //identity needed
                                                        if(this.identityNeeded == 'true') {
                                                            tokenType = 'Embed';
                                                            //console.log('effective identity is needed');

                                                            getEmbedToken({ accessToken: this.accessToken, userId: this.userId, groupId: this.groupId, reportId: this.reportId, datasetId: this.datasetId})
                                                                .then(result => {
                                                                    //console.log('lwc getEmbedToken result: ', JSON.stringify(result));
                                                                    this.embedToken =  result.token;

                                                                    if(this.embedToken) {

                                                                        this.createSrcAddress(this.reportId, this.groupId, this.embedToken, this.reportId, tokenType);

                                                                    //embed token is undefined
                                                                    }else{
                                                                        this.loading = false;
                                                                        //console.log('Unable to get embed token!');
                                                                    }

                                                                })
                                                                //getEmbedToken error
                                                                .catch(error =>{
                                                                    this.loading = false;
                                                                    //console.log('lwc getEmbedToken error: ', JSON.stringify(error));

                                                                });

                                                        }
                                                    //identityNeeded is undefined
                                                    }else{
                                                        this.loading = false;
                                                        //console.log('Unable to get identityNeeded!');
                                                    }

                                                })
                                                //getDatasetDetail error
                                                .catch(error => {
                                                    this.loading = false;
                                                    //console.log('getDatasetDetail error: ', JSON.stringify(error));
                                                });
                                        //datasetId is undefined
                                        }else{
                                            this.loading = false;
                                            //console.log('Unable to get datasetId!');
                                        }
                                    //getReportDetails error
                                    })
                                    .catch(error => {
                                        this.loading = false;
                                        //console.log('getReportDetails error: ', JSON.stringify(error));
                                    });

                            //access token is undefined
                            }else{
                                this.loading = false;
                                //console.log('Unable to get access token!');
                            }
                        //access token error
                        })
                        .catch(error => {
                            this.loading = false;
                            //console.log('getAccessToken error: ', JSON.stringify(error));
                        });
                //groupId or reportId is undefined
                }else{
                    this.loading = false;
                    //console.log('Unable to get config details: groupId: ' + this.groupId + ', reportId: ' + this.reportId);
                }
            //getReportConfigDetails error
            })
            .catch(error => {
                this.loading = false;
                //console.log('getReportConfigDetails error: ', JSON.stringify(error));
            })

    }


    createSrcAddress(reportId, groupId, accessToken, objectId, tokenType) {
        let address= '/TreasuryDashboardPowerBiPage?embedUrl='+encodeURIComponent('https://app.powerbi.com/reportEmbed?reportId=' + reportId
                                        + '&groupId=' + groupId)+'+&accessToken='+accessToken+'&objectId='+objectId+'&tokenType='+tokenType;
        this.powerBiSource = address;
        this.loading = false;
    }

    enlarge() {

        if(! this.isCloned) {
            let pbi = this.template.querySelector('iframe');
            let clone = pbi.cloneNode(false);
            clone.id = "";
            clone.classList.remove('resp-iframe');
            clone.style = "height:100%; width:100%; border:none;";
            let iframeBig = this.template.querySelector('.iframeBig');
            iframeBig.parentNode.appendChild(clone);

            this.isCloned = true;

        }

        let myModal = this.template.querySelector('.myModal');
        myModal.classList.remove('slds-hide');
    }

    closeModal() {
       let myModal = this.template.querySelector('.myModal');
       myModal.classList.add('slds-hide');
    }


    abortRequest() {
        this.showRequestAccess = false;
    }

    requestAccessClicked() {
        this.showRequestAccess = true;
    }


    collapse() {
        const content = this.template.querySelector('.collapsible-content');
        //collapse or expand the area
        if(content.style.maxHeight) {
            if(content.style.maxHeight === content.scrollHeight + "px") {
                content.style.maxHeight = content.scrollHeight/8.5 +"px";
                this.changeIcons(true);
            }else{
                content.style.maxHeight = content.scrollHeight + "px";
                this.changeIcons(false);
            }
        }else{
            content.style.maxHeight = content.scrollHeight/8.5 +"px";
            this.changeIcons(true);
        }

    }

    changeIcons(collapse) {
        const collapseIcon = this.template.querySelector('.iconCollapse');
        const expandIcon = this.template.querySelector('.iconCollapseExpand');

        if(collapse) {
            collapseIcon.classList.add('slds-hide');
            expandIcon.classList.remove('slds-hide');

        }else{
            collapseIcon.classList.remove('slds-hide');
            expandIcon.classList.add('slds-hide');
        }

    }


    reloadPage() {
        location.reload();
    }


    requestPremiumAccess() {
        this.requestingAccess = true;

        newPremiumAccessRequest({applicationId: this.tdPremiumService.Id, contactId: this.contactId})
            .then(result => {
                let results = JSON.parse(JSON.stringify(result));
                if (results === 'okauto' || results === 'ok') {
                    this.showRequestAccess = false;
                    this.showSuccessModal = true;
                }
            })
            .catch(error => {
                this.showRequestAccess = false;
                this.showSuccessModal = true;
            });

    }


}
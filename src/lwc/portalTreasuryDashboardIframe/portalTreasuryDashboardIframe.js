import { LightningElement, track, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getReportDetails from '@salesforce/apex/TreasuryDashboardCtrl.getReportsDetails';
import getDatasetDetail from '@salesforce/apex/TreasuryDashboardCtrl.getDataset';
import getEmbedToken from '@salesforce/apex/TreasuryDashboardCtrl.getEmbedToken';
import getReportConfigDetails from '@salesforce/apex/TreasuryDashboardCtrl.getReportConfigDetails';
import newPremiumAccessRequest from '@salesforce/apex/TreasuryDashboardCtrl.premiumAccessRequest';

//labels
import ISSP_Access_Requested from '@salesforce/label/c.ISSP_Access_Requested';
import ISSP_Thanks_for_request from '@salesforce/label/c.ISSP_Thanks_for_request';
import standardDashboard from '@salesforce/label/c.Treasury_Dashboard_Standard_Dashboard';
import premiumDashboard from '@salesforce/label/c.Treasury_Dashboard_Premium_Dashboard';

//portal path
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalTreasuryDashboardIframe extends LightningElement {

    //icons
    expandIcon = CSP_PortalPath + 'TreasuryDashboard/Icons/arrow-expand.png';
    collapseIcon = CSP_PortalPath + 'TreasuryDashboard/Icons/arrow-collapse.png';
    iePremiumDashboardPicture = CSP_PortalPath + 'TreasuryDashboard/Images/premiun-dashboard-blurred.png';

    labels = {
        ISSP_Access_Requested,
        ISSP_Thanks_for_request,
        standardDashboard,
        premiumDashboard
    }

    scrollbarWidth;

    //info
    @api userId;
    @api contactId;
    @api isResponsive;
    @api applicationName;
    @api reportName;
    @api isPremiumUser;
    @track reportLabel;


    //iframe source + loading
    @track powerBiSource;
    @track loading = true;


    //request premium access
    @api tdPremiumService;
    @track showRequestAccess;
    @track accessModalHeader;
    @track accessModalBody;
    premiumApplicationId;
    @track requestingAccess = false;
    @track showSuccessModal;

    //show fullscreen modal
    @track showFullScreen = false;
    @track fullScreenContainerClass = '';
    @track fullScreenBodyClass = '';
    @track iframeContainerClass = 'resp-container';
    @track collapsibleContentClass = 'collapsible-content';
    @track requestButtonClass = 'requestButton';

    //collapse/expand icons
    @track showCollapseIcon = true;
    @track showCollapseExpandIcon = false;
    @track showCollapse;
    @track showEnlarge;

    get isPremiumDashboard() {
        return this.reportName.includes('Premium');
    }

    get isIe() {
        return this.detectIe();
    }


    @ api powerBiConfig;
    groupId;
    reportId;
    @ api accessToken;
    datasetId;
    identityNeeded;
    embedToken;
    expiration;

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

        this.showCollapse = this.isPremiumDashboard;
        this.showEnlarge = !this.isPremiumDashboard || (this.isPremiumDashboard && this.isPremiumUser);


        getReportConfigDetails({reportName: this.reportName})
            .then(result => {

                this.reportId = result.reportId;
                this.groupId = result.groupId;

                if(this.reportId != undefined && this.groupId != undefined) {

                    getReportDetails({ accessToken: this.accessToken, reportId: this.reportId, conf: this.powerBiConfig})
                        .then(result => {

                            this.datasetId = result.datasetId;

                            if(this.datasetId) {

                                getDatasetDetail({accessToken: this.accessToken, datasetId: this.datasetId, conf: this.powerBiConfig})
                                    .then(result => {

                                        this.identityNeeded = result.isEffectiveIdentityRequired;

                                        if(this.identityNeeded) {

                                            let tokenType = 'Aad';

                                            //identity not needed
                                            if(this.identityNeeded == 'false') {
                                                this.createSrcAddress(this.reportId, this.groupId, this.accessToken, this.reportId, tokenType, this.powerBiConfig, this.datasetId, this.expiration);
                                            }


                                            //identity needed
                                            if(this.identityNeeded == 'true') {
                                                tokenType = 'Embed';

                                                getEmbedToken({ accessToken: this.accessToken, userId: this.userId, groupId: this.groupId, reportId: this.reportId, datasetId: this.datasetId, conf: this.powerBiConfig})
                                                    .then(result => {

                                                        this.embedToken = result.token;
                                                        this.expiration = result.expiration;

                                                        if(this.embedToken) {

                                                            this.createSrcAddress(this.reportId, this.groupId, this.embedToken, this.reportId, tokenType, this.powerBiConfig, this.datasetId, this.expiration);

                                                        }else{
                                                            this.loading = false;
                                                            this.logMessage('Embed token is empty!');
                                                        }

                                                    })
                                                    //getEmbedToken error
                                                    .catch(error =>{
                                                        this.loading = false;
                                                        this.logError(error);
                                                    });

                                            }
                                        //identityNeeded is undefined
                                        }else{
                                            this.loading = false;
                                            this.logMessage('IdenityNeeded is empty!');
                                        }

                                    })
                                    //getDatasetDetail error
                                    .catch(error => {
                                        this.loading = false;
                                        this.logError(error);
                                    });
                            //datasetId is undefined
                            }else{
                                this.loading = false;
                                this.logMessage('DatasetId is empty!');
                            }
                        //getReportDetails error
                        })
                        .catch(error => {
                            this.loading = false;
                            this.logError(error);
                        });

                //groupId or reportId is undefined
                }else{
                    this.loading = false;
                    this.logMessage('GroupId/ReportId is empty!');
                }
            //getReportConfigDetails error
            })
            .catch(error => {
                this.loading = false;
                this.logError(error);
            })


    }


    logError(error) {
        let message = JSON.parse(JSON.stringify(error)).body.message;
        console.error('Iframe error: ', message);
        this.showToast(message);
    }

    logMessage(message) {
        console.error('Iframe error: ', message);
        this.showToast(message);
    }

    showToast(toastMessage) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: toastMessage,
                variant: 'error',
                mode: 'pester'
            })
        );

    }


    //get scrollbar width
    renderedCallback() {

        if(! this.scrollbarWidth) {
            let inner = this.template.querySelector('.inner');
            let outer = this.template.querySelector('.outer');
            if(inner && outer) {
                this.scrollbarWidth = outer.offsetWidth - inner.offsetWidth;
                outer.classList.add('slds-hide');
            }
        }

    }


    createSrcAddress(reportId, groupId, accessToken, objectId, tokenType, conf, datasetId, expiration) {
        let address= '/TreasuryDashboardPowerBiPage?embedUrl='+encodeURIComponent(conf.Report_Resource__c + '?reportId=' + reportId
                                        + '&groupId=' + groupId) +'+&accessToken='+accessToken+'&objectId='+objectId+'&tokenType='+tokenType+'&datasetId='+datasetId+'&groupId='+groupId+'&expiration='+expiration;
        this.powerBiSource = address;
        this.loading = false;
    }


    abortRequest() {
        this.showRequestAccess = false;
    }

    requestAccessClicked() {
        this.showRequestAccess = true;
    }

    detectIe() {
        let ua = window.navigator.userAgent;
        if (ua.indexOf("Trident/7.0") > -1){
            return true;
        }

        else if (ua.indexOf("Trident/6.0") > -1) {
            return true;
        }

        else if (ua.indexOf("Trident/5.0") > -1) {
            return true;
        }

        else if (ua.indexOf("MSIE ") > -1){
            return true;

        }else {
            return false;
        }

    }


    collapse() {

        this.collapsibleContentClass = 'collapsible-content-collapsed';

        this.showCollapseIcon = false;
        this.showCollapseExpandIcon = true;

        let self = this;

        setTimeout(
            function() {
                self.requestButtonClass = 'requestButton-collapsed';
            }
        , 400)

    }

    expand() {

        this.collapsibleContentClass = 'collapsible-content';
        this.requestButtonClass = 'requestButton';

        this.showCollapseIcon = true;
        this.showCollapseExpandIcon = false;

    }


    reloadPage() {
        location.reload();
    }


    requestPremiumAccess() {
        this.requestingAccess = true;

        newPremiumAccessRequest({applicationId: this.premiumApplicationId, contactId: this.contactId})
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

    handleFullScreen() {
        this.showFullScreen = true;
        this.fullScreenContainerClass = 'fullScreenModal';
        this.fullScreenBodyClass = 'fullScreenContainer';
        this.iframeContainerClass = 'resp-container-full-screen';

        /*prevent page body from jumping to left/right when modal is open*/
        document.body.style.overflow = 'hidden';
        document.body.style.paddingRight = this.scrollbarWidth + 'px';
    }

    closeFullScreen() {
        this.showFullScreen = false;
        this.fullScreenContainerClass = '';
        this.fullScreenBodyClass = '';
        this.iframeContainerClass = 'resp-container';

        /*prevent page body from jumping to left/right when modal is open*/
        document.body.style.overflow = 'auto';
        document.body.style.paddingRight = 0;

    }


}
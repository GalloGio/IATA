import { LightningElement, track } from 'lwc';

//navigation
import { navigateToPage, getPageName } from 'c/navigationUtils';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//label
import accessDeniedMessage from '@salesforce/label/c.Treasury_Dashboard_Report_Access_Denied';
import accessDeniedMessageLink from '@salesforce/label/c.Treasury_Dashboard_Report_Access_Denied_Link';

import userId from '@salesforce/user/Id';
import getPowerBICredentials from '@salesforce/apex/TreasuryDashboardReportCtrl.getPowerBICredentials';
import getReportConfigDetails from '@salesforce/apex/TreasuryDashboardReportCtrl.getReportConfigDetails';
import getServicePrincipalAccessToken from '@salesforce/apex/TreasuryDashboardReportCtrl.getServicePrincipalAccessToken';
import getServicePrincipalEmbedToken from '@salesforce/apex/TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken';

//userId
import getUserInformation from '@salesforce/apex/TreasuryDashboardCtrl.getUserInformation';

//portal path
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';



export default class PortalTreasuryDashboardReportIframe extends LightningElement {

     //icons
    expandIcon = CSP_PortalPath + 'TreasuryDashboard/Icons/arrow-expand.png';

    labels = {
        accessDeniedMessage,
        accessDeniedMessageLink
    }



    //application name
    applicationName = 'TreasuryDashboardReport';

    //show spinner
    @track loading = true;

    //iframe - enlarge classes
    @track showFullScreen = false;
    @track fullScreenContainerClass = '';
    @track fullScreenBodyClass = '';
    @track iframeContainerClass = 'resp-container';

    //scrollbar width
    scrollbarWidth;

    //iframe source
    @track powerBiSource;

    //report info
    reportName;
    @ track reportLabel;
    reportParams = '';
    reportType;

    //user info
    isStandardUser;
    isPremiumUser;
    @ track userHasAccessToReport = true;

    //error
    @track errorText;

    //credentials configuration
    conf;

    //report details
    tokenType = 'Embed';
    groupId;
    reportId;


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

    connectedCallback() {

        let parsedParams = this.parseUrlParams();
        if(parsedParams && parsedParams.length > 0) {
            for(let i = 0; i < parsedParams.length; i++) {
                if(parsedParams[i].includes('reportName')) {
                    let name = parsedParams[i].split('=')[1];
                    if(name) {
                       this.reportName = name;
                    }
                }else{
                    this.reportParams += '&' + parsedParams[i];
                }
            }
        }


        if(this.reportName) {

            getPowerBICredentials({configurationName: this.applicationName})
                .then(result => {

                    if(result) {
                        this.conf = result;

                        getReportConfigDetails({reportName: this.reportName})
                            .then(result => {

                                this.reportId = result.reportId;
                                this.groupId = result.groupId;
                                this.reportLabel = result.reportLabel;
                                this.reportType = result.type;

                                getUserInformation({})
                                    .then(result => {

                                        this.isStandardUser = result.isStandardUser;
                                        this.isPremiumUser = result.isPremiumUser;

                                        let isEligible = false;

                                        //standard user has access only to standard report
                                        if(this.isStandardUser && this.reportType === 'Standard') {

                                            isEligible = true;

                                        //premium user has access to standard and premium report
                                        } else if(this.isPremiumUser && (this.reportType === 'Standard' || this.reportType === 'Premium')) {

                                            isEligible = true;

                                        }

                                        //user has access to report
                                        if(isEligible) {
                                            this.userHasAccessToReport = true;

                                            getServicePrincipalAccessToken({conf: this.conf})
                                                .then(result => {

                                                    if(result.access_token) {

                                                        getServicePrincipalEmbedToken({accessToken: result.access_token, userId: userId, groupId: this.groupId, reportId: this.reportId, conf: this.conf})
                                                            .then(result => {

                                                                if(result.token) {

                                                                    this.createSrcAddress(this.reportId, this.groupId, result.token, this.reportId, this.tokenType, this.conf, result.expiration);

                                                                }else{
                                                                    //embed token is empty
                                                                    this.loading = false;
                                                                    this.logMessage('Embed token is empty!');
                                                                }

                                                            })
                                                            //getServicePrincipalEmbedToken error
                                                            .catch(error => {
                                                                this.loading = false;
                                                                this.logError(error);
                                                            });

                                                    }else{
                                                        //access_token is empty
                                                        this.loading = false;
                                                        this.logMessage('Access token is empty!');
                                                    }

                                                })
                                                //getReportConfigDetails error
                                                .catch(error => {
                                                    this.loading = false;
                                                    this.logError(error);
                                                });

                                        //user is not eligible to see the report
                                        }else{

                                            this.loading = false;
                                            this.showAccessDenied();
                                        }

                                    })
                                    //getUserInformation error
                                    .catch(error => {
                                        this.loading = false;
                                        this.logError(error);

                                    });

                            })
                            //getReportConfigDetails error
                            .catch(error => {
                                this.loading = false;
                                this.logError(error);
                            });

                    }else{
                        //access_token is empty
                        this.loading = false;
                        this.logMessage('PowerBI credentials are empty!');
                    }

                })
                //getPowerBICredentials error
                .catch(error => {
                    this.loading = false;
                    this.logError(error);
                });

        //report name is empty
        }else{
            this.loading = false;
            this.logMessage('Report name is empty!');
        }


    }


    logError(error) {
        let message = JSON.parse(JSON.stringify(error)).body.message
        console.error('Report iframe error: ', message);
        this.showToast(message);
    }

    logMessage(message) {
        console.error('Report iframe error: ', message);
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

    createSrcAddress(reportId, groupId, accessToken, objectId, tokenType, conf, expiration) {
        if(this.reportParams) {
            reportId += this.reportParams;
        }

        let address= '/TreasuryDashboardPowerBiReportPage?embedUrl='+encodeURIComponent(conf.Report_Resource__c + '?reportId=' + reportId) +'&accessToken='+accessToken+'&objectId='+objectId+'&tokenType='+tokenType+'&groupId='+groupId+'&expiration='+expiration;
        this.powerBiSource = address;
        this.loading = false;
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

    parseUrlParams() {
        let url = location.search;
        let query = url.substr(1);
        let result = [];
        if(query) {
            //partner portal codes "%20" to "+" so we need to code it back before sending to PowerBI
            //otherwise PowerBI would not get it correctly
            query = query.replace(/\+/g, '%20');
            result = query.split("&");
        }
        return result;
    }


    showAccessDenied() {
        let name;
        if(this.reportLabel === undefined) {
            if(this.reportName === undefined) {
                name = 'Error';
            }else{
                name = this.reportName;
            }
        }else{
            name = this.reportLabel;
        }

        this.errorText = this.getSubscriptionLink(name);
        this.userHasAccessToReport = false;
    }

    closeAccessDenied() {
        this.userHasAccessToReport = true;
    }

    navigateToTreasuryDashboard() {
        navigateToPage(CSP_PortalPath + 'treasury-dashboard');
    }

    getSubscriptionLink(reportName) {
        let label = this.labels.accessDeniedMessage;
        let message = label.replace('{name}', reportName);
        return message;
    }

}
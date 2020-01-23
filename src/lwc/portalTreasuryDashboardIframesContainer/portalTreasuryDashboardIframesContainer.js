
import { LightningElement, track, api } from 'lwc';

import getPowerBICredentials from '@salesforce/apex/TreasuryDashboardCtrl.getPowerBICredentials';
import getAccessToken from '@salesforce/apex/TreasuryDashboardCtrl.getAccessToken';

export default class PortalTreasuryDashboardIframesContainer extends LightningElement {

    @api reportName = 'Treasury_Dashboard';
    @api premiumReportName = 'Treasury_Dashboard_Premium';
    @api applicationName = 'TreasuryDashboard';

    //from parent component
    @api tdPremiumService;
    @api userId;
    @api contactId;
    @api isStandardUser;
    @api isPremiumUser;


    @track loading = true;

    @api powerBiConfig;
    @api accessToken;


    connectedCallback() {

        getPowerBICredentials({configurationName: this.applicationName})
            .then(result => {
                this.powerBiConfig = result;

                if(this.powerBiConfig) {

                    getAccessToken({ conf: this.powerBiConfig})
                        .then(result => {

                            this.accessToken =  result.access_token;
                            if(this.accessToken) {

                                this.loading = false;

                            }else{
                                //access token is empty
                                this.logMessage('Access token is empty!');
                            }

                        })
                        .catch(error => {
                            //getAccessToken
                            this.logError(error);

                        });

                }else{
                    //powerBiConfig is empty
                    this.logMessage('PowerBiConfig is empty!');
                }
            })
            .catch(error => {
                //getPowerBICredentials error
                this.logError(error);
            });

    }


    logError(error) {
        console.log('Iframe error: ', JSON.parse(JSON.stringify(error)).body.message);
    }

    logMessage(message) {
        console.log('Iframe error: ', message);
    }



}
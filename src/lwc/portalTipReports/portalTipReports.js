import { LightningElement, track, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';

import getPowerBICredentials from '@salesforce/apex/TipCtrl.getPowerBICredentials';
import getAccessToken from '@salesforce/apex/TipCtrl.getAccessToken';
import getReportDetails from '@salesforce/apex/TipCtrl.getReportsDetails';
import getEmbedToken from '@salesforce/apex/TipCtrl.getEmbedToken';

export default class PortalTipReports extends LightningElement {

    applicationName = 'TipReports';

    @track loading = true;
    @track powerBiSource;

    //report details
	@api reportId;
	@api groupId;
    @track datasetId;
    @track embedUrl;
    @track embedToken;
    @track embedTokenExpiration;

	//access token
	accessToken;
    powerBiConfig;


    connectedCallback() {

        if(this.reportId != undefined && this.groupId != undefined) {

            getPowerBICredentials({configurationName: this.applicationName})
				.then(result => {

					this.powerBiConfig = result;

					if(this.powerBiConfig) {

						getAccessToken({conf: this.powerBiConfig})
							.then(result => {

								this.accessToken = result.access_token;

								if(this.accessToken) {

									getReportDetails({accessToken: this.accessToken, reportId: this.reportId, conf: this.powerBiConfig})
										.then(result => {

											this.datasetId = result.datasetId;
											this.embedUrl = result.embedUrl;

											if(this.datasetId) {

												getEmbedToken({accessToken: this.accessToken, userId: userId, groupId: this.groupId, reportId: this.reportId, datasetId: this.datasetId, conf: this.powerBiConfig})
													.then(result => {

														this.embedToken = result.token;
														this.embedTokenExpiration = result.expiration;

														this.createSrcAddress(this.reportId, this.groupId, this.embedToken, this.reportId, this.powerBiConfig, this.datasetId, this.embedTokenExpiration, this.embedUrl);

													})
													.catch(error => {
														//getEmbedToken error
														this.loading = false;
														this.logError(error);
													});

											} else{
												//datasetId is empty
												this.loading = false;
												this.logMessage('Access token is empty!');
											}

										})
										.catch(error => {
											//getReportDetails error
											this.loading = false;
											this.logError(error);
										});

								}else{
									//access token is empty
									this.loading = false;
									this.logMessage('Access token is empty!');
								}

							})
							.catch(error => {
								//getAccessToken error
								this.loading = false;
								this.logError(error);
							});

					}else{
						//powerBiConfig is empty
						this.loading = false;
						this.logMessage('PowerBiConfig is empty!');
					}

				})
				.catch(error => {
					//getPowerBICredentials error
					this.loading = false;
					this.logError(error);
				});

        } else {
			//groupId or reportId is undefined
			this.loading = false;
			this.logMessage('GroupId/ReportId is empty!');
		}


    }


    createSrcAddress(reportId, groupId, accessToken, objectId, conf, datasetId, expiration, embedUrl) {
        let address = '';
        if(embedUrl) {
            address= '/TipPowerBiPage?embedUrl='+embedUrl+'+&accessToken='+accessToken+'&objectId='+objectId+'&datasetId='+datasetId+'&groupId='+groupId+'&expiration='+expiration;
        } else {
            address= '/TipPowerBiPage?embedUrl='+encodeURIComponent(conf.Report_Resource__c + '?reportId=' + reportId
            										+ '&groupId=' + groupId) +'+&accessToken='+accessToken+'&objectId='+objectId+'&datasetId='+datasetId+'&groupId='+groupId+'&expiration='+expiration;
        }
		this.powerBiSource = address;
		this.loading = false;
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

}
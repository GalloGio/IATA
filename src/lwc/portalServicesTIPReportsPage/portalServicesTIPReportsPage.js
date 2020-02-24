import { LightningElement, track } from 'lwc';

//import labels
import ISSP_AMS_ACCR_Alert1 from '@salesforce/label/c.ISSP_AMS_ACCR_Alert1';

//import controller methods
import getTIPReportPageWrapper from '@salesforce/apex/PortalServiceTIPReportsCtrl.getTIPReportPageWrapper';
import getExpiringLinkIfap from '@salesforce/apex/PortalServiceTIPReportsCtrl.getExpiringLinkIfap';
import createDocumentTrackerRecord from '@salesforce/apex/PortalServiceTIPReportsCtrl.createDocumentTrackerRecord';

export default class PortalServicesTIPReportsPage extends LightningElement {

	label = { 
        ISSP_AMS_ACCR_Alert1
    };

	@track loading = true;
	@track viewResults = false;
	@track haveAccessToTIPReports = false;
	@track tipReportsTableColumns = [];
	@track tipReportsList = [];

	@track selectedReport = {};
	@track showReportPopup = false;

	connectedCallback() {

		this.tipReportsTableColumns = [
			{label: 'File Type', fieldName: 'reportType', type: 'text'},
			{label: 'Posted Date', fieldName: 'lastModifiedDate', type: 'date', typeAttributes: {year: "numeric", month: "short", day: "2-digit", hour: "2-digit", minute: "2-digit"}, cellAttributes: {class: ''}},
			{label: 'File Name/ Report Name', fieldName: 'masterLabel', type: 'text', cellAttributes: {class: ''}},
			{label: 'Action', type: 'button', typeAttributes: { label: 'Open', name: 'openReportOrFile', variant: 'base' }}
		];

		getTIPReportPageWrapper({})
		.then(results => {
			
			let resultsAux = JSON.parse(JSON.stringify(results));

			this.haveAccessToTIPReports = resultsAux.haveAccessToTIPReports;

			if(this.haveAccessToTIPReports === true){
				this.viewResults = true;
				this.tipReportsList = resultsAux.lstTIPReports;

			}else{
				this.viewResults = false;
				this.tipReportsList = [];
			}
			this.loading = false;

		})
		.catch(error => {
			//something went wrong, stop loading
			this.viewResults = false;
			this.tipReportsList = [];
			this.loading = false;
		});

	}

	handleRowAction(event){

		const actionName = event.detail.action.name;
		const row = event.detail.row;
		switch (actionName) {
			case 'openReportOrFile':
				this.openReportPopup(row);
				break;
			default:
		}
	}

	openReportPopup(row){
		let selectedReportAux = JSON.parse(JSON.stringify(row));

		if(selectedReportAux.reportType === 'Power BI'){
			this.selectedReport = selectedReportAux;
			this.showReportPopup = true;
		}else{
			
			getExpiringLinkIfap({fileName : selectedReportAux.developerName})
			.then(getExpiringLinkIfapresults => {
				
				let linkAux = JSON.parse(JSON.stringify(getExpiringLinkIfapresults));
				let finalLink = linkAux.replace("&amp;","&");
				let newWin = window.open(finalLink);
				if(!newWin || newWin.closed || typeof newWin.closed=='undefined') {
					alert(this.label.ISSP_AMS_ACCR_Alert1);
				}
			});

			createDocumentTrackerRecord({fileId : selectedReportAux.id, reportId : selectedReportAux.isspExternalReportId})
			.then(() => {});

		}

		
	}

	handleReportPopupCloseButton(event){
		this.selectedReport = {};
		this.showReportPopup = false;
	}

}
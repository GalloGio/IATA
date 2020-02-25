import { LightningElement, track } from 'lwc';

//import labels
import ISSP_AMS_ACCR_Alert1 from '@salesforce/label/c.ISSP_AMS_ACCR_Alert1';
import CSP_Service_TIPReports_NoAccess from '@salesforce/label/c.CSP_Service_TIPReports_NoAccess';
import CSP_Service_TIPReports_NoReports from '@salesforce/label/c.CSP_Service_TIPReports_NoReports';
import CSP_Service_TIPReports_TextFileType from '@salesforce/label/c.CSP_Service_TIPReports_TextFileType';
import CSP_Service_TIPReports_TextPostedDate from '@salesforce/label/c.CSP_Service_TIPReports_TextPostedDate';
import CSP_Service_TIPReports_TextFileName from '@salesforce/label/c.CSP_Service_TIPReports_TextFileName';
import CSP_Service_TIPReports_TextAction from '@salesforce/label/c.CSP_Service_TIPReports_TextAction';
import CSP_Service_TIPReports_TextOpen from '@salesforce/label/c.CSP_Service_TIPReports_TextOpen';

//import controller methods
import getTIPReportPageWrapper from '@salesforce/apex/PortalServiceTIPReportsCtrl.getTIPReportPageWrapper';
import getExpiringLinkIfap from '@salesforce/apex/PortalServiceTIPReportsCtrl.getExpiringLinkIfap';
import createDocumentTrackerRecord from '@salesforce/apex/PortalServiceTIPReportsCtrl.createDocumentTrackerRecord';

export default class PortalServicesTIPReportsPage extends LightningElement {

	label = { 
		ISSP_AMS_ACCR_Alert1,
		CSP_Service_TIPReports_NoAccess,
		CSP_Service_TIPReports_NoReports,
		CSP_Service_TIPReports_TextFileType,
		CSP_Service_TIPReports_TextPostedDate,
		CSP_Service_TIPReports_TextFileName,
		CSP_Service_TIPReports_TextAction,
		CSP_Service_TIPReports_TextOpen
    };

	@track loading = true;
	@track viewResults = false;
	@track haveAccessToTIPReports = false;
	@track tipReportsTableColumns = [];
	@track tipReportsList = [];

	@track selectedReport = {};
	@track showReportPopup = false;
	@track viewPopupFooter = false;

	connectedCallback() {

		this.tipReportsTableColumns = [
			{label: this.label.CSP_Service_TIPReports_TextFileType , fieldName: 'reportType', type: 'text'},
			{label: this.label.CSP_Service_TIPReports_TextPostedDate , fieldName: 'lastModifiedDate', type: 'date', typeAttributes: {year: "numeric", month: "short", day: "2-digit", hour: "2-digit", minute: "2-digit"}, cellAttributes: {class: ''}},
			{label: this.label.CSP_Service_TIPReports_TextFileName, fieldName: 'masterLabel', type: 'text', cellAttributes: {class: ''}},
			{label: this.label.CSP_Service_TIPReports_TextAction, type: 'button', typeAttributes: { label: this.label.CSP_Service_TIPReports_TextOpen, name: 'openReportOrFile', variant: 'base' }}
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
		.catch(() => {
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
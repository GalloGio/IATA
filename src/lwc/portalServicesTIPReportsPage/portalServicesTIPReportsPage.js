import { LightningElement, track } from 'lwc';
import { getPageName }    from 'c/navigationUtils';

//import labels
import ISSP_AMS_ACCR_Alert1 from '@salesforce/label/c.ISSP_AMS_ACCR_Alert1';
import CSP_Service_TIPReports_NoAccess from '@salesforce/label/c.CSP_Service_TIPReports_NoAccess';
import CSP_Service_TIPReports_NoReports from '@salesforce/label/c.CSP_Service_TIPReports_NoReports';
import CSP_Service_TIPReports_TextFileType from '@salesforce/label/c.CSP_Service_TIPReports_TextFileType';
import CSP_Service_TIPReports_TextPostedDate from '@salesforce/label/c.CSP_Service_TIPReports_TextPostedDate';
import CSP_Service_TIPReports_TextFileName from '@salesforce/label/c.CSP_Service_TIPReports_TextFileName';
import CSP_Service_TIPReports_TextAction from '@salesforce/label/c.CSP_Service_TIPReports_TextAction';
import CSP_Service_TIPReports_TextOpen from '@salesforce/label/c.CSP_Service_TIPReports_TextOpen';
import CSP_Service_AirlineDailySales_NoAccess from '@salesforce/label/c.CSP_Service_AirlineDailySales_NoAccess';
import CSP_Service_SmartLite_NoAccess from '@salesforce/label/c.CSP_Service_SmartLite_NoAccess';

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
		CSP_Service_TIPReports_TextOpen,
		CSP_Service_AirlineDailySales_NoAccess,
		CSP_Service_SmartLite_NoAccess
	};

	@track loading = true;
	@track viewResults = false;
	@track haveAccessToService = false;
	@track tipReportsTableColumns = [];
	@track tipReportsList = [];

	@track selectedReport = {};
	@track showReportPopup = false;
	@track viewPopupFooter = false;

	get noAccessMessage() {
		if (this.pageName==='service-tipreports') {
			return this.label.CSP_Service_TIPReports_NoAccess;
		}
		if (this.pageName==='airline-daily-sales') {
			return this.label.CSP_Service_AirlineDailySales_NoAccess;
		}
		if (this.pageName==='smart-lite') {
			return this.label.CSP_Service_SmartLite_NoAccess;
		}
		return '';
	}

	connectedCallback() {

		this.pageName = getPageName();

		this.tipReportsTableColumns = [
			{label: this.label.CSP_Service_TIPReports_TextPostedDate , fieldName: 'lastModifiedDate', type: 'date', typeAttributes: {year: "numeric", month: "short", day: "2-digit", hour: "2-digit", minute: "2-digit"}, cellAttributes: {class: ''}},
			{label: this.label.CSP_Service_TIPReports_TextFileName, fieldName: 'masterLabel', type: 'text', cellAttributes: {class: ''}},
			{label: this.label.CSP_Service_TIPReports_TextAction, type: 'button', typeAttributes: { label: this.label.CSP_Service_TIPReports_TextOpen, name: 'openReportOrFile', variant: 'base' }}
		];

		getTIPReportPageWrapper({pageName : this.pageName})
		.then(results => {
			
			let resultsAux = JSON.parse(JSON.stringify(results));

			this.haveAccessToService = resultsAux.haveAccessToTIPReports;

			if(this.haveAccessToService === true){
				this.viewResults = resultsAux.lstTIPReports.length>0;
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
		if(actionName === 'openReportOrFile'){
				this.openReportPopup(row);
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

			createDocumentTrackerRecord({fileId : selectedReportAux.id, reportId : selectedReportAux.isspExternalReportId, pageName : this.pageName})
			.then(() => {});
		}
	}

	handleReportPopupCloseButton(event){
		this.selectedReport = {};
		this.showReportPopup = false;
	}

}
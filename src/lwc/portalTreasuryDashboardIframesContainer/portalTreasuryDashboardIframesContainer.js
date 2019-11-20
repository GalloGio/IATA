
import { LightningElement, track, api } from 'lwc';

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


    connectedCallback() {

    }



}
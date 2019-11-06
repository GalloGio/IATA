import { LightningElement,api } from 'lwc';

export default class PortalCaseDetailsPage extends LightningElement {
     @api isExpired;

    handleExpired(event) {
        this.isExpired = event.detail;
      }
}
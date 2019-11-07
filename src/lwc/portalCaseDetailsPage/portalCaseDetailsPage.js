import { LightningElement,track } from 'lwc';

export default class PortalCaseDetailsPage extends LightningElement {
     @track isExpired;

    handleExpired(event) {
        this.isExpired = event.detail;
      }
}
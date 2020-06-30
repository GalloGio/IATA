import { LightningElement } from 'lwc';
import { getParamsFromPage } from'c/navigationUtils';
import closeCase from '@salesforce/apex/PortalCaseClosureController.closeCase';

export default class PortalCaseClosure extends LightningElement {

	caseId = null;

	connectedCallback() {
		console.log('test 123');
		var sPageURL = ''+ window.location;
		console.log('page url', sPageURL);
		closeCase({pageUrl: sPageURL}).then(data => {
			console.log('success 123');
			console.log(data);
		}).catch(error => {
			console.log('error 123');
			console.log(error);
		})
		
	}

}
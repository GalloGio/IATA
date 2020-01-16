import { LightningElement, api } from 'lwc';
import createCommunity360ReadEntry from '@salesforce/apex/Community360Ctrl.createCommunity360ReadEntry';

export default class PortalCommunity360Util extends LightningElement {

	@api
	get recordId(){
		return this._recordId;
	}
	set recordId(value){
		this._recordId = value;
		createCommunity360ReadEntry({recortId : this._recordId});
	}
}

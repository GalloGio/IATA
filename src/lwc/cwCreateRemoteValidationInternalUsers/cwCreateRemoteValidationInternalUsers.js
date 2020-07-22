import { LightningElement, api, wire, track } from 'lwc';
import getStationRemoteValidations from "@salesforce/apex/CW_RemoteValidationsController.getUserRemoteValidations";
import createRemoteValidation from "@salesforce/apex/CW_RemoteValidationsController.createRemoteValidation";
import labels from 'c/cwOneSourceLabels';
export default class CwCreateRemoteValidationInternalUsers extends LightningElement {
	_recordId;
	@api 
	get recordId(){
		return this._recordId;
	}
	set recordId(value){
		this._recordId = value;
		this.getRemoteValidations();
	}
	@track loading = true;
	@track success = false;
	@track errorMessage;
	@track existingRemoteValidations = [];
	label = labels.labels();

	getRemoteValidations(){
       getStationRemoteValidations({ managedFacilitiesIds: [this.recordId] }).then(result =>{
			JSON.parse(result).forEach(remval => {
				if (remval.Order.Remote_Validation_Status__c !== "RV_Complete" && remval.Order.Remote_Validation_Status__c !== "Cancelled") {
					this.existingRemoteValidations.push(remval);
				}
			});
		this.loading = false;
	   })
	}


	get creationAvailable(){
		return (!this.existingRemoteValidations || this.existingRemoteValidations.length < 1) && !this.success;
	}

	createRemVal(){
		if (confirm('Are you sure? This will trigger all the Remote Validation purchase process')){
			this.success = false;
			this.errorMessage = null;
			this.loading = true;
			createRemoteValidation({stationId : this.recordId}).then(res => {
				this.success = res.success;
				this.errorMessage = res.errorMessage;
				this.loading=false;
			})
		}
	}

}
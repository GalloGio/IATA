import { LightningElement, track, api, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAccountRoles from '@salesforce/apex/PortalInvitationController.getAccountRoles';
// import getServices from '@salesforce/apex/PortalInvitationController.getServices';

import INVITATION_OBJECT from '@salesforce/schema/Invitation__c';
import EMAIL_FIELD from '@salesforce/schema/Invitation__c.Email__c';
import SERVICEID_FIELD from '@salesforce/schema/Invitation__c.ServiceId__c'
import ACCOUNTROLEID_FIELD from '@salesforce/schema/Invitation__c.AccountRoleId__c';

export default class PortalInvitation extends LightningElement {
	
	@track accountRoles;
	@wire(getAccountRoles) wireRoles({error, data}) {
		if(data) {
			let rolesList = [];
			Object.entries(data).forEach(([key, value]) => {
				rolesList.push({
					label: key,
					value: value
				});
			});
			this.accountRoles = rolesList;
		} else if(error) {
			console.log(error);
		}
	};
	
	email;
	accountRoleId;
	
	title = 'Invite';
	
	handleChangeEvent() {
		switch(event.target.name) {
			case 'email':
				this.email = event.target.value;
			case 'accountRole':
				this.accountRoleId = event.target.value;
			default:
				break;
		}
	}
	
	createInvite() {
		let serviceId = new URL(window.location.href).searchParams('serviceId');
		
		let fields = {};
		fields[EMAIL_FIELD.fieldApiName] = this.email;
		fields[ACCOUNTROLEID_FIELD.fieldApiName] = this.accountRoleId;
		fields[SERVICEID_FIELD.fieldApiName] = serviceId;
		
		createRecord(
			{ apiName: INVITATION_OBJECT.objectApiName, fields }
		).then(
			invitation => {
				// this.invitationId = invitation.id;
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Success',
						message: 'Invitation created',
						variant: 'success'
					})
				);
			}
		).catch(
			error => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error while creting record',
						message: error.body.message,
						variant: 'error'
					})
				);
			}
		);
	}
	
}
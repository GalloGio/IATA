import { LightningElement, track, api, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getParamsFromPage } from 'c/navigationUtils';

import getAccountRoles from '@salesforce/apex/PortalInvitationController.getAccountRoles';
import sendEmail from '@salesforce/apex/PortalInvitationController.sendEmail';

import INVITATION_OBJECT from '@salesforce/schema/Invitation__c';
import EMAIL_FIELD from '@salesforce/schema/Invitation__c.Email__c';
import ACCOUNTROLEID_FIELD from '@salesforce/schema/Invitation__c.AccountRoleId__c';
import ACCOUNTID_FIELD from '@salesforce/schema/Invitation__c.AccountId__c';
import ROLE_FIELD from '@salesforce/schema/Invitation__c.Role__c';
import SERVICEID_FIELD from '@salesforce/schema/Invitation__c.ServiceId__c';

export default class PortalInvitation extends LightningElement {
	
	@track roles;
	
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
		
		let rolesList = [
			{label: "Service Admin", value:"Service Admin"},
			{label: "Standard User", value:"Standard User"}
		];
		this.roles = rolesList;
		
	}
	
	@api title = 'Invite';
	@track email;
	@track accountRoleId;
	@track accountId;
	@track serviceId;
	
	connectedCallback() {
		let pageParams = getParamsFromPage();
		if(pageParams.serviceId !== undefined) {
			this.serviceId = pageParams.serviceId;
		}
	}
	
	handleChangeEvent(event) {
		this.email = event.target.value;
	}
	
	handdleChange(event) {
		switch(event.target.name) {
			case 'accountRole':
				let valueArray = event.target.value.split(':');
				this.accountRoleId = valueArray[0];
				this.accountId = valueArray[1];
				break;
			case 'role':
				this.roleId = event.target.value;
				break;
			case 'email':
				this.email = event.target.value;
				break;
		}
	}
	
	cancel() {
		this.dispatchEvent(new CustomEvent('cancel'));
	}
	
	createInvite() {
		console.log(this.email);
		console.log(this.accountRoleId);
		console.log(this.roleId);
		console.log(this.accountId);
		console.log(this.serviceId);
		
		let fields = {};
		fields[EMAIL_FIELD.fieldApiName] = this.email;
		fields[ACCOUNTROLEID_FIELD.fieldApiName] = this.accountRoleId;
		fields[ACCOUNTID_FIELD.fieldApiName] = this.accountId;
		fields[ROLE_FIELD.fieldApiName] = this.roleId;
		if(this.serviceId !== undefined) fields[SERVICEID_FIELD.fieldApiName] = this.serviceId;
		
		createRecord(
			{ apiName: INVITATION_OBJECT.objectApiName, fields }
		).then(
			invitation => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Success',
						message: 'Invitation created: '+invitation.id,
						variant: 'success'
					})
				);
				
				sendEmail(
					{emailAddress: this.email}
				).then(
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Success',
							message: 'Invitation email sent',
							variant: 'success'
						})
					)
				).catch(
					error => {
						console.log(error);
						this.dispatchEvent(
							new ShowToastEvent({
								title: 'Error while sending email',
								message: error.body.message,
								variant: 'error'
							})
						);
					}
				);
			}
		).catch(
			error => {
				console.log(error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error while creting record',
						message: error.body.message,
						variant: 'error'
					})
				);
			}
		);
	};
}
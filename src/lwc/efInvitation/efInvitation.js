import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import RegistrationUtils from 'c/registrationUtils';

import customStyle from '@salesforce/resourceUrl/CSP_Stylesheet';

import getAccountRoles from '@salesforce/apex/EF_InvitationCtrl.getAccountRoles';
import createRecord from '@salesforce/apex/EF_InvitationCtrl.createInvite';
import getService from '@salesforce/apex/EF_InvitationCtrl.getService';
import getUser from '@salesforce/apex/CSP_Utils.getLoggedUser';

import EMAIL_FIELD from '@salesforce/schema/Invitation__c.Email__c';
import ACCOUNTROLEID_FIELD from '@salesforce/schema/Invitation__c.AccountRoleId__c';
import ACCOUNTID_FIELD from '@salesforce/schema/Invitation__c.AccountId__c';
import ROLE_FIELD from '@salesforce/schema/Invitation__c.Role__c';
import SERVICEID_FIELD from '@salesforce/schema/Invitation__c.ServiceId__c';

import Email from '@salesforce/label/c.Email';
import Account from '@salesforce/label/c.EF_Account';
import Role from '@salesforce/label/c.ICCS_Role_Label';
import Cancel from '@salesforce/label/c.Cancel';
import Invite from '@salesforce/label/c.EF_Invite';
import Select from '@salesforce/label/c.EF_Select';

import Success from '@salesforce/label/c.CSP_Success';
import Error from '@salesforce/label/c.ISSP_Error';
import ErrorInvalidEmail from '@salesforce/label/c.LAQ_EmailValidation';
import ErrorSendingEmail from '@salesforce/label/c.Send_FS_Request_Letter_Error';
import ErrorBlankFields from '@salesforce/label/c.ICCS_Mandatory_Fields';
import InvitationEmailSent from '@salesforce/label/c.EF_Invitation_Sent';

export default class EF_Invitation extends LightningElement {

	label = {
		Email,
		Account,
		Role,
		Cancel,
		Invite,
		InvitationEmailSent,
		ErrorSendingEmail,
		ErrorBlankFields,
		ErrorInvalidEmail,
		Success,
		Error,
		SelectAccount: Select.replace('{0}', Account),
		SelectRole: Select.replace('{0}', Role)
	};

	@track roles = [
		{label: "Service Admin", value:"Service Admin"},
		{label: "Standard User", value:"Standard User"}
	];

	@track accountRoles;
	@track isCommunity = false;

	@track accountId;

	@track email;
	@track accountRoleId;
	@api serviceId;

	connectedCallback() {
		getUser().then(user => {
			let u = JSON.parse(JSON.stringify(user));
			if(u.ContactId){
				this.isCommunity = true;
			}else{
				loadStyle(this, customStyle);
			}
			return getAccountRoles({contactId: u.ContactId });
		}).then(data => {
			let accountsList = [];
			Object.entries(data).forEach(([key, value]) => {
				accountsList.push({
					label: key,
					value: value
				});
			});
			this.accountRoles = accountsList;
		});

		getService().then(service => {
			this.serviceId = service.Id;
		});
	}

	handleEmail(event) {
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
		}
	}

	cancel() {
		this.dispatchEvent(new CustomEvent('cancel'));
	}

	validateEmail(event) {
		let input = this.template.querySelector('.textInput');
		const RegistrationUtilsJs = new RegistrationUtils();
		RegistrationUtilsJs.checkEmailIsValid(`${input.value}`).then(
			resolve => {
				if(!resolve) {
					input.setCustomValidity(this.label.ErrorInvalidEmail);
				} else {
					input.setCustomValidity("");
				}
				input.reportValidity();
			}
		);
	}

	createInvite() {
		let inputs = [...this.template.querySelectorAll('lightning-combobox')];
		inputs.push(this.template.querySelector('.textInput'));
		let allValid = inputs.reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		
		if(allValid) {
			let fields = {};
			fields[EMAIL_FIELD.fieldApiName] = this.email;
			fields[ACCOUNTROLEID_FIELD.fieldApiName] = this.accountRoleId;
			fields[ROLE_FIELD.fieldApiName] = this.roleId;
			fields[ACCOUNTID_FIELD.fieldApiName] = this.accountId;
			fields[SERVICEID_FIELD.fieldApiName] = this.serviceId;

			createRecord({ fields })
			.then(
				this.dispatchEvent(
					new ShowToastEvent({
						title: this.label.Success,
						message: this.label.InvitationEmailSent,
						variant: 'success'
					})
				)
			).catch(error => {
				console.error(`error: ${error.body.message}`);
				this.dispatchEvent(
					new ShowToastEvent({
						title: this.label.Error,
						message: this.label.ErrorSendingEmail,
						variant: 'error'
					})
				)}
			);
		} else {
			this.dispatchEvent(
				new ShowToastEvent({
					title: this.label.error,
					message: this.label.ErrorBlankFields,
					variant: 'error'
				})
			)
		}
	};
}
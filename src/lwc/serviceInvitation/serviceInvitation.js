import { LightningElement, track, wire } from 'lwc';

import email from '@salesforce/label/c.Email';
import selectedRole from '@salesforce/label/c.Selected_Role';
import status from '@salesforce/label/c.Status';
import role from '@salesforce/label/c.Role';
import cancel from '@salesforce/label/c.Button_Cancel';
import invite from '@salesforce/label/c.Invite';

//import user id
import userId from '@salesforce/user/Id';
import isServiceAdministrator from '@salesforce/apex/InvitationService.isServiceAdministrator';


export default class ServiceInvitation extends LightningElement {
    label = {
        email,
        selectedRole,
        status,
        role,
        cancel,
        invite
	};

    paramKey = 'serviceId';
    serviceId = this.getUrlParamValue(window.location.href, this.paramKey);

    @track invitationInfo = {};
    
    @wire(isServiceAdministrator, { userId : '$userId' })
    listUserServices;

    connectedCallback(){
        console.log('Param service id: ' + JSON.stringify(this.serviceId));
    }

    get roleOptions(){
        return [
            {label:'Test 1', value:'Test 1'},
            {label:'Test 2', value:'Test 2'},
            {label:'Test 3', value:'Test 3'},
            {label:'Test 4', value:'Test 4'},
            {label:'Test 5', value:'Test 5'},
            {label:'Test 6', value:'Test 6'}
        ];
    }

    get areInvitationListed(){
        return true; //this.invitationListed.length !== 0;
    }

    get isServiceAdmin(){
        return true; //listUserServices.filter(service => service.Id === serviceId)[0].isAdmin;
    }

    get invitationListed(){
        return [
            {id:'invite1', email:'test@email.com', role: 'Admin', status: 'Active', isActive: true},
            {id:'invite2', email:'test@email.com', role: 'Admin', status: 'Active', isActive: true},
            {id:'invite3', email:'test@email.com', role: 'Admin', status: 'Active', isActive: true},
            {id:'invite4', email:'test@email.com', role: 'Admin', status: 'Active', isActive: true},
            {id:'invite5', email:'test@email.com', role: 'Admin', status: 'Active', isActive: true},
            {id:'invite6', email:'test@email.com', role: 'Admin', status: 'Active', isActive: true},
            {id:'invite7', email:'test@email.com', role: 'Admin', status: 'Active', isActive: false},
            {id:'invite8', email:'test@email.com', role: 'Admin', status: 'Active', isActive: false}
        ];
    }

    updateField(event){
        const fieldName = event.target.dataset.field;
        const value = event.target.value;
        if(fieldName === 'email')
            if(!this.validateEmail(value)){
                return;
            }
        this.invitationInfo[fieldName] = value;
        console.log('Invitation info: ' + JSON.stringify(this.invitationInfo));
    }

    inviteUser(){
        console.log('Sending invitation to user');
    }
    
    cancelInvitation(event){
        console.log('Canceling invitation ' + event.target.dataset.id);
    }


    //Private methods
    validateEmail(email){
        return /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/.test(email);
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
}
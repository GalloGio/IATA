import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import email from '@salesforce/label/c.Email';
import selectedRole from '@salesforce/label/c.Selected_Role';
import status from '@salesforce/label/c.Status';
import role from '@salesforce/label/c.Role';
import cancel from '@salesforce/label/c.Button_Cancel';
import invite from '@salesforce/label/c.Invite';
import pageNumbering from '@salesforce/label/c.Page_Numbering';
import emailFormatErr from '@salesforce/label/c.Email_Wrong_Format';
import reInvite from '@salesforce/label/c.Re_Invite';

//import user id
import userId from '@salesforce/user/Id';
import isServiceAdministrator from '@salesforce/apex/InvitationService.isServiceAdministrator'; // Params: Id portalApplicationId, List<Id> userIdList - Return: Map<Id,Boolean>
import getRoles from '@salesforce/apex/InvitationService.getRoles'; // Param: Id portalApplicationId - Return: List<String>
import getInvitationList from '@salesforce/apex/InvitationService.getInvitationList'; // Param: Id portalApplicationId, List<Id> userIdList - Return: List<EncodedInvitation>
import inviteUsers from '@salesforce/apex/InvitationService.inviteUsers'; // Param: List<EncodedInvitation> encodedInvitationList - Return: void
import cancelInvitation from '@salesforce/apex/InvitationService.inviteUsers'; // Param: List<Invitation__c> - Return: void

const activeLbl = 'Active';
const cancelledLbl = 'Cancelled';

export default class ServiceInvitation extends LightningElement {
    label = {
        email,
        selectedRole,
        status,
        role,
        cancel,
        invite,
        pageNumbering,
        emailFormatErr,
        reInvite
	};

    paramKey = 'serviceId';
    portalApplicationId = this.getUrlParamValue(window.location.href, this.paramKey);
    userIdList = [userId];

    pageNo = 1;
    recordsPerPage = 10;
    
    invitationEntireListWired;
    @track invitationEntireList = [];
    roleOptionList = [];

    @wire(getInvitationList, {portalApplicationId : '$portalApplicationId', userIdList: '$userIdList'})
    getInvitationListWire(result) {
        this.invitationEntireListWired = result;
        if (this.invitationEntireListWired && this.invitationEntireListWired.data && this.invitationEntireListWired.data.length !== 0) {
            this.invitationEntireList = [];
            this.invitationEntireListWired.data.forEach(invitation => {
                this.invitationEntireList.push({
                    id: invitation.id,
                    status: invitation.status,
                    email: invitation.emailAddress,
                    role: invitation.userRole,
                    isActive: invitation.status == activeLbl,
                    isCancelled: invitation.status == cancelledLbl
                });
            });

            this.sortInvitations();
        }
	}

    @track invitationInfo = {};
    
    @wire(getRoles, { portalApplicationId : '$portalApplicationId' })
    getRolesWired({data, error}){
        if(data && data.length !== 0){
            this.roleOptionList = [];
            data.forEach(element => {
                this.roleOptionList.push({ label: element, value: element });
            });
            this.invitationInfo['role'] = this.roleOptionList[0].value;
        }
    }

    @wire(isServiceAdministrator, { portalApplicationId : '$portalApplicationId', userIdList : '$userIdList' })
    isServiceAdministratorWired({data, error}){

    }

    get roleOptions(){
        return this.roleOptionList;
    }

    get areInvitationListed(){
        return this.invitationsToDisplay.length !== 0;
    }

    get isServiceAdmin(){
        return true; //this.listUserServices.filter(service => service.Id === serviceId)[0].isAdmin;
    }

    get totalPages(){
        return Math.ceil(this.invitationEntireList.length/this.recordsPerPage);
    }

    get invitationsToDisplay(){
        var begin = (this.pageNo - 1) * parseInt(this.recordsPerPage);
        var end = parseInt(begin) + parseInt(this.recordsPerPage);
        return this.invitationEntireList.slice(begin, end);
    }

    get pageNumberLbl(){
        return this.label.pageNumbering.replace('{0}', this.pageNo).replace('{1}', this.totalPages);
    }

    get isFirstPage(){
        return this.pageNo === 1;
    }

    get hasMorePages(){
        return this.pageNo < this.totalPages;
    }

    // Action functions
    updateField(event){
        var element = event.target;
        const fieldName = element.dataset.field;
        const value = element.value;
        if(fieldName === 'email'){
            if(!this.validateEmail(value)){
                this.invitationInfo[fieldName] = null;
                return;
            }
        } else {
            console.log('Selectable options ' + JSON.stringify(this.roleOptionList));
        }
        this.invitationInfo[fieldName] = value;
        console.log('Invitation info: ' + JSON.stringify(this.invitationInfo));
    }

    inviteUser(){
        if(this.invitationInfo.email == undefined || this.invitationInfo.email === ''){
            let target = this.template.querySelector('[data-field="email"]');
            target.setCustomValidity(this.label.emailFormatErr);
            target.reportValidity();
        }else{
            this.sendInvitation(this.invitationInfo.email, this.invitationInfo.role);
            this.cleanInformationUp();
        }
    }

    resendInvitation(event){
        let invitationId = event.target.dataset.id;
        console.log('Canceling invitation ' + invitationId);
        let invitationToResend = this.invitationsToDisplay.filter(inv => {
            return inv.id == invitationId;
        });
        console.log('Invitation ' + JSON.stringify(invitationToResend));
        this.sendInvitation(invitationToResend[0].email, invitationToResend[0].role);
    }
    
    cancelInvitation(event){
        console.log('Canceling invitation ' + event.target.dataset.id);
    }

    handleNext(){
       this.pageNo += 1;
    }

    handlePrevious(){
        this.pageNo -= 1;
    }

    handleFirst(){
        this.pageNo = 1;
    }

    handleLast(){
        this.pageNo = this.totalPages;
    }

    //Private functions
    validateEmail(email){
        return /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/.test(email);
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    sortInvitations(){
        this.invitationEntireList.sort(function(invitationA, invitationB) {
            if(invitationA.status === invitationB.status){
                return 0;
            }
            else if ((invitationA.status === activeLbl || (invitationA.status === cancelledLbl && invitationB.status !== activeLbl))){
              return -1;
            }
            return 1;
        });
    }

    cleanInformationUp(){
        this.invitationInfo.email = null;
        this.invitationInfo.role = this.roleOptionList[0].value;

        let emailTarget = this.template.querySelector('[data-field="email"]');
        emailTarget.value = null;

        let roleTarget = this.template.querySelector('[data-field="role"]');
        roleTarget.selectedIndex = 0;
    }

    sendInvitation(email, role){
        var invitationList = [];
        invitationList.push({
            emailAddress: email,
            portalApplicationId: this.portalApplicationId,
            userRole: role,
            status: activeLbl
        });
        console.log('INvitations sent ' + JSON.stringify(invitationList));
        inviteUsers({encodedInvitationList: invitationList}).then(data => {
            console.log('Invitation sent to ' + email + ' with role ' + role);
            refreshApex(this.invitationEntireListWired);
        });

    }
}
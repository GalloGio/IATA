import { LightningElement, track, wire } from 'lwc';

import email from '@salesforce/label/c.Email';
import selectedRole from '@salesforce/label/c.Selected_Role';
import status from '@salesforce/label/c.Status';
import role from '@salesforce/label/c.Role';
import cancel from '@salesforce/label/c.Button_Cancel';
import invite from '@salesforce/label/c.Invite';
import pageNumbering from '@salesforce/label/c.Page_Numbering';

//import user id
import userId from '@salesforce/user/Id';
// import isServiceAdministrator from '@salesforce/apex/InvitationService.isServiceAdministrator';
// import getRoles from '@salesforce/apex/InvitationService.getRoles';
// import getInvitationList from '@salesforce/apex/InvitationService.getInvitationList';


export default class ServiceInvitation extends LightningElement {
    label = {
        email,
        selectedRole,
        status,
        role,
        cancel,
        invite,
        pageNumbering
	};

    paramKey = 'serviceId';
    serviceId = this.getUrlParamValue(window.location.href, this.paramKey);

    pageNo = 1;
    recordsPerPage = 10;
    
    // @wire(getInvitationList, { serviceId : '$serviceId' })
    invitationEntireList = [
        {id:'invite1', email:'test1@email.com', role: 'Admin', status: 'Active', isActive: true},
        {id:'invite2', email:'test2@email.com', role: 'Admin', status: 'Active', isActive: true},
        {id:'invite3', email:'test3@email.com', role: 'Admin', status: 'Active', isActive: true},
        {id:'invite4', email:'test4@email.com', role: 'Admin', status: 'Active', isActive: true},
        {id:'invite5', email:'test5@email.com', role: 'Admin', status: 'Active', isActive: true},
        {id:'invite6', email:'test6@email.com', role: 'Admin', status: 'Active', isActive: true},
        {id:'invite7', email:'test7@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite8', email:'test8@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite9', email:'test9@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite10', email:'test10@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite11', email:'test11@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite12', email:'test12@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite13', email:'test13@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite14', email:'test14@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite15', email:'test15@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite16', email:'test16@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite17', email:'test17@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite18', email:'test18@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite19', email:'test19@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite20', email:'test20@email.com', role: 'Admin', status: 'Active', isActive: false},
        {id:'invite21', email:'test21@email.com', role: 'Admin', status: 'Active', isActive: false}
    ]

    @track invitationInfo = {};
    
    // @wire(getRoles, { functionalRole : '$' })
    // roleOptionList;

    // @wire(isServiceAdministrator, { userId : '$userId' })
    // listUserServices;

    get roleOptions(){
        // var options = [];
        // roleOptionList.forEach(element => {
        //     options.push({label:element, value:element});
        // });
        // return options;
        return  [
            {label:'Test 1', value:'Test 1'},
            {label:'Test 2', value:'Test 2'},
            {label:'Test 3', value:'Test 3'},
            {label:'Test 4', value:'Test 4'},
            {label:'Test 5', value:'Test 5'},
            {label:'Test 6', value:'Test 6'}
        ];
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
}
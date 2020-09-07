import { LightningElement, wire, api, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ACCOUNT_CONTACT_ROLE_OBJECT from '@salesforce/schema/Account_Contact_Role__c';
import CONTACT_FIELD from '@salesforce/schema/Account_Contact_Role__c.Contact__c';
import getAllAccountContactRoles from "@salesforce/apex/CW_StationManagers.getAllAccountContactRoles";
import deleteAccountContactRole from "@salesforce/apex/CW_StationManagers.deleteAccountContactRole";
import getContactsToAdd from "@salesforce/apex/CW_StationManagers.getContactsToAdd";
import becomeFacilityAdmin from '@salesforce/apex/CW_Utilities.becomeFacilityAdmin';
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";

import {
    checkIconType
} from 'c/cwUtilities';

export default class CwStationManagers extends LightningElement {

    plusIcon = ICG_RESOURCES + "/icons/icon-plus.svg";
    minusIcon = ICG_RESOURCES + "/icons/icon-minus.svg";
    checkedIcon = ICG_RESOURCES + "/icons/ic-tic-green.svg";
    uncheckedIcon = ICG_RESOURCES + "/icons/ic-tic-closed.svg";

    @track accountContactRoleObject = ACCOUNT_CONTACT_ROLE_OBJECT;
    @track accountContactRoleFields = [CONTACT_FIELD];

    @api title;
    @api label;
    @api editMode = false;
    @track accountContactRoles;
    @track seeMoreLabel = '';
    totalAccountContactRoles = [];
    itemsByPage = 3;
    initialized = false;
    listennerAdded= false;
    @api userRole;
    @api userInfo;
    @track error;
    @track key;
    @track keyacr;
    @track predictiveValues = [];
    @track isboxfocus;
    @track searchValue = "";
    @track searchValueId;

    @track openCreateAccountContactRole = false;
    @track openConfirm = false;
    @track openCreateContactRoleDetail = false;
    @track showStationManagers = false;
    availableContacts = [];
    @track isLoading = true;

    _facility = null;

    @api
    get facility(){
        return this._facility;
    }

    set facility(value) {
        this._facility = value;
        this.init();
    }

    renderedCallback() {
        if (this.initialized) {
            return;
        }
        this.init();
        this.initialized = true;
    }

    init() {    
        this.getAllAccountContactRolesJS(this.facility.Id);
        this.getContactsToAddJS(this.facility.Id);
        this.showStationManagers = true;
        this.openCreateAccountContactRole = false;
        this.openCreateContactRoleDetail = false;
        this.isboxfocus = false;
        this.openConfirm = false;
    }

    getContactsToAddJS(facilityId) {
        this.isLoading = true;
        this.availableContacts = [];
        getContactsToAdd({ stationId: facilityId }).then(data => {
            if(data){
                data = JSON.parse(data); 
                data.forEach(contactAux =>{

                this.availableContacts.push({
                    key: contactAux.Id,
                    value: contactAux.Id,
                    label: contactAux.Name,
                    icon: checkIconType('person')
                    });
                });
            }
            this.isLoading = false;
            
        }).catch(err => {
            console.error('Error getting contacts to add', err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting contacts to add',
                    message: err.body ? err.body.message : 'The contacts could not be retrieved successfully',
                    variant: 'error'
                })
            );
            this.isLoading = false;
        });
    }

    getAllAccountContactRolesJS(facId) {
        this.isLoading = true;
        getAllAccountContactRoles({ accountRoleDetailId: facId }).then(data => {
            this.accountContactRoles = [];
            this.totalAccountContactRoles = [];
            data = JSON.parse(data);
            data.forEach(contactRoleDetail =>{
                let nameAux = contactRoleDetail.Account_Contact_Role__r.Contact__r.Name ? contactRoleDetail.Account_Contact_Role__r.Contact__r.Name : 'N/A';
                let phoneAux = contactRoleDetail.Account_Contact_Role__r.Contact__r.Phone ? contactRoleDetail.Account_Contact_Role__r.Contact__r.Phone : 'N/A';
                let phoneLinkAux = contactRoleDetail.Account_Contact_Role__r.Contact__r.Phone ? "tel:" + contactRoleDetail.Account_Contact_Role__r.Contact__r.Phone : '';
                let emailAux = contactRoleDetail.Account_Contact_Role__r.Contact__r.Email ? contactRoleDetail.Account_Contact_Role__r.Contact__r.Email : 'N/A';
                let emailLinkAux = contactRoleDetail.Account_Contact_Role__r.Contact__r.Email ? "mailto:" + contactRoleDetail.Account_Contact_Role__r.Contact__r.Email : '';
                let addressAux = 'N/A';
                if (contactRoleDetail.Account_Contact_Role__r.Contact__r.OtherState) {
                    addressAux = contactRoleDetail.Account_Contact_Role__r.Contact__r.OtherState;
                    if (contactRoleDetail.Account_Contact_Role__r.Contact__r.OtherCountry) {
                        addressAux = addressAux + ', ' + contactRoleDetail.Account_Contact_Role__r.Contact__r.OtherCountry;
                    }
                } else if (contactRoleDetail.Account_Contact_Role__r.Contact__r.OtherCountry) {
                    addressAux = contactRoleDetail.Account_Contact_Role__r.Contact__r.OtherCountry;
                }
                let accountContactRoleInfo = {
                    id : contactRoleDetail.Id,
                    idAccountContactRole : contactRoleDetail.Account_Contact_Role__r.Id,
                    name : nameAux,
                    phone : phoneAux,
                    phoneLink : phoneLinkAux,
                    email: emailAux,
                    emailLink: emailLinkAux,
                    otherAddress : addressAux,
                    showDelete : this.isCompanyAdmin || this.userInfo.ContactId === contactRoleDetail.Account_Contact_Role__r.Contact__r.Id,
                    contactId: contactRoleDetail.Account_Contact_Role__r.Contact__c, 
                    companyId: contactRoleDetail.Account_Contact_Role__r.Account__c, 
                    facilityId: contactRoleDetail.ICG_Account_Role_Detail__c
                }
                this.totalAccountContactRoles.push(JSON.parse(JSON.stringify(accountContactRoleInfo)));
            });
            
            let counter = 0;
            let listAux = [];
            this.totalAccountContactRoles.forEach(itemAux =>{
                if (counter < this.itemsByPage) {
                    listAux.push(itemAux);
                    counter++;
                }
                
            });
            listAux = JSON.parse(JSON.stringify(listAux));
            this.accountContactRoles = listAux; 
            this.seeMoreLabel = '';
            if (this.totalAccountContactRoles.length) {
                if (this.totalAccountContactRoles.length < this.itemsByPage || this.totalAccountContactRoles.length === this.itemsByPage) {
                    this.seeMoreLabel = this.seeMoreLabel.concat('See more (',0,')');
                } else {
                    this.seeMoreLabel = this.seeMoreLabel.concat('See more (',this.totalAccountContactRoles.length - this.itemsByPage,')');
                }
                
            }
            this.isLoading = false;
        }).catch(err => {
            console.error('Error getting all contacts', err);
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting all contacts',
                    message: err.body ? err.body.message : 'The contacts could not be retrieved successfully',
                    variant: 'error'
                })
            );
        });
    }

    get showShowMoreButton(){
        return this.totalAccountContactRoles && this.totalAccountContactRoles.length && this.totalAccountContactRoles.length - this.itemsByPage > 0;
    }

    deleteAccountContactRoleJS(cRdI, isCompanyAdmin) {
        this.isLoading = true;
        deleteAccountContactRole({ contactRoleDetailId: cRdI, isCompanyAdmin: isCompanyAdmin }).then(data => {
            let msg = '';         
            if(data === 'Removed'){
                msg = 'Station manager has successfully been removed';
            } else if(data === 'Pending for Removal'){
                msg = 'Removal request has been sent to company administrators';
            }
            this.getAllAccountContactRolesJS(this.facility.Id); 
                
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: msg,
                    variant: 'success'
                })
            );
            this.isLoading = false;
        }).catch(err => {
            console.error('Error removing station manager', err);
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error removing station manager',
                    message: err.body ? err.body.message : 'The station manager could not be removed successfully',
                    variant: 'error'
                })
            );
        });
    }

    becomeFacilityAdminJS(event){
        this.becomeFacilityAdminToDB(this.userInfo.AccountId, this.facility.Id, this.userInfo.ContactId);
    }

    checkIfIsDuplicatedStationManager(companyId, facilityIds, contactId){
        let isDuplicate = false;
        this.totalAccountContactRoles.forEach(acr => {
            if(acr.companyId === companyId && acr.facilityId === facilityIds && acr.contactId === contactId){
                isDuplicate = true;
            }
        });

        return isDuplicate;
    }

    becomeFacilityAdminToDB(companyId, facilityIds, contactId){
        this.isLoading = true;
        let isDuplicate = this.checkIfIsDuplicatedStationManager(companyId, facilityIds, contactId);

        let filteredValues = this.availableContacts.filter(entry => {
            return entry.key.toLowerCase() == contactId.toLowerCase()
        });
        let contact; 
        if(filteredValues.length == 1){
           contact = filteredValues[0];
        }
        if(isDuplicate){

            let message;
            if(contact){
                message = contact.label;
            }
            else{
                message = 'The user';
            }

            message +=  ' is already a station manager for this station';

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: message,
                    variant: 'warning'
                })
            );
            this.isLoading = false;
            return;
        }

        becomeFacilityAdmin({companyId: companyId, facilityIds : facilityIds, contactId : contactId, skipApprovalProcess: true}).then(resp => {
            let parsedRes = JSON.parse(resp);
            if(parsedRes.success){
                this.getAllAccountContactRolesJS(facilityIds);

                let message; 
                if(contact){
                    message = 'Successfully added ' + contact.label + ' as station manager';
                }
                else{
                    message = 'Successfully added new station manager';
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: message,
                        variant: 'success'
                    })
                );
                this.showModal = true;

            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: parsedRes.message,
                        variant: 'error'
                    })
                );
            }
            this.isLoading = false;
        }).catch(err => {
            console.error(err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Become Station Manager',
                    message: err.message,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        });
    }
    
    showMore(){
        if (this.accountContactRoles.length < this.totalAccountContactRoles.length) {
            this.accountContactRoles = JSON.parse(JSON.stringify(this.totalAccountContactRoles));
            this.seeMoreLabel = '';
            this.seeMoreLabel = this.seeMoreLabel.concat('See more (',0,')');
        }
    }

    handleAccountContactRoleCreated(){
        this.openCreateAccountContactRole = false;
        this.openConfirm = false;
        this.showStationManagers = true;
    }

    handleCancel(){
        this.openCreateAccountContactRole = false;
        this.openConfirm = false;
        this.showStationManagers = true;
        this.searchValue = '';
        this.searchValueId = '';
    }

    handleConfirmDialogYes(){
        this.openCreateAccountContactRole = false;
        this.openConfirm = false;
        this.showStationManagers = true;
        this.deleteAccountContactRoleJS(this.key,this.isCompanyAdmin);
    }

    deleteAccountContactRole(event) {
        this.openCreateAccountContactRole = false;
        this.openConfirm = true;
        this.showStationManagers = false;
        this.key = event.target.dataset.key;
        this.keyacr = event.target.dataset.keyacr;
    }

    addStationManager(event){
        this.openCreateAccountContactRole = true;
        this.openConfirm = false;
        this.showStationManagers = false;
        this.listennerAdded = false;
    }

    handleAddStationManager(){
        if (this.searchValueId) {
            this.openCreateAccountContactRole = false;
            this.openConfirm = false;
            this.showStationManagers = true;
            let companyId = this.facility.companyId ? this.facility.companyId: this.facility.Account_Role__r.Account__c;
            this.becomeFacilityAdminToDB(companyId, this.facility.Id, this.searchValueId);
            this.searchValue = '';
            this.searchValueId = '';
        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No contact with the specified name',
                    variant: 'error'
                })
            );
        }
    }

    updateSearchbox(event) {
        let searchbox = this.template.querySelector('.searchbox');
        searchbox.value = event.detail.value;
        this.searchValue = event.detail.value;
        this.searchValueId = event.detail.item;
        this.isboxfocus = false;
    }
    
    predictiveSearch(event) {
        if (!this.listennerAdded) {
            this.listennerAdded = true;
            this._addFocusOnSearchListener();
        }
        this.predictiveValues = [];
        this.searchValue = event.target.value;
        if (!event.target.value || event.target.value.length < 3) {
            return;
        }

        let filteredValues = [];
        
        filteredValues = this.availableContacts.filter(entry => {
            return entry.label.toLowerCase().includes(this.searchValue.toLowerCase())
        });

        filteredValues.forEach(element => {
            const alreadyAdded =  this.predictiveValues.some(obj => obj.key === element.key);
            if(!alreadyAdded){
                this.predictiveValues.push({
                    key: element.key,
                    value: element.label,
                    label: element.label,
                    icon: checkIconType('person')
                });
            }
        });
        this.isboxfocus = true;
    }

    _addFocusOnSearchListener() { 
        let box = this.template.querySelector('[data-tosca="locationinput"]');
        if (box) {
            box.addEventListener("focus", (event) => {
                //this.isboxfocus = true;
            });
            box.addEventListener("blur", (event) => {
                this.isboxfocus = false;
            });
        }
    }

    get isCompanyAdmin (){
        return this.userRole === 'Company Admin';
    }

    get isFacilityManager (){
        return this.userRole === "Facility Manager";
    }

    get showBecomeStationManager(){
        this.isCompanyAdmin === false && this.isFacilityManager === false;
    }

    get noAccountContactRoles(){
        return !this.accountContactRoles || this.accountContactRoles.length < 1;
    }

}
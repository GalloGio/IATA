import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/ldsUtils';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';

import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import getRedirectURL from '@salesforce/apex/PortalIftpUtils.getRedirectURL';


export default class portalIftpTabs extends NavigationMixin(LightningElement) {
    @api userInfo;

    @track error;
    @track mainErrorMessage;

    @wire(CurrentPageReference) pageRef;

    /*
        Regular USER:
            contact.User_Portal_Status__c = Approved User

        ADMIN USER:
            contact.User_Portal_Status__c = Approved Admin

        ITP USER:                                       
            User.Profile_Name__c =  ISS Portal (Partner)
                                    ISS Portal
                                    ISS Portal ITP ????
            Account.RecordType.DeveloperName = Others ?

        AIRLINE USER:
            User.Profile_Name__c =  ISS Portal Airline User (Partner)
                                    ISS Portal Airline User
                                    ISS Portal Airline Delegated Admin User 
            Account.RecordType.DeveloperName =  IATA_Airline  
                                                IATA_Airline_BR

    */
    @track isUserAdmin = false;
    @track isITPUser = false;
    @track isAirlineUser = false;


    /**
     * Tabs management
     * defines Tabs to show Accordingly to the User Profile and access 
     */
    @track showManageEmployees			= false;
	@track showManageStations          	= false;
	@track showEmployeeRecordsTransfer 	= false;
	@track showProficiencyManagement   	= false;
	@track showTrainingRecordsDetail   	= false;
	@track showTrainingRecordsSummary  	= false;
	@track showUploadOJT               	= false;
	@track showImportStation           	= false;
    @track showImportEmployees         	= false;
    @track showMonitorTrainings         = false;
    @track showProficiencyReports       = false;
    
    get showLMSButton() { 
        return this.isITPUser || this.isUserAdmin;
    }
    
    connectedCallback() {

        getUserInfo()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            
            this.userInfo = myResult;

            // //Check User Access, for both ITP User and Airline User
            // this.userInfo.accountRoleStatus === 'Active' - Not able to set to Airline users since these don't have acc cont roles
            if( this.userInfo.accountRoleType === 'IFTP' && 
                    this.userInfo.PortalApplication === 'IFTP' && 
                    this.userInfo.PortalApplicationStatus === 'Access Granted' &&
                    this.userInfo.accountRoleSrvName.indexOf('IFTP') !== -1 ){

                        this.setUserAccess(this.userInfo);
                        this.setTabsVisibility(this.userInfo);
            }else{
                this.mainErrorMessage = 'Currently you dont have access to IFTP Portal, please contact the Administrator';
                let err = [];
                err[0] = 'Setup to access:\n- Account role type = IFTP(ITP)\n- Account Role Status = ACtive\n- Portal Service = IFTP\n- Portal Service status = Access Granted';    
                this.error = err;    
            } 
            
        })
        .catch(error => {
            
            let err = reduceErrors(error);
            
            if(err[0] === 'List has no rows for assignment to SObject' ){
                this.mainErrorMessage = 'Currently you dont have access to IFTP Portal, please contact the Administrator';
                this.error = error;
            }else{
                this.mainErrorMessage = error;
                this.error = error;
                fireEvent(this.pageRef, 'errorEvent', error);  
            }
        });
        
        registerListener('errorEvent', this.removeAccessToIFTPIfLoggedOut, this);
    }

    disconnectedCallback() {
		// unsubscribe from bearListUpdate event
		unregisterAllListeners(this);
	}

    /**
     * User management
     * defines user type Accordingly to the User Profile and access 
     */
    setUserAccess(userInfo){

        if(userInfo.UserPortalStatus === 'Approved Admin'){
            this.isUserAdmin = true;
        }

        if(userInfo.profile.includes('ISS Portal Airline') && userInfo.accountRecordType.includes('IATA_Airline')){
        
            this.isAirlineUser = true;
            
        }else if(this.userInfo.profile === 'ISS Portal (Partner)' || userInfo.profile === 'ISS Portal' || userInfo.profile === 'ISS Portal Delegated Admin User'){
        
            this.isITPUser = true;

        }
    }

    /**
     * Tabs management
     * defines Tabs to show Accordingly to the User Profile and access 
     */
    setTabsVisibility(userInfo){

        if(this.isITPUser){
            this.showManageEmployees			= true;
            this.showManageStations          	= true;
            this.showEmployeeRecordsTransfer 	= true;
            this.showProficiencyManagement   	= true;
            this.showUploadOJT               	= true;
            this.showImportStation           	= true;
            this.showImportEmployees         	= true;
            this.showMonitorTrainings           = true;
            this.showProficiencyReports         = true;
            
        }

        if(this.isAirlineUser){
            this.showTrainingRecordsDetail   	= true;
            this.showTrainingRecordsSummary  	= true;
        }
        
    }

    handleRedirect(){
        getRedirectURL()
        .then(result => {
            // Navigate to a URL
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: result
                    }
                },
                true // Replaces the current page in your browser history with the URL
            );

        })
        .catch(error => {
            console.error('handleRedirect - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
            fireEvent(this.pageRef, 'errorEvent', error);  
        });
    }

    removeAccessToIFTPIfLoggedOut(error){
        let error2 =JSON.parse(JSON.stringify(error));
        if (error.body && typeof error.body.message === 'string'){
            let msg = error2.body.message;
            if(msg.includes('logged out')){
                this.showManageEmployees			= false;
                this.showManageStations          	= false;
                this.showEmployeeRecordsTransfer 	= false;
                this.showProficiencyManagement   	= false;
                this.showUploadOJT               	= false;
                this.showImportStation           	= false;
                this.showImportEmployees         	= false;
                this.showMonitorTrainings           = false;
                this.showProficiencyReports         = false;
                
                this.showTrainingRecordsDetail   	= false;
                this.showTrainingRecordsSummary  	= false;

                this.isITPUser = false;
                this.isAirlineUser = false;
                this.mainErrorMessage = 'You have been logged out. Please login again. ';
                this.error = true;
                this.showLMSButton();
            }
        } 
    }

}
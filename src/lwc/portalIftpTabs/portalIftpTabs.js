import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/ldsUtils';

import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import getRedirectURL from '@salesforce/apex/PortalIftpUtils.getRedirectURL';


export default class portalIftpTabs extends NavigationMixin(LightningElement) {
    @api userInfo;

    @track error;
    @track mainErrorMessage;

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
        console.log('INIT connectedCallback');

        getUserInfo()
        .then(result => {
            console.log(result);
            let myResult = JSON.parse(JSON.stringify(result));
            
            this.userInfo = myResult;
            console.log('-- [portalIftpTabs - getUserInfo] this.userInfo - ',  this.userInfo);

            this.setUserAccess(this.userInfo);
            this.setTabsVisibility(this.userInfo);
            
        })
        .catch(error => {
            
            let err = reduceErrors(error);
            
            if(err[0] === 'List has no rows for assignment to SObject' ){
                this.mainErrorMessage = 'Currently you dont have access to IFTP Portal, please contact the Administrator';
                this.error = error;
            }else{
                this.mainErrorMessage = error;
                this.error = error;
            }
        });
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
        });
    }

}
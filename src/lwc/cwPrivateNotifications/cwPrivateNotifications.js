import { LightningElement , track,api,wire } from 'lwc';

import resources from "@salesforce/resourceUrl/ICG_Resources";
import getNotificationsFromUser_ from "@salesforce/apex/CW_NotificationsController.getNotificationsFromUser";
import setDismiss_ from "@salesforce/apex/CW_NotificationsController.setDismissNotifications";
import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";
import { refreshApex } from "@salesforce/apex";
import CHECKED_IMAGE from "@salesforce/resourceUrl/ic_tic_green";
import labels from "c/cwOneSourceLabels";

export default class CwPrivateNotifications extends LightningElement {
    initialized = false;

    icons = resources + "/icons/";
    
    label = labels.labels();

    @track data = [];
    @track dataLimit = [];
    @track showModal = false;
    @track modalMessage = "When you perform an action, this modal appears with extra info.";
    @track modalImage = CHECKED_IMAGE;
	checkedImage = CHECKED_IMAGE;

    @api companyAdmins;
    @api companyInfo;
    @api userInfo;
    @api gxaUrl;

    viewAll = false;
    registerToShow = 5;

    @api viewAlertsEvents;
    
    renderedCallback() {
		if (!this.initialized) {
			if (this.viewAlertsEvents === "true") {
                this.viewAlertsEvents = true;
				this.initialized = true;
				this.getNotificationsFromUser(true);
			}
			else { 
                this.viewAlertsEvents = false;
                this.initialized = true;
                this.getNotificationsFromUser(false);
			}
		}
    }

    closeModal() {
        this.showModal = false;
        //this.dispatchEvent(new CustomEvent("refresh"));
        //this.dispatchEvent(new CustomEvent("gotohome"));
    }
    
    get getViewAll()
    {
        return this.viewAll;
    }

    get dataInformed() {
		return this.data.length > 0 ? true : false;
	}
    
    get numberRegisterToShow(){
        if(this.dataInformed){
            return this.data.length > this.dataLimit.length ?  this.dataLimit.length : this.data.length;
        }
        else{
            return 0;
        }
    }

    get dataSize(){
        return this.dataInformed ? this.data.length : 0;
    }
    

    getNotificationsFromUser(viewAlertsEvents) {
		getNotificationsFromUser_({viewAlertsEvents})
			.then(result => {
                let parseResult = JSON.parse(JSON.stringify(result));
				this.data = JSON.parse(parseResult);
                if(this.data){
                    this.checkRedirectionAndDate();

                    if(this.data.length > 5 && !this.viewAlertsEvents && !this.getViewAll){
                        this.limitData();
                    }
                    else{
                        this.dataLimit = this.data;
                    }
                }           
			})
			.catch(err => {
				this.modalMessage = err.message;
				this.modalImage = "X";
				this.showModal = true;
			});
	}
    
    checkRedirectionAndDate(){
		getUserInfo().then(result => {
			this.userInfo = JSON.parse(result);

			this.data.forEach(elem=>{
				let description = elem.Short_Description__c.toLowerCase();
				if( (elem.Station__c != '' && elem.Station__c != undefined ) || 
					(description.includes('remote') || description.includes('validation')) ||
					description.includes('pending approval') ||
					description.includes('station manager') ||
					description.includes('facility manager') ||
					description.includes('company admin') ||
					description.includes('audit schedule') ){
					elem.isRedirection = true;
					if(description.includes('pending approval') && (elem.Station__c != '' && elem.Station__c != undefined)){
						if (elem.CreatedById === this.userInfo.Id){
							elem.destiny = 'my requests';
						}
						else{
							elem.destiny = 'pending user approval';
						}
					}
					else if(description.includes('pending approval')){
						elem.destiny = 'pending user approval';
					}
					else if(description.includes('audit schedule')){
						elem.destiny = 'audit schedule';
					}
					else if(elem.Station__c != '' && elem.Station__c != undefined){
						elem.destiny = 'station';
					}
					else if(description.includes('station manager') || description.includes('facility manager')){
						elem.destiny = 'station managers';
					}
					else if(description.includes('company admin')){
						elem.destiny = 'company admin';
					}                
					if(description.includes('remote') || description.includes('validation')){
						elem.destiny = 'remote';
					}
				}
				else{
					elem.isRedirection = false;
				}

				//parse Dates
				let parseDate = new Date(elem.CreatedDate);
				let endDate = parseDate.getDate() + '/' + (parseDate.getMonth()+1) + '/' + parseDate.getFullYear();
				elem.CreatedDate = endDate;

			});
		});
    }

    handleNavigate(event){
        let destiny = event.currentTarget.getAttribute("data-destiny").toLowerCase();
        let url='';
        if(destiny === 'station'){
            url = '#ID:' + event.currentTarget.getAttribute("data-id");
            window.open(url, "_blank");
        }
        else if(destiny === 'pending station approval'){
            url = '#Pending Facility Approvals';
            window.open(url, "_blank");
        }
        else if(destiny === 'pending user approval'){
            url = '#Pending User Approvals';
            window.open(url, "_blank");
        }
        else if(destiny === 'station managers'){
            url = '#Station Managers';
            window.open(url, "_blank");
        } 
        else if(destiny === 'company admin'){
            url = '#Company Admins';
            window.open(url, "_blank");
        }
        else if(destiny === 'audit schedule'){
            url = '#Schedule Audits';
            window.open(url, "_blank");
        }  
        else if(destiny === 'my requests'){
            url = '#My Requests';
            window.open(url, "_blank");
        }  
        else if(destiny === 'remote'){
            let description = event.currentTarget.getAttribute("data-description").toLowerCase();
            //redirection depend to the action...
            if(description.includes('granted') || description.includes('approved') || description.includes('accepted')){
                url = '#ID:' + event.currentTarget.getAttribute("data-id");
                window.open(url, "_blank");
            }
            else if(description.includes('expired') || description.includes('rejected')){
                url = '#Remote Validation History';
                window.open(url, "_blank");
            }
            else{
                url = this.gxaUrl;
                window.open(url, "_blank");
            }
        }

        if(event.currentTarget.getAttribute("data-read") === 'false'){
            this.setDismissSelected(event);
        }
        
    }

    limitData()
    {
        let getLimit=[];
        for(let i=0;i<this.registerToShow;i++){
            getLimit.push(this.data[i]);
        }
        this.dataLimit = getLimit;
        
    }

    setDismiss(notificationList,mode) {
		setDismiss_({notificationList})
			.then(result => {
                let parsedRes = JSON.parse(result);
				if (parsedRes.success) {
                    if(mode === 'all'){
                        this.modalMessage = "Operation successfull.";
                        this.showModal = true; 
                    }
                    
                    this.getNotificationsFromUser(this.viewAlertsEvents);
				} else {
					this.modalMessage = parsedRes.message;
                    this.modalImage = "X";
                    this.showModal = true; 
                }
                
			})
			.catch(err => {
				this.modalMessage = err.message;
				this.modalImage = "X";
				this.showModal = true;
			});
	}


    setDismissSelected(event){
        let notificationId = event.target.dataset.key;
        let position = event.target.dataset.position;

        this.dataLimit[position].Read__c = true;
        this.data.forEach(elemen => {
            if(elemen.Id === notificationId){
                elemen.Read__c = true;
            }
        });

        let notificationList = [];
        notificationList.push(notificationId);

        this.setDismiss(notificationList, 'selected');

    }

    setDismissAll(event){
        let notificationList = [];
        this.data.forEach(function(row){
            notificationList.push(row.Id);
        });

        this.setDismiss(notificationList,'all');
    }

    setViewAll(event){
        let view = event.target.dataset.view;
        if(view === 'false'){
            this.limitData();
            this.viewAll = false;
        }
        else{
            this.dataLimit = this.data;
            this.viewAll = true;
        }
    }

}
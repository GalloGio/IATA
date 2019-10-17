import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//FROM APEX CUSTOM CLASSES
import getGeneralPublicUsers from '@salesforce/apex/UserController.getGeneralPublicUsersByCategoryAndSector';
import getTotalGeneralPublicUsers from '@salesforce/apex/UserController.getTotalGeneralPublicUsersByCategoryAndSector';
import getItemsPerPage from '@salesforce/apex/UserController.getItemsPerPage'; 
import singleNotification from '@salesforce/apex/RegistrationComunicationsController.sendSingleLevel2RegistrationAlert'
import batchNotification from '@salesforce/apex/RegistrationComunicationsController.sendBatchLevel2RegistrationAlert';
import notifyAll from '@salesforce/apex/RegistrationComunicationsController.sendLevel2RegistrationAlertToAll';
import getSiteCompleteUrl from '@salesforce/apex/OneIdUtils.getSiteCompleteUrl';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Contact', fieldName: 'Link', type: 'url', typeAttributes: { label : { fieldName: 'ContactName' }, target: '_blank' }},
    { label: 'Sector', fieldName: 'Sector', type: 'text' },
    { label: 'Category', fieldName: 'Category', type: 'text' },    
    { label: 'Country', fieldName: 'Country', type: 'text'},
    { label: 'Preferred Language', fieldName: 'PreferredLanguage', type: 'text' },
    { label: 'Last Contacted', fieldName: 'LastContacted', type: 'date' },
    { label: 'Actions', type: 'button', initialWidth: 130, typeAttributes: {name: 'notify', label: 'Notify', title: 'Notify', variant: 'info' }},
    //{ label: 'Show', type: 'button', initialWidth: 130, typeAttributes: {name: 'show', label: 'show', title: 'show', variant: 'success' }},
];

const ERROR = 'error';
const SUCCESS = 'success';
const GENERA_ERROR_MESSAGE = 'Some error ocurred while getting the list of users';

export default class UnregisteredUsers extends LightningElement {
    //Table data
    @track data = [];
    @track columns = columns;
    @track orgUrl = '';

    //Table control variables
    @track ITEMS_PER_PAGE = 50; //Althougth this value is being fetched from APEX in connectedCallback it is better to initialize it as the correct value
    @track totalRecords;
    @track currentPageRecords = [];
    @track auxiliarSelected = [];
    @track selectedRows = [];
    @track page = 1;
    @track previousPage = 1;
    @track maxpage = 1;    

    //Table filters
    @track category = '';
    @track sector = ''; 
    @track country = '';   
    @track preferredLanguage = '';
    
    
    //@track isFirstPage = true;
    //@track isLastPage = false;
    //@track offset = 0;

    async connectedCallback(){
        try{
            this.ITEMS_PER_PAGE = await getItemsPerPage();
            this.orgUrl = await getSiteCompleteUrl();
        }catch(e){
            this.showToast(ERROR,'Error',GENERA_ERROR_MESSAGE);
        }
    }

    @wire(getTotalGeneralPublicUsers,{category: '$category',sector: '$sector',country: '$country',preferredLanguage:'$preferredLanguage'})
    wiredTotalRecors({error,data}){
        if (data) {            
            this.totalRecords = data;
            this.maxPage = Math.ceil(data/this.ITEMS_PER_PAGE);
        } else if (error) {           
            this.showToast(ERROR,'Error',GENERA_ERROR_MESSAGE);
        }
    }

    @wire(getGeneralPublicUsers,{category: '$category',sector: '$sector',country: '$country',preferredLanguage:'$preferredLanguage',page:'$page'})
    wiredUsers({ error, data }) {         
        let currentPageIds = [];
        if (data) {     
            data = JSON.parse(JSON.stringify(data));   
            data.forEach(row => {                
                row.ContactName = row.Contact.Name;
                row.PreferredLanguage = row.Contact.Preferred_Language__c;
                row.Sector = row.Contact.Account.Sector__c; 
                row.Category = row.Contact.Account.Category__c;      
                row.Country = row.Contact.Account.IATA_ISO_Country__r.Name;
                row.LastContacted = row.Contact.Last_registration_notification_date__c;
                row.Link = this.orgUrl + '/' + row.ContactId;
                currentPageIds.push(row.ContactId);
            });
            this.data = data;
            this.selectedRows = this.auxiliarSelected;
            this.currentPageRecords = currentPageIds;
            if (data.length < 1) {
                this.showToast(ERROR,'Error','There are no users to be displayed');

            }
        } else if (error) {              
            this.page = this.previousPage;          
            this.showToast(ERROR,'Error',GENERA_ERROR_MESSAGE);
        }
    }

    handleSubmitAccountFilters(event){
        // stop the form from submitting
        event.preventDefault(); 
        /*
        //reset navigatiton
        this.page = 1;
        this.previousPage = 1;

        if(this.category !== event.detail.fields.Category__c || this.sector !== event.detail.fields.Sector__c){
            this.category = event.detail.fields.Category__c;
            this.sector = event.detail.fields.Sector__c;
        } else {            
            this.showToast(ERROR,'Error','No filter was changed');
        }   */
    }

    handleSubmitContactFilters(event){
        // stop the form from submitting
        event.preventDefault(); 
    }

    handleFilterTable(event){
        //reset navigatiton
        this.page = 1;
        this.previousPage = 1;

        let sector =  this.template.querySelector("[data-filter='sector']").value;
        let category =  this.template.querySelector("[data-filter='category']").value;
        let country =  this.template.querySelector("[data-filter='country']").value;
        let preferredLanguage =  this.template.querySelector("[data-filter='language']").value;

        if(this.category !== category || this.sector !== sector || this.country !== country || this.preferredLanguage !== preferredLanguage){
            this.category = category;
            this.sector = sector;
            this.country = country;
            this.preferredLanguage = preferredLanguage;
        } else {            
            this.showToast(ERROR,'Error','No filter was changed');
        }

    }

    handleNavigation(event){        
        this.auxiliarSelected = this.selectedRows;
        this.selectedRows = [];        

        if(event.target.label === 'Next'){
            if(! this.isLastPage){
                this.previousPage = this.page;
                this.page += 1;    
            }else{
                this.showToast(ERROR,'Error','There are no Next Page');                
            }
        } else if (event.target.label === 'Previous'){
            if(! this.isFirstPage){
                this.previousPage = this.page;
                this.page -= 1;   
            }else{
                this.showToast(ERROR,'Error','No are no Previous Page');
            }
        }        
    }

    handleRowSelection(event){    

        let aux = this.selectedRows;        
        let selected = event.detail.selectedRows;
        
        //remove all records belonging to current page
        aux = aux.filter(elem => {            
            return !this.currentPageRecords.includes(elem);
        });       
        
        //add the ones from current page that are selected
        selected.forEach( elem => {
            if(!aux.includes(elem.ContactId)){
                aux.push(elem.ContactId);
            }
        });        

        this.selectedRows = aux;
    }

    async handleNotifySelected(){  
        
        if(this.selectedRows.length < 1){
            this.showToast(ERROR,'Error!',"There are no selected rows!");
            return; 
        }
        try{
            let result = await batchNotification({contactIds : this.selectedRows});

            if(result.notification !== undefined){
                if(result.notification === 'all'){
                    this.showToast(SUCCESS,'Notification success!',"All notifications were sent!"); 
                }else if(result.notification === 'none'){
                    this.showToast(ERROR,'Notification error!',"All notifications failed!"); 
                }else{
                    this.showToast(ERROR,'Notification error!',"Some notifications failed!"); 
                }
            } 
            
            if(result.email !== undefined){
                if(result.email === 'all'){
                    this.showToast(SUCCESS,'Email success!',"All emails were sent!"); 
                }else if(result.email === 'none'){
                    this.showToast(ERROR,'Email error!',"All emails failed!"); 
                }else{
                    this.showToast(ERROR,'Email error!',"Some emails failed!"); 
                }
            } 
        }catch(error){
            this.showToast(ERROR,'Error','Error creating notifications and emails');
        }
        
        this.selectedRows = [];
    }

    async handleNotifyAll(){
        if(this.currentPageRecords.length  < 1){
            this.showToast(ERROR,'Error!',"There are no one to contact!");
            return; 
        }
        try{
            let result = await notifyAll();
            if(result.notification !== undefined){
                if(result.notification === 'all'){
                    this.showToast(SUCCESS,'Notification success!',"All notifications were sent!"); 
                }else if(result.notification === 'none'){
                    this.showToast(ERROR,'Notification error!',"All notifications failed!"); 
                }else{
                    this.showToast(ERROR,'Notification error!',"Some notifications failed!"); 
                }
            } 
            
            if(result.email !== undefined){
                if(result.email === 'all'){
                    this.showToast(SUCCESS,'Email success!',"All emails were sent!"); 
                }else if(result.email === 'none'){
                    this.showToast(ERROR,'Email error!',"All emails failed!"); 
                }{
                    this.showToast(ERROR,'Email error!',"Some emails failed!"); 
                }
            } 

        }catch(error){
            this.showToast(ERROR,'Error','Error creating notifications');
        }
    }

    async handleRowAction(event){
        const row = event.detail.row;

        //const actionName = event.detail.action.name;
        //if (actionName === 'show'){
        //    alert(JSON.parse(JSON.stringify(row.ContactId)));
        //}else{
            try{
                let result = await singleNotification({contactId: row.ContactId});

                if(result.notification !== undefined && result.email !== undefined){

                    if(result.notification){
                        this.showToast(SUCCESS,'Notification success!',"A notification was sent to " + row.ContactName + "!"); 
                    }else{
                        this.showToast(ERROR,'Notification error!',"The notification failed to be sent!"); 
                    }
    
                    if(result.email){
                        this.showToast(SUCCESS,'Email success!',"An email was sent to " + row.ContactName + "!"); 
                    }else{
                        this.showToast(ERROR,'Email error!',"The email failed to be sent!"); 
                    }
                } else {
                    this.showToast(ERROR,'Error','The notification and email have failed to be sent!');
                }
    
            }catch(error){
                this.showToast(ERROR,'Error','Error creating notifications');
            }
        //}
    }

    get isFirstPage(){
        return  this.page === 1;
    }

    get isLastPage(){
        return this.page === this.maxPage;
    }

    get offset(){
        return (this.page - 1) * this.ITEMS_PER_PAGE;
    }

    showToast(variant, title, message){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    
}
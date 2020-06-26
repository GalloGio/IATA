import { LightningElement, api, track } from 'lwc';
import becomeCompanyAdmin   from '@salesforce/apex/CW_Utilities.becomeCompanyAdmin';
import resources from '@salesforce/resourceUrl/ICG_Resources';

export default class CwBecomeCompanyAdminContainer extends LightningElement {
    @api
    userInfo;
    @api label;
    @track requesting;
    @track showModal = false;
    @track modalMessage = 'When you perform an action, this modal appears with extra info.';
    CHECKED_IMAGE = resources +'/icons/ic-tic-green.svg';
    ERROR_IMAGE = resources +'/icons/error-icon.svg';
    @track modalImage = this.CHECKED_IMAGE;
    @api facilities;


    becomeCompanyAdminJS(event){
        this.requesting=true;
        becomeCompanyAdmin({groupName: event.currentTarget.dataset.group, companyId : this.userInfo.AccountId, contactId : this.userInfo.ContactId}).then(resp => {
            let parsedRes = JSON.parse(resp);
            if(parsedRes.success){
                this.modalImage = this.CHECKED_IMAGE;
                this.modalMessage = 'Your request has been submitted and is pending approval from your Company Admin / IATA.<br/><br/>You will receive a confirmation once your request has been processed.';
                this.dispatchEvent( new CustomEvent('refresh'));
            }else{
                this.modalMessage = parsedRes.message;
                this.modalImage = this.ERROR_IMAGE;
            }
            this.requesting = false;
            this.showModal = true;
        }).catch(err => {
            console.log(err);
            this.modalMessage = err.body.pageErrors[0].message;
            this.modalImage = this.ERROR_IMAGE;
            this.requesting = false;
            this.showModal = true;
        });

    }
    closeModal(){
        this.showModal = false;
    }
}
import { LightningElement, api,track } from 'lwc';
import becomeFacilityAdmin from '@salesforce/apex/CW_Utilities.becomeFacilityAdmin';
import resources from '@salesforce/resourceUrl/ICG_Resources';

export default class CwBecomeFacilityManagerContainer extends LightningElement {
    @api facilities;
    @api userInfo;
    @api label;
    @api filterTextFacilities;
    @track selectedFacilities;
    @track showModal = false;
    @track modalMessage = 'When you perform an action, this modal appears with extra info.';
    CHECKED_IMAGE = resources +'/icons/ic-tic-green.svg';
    ERROR_IMAGE = resources +'/icons/error-icon.svg';
    @track modalImage = this.CHECKED_IMAGE;
    @track requesting;

    setSelectedFacilities (event){
        this.selectedFacilities = event.detail;
    }
    filterFacilities(event){
        this.filterTextFacilities = event.detail;
    }

    becomeFacilityManager(){
            let facIds;
            if(this.selectedFacilities){
                facIds = [];
                this.selectedFacilities.forEach(fac =>{
                    if(fac.value) facIds.push(fac.value);
                });
                facIds = JSON.stringify(facIds);
            }
            this.requesting= true;
            becomeFacilityAdmin({companyId: this.userInfo.AccountId, facilityIds : facIds, contactId : this.userInfo.ContactId}).then(resp => {
				let parsedRes = JSON.parse(resp);
				this.modalImage = this.CHECKED_IMAGE;
				this.modalMessage = parsedRes.message;
				this.selectedFacilities = null;
				this.dispatchEvent( new CustomEvent('refresh'));
                this.requesting= false;
                this.showModal = true;
            }).catch(err => {
				console.error('Error ', err);
                this.modalMessage = this.label.icg_error_message;
                this.modalImage = this.ERROR_IMAGE;
                this.requesting= false;
                this.showModal = true;
            });
    }
    get facilitiesList (){
        let facilitiesList = [];
        this.facilities.forEach(opsGroup => {
            opsGroup.companyList.forEach(company => {
                if(company.stations && !opsGroup.isCompanyAdmin && !opsGroup.isPendingCompanyAdmin) facilitiesList.push(...company.stations);
            })
        })
        return facilitiesList;
    }
    createNewFacility(event){
        const selectedItemEvent = new CustomEvent("menuitemselection", {
            detail: event.currentTarget.dataset.action
        });
        // Dispatches the event.
        this.dispatchEvent(selectedItemEvent);
    }
    closeModal(){
        this.showModal = false;
    }

    handleTooManyFacilities(){
        this.modalMessage = this.label.icg_one_process_at_time_msg;
        this.modalImage = this.ERROR_IMAGE;
        this.showModal = true;
    }
}
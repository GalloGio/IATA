import { LightningElement,track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import removeProficiency from '@salesforce/apex/PortalIftpUtils.removeProficiency';

export default class PortalIftpRemoveProficiency extends LightningElement {

    @api recordId;
    @track loading = true;

    connectedCallback(){
        removeProficiency({roleAddressId: this.recordId})
        .then(results => {
            if(results !== undefined){
                this.loading = false;
                this.handleLoad();
                if(results == true){
                    this.showSuccessToast();
                }
                else{
                    this.showErrorToast();
                }
            }
            
        });
        

    }
 
    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            variant: 'success',
            message: 'Proficiency removed successfully.',
        });
        this.dispatchEvent(event);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message: 'An Error has occurred. Please contact your administtrator.',
        });
        this.dispatchEvent(event);
    }

    handleLoad() {
        const loadedEvent = new CustomEvent('loaded');
        // Fire the custom event
        this.dispatchEvent(loadedEvent);
    }
    
}
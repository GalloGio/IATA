import { LightningElement,track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import removeProficiency from '@salesforce/apex/PortalIftpUtils.removeProficiency';

export default class PortalIftpRemoveProficiency extends LightningElement {

    @api recordId;
    @track loading = true;

    connectedCallback(){
        
        let errorMessage = 'An error has occured, please contact your administrator';

        removeProficiency({roleAddressId: this.recordId})
        .then(results => {
            if(results !== undefined){
                this.loading = false;
                this.handleLoad();
                if(results === true){
                    this.showToast('Success', 'Proficiency removed successfully.', 'success');
                }
                else{
                    this.showToast('Error', errorMessage, 'error');
                }
            }
            
        }).catch(error => {
            this.loading = false;
            this.handleLoad();
            if (error.body.message) {
                errorMessage = error.body.message;
            }
            this.showToast('Remove Proficiency Not Applicable', errorMessage, 'error');
        });
        
    }

    showToast(theTitle, theMessage, theVariant){
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
        this.dispatchEvent(event);
    }

    handleLoad() {
        const loadedEvent = new CustomEvent('loaded');
        // Fire the custom event
        this.dispatchEvent(loadedEvent);
    }
    
}
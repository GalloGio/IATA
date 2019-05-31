import { LightningElement, api, track } from 'lwc';
import confirmSendRecycleBin from '@salesforce/label/c.ConfirmSendRecycleBin'
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findRecycleQueue from '@salesforce/apex/sendToRecicleBinCaseController.findRecycleQueue';

export default class sendToRecicleBinCase extends LightningElement {
    //API brought from the Aura wrapper
    @api name;

    //global variables
    group;
    recordInput;

    // Expose the labels to use in the template.
    label = {
        confirmSendRecycleBin
    };

    @track loading;

    //doInit function
    connectedCallback() {
        this.loading = false;
        //function grabs id of Queue from Apex Method based on the Region of this Record
        findRecycleQueue({ searchKey: this.name })
            .then(result => {
                //set this.group with Id of Queue

                // eslint-disable-next-line no-console
                console.log(result);
                this.group = result;

                //new recordInput for updating the Case
                this.recordInput = {
                    fields: {
                        Id: this.name,
                        OwnerId: this.group
                    }
                };

            })
            .catch(error => {
                //error handling
                this.error = error.body.message;
            });
    }

    save() {
        //standard function. updates record based on the recordInput
        this.loading = true;
        updateRecord(this.recordInput)
            .then(() => {
                //in case of success show green light toast
                const filterChangeEvent = new CustomEvent('filterchange');
                
                // Fires the custom event
                this.dispatchEvent(filterChangeEvent);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Sent to Recycle Bin',
                        variant: 'success'
                    })
                );
                this.loading = false;
            })
            //in case of failure show red light toast
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });


    }
    cancel() {
        const filterChangeEvent = new CustomEvent('filterchange');
        // Fires the custom event
        this.dispatchEvent(filterChangeEvent);
    }
}
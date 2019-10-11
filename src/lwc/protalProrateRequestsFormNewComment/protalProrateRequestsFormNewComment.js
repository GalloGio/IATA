import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveNewComment from '@salesforce/apex/ISSP_Baggage_Proration.saveNewComment';
export default class ProtalProrateRequestsFormNewComment extends LightningElement {
    
    @api recid; // rec  id
    @track goBack = false; // control to return to list
    @track baggageClaimComment; // Baggage Claim 
    @track dataRecords = false;
    @track showMeNow = false;
    @track loading = false;

    @track BaggageClaim = '';
    @track BaggageClaimName = '';
    @track PIRFileRef = '';
    @track EmailProrateDeptAirlineissuing = '';
    @track EmailProrateDeptAirlinereceiving = '';
    @track Comments = '';

    @track rec = {
        Baggage_Claim__c : '',
        Email_Prorate_Dept_Airline_issuing__c : '',
        Email_Prorate_Dept_Airline_receiving__c : '',
        Comments__c: ''
    }
    
    @track msg;
    @track variant;
    @track mode;




    /**
     * Executed on component opening
     */
    connectedCallback() {
        this.rec.Baggage_Claim__c = this.recid;
        this.showMeNow = true;
    }

    
    handleCommentChange(event) {
        this.rec.Comments__c = event.target.value;
    }

    /**
     * Handles the Create New Comment
     * 
     */

    handleBackClick() {
        console.log('handleBackClick');
        this.goBack = true;
    }

    /**
     * Handles the Create New Comment
     * 
     */

    handleAddCommentClick() {
        this.loading = true;
        if(this.rec.Comments__c !== ''){
            let wrapper = {
                Baggage_Claim: this.rec.Baggage_Claim__c,
                Comments: this.rec.Comments__c
            };
            saveNewComment({
                sWrapper:JSON.stringify(wrapper),
            })
            .then(results => {
                console.log('MR AddComment:: ',results);
                this.loading = false;
                this.goBack = true;
                this.dispatchEvent(new CustomEvent('addnewcomment'));

            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                this.variant = 'error';
                this.mode = 'sticky';
                this.msg = error;
            })
            .finally(() => {
                const event = new ShowToastEvent({
                    //title: 'Get PIR Data',
                    message: this.msg,
                    variant: this.variant,
                    mode: this.mode
                });
    
                this.dispatchEvent(event);
            });
        }
    }



}
import { LightningElement, track, api} from 'lwc';

import getContactJobFunctionValues      from '@salesforce/apex/OneId_RegistrationProcessController.getContactJobFunctionValues';

//custom labels
import ISSP_Registration_MR             from '@salesforce/label/c.ISSP_Registration_MR';
import ISSP_Registration_MRS            from '@salesforce/label/c.ISSP_Registration_MRS';
import ISSP_Registration_MS             from '@salesforce/label/c.ISSP_Registration_MS';
import CSP_L2_Profile_Details_Message   from '@salesforce/label/c.CSP_L2_Profile_Details_Message';
import CSP_L2_Profile_Details           from '@salesforce/label/c.CSP_L2_Profile_Details';
import CSP_L2_Title                     from '@salesforce/label/c.CSP_L2_Title';
import CSP_L2_Job_Function              from '@salesforce/label/c.CSP_L2_Job_Function';
import CSP_L2_Job_Title                 from '@salesforce/label/c.CSP_L2_Job_Title';
import CSP_L2_Next_Account_Selection    from '@salesforce/label/c.CSP_L2_Next_Account_Selection';
import CSP_PortalPath                       from '@salesforce/label/c.CSP_PortalPath';

export default class PortalRegistrationProfileDetails extends LightningElement {
    @api contactInfo;
    @track localContactInfo;
    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';

    /* Picklist options */
    @track salutationPicklistOptions;
    @track jobFunctionsPicklistOptions;

    @track isNextDisabled;

    /* label variables */
    _labels = {
        ISSP_Registration_MR,
        ISSP_Registration_MRS,
        ISSP_Registration_MS,
        CSP_L2_Profile_Details,
        CSP_L2_Profile_Details_Message,
        CSP_L2_Title,
        CSP_L2_Job_Function,
        CSP_L2_Job_Title,
        CSP_L2_Next_Account_Selection
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }
    
    checkCompletion(){
        var currentCompletionStatus = this.isNextDisabled;
        
        this.isNextDisabled = (this.localContactInfo.Salutation === '' || this.localContactInfo.Salutation === null || this.localContactInfo.Salutation === undefined)
                                || (this.localContactInfo.Membership_Function__c === '' || this.localContactInfo.Membership_Function__c === null || this.localContactInfo.Membership_Function__c === undefined) 
                                || (this.localContactInfo.Title === '' || this.localContactInfo.Title === null || this.localContactInfo.Title === undefined);

        if(this.isNextDisabled !== currentCompletionStatus){
            this.dispatchEvent(new CustomEvent('completionstatus',{detail : !this.isNextDisabled}));
        }
    }


    connectedCallback() {
        if (!String.prototype.padStart) {
            String.prototype.padStart = function padStart(targetLength,padString) {
                targetLength = targetLength>>0; //truncate if number or convert non-number to 0;
                padString = String((typeof padString !== 'undefined' ? padString : ' '));
                if (this.length > targetLength) {
                    return String(this);
                }
                else {
                    targetLength = targetLength-this.length;
                    if (targetLength > padString.length) {
                        padString += padString.repeat(targetLength/padString.length); //append to original to ensure we are longer than needed
                    }
                    return padString.slice(0,targetLength) + String(this);
                }
            };
        }

        this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));

        var salutationList = [];
        salutationList.push({ label: '', value: '' });
        salutationList.push({ label: this.labels.ISSP_Registration_MR, value: 'Mr.' });
        salutationList.push({ label: this.labels.ISSP_Registration_MRS, value: 'Mrs.' });
        salutationList.push({ label: this.labels.ISSP_Registration_MS, value: 'Ms.' });
        this.salutationPicklistOptions = salutationList;

        // Retrieve Job Functions list
        getContactJobFunctionValues()
            .then(result => {
                let functionList = [];

                functionList.push({ label: '', value: '' });

                for(let i = 0; i < result.length; i++){
                    functionList.push({ label: result[i].label, value: result[i].value });
                }
                this.jobFunctionsPicklistOptions = functionList;
                
                // keep 1st selected value if it exists
                let jobFunctions = this.localContactInfo.Membership_Function__c;

                if(jobFunctions !== undefined){
                    let splittedJobFunctions = jobFunctions.split(';');

                    if(splittedJobFunctions.length > 0){
                        this.localContactInfo.Membership_Function__c = splittedJobFunctions[0];
                    }
                }

                this.checkCompletion();
            })
            .catch((error) => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
            });
        this.dispatchEvent(new CustomEvent('scrolltotop'));
    }

    // Events handling
    changeSalutation(event){
        this.localContactInfo.Salutation = event.target.value;
        this.checkCompletion();
    }

    changeSelectedJobFunctions(event){
        this.localContactInfo.Membership_Function__c = event.target.value;
        this.checkCompletion();
    }

    changeTitle(event){
        this.localContactInfo.Title = event.target.value;
        this.checkCompletion();
    }

    next(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'2'}));
    }

    startLoading(){
        this.dispatchEvent(new CustomEvent('startloading'));
    }

    stopLoading(){
        this.dispatchEvent(new CustomEvent('stoploading'));
    }

    @api
    getContactInfo(){
        return this.localContactInfo;
    }
}
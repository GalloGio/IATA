import { LightningElement, api } from 'lwc';

export default class LwcFileUpload extends LightningElement {

    @api myRecordId;
    @api acceptedFormats;
    @api labelName = "Upload Document";

    //get acceptedFormats() {
    //    return ['.pdf'];
    //}


    connectedCallback() {
        console.log('LwcFileUpload: INIT connectedCallback');
        console.log('myRecordId: ', this.myRecordId);
        
        /*
        if(this.acceptedFormats === undefined || this.acceptedFormats.size() === 0){
            this.acceptedFormats.push('.pdf'); 
        }
        */
        
    }

    handleUploadFinished(event) {

        console.log('handleUploadFinished!!');


        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles: ',uploadedFiles );
        //alert("No. of files uploaded : " + uploadedFiles.length);

        // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        // 2. Read about event best practices at http://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_best_practices
        const uploadFinishEvent = new CustomEvent('uploadfinish', {
            detail: uploadedFiles
        });
        // 3. Fire the custom event
        this.dispatchEvent(uploadFinishEvent);
    }
    
}
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import manageUploadGlobalOJT from '@salesforce/apex/PortalIftpUtils.manageUploadGlobalOJT';

export default class PortalIftpUploadOJT extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track myRecordId;
    @track userInfo;
    @track showSearch = false;
    @track acceptedFormats = ['.pdf'];
    @track data;
    @track loadingSpinner = false;

    connectedCallback(){
        
        getUserInfo()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            
            this.userInfo = myResult;
            this.myRecordId = this.userInfo.accountRole;

        })
        .catch(error => {
            console.log('PortalIftpUploadOJT - getITPStations - Error : ' + error);
            this.mainErrorMessage = error;
            this.error = error;
        });  
    }

    handleUploadFinish(event){
        this.loadingSpinner = true;
        const uploadedFiles = JSON.parse(JSON.stringify(event.detail));
        let docdId = uploadedFiles[0].documentId;

        manageUploadGlobalOJT({fileId: docdId})
        .then(result =>{
            if(result){
                const event = new ShowToastEvent({
                    title: 'Upload Company OJT Document',
                    message: 'Document was uploaded successfully and is waiting IATA validation.',
                    variant: 'success',
                    mode: 'pester'
                });
                this.dispatchEvent(event);
                
            } else{
                const event = new ShowToastEvent({
                    title: 'Upload Company OJT Document',
                    message: 'An error has occurred. Unable to upload document. ',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            } 
            this.loadingSpinner = false;
        });
    }
}
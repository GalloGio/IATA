import { LightningElement, track } from 'lwc';

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

    connectedCallback(){
        
        getUserInfo()
            .then(result => {
                console.log(result);
                let myResult = JSON.parse(JSON.stringify(result));
                
                this.userInfo = myResult;
                console.log(' this.userInfo: ',  this.userInfo);

            })
            .catch(error => {
                console.log('getITPStations - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  

            console.log(' this.userInfo.accountRole: ',  this.userInfo.accountRole);
        this.myRecordId = this.userInfo.accountRole;

    }

    handleUploadFinish(event){

        const uploadedFiles = JSON.parse(JSON.stringify(event.detail));
        let docdId = uploadedFiles[0].documentId;
        
        console.log('PortalIftpImportStations - handleUploadFinish - uploadedFiles: ',uploadedFiles );
        console.log('PortalIftpImportStations - handleUploadFinish - docdId: ',docdId );

        manageUploadGlobalOJT({fileId: docdId});
    }
}
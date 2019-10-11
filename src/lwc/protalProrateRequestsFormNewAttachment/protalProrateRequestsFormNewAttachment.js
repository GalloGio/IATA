import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createUploadFile from '@salesforce/apex/UploadMultipleFileToAmazonButtonCtrl.createUploadFile';
import createAmazonFileObject from '@salesforce/apex/UploadMultipleFileToAmazonButtonCtrl.createAmazonFileObject';
export default class ProtalProrateRequestsFormNewAttachment extends LightningElement {

    @api recid; // rec  id
    @track goBack = false; // control to return to list
    @track loading = false;
    @track showErrorMessage = false;
    @track errorMessage ;

    @track msg;
    @track variant;
    @track mode;
    /**
     * Handles the Create New Comment
     * 
     */
    
    
    // this.dispatchEvent(new CustomEvent('addnewcomment'));
    handleUploadFinished(event){
        this.showErrorMessage = false;
        this.loading = true;
        var file = event.currentTarget.files[0];
        console.log('File::: ',file);

        createUploadFile({
            id: this.recid,
            filenameupload: file.name,
            contentType: file.type,
            filesize: file.size,
            folder: "prorate/"+this.recid+"/",
            credentialName: 'GenericAttach'
        })
        .then(result => {
            console.log('MR createUploadFile:: ',result);

			if( ! result.isSuccess){
                /*this.showErrorMessage = true;
                this.errorMessage = result.errorMessage;*/
                this.msg = result.errorMessage;
                this.variant = 'error';
                this.mode = 'sticky';
                this.loading = false;
				return false;
			}
			var reader = new FileReader();
            reader.readAsArrayBuffer(file);
			reader.onload = (e)=> {
				var arrayBuffer = reader.result;
                console.log('MR onload:: ',arrayBuffer);
				this.remoteFunctionPut(result, file, reader.result);
			};
        })
        .catch(error => {
            this.loading = false;
            console.log('createUploadFile - Error : ', error);
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
    remoteFunctionPut(awsCredencials, file, fileBody) {
		console.log("remoteFunctionPut: file - "+file);

		var amazonFilePath = awsCredencials.endpoint+awsCredencials.bucketName+'/'+awsCredencials.fullFileNameEncoded;
		/*sforce.connection.sessionId = "{!$Api.Session_ID}";
		sforce.connection.init("{!$Api.Session_ID}", amazonFilePath);*/

		//var progressBar;

		var xhr = new XMLHttpRequest();
		
		// salesforce overrides original XMLHttpRequest in IE
		if (!xhr.upload && window.Sarissa && window.Sarissa.originalXMLHttpRequest) {
			xhr = new Sarissa.originalXMLHttpRequest();
		}

		xhr.onreadystatechange = function () {
			if (this.readyState == 4) {
				fileCounter.refreshIfEmpty();
				var status = this.status;
				if (status == 200) { 
					////progressUpload(100, this.progressBar);
					//uploadFile(file);
				} else {
					if (this.responseText) {
						getResponseFromXML(this.responseText); 
						//uploadFile(file);
					} else {
						var message = '';
						if (this.statusText) {
							message = 'Status: '+this.status+'. Error: '+this.statusText; 
						}
						else if (this.responseText) {
							message = 'Status: '+this.status+'. Error: '+this.responseText;
						}
						else {
							message = 'Status:'+this.status+'. Error: Unknown error.'; 
						}
					}
				}
			}
		};

		xhr.open("PUT", amazonFilePath);

		xhr.setRequestHeader("Cache-Control", "no-cache");
		xhr.setRequestHeader("Authorization",awsCredencials.authorization);
		xhr.setRequestHeader("X-Amz-Date",awsCredencials.timestamp);
		xhr.setRequestHeader("Content-Type",file.type+';charset=UTF-8');

		xhr.send(fileBody);

		this.callToCreateAmazonFileObject(file, awsCredencials.fullFileName, null);
    }
    
    callToCreateAmazonFileObject(file, path, fileIdentifierPick) {
        console.log("callToCreateAmazonFileObject: path - "+path);
        console.log("callToCreateAmazonFileObject: file - "+file);
        console.log("callToCreateAmazonFileObject: fileIdentifierPick - "+fileIdentifierPick);
       if(fileIdentifierPick == null){
           fileIdentifierPick = '';
       }

        createAmazonFileObject({
            amazonKey: path,
            filesize: file.size,
            parentId: this.recid,
            recordType: 'AMS_File',
            fileIdentifierPick: fileIdentifierPick,
            source: ''
        })
        .then(result => {
            console.log('MR createUploadFile:: ',result);
            this.loading = false;
            this.msg = 'Attachment created successfully.';
            this.variant = 'success';
            this.mode = 'pester';
            this.dispatchEvent(new CustomEvent('addnewattachment'));

        })
        .catch(error => {
            console.log('createUploadFile - Error : ', error);
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
    handlestartUploadFile(){
        this.template.querySelector(`[data-id="inputFile"]`).click();
    }
    handleBackClick() {
        console.log('Create New Comment');
        console.log('handleBackClick');
        this.goBack = true;
    }
}
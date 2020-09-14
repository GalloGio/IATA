import { LightningElement, track, api } from 'lwc';
import relatedFiles from "@salesforce/apex/TIDSUtil.relatedFiles";
import { iconFile } from 'c/tidsUserInfo';

import { fireEvent, registerListener } from 'c/tidsPubSub';
import { CurrentPageReference } from 'lightning/navigation';

export default class TidsDocuments extends LightningElement {

	@api tidsCaseId = null;
	@track spinner = false;
	@track documents = [];
	@track isCaseClosed=false;
	@track isDocumentOpen=false;
	connectedCallback() {
		console.log('connectedCallback:parentid', this.tidsCaseId);
		if(this.tidsCaseId) {
			this.getDocuments(this.tidsCaseId);
		}
	}
	getDocuments(caseid) {
		this.spinner = true;
		this.isCaseClosed=false;
		console.log('getDocuments:parentid', caseid);
		relatedFiles({parentid: caseid})
		.then(response => {
			console.log('getDocuments:response', JSON.stringify(response));
			if (response!=null){
				if (response.isError===0){this.documentsCallback(response.documents);}
				if (response.isError===2){
					this.isCaseClosed=true;
					this.spinner=false;
				}
			}
		})
	}

	documentsCallback(payload) {
		this.documents = this.mappingFileFromSF(payload);
		this.spinner = false;
	}

	mappingFileFromSF(attachments) {
		console.log('mappingFileFromSF:attachments', JSON.stringify(attachments));
		let result = attachments.map(attachment => {
			return {
				id: attachment.Id, 
				name: attachment.Name, 
				contentType: attachment.ContentType,
				filepath:'/servlet/servlet.FileDownload?file='+attachment.Id,
				iconName:iconFile({type:attachment.ContentType})
			}
		});
		console.log('mappingFileFromSF:result', JSON.stringify(result));
		return result;
	}
	
}
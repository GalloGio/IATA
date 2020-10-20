import { LightningElement, track, api } from 'lwc';
import relatedFiles from "@salesforce/apex/TIDSUtil.relatedFiles";
import { iconFile } from 'c/tidsUserInfo';

//import { fireEvent, registerListener } from 'c/tidsPubSub';
//import { CurrentPageReference } from 'lightning/navigation';

export default class TidsDocuments extends LightningElement {

	@api tidsCaseId = null;
	@track spinner = false;
	@track documents = [];
	@track isCaseClosed=false;
	@track isDocumentOpen=false;
	connectedCallback() {
		if(this.tidsCaseId) {
			this.getDocuments(this.tidsCaseId);
		}
	}
	getDocuments(caseid) {
		this.spinner = true;
		this.isCaseClosed=false;
		relatedFiles({parentid: caseid})
		.then(response => {
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
		let result = attachments.map(attachment => {
			return {
				id: attachment.Id, 
				name: attachment.Name, 
				contentType: attachment.ContentType,
				filepath:'/servlet/servlet.FileDownload?file='+attachment.Id,
				iconName:iconFile({type:attachment.ContentType})
			}
		});
		return result;
	}
	
}
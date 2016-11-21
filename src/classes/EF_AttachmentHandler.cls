public with sharing class EF_AttachmentHandler {
	public EF_AttachmentHandler() {

	}

	public List<Id> getListAttachmentIds(List<Attachment> lsAttachments) {
		List<Id> lsIds = new List<Id>();
		for (Attachment a: lsAttachments) {
			lsIds.add(a.Id);
		}
		return lsIds;
	}

	@Future(callout=true)
	public static void createAmazonAttachmentsFromAttachments(List<Id> lsAttachmentIds) {
		List<Attachment> lsAttachments = [SELECT Id, Name, ParentId, ContentType, BodyLength, Body FROM Attachment WHERE Id IN :lsAttachmentIds];
		EF_AttachmentListController c = new EF_AttachmentListController();
		for(Attachment a: lsAttachments) {
			// (String)a.ParentId.left(3)+'/'+
			String folder =  WrapperAttach.getAmazonFolder(a.ParentId);
			String credentialName = c.credentialName;

			// System.debug(a.ParentId +' ' +  filenameupload +' ' + a.contentType +' ' + a.BodyLength +' ' + folder +' ' + credentialName);
			EF_AttachmentListController.UploadFile credentialNames = EF_AttachmentListController.createUploadFile(a.ParentId,  a.Name, a.contentType, a.BodyLength, folder, credentialName);

			// string s = EF_AttachmentListController.getExpiringLink(filenameupload );

			String  amazonFilePath = credentialNames.endpoint+credentialNames.bucketName+'/'+credentialNames.fullFileNameEncoded;
			Http h = new Http();
			HttpRequest xhr = new HttpRequest();
			xhr.setEndpoint(amazonFilePath);
			xhr.setMethod('PUT');


			xhr.setHeader('Cache-Control', 'no-cache');
			xhr.setHeader('Authorization',credentialNames.authorization);
			xhr.setHeader('X-Amz-Date',credentialNames.timestamp);
			xhr.setHeader('Content-Type',a.contentType+';charset=UTF-8');

			xhr.setBodyAsBlob(a.Body);

			HttpResponse res1 = null;
			res1 = h.send(xhr);
			Integer StatusCode = res1.getStatusCode();
			if(StatusCode == 200) {

				System.debug('akuakuakuaaku ' + res1);
			} else {
				System.debug('amazon transfer failed ' + res1);
			}

		}
	}
}

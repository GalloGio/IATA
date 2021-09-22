public without sharing class IGOMAttachmentUtil
{

	/**
	 * @description		Duplicates an existing attachment list and reparents it
	 * @param           attachments <Source of attachments to clone>
	 * @param           newParentId <Id of the new parent object>
	 * @return			List<Attachment> List of newly inserted attachments
	 */
	public static List<Attachment> duplicateAttachments(List<Attachment> attachments, Map<Id, Id> oldParentIdToNewParentId) {
		List<Attachment> newAttachments = new List<Attachment>();
		for (Attachment attachment : attachments) {
			attachment = new Attachment(
				ParentId = oldParentIdToNewParentId.get(attachment.ParentId),
				Name = attachment.Name,
				Description = attachment.Description,
				Body = attachment.Body
			);
			newAttachments.add(attachment);
		}
		insert newAttachments;
		for (Attachment attachment : newAttachments) {
			attachment.Body = null;
		}
		return newAttachments;
	}

	/**
	 * @description     Deletes an existing attachment
	 * @param           attachmentId <Id of the Attachment to delete>
	 */
	@AuraEnabled
	public static void deleteAttachment(Id attachmentId) {
		if (attachmentId != null && attachmentId.getSObjectType() === Attachment.getSObjectType())  {
			// Check the parent object, to limit scope of removal depending of parentids
			Attachment attachment = [SELECT ParentId FROM Attachment WHERE Id = :attachmentId];
			if (attachment.ParentId.getSObjectType() != Compliance_Review_Part__c.getSObjectType() &&
				attachment.ParentId.getSObjectType() != Document__c.getSObjectType()) {
				throw new AuraHandledException(IGOMConstants.ERRORS.INVALID_ATTACHMENT_PARENT);
			}
			// Delete the attachment
			delete new Attachment(Id = attachmentId);
		} else {
			throw new AuraHandledException(IGOMConstants.ERRORS.METHOD_ONLY_FOR_ATTACHMENTS_ERROR);
		}
	}

	/**
	 * @description     Creates a new attachment or appends to an existing one if the fileId is provided
	 * @param           parentId <Id of the Object for which the attachment will be created>
	 * @param           fileName <Name of the attachment>
	 * @param           contentType <Content-type (MIME) of the attachment>
	 * @param           fileId <Id of the existing attachment if this is an APPEND operation. If not, keep at null.>
	 * @param           base64data <Content of the attachment encoded as Base64. If an append operations follows, the data must be given in pieces of 3chars to ensure no data is lost when appending the split file.>
	 * @return          Id of the created Attachment
	 */
	@AuraEnabled
	public static Id saveAttachment(Id parentId, String fileName, String contentType, String fileId, String base64data) {
		if (fileId == null || fileId == '')  {
			fileId = saveNewFile(parentId, fileName, contentType, base64Data);
		} else {
			appendToFile(fileId, base64data);
		}
		return fileId;
	}

	private static Id saveNewFile(Id parentId, String fileName, String contentType, String base64Data) {
		Attachment att = new Attachment(
			ParentId = parentId,
			Body = EncodingUtil.base64Decode(base64Data),
			Name = fileName,
			ContentType = contentType
		);
		insert att;
		return att.Id;
	}

	private static void appendToFile(Id fileId, String base64Data) {
		Attachment a = [SELECT Id, Body FROM Attachment WHERE Id = :fileId];
		a.Body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(a.Body) + base64Data);
		update a;
	}
}
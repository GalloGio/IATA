public with sharing class Attachment_sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			Attachment.Id,
			Attachment.ParentId,
			Attachment.Name,
			Attachment.ContentType
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Attachment.sObjectType;
	}

	/****************************************************************************************************
		Created by David D 2015-10-19
			Return List of attachments for a given set of parent Id
	****************************************************************************************************/
	public Map<Id, List<Attachment>> getAttachments(Set<Id> parentIds)
	{
		Map<Id, List<Attachment>> ret = new Map<Id, List<Attachment>>();
		List<Attachment> attachments = (List<Attachment>) selectSObjectByField('ParentId', IdToString(parentIds));

		for(Attachment attach : attachments)
		{
			List<Attachment> tmp = (ret.containsKey(attach.ParentId)) ? ret.get(attach.ParentId) : new List<Attachment>();
				tmp.add(attach);
			ret.put(attach.ParentId,tmp);
		}

		return ret;
	}

	public Map<Id, Attachment> getAttachmentByTnC(Set<Id> tncIds)
	{
		Map<Id, Attachment> ret = new Map<Id, Attachment>();
		List<Attachment> attachments = (List<Attachment>) selectSObjectByField('ParentId', IdToString(tncIds));

		for(Attachment attach : attachments)
		{
			ret.put(attach.ParentId,attach); //Each T&C has only one attachment
		}

		return ret;
	}

}

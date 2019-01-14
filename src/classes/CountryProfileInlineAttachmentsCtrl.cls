public with sharing class CountryProfileInlineAttachmentsCtrl {

	private final Country_Profile__c cp;
	public List<Attachment> attList {get;set;}
	public List<AttWrapper> attWrapperList {get;set;}

	public Boolean showUpload {get;set;}
	public Blob file {get;set;}
	public String fileName {get;set;}	
	public String fileSection {get;set;}
	public String fileDescription {get;set;}

	public String toggleAttId {get;set;}

	public CountryProfileInlineAttachmentsCtrl(ApexPages.StandardController stdController) {

		cp = (Country_Profile__c)stdController.getRecord();
		attWrapperList = new List<AttWrapper>();

		attList = new List<Attachment>(
					[SELECT Id,Name,Description
					FROM Attachment
					WHERE ParentId =: cp.Id
					ORDER BY CreatedDate DESC]);

		for(Attachment a: attList){
			if(a.Description != null){
				String[] descSplit = a.Description.split('__###__',3);
				if(descSplit.size() == 3){
					if(descSplit[0] == '1')
						attWrapperList.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id,true,true));
					else
						attWrapperList.add(new AttWrapper(a.Name,descSplit[2],descSplit[1],a.id,false,true));
				}
				else{
					attWrapperList.add(new AttWrapper(a.Name,a.Description,'',a.id,false,false));
				}
			} else {
				attWrapperList.add(new AttWrapper(a.Name,'','',a.id, false,false));
			}			
		}
		
	}

	public List<SelectOption> getSections(){
  		List<SelectOption> options = new List<SelectOption>();
  		options.add(new SelectOption('General Information__###__', 'General Information'));
  		options.add(new SelectOption('BSP Profile__###__', 'BSP Profile'));
  		options.add(new SelectOption('CASS Profile__###__', 'CASS Profile'));
  		options.add(new SelectOption('Economic Profile__###__', 'Economic Profile'));
  		options.add(new SelectOption('Currency__###__', 'Currency'));
  		options.add(new SelectOption('Repatriation Process__###__', 'Repatriation Process'));
  		options.add(new SelectOption('Important Contacts__###__', 'Important Contacts'));
  		options.add(new SelectOption('ICCS Content__###__', 'ICCS Content'));
  		options.add(new SelectOption('Airlines Charges__###__', 'Airlines Charges'));
   		return options;
	}

	public PageReference disableAtt(){
        Attachment att = [SELECT Id,Description
					FROM Attachment
					WHERE Id =: toggleAttId];
		att.Description = '0'+att.Description.substring(1);
		update att;
        PageReference pageRef = new PageReference('/apex/CountryProfileInlineAttachments?id='+cp.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference enableAtt(){
        Attachment att = [SELECT Id,Description
					FROM Attachment
					WHERE Id =: toggleAttId];
		att.Description = '1'+att.Description.substring(1);
		update att;
        PageReference pageRef = new PageReference('/apex/CountryProfileInlineAttachments?id='+cp.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

	public PageReference showUpload(){
		showUpload=true;
		return null;
	}

	public PageReference uploadFile(){
		showupload=false;
		if(file == null){
            return null;
        }

        //else upload....
        Attachment newAtt = new Attachment();
        newAtt.parentId = cp.Id;
        newAtt.Name = fileName;
        newAtt.Description = '1__###__'+fileSection+fileDescription;
        newAtt.Body = file;
        insert newAtt;
        PageReference pageRef = new PageReference('/apex/CountryProfileInlineAttachments?id='+cp.Id);
        pageRef.setRedirect(true);
        return pageRef;
	}

	public class AttWrapper{
		public String name {get;set;}
		public String description {get;set;}
		public String section {get;set;}
		public String recordId {get;set;}
		public Boolean visible {get;set;}
		public Boolean namingConventionFulfilled {get;set;}

		public AttWrapper(String name, String description, String section, String recordId, Boolean visible, Boolean namingConventionFulfilled){
			this.name = name;
			this.description = description;
			this.section = section;
			this.recordId = recordId;
			this.visible = visible;
			this.namingConventionFulfilled = namingConventionFulfilled;
		}
	}

}
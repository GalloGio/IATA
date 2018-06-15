public without sharing class LiveAgentPostChatController {
	public String channelAnswer {get; set;}
	public String agentExperienceAnswer {get; set;}
	public String commentAnswer {get; set;}
	public Boolean isSuccess {get; set;}
	public Boolean isSubmitted {get; set;}
	public Boolean isResubmission {get; set;}
	public User agent {
		get{
			if (agent == null) {
				if (relatedCase != null) {
					if (relatedCase.OwnerId != null && relatedCase.LastModifiedById != null) {
						Integer countUser = [SELECT COUNT() FROM User WHERE Id =:relatedCase.OwnerId];
						String id;
						if (countUser > 0){
							id = relatedCase.OwnerId;
						}else{
							//Owner is a Queue. We will get LastModifiedById
							id = relatedCase.LastModifiedById;
						}
						agent = [SELECT Id, Name, FirstName, LastName FROM User WHERE Id = :id LIMIT 1][0];
					}
				}
			}
			return agent;
		}
		set;
	}
	public Boolean isIncomplete {
		get{
			if (relatedCase.Subject != null && relatedCase.OwnerId != null){
				isIncomplete = false;
			}else{
				isIncomplete = true;
			}
			return isIncomplete;
		}
		set;
	}
	public String caseId {
		get{
			if (caseId == null){
				try{
					caseId = ApexPages.currentPage().getParameters().get('attachedRecords').substringAfter('"Case":"').substringBefore('"');
				}catch(Exception e){
					return null;
				}
			}
			return caseId;
		}
		set;
	}
	public String lang {
		get{
			if (lang == null) {
				try{
					String jsn = ApexPages.currentPage().getParameters().get('chatDetails');
					WrapperDetailsChatDetails details = new WrapperDetailsChatDetails();
					details = (WrapperDetailsChatDetails)System.JSON.deserialize(jsn, WrapperDetailsChatDetails.class);
					List<WrapperCustomDetails> customDetails = details.customDetails;
					lang = 'en';
					for (WrapperCustomDetails detail : customDetails){
						if (detail.label == 'buttonlanguage'){
							lang = detail.value;
							break;
						}
					}
				}catch(Exception e) {
				}
			}
			return lang;
		}
		set;
	}
	public Case relatedCase {
		get{
			if (relatedCase == null){
				if (caseId != null && caseID != ''){
					relatedCase = [SELECT Id, Subject, OwnerId, LastModifiedById FROM Case WHERE Id=:caseID];
				}
			}
			return relatedCase;
		}
		set;
	}
	public void setChannelAnswer(String answer) {
		channelAnswer = answer;
	}
	public void setAgentExperienceAnswer(String answer) {
		agentExperienceAnswer = answer;
	}
	public List<SelectOption> getChannel() {
		Schema.DescribeFieldResult fieldResult = Instant_Surveys__c.Chat_Channel__c.getDescribe();
		return fetchOptions(fieldResult);
	}
	public List<SelectOption> getAgentExperience() {
		Schema.DescribeFieldResult fieldResult = Instant_Surveys__c.Chat_Agent_Experience__c.getDescribe();
		return fetchOptions(fieldResult);
	}

	public void submit() {
		if (relatedCase != null){
			if (relatedCase.Subject != null && relatedCase.OwnerId != null) {
				if (channelAnswer != null && channelAnswer != '' && agentExperienceAnswer != null && agentExperienceAnswer != ''){
					Integer countSurvey = [SELECT COUNT() FROM Instant_Surveys__c WHERE Relationship_to_Case__c =:relatedCase.Id];
					if(countSurvey < 1){
						Instant_Surveys__c survey = new Instant_Surveys__c();
						survey.Chat_Agent__c = agent.Id;
						survey.Name = 'Chat - ' + relatedCase.Subject;
						survey.Relationship_to_Case__c = relatedCase.Id;
						survey.Chat_Channel__c = channelAnswer;
						survey.Chat_Comment__c = commentAnswer;
						survey.Chat_Agent_Experience__c = agentExperienceAnswer;
						survey.RecordTypeId  = RecordTypeSingleton.getInstance().getRecordTypeId('Instant_Surveys__c', 'Live_Agent_Chat');
						try{
							insert survey;
							isSuccess = true;
						}catch (Exception e){
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An error occurred: ' + e));
						}
					}else{
						isResubmission = true;
					}
				}else{
					isSubmitted = true;
					if (channelAnswer == null || channelAnswer == ''){
						channelAnswer = null;
					}
					if (agentExperienceAnswer == null || agentExperienceAnswer == ''){
						agentExperienceAnswer = null;
					}
				}
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Case information is incomplete'));
			}
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Case not found'));
		}
	}

	private List<SelectOption> fetchOptions (Schema.DescribeFieldResult fieldResult) {
		List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
		List<SelectOption> options = new List<SelectOption>();
		for (Schema.PicklistEntry entry : entries){
			options.add(new SelectOption(entry.getValue(), entry.getLabel()));
		}
		return options;
	}

	public Class WrapperDetailsChatDetails {
		public List<String> prechatDetails;
		public WrapperGeoLocation geolocation;
		public String visitorId;
		public List<WrapperCustomDetails> customDetails;
		public WrapperAgent agent;
	}

	public Class WrapperAgent {
		public String userId;
		public String agentName;
		public String transfer;
	}

	public Class WrapperCustomDetails {
		public String value;
		public List<String> entityMaps;
		public String label;
		public List<String> transcriptFields;
	}

	public Class WrapperGeoLocation {
		public String organization;
		public String region;
		public String city;
		public String countryName;
		public String latitude;
		public String longitude;
	}

	public LiveAgentPostChatController() {
		agentExperienceAnswer = null;
		channelAnswer = null;
		if (agent == null){
			isIncomplete = true;
		}
	}
}
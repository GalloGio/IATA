public with sharing class TopicHelper {
    
    public class TopicsWrapper {
		public String acceptedTopics {get;set;}
		public Set<String> topicSet {get; set;}
		
		public TopicsWrapper(String acceptedTopics, Set<String> topicSet){
			this.acceptedTopics = acceptedTopics;
			this.topicSet = topicSet;
		}
	}
	
	public static TopicsWrapper getTopicsInfo(){
		
		String strAcceptedValues = '';
		
		Set<String> topicSet = new Set<String>();
		
		List<AMP_Account_Topics__c> topics = AMP_Account_Topics__c.getAll().Values();
		
		//Sort topics by name
		List<String> topicstr = new List<String>();
		for (AMP_Account_Topics__c at : topics){
			topicstr.add(at.Name);
		}
		
		topicstr.sort();

		integer i=1;
		
		Boolean requestFromVf = ApexPages.currentPage() != null;
		
		if(requestFromVf){
			strAcceptedValues += '<table><tbody>';
		}
		
		for (String at : topicstr) {
			
			topicSet.add(at);
			
			//If the request is from visualforce (ChatterBroadCast Tool)
			//formats the topics as a two column "table"
			if(requestFromVf){
				
				if(Math.mod(i, 2) != 0){
					strAcceptedValues += '<tr>';
					strAcceptedValues += '<td><b>' + at + '</b></td>';
				}
				else {
					strAcceptedValues += '<td><b>' + at + '</b></td>';
					strAcceptedValues += '</tr>';
				}
				
				i++;
							
			}
			else {
				//Ideally the topics would be separated by tabs (\t)
				//However "\t" does not work on Chrome
				strAcceptedValues += (strAcceptedValues == '' ? '' : ';   ') + at;
			}
		
		}
		
		if(requestFromVf){
			strAcceptedValues += '</tbody></table>';
		}
		
		return new TopicsWrapper(strAcceptedValues, topicSet);
		
	}
	
}
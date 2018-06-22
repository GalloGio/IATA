public with sharing class transformationTestHelper {


    public static map<string,id> AccRtNamePerIds (){
    
     	map<string,id> developerNamePerId = new map<string,id>();
        set<String> developerNames = new set<String>{'IATA_Agency' ,'IATA_Airline_BR', 'IATA_Airline', 'IATA_GSA', 'IATA','Others'}; 
            	
	    for(RecordType rT:[SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName IN: developerNames]){
	    			developerNamePerId.put(rt.developername,rT.id);
	    }
	    
	    return developerNamePerId;
    }


}
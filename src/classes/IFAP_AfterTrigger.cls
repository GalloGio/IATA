public  class IFAP_AfterTrigger {	

	public static map<Id,Account> latestDate(map<Id,list<Case>> casesPerAcct){	
		Map<Id,Account> newAcctPerAcctId = new Map<Id,Account>();
		
		for(Id acctId: casesPerAcct.keyset()){
			date tmp;
			date winner;
			for(Case c:casesPerAcct.get(acctId)){
				
				tmp = c.Assessment_Performed_Date__c;
				winner = winner == null ? tmp : tmp >= winner ? tmp : winner;
			    if(newAcctPerAcctId.get(c.Accountid) == null || winner <> newAcctPerAcctId.get(c.Accountid).Assessment_Performed_Date__c )
			    	newAcctPerAcctId.put(c.Accountid, new Account(id = c.Accountid, Assessment_Performed_Date__c = winner, 
			    		Financial_Review_Result__c = c.Financial_Review_Result__c));			
			}				
		}
		return newAcctPerAcctId; 							
	}
}
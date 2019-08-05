global Class ANG_FillCaseTypeOfCustomer{

	public static Map<String, String> categoryCustomerMap = new Map<String, String> {
        'IATA Passenger Sales Agent' => 'IATA Travel Agent',
        'IATA Cargo Agent' =>   'IATA Cargo Agent',
        'Import Agent' =>   'IATA Cargo Agent',
        'CASS Associate' => 'CASS Associates',
        'Courier' =>    'IATA Cargo Agent',
        'Handling Agent' => 'IATA Travel Agent',
        'MSO Member Sales Office' => 'IATA Travel Agent',
        'TIDS Agent' => 'TIDS',
        'GSA General Sales Agent' =>    'General Sales Agent (GSA)',
        'GSSA Cargo' => 'GSSA Cargo'
    };
        
    @InvocableMethod
    public static List<String> fillCaseTypeOfCustomer(List<String> accountId){
        
        List<String> resultLst = new List<String>();
        
		Account acct = [Select Id, category__c, location_type__c from Account where Id =:accountId];
        
		if(acct.location_type__c == null) return null;

        if(acct.location_type__c == 'SA'){
            resultLst.Add('IATA Travel Agent');
			return resultLst;
        }
        
        if(acct.category__c == null) return null;
      
        resultLst.Add(categoryCustomerMap.get(acct.category__c)); 
        
        return resultLst; 
    }
}
global class ISSP_Switch_IFAP_CaseContact{
    //Called by AssignFinancialAssessmentContact visula flow to change IFAP Case Owner
    //Apex allows us to bypass case sharing for Portal Admin (on Account Team which is Read-only)
    
    private static Id RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    
    @InvocableMethod
    
    public static void getSetPermissionSet(List<Contact> newIFAPContacts) {
        
        Contact newifapcon = newIFAPContacts[0];
        
        //Get all open IFAP cases for this contact's Account
        //Usually only 1 open IFAP case at a time, but limit to 2 just in case more than one
        List <Case> ifapOpenCases = [SELECT Id FROM Case
                                     WHERE RecordTypeId= :RECORD_TYPE_ID AND IsClosed=false AND AccountId = :newifapcon.AccountId
                                     LIMIT 2
                                    ];
      
        for(Case ifapcase : ifapOpenCases) {
            ifapCase.ContactId = newifapcon.Id;
        }
        update ifapOpenCases;
    }
}
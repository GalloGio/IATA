/* General Trigger on Case
 * Created On 12/12/2013
 * Created By Kofi Johnson
 */

trigger trgCaseLastSIDRADate on Case (after insert, after update)
//Get the most recent SIDRA case and update the Account with its CreatedDate
{
    // Get Sidra Record Type Id
    private Id sidraRecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SIDRA');    
    private Map<Id,Account> sidraCasesAccounts;
    private Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
    Boolean isSidraCasesAccountsInit = false; // This variable checks if the sidraCasesAccounts have been already initialized.
    
    if (Trigger.isInsert)
    {         
      	if (Trigger.isAfter)
        {
       		for (Case thisCase:Trigger.New)
           	{
           		if (thisCase.RecordTypeId == sidraRecordTypeId) 
                {
                    // Initialization of SOQL variables
                    if (isSidraCasesAccountsInit == false)
                    {
                     	sidraCasesAccounts= new Map<Id,Account>([SELECT Id, Identify_as_Last_SIDRA_Date__c, 
                                                                     (SELECT Id, CaseNumber, CreatedDate FROM Account.Cases 
                                                                      WHERE RecordTypeId =:sidraRecordTypeId /*AND Status != 'Closed'*/ 
                                                                      ORDER BY createdDate DESC LIMIT 1) 
                                                                      FROM Account WHERE Id IN (SELECT AccountId From Case WHERE Id IN :Trigger.newMap.keySet())]);   
                        isSidraCasesAccountsInit = true;
                    }
                    
                    Account acc = sidraCasesAccounts.get(thisCase.AccountId);                    
                    if (acc != null)
                    {
                        acc.Identify_as_Last_SIDRA_Date__c = DateTime.now();
                        accountsToUpdate.put(acc.Id, acc);
                    }
                }
           }
    	   if (accountsToUpdate.size() > 0)
           {
           		update accountsToUpdate.values();
           }
        }     
    }
    
    if (Trigger.isUpdate)
    {
        if (Trigger.isAfter)
        {
        	for (Case thisCase:Trigger.new)
            {
                Case oldCase = Trigger.oldMap.get(thisCase.Id);
                
                if ((thisCase.RecordTypeId == sidraRecordTypeId) && (oldCase.RecordTypeId != sidraRecordTypeId))
                { 
                    // Initialization of SOQL variables
                    if (isSidraCasesAccountsInit == false)
                    {
                     	sidraCasesAccounts= new Map<Id,Account>([SELECT Id, Identify_as_Last_SIDRA_Date__c, 
                                                                     (SELECT Id, CaseNumber, CreatedDate FROM Account.Cases 
                                                                      WHERE RecordTypeId =:sidraRecordTypeId /*AND Status != 'Closed'*/ 
                                                                      ORDER BY createdDate DESC LIMIT 1) 
                                                                      FROM Account WHERE Id IN (SELECT AccountId From Case WHERE Id IN :Trigger.newMap.keySet())]);   
                        isSidraCasesAccountsInit = true;
                    }
                    System.debug('*********' + sidraCasesAccounts);
                    System.debug('********* isSidraCasesAccountsInit ' + isSidraCasesAccountsInit);
                    Account acc = sidraCasesAccounts.get(thisCase.AccountId);                    
                    if (acc != null)
                    {
                        acc.Identify_as_Last_SIDRA_Date__c = DateTime.now(); //thisCase.createdDate;
                        accountsToUpdate.put(acc.Id, acc);
                    }                   
                }
                if ((thisCase.RecordTypeId != sidraRecordTypeId) && (oldCase.RecordTypeId == sidraRecordTypeId))
                {
                    // Initialization of SOQL variables
                    if (isSidraCasesAccountsInit == false)
                    {
                     	sidraCasesAccounts= new Map<Id,Account>([SELECT Id, Identify_as_Last_SIDRA_Date__c, 
                                                                     (SELECT Id, CaseNumber, CreatedDate FROM Account.Cases 
                                                                      WHERE RecordTypeId =:sidraRecordTypeId /*AND Status != 'Closed'*/ 
                                                                      ORDER BY createdDate DESC LIMIT 1) 
                                                                      FROM Account WHERE Id IN (SELECT AccountId From Case WHERE Id IN :Trigger.newMap.keySet())]);   
                        isSidraCasesAccountsInit = true;
                    }
                    
                    Account acc = sidraCasesAccounts.get(thisCase.AccountId);                    
                    if (acc != null)
                    {
                        if (acc.Cases.size() > 0)
                        {
                            acc.Identify_as_Last_SIDRA_Date__c = acc.Cases[0].createdDate;
                            accountsToUpdate.put(acc.Id, acc);
                        }
                        else
                        {
                            acc.Identify_as_Last_SIDRA_Date__c = null;
                            accountsToUpdate.put(acc.Id, acc);
                        }
                    }
                }
            }
            if (accountsToUpdate.size() > 0)
           	{
           		update accountsToUpdate.values();
           	}
        }       
    }   
}
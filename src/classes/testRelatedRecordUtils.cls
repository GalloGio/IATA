@isTest
public class testRelatedRecordUtils{
testMethod static void closerelatedtest() {
    //create dummy test data, filling out all required fields
    //Use select to get Open/Closed Statuses for Tasks, Opportunity and Case
    OpportunityStage OpenOppStage = [Select MasterLabel, IsActive, IsClosed from OpportunityStage Where IsActive = true And IsClosed = False Limit 1];
    OpportunityStage ClosedOppStage = [Select MasterLabel, IsActive, IsClosed from OpportunityStage Where IsActive = true And IsClosed = True Limit 1];
    CaseStatus OpenCaseStatus = [Select MasterLabel, IsClosed, IsDefault from CaseStatus Where IsClosed = False Limit 1];
    system.debug(opencasestatus.masterlabel + ' open case status');
    CaseStatus ClosedCaseStatus = [Select MasterLabel, IsClosed, IsDefault from CaseStatus Where IsClosed = True Limit 1];
    system.debug(closedcasestatus.masterlabel + ' closed case status');
    TaskStatus OpenTaskStatus = [Select MasterLabel, IsClosed, IsDefault from TaskStatus Where isClosed = False Limit 1];
    TaskStatus ClosedTaskStatus = [Select MasterLabel, IsClosed, IsDefault from TaskStatus Where isClosed = True Limit 1];    
    //account to associate opportunity
    Account a = new Account(name = 'testaccoppclone', site = 'test',BillingCity='test',BillingCountry='test' );
    
    Insert a;
    
    //opportunity to close
    Opportunity o = new Opportunity(name = 'test', AccountId = a.id, CurrencyISOCode = 'EUR', CloseDate = Date.today(), StageName = OpenOppStage.MasterLabel, Amount = 50000);
    
    Insert o;
    
    //contact for task/case association
    Contact c = new Contact(FirstName = 'bob', LastName = 'test', AccountId = a.Id, email = 'bob@test.com');
    
    Insert c;
    //Case to close
    Case ca = new Case(AccountID = a.id, ContactId = c.id, CurrencyISOCode = 'EUR', Origin = 'test', Reason = 'test', Subject = 'test case', Description = 'this is a test case', Status = openCaseStatus.MasterLabel);
    
    Insert ca;
    //task for association to Opp
    Task tsko = new Task(ActivityDate = date.Today(), CurrencyISOCode = 'EUR', Description = 'test opportunity task', Priority = 'test', Status = openTaskStatus.MasterLabel, Subject = 'test Subject', WhatId = o.id, WhoId = c.id);
    
    Insert tsko;
    //task for association to Case
    Task tskc = new Task(ActivityDate = date.Today(), CurrencyISOCode = 'EUR', Description = 'test opportunity task', Priority = 'test', Status = openTaskStatus.MasterLabel, Subject = 'test Subject', WhatId = ca.id, WhoId = c.id);
    
    Insert tskc;
    //StartTests
    Test.StartTest();
    //opp trigger Test
    //Set Opp Stage to Closed
    o.StageName = ClosedOppStage.MasterLabel;
    Update o;
    //Assert that associated task was closed
    // RDJ : 11/03/09 comment the 3 lines below
    //for(Task t:[Select isClosed from Task where WhatID =: o.id]){
    //    System.assertEquals(t.IsClosed, True,'Opp task was not updated');
    //}
    //Case Trigger Test
    //Set Case Status to Closed
    ca.Status = ClosedCaseStatus.MasterLabel;
    Update ca;
    // RDJ : 11/03/09 comment the 3 lines below
    //Assert that associated task was closed
    //for(Task t:[Select isClosed from Task where WhatID =: ca.id]){
     //   System.assertEquals(t.IsClosed, True,'Case task was not updated');
     //   }
    Test.StopTest();
    }
}
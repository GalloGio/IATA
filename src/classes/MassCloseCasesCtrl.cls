public class MassCloseCasesCtrl{
	public list<Case> casesel {get;set;}
	public integer pagenumber{get;set;}
	list<id> caseids;

	public MassCloseCasesCtrl(ApexPages.StandardSetController standardController){
		casesel = new List<Case>();
		casesel.addAll((List<Case>) standardController.getSelected());
		caseids= new list<Id>();
		for(Case c : casesel){
			caseids.add(c.id);
		}
		casesel = [SELECT  Subject, casenumber, priority, RecordType.DeveloperName, Contact.Name, Account.Name, CreatedDate, LastModifiedDate, Account_Billing_Country__c, Owner.Alias, Status
					FROM Case WHERE Id IN :caseids];
		pagenumber = 1;
		for(Case c : casesel){
			if(c.RecordType.DeveloperName != 'IATA_Financial_Review'){
				pagenumber = 0;
				break;
			}
		}


	}


	public PageReference CloseCases(){

		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing')] < 5){
			MassCloseCaseBatch batch = new MassCloseCaseBatch();
			batch.cases = casesel;
			database.executebatch(batch);
		} else {
		   //schedule this same schedulable class again in 30 mins
		   MassCloseCaseWrapper sc = new MassCloseCaseWrapper();
		   sc.caseids = caseids;
		   DateTime dt = DateTime.now().addSeconds(1800);
		   String timeForScheduler = String.valueOf(dt.second() +' ' + dt.minute() + ' ' + dt.hour() + ' * * ? *');
		   Id schedId = System.Schedule('MassCloseCaseWrapper-'+timeForScheduler,timeForScheduler,sc);
		}
		pagenumber = 2;
		return null;
	}

}

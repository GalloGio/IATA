public class ChangeOwnershipCtrl {

	private final Contact ctc;
	private UtilityCS__c utcs;
	private CRMfusionDBR101__Scenario__c scenario;

	public ChangeOwnershipCtrl(ApexPages.StandardController controller) {
				this.ctc = (Contact)controller.getRecord();


	}

	public PageReference returnToContact(){

		Savepoint sp = Database.setSavepoint();
	 try{
			   this.utcs = UtilityCS__c.getValues('DupeScenarioNumber');
			   if(this.utcs == null)
					   throw new transformationException('No Dupe Blocker Scenario Found: please check with an Administrator');

				scenario = [SELECT ID,CRMfusionDBR101__Deployed__c
							FROM  CRMfusionDBR101__Scenario__c
							WHERE CRMfusionDBR101__Scenario_Number__c =:utcs.Value__c ];
				boolean updateTheScen = scenario.CRMfusionDBR101__Deployed__c;

				if(updateTheScen){ // we dont want to activate a dupe blocker scenario that is inactive
					scenario.CRMfusionDBR101__Deployed__c = false;
					update scenario;
				}

				ctc.OwnerId = system.Userinfo.getUserId();
				update ctc;

				if(updateTheScen){  // we dont want to activate a dupe blocker scenario that is inactive
					scenario.CRMfusionDBR101__Deployed__c = true;
					update scenario;
				}


		PageReference ctcPage = new ApexPages.StandardController(ctc).view();
		ctcPage.setRedirect(true);
		return ctcPage;


		 }catch(Exception e){

			Database.rollback( sp );
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Error : ' + e.getMessage()  +  '      cd  ' +e.getlineNumber()));
			System.debug(e.getmessage());

			return null;
		}
	}

}

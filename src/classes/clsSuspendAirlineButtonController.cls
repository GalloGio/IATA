public class clsSuspendAirlineButtonController {
	public Id accountId {public get; private set;}

	public Boolean showSuspendButton {
		public get {
			String currentUserProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
			String allowedProfiles = 'IDFS Airline Participation Supervisor - HO';

			return allowedProfiles.contains(currentUserProfile);
		} private set;
	}

	public clsSuspendAirlineButtonController (final ApexPages.StandardController controller) {
		accountId = controller.getRecord().Id;
	}

	public PageReference suspendAirline() {

		set<Id> consumersId = new set<Id>();
		for(account a: [SELECT Id FROM Account where parentId =: accountId ])
			consumersId.add(a.id);
	  //  throw new TransformationException('ASAs ');
		if(!consumersId.isEmpty()){

				list<Services_Rendered__c> services = [SELECT Id, Services_Rendered_Status__c
														FROM Services_Rendered__c
														WHERE Services_Rendered_to_Airline__c IN:consumersId
														AND Services_Rendered_Status__c = 'Active'
														AND(  Services_Rendered_Type__c = 'CASS Participation'
															  OR  Services_Rendered_Type__c  = 'BSP Representation')];
				system.debug('consumersId : ' + consumersId );
				for(Services_Rendered__c ser :services){

												 ser.Services_Rendered_Status__c = 'Inactive';
									}
				system.debug('No of services: ' + services.size());
				update services;

		}

		PageReference curPage = ApexPages.currentPage();
		curPage.getParameters().put('success','true');
		curPage.setRedirect(true);
		return curPage;
	}
}

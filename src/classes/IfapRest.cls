@RestResource(urlMapping='/IFAP/*')
global with sharing class IfapRest {
	/*
	IfapId:   ID case
	FileName : name of the amazon file name (!filename not the fullname)

	*/

	private static final string FOLDER = 'IFAP/FinancialDocuments/';
	private static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME);

	@HttpPost
	webservice static boolean changeStatus(String caseNumber, String FileName, Double FileSize) {
		system.debug('caseNumber' +caseNumber+ ' FileName ' + FileName);

		List<AmazonFile> listfile = new List<AmazonFile>();
		AmazonFile__c amazonFile = new AmazonFile__c();


		try{
			if(caseNumber <> null){
				List<Case> cse =[select Id, OwnerID, Casenumber, IFAP_Agent_Code__c, From_IFAPRest__c FROM case where CaseNumber = : caseNumber and STATUS != 'Submitted' ];
				if(cse <> null && cse.size()>0){

					//CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
					cse[0].status = 'Submitted';
					cse[0].From_IFAPRest__c = true;
					update cse;
				}
			}

			return true;

			}catch(Exception ex){
				//TransformationHelper.sendEmailSupport('FATAL: IFAP changeStatus ' +caseNumber ,'STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
				return false;
			}
		}

	   @future(callout=true)
	   @TestVisible
	   private static void deleteRemainingFiles(list<Id> iDAmazonFiles){
			List<AmazonFile__c> amazonFiles = new List<AmazonFile__c>();

			try{
				amazonFiles = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE ID IN: iDAmazonFiles];
				system.debug('amazonFiles ' + amazonFiles);

				if(!amazonFiles.isEmpty()){
					for(AmazonFile__c amFiles : amazonFiles){
						AmazonRest.deleteFile(amFiles.Full_Name_Unique__c, CREDENTIALS);
					}
				}

				//delete from sfdc
				List<AmazonFile__c> amfiles = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE ID IN: iDAmazonFiles AND Full_Name_Unique__c like'%.pdf%'];
				database.delete(amfiles);

			}catch(Exception ex){
				TransformationHelper.sendEmailSupport('FATAL: IFAP deleteRemainingFiles iDAmazonFiles ' + iDAmazonFiles + ' amazonFiles List ' + amazonFiles , 'STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
			}
		}
}

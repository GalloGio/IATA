/**
 * @author		  Jorge Corral <jorge.corral@adesso.es>
 * @description	  Class to test the code in IGOMParser class.
 *
 * Edit Log:
 * @history		 2020/08/19  |  Jorge Corral <jorge.corral@adesso.es>  |  Class creation and parseTest method added.
 */
@isTest
public class IGOMParserTest {
	
	/**
	 * @description Method that tests the parse method in a working scenario.
	 * Take effective date from XML parameter.
	 */
	@isTest
	public static void parseTest_MultipleSections_Success(){
		String str = '<?xmlversion="1.0" encoding="utf-8"?><Chapter permid="igom-gap-1" id="igom-gap-1" edition="10"><Section1 permid="igom-permid_0.4171466117622492" id="igom-1" xml:lang="es" effectivedate="2020/12/23"><Section1Number>Chapter 1:</Section1Number><Section1Heading>PassengerHandlingProcedures</Section1Heading><Section2 permid="igom-permid_0.7857337828998681" id="igom-1-1.1"><Section2Number>1.1</Section2Number><Section2Heading>PassengerDeparture</Section2Heading><Section3 permid="igom-permid_0.6496767700095887" id="igom-1-1.1.1"><Section3Number>1.1.1</Section3Number><Section3Heading>Pre-DepartureActivities</Section3Heading><Section4 permid="igom-permid_0.6146238625670233" id="igom-1-1.1.1.1" rev="changed"><Section4Number>1.1.1.1</Section4Number><Section4Heading>TicketSalesCounter</Section4Heading></Section4><Section4 permid="igom-permid_0.6487040525387596" id="igom-1-1.1.1.2" rev="deleted"><Section4Number>1.1.1.2</Section4Number><Section4Heading>PassengerPre-FlightPreparation</Section4Heading></Section4></Section3></Section2></Section1></Chapter>';
		
		Test.startTest();
		Id manualID = IGOMParser.parse(str);
		Test.stopTest();
		
		Document__c document = [SELECT Effective_Date__c, Language__c FROM Document__c WHERE Id = :manualID LIMIT 1];
		System.assertEquals(Date.newInstance(2020, 12, 23), document.Effective_Date__c);
		System.assertEquals('Spanish', document.Language__c);
		List<Document_Part__c> procedureFirstLv = [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.PART AND Document__c = :manualID];
		System.assertEquals(1, procedureFirstLv.size());
		List<Document_Part__c> procedureSecondLv = [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER AND Document__c = :manualID];
		System.assertEquals(1, procedureSecondLv.size());
		List<Document_Part__c> procedureThirdLv = [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.SECTION AND Document__c = :manualID];
		System.assertEquals(1, procedureThirdLv.size());
		List<Document_Part__c> procedureFourthLv = [SELECT Id, Version_Change_Status__c, Index__c FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.SUB_SECTION AND Document__c = :manualID];
		System.assertEquals(2, procedureFourthLv.size());
		
		List<Document_Part__c> deletedProc = new List<Document_Part__c>();
		for(Document_Part__c aProced : procedureFourthLv){
			if(aProced.Version_Change_Status__c == IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.DELETED && aProced.Index__c == null){
				deletedProc.add(aProced);
			}
		}
		System.assertEquals(1, deletedProc.size());
	}
	
	/**
	 * @description Method that tests the parse method in a working scenario, multiple sections have the same index.
	 * Take effective date from metadata.
	 */
	@isTest
	public static void parseTest_SameIndexMultipleSections_Success(){
		String str = '<?xmlversion="1.0" encoding="utf-8"?><Chapter permid="igom-gap-1" id="igom-gap-1" edition="10" xml:lang="en"><Section1 permid="igom-permid_0.4171466117622492" id="igom-1" xml:lang="en"><Section1Number>Chapter 1:</Section1Number><Section1Heading>PassengerHandlingProcedures</Section1Heading><Section2 permid="igom-permid_0.7857337828998681" id="igom-1-1.1" rev="changed"><Section2Number>1.1</Section2Number><Section2Heading>PassengerDeparture</Section2Heading></Section2><Section2 permid="igom-permid_0.7857337828998682" id="igom-1-1.1" rev="inserted"><Section2Number>1.1</Section2Number><Section2Heading>PassengerDeparture</Section2Heading></Section2></Section1></Chapter>';
		
		Test.startTest();
		Id manualID = IGOMParser.parse(str);
		Test.stopTest();
		
		Document__c document = [SELECT Effective_Date__c FROM Document__c WHERE Id = :manualID LIMIT 1];
		List<String> firstReminderDateInfo = IGOMConstants.METADATA.REMINDERS_FIRST_DATE.split('/');
		Date effectiveDateInMtd = Date.newInstance(Integer.valueOf(firstReminderDateInfo.get(0)), Integer.valueOf(firstReminderDateInfo.get(1)), Integer.valueOf(firstReminderDateInfo.get(2)));
		System.assertEquals(effectiveDateInMtd, document.Effective_Date__c);
		List<Document_Part__c> procedureFirstLv = [SELECT Id FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.PART AND Document__c = :manualID];
		System.assertEquals(1, procedureFirstLv.size());
		List<Document_Part__c> procedureSecondLv = [SELECT Id, Version_Change_Status__c, Index__c FROM Document_Part__c WHERE Category__c = :IGOMConstants.DOCUMENT_PART.CATEGORY.CHAPTER AND Document__c = :manualID];
		System.assertEquals(2, procedureSecondLv.size());
		
		for(Document_Part__c aProced : procedureSecondLv){
			if(aProced.Version_Change_Status__c == IGOMConstants.DOCUMENT_PART.VERSION_CHANGE_STATUS.NEVV){
				System.assertEquals(1, aProced.Index__c);
			}else{
				System.assertEquals(2, aProced.Index__c);
			}
		}
	}

	/**
	 * @description Method that tests the parse method when there are no sections in the parsed document.
	 */
	@isTest
	public static void parseTest_NoSections_Success(){
		String str = '<?xmlversion="1.0" encoding="utf-8"?><Chapter permid="igom-gap-1" id="igom-gap-1" edition="10" xml:lang="en"></Chapter>';
		
		Id manualID;
		Test.startTest();
		manualID = IGOMParser.parse(str);
		Test.stopTest();
		
		System.assertEquals(null, manualID);
		List<Document_Part__c> procedures = [SELECT Id FROM Document_Part__c];
		System.assertEquals(0, procedures.size());
	}

	/**
	 * @description Method that tests the parse method when there category of the section is not considered.
	 */
	@isTest
	public static void parseTest_CategoryNonExistent_Error(){
		String str = '<?xmlversion="1.0" encoding="utf-8"?><Chapter permid="igom-gap-1" id="igom-gap-1" edition="10" xml:lang="en"><Section1 permid="igom-permid_0.4171466117622492" id="igom-1" xml:lang="en"><Section1Number>Chapter 1:</Section1Number><Section1Heading>PassengerHandlingProcedures</Section1Heading><Section2 permid="igom-permid_0.7857337828998681" id="igom-1-1.1"><Section2Number>1.1</Section2Number><Section2Heading>PassengerDeparture</Section2Heading><Section3 permid="igom-permid_0.6496767700095887" id="igom-1-1.1.1"><Section3Number>1.1.1</Section3Number><Section3Heading>Pre-DepartureActivities</Section3Heading><Section4 permid="igom-permid_0.6146238625670233" id="igom-1-1.1.1.1" rev="changed"><Section4Number>1.1.1.1</Section4Number><Section4Heading>TicketSalesCounter</Section4Heading><Section5 permid="igom-permid_0.6146238625670245" id="igom-1-1.1.1.1.1" rev="changed"><Section5Number>1.1.1.1.1</Section5Number><Section5Heading>5th category level</Section5Heading><Section6 permid="igom-permid_0.6146238625670246" id="igom-1-1.1.1.1.1.1" rev="changed"><Section6Number>1.1.1.1.1.1</Section6Number><Section6Heading>6th category level</Section6Heading><Section7 permid="igom-permid_0.6146238625670247" id="igom-1-1.1.1.1.1.1.1" rev="changed"><Section7Number>1.1.1.1.1.1.1</Section7Number><Section7Heading>7th category level</Section7Heading><Section8 permid="igom-permid_0.6146238625670248" id="igom-1-1.1.1.1.1.1.1.1" rev="changed"><Section8Number>1.1.1.1.1.1.1.1</Section8Number><Section8Heading>8th category level</Section8Heading><Section9 permid="igom-permid_0.6146238625670249" id="igom-1-1.1.1.1.1.1.1.1.1" rev="changed"><Section9Number>1.1.1.1.1.1.1.1.1</Section9Number><Section9Heading>9th category level</Section9Heading></Section9></Section8></Section7></Section6></Section5></Section4></Section3></Section2></Section1></Chapter>';
		
		Test.startTest();
		try {
			Id manualID = IGOMParser.parse(str);
		} catch (IGOMParser.ParsingException pEx) {
			System.assert(pEx.getMessage().contains('Level '));
			System.assert(pEx.getMessage().contains(' is not related to a category, please make sure that the category has the propper values and that a constant has been created for them.'));
		}
		Test.stopTest();
	}
}
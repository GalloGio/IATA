@isTest
public class CodeRangeDAO_Test {
	

	private static IATA_ISO_Country__c c1 = new IATA_ISO_Country__c (Name='ARGENTINA',ISO_Code__c='AR');
	private static IATA_ISO_Country__c c2 = new IATA_ISO_Country__c (Name='FRANCE',ISO_Code__c='FR');
	private static IATA_ISO_Country__c[] ctries = null;

	private static Id programRT  =  RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'IATA_Code_Programs');
    private static Id codeRangeRT  =  RecordTypeSingleton.getInstance().getRecordTypeId('Code_Range__c', 'IATA_Code');
	
    private static AMS_Segment__c p1 = new AMS_Segment__c (label__c='A',RecordTypeId=programRT );


	/**
	 * Setup to prepare data testing.
	 */
	 @testSetup static void setup() {	

	 	ctries = new IATA_ISO_Country__c[]{c1,c2}; 
	 	insert ctries;
	 	
	 	IATA_ISO_State__c stateFR = new IATA_ISO_State__c(IATA_ISO_Country__c=c2.id, NAME='FRANCE',ISO_Code__c='FR');
	 	List<IATA_ISO_State__c> states =  new IATA_ISO_State__c[]{stateFR};
        insert states;

		List<Code_Range__c> codeList = new List<Code_Range__c>();

		codeList.add(new Code_Range__c (Name ='FR1',Area__c=1, Area_Code__c=2,Prefix__c='10',IATA_ISO_Country__c=c2.Id,
                                         IATA_ISO_State__c=stateFR.Id,Max_Range__c=9999,Min_Range__c=1, ProgramCode__c = 'P', program__c=p1.id,RecordTypeId=codeRangeRT));
                                            
        codeList.add(new Code_Range__c (Name ='AR1',Area__c=2, Area_Code__c=2,Prefix__c='17',IATA_ISO_Country__c=c1.Id,
                                        IATA_ISO_State__c=stateFR.Id, Max_Range__c=19,Min_Range__c=0, ProgramCode__c = 'C', program__c=p1.id,RecordTypeId=codeRangeRT));
                                            
        codeList.add(new Code_Range__c (Name ='AR2',Area__c=3, Area_Code__c=3,Prefix__c='17',IATA_ISO_Country__c=c1.Id,
                                        IATA_ISO_State__c=stateFR.Id, Max_Range__c=19,Min_Range__c=0, ProgramCode__c = 'P', program__c=p1.id,RecordTypeId=codeRangeRT));
                                            
		insert codeList;
	}


	/**
	 * Test the method that return a list of the Code_Range__c.
	 */
	@isTest static void testGetAllCodeRanges(){

		Test.startTest();

		List<Code_Range__c> codeRangeList = CodeRangeDAO.getAllCodeRanges();

		System.debug(codeRangeList);

		System.assertEquals(codeRangeList.get(0).Name, '2-10-FR-FR-P-[1-9999]');
		System.assertEquals(codeRangeList.get(1).Name, '2-17-AR-FR-C-[0-19]');
		System.assertEquals(codeRangeList.get(2).Name, '3-17-AR-FR-P-[0-19]');
		System.assertEquals(codeRangeList.size(), 3);

		Test.stopTest();
	}

	/**
	 * Test the method that return a list of the Code_Range__c
	 * filtered by Range Name
	 */
	@isTest static void testGetCodeRangeByName(){
		Test.startTest();


		List<Code_Range__c> codeRangeList = CodeRangeDAO.getCodeRangeByName(new Set<String>{'3-17-AR-FR-P-[0-19]'});

		System.assertEquals(codeRangeList.size(), 1);
		System.assertEquals(codeRangeList.get(0).Max_Range__c, 19);
		System.assertEquals(codeRangeList.get(0).Min_Range__c, 0);
		System.assertEquals(codeRangeList.get(0).Area_Code__c, 3);
		System.assertEquals(codeRangeList.get(0).Prefix__c, '17');


		Test.stopTest();
	}

}
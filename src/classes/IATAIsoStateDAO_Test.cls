@isTest
public class IATAIsoStateDAO_Test {


   	/**
	 * Setup to prepare data testing.
	 *
	 */
	@testSetup static void setup() {	

		IATA_ISO_Country__c country1 = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c = 'PT');
		insert country1;
		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(Name='Brasil', ISO_Code__c = 'BR');
		insert country2;
		IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(Name='Spain', ISO_Code__c = 'SP');
		insert country3;

		List<IATA_ISO_State__c> stateList = new List<IATA_ISO_State__c>();

		stateList.add(new IATA_ISO_State__c(Name='AZORES', ISO_Code__c = 'PT02', IATA_ISO_Country__c = country1.id));
		stateList.add(new IATA_ISO_State__c(Name='MADEIRA', ISO_Code__c = 'PT03', IATA_ISO_Country__c = country1.id));
		stateList.add(new IATA_ISO_State__c(Name='Rio de Janeiro', ISO_Code__c = 'BR-RJ', IATA_ISO_Country__c = country2.id));
		stateList.add(new IATA_ISO_State__c(Name='SPAIN', ISO_Code__c = 'ES01', IATA_ISO_Country__c = country3.id));
		stateList.add(new IATA_ISO_State__c(Name='ABU DHABI', ISO_Code__c = 'AE01', IATA_ISO_Country__c = country3.id));

		insert stateList;
	}

	/**
	 * Test the method that return a list of the IATA_ISO_State__c.
	 * Ordered by State name
	 */
	@isTest static void testGetIsoStates(){

		Test.startTest();
		List<IATA_ISO_State__c> stateList = IATAIsoStateDAO.getIsoStates();
		System.assertEquals(stateList.get(0).Name, 'ABU DHABI');
		System.assertEquals(stateList.get(0).ISO_Code__c, 'AE01');
		System.assertEquals(stateList.get(4).Name, 'SPAIN');
		System.assertEquals(stateList.get(4).ISO_Code__c, 'ES01');
		System.assertEquals(stateList.size(), 5);
		Test.stopTest();
	}


	@isTest static void testGetIsoStatesByIds(){
		Test.startTest();

		IATA_ISO_Country__c country1 = new IATA_ISO_Country__c(Name='Portugal2', ISO_Code__c = 'P');
		insert country1;
		IATA_ISO_Country__c country4 = new IATA_ISO_Country__c(Name='France', ISO_Code__c = 'FR');
		insert country4;

		IATA_ISO_State__c state1 = new IATA_ISO_State__c(Name='PORTUGAL', ISO_Code__c ='PT01', IATA_ISO_Country__c = country1.id);
		insert state1;

		IATA_ISO_State__c state2 = new IATA_ISO_State__c(Name='FRANCE', ISO_Code__c ='FR01', IATA_ISO_Country__c = country4.id);
		insert state2;

		List<IATA_ISO_State__c> stateList = IATAIsoStateDAO.getIsoStatesByIds(new Set<ID>{state1.ID});
		List<IATA_ISO_State__c> stateList2 = IATAIsoStateDAO.getIsoStatesByIds(new Set<String>{state2.ID});

		System.assertEquals(stateList.size(), 1);
		System.assertEquals(stateList.get(0).Name, 'PORTUGAL');
		System.assertEquals(stateList.get(0).ISO_Code__c, 'PT01');

		System.assertEquals(stateList2.size(), 1);
		System.assertEquals(stateList2.get(0).Name, 'FRANCE');
		System.assertEquals(stateList2.get(0).ISO_Code__c, 'FR01');

		Test.stopTest();
	}


	@isTest static void testGetIsoStateByStateName(){
		
		Test.startTest();
		
		Set<String> stateNames = new Set<String>{'ABU DHABI', 'Rio de Janeiro', 'MADEIRA'};
		List<IATA_ISO_State__c> stateList = IATAIsoStateDAO.getIsoStateByStateName(stateNames);

		System.assertEquals(stateList.size(), 3);
		System.assertEquals(stateList.get(0).Name, 'ABU DHABI');
		System.assertEquals(stateList.get(1).Name, 'Rio de Janeiro');
		System.assertEquals(stateList.get(2).Name, 'MADEIRA');

		Test.stopTest();
	}


	/**
	 * 
	 *
	 */
	@isTest static void tesGetIsoStateByIsoCodes(){
		
		Test.startTest();

		Set<String> stateIsoCodes = new Set<String>{'PT03', 'AE01'};	
		List<IATA_ISO_State__c> stateList = IATAIsoStateDAO.getIsoStateByIsoCodes(stateIsoCodes);

		System.assertEquals(stateList.size(), 2);
		System.assertEquals(stateList.get(0).Name, 'MADEIRA');
		System.assertEquals(stateList.get(1).Name, 'ABU DHABI');

		Test.stopTest();
	}

	/**
	 *
	 *
	 */
	@isTest static void testGetIsoStateByStateNameOrderByStateName(){

		Test.startTest();

		Set<String> stateNames = new Set<String>{'MADEIRA', 'Rio de Janeiro', 'ABU DHABI'};	
		
		List<IATA_ISO_State__c> stateList = IATAIsoStateDAO.sortIATAIsoStateList(IATAIsoStateDAO.getIsoStateByStateName(stateNames), 'Name');

		System.assertEquals(stateList.size(), 3);
		System.assertEquals(stateList.get(0).Name, 'ABU DHABI');
		System.assertEquals(stateList.get(1).Name, 'MADEIRA');
		System.assertEquals(stateList.get(2).Name, 'Rio de Janeiro');

		Test.stopTest();
	}

}
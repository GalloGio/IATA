@isTest
public class AMS_ISOCountryTest {
	@TestSetup
	static void makeData(){
		List<Portal_Applications__c> portalApplicationsList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);

		Portal_Applications__c easyPay1 = portalApplicationsList.get(0);
		easyPay1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		easyPay1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		easyPay1.ANG_Accredited_Agents_Only__c = false;
		easyPay1.Agency__c = true;
		easyPay1.Functional_Role__c = 'IATA EasyPay (EDENRED)';
		insert easyPay1;

		Portal_Applications__c easyPay2 = portalApplicationsList.get(1);
		easyPay2.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS;
		easyPay2.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		easyPay2.ANG_Accredited_Agents_Only__c = false;
		easyPay2.Agency__c = true;
		easyPay2.Functional_Role__c = 'IATA EasyPay (MSTS)';
		insert easyPay2;   	
	}

	@isTest
	public static void testCountrySegmentCreation(){
 				
		Test.startTest();
	
		// if I create a new AMS Country, a segment should be created too //Name='TestAMS', 
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
		insert isoc;

		List<IATA_ISO_Country__c> resc = [SELECT Name, ISO_Code__c FROM IATA_ISO_Country__c];
		system.assertEquals(1, resc.size());
		
		Id countryrt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'Country_Area');
		List<AMS_Segment__c> ress = [SELECT ID FROM AMS_Segment__c WHERE RecordTypeId=:countryrt];
		system.assertEquals(1, ress.size());
		
		
		List<AMS_Segment_Country__c> nton = [SELECT Country__c, Segment__c FROM AMS_Segment_Country__c];
		system.assertEquals(1, nton.size());
		system.assertEquals(resc[0].Id, nton[0].Country__c);
		system.assertEquals(ress[0].Id, nton[0].Segment__c);
		
		
		// I'm not allowed to insert again the same ISO Country
		boolean err = false;
		try{
			isoc = new IATA_ISO_Country__c(ISO_code__c='TS');
			insert isoc;
		}catch(Exception e){
			err = true;
		}
		system.assertEquals(true, err);
	}
	
	@isTest
	public static void testStateSegmentCreation(){
 		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(ISO_Code__c = 'TS', Name = 'Test');
		insert isoc;
		
		Test.startTest();
		
		// if I create a new AMS Country, a segment should be created too
		IATA_ISO_State__c amss = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=isoc.Id, Name='TestAMS'); 
		insert amss;
		
		List<IATA_ISO_State__c> resc = [SELECT ID FROM IATA_ISO_State__c];
		system.assertEquals(1, resc.size());
		
		Id statert = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'Country_State_Area');
		List<AMS_Segment__c> ress = [SELECT ID FROM AMS_Segment__c WHERE RecordTypeId=:statert];
		system.assertEquals(1, ress.size());
		
		List<AMS_Segment_Country__c> nton = [SELECT Segment__c, ISO_State__c FROM AMS_Segment_Country__c WHERE Country__c = null];
		system.assertEquals(1, nton.size());
		system.debug('---------------  Query founds nton '+nton[0]);
		system.assertEquals(resc[0].Id, nton[0].ISO_State__c);
		system.assertEquals(ress[0].Id, nton[0].Segment__c);
		
		// if I create again the same AMS Country I won't create any new  segment
		amss = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=isoc.Id, Name='TestAMS');
		insert amss;
	 
		resc = [SELECT ID FROM IATA_ISO_State__c ORDER BY CreatedDate DESC];
		system.assertEquals(2, resc.size());
		
		ress = [SELECT ID FROM AMS_Segment__c WHERE RecordTypeId=:statert];
		system.assertEquals(1, ress.size());
		
		nton = [SELECT Segment__c, ISO_State__c FROM AMS_Segment_Country__c WHERE Country__c = null ORDER BY CreatedDate DESC];
		system.assertEquals(2, nton.size());
		//system.assertEquals(resc[0].Id, nton[0].ISO_State__c);
		//system.assertEquals(ress[0].Id, nton[0].Segment__c);
		
	}

	@isTest
	public static void testPortalApplicationCountryCoverageUpdate() {
			
		Test.startTest();

		Map<String, Portal_Applications__c> portalApplicationMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED, ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS});
		Portal_Applications__c easyPay1 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED);
		Portal_Applications__c easyPay2 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS);

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', 
			ISO_Code__c = 'TS',
			ANG_Portal_Service__c = easyPay1.id);       

		insert isoc;

		String ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c);

		//--------------------

		IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'ST',
			ANG_Portal_Service__c = easyPay1.id);       

		insert isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c + ',' + isoc2.ISO_Code__c);

		//--------------------
		
		isoc2.ISO_Code__c = 'AA';

		update isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c + ',' + isoc2.ISO_Code__c);

		//--------------------

		isoc2.ANG_Portal_Service__c = null;
		isoc2.ISO_Code__c = 'ZZ';

		update isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c);

		//--------------------

		isoc2.ANG_Portal_Service__c = null;

		update isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c);

		//--------------------

		isoc2.ANG_Portal_Service__c = easyPay1.id;
		isoc2.ISO_Code__c = 'XX';

		update isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c + ',' + isoc2.ISO_Code__c);

		//--------------------

		isoc.ANG_Portal_Service__c = null;

		update isoc;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc2.ISO_Code__c);

		//--------------------

		Test.stopTest();

		isoc2.ANG_Portal_Service__c = null;

		update isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, null);

		//--------------------

		IATA_ISO_Country__c isoc3 = new IATA_ISO_Country__c(Name = 'Test3', 
			ISO_Code__c = 'AA',
			ANG_Portal_Service__c = easyPay1.id);

		insert isoc3;

		isoc2.ANG_Portal_Service__c = easyPay1.id;

		update isoc2;
	
		isoc.ANG_Portal_Service__c = easyPay1.id;

		update isoc;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc3.ISO_Code__c + ',' + isoc2.ISO_Code__c + ',' + isoc.ISO_Code__c);

		//--------------------

		isoc3.ANG_Portal_Service__c = null;

		update isoc3;        

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc2.ISO_Code__c + ',' + isoc.ISO_Code__c);

		//--------------------        

		isoc.ANG_Portal_Service__c = null;

		update isoc;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc2.ISO_Code__c);

		//--------------------

		isoc2.ANG_Portal_Service__c = null;

		update isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, null);

		//--------------------

		isoc3.ANG_Portal_Service__c = easyPay1.id;

		update isoc3;

		isoc2.ANG_Portal_Service__c = easyPay1.id;

		update isoc2;
	
		isoc.ANG_Portal_Service__c = easyPay1.id;

		update isoc;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc3.ISO_Code__c + ',' + isoc2.ISO_Code__c + ',' + isoc.ISO_Code__c);

		//--------------------

		isoc.ANG_Portal_Service__c = null;

		update isoc;

		isoc2.ANG_Portal_Service__c = null;

		update isoc2;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc3.ISO_Code__c);

		//-------

		isoc2.ANG_Portal_Service__c = easyPay1.id;        

		update isoc2;

		isoc3.ANG_Portal_Service__c = easyPay2.id;

		update isoc3;

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage, isoc2.ISO_Code__c);

		String ANG_Country_Coverage2 = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay2.id].ANG_Country_Coverage__c;

		System.assertEquals(ANG_Country_Coverage2, isoc3.ISO_Code__c);

	}


	@isTest
	public static void testPortalApplicationCountryCoverageUpdateBulk() {
			
		Test.startTest();

		Map<String, Portal_Applications__c> portalApplicationMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED, ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS});
		Portal_Applications__c easyPay1 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED);
		Portal_Applications__c easyPay2 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS);
	
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', 
			ISO_Code__c = 'TS',
			ANG_Portal_Service__c = easyPay1.id);       


		IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'ST');       


		IATA_ISO_Country__c isoc3 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'BB');       


		insert new List<IATA_ISO_Country__c>{isoc, isoc2, isoc3};

		String ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c);

		Test.stopTest();

	}    

	@isTest
	public static void testPortalApplicationCountryCoverageUpdateBulk2() {
			
		Test.startTest();

		Map<String, Portal_Applications__c> portalApplicationMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED, ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS});
		Portal_Applications__c easyPay1 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED);
		Portal_Applications__c easyPay2 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS);       
	
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', 
			ISO_Code__c = 'TS');       

		IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'ST');       


		IATA_ISO_Country__c isoc3 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'BB');       


		insert new List<IATA_ISO_Country__c>{isoc, isoc2, isoc3};

		String ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, null);

		Test.stopTest();

	}        

	@isTest
	public static void testPortalApplicationCountryCoverageUpdateBulk3() {
			
		Test.startTest();

		Map<String, Portal_Applications__c> portalApplicationMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED, ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS});
		Portal_Applications__c easyPay1 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED);
		Portal_Applications__c easyPay2 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS);      
	
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', 
			ISO_Code__c = 'TS');       

		IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'ST');       


		IATA_ISO_Country__c isoc3 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'BB');       


		insert new List<IATA_ISO_Country__c>{isoc, isoc2, isoc3};

		String ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, null);

		//-------

		isoc.ANG_Portal_Service__c = easyPay1.id;

		update new List<IATA_ISO_Country__c>{isoc, isoc2, isoc3};

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c);

		Test.stopTest();
	}

	@isTest
	public static void testPortalApplicationCountryCoverageUpdateBulk4() {

		Test.startTest();

		Map<String, Portal_Applications__c> portalApplicationMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED, ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS});
		Portal_Applications__c easyPay1 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED);
		Portal_Applications__c easyPay2 = portalApplicationMap.get(ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_MSTS);      
	
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', 
			ISO_Code__c = 'TS',
			ANG_Portal_Service__c = easyPay1.id);       

		IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'ST',
			ANG_Portal_Service__c = easyPay1.id);       

		IATA_ISO_Country__c isoc3 = new IATA_ISO_Country__c(Name = 'Test2', 
			ISO_Code__c = 'BB',
			ANG_Portal_Service__c = easyPay2.id);       


		insert new List<IATA_ISO_Country__c>{isoc, isoc2, isoc3};

		String ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c + ',' + isoc2.ISO_Code__c);


		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay2.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, isoc3.ISO_Code__c);

		//-------

		IATA_ISO_Country__c isoc4 = new IATA_ISO_Country__c(Name = 'Test4', 
			ISO_Code__c = 'CC',
			ANG_Portal_Service__c = easyPay1.id);


		upsert new List<IATA_ISO_Country__c>{isoc, isoc2, isoc3, isoc4};

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c + ',' + isoc2.ISO_Code__c + ',' + isoc4.ISO_Code__c);

		isoc.ANG_Portal_Service__c = null;
		isoc3.ANG_Portal_Service__c = null;

		upsert new List<IATA_ISO_Country__c>{isoc, isoc2, isoc3, isoc4};

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, isoc2.ISO_Code__c + ',' + isoc4.ISO_Code__c);

		ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay2.id].ANG_Country_Coverage__c;

		System.debug('ANG_Country_Coverage-->' + ANG_Country_Coverage);

		System.assertEquals(ANG_Country_Coverage, null);

		Test.stopTest();
	}    
}
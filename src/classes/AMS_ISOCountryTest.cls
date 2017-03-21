@isTest
public class AMS_ISOCountryTest {
	
    public static testmethod void testCountrySegmentCreation(){
 		        
        Test.startTest();
    
        // if I create a new AMS Country, a segment should be created too //Name='TestAMS', 
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        List<IATA_ISO_Country__c> resc = [SELECT Name, ISO_Code__c FROM IATA_ISO_Country__c];
        system.assertEquals(1, resc.size());
        
        Id countryrt = Schema.getGlobalDescribe().get('AMS_Segment__c').getDescribe().getRecordTypeInfosByName().get('Country Area').getRecordTypeId();
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
    
    public static testmethod void testStateSegmentCreation(){
 		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(ISO_Code__c = 'TS', Name = 'Test');
        insert isoc;
        
        Test.startTest();
        
        // if I create a new AMS Country, a segment should be created too
        system.debug('---------------  AAAAAAAAAAAAAAAAAAA --------------------');
        IATA_ISO_State__c amss = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=isoc.Id, Name='TestAMS'); 
        insert amss;
        
        List<IATA_ISO_State__c> resc = [SELECT ID FROM IATA_ISO_State__c];
        system.assertEquals(1, resc.size());
        
        Id statert = Schema.getGlobalDescribe().get('AMS_Segment__c').getDescribe().getRecordTypeInfosByName().get('Country State Area').getRecordTypeId();
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

    public static testmethod void testPortalApplicationCountryCoverageUpdate() {
            
        Test.startTest();

        Portal_Applications__c easyPay1 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false
            );

        insert easyPay1;
    
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', 
            ISO_Code__c = 'TS',
            ANG_Portal_Service__c = easyPay1.id);       

        insert isoc;

        String ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

        System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c);

        IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', 
            ISO_Code__c = 'ST',
            ANG_Portal_Service__c = easyPay1.id);       

        insert isoc2;

        ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

        System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c + ',' + isoc2.ISO_Code__c);
        
        isoc2.ISO_Code__c = 'AA';

        update isoc2;

        ANG_Country_Coverage = [SELECT ANG_Country_Coverage__c FROM Portal_Applications__c WHERE id =: easyPay1.id].ANG_Country_Coverage__c;

        System.assertEquals(ANG_Country_Coverage, isoc.ISO_Code__c + ',' + isoc2.ISO_Code__c);

        Test.stopTest();
    }
}
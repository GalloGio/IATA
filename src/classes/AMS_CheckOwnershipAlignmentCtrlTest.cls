@isTest
public class AMS_CheckOwnershipAlignmentCtrlTest {

    
    @testSetup static void insertDummyData() {

        
       System.debug('inserting dummy data');
        Id ownerRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        Id agencyownershipId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'suzilandia', region__c = 'aaa', ISO_Code__c= '21', ISO_Code_Numeric__c = 212,CurrencyIsoCode = 'AUD'); 
        insert country;
        
        
        //------------INSERT GOOD DATA TO VALIDATE-----------
        //insert account HO
        Account acc = new Account();
        acc.iatacode__c = '876543';
        acc.Location_type__c = 'HO';
        acc.Location_class__c = 'P';
        acc.iata_iso_country__c= country.id;
        acc.name = 'name_OWNERSHIP Well';
        acc.recordtypeid = agencyownershipId;
        
        insert acc;
       system.debug('## acc: '+acc);
        
		
		/*
        Contact c = new Contact();
        c.Email = 'randomwell@email.com';
        c.LastName = ' rnadom cenas';
        c.FirstName = 'Contact Well ';
        
       system.debug('## Going to insert! '+c);
        insert c;
        
       system.debug('## contact: '+c);
        
        //insert 3 accounts BR
        List<Account> accBRS = new List<Account>();
        Account accBR = new Account();
        for (Integer i=0; i<3; i++){
            accBR = new Account();
            accBR.iatacode__c = '876543'+i;
            accBR.Location_type__c = 'BR';
            accBR.Location_class__c = 'P';
            accBR.iata_iso_country__c= country.id;
            accBR.name = 'BRname_OWNERSHIP-WELL'+i;
            accBR.recordtypeid = agencyownershipId;
            accBR.Top_Parent__c = acc.id;
            accBR.ParentId = acc.id;
            accBRs.add(accBR);
        }
        insert accBRs;
       system.debug('## accBR: '+accBRs);
        
        //insert owners
        AMS_Account_Role__c owner = new AMS_Account_Role__c();
        owner.contact__c = c.id;
        owner.Account__c = acc.id;
        owner.recordtypeid = ownerRecTypeId;
        insert owner;
        
        AMS_Account_Role__c owner1 = new AMS_Account_Role__c();
        owner1.contact__c = c.id;
        owner1.Account__c = accBrs[0].id;
        owner1.recordtypeid = ownerRecTypeId;
        insert owner1;
        
        AMS_Account_Role__c owner2 = new AMS_Account_Role__c();
        owner2.contact__c = c.id;
        owner2.Account__c = accBrs[1].id;
        owner2.recordtypeid = ownerRecTypeId;
        insert owner2;
        
        AMS_Account_Role__c owner3 = new AMS_Account_Role__c();
        owner3.contact__c = c.id;
        owner3.Account__c = accBrs[2].id;
        owner3.recordtypeid = ownerRecTypeId;
        insert owner3;
        
       system.debug('## owner: '+owner);
        
        //------------INSERTING BAD DATA TO VALIDATE----------------
       
        
        //-----------INSERT BAD OWNER IN THIRD LEVEL-------------
          
//insert account HO
        Account accBad = new Account();
        accBad.iatacode__c = '2222222';
        accBad.Location_type__c = 'HO';
        accBad.Location_class__c = 'P';
        accBad.iata_iso_country__c= country.id;
        accBad.name = 'name_OWNERSHIP-BAD';
        accBad.recordtypeid = agencyownershipId;
        insert accBad;        
                
  
        //insert 3 Contacts
        Contact contactBad = new Contact();
        contactBad.Account = accBad;
        contactBad.Email = 'Bad' +'@email.com';
        contactBad.LastName = ' bad';
        contactBad.FirstName = 'contact Bad ';
        insert contactBad;
        
        Contact contactBad1 = new Contact();
        contactBad1.Account = accBad;
        contactBad1.Email = 'bad1' + '@email.com';
        contactBad1.LastName = ' bad';
        contactBad1.FirstName = 'Contact Bad1 ';
        insert contactBad1;

		Contact contactBad2 = new Contact();
        contactBad2.Account = accBad;
        contactBad2.Email = 'bad2' + '@email.com';
        contactBad2.LastName = ' bad';
        contactBad2.FirstName = 'Contact Bad2 ';
        insert contactBad2;

        //insert 3 accounts BR
        List<Account> accBRBadS = new List<Account>();
        for (Integer i=0; i<3; i++){
          Account accBRBad = new Account();
          accBRBad.iatacode__c = '2222222'+i;
          accBRBad.Location_type__c = 'BR';
          accBRBad.Location_class__c = 'P';
          accBRBad.iata_iso_country__c= country.id;
          accBR.recordtypeid = agencyownershipId;
          accBRBad.Top_Parent__c = accBad.id;
          accBRBad.name = 'BRname_OWNERSHIP-BAD-'+i;
          accBRBad.parentId = accBad.id;
          accBRBads.add(accBRBad); 
        }
        insert accBRBads;
        
        //insert 3 accounts BR in BR
        List<Account> accBROfBRBadS = new List<Account>();
        for (Integer i=0; i<3; i++){
          Account accBRBad = new Account();
          accBRBad.iatacode__c = '22222220'+i;
          accBRBad.Location_type__c = 'BR';
          accBRBad.Location_class__c = 'P';
          accBRBad.iata_iso_country__c= country.id;
          accBRBad.name = 'BRname_OWNERSHIP-BR-BAD-'+i;
          accBRBad.recordtypeid = agencyownershipId;
          accBRBad.Top_Parent__c = accBad.id;
          accBRBad.ParentId = accBRBads[0].id;
          accBROfBRBadS.add(accBRBad); 
        }
        insert accBROfBRBadS;
        
        //insert owners 
        AMS_Account_Role__c badOwner = new AMS_Account_Role__c();
        badOwner.contact__c = contactBad.id;
        badOwner.Account__c = accBad.id;
        badOwner.recordtypeid = ownerRecTypeId;
        insert badOwner;

		badOwner = new AMS_Account_Role__c();
        badOwner.contact__c = contactBad1.id;
        badOwner.Account__c = accBad.id;
        badOwner.recordtypeid = ownerRecTypeId;
        insert badOwner;
        
        AMS_Account_Role__c badOwner1 = new AMS_Account_Role__c();
        badOwner1.contact__c = contactBad.id;
        badOwner1.Account__c = accBrBads[0].id;
        badOwner1.recordtypeid = ownerRecTypeId;
        insert badOwner1;
        
        AMS_Account_Role__c badOwner2 = new AMS_Account_Role__c();
        badOwner2.contact__c = contactBad.id;
        badOwner2.Account__c = accBrBads[1].id;
        badOwner2.recordtypeid = ownerRecTypeId;
        insert badOwner2;
        
        AMS_Account_Role__c badOwner3 = new AMS_Account_Role__c();
        badOwner3.contact__c = contactBad.id; 
        badOwner3.Account__c = accBrBads[2].id;
        badOwner3.recordtypeid = ownerRecTypeId;
        insert badOwner3;

		AMS_Account_Role__c badOwner4 = new AMS_Account_Role__c();
        badOwner4.contact__c = contactBad1.id; 
        badOwner4.Account__c = accBrBads[0].id;
        badOwner4.recordtypeid = ownerRecTypeId;
        insert badOwner4;

		AMS_Account_Role__c badOwner5 = new AMS_Account_Role__c();
        badOwner5.contact__c = contactBad1.id; 
        badOwner5.Account__c = accBrBads[1].id;
        badOwner5.recordtypeid = ownerRecTypeId;
        insert badOwner5;
        
		AMS_Account_Role__c badOwner6 = new AMS_Account_Role__c();
        badOwner6.contact__c = contactBad1.id; 
        badOwner6.Account__c = accBrBads[2].id;
        badOwner6.recordtypeid = ownerRecTypeId;
        insert badOwner6;

        //owners for brs of brs (1 bad)
        AMS_Account_Role__c badOwnerBR1 = new AMS_Account_Role__c();
        badOwnerBR1.contact__c = contactBad.id;
        badOwnerBR1.Account__c = accBROfBRBadS[0].id;
        badOwnerBR1.recordtypeid = ownerRecTypeId;
        insert badOwnerBR1;
        
        AMS_Account_Role__c badOwnerBR2 = new AMS_Account_Role__c();
        badOwnerBR2.contact__c = contactBad.id;
        badOwnerBR2.Account__c = accBROfBRBadS[1].id;
        badOwnerBR2.recordtypeid = ownerRecTypeId;
        insert badOwnerBR2;
        
        AMS_Account_Role__c badOwnerBR3 = new AMS_Account_Role__c();
        badOwnerBR3.contact__c = contactBad.id; 
        badOwnerBR3.Account__c = accBROfBRBadS[2].id;
        badOwnerBR3.recordtypeid = ownerRecTypeId;
        insert badOwnerBR3;

        AMS_Account_Role__c badOwnerBR4 = new AMS_Account_Role__c();
        badOwnerBR4.contact__c = contactBad1.id; 
        badOwnerBR4.Account__c = accBROfBRBadS[0].id;
        badOwnerBR4.recordtypeid = ownerRecTypeId;
        insert badOwnerBR4;

        AMS_Account_Role__c badOwnerBR5 = new AMS_Account_Role__c();
        badOwnerBR5.contact__c = contactBad1.id; 
        badOwnerBR5.Account__c = accBROfBRBadS[1].id;
        badOwnerBR5.recordtypeid = ownerRecTypeId;
        insert badOwnerBR5;

        AMS_Account_Role__c badOwnerBR6 = new AMS_Account_Role__c();
        badOwnerBR6.contact__c = contactBad2.id; 
        badOwnerBR6.Account__c = accBROfBRBadS[2].id;
        badOwnerBR6.recordtypeid = ownerRecTypeId;
        insert badOwnerBR6;
        
		system.debug('## done inserting!');
		*/
	}
    
    @isTest()
    static void validateDummyDataHierarchy() {
		
		Test.startTest();        
        
        AMS_CheckOwnershipAlignmentController ctrl = new AMS_CheckOwnershipAlignmentController();
        ctrl.qRegion = 'aaa';
        ctrl.email = 'aaa@dummy.dummy';
        ctrl.checkowners();
        System.assertEquals(ctrl.getROptions().size(), 10);
        AMS_CheckOwnershipAlignmentBatch b = new AMS_CheckOwnershipAlignmentBatch('aaa','aaa@dummy.dummy');
        DataBase.executeBatch(b);

        Test.stopTest();
        
        
        
        /*
        Boolean badDataFound = false;
        System.Debug('here: ' + ctrl.iataCodesinError);
        for (String error : ctrl.iataCodesinError){
        	System.assertNotEquals('876543', error);  
            if(error == '1111111') //found bad data
                badDataFound = true;
        }
        System.assert(badDataFound);
        System.assert(!ctrl.getROptions().isEmpty());*/
    }
}
@isTest
private class AMS_IataCodeRangesLoaderCtrlTest {
	/* Does not work with System Email Only setting for Email Deliverability, but works fine with All Email option selected */
	
    @testSetup static void setup(){
        IATA_ISO_Country__c c1 = new IATA_ISO_Country__c (Name='ARGENTINA',ISO_Code__c='AR');
        IATA_ISO_Country__c c2 = new IATA_ISO_Country__c (Name='FRANCE',ISO_Code__c='FR');
        IATA_ISO_Country__c c3 = new IATA_ISO_Country__c (Name='U.S.',ISO_Code__c='US');
        IATA_ISO_Country__c c4 = new IATA_ISO_Country__c (Name='AUSTRALIA',ISO_Code__c='AU');
        IATA_ISO_Country__c c5 = new IATA_ISO_Country__c (Name='AUSTRIA',ISO_Code__c='AT');
        IATA_ISO_Country__c c6 = new IATA_ISO_Country__c (Name='CHILE',ISO_Code__c='CL');
        IATA_ISO_Country__c c7 = new IATA_ISO_Country__c (Name='COLOMBIA',ISO_Code__c='CO');
        IATA_ISO_Country__c[] ctries =  new IATA_ISO_Country__c[]{c1,c2,c3,c4,c5,c6,c7};
        insert ctries;

        IATA_ISO_State__c stateTX = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.Id, NAME='TEXAS',ISO_Code__c='TX');
        IATA_ISO_State__c stateCA = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='CALIFORNIA',ISO_Code__c='CA');
        IATA_ISO_State__c stateAL = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='ALABAMA',ISO_Code__c='AL');    
        IATA_ISO_State__c[] states =  new IATA_ISO_State__c[]{stateTX,stateCA,stateAL};
        insert states;
    }
    
    @isTest static void test_AMS_IataCodeRangesLoaderCtrl() {

        String doc = 'Area;Country code;Area Code;Country;0999;1999;2999;3999;4999;5999;6999;7999;8999;9999\r\n3;1;3;AFGHANISTAN;Pax/Cargo;Pax/Cargo;Pax/Cargo;Pax/Cargo;Pax/Cargo;Pax/Cargo;Pax/Cargo;P/C/Cass;GSAs;MSOs\r\n1;55;5;ARGENTINA;Pax;Pax;Pax;Pax;Pax;Pax;Pax;Pax;Pax;Pax';
        Blob myBlob = Blob.valueof(doc);

        Test.startTest();
        AMS_IataCodeRangesLoaderCtrl2 ctrl = new AMS_IataCodeRangesLoaderCtrl2();
        ctrl.csvFileBody = myBlob;
        ctrl.importCSVFile();
        ctrl.saveRecord();

        doc+='2;6;2;AUSTRIA;Agents;Agents;Agents;Agents;Agents;Agents;Agents;Agents;Agents;Agents\r\n2;5;4;ALABAMA;;;;;;Cass;Cass;Cargo;GSAs;MSOs\r\n-1;-59;-1;FRANCE;Cargo;Cargo;Cargo;Cargo;Cargo;Cargo;Cargo;Cargo;Cargo;Cass';
        myBlob = Blob.valueOf(doc);
        ctrl.csvFileBody = myBlob;
        ctrl.importCSVFile();

        Test.stopTest();
    }

    @isTest static void test_AMS_IataCodeRangesLoaderCtrl3() {


//        Country Code                (AF)
//        Country Description         (AFGHANISTAN)
//        State Code                  (AF01)
//        State Description           (AFGHANISTAN)
//        Country State Code          (AF)
//        State Number                (1)
//        Class Code                  (C)
//        Class Description           (CARGO)
//        Prefix                      (1)
//        MIN Area Code               (3)
//        MIN Last four               (1)
//        MAX Area Code               (3)
//        MAX Last four               (6999)
//        MIN-MAX area code differ?   (blank or DIFF)

        String doc =    'Country Code;Country Description;State Code;State Description;Country State Code;State Number;Class Code;Class Description;Prefix;MIN Area Code;MIN Last four;MAX Area Code;MAX Last four;MIN-MAX area code differ?'+
                        '\r\nAF;AFGHANISTAN;AF01;AFGHANISTAN;AF;1;C;CARGO;1;3;1;3;6999;blank'+
                        '\r\nAR;ARGENTINA;AR02;ARGENTINA;AR;2;P;PAX;1;3;1;3;6999;DIFF'+
                        '\r\nUS;USA;AL;ALABAMA;AL;2;P;PAX;1;3;1;3;6999;DIFF'+
                        '\r\nUS;USA;TX;TEXAS;TX;2;P; ;1;3;1;3;6999;DIFF'+
                        '\r\ninvalid;line';

        for(Integer i = 0; i <200; i++) doc += '\r\nAR;ARGENTINA;AR'+i+';ARGENTINA;AR'+i+';2;C;CARGO'+i+';1;3;'+i+';3;'+(5000+1)+';blank';

        Blob myBlob = Blob.valueof(doc);

        Test.startTest();
        AMS_IataCodeRangesLoaderCtrl3 ctrl = new AMS_IataCodeRangesLoaderCtrl3();

        //test error
        ctrl.parseLines();
        ctrl.importCSVFile();

        //test sucess
        ctrl.csvFileBody = myBlob;
        ctrl.importCSVFile();
        ctrl.saveRecord();

        doc+='FR;FRANCE;FR03;FRANCE;FR;3;C;CARGO;1;3;1;3;6999;blank\r\nUS;U.S.;TEXAS;U.S.;TEXAS;4;P;PAX;1;3;1;3;6999;DIFF';
        myBlob = Blob.valueOf(doc);
        ctrl.csvFileBody = myBlob;
        ctrl.importCSVFile();

        Test.stopTest();
    }
}
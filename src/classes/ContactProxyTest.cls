@isTest
private class ContactProxyTest {

    static testMethod void test_AllMethod(){
    
        IDCardTestData idcarddata = new IDCardTestData();
        Contact con = idcarddata.IDCard_Contacts[0];
        con.Revenue_Confirmation__c = false;
        con.AgencyShare_Confirmation__c = false;
        con.Date_of_Birth__c = Date.today().addYears(-35);
        insert con;
        ContactProxy cp = new ContactProxy(con);
        cp.addApplication(idcarddata.IDCards_IDCardApplications[0]);
        cp.addIDcard(createIDCard());
        cp.error = 'error';
        cp.selected = true;
        cp.applicationType = 'New';
        cp.Photo = 'photo';
        cp.getHasPhoto();
    	cp.IATACode = '12312312';
      	cp.previousIATACode = '12312312';
    	cp.country = 'Portugal';

        ContactProxy.copyValuesToTargetContact(idcarddata.IDCard_Contacts[0],idcarddata.IDCard_Contacts[0]);  
        cp.CloneWithoutId();
        cp.printCSVrow();
        cp.ProxyToContact(true);
        cp.getUniqueId();
        ContactProxy.getUniqueId(con);
        cp.getUniqueIdPreviousIATAcode();
        ContactProxy.getUniqueQuery(con);
        ContactProxy.clean('123123');
        ContactProxy.printCSVheader();
        String st1 = '1';
        String st2 = '1';
        String st3 = '2';
        String st4 = '1980-08-08';
        String st5 = '1';
        String st6 = '1';
        String st7 = '1';
        String st8 = '1';
        String st9 = '1';
        String st10 = '1';
       	String st11 = '1';
        String st12 = '1';
        String st13 = '1';
        String st14 = '1';
        String st15 = 'True';
        String st16 = 'True';
        String st17 = '1';
        String st18 = '1';
        String st19 = '1';
        String st20 = '1';
        String st21 = '1';
        String st22 = '1';
        List<String> rows = new List<String>();
        rows.add(st1);
        rows.add(st2);
        rows.add(st3);
        rows.add(st4);
        rows.add(st5);
        rows.add(st6);
        rows.add(st7);
        rows.add(st8);
        rows.add(st9);
        rows.add(st10);
        rows.add(st11);
        rows.add(st12);
        rows.add(st13);
        rows.add(st14);
        rows.add(st15);
        rows.add(st16);
        rows.add(st17);
        rows.add(st18);
        rows.add(st19);
        rows.add(st20);
        rows.add(st21);
        rows.add(st22);       
        
        ContactProxy cp1 = new ContactProxy(rows);
    }
    
    static ID_Card__c createIDCard(){
            
                    ID_Card__c newIdCard = new ID_Card__c ( 
                    FirstName__c = 'first'
                    , LastName__c = 'LastName' 
                    , Name_on_ID_Card__c = 'name on card'                                    
                    , Card_Status__c = 'Sent ID Card'
                    , Blacklisted__c = false
                    , Valid_To_Date__c = Date.today().addMonths(5)
                    , Title__c = 'Mr.'
                    , Gender__c = 'M'
                    , Position__c = 'Sales'
                    , Hours_per_week__c = '35'
                    , Duties__c = 'Sales'
                    , Start_Date_Agency_Month__c = 'March'
                    , Start_Date_Agency_Year__c = '2010'
                    );
                insert newIdCard;
        return newIdCard;
           
      
         

}
}
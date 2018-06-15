public with sharing class IDCardTestData{
    
    public list<Account> IDCard_Accounts;
    public list<Account> IDCard_keyAccounts;
    public list<Contact> IDCard_Contacts;
    public list<ID_Card__c> IDCard_Cards;
    public list<ID_Card_Application__c> IDCards_IDCardApplications;
    //public list<Area_Counter__c> IDCards_Area_Counters;
    public list<Price_Table__c> IDCards_Price_Tables;
    public list<IATA_ISO_Country__c> IDCards_IATAISOCountries;
    public list<Promotion__c> IDCards_Promotions;
    
    public IDCardTestData() {
                
        IDCard_Accounts = new list<Account>();
        IDCard_keyAccounts = new list<Account>();
        IDCard_Contacts = new list<Contact>();
        IDCard_Cards = new list<ID_Card__c>();
        IDCards_IDCardApplications = new list<ID_Card_Application__c>();
        //IDCards_Area_Counters = new List<Area_Counter__c> ();
    	IDCards_Price_Tables = new List<Price_Table__c>();
    	IDCards_IATAISOCountries = new List<IATA_ISO_Country__c>(); 
        IDCards_Promotions = new List<Promotion__c>();
        
        //List of Account Data 
        Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcont = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        
        
        Account account1 = new Account();
        account1.RecordTypeId = rtidca;
        account1.Name = 'ADAM TRAVEL SERVICES INC.';
        account1.IATACode__c = '67504242';
        account1.Industry = 'Travel Agent';
        account1.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account1.Status__c = 'Approved';
        account1.BillingStreet = '5056 FAIRVIEW STREET';
        account1.BillingCity = 'BURLINGTON';
        account1.BillingCountry = 'CANADA';
        account1.BillingPostalCode = ' L7L 0B4';
        account1.Is_AIMS_Account__c = true;
        
        Account account2 = new Account();
        account2.RecordTypeId = rtidca;
        account2.Name = 'ADAMA TRAVEL SERVICES INC.';
        account2.IATACode__c = '4242424';
        account2.Industry = 'Travel Agent';
        account2.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account2.Status__c = 'Approved';
        account2.BillingStreet = '5056 FAIRVIEW STREET';
        account2.BillingCity = 'BURLINGTON';
        account2.BillingCountry = 'CANADA';
        account2.BillingPostalCode = ' L7L 0B4';
        account2.Is_AIMS_Account__c = true;
        
        Account account3 = new Account();
        account3.RecordTypeId = rtidca;
        account3.Name = 'ADAMB TRAVEL SERVICES INC.';
        account3.IATACode__c = '85500100';
        account3.Industry = 'Travel Agent';
        account3.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account3.Status__c = 'Approved';
        account3.BillingStreet = '5056 FAIRVIEW STREET';
        account3.BillingCity = 'BURLINGTON';
        account3.BillingCountry = 'CANADA';
        account3.BillingPostalCode = ' L7L 0B4';
        account3.Is_AIMS_Account__c = true;
        
        Account account4 = new Account();
        account4.RecordTypeId = rtidca;
        account4.Name = 'ADAMA TRAVEL SERVICES INC.';
        account4.IATACode__c = '1111111';
        account4.Industry = 'Travel Agent';
        account4.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account4.Status__c = 'Terminated';
        account4.BillingStreet = '5056 FAIRVIEW STREET';
        account4.BillingCity = 'BURLINGTON';
        account4.BillingCountry = 'CANADA';
        account4.BillingPostalCode = ' L7L 0B4';
        account4.Is_AIMS_Account__c = true;
        
        
        Account account5 = new Account();
        account5.RecordTypeId = rtidca;
        account5.Name = 'KeyAccount Limited.';
        account5.IATACode__c = '01254785';
        account5.Industry = 'Travel Agent';
        account5.IDCard_Key_Account__c = true;
        account5.ID_Card_Key_Account_Discount__c = 10;
        account5.ID_Card_KeyAccount_features__c = IDCardUtil.Key_Account_Feature_Only_KC_Purchase;
        account5.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account5.Status__c = 'Approved';
        account5.BillingStreet = '5056 FAIRVIEW STREET';
        account5.BillingCity = 'BURLINGTON';
        account5.BillingCountry = 'CANADA';
        account5.BillingPostalCode = ' L7L 0B4';
        account5.Is_AIMS_Account__c = true;
        
        
    	Account account6 = new Account();
        account6.RecordTypeId = rtidca;
        account6.Name = 'KeyAccount unLimited.';
        account6.IATACode__c = '01254785';
        account6.Industry = 'Travel Agent';
        account6.IDCard_Key_Account__c = true;
        account6.ID_Card_Key_Account_Discount__c = 0;
        //account6.ID_Card_KeyAccount_features__c = IDCardUtil.Key_Account_Feature_Only_KC_Purchase;
        account6.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account6.Status__c = 'Approved';
        account6.BillingStreet = '5056 FAIRVIEW STREET';
        account6.BillingCity = 'BURLINGTON';
        account6.BillingCountry = 'CANADA';
        account6.BillingPostalCode = ' L7L 0B4';
        account6.Is_AIMS_Account__c = true;
        
        Account account7 = new Account();
        account7.RecordTypeId = rtidca;
        account7.Name = 'KeyAccount unLimited.';
        account7.IATACode__c = '1234567';
        account7.Industry = 'Travel Agent';
        account7.IDCard_Key_Account__c = true;
        account7.ID_Card_Key_Account_Discount__c = 0;
        //account6.ID_Card_KeyAccount_features__c = IDCardUtil.Key_Account_Feature_Only_KC_Purchase;
        account7.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account7.Status__c = 'Approved';
        account7.BillingStreet = '1200 CHINA STREET';
        account7.BillingCity = 'CHINA TOWN';
        account7.BillingCountry = 'PEOPLE\'S REPUBLIC OF CHINA';
        account7.BillingPostalCode = ' L7L 0B4';
        account7.Is_AIMS_Account__c = true;
        
        // List of Contact Data
        
        Contact contact1 = new Contact();
        contact1.LastName = 'UserOne';
        contact1.FirstName = 'ContactOne';
        contact1.RecordTypeId = rtcont;
                    
        // List of IDCardApplication 
        
        // Inactive account 
        ID_Card_Application__c inactiveAccount = new ID_Card_Application__c();      
        inactiveAccount.Date_of_Birth__c = date.newInstance(1980, 1, 1);      
        inactiveAccount.First_Name__c = 'NoFirstName';            
        inactiveAccount.IATA_Code__c = '11111111';    
        inactiveAccount.Last_Name__c = 'NoLastName';
        
        // Multiple agent account
        ID_Card_Application__c multipleAgentAccount = new ID_Card_Application__c();      
        multipleAgentAccount.Date_of_Birth__c = date.newInstance(1980, 1, 1);      
        multipleAgentAccount.First_Name__c = 'David';            
        multipleAgentAccount.IATA_Code__c = '4242424';    
        multipleAgentAccount.Last_Name__c = 'Simard';  
        multipleAgentAccount.Approving_Manager_s_Name__c = 'Manager Name';
        multipleAgentAccount.Approving_Manager_s_Email__c = 'manager@email.com';        
        multipleAgentAccount.Duties_in_Current_Agency__c = 'Administration';
        multipleAgentAccount.Email_admin__c = 'johnsonk@iata.org';        
        multipleAgentAccount.Gender__c = 'M';
        multipleAgentAccount.Hours_worked__c = '35h or more';       
        multipleAgentAccount.IDCard_Expedite_Delivery__c  = false;       
        multipleAgentAccount.Middle_Initial__c = 'K';
        multipleAgentAccount.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        multipleAgentAccount.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        multipleAgentAccount.Position_in_Current_Agency__c = 'Director';
        multipleAgentAccount.Revenue_Confirmation__c = true;
        multipleAgentAccount.Solicitation_Flag__c = false;
        multipleAgentAccount.Start_Date_Agency_Month__c = 'January';
        multipleAgentAccount.Start_Date_Agency_Year__c = '2003';
        multipleAgentAccount.Start_Date_Industry__c = '2000';
        multipleAgentAccount.Telephone__c = '5145550001';
        multipleAgentAccount.Title__c = 'Mrs.';
        multipleAgentAccount.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;        
        multipleAgentAccount.Promotion_Code__c = 'Inv';
        multipleAgentAccount.Displayed_Name__c = 'ContactOne UserOne';
        
        // Multiple agent account
        ID_Card_Application__c multipleAgentAccountChangeName = new ID_Card_Application__c(); 
        multipleAgentAccountChangeName.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REPLACEMENT;
        multipleAgentAccountChangeName.Date_of_Birth__c = date.newInstance(1980, 1, 1);      
        multipleAgentAccountChangeName.First_Name__c = 'Davidd';            
        multipleAgentAccountChangeName.IATA_Code__c = '85500100';    
        multipleAgentAccountChangeName.Last_Name__c = 'Simardd';  
        multipleAgentAccountChangeName.Approving_Manager_s_Name__c = 'Manager Name';
        multipleAgentAccountChangeName.Approving_Manager_s_Email__c = 'manager@email.com';        
        multipleAgentAccountChangeName.Duties_in_Current_Agency__c = 'Administration';
        multipleAgentAccountChangeName.Email_admin__c = 'johnsonk@iata.org';        
        multipleAgentAccountChangeName.Gender__c = 'M';
        multipleAgentAccountChangeName.Hours_worked__c = '35h or more';       
        multipleAgentAccountChangeName.IDCard_Expedite_Delivery__c  = false;       
        multipleAgentAccountChangeName.Middle_Initial__c = 'K';
        multipleAgentAccountChangeName.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        multipleAgentAccountChangeName.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        multipleAgentAccountChangeName.Position_in_Current_Agency__c = 'Director';
        multipleAgentAccountChangeName.Revenue_Confirmation__c = true;
        multipleAgentAccountChangeName.Solicitation_Flag__c = false;
        multipleAgentAccountChangeName.Start_Date_Agency_Month__c = 'January';
        multipleAgentAccountChangeName.Start_Date_Agency_Year__c = '2003';
        multipleAgentAccountChangeName.Start_Date_Industry__c = '2000';
        multipleAgentAccountChangeName.Telephone__c = '5145550001';
        multipleAgentAccountChangeName.Title__c = 'Mrs.';
        multipleAgentAccountChangeName.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;        
        multipleAgentAccountChangeName.Promotion_Code__c = 'Inv';
        multipleAgentAccountChangeName.Displayed_Name__c = 'ContactOne UserOne';
        
        
        //New Application Record
        ID_Card_Application__c IDCardApplication1 = new ID_Card_Application__c();
        IDCardApplication1.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication1.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication1.Date_of_Birth__c = date.newInstance(1980, 1, 1);
        IDCardApplication1.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication1.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication1.First_Name__c = 'ContactOne';
        IDCardApplication1.Gender__c = 'M';
        IDCardApplication1.Hours_worked__c = '35h or more';        
        IDCardApplication1.IATA_Code__c = '67504242';
        IDCardApplication1.IDCard_Expedite_Delivery__c  = false;
        IDCardApplication1.Last_Name__c = 'UserOne';
        IDCardApplication1.Middle_Initial__c = 'K';
        IDCardApplication1.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        IDCardApplication1.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        IDCardApplication1.Position_in_Current_Agency__c = 'Director';
        IDCardApplication1.Revenue_Confirmation__c = true;
        IDCardApplication1.Solicitation_Flag__c = false;
        IDCardApplication1.Start_Date_Agency_Month__c = 'January';
        IDCardApplication1.Start_Date_Agency_Year__c = '2003';
        IDCardApplication1.Start_Date_Industry__c = '2000';
        IDCardApplication1.Telephone__c = '5145550001';
        IDCardApplication1.Title__c = 'Mrs.';
        IDCardApplication1.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        IDCardApplication1.UIR__c = '';
        IDCardApplication1.VER_Number__c = ''; 
        IDCardApplication1.Promotion_Code__c = 'Inv';
        IDCardApplication1.Displayed_Name__c = 'ContactOne UserOne';
        
        
        //New Application Record as key account
        ID_Card_Application__c IDCardApplicationKeyAccount = new ID_Card_Application__c();
        IDCardApplicationKeyAccount.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplicationKeyAccount.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplicationKeyAccount.Date_of_Birth__c = date.newInstance(1980, 1, 1);
        IDCardApplicationKeyAccount.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplicationKeyAccount.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplicationKeyAccount.First_Name__c = 'ContactOne';
        IDCardApplicationKeyAccount.Gender__c = 'M';
        IDCardApplicationKeyAccount.Hours_worked__c = '35h or more';        
        IDCardApplicationKeyAccount.IATA_Code__c = '01254785';
        IDCardApplicationKeyAccount.IDCard_Expedite_Delivery__c  = false;
        IDCardApplicationKeyAccount.Last_Name__c = 'UserOne';
        IDCardApplicationKeyAccount.Middle_Initial__c = 'K';
        IDCardApplicationKeyAccount.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        IDCardApplicationKeyAccount.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        IDCardApplicationKeyAccount.Position_in_Current_Agency__c = 'Director';
        IDCardApplicationKeyAccount.Revenue_Confirmation__c = true;
        IDCardApplicationKeyAccount.Solicitation_Flag__c = false;
        IDCardApplicationKeyAccount.Start_Date_Agency_Month__c = 'January';
        IDCardApplicationKeyAccount.Start_Date_Agency_Year__c = '2003';
        IDCardApplicationKeyAccount.Start_Date_Industry__c = '2000';
        IDCardApplicationKeyAccount.Telephone__c = '5145550001';
        IDCardApplicationKeyAccount.Title__c = 'Mrs.';
        IDCardApplicationKeyAccount.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        IDCardApplicationKeyAccount.UIR__c = '';
        IDCardApplicationKeyAccount.VER_Number__c = ''; 
        IDCardApplicationKeyAccount.Promotion_Code__c = 'Inv';
        IDCardApplicationKeyAccount.Displayed_Name__c = 'ContactOne UserOne';
        
        
        // Change of Agencey ID Application
        ID_Card_Application__c IDCardApplication2 = new ID_Card_Application__c();
        IDCardApplication2.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication2.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication2.Date_of_Birth__c = date.newInstance(1971, 10, 16);
        IDCardApplication2.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication2.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication2.First_Name__c = 'MARWA';
        IDCardApplication2.Gender__c = 'F';
        IDCardApplication2.Hours_worked__c = '35h or more';        
        IDCardApplication2.IATA_Code__c = '67504242';
        IDCardApplication2.IDCard_Expedite_Delivery__c  = true;
        IDCardApplication2.Last_Name__c = 'ALLAM';
        IDCardApplication2.Middle_Initial__c = '';
        IDCardApplication2.Package_of_Travel_Professionals_Course_1__c = '';
        IDCardApplication2.Package_of_Travel_Professionals_Course_2__c = '';
        IDCardApplication2.Position_in_Current_Agency__c = 'Independent Consultant/Broker';
        IDCardApplication2.Revenue_Confirmation__c = true;
        IDCardApplication2.Solicitation_Flag__c = true;
        IDCardApplication2.Start_Date_Agency_Month__c = 'July';
        IDCardApplication2.Start_Date_Agency_Year__c = '2002';
        IDCardApplication2.Start_Date_Industry__c = '1995';
        IDCardApplication2.Telephone__c = '5145550001';
        IDCardApplication2.Title__c = 'Mrs.';
        IDCardApplication2.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REPLACEMENT;
        IDCardApplication2.UIR__c = 'CA024202';
        IDCardApplication2.Photo__c = 'CA024202.jpg';
        IDCardApplication2.VER_Number__c = '5990024202';
        IDCardApplication2.Promotion_Code__c = 'S00010';
        IDCardApplication2.Displayed_Name__c = 'ALLAM MARWA';
        
        // Renew
        ID_Card_Application__c IDCardApplication3 = new ID_Card_Application__c();
        IDCardApplication3.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication3.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication3.Date_of_Birth__c = date.newInstance(1971, 10, 16);
        IDCardApplication3.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication3.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication3.First_Name__c = 'MARWA';
        IDCardApplication3.Gender__c = 'F';
        IDCardApplication3.Hours_worked__c = '35h or more';        
        IDCardApplication3.IATA_Code__c = '67504242';
        IDCardApplication3.IDCard_Expedite_Delivery__c  = true;
        IDCardApplication3.Last_Name__c = 'ALLAM';
        IDCardApplication3.Middle_Initial__c = '';
        IDCardApplication3.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        IDCardApplication3.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        IDCardApplication3.Position_in_Current_Agency__c = 'Independent Consultant/Broker';
        IDCardApplication3.Revenue_Confirmation__c = true;
        IDCardApplication3.Solicitation_Flag__c = true;
        IDCardApplication3.Start_Date_Agency_Month__c = 'July';
        IDCardApplication3.Start_Date_Agency_Year__c = '2002';
        IDCardApplication3.Start_Date_Industry__c = '1995';
        IDCardApplication3.Telephone__c = '514-555-0001';
        IDCardApplication3.Title__c = 'Mrs.';
        IDCardApplication3.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_RENEWAL;
        IDCardApplication3.UIR__c = 'CA024202';
        IDCardApplication3.VER_Number__c = '5990024202';
        IDCardApplication3.Promotion_Code__c = 'S00010';
        IDCardApplication3.Displayed_Name__c = 'ALLAM MARWA';
        
        // Reissue
        ID_Card_Application__c IDCardApplication4 = new ID_Card_Application__c();
        IDCardApplication4.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication4.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication4.Date_of_Birth__c = date.newInstance(1971, 10, 16);
        IDCardApplication4.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication4.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication4.First_Name__c = 'MARWA';
        IDCardApplication4.Gender__c = 'F';
        IDCardApplication4.Hours_worked__c = '35h or more';        
        IDCardApplication4.IATA_Code__c = '67504242';
        IDCardApplication4.IDCard_Expedite_Delivery__c  = true;
        IDCardApplication4.Last_Name__c = 'ALLAM';
        IDCardApplication4.Middle_Initial__c = '';
        IDCardApplication4.Package_of_Travel_Professionals_Course_1__c = '';
        IDCardApplication4.Package_of_Travel_Professionals_Course_2__c = '';
        IDCardApplication4.Position_in_Current_Agency__c = 'Director';
        IDCardApplication4.Revenue_Confirmation__c = true;
        IDCardApplication4.Solicitation_Flag__c = true;
        IDCardApplication4.Start_Date_Agency_Month__c = 'July';
        IDCardApplication4.Start_Date_Agency_Year__c = '2002';
        IDCardApplication4.Start_Date_Industry__c = '1995';
        IDCardApplication4.Telephone__c = '514-555-0001';
        IDCardApplication4.Title__c = 'Mrs.';
        IDCardApplication4.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REISSUE;
        IDCardApplication4.UIR__c = 'CA024202';
        IDCardApplication4.VER_Number__c = '5990024202';
        IDCardApplication4.Promotion_Code__c = 'S00010';
        IDCardApplication4.Displayed_Name__c = 'ALLAM MARWA';
        
        
        
        
        
        
        /**************************************/
        
         // Multiple agent account
        ID_Card_Application__c multipleAgentAccountChangeName11 = new ID_Card_Application__c(); 
        multipleAgentAccountChangeName11.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REPLACEMENT;
        multipleAgentAccountChangeName11.Date_of_Birth__c = date.newInstance(1980, 1, 1);      
        multipleAgentAccountChangeName11.First_Name__c = 'Davidd';            
        multipleAgentAccountChangeName11.IATA_Code__c = '85500100';    
        multipleAgentAccountChangeName11.Last_Name__c = 'Simardd';  
        multipleAgentAccountChangeName11.Approving_Manager_s_Name__c = 'Manager Name';
        multipleAgentAccountChangeName11.Approving_Manager_s_Email__c = 'manager@email.com';        
        multipleAgentAccountChangeName11.Duties_in_Current_Agency__c = 'Administration';
        multipleAgentAccountChangeName11.Email_admin__c = 'johnsonk@iata.org';        
        multipleAgentAccountChangeName11.Gender__c = 'M';
        multipleAgentAccountChangeName11.Hours_worked__c = '35h or more';       
        multipleAgentAccountChangeName11.IDCard_Expedite_Delivery__c  = false;       
        multipleAgentAccountChangeName11.Middle_Initial__c = 'K';
        multipleAgentAccountChangeName11.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        multipleAgentAccountChangeName11.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        multipleAgentAccountChangeName11.Position_in_Current_Agency__c = 'Director';
        multipleAgentAccountChangeName11.Revenue_Confirmation__c = true;
        multipleAgentAccountChangeName11.Solicitation_Flag__c = false;
        multipleAgentAccountChangeName11.Start_Date_Agency_Month__c = 'January';
        multipleAgentAccountChangeName11.Start_Date_Agency_Year__c = '2003';
        multipleAgentAccountChangeName11.Start_Date_Industry__c = '2000';
        multipleAgentAccountChangeName11.Telephone__c = '5145550001';
        multipleAgentAccountChangeName11.Title__c = 'Mrs.';
        multipleAgentAccountChangeName11.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;        
        multipleAgentAccountChangeName11.Promotion_Code__c = 'Inv';
        multipleAgentAccountChangeName11.Displayed_Name__c = 'ContactOne UserOne';
        
        
        //New Application Record
        ID_Card_Application__c IDCardApplication111 = new ID_Card_Application__c();
        IDCardApplication111.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication111.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication111.Date_of_Birth__c = date.newInstance(1980, 1, 1);
        IDCardApplication111.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication111.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication111.First_Name__c = 'ContactOne';
        IDCardApplication111.Gender__c = 'M';
        IDCardApplication111.Hours_worked__c = '35h or more';        
        IDCardApplication111.IATA_Code__c = '67504242';
        IDCardApplication111.IDCard_Expedite_Delivery__c  = false;
        IDCardApplication111.Last_Name__c = 'UserOne';
        IDCardApplication111.Middle_Initial__c = 'K';
        IDCardApplication111.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        IDCardApplication111.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        IDCardApplication111.Position_in_Current_Agency__c = 'Director';
        IDCardApplication111.Revenue_Confirmation__c = true;
        IDCardApplication111.Solicitation_Flag__c = false;
        IDCardApplication111.Start_Date_Agency_Month__c = 'January';
        IDCardApplication111.Start_Date_Agency_Year__c = '2003';
        IDCardApplication111.Start_Date_Industry__c = '2000';
        IDCardApplication111.Telephone__c = '5145550001';
        IDCardApplication111.Title__c = 'Mrs.';
        IDCardApplication111.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        IDCardApplication111.UIR__c = '';
        IDCardApplication111.VER_Number__c = ''; 
        IDCardApplication111.Promotion_Code__c = 'Inv';
        IDCardApplication111.Displayed_Name__c = 'ContactOne UserOne';
        
        
        //New Application Record as key account
        ID_Card_Application__c IDCardApplicationKeyAccount11 = new ID_Card_Application__c();
        IDCardApplicationKeyAccount11.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplicationKeyAccount11.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplicationKeyAccount11.Date_of_Birth__c = date.newInstance(1980, 1, 1);
        IDCardApplicationKeyAccount11.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplicationKeyAccount11.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplicationKeyAccount11.First_Name__c = 'ContactOne';
        IDCardApplicationKeyAccount11.Gender__c = 'M';
        IDCardApplicationKeyAccount11.Hours_worked__c = '35h or more';        
        IDCardApplicationKeyAccount11.IATA_Code__c = '01254785';
        IDCardApplicationKeyAccount11.IDCard_Expedite_Delivery__c  = false;
        IDCardApplicationKeyAccount11.Last_Name__c = 'UserOne';
        IDCardApplicationKeyAccount11.Middle_Initial__c = 'K';
        IDCardApplicationKeyAccount11.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        IDCardApplicationKeyAccount11.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        IDCardApplicationKeyAccount11.Position_in_Current_Agency__c = 'Director';
        IDCardApplicationKeyAccount11.Revenue_Confirmation__c = true;
        IDCardApplicationKeyAccount11.Solicitation_Flag__c = false;
        IDCardApplicationKeyAccount11.Start_Date_Agency_Month__c = 'January';
        IDCardApplicationKeyAccount11.Start_Date_Agency_Year__c = '2003';
        IDCardApplicationKeyAccount11.Start_Date_Industry__c = '2000';
        IDCardApplicationKeyAccount11.Telephone__c = '5145550001';
        IDCardApplicationKeyAccount11.Title__c = 'Mrs.';
        IDCardApplicationKeyAccount11.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        IDCardApplicationKeyAccount11.UIR__c = '';
        IDCardApplicationKeyAccount11.VER_Number__c = ''; 
        IDCardApplicationKeyAccount11.Promotion_Code__c = 'Inv';
        IDCardApplicationKeyAccount11.Displayed_Name__c = 'ContactOne UserOne';
        
        
        // Change of Agencey ID Application
        ID_Card_Application__c IDCardApplication12 = new ID_Card_Application__c();
        IDCardApplication12.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication12.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication12.Date_of_Birth__c = date.newInstance(1971, 10, 16);
        IDCardApplication12.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication12.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication12.First_Name__c = 'MARWA';
        IDCardApplication12.Gender__c = 'F';
        IDCardApplication12.Hours_worked__c = '35h or more';        
        IDCardApplication12.IATA_Code__c = '67504242';
        IDCardApplication12.IDCard_Expedite_Delivery__c  = true;
        IDCardApplication12.Last_Name__c = 'ALLAM';
        IDCardApplication12.Middle_Initial__c = '';
        IDCardApplication12.Package_of_Travel_Professionals_Course_1__c = '';
        IDCardApplication12.Package_of_Travel_Professionals_Course_2__c = '';
        IDCardApplication12.Position_in_Current_Agency__c = 'Independent Consultant/Broker';
        IDCardApplication12.Revenue_Confirmation__c = true;
        IDCardApplication12.Solicitation_Flag__c = true;
        IDCardApplication12.Start_Date_Agency_Month__c = 'July';
        IDCardApplication12.Start_Date_Agency_Year__c = '2002';
        IDCardApplication12.Start_Date_Industry__c = '1995';
        IDCardApplication12.Telephone__c = '5145550001';
        IDCardApplication12.Title__c = 'Mrs.';
        IDCardApplication12.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REPLACEMENT;
        IDCardApplication12.UIR__c = 'CA024202';
        IDCardApplication12.Photo__c = 'CA024202.jpg';
        IDCardApplication12.VER_Number__c = '5990024202';
        IDCardApplication12.Promotion_Code__c = 'S00010';
        IDCardApplication12.Displayed_Name__c = 'ALLAM MARWA';
        
        // Renew
        ID_Card_Application__c IDCardApplication13 = new ID_Card_Application__c();
        IDCardApplication13.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication13.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication13.Date_of_Birth__c = date.newInstance(1971, 10, 16);
        IDCardApplication13.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication13.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication13.First_Name__c = 'MARWA';
        IDCardApplication13.Gender__c = 'F';
        IDCardApplication13.Hours_worked__c = '35h or more';        
        IDCardApplication13.IATA_Code__c = '67504242';
        IDCardApplication13.IDCard_Expedite_Delivery__c  = true;
        IDCardApplication13.Last_Name__c = 'ALLAM';
        IDCardApplication13.Middle_Initial__c = '';
        IDCardApplication13.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        IDCardApplication13.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
        IDCardApplication13.Position_in_Current_Agency__c = 'Independent Consultant/Broker';
        IDCardApplication13.Revenue_Confirmation__c = true;
        IDCardApplication13.Solicitation_Flag__c = true;
        IDCardApplication13.Start_Date_Agency_Month__c = 'July';
        IDCardApplication13.Start_Date_Agency_Year__c = '2002';
        IDCardApplication13.Start_Date_Industry__c = '1995';
        IDCardApplication13.Telephone__c = '514-555-0001';
        IDCardApplication13.Title__c = 'Mrs.';
        IDCardApplication13.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_RENEWAL;
        IDCardApplication13.UIR__c = 'CA024202';
        IDCardApplication13.VER_Number__c = '5990024202';
        IDCardApplication13.Promotion_Code__c = 'S00010';
        IDCardApplication13.Displayed_Name__c = 'ALLAM MARWA';
        
        // Reissue
        ID_Card_Application__c IDCardApplication14 = new ID_Card_Application__c();
        IDCardApplication14.Approving_Manager_s_Name__c = 'Manager Name';
        IDCardApplication14.Approving_Manager_s_Email__c = 'manager@email.com';
        IDCardApplication14.Date_of_Birth__c = date.newInstance(1971, 10, 16);
        IDCardApplication14.Duties_in_Current_Agency__c = 'Administration';
        IDCardApplication14.Email_admin__c = 'johnsonk@iata.org';
        IDCardApplication14.First_Name__c = 'MARWA';
        IDCardApplication14.Gender__c = 'F';
        IDCardApplication14.Hours_worked__c = '35h or more';        
        IDCardApplication14.IATA_Code__c = '67504242';
        IDCardApplication14.IDCard_Expedite_Delivery__c  = true;
        IDCardApplication14.Last_Name__c = 'ALLAM';
        IDCardApplication14.Middle_Initial__c = '';
        IDCardApplication14.Package_of_Travel_Professionals_Course_1__c = '';
        IDCardApplication14.Package_of_Travel_Professionals_Course_2__c = '';
        IDCardApplication14.Position_in_Current_Agency__c = 'Director';
        IDCardApplication14.Revenue_Confirmation__c = true;
        IDCardApplication14.Solicitation_Flag__c = true;
        IDCardApplication14.Start_Date_Agency_Month__c = 'July';
        IDCardApplication14.Start_Date_Agency_Year__c = '2002';
        IDCardApplication14.Start_Date_Industry__c = '1995';
        IDCardApplication14.Telephone__c = '514-555-0001';
        IDCardApplication14.Title__c = 'Mrs.';
        IDCardApplication14.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REISSUE;
        IDCardApplication14.UIR__c = 'CA024202';
        IDCardApplication14.VER_Number__c = '5990024202';
        IDCardApplication14.Promotion_Code__c = 'S00010';
        IDCardApplication14.Displayed_Name__c = 'ALLAM MARWA';
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        /*
        Area_Counter__c areaCounter1 = new Area_Counter__c();
        areaCounter1.Name = 'Area 1 counter';
        areaCounter1.AIMS_Area_Id__c = 1.0;
        areaCounter1.Next_Counter_Value__c = 78527.0;
        
        Area_Counter__c areaCounter2 = new Area_Counter__c();
        areaCounter2.Name = 'Area 2 counter';
        areaCounter2.AIMS_Area_Id__c = 2.0;
        areaCounter2.Next_Counter_Value__c = 78720.0;
        
        Area_Counter__c areaCounter3 = new Area_Counter__c();
        areaCounter3.Name = 'Area 3 counter';
        areaCounter3.AIMS_Area_Id__c = 3.0;
        areaCounter3.Next_Counter_Value__c = 78929.0;
          */   
        IATA_ISO_Country__c iataISOCountry1 = new IATA_ISO_Country__c ();
        iataISOCountry1.Name = 'Canada';
        iataISOCountry1.AIMS_Area_ID__c = '1';
        iataISOCountry1.AIMS_Area_Name__c = 'CANADA';
        iataISOCountry1.Case_BSP_Country__c = 'Canada';
        iataISOCountry1.ISO_Code__c = 'CA';
        iataISOCountry1.ISO_Code_Numeric__c = 990;
        iataISOCountry1.Region__c = 'Americas';
        iataISOCountry1.SLA_Type__c = 'SET4';
                
        IDCards_IATAISOCountries.add(iataISOCountry1);
    	insert IDCards_IATAISOCountries;
    	
        Price_Table__c priceTable1 = new Price_Table__c();
        priceTable1.Can_Pay_by_Cheque__c = false;
        priceTable1.CurrencyIsoCode = 'CAD';
        priceTable1.Expedite__c = 23.0;
        priceTable1.Expedite_Delivery_added_to_IDCard_Price__c = false;
        priceTable1.IATA_Package__c = 180;
        priceTable1.ID_Card_Fee__c = 55;
        priceTable1.ISO_Country__c = IDCards_IATAISOCountries[0].Id;
        priceTable1.Region__c = 'IDCA';
        priceTable1.Type_Class_of_Agent__c = 'TIDS';
        
        Price_Table__c priceTable2 = new Price_Table__c();
        priceTable2.Can_Pay_by_Cheque__c = false;
        priceTable2.CurrencyIsoCode = 'CAD';
        priceTable2.Expedite__c = 23.0;
        priceTable2.Expedite_Delivery_added_to_IDCard_Price__c = false;
        priceTable2.IATA_Package__c = 160;
        priceTable2.ID_Card_Fee__c = 35;
        priceTable2.ISO_Country__c = IDCards_IATAISOCountries[0].Id;
        priceTable2.Region__c = 'IDCA';
        priceTable2.Type_Class_of_Agent__c = 'Passenger';
        
         Price_Table__c priceTable3 = new Price_Table__c();
        priceTable3.Can_Pay_by_Cheque__c = false;
        priceTable3.CurrencyIsoCode = 'CAD';
        priceTable3.Expedite__c = 23.0;
        priceTable3.Expedite_Delivery_added_to_IDCard_Price__c = false;
        priceTable3.IATA_Package__c = 160;
        priceTable3.ID_Card_Fee__c = 35;
        priceTable3.ISO_Country__c = IDCards_IATAISOCountries[0].Id;
        priceTable3.Region__c = 'IDCA';
        priceTable3.Type_Class_of_Agent__c = 'Domestic';
        
        Promotion__c promotion1 = new Promotion__c();
        promotion1.Promotion_Value__c = 50;
        promotion1.Promotion_Duration_Valid_From__c = Date.today().addDays(-365);
        promotion1.Promotion_Duration_Valid_Up_to__c = Date.today().addDays(365);
       	promotion1.Promotion_Code__c = 'PROMOP';
       	promotion1.Type_of_Application__c = 'New;Reissue';
              
        IDCards_IDCardApplications.add(inactiveAccount);  
        IDCards_IDCardApplications.add(multipleAgentAccount);
        IDCards_IDCardApplications.add(IDCardApplication1);
        IDCards_IDCardApplications.add(IDCardApplication2);
        IDCards_IDCardApplications.add(multipleAgentAccountChangeName);
        IDCards_IDCardApplications.add(IDCardApplication3);
        IDCards_IDCardApplications.add(IDCardApplication4);
        IDCards_IDCardApplications.add(IDCardApplicationKeyAccount);
        
        
        IDCard_Accounts.add(account1);
        IDCard_Accounts.add(account2);
        IDCard_Accounts.add(account3);
        IDCard_Accounts.add(account4);
        IDCard_Accounts.add(account7);
        
        IDCard_keyAccounts.add(account5);
        IDCard_KeyAccounts.add(account6);
        
        insert IDCard_keyAccounts;
        /*
        IDCards_Area_Counters.add(areaCounter1);
        IDCards_Area_Counters.add(areaCounter2);
        IDCards_Area_Counters.add(areaCounter3);
            */    
    	IDCards_Price_Tables.add(priceTable1);
    	IDCards_Price_Tables.add(priceTable2);
    	
    	IDCards_Promotions.add(promotion1);
    	
    	//insert IDCards_Area_Counters;
    	insert IDCards_Price_Tables;
    	
        
        IDCard_Contacts.add(contact1);
        insert (new List<Account> {IDCard_Accounts[0], IDCard_Accounts[1], IDCard_Accounts[2], IDCard_Accounts[3], IDCard_Accounts[4]});
        
    }
}
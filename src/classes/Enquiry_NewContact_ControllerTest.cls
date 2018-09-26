@isTest
public class Enquiry_NewContact_ControllerTest{

  	public static	list<IATA_ISO_Country__c> isoCountries = new list<IATA_ISO_Country__c>();
	public static PageReference pageRef = Page.Enquiry_NewContact;  
	public static contact c = new contact(email ='some@email.org', Lastname = 'myName', firstname = 'Name' );
	public static list<LogAnEnquiryUtil__c> LOGs  = new list<LogAnEnquiryUtil__c>();
	public static map<string,map<string,id>> RtIDsPerDeveloperNamePerObj  = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account','Contact'});
	
	
	

	
	
	public static void createData(){
		
		//EmailDeveloper
		ID USERIDLOCAL =  [SELECT ID FROM USER WHERE ISACTIVE = TRUE LIMIT 1].ID;
		LOGs = NEW list<LogAnEnquiryUtil__c> {	NEW LogAnEnquiryUtil__c(CONTENT__C =USERIDLOCAL ,NAME='UserID'),
												NEW LogAnEnquiryUtil__c(CONTENT__C ='Pages/thankspage.aspx' ,NAME='thankspage'),
												NEW LogAnEnquiryUtil__c(CONTENT__C ='pages/log-an-enquiry.aspx?' ,NAME='LogAnEnquiry'),
												NEW LogAnEnquiryUtil__c(CONTENT__C ='someURL',NAME='Enquiry_NewContact'),
												NEW LogAnEnquiryUtil__c(CONTENT__C ='http://www.iata.org/customer-portal/' ,NAME='customer-portal'),
												NEW LogAnEnquiryUtil__c(CONTENT__C ='some email' ,NAME='EmailDeveloper')
												};
		
		
		insert LOGs;
		isoCountries = new list<IATA_ISO_Country__c>{	new IATA_ISO_Country__c(Name = 'italia',ISO_Code__c  ='ir'),
														new IATA_ISO_Country__c(Name = 'francia',ISO_Code__c  ='fr'),
														new IATA_ISO_Country__c(Name = 'svizzera',ISO_Code__c  ='sv'),
														new IATA_ISO_Country__c(Name = 'germania',ISO_Code__c  ='de')
		};
		
			insert isoCountries;
			
		Test.setCurrentPage(pageRef);	
	    ApexPages.currentPage().getParameters().put('l', 'en');
        ApexPages.currentPage().getParameters().put('it', 'Italia');
        ApexPages.currentPage().getParameters().put('e', 'some@email.org');
			
			
	}	
	

	   static testMethod void testSearchForNotFound(){
    		
    		set<string> customerTypes  = new set<string>{'Airline',
														'Agency',
														'General Sales Agent',
														'TIESS',
														'Non IATA Agency',
														'Partner',
														'General Public'};
    		createData();
    		Enquiry_NewContact_Controller controller = new Enquiry_NewContact_Controller(); 
    		controller.con.phone = '123';
    		controller.con.Salutation = 'ciao';
    		controller.con.LastName = 'mondo';
    		controller.con.Title = 'predisnde';
    		controller.con.FirstName = 'asdasd';
    		controller.con.Membership_Function__c = 'asdasdasd';
			
			controller.con.ISO_Country__c = isoCountries[0].id;
			
			
			controller.acc.TIESS_Code__c = 'TIESS_12312312';
			controller.acc.Name = 'aADS'; //no sense name
			// WE ARE TESTING THE VALIDATION ERRORS OF THE IATACODE TIESCODE AND NAME....
			for(string customT :customerTypes){
				controller.acc.IATACode__c = customT == 'Airline' ? '123' : customT == 'General Sales Agent' ?  'ACZ' : '5550498';
				controller.CustomerType = customT;
				controller.searchForAccount();
				system.assertEquals(controller.errorMessage.size() , 1);	
			}
			
 
			
						
    }
		
   static testMethod void testSearchForAccountVariousErros(){
    		
    		set<string> customerTypes  = new set<string>{'Airline',
														'Agency',
														'General Sales Agent',
														'TIESS',
														'Non IATA Agency',
														'Partner',
														'General Public'};
    		createData();
    		Enquiry_NewContact_Controller controller = new Enquiry_NewContact_Controller(); 
    		controller.con.phone = '123';
    		controller.con.Salutation = 'ciao';
    		controller.con.LastName = 'mondo';
    		controller.con.Title = 'predisnde';
    		controller.con.FirstName = 'asdasd';
    		controller.con.Membership_Function__c = 'asdasdasd';
			
			controller.con.ISO_Country__c = isoCountries[0].id;
			
			controller.acc.IATACode__c = 'nosenseIATACODE';
			controller.acc.TIESS_Code__c = 'nosenseTiess';
			controller.acc.Name = 'a'; //no sense name
			// WE ARE TESTING THE VALIDATION ERRORS OF THE IATACODE TIESCODE AND NAME....
			for(string customT :customerTypes){
				controller.CustomerType = customT;
				controller.searchForAccount();
				system.assertEquals(controller.errorMessage.size() , 1);	
			}
			
 
			
						
    }	
			
	    static testMethod void testNoContactGeneralPublicWIthExistingcontact(){
    		
    		
    		createData();
    		contact con = new contact(	email ='some@email.org', 
   										Lastname = 'myName' ,
   										firstname = 'Name' ,
   										recordtypeID = RtIDsPerDeveloperNamePerObj.get('Contact').get('Standard_Contact'),
   										ISO_Country__c = isoCountries[0].id,
   										phone = '123'
   										);
			insert con;
    		
    		 ApexPages.currentPage().getParameters().put('cid', con.id);
    		
    		Enquiry_NewContact_Controller controller = new Enquiry_NewContact_Controller(); 
    		controller.con.phone = '123';
    		controller.con.Salutation = 'ciao';
    		controller.con.Title = 'predisnde';
    		controller.con.FirstName = 'asdasd';
    		controller.con.Membership_Function__c = 'asdasdasd';
			controller.CustomerType = 'General Public';
			controller.con.ISO_Country__c = isoCountries[0].id;
    		
    		 Account GeneralAccount = new account(type='General Public',name = 'genral',
    		  									 		IATA_ISO_Country__c =isoCountries[0].id );
    		insert GeneralAccount;
    		controller.goToAccountSearch(); 
    			
    			
    		contact result = [select id, LastName  from contact limit 1];
    		system.assertEquals(result.LastName , 'myName' );	

    }
			
			
			
    static testMethod void testNoContactGeneralPublic(){
    		
    		createData();
    		Enquiry_NewContact_Controller controller = new Enquiry_NewContact_Controller(); 
    		controller.con.phone = '123';
    		controller.con.Salutation = 'ciao';
    		controller.con.LastName = 'mondo';
    		controller.con.Title = 'predisnde';
    		controller.con.FirstName = 'asdasd';
    		controller.con.Membership_Function__c = 'asdasdasd';
			controller.CustomerType = 'General Public';
			controller.con.ISO_Country__c = isoCountries[0].id;
    		
    		 Account GeneralAccount = new account(type='General Public',name = 'genral',
    		  									 		IATA_ISO_Country__c =isoCountries[0].id );
    		insert GeneralAccount;
    		controller.goToAccountSearch(); 
    			
    			
    		contact result = [select id, LastName  from contact limit 1];
    		system.assertEquals(result.LastName , 'mondo' );	

    }


static testMethod void testNoContactAirline(){
    		
    		createData();
    		Enquiry_NewContact_Controller controller = new Enquiry_NewContact_Controller(); 
    		controller.con.phone = '123';
    		controller.con.Salutation = 'ciao';
    		controller.con.LastName = 'mondo';
    		controller.con.Title = 'predisnde';
    		controller.con.FirstName = 'asdasd';
    		controller.con.Membership_Function__c = 'asdasdasd';
			controller.CustomerType = 'Airline';
			controller.con.ISO_Country__c = isoCountries[0].id;
			
    		controller.goToAccountSearch(); 
			 Account airline = new account(type='some airline',
			 											name = 'myArilne',IATACode__c = '123',
			 											RecordTypeId = RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline'),
    		  									 		IATA_ISO_Country__c =isoCountries[0].id );
    		insert airline;
			controller.acc.IATACode__c = '123';
			
			controller.searchForAccount();    			
			system.assertEquals(controller.AccListHQ[0].id,airline.id);
			
			
			controller.savecontact();
			
			contact result = [select id, LastName  from contact limit 1];
    		system.assertEquals(result.LastName , 'mondo' );	
			
			
						
    }
    
    
    static testMethod void testNoContactAirlineACCNCON(){
    		
    		createData();
    		Enquiry_NewContact_Controller controller = new Enquiry_NewContact_Controller(); 
    		controller.con.phone = '123';
    		controller.con.Salutation = 'ciao';
    		controller.con.LastName = 'mondo';
    		controller.con.Title = 'predisnde';
    		controller.con.FirstName = 'asdasd';
    		controller.con.Membership_Function__c = 'asdasdasd';
			controller.CustomerType = 'Airline';
			controller.con.ISO_Country__c = isoCountries[0].id;
			
    		controller.goToAccountSearch(); 
			 Account airline = new account(type='some airline',
			 											name = 'myArilne',IATACode__c = '123',
			 											RecordTypeId = RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline'),
    		  									 		IATA_ISO_Country__c =isoCountries[0].id );
    		insert airline;
			controller.acc.IATACode__c = '123';
			
			controller.searchForAccount();    			
			system.assertEquals(controller.AccListHQ[0].id,airline.id);
			

			 
			controller.acc.name = 'bla';
			controller.acc.industry ='dealer';
			controller.acc.type ='atyasd';
			controller.acc.BillingStreet ='asd';
			controller.acc.BillingCity = 'asd';
			controller.acc.Phone = '123';
			controller.acc.BillingCountry ='Italia';
			controller.acc.Fax = '123';
			controller.acc.Email__c = 'myconp@asd.it';
			
			
			controller.saveAccountAndContact();
			
			contact resultCon = [select id, LastName  from contact limit 1];
    		system.assertEquals(resultCon.LastName , 'mondo' );
    		
    		account resultAcc = [select id, name  from account limit 1];
    		system.assertEquals(resultAcc.name , 'myArilne' );	
    		
    		
    		controller.backToContact();
						
    }
    
	
 static testMethod void testNoContactGeneralPublicWIthEmailError(){
    		
    		
   			createData();
    		ApexPages.currentPage().getParameters().put('cid','idinesisnte');
    		
    		Enquiry_NewContact_Controller controller = new Enquiry_NewContact_Controller(); 
    		
    		system.assertEquals(controller.errorMessage[0].contains('An Error occured'),true );	
    
    }		
  
        
}
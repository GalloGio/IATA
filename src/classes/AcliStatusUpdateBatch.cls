global class AcliStatusUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
   
   global boolean StateOff {get;set;} 
   global  String backUp = AcliAccount.firstLineCSV();
   global String UserEmail {get;set;}   
   global boolean inctivateTheAirlines =false;  
    
global Database.QueryLocator start(Database.BatchableContext BC){

        StateOff = stateOFf == null?false:stateOff;
        set<string> acctFoundIDs = new set<string>();
    
        Document acliTxtFile = [SELECT Body FROM document where developername = 'AcliUniqueFile' ];
        string acliTxtFileString  = acliTxtFile.Body.tostring() ;
        
        integer max =0;
           string separator =  acliTxtFileString.contains('<br>') ?  '<br>' : '\\n';          
                for(String line : acliTxtFileString.split(separator)) {
                    max++;
                }
       
        AcliWrapper wrapperTmp =AcliParser.AcliParsingNotFound(acliTxtFileString,0,max,stateOFf);  

        if(wrapperTmp.AcliAccount.IsEmpty() 
                          ){
            inctivateTheAirlines =true;
        }
   // throw new transformationException(''+AcliParser.AcliParsingFound(acliTxtFileString  ,0,max,StateOff).acliAccount.values());
        if(inctivateTheAirlines) 
        for(acliAccount accL: AcliParser.AcliParsingFound(acliTxtFileString  ,0,max,StateOff).acliAccount.values()){
            if(accL.AcctID <> null)
                acctFoundIDs.add(accL.AcctID);
        }
       // throw new transformationException('' +acctFoundIDs.size());
       String Query =                'SELECT Id,name,IATACode__c,Name_on_AOC__c,'
                                   +' Airline_designator__c,ICAO_designator__c,'
                                   +' duplicate_flag_indicato__c,billingStreet,'
                                   +' billingCity,billingState,'
                                   +' billingCountry,billingPostalCode,'
                                   +' Membership_SITA__c,Memmership_ARINC__c,'
                                   +' IATA_Member__c,Memmership_ATA__c,Type_of__c,'
                                   +' Account_code_secondary_flag__c,Airline_Prefix__c,'
                                   +' IATA_ISO_Country__c,ACLI_Status__c,IATA_ISO_Country__r.ISO_Code__c'
                                   +' FROM account '
                                   +' WHERE '
                                   + 'id not IN: acctFoundIDs AND  recordtype.developername = \'iata_airline\' '
                                   ;
                                   
 //   list<account> accts =(list<account>) Database.query(query);
  //       throw new transformationException('' +accts );                           
       if(acctFoundIDs <> null && acctFoundIDs.size()>0)
            return Database.getQueryLocator(query);
         return Database.getQueryLocator('select id from account where name = \'Pompidur\'');
      }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
          
           if(!scope.isEmpty()){    
                list<Account> Updates = new list<Account>();
                        
                  for(Sobject s : scope){   
                         
                         Account a = (Account)s;
                         //  throw new transformationException('' + a);               
                         Account cloned =a.clone(false,true,false,false);
                          backup +=AcliAccount.lineOfAcliFromACct(cloned);
                         a.ACLI_Status__c =  'Inactive Company';
                        Updates.add(a);
                  }
            if(!Updates.isEmpty())
                update Updates;
           }   
    }

   global void finish(Database.BatchableContext BC){
            
    
   if(inctivateTheAirlines){ 
     Blob b =blob.valueOf(backup );   
         Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

         efa.setContentType('application/xml');   
         efa.setFileName('BackUpAcliACtive'+datetime.now()+'.txt');
         efa.setBody(b);
          
         String body = 'Please find attached the backUp';
         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        // Sets the 'BACK Up Accounts Pre Acli ' + dateTime.now()of the email
        email.setSubject('Acli Back Up STATUS ' + datetime.now());
        list<string> emails = new list<string>{'sfdcadmin@iata.org'};
        if(userEmail <> null)emails.add(userEmail);
        email.setToAddresses( emails);
        email.setPlainTextBody( body );
         Messaging.EmailFileAttachment[] attachements = new Messaging.EmailFileAttachment[]{} ;
         

        attachements.add(efa);
        
        email.setFileAttachments(attachements);

        // Sends the email
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
  
    }  
   }        
            
            
            
            
            
   

}
global  class AcliUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
   global  boolean stateOFF {get;set;}
   global  String backUp = AcliAccount.firstLineCSV();
   global String UserEmail {get;set;}   
    
global Database.QueryLocator start(Database.BatchableContext BC){
       String Query =                'SELECT Id,name,IATACode__c,Name_on_AOC__c,'
                                   +' Airline_designator__c,ICAO_designator__c,'
                                   +' billingStreet,'
                                   +' billingCity,billingState,'
                                   +' billingCountry,billingPostalCode,'
                                   +' Membership_SITA__c,Memmership_ARINC__c,'
                                   +' IATA_Member__c,Memmership_ATA__c,Type_of__c,'
                                   +' Account_code_secondary_flag__c,Airline_Prefix__c,'
                                   +' IATA_ISO_Country__c,ACLI_Status__c,IATA_ISO_Country__r.ISO_Code__c'
                                   + ' ,Membership_status__c ' 
                                   +' FROM account '
                                   +' WHERE '
                                 //  + 'id in (\'001w0000015LHV3\',\'001w0000015LHOi\',\'001w0000015LHQU\',\'001w0000015LHS9\',\'001w0000015LHMY\')'
                                   +'  recordtype.developername = \'iata_airline\'  '
                                   ;
       return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
            list<Account> acctUpdates = new list<Account>(); 
            TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndeleteSet();  
            map<id,Account> bkUpMap = new map<id,Account>();
            
            map<string,Account> accountOnDbPerChiave = new map<string,Account>();
               
                        /* here we have to push the logic not to update the values of the Membership 
                            basically the name and the address fo the memebers must be updated by Colette*/        
                  map<Id,Account> acctMembersPerID = new map<Id,Account>();
                  
                  for(Sobject s : scope){ 
                        
                     Account a = (Account)s;
                     Account cloned =a.clone(false,true,false,false);
                     cloned.id =a.id;
                    bkUpMap.put(a.id,cloned);
                      // Add some information to the contact
                    string site = TransformationHelper.buildSiteForAcli(a.IATACode__c, 
                                                                        a.Airline_designator__c,
                                                                        a.IATA_ISO_Country__r.ISO_Code__c,
                                                                        null);

                    string bilstate = a.BillingState <> null ? a.BillingState:'';
                    if(!stateOFF && bilstate <> '')site +=bilstate;
                    accountOnDbPerChiave.put(site,a);
                    /*members logic*/
                    if(a.Membership_status__c == 'IATA member')
                        acctMembersPerID.put(a.id,a);
                  }

            Document acliTxtFile = [SELECT Body FROM document where developername = 'AcliUniqueFile' ];
            string acliTxtFileString  = acliTxtFile.Body.tostring() ;
            
            /* and we get all the found ones*/
            integer max =0;
               string separator =  acliTxtFileString.contains('<br>') ?  '<br>' : '\\n';          
                    for(String line : acliTxtFileString.split(separator)) {
                        max++;
                    }
           

            map<String,AcliAccount>  acliAcctToUpdate = AcliParser.AcliParsingFound(acliTxtFileString  ,0,max,stateOFF ).acliAccount;
           
         
         for(String key: accountOnDbPerChiave.keyset()){
                            /* here we have active ones */
                             AcliAccount newACliACct = acliAcctToUpdate.get(key);
                             if(newACliACct<>null)
                             acctUpdates.add( AcliAccount.createAcctFromAcliAccount(newACliACct));// AcliAccount.createAcctFromAcliAccount(newACliACct)
                  
           } 
                //   throw new transformationException('acctUpdates ' + acctUpdates);
            
        if(!acctUpdates.isEmpty()){ 
        /* membership logic fields that cannot be update ==> only Colette can!!!!!!!!! */
        for(account a:acctUpdates)
            if(acctMembersPerID.get(a.id) <> null){
                    Account member = acctMembersPerID.get(a.id); 
                    a.Name  = member.Name ;
                    a.billingStreet = member.billingStreet;
                    a.billingCity = member.billingCity;
                    a.billingState = member.billingState;
                    a.billingCountry = member.billingCountry;
                    a.billingPostalCode = member.billingPostalCode;
                    a.IATA_ISO_Country__c = member.IATA_ISO_Country__c; 
            }
         update  acctUpdates; 
       for(account a:acctUpdates)
          if(bkUpMap.get(a.id) <> null)
           backup +=AcliAccount.lineOfAcliFromACct(bkUpMap.get(a.id));
         }      
            
    }

   global void finish(Database.BatchableContext BC){
    
    
    
     Blob b =blob.valueOf(backup );   
         Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

         efa.setContentType('application/xml');   
         efa.setFileName('BackUpAcliACtive'+datetime.now()+'.txt');
         efa.setBody(b);
          
         String body = 'Please find attached the backUp';
         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        // Sets the 'BACK Up Accounts Pre Acli ' + dateTime.now()of the email
        email.setSubject('Acli Back Up ' + datetime.now());
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
            
         AcliStatusUpdateBatch btch = new AcliStatusUpdateBatch();
         btch.UserEmail =  UserEmail;  
         btch.StateOff = StateOff;
         DataBase.ExecuteBatch(btch,200);
   }
}
public class MemberContactsCsv{ 
    public transient Blob contentFile           {get; set;}
    public account acct                         {get;private set;}
    public list<Contact> contactsToInsert       {get;set;}
    public list<Contact> contactsFromCsv        {get;private set;}
    public integer page                         {get;private set;}
    private Set<String> picklistValues;

    public MemberContactsCsv() {
        try{
            page = 1;
            String accountIdLocal = ApexPages.currentPage().getParameters().get('acctID');
            acct  = [select id, name from account where id =: accountIDLocal];
            picklistValues =TransformationHelper.getPicklistValues('Contact','Membership_Function__c');
        }catch(exception e){
            throw new transformationException('This page should not be accessed directly ' );
        }
    }

    public class NoFileSelectedException extends exception{}

    public PageReference Next(){
        List<List<String>> parsedCSV;
        string SeniorRecordTypeID =  RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Senior');
        contactsFromCsv = new list<Contact>();
        try{
            if(contentFile == null)
                throw new NoFileSelectedException ('No File Selected');

            if(contentFile!=null && contentFile.size()>10*1024*1024)
                throw new transformationException('The File you are trying to upload is too big');

            String fileString = contentFile.toString();
            parsedCSV = CSVParser.parseCSV(fileString, false);
            parsedCSV.remove(0);
            map<string,contact> contactPerName = new map<string,Contact>();
            
            //Country selection
            map<string, id> mapCountryCode = new map<string, id>();
            for(IATA_ISO_Country__c c:IATAIsoCountryDAO.getIsoCountries())
                mapCountryCode.put(c.ISO_Code__c, c.Id);
            
            integer i = 0;
            for(List<String> row: parsedCSV){
                if(!String.isEmpty(row[3].replaceAll('"', '')) && (!String.isEmpty(row[7].replaceAll('"', ''))||!String.isEmpty(row[5].replaceAll('"', '')) ) ){
                    string nameEmailTrimToLower = row[5].replaceAll('"', '').trim().toLowerCase();
                    string jobFunction = picklistValues.contains(row[0].replaceAll('"', ''))?row[0].replaceAll('"', ''):null;
                    contact c = new contact(AccountID = acct.id,
                                            Membership_Function__c = i == 0 || jobFunction == null  ? '': jobFunction + ';'  ,
                                            Membership_Main_Contact__c = i==0 ? true: false,
                                            Salutation = row[1].replaceAll('"', '') ,
                                            FirstName = row[2].replaceAll('"', '') ,
                                            LastName=row[3].replaceAll('"', '') ,
                                            Title=row[4].replaceAll('"', '') ,
                                            Senior_Contact_Email__c =row[5].replaceAll('"', '') ,
                                            Senior_Contact_Phone__c =row[7].replaceAll('"', '') ,
                                            Senior_Contact_Fax__c=row[8].replaceAll('"', '') ,
                                            recordtypeID = SeniorRecordTypeID);
                    //Added Email set field because of validation rule and change of record type
                    c.Email = 'onlonreuqre@'+ c.Senior_Contact_Email__c.substringAfter('@');
                    if(row[6]!=null && row[6]!='' && row[6].replaceAll('"', '') != null)
                        c.ISO_Country__c = mapCountryCode.containsKey(row[6].replaceAll('"', ''))?mapCountryCode.get(row[6].replaceAll('"', '')):null;
                    else
                        c.ISO_Country__c = null;
                                                
                    if(contactPerName.get(nameEmailTrimToLower ) == null){                                      
                        Contact cToIns = c.clone();
                        contactPerName.put(nameEmailTrimToLower ,cToIns);
                    }else{
                        contactPerName.get(nameEmailTrimToLower).Membership_Function__c +=jobFunction == null  ? '':  jobFunction + ';';
                    }
                    
                    c.Description=row[6].replaceAll('"', '');
                    contactsFromCsv.add(c);
                }
                i++;
            }
            page = 2;
            contactsToInsert  =  contactPerName.values();
            // insert contactPerName.values();
        }catch(NoFileSelectedException  e){
            return null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Errors during the upload. Have you Uploaded the correct file? '+e.getMessage()  +    '  n. ' + e.getlinenumber()));
            return null;
        }

        return null;
    }
    
    public PageReference Cancel(){
        PageReference acctPage = new PageReference('/'+ acct.id);
        acctPage.setRedirect(true);
        return acctPage;
    }

    public PageReference Save(){
        try{
            insert contactsToInsert;
            return this.Cancel();
        } catch(DMLException e){
            if( e.getMessage().contains('Please fill a phone number or an email address'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill a phone number or an email address'  ));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
            return null;
        } 
    }
}
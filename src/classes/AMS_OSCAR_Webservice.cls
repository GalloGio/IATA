global class AMS_OSCAR_Webservice {

    WebService static String updateFormFields(String[] fieldsToUpdateKey, String[] fieldsToUpdateValue, String recordId) {
        
        Map<String,Schema.DisplayType> fTypes; 
        Boolean needsUpdate = false;
        String theQuery = 'SELECT ';

        for(Integer i = 0; i < fieldsToUpdateKey.size(); i++){
            theQuery += fieldsToUpdateKey[i];
            if(i<fieldsToUpdateKey.size()-1)
                theQuery+=', ';
        }
        
        theQuery += ' FROM AMS_OSCAR__c WHERE Id=' + '\'' + recordId + '\'';

        system.debug('AMS OSCAR Webservice query: '+ theQuery);
        
        List<AMS_OSCAR__c> oscar = database.query(theQuery);
        if(oscar != null && oscar.size()>0){    
            for(Integer i = 0; i < fieldsToUpdateKey.size(); i++) {
                
                Object fieldValue = oscar[0].get(fieldsToUpdateKey[i]);

                String updatedValue = fieldsToUpdateValue[i].trim();
                
                if(String.valueOf(fieldValue) != updatedValue){
                    
                    needsUpdate = true;
                    
                    if(ftypes == null)
                        fTypes = getFieldTypes(fieldsToUpdateKey);
                    
                    try{
                        if(updatedValue == '' || updatedValue == null)
                            oscar[0].put(fieldsToUpdateKey[i], null);
                        else{
                            //check fieldType
                            Schema.DisplayType fldDisplayType = ftypes.get(fieldsToUpdateKey[i]);
                            if(fldDisplayType == Schema.DisplayType.DOUBLE || 
                               fldDisplayType == Schema.DisplayType.CURRENCY ||
                                fldDisplayType == Schema.DisplayType.PERCENT){
                                        //remove commas from doubles
                                        updatedValue = updatedValue.replace(',','');
                                        oscar[0].put(fieldsToUpdateKey[i], Double.valueOf(updatedValue));
                                }
                            else if(fldDisplayType == Schema.DisplayType.BOOLEAN)
                                oscar[0].put(fieldsToUpdateKey[i], Boolean.valueOf(updatedValue));
                            else if(fldDisplayType == Schema.DisplayType.INTEGER)
                                oscar[0].put(fieldsToUpdateKey[i], Integer.valueOf(updatedValue));
                            else if(fldDisplayType == Schema.DisplayType.DATE){
                                oscar[0].put(fieldsToUpdateKey[i], Date.parse(updatedValue));
                            }
                            else //default will try to update field with String value
                                oscar[0].put(fieldsToUpdateKey[i], String.valueOf(updatedValue));
                        }
                        
                    }catch(TypeException te){
                        return te.getMessage();
                    }
                    
                }
            }
            
            if(needsUpdate)
                try{
                    update oscar[0];
                }catch(DMLException dmle){
                    String errorMessage = AMS_Utils.errorMessageBeautifyer(dmle);
                    return errorMessage;
                    //return dmle.getMessage();
                }
        }
        
        return '';
    }
    
    private static Map<String,Schema.DisplayType> getFieldTypes(List<String> fieldsApiName){
        
        Map<String,Schema.DisplayType> fieldTypes = new Map<String,Schema.DisplayType>();
        Map<String, Schema.SObjectField> allFields = Schema.getGlobalDescribe().get('AMS_OSCAR__c').getDescribe().fields.getMap();
        
        for(String f: fieldsApiName){
            Schema.DescribeFieldResult fr = allFields.get(f).getDescribe();
            fieldTypes.put(f, fr.getType());
            system.debug('Field types map: ' + fieldTypes);
        }
        
        return fieldTypes;
        
    }

    WebService static String createIFAPFromOSCAR(String oscarId){

        String result = '';

        try{

            ID IFAPcaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('IATA Financial Review');

            List<AMS_OSCAR__c> oscar = [select Name, Account__c, Account__r.BillingCountry, Account__r.Type, Account__r.Name from AMS_OSCAR__c where Id =: oscarId];
            if(oscar!=null && oscar.size()>0){
                String accountId = oscar[0].Account__c;

                if(accountId == null){
                    result = 'Could not find an account related to this OSCAR.';
                    return 'ERROR: ' + result;
                }
                //account must have billing country
                String billingCountry = oscar[0].Account__r.BillingCountry;
                if(billingCountry == null){
                    result = 'Could not find a billing country on the account related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                String accountType = oscar[0].Account__r.Type;
                if(accountType == null || !Pattern.matches('IATA Cargo Agent|IATA Passenger Sales Agent|CASS Associate', accountType)){
                    result = 'The type of account related to this oscar must be one of the following: IATA Cargo Agent|IATA Passenger Sales Agent|CASS Associate';
                    return 'ERROR: ' + result;
                }

                //find IFAP Contact in Account
                List<Contact> ifapContact = [select Financial_Assessment_Contact__c from Contact where AccountId =: accountId AND Financial_Assessment_Contact__c = true limit 1];
                if(ifapContact==null || ifapContact.size() ==0){
                    result = 'Could not find a Financial Assessment contact for the account related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                Case oscarCommCase = [select Id,Reason1__c from Case where OSCAR__c =: oscar[0].Id AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) limit 1];

                if(oscarCommCase == null){
                    result = 'Could not find a the Oscar Communication case related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                Date currentDate = Date.today();
                Case ifapCase = new Case(RecordTypeId = IFAPcaseRecordTypeID, ParentId = oscarCommCase.Id, AccountId = oscar[0].Account__c, Subject = oscarCommCase.Reason1__c + ' - ' + oscar[0].Account__r.Name, Status = 'Agent to be Notified',
                                         Financial_Review_Type__c = 'New applications', IFAP_Financial_Year__c = String.valueOf(currentDate.year()),
                                         Deadline_Date__c = currentDate+5, ContactId = ifapContact[0].Id, OSCAR__c = oscar[0].Id, Financial_Assessment_requested__c = currentDate);

                insert ifapCase;

                oscar[0].STEP11__c = 'In Progress';
                update oscar;

                //OSCAR Name will be equal to the CaseNumber, so instead of querying the ifap Case for its CaseNumber
                //we simply return the OSCAR Name 
                return ifapCase.Id + ':' + oscar[0].Name;

            }

            return 'ERROR: OSCAR not found.';

        }catch(Exception ex){
            return AMS_Utils.errorMessageBeautifyer(ex);
        }
        
    }

    WebService static String createAMLCase(String oscarId){

        String result = '';

        try{

            ID InternalCaseRecordTypeID = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('Internal Cases (IDFS ISS)');

            List<AMS_OSCAR__c> oscar = [select Name, Account__c, Account__r.Name, Account__r.IATA_ISO_Country__r.Region__c, Account__r.IATA_ISO_Country__r.Name from AMS_OSCAR__c where Id =: oscarId];
            if(oscar!=null && oscar.size()>0){

                Case oscarCommCase = [select Id from Case where OSCAR__c =: oscar[0].Id AND ParentId = null limit 1];

                if(oscarCommCase == null){
                    result = 'Could not find a the Oscar Communication case related to this OSCAR.';
                    return 'ERROR: ' + result;
                }

                Case issCase = new Case(RecordTypeId = InternalCaseRecordTypeID, Reason1__c = 'New Accredited Agent', CaseArea__c = 'Corporate Compliance',
                                    ParentId = oscarCommCase.Id, AccountId = oscar[0].Account__c, Subject = 'Anti Money Laundering – ' + oscar[0].Account__r.Name,
                                    OSCAR__c = oscar[0].Id, Region__c = oscar[0].Account__r.IATA_ISO_Country__r.Region__c, BSPCountry__c = oscar[0].Account__r.IATA_ISO_Country__r.Name);

                insert issCase;

                oscar[0].STEP17__c = 'In Progress';
                oscar[0].AML_requested__c = Date.today();
                oscar[0].AML_deadline__c = Date.today()+3;
                update oscar;

                return issCase.Id;

            }

            return 'ERROR: OSCAR not found.';

        }catch(Exception ex){
            return AMS_Utils.errorMessageBeautifyer(ex);
        }
        
    }

    WebService static String copyDataToAccount(String oscarId){

        try{
            List<AMS_OSCAR__c> oscar = [select Account__c, AMS_Online_Accreditation__c, Process__c, recordTypeID from AMS_OSCAR__c where Id =: oscarId];
            AMS_Utils.copyDataToAccount(oscar);
            return 'OK';
        }catch (Exception ex) {
            if (ex.getMessage().contains('ISSP_ContactUpdaetPortalUser'))
                return Label.AMS_Duplicate_Username;
            else
                return ex.getMessage();
        }
    }

    WebService static String createChangeCodeNEW(String oscarId){

        try{
            List<AMS_OSCAR__c> oscar = [select Account__c, Process__c, AMS_Online_Accreditation__c, recordTypeID from AMS_OSCAR__c where Id =: oscarId];

            AMS_OSCAR__c theOSCAR = oscar[0];

            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

            changeCode.name = 'NEW';
            changeCode.reasonCode = '21';
            changeCode.memoText = AMS_Utils.getChangeCodeMemoText(theOSCAR.Process__c,changeCode.name);
            changeCode.reasonDesc  = 'NEW APPLICATION';
            changeCode.status  = '2';

            Account acct = new Account(Id = theOSCAR.Account__c); 
            AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{theOSCAR}, new List<Account>{acct}, true);
            
            return 'OK';
        }catch(Exception ex){
            return ex.getMessage();
        }
    }

}
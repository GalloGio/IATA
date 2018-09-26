public without sharing class Utility {
    public class PicklistEntryWrapper{    
        public PicklistEntryWrapper(){            
        }
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
    }

    public class BitSet{
        public Map<String,Integer> alphaNumCharCodes {get;set;}
        public Map<String, Integer> base64CharCodes {get;set;}
        
        public BitSet(){
            LoadCharCodes();
        }
        
        //Method loads the character codes for all letters
        private void LoadCharCodes(){
            alphaNumCharCodes = new Map<String,Integer>{
                'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90    
            };
            base64CharCodes = new Map<String, Integer>();
            //all lower cases
            Set<String> pUpperCase = alphaNumCharCodes.keySet();
            for(String pKey : pUpperCase){
                //the difference between upper case and lower case is 32
                alphaNumCharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                base64CharCodes.put(pKey,alphaNumCharCodes.get(pKey) - 65);
                base64CharCodes.put(pKey.toLowerCase(),alphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //numerics
            for (Integer i=0; i<=9; i++){
                alphaNumCharCodes.put(string.valueOf(i),i+48);
                //base 64 numeric starts from 52
                base64CharCodes.put(string.valueOf(i), i + 52);
            }
        }
            
          public List<Integer> testBits(String pValidFor,List<Integer> nList){
                List<Integer> results = new List<Integer>();
                List<Integer> pBytes = new List<Integer>();
                Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
                Integer pFullValue = 0;
                if (bytesBeingUsed <= 1)
                    return results;
                for(Integer i=0;i<pValidFor.length();i++){
                    pBytes.Add((base64CharCodes.get((pValidFor.Substring(i, i+1)))));
                }   
                for (Integer i = 0; i < pBytes.size(); i++)
                {
                    Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
                    pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
                }
                
                Integer bit;
                Integer targetOctet;
                Integer shiftBits;
                Integer tBitVal;
                Integer n;
                Integer nListSize = nList.size();
                for(Integer i=0; i<nListSize; i++){
                    n = nList[i];
                    bit = 7 - (Math.mod(n,8)); 
                    targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed); 
                    shiftBits = (targetOctet * 8) + bit;
                    tBitVal = ((Integer)(2 << (shiftBits-1)) & pFullValue) >> shiftBits;
                    if (tBitVal==1)
                        results.add(n);
                }
                return results;
            }
    }

    /*public static map<Id,String> idsInTriggers{get{
        if(idsInTriggers == null) 
            idsInTriggers = new map<Id,String>(); 
        return idsInTriggers;
    }set;}*/

/****************************************************************************************************
    Created by CGI 2015-08-17
        Various utility methods 
****************************************************************************************************/
    
    /****************************************************************************************************
        Created by Kevin Ky 2015-08-17
            Send email to a list of email addresses
    ****************************************************************************************************/
    public static void sendEmail(List<String> recipients,String emailSubject,String body,Boolean useHTML,List<Messaging.EmailFileAttachment> fileAttachments){
    	sendEmail(recipients, emailSubject, body, useHTML, fileAttachments, true);
    }
    
    public static Messaging.SingleEmailMessage sendEmail(List<String> recipients,String emailSubject,String body,Boolean useHTML,List<Messaging.EmailFileAttachment> fileAttachments, Boolean send) { 
        
        if(recipients == null) return null;
        if(recipients.size() == 0) return null;
        // Create a new single email message object
        // that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        //the email is not saved as an activity.
        mail.setSaveAsActivity(false);
        // Assign the addresses for the To lists to the mail object.
        mail.setToAddresses(recipients);          
        // Specify the subject line for your email address.
        mail.setSubject(emailSubject);
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        if (useHTML) {
            // Specify the html content of the email.
            mail.setHtmlBody(body);
        } else {
            // Specify the text content of the email.
            mail.setPlainTextBody(body);
        }
        // Specify FileAttachments
        if(fileAttachments != null && fileAttachments.size() > 0) {
            mail.setFileAttachments(fileAttachments);
        }
        // Send the email you have created.
        if(send)
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return mail;
    } //*** end of "sendEmail"

    
    /****************************************************************************************************
        Created by Kevin Ky 2015-10-09
            Send a mass email to a list of email addresses
            @param list of Mail_DTO object
    ****************************************************************************************************/
    public static void sendBulkEmails(list<Mail_DTO> mailsObj){
        
        list<Messaging.SingleEmailMessage> lstMails = new list<Messaging.SingleEmailMessage>();
        list<Messaging.SingleEmailMessage> emailToGetEmailMsg = new list<Messaging.SingleEmailMessage>();
        
        String tempContactId;
        map<Id,Contact> contactId_Contact = Contact_Sel.getContactById(new set<Id>{getTextSetting('ContactId to populate email Template')});
        if(contactId_Contact.values()[0] != null)
            tempContactId = contactId_Contact.values()[0].Id;
        if(tempContactId == null) return;
        
        for(Mail_DTO mail : mailsObj){
            
            Boolean userTempId = false;
            //Messaging.SingleEmailMessage email = sendEmail(mail,tempContactId,false);
            // Create a new single email message object
            // that will send out a single email to the addresses in the To, CC & BCC list.
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
            //the email is not saved as an activity.
            email.setSaveAsActivity(false);
            // Assign the addresses for the To lists to the mail object.
            if(mail.recipients != null && mail.recipients.size() > 0)
                email.setToAddresses(mail.recipients);
            // Set to True if you want to BCC yourself on the email.
            email.setBccSender(false);
            // The email address of the user executing the Apex Code will be used.
            email.setUseSignature(false);
            
            email.setTemplateId(mail.templateId);
            
            if(mail.targetObjectId != null){
                email.setTargetObjectId(mail.targetObjectId);
            }else{
                email.setTargetObjectId(tempContactId);
                userTempId = true;
            }
            email.setWhatId(mail.whatId);
            
            if(mail.orgWideEmailAddressId != null && mail.orgWideEmailAddressId != ''){
                email.setOrgWideEmailAddressId(mail.orgWideEmailAddressId);
            }
            
            if(userTempId){
                emailToGetEmailMsg.add(email);
            }else{
                lstMails.add(email);
            }
            
        }
        
        if(emailToGetEmailMsg.size() > 0){
            // Send the emails in a transaction, then roll it back 
            // This will allow to modify the message after
            
            try{
                Savepoint sp = Database.setSavepoint(); 
                Messaging.sendEmail(emailToGetEmailMsg); 
                Database.rollback(sp); 
            }catch(Exception ex){
                system.debug('error ' + ex.getMessage());
            }
            
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its 
            // contents to a new SingleEmailMessage. Then send those new messages. 
            for(Messaging.SingleEmailMessage email : emailToGetEmailMsg){
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage(); 
                emailToSend.setToAddresses(email.getToAddresses()); 
                emailToSend.setPlainTextBody(email.getPlainTextBody()); 
                emailToSend.setHTMLBody(email.getHTMLBody()); 
                emailToSend.setSubject(email.getSubject()); 
                emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                //Add to the list of emails to send
                lstMails.add(emailToSend); 
            }
        }
        
        if(lstMails.size() > 0){
            try{
                Messaging.sendEmail(lstMails);
            }catch(Exception ex){
                system.debug('Error sendBulkEmails() ' + ex.getMessage());
            }
        }
    }
    
    public static Set<String> IdToString(Set<Id> ids)
    {
        Set<String> ret = new Set<String>();
        
        for(Id i: ids)  
            ret.add((String)i);
        
        return ret;
    }
    
    
    /****************************************************************************************************
        Created by CGI, Kevin 2015-08-20
            Caclulate the number of days remaining before Activity Effective Date Reached
    ****************************************************************************************************/
    public static Integer getNumberOfDays(Date effectiveDate){
        return (Test.isRunningTest()) ? 10 : Date.Today().daysBetween(effectiveDate);
    }
    
    /****************************************************************************************************
        Created by CGI, Kevin 2015-08-20
            Return a new instance of Task
    ****************************************************************************************************/ 
    public static Task getNewTask(Id productManager, String emailSubject,String description){
        Task task = new Task();
        task.OwnerId = productManager;
        task.Subject = emailSubject;
        task.Status = 'In Progress';
        task.Priority = 'Normal';
        task.Description = description;
        
        return task;
    }
    
    /****************************************************************************************************
        Created by CGI - Kevin 8/26/2015
            get EmailTemplate base on the template id
    ****************************************************************************************************/
    public static list<EmailTemplate> getEmailTemplatebyTemplateId(Id templateId){
        return [select id,body,HtmlValue,Subject from EmailTemplate where id = :templateId];
    }
    
    /****************************************************************************************************
        Created by CGI, Kevin 2015-08-25
            Return a list of administrators emails
    ****************************************************************************************************/
    public static list<String> getAdminEmails(){
        
        //get the list of email notification Administrator object from the custom setting
        list<String> emails = new list<String>();
        String textEmails = getTextSetting('Products email notification admin');
        
        if(textEmails.contains(',')){
            emails.addAll(textEmails.split(','));
        }else{
            emails.add(textEmails);
        }
        
        return  emails;
    }
    
    /****************************************************************************************************
        Created by CGI, Kevin 2015-09-14
            Return a new instance of date. Parameter format is 'yyyyMMDD'
    ****************************************************************************************************/
    public static date getDate(string myDate){
        
        try{
            integer year = integer.valueOf(myDate.subString(0,4));
            integer month = integer.valueOf(myDate.subString(4,6));
            integer days = integer.valueOf(myDate.subString(6,8));
            return date.newInstance(year, month, days);
        }catch(Exception ex){}
        
        return null;
        
    }
    
    /****************************************************************************************************
        Created by David D
            Return a date in format yyyy-m-dd
    ****************************************************************************************************/
    public static String formatDate(Date d)
    {
        String ret = d.year() + '-';

        if(d.month() < 10) ret += '0';
        ret += d.month()+'-';
        
        if(d.day() <10) ret += '0';
        ret += d.day();
        
        return ret;
    }
    
    /****************************************************************************************************
    Created by Kevin Ky 2015-09-30
        Get the Order Label base on the api name
    ****************************************************************************************************/
    public static map<String,String> getOrderLabelByApiName(set<String> apiNames){
        
        Schema.DescribeSObjectResult r = Order.sObjectType.getDescribe();
        map<String,String> apiNames_label =  new map<String,String>();
        for(string apiName : r.fields.getMap().keySet()){
            if(apiNames.contains(apiName.toLowerCase())){
                //Add product api name and label in my map
                apiNames_label.put(apiName,r.fields.getMap().get(apiName).getDescribe().getLabel());
            }
        }
        return apiNames_label;
    }
    public static map<String,String> getOrderLabelByApiName(){
        
        Schema.DescribeSObjectResult r = Order.sObjectType.getDescribe();
        map<String,String> apiNames_label =  new map<String,String>();
        for(string apiName : r.fields.getMap().keySet()){
            apiNames_label.put(apiName,r.fields.getMap().get(apiName).getDescribe().getLabel());
        }
        return apiNames_label;
    }
    
    /****************************************************************************************************
    Created by Kevin Ky 2015-09-30
        Get the Order Item Label base on the api name
    ****************************************************************************************************/
    public static map<String,String> getOrderItemLabelByApiName(set<String> apiNames){
        
        Schema.DescribeSObjectResult r = OrderItem.sObjectType.getDescribe();
        map<String,String> apiNames_label =  new map<String,String>();
        for(string apiName : r.fields.getMap().keySet()){
            if(apiNames.contains(apiName.toLowerCase())){
                //Add product api name and label in my map
                apiNames_label.put(apiName,r.fields.getMap().get(apiName).getDescribe().getLabel());
            }
        }
        return apiNames_label;
    }
    public static map<String,String> getOrderItemLabelByApiName(){
        
        Schema.DescribeSObjectResult r = OrderItem.sObjectType.getDescribe();
        map<String,String> apiNames_label =  new map<String,String>();
        for(string apiName : r.fields.getMap().keySet()){
            //Add product api name and label in my map
            apiNames_label.put(apiName,r.fields.getMap().get(apiName).getDescribe().getLabel());
        }
        return apiNames_label;
    }
    

    /****************************************************************************************************
        Created by CGI, Thai 2015-08-24
            Return map of name of record type and its ID
    ****************************************************************************************************/
    public static Map<String, Id> getRTmapName_Id(String strObjectName, List<String> listDevName) {
        Map<String, Id> mapName_Id = new Map<String, Id>();
        
        //*** build query command
        String SOQL = 'select Id, DeveloperName from RecordType where SObjectType = :strObjectName';
        if (listDevName != null && listDevName.size() > 0)
            SOQL += ' and DeveloperName in :listDevName';
        
        //*** build and return map of name of record type and its ID
        for (RecordType rt : Database.query(SOQL))
            mapName_Id.put(rt.DeveloperName, rt.Id);
        return mapName_Id;
    } //*** end of "getRTmapName_Id"


    /****************************************************************************************************
        Created by CGI, David D 2015-08-24
            Return random String
    ****************************************************************************************************/
    public static String generateRandomString(Integer len) 
    {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        
        while (randStr.length() < len) 
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
    
        return randStr; 
    }

    public static String generateRandomDigit(Integer len)
    {
        final String chars = '0123456789';
        String randStr = '';
        
        while (randStr.length() < len) 
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }

        return randStr; 
    }

    public static List<Schema.FieldSetMember> readFieldSet(String objectName, String fieldSetName)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields(); 
    }  

    public static List<Schema.PicklistEntry> getPicklistEntries(String objectName, String fieldName)
    {
        return Schema.getGlobalDescribe().get(objectName).newSObject().getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues(); 
    }
    
    public static List<SelectOption> getPicklistSelectOptions(String objectName, String fieldName, Boolean showBlank)
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.PicklistEntry> entries = getPicklistEntries(objectName, fieldName);
        
        if(showBlank) options.add(new SelectOption('', ''));
        
        for( Schema.PicklistEntry f : entries)
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        
        return options;
    }
    
    public static List<SelectOption> getFieldSetSelectOptions(String objectName, String fieldSetName, Boolean showBlank)
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.FieldSetMember> entries = readFieldSet(objectName, fieldSetName);
        
        if(showBlank) options.add(new SelectOption('', ''));
        
        for(Schema.FieldSetMember f : entries)
            options.add(new SelectOption(f.getFieldPath(), f.getLabel()));
        
        return options;
    }
    
    public static Map<String,List<SelectOption>> getDependentOptions(String objName, String contrfieldName, String depfieldName)
    {
        String objectName = objName.toLowerCase();
        String controllingField = contrfieldName.toLowerCase();
        String dependentField = depfieldName.toLowerCase();

        Map<String,List<SelectOption>> objResults = new Map<String,List<SelectOption>>();

        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
        }

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){ return objResults; }

        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }

        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
        objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String value = ctrlentry.getValue();
            objResults.put(value,new List<SelectOption>());
            controllingIndexes.add(contrIndex);
        }

        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
            Schema.PicklistEntry depentry = depEntries[dependentIndex];
            objEntries.add(depentry);
        } 

        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){ continue; }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrValue = contrEntries[idx].getValue();
                objResults.get(contrValue).add(new SelectOption(objJson.value,objJson.label));
            }
        }
        
        objEntries = null; objJsonEntries = null;
        return objResults;
    }

    public static List<String> getPicklistValues(String objectName, String fieldName)
    {
        List<String> result = new List<String>(); 

        for(Schema.PicklistEntry pe : getPicklistEntries(objectName, fieldName))
        {
            if(pe.isActive())
                result.add(pe.getValue());
        }

        return result;
    }

    public static Integer generateRandomInteger(Integer min, Integer max)
    {
        return  min + Math.round(Math.random() * (max-min));
    }

    public static Decimal generateRandomDecimal(Decimal min, Decimal max)
    {
        return  min + Math.random() * (max-min);
    }

    public static String getRandomPicklistValue(String objectName, String fieldName)
    {
        String ret = ''; 

        List<String> picklistValues = getPicklistValues(objectName, fieldName);
        Integer rd = generateRandomInteger(0,picklistValues.size()-1);

        return picklistValues[rd];
    }
    

    /****************************************************************************************************
        Created by CGI, Thai 2015-08-31
            Return a map of picklist value and its translation
    ****************************************************************************************************/
    public static Map<String, String> getPicklistValue_Label(String strObjectName, String strFieldName) {
        Map<String, String> mapValue_Label = new Map<String, String>();
        
        try {
            //*** build map of picklist value and its translation
            for (Schema.PicklistEntry p : Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap().get(strFieldName).getDescribe().getPicklistValues())
                mapValue_Label.put(p.getValue(), p.getLabel());
        } catch(Exception e) {
            //*** will return empty map if error
            mapValue_Label.clear();
        }
        return mapValue_Label;
    } //*** end of "getPicklistValue_Label"
    

    /****************************************************************************************************
        Created by CGI, Thai 2015-08-31
            Return the translation of a picklist value
    ****************************************************************************************************/
    public static String getPicklistLabel(String strObjectName, String strFieldName, String strKey) {
        String PicklistLabel;
        
        try {
            //*** picklist translation is the trimmed picklist value by default
            PicklistLabel = strKey.trim();
            //*** search translation for picklist value
            for (Schema.PicklistEntry p : Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap().get(strFieldName).getDescribe().getPicklistValues())
                if (PicklistLabel.equalsIgnoreCase(p.getValue())) {
                    PicklistLabel = p.getLabel(); break;
                }
        } catch (Exception e) {
            //*** will return original picklist value of error
            PicklistLabel = strKey;
        }
        return PicklistLabel;
    } //*** end of "getPicklistLabel"

    /****************************************************************************************************
        Created by CGI, David D 2015-09-08
            Return value defined in number field for a setting
    ****************************************************************************************************/
    public static Integer getIntegerSetting(String settingName) {
        return (Integer) getNumericSetting(settingName);
    } //*** end of "getIntegerSetting"

    public static Double getNumericSetting(String settingName) {
        //return getNumericSetting(settingName, 'Number_1__c');
        Apex_Setting__c cs = Apex_Setting__c.getValues(settingName);
        if (cs == null || cs.Number_1__c == null)
            return 0;
        else
            return cs.Number_1__c;
    } //*** end of "getNumericSetting"

    //public static Double getNumericSetting(String settingName, String fieldName) {
    //    Apex_Setting__c cs = Apex_Setting__c.getValues(settingName);
    //    return ((cs == null || cs.get(fieldName) == null) ? 0 : Double.valueOf(cs.get(fieldName)));
    //} //*** end of "getNumericSetting"
    
       
    /****************************************************************************************************
        Created by CGI, Thai 2015-09-01
            Return value defined in text field for a setting
    ****************************************************************************************************/
    public static String getTextSetting(String settingName) {
        //return getTextSetting(settingName, 'Text_1__c');
        Apex_Setting__c cs = Apex_Setting__c.getValues(settingName);
        if (cs == null || cs.Text_1__c == null)
            return '';
        else
            return cs.Text_1__c;
    } //*** end of "getTextSetting"
    //public static String getTextSetting(String settingName, String fieldName) {
    //    Apex_Setting__c cs = Apex_Setting__c.getValues(settingName);
    //    return ((cs == null || cs.get(fieldName) == null) ? '' : String.valueOf(cs.get(fieldName)));
    //} //*** end of "getTextSetting"
    
    
    /****************************************************************************************************
        Created by CGI, Thai 2015-09-01
            Split value defined in text field for a setting to an array according to provided separator
            and return the array
            *** Beware that separator should in proper REGEX expression
    ****************************************************************************************************/
    public static List<String> getTextSettingToArray(String settingName, String separator) {
        //return getTextSettingToArray(settingName, 'Text_1__c', separator);
        Apex_Setting__c cs = Apex_Setting__c.getValues(settingName);
        if (cs == null || cs.Text_1__c == null)
            return new List<String>();
        else
            return cs.Text_1__c.split(separator);
    } //*** end of "getTextSettingToArray"
    //public static List<String> getTextSettingToArray(String settingName, String fieldName, String separator) {
    //    Apex_Setting__c cs = Apex_Setting__c.getValues(settingName);
    //    return ((cs == null || cs.get(fieldName) == null) ? new List<String>() : String.valueOf(cs.get(fieldName)).split(separator));
    //} //*** end of "getTextSettingToArray"
    
    
    /****************************************************************************************************
        Created by CGI, Thai 2015-09-01
            Read sequential parameters (setting concatenated with a sequential index starting by 1)
            and return its values in an array of string
    ****************************************************************************************************/
    public static String getSeqTextSetting(String settingName, String separator) {
        //return getSeqTextSetting(settingName, 'Text_1__c', separator);
        List<String> listSetting = getSeqTextSettingToArray(settingName);
        return ((listSetting.size() == 0) ? '' : String.join(listSetting, separator));
    } //*** end of "getSeqTextSetting"
    //public static String getSeqTextSetting(String settingName, String fieldName, String separator) {
    //    List<String> listSetting = getSeqTextSettingToArray(settingName, fieldName);
    //    return ((listSetting.size() == 0) ? '' : String.join(listSetting, separator));
    //} //*** end of "getSeqTextSetting"
    
    
    /****************************************************************************************************
        Created by CGI, Thai 2015-09-01
            Read sequential parameters (setting concatenated with a sequential index starting by 1)
            and return its values in an array of string
    ****************************************************************************************************/
    public static List<String> getSeqTextSettingToArray(String settingName) {
        //return getSeqTextSettingToArray(settingName, 'Text_1__c');
        Apex_Setting__c cs;
        List<String> listSetting = new List<String>();
        String fieldValues = '';
        for (Integer i1 = 1; i1 > 0; i1++) {
            cs = Apex_Setting__c.getValues(settingName + i1);
            if (cs == null)
                break;
            else if (cs.Text_1__c != null)
                listSetting.add(String.valueOf(cs.Text_1__c));
        }
        
        return listSetting;
    } //*** end of "getSeqTextSettingToArray"
    //public static List<String> getSeqTextSettingToArray(String settingName, String fieldName) {
    //    Apex_Setting__c cs;
    //    List<String> listSetting = new List<String>();
    //    String fieldValues = '';
    //    for (Integer i1 = 1; i1 > 0; i1++) {
    //        cs = Apex_Setting__c.getValues(settingName + i1);
    //        if (cs == null)
    //            break;
    //        else if (cs.get(fieldName) != null)
    //            listSetting.add(String.valueOf(cs.get(fieldName)));
    //    }
        
    //    return listSetting;
    //} //*** end of "getSeqTextSettingToArray"
    
    
    /****************************************************************************************************
        Created by CGI, Thai 2015-10-09
            Return authorization header for SAP call outs
    ****************************************************************************************************/
    public static String getSAPauthorization() {
        Blob headerValue = Blob.valueOf(IEC_SAP_Settings__c.getOrgDefaults().Web_Service_Username__c + ':' + IECUtil.DecryptParameter(IEC_SAP_Settings__c.getOrgDefaults().Web_Service_Password__c));
        return 'Basic '+ EncodingUtil.base64Encode(headerValue);
    } //*** end of "getSAPauthorization"
    
    
    /****************************************************************************************************
        Created by CGI, Thai 2015-10-14
            Replace SOAP endpoint domain in WSDL by proper domain from SFDC custom setting
    ****************************************************************************************************/
    public static String fixEndpointDomain(String endpoint) {
        return IEC_SAP_Settings__c.getOrgDefaults().Web_Service_endpoint__c + endpoint.substring(endpoint.indexOf('?'));
    } //*** end of "fixEndpointDomain"


    /****************************************************************************************************
        Created by CGI, Thai 2015-10-30
            Search values from a selection list
    ****************************************************************************************************/
    public static Integer findItemInSelectList(List<SelectOption> picklist, String searchCode, String searchName) {
        Integer i1;
        
        //*** find by code first -> skip the first item by assuming it is empty
        for (i1 = 1; i1 < picklist.size(); i1++)
            if (picklist[i1].getValue() == searchCode)
                break;
        
        //*** find by name if not found by code -> skip the first item by assuming it is empty
        if (i1 >= picklist.size())
            for (i1 = 1; i1 < picklist.size(); i1++)
                if (picklist[i1].getLabel() == searchName)
                    break;
        
        //*** if found then return index otherwise return a negative number
        return ((i1 >= picklist.size()) ? -1 : i1);
    } //*** end of "findItemInSelectList"


    /****************************************************************************************************
        Created by CGI Thai 2015-11-05
            Build a map from a string
    ****************************************************************************************************/
    public static Map<String,String> buildMapFromString(String text, String LineSeparator, String Key_ValueSeparator) {
        Map<String, String> mapKey_Value = new Map<String, String>();
        Integer pos, Key_ValueLength;
        
        try {
            Key_ValueLength = Key_ValueSeparator.length();
            
            //*** split input text to multiple lines based on line separator LineSeparator
            //*** for each line find separator of key and value based on LineSeparator -> ignore line if not found
            for (String line : text.split(LineSeparator)) {
                pos = line.indexOf(Key_ValueSeparator);
                if (pos > 0)
                    mapKey_Value.put(line.left(pos), line.substring(pos + Key_ValueLength));
            }
        } catch (Exception e) {}
        
        return mapKey_Value;
    } //*** end of "buildMapFromString"

    public static String truncate(String str, Integer size)
    {
        if(str == null)
            return ''; 
        else 
            return str.left(size); 
    }
    
    public static String truncate(String str, Integer start, Integer size)
    {
        return (str == null || str.length() <= start)  ?   '' :   str.substring(start).left(size);
    }


    /****************************************************************************************************
        Created by CGI Thai 2015-11-27
            Get default currency
    ****************************************************************************************************/
    public static String getDefaultCurrency() {
        try
        {
            return [select IsoCode from CurrencyType where IsCorporate = true limit 1][0].IsoCode;
        }
        catch (Exception e)
        {
            return UserInfo.getDefaultCurrency();
        }
    } //*** end of "getDefaultCurrency"
    
    /****************************************************************************************************
        Created by CGI David D 2015-12-22
            Get RecordType Id by Name
    ****************************************************************************************************/
    public static Id getRecordTypeId(String objectName, String recordTypeName)
    {
        try
        {
            return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        catch(Exception ex)
        {
            return null;
        }
    }
    
    /****************************************************************************************************
        Created by CGI Kevin Ky 2015-12-29
            Get RecordType Id by Name
    ****************************************************************************************************/
    public static map<String,Id> getRecordTypeIdByName(String sobjectType){
        
        map<String,Id> recordTypeName_Id = new map<String,Id>();

        List<RecordType> lstRecordType = [SELECT id, Name from RecordType where sObjectType = :sobjectType and isActive = true];
        for(RecordType rt : lstRecordType){
            recordTypeName_Id.put(rt.Name.toLowerCase(),rt.Id);
        }

        return recordTypeName_Id;
    }
    
    /****************************************************************************************************
        Created by CGI Thai 2016-03-23
            Replace newline character by something else.  Developped for Street field
    ****************************************************************************************************/
    public static String removeNewline(String text)
    {
        if (String.isBlank(text))
            return text;
        else
            return text.replace('\r', ',').replace('\n', ' ');
    } //*** end of "removeNewline"


	/****************************************************************************************************
		Enhancement split address lines
		Add adddress spliting logic
	****************************************************************************************************/
	public static List<String> splitAddress(String addressIn, Integer size) {
		String addressLine1 = '';
		String addressLine2 = '';
		
		if(!String.isBlank(addressIn)) {
			String address = addressIn.replace(',', '');
			List<String> elem = address.split(' ');
			String prev= '';
			addressLine1 = elem[0];
			Integer counter = 1;
			while(addressLine1.length() <= size && counter < elem.size()) {
				String calc = addressLine1 + ' ' + elem[counter];
				if(calc.length() < size) {
					addressLine1 += ' ' + elem[counter];
				} else {
					break;
				}
				counter++;
			}
			
			if(addressLine1.length() > size) {
				addressLine1 = Utility.truncate(address, size);
				addressLine2 = Utility.truncate(address, size, size);
			} else {
				while(counter < elem.size()) {
					addressLine2 += elem[counter] + ' ';
					counter++;
				}
				addressLine2 = addressLine2.trim();
			}
			
			if(addressLine2.length() > size) {
				addressLine1 = Utility.truncate(address, size);
				addressLine2 = Utility.truncate(address, size, size);
			}
		}
		
		return new List<String> {addressLine1, addressLine2};
	}
} //*** end of class
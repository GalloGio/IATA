public class AMS_AccreditationOnlineTriggerHelper {

    public static void prepopulateAbbreviatedFields(AMS_Pax_Accreditation_Form__c a, AMS_Pax_Accreditation_Form__c olda){
        
        Integer length = 0;
        if(AMS_Utils.LocationClassCARGO.contains(a.Location_Class__c))    length = 60;
        else if(AMS_Utils.LocationClassPASSENGER.contains(a.Location_Class__c))   length = 30;
        
        // abbreviated field is populated automatically if
        // abbreviated is null
        // OR
        // is update, full field is changed and abbreviated is not

        if(a.Abbreviated_address__c == null || (olda!=null && a.Branch_Office_Street_name_number__c!=olda.Branch_Office_Street_name_number__c && a.Abbreviated_address__c == olda.Abbreviated_address__c)){
            String str = a.Branch_Office_Street_name_number__c;
            if(str!=null && str.length()>length) str = str.substring(0,length);
            a.Abbreviated_address__c = str;
        }

        
        if(a.Abbreviated_name__c == null || (olda!=null && a.Account_Name__c!=olda.Account_Name__c && a.Abbreviated_name__c == olda.Abbreviated_name__c)){
            String str = a.Account_Name__c;
            if(str!=null && str.length()>length) str = str.substring(0,length);
            a.Abbreviated_name__c = str;
        }
        
    }
    
}
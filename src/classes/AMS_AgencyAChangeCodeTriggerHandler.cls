public class AMS_AgencyAChangeCodeTriggerHandler{

//    public static void handleBeforeInsert(List<Agency_Applied_Change_code__c> aaccList){
//        processChanges(aaccList);
//    }

//    public static void handleBeforeUpdate(List<Agency_Applied_Change_code__c> aaccList){
//        processChanges(aaccList);
//    }

//    private static void processChanges(List<Agency_Applied_Change_code__c> aaccList){

//        /*Map<String,String> bulletinMemos = buildBulletinMemosMap();

//        Map<Id,Schema.RecordTypeInfo> rtMap = Agency_Applied_Change_code__c.sObjectType.getDescribe().getRecordTypeInfosById();

//        Set<Id> agencyIds = (new Map<Id, AMS_Agency__c>([SELECT Id FROM AMS_Agency__c])).keySet();
//        Map<Id,AMS_Agency__c> agencyMap = new Map<Id, AMS_Agency__c>([SELECT Id, Agency_Status__c FROM AMS_Agency__c WHERE Id IN :agencyIds]);
//        List<AMS_Agency__c> agenciesToUpdate = new List<AMS_Agency__c>();

//        //find the bulletin memo text
//        for(Agency_Applied_Change_code__c aacc: aaccList){
//            String rtName = rtMap.get(aacc.recordTypeID).getName();
//            String key = (rtName + aacc.Reason__c).toLowerCase();
//            System.debug('This is the key to be found: '+ key);
//            aacc.Bulletin_Memo_Text__c = bulletinMemos.get(key);
//            AMS_Agency__c agToupdate = setAgencyStatus(agencyMap.get(aacc.Agency__c), rtName, aacc.Reason__c);
//            if(agToupdate != null)
//                agenciesToUpdate.add(agToupdate);
//        }

//        update agenciesToUpdate;*/

//    }

//    private static Map<String,String> buildBulletinMemosMap(){

//        /*Map<String,String> bulletinMemosMap = new Map<String,String>();

//        for(AMS_ChangeCode_BulletinMemo__c bm: AMS_ChangeCode_BulletinMemo__c.getall().values()){
//            String key = (bm.Record_Type__c + bm.Reason__c).toLowerCase();
//            bulletinMemosMap.put(key, bm.Bulletin_Memo_Text__c);
//        }

//        return bulletinMemosMap;*/
//        return null;

//    }

//    private static AMS_Agency__c setAgencyStatus(AMS_Agency__c ag, String recordTypeName, String reason){

//        String status;

//        if(Pattern.matches('CCF|CHF|CLF|CMF|CNF|COR|CSF|CWD|FIN|NCA|RCR|REC|TCH', recordTypeName)){status = '9';}
//        else if(Pattern.matches('DIS|TAP|TER', recordTypeName)){status = '0';}
//        else if(Pattern.matches('NAC|NEP|NEW', recordTypeName)){status = '2';}
//        else if(Pattern.matches('CAD|CAS|CHG|CLO|DWD|FPY|IRW|RPY', recordTypeName)){/*NOTHING TO DO*/}
//        else if(Pattern.matches('CHC|CHI|CHJ|CHL|CHM|CHN|CHO|CHS|CLI|MCH', recordTypeName)){
//        	if(getIATANumericStatus(ag.Agency_Status__c) == 9)
//                status = '8';
//        }
//        else if(recordTypeName == 'DEF'){status = '5';}
//        else if(recordTypeName == 'IRR'){
//            if(reason=='Non submission of financial security')
//            	status = '6';
//        }
//        else if(recordTypeName == 'NOT')
//            status = '6';
//        else if(recordTypeName == 'NWD'){
//            if(reason=='New Application - BR')
//            	status = '0';
//        	else
//                status = '2';
//        }
//        else if(recordTypeName == 'RVW'){
//            if(reason=='Non submission of financial security' || reason=='Sanity Check failure of financial statement')
//				status = '7';
//        	else
//                status = '6';
//        }

//        if(status != null && status != ''){
//        	ag.Agency_Status__c = getIATAReadableStatus(status);
//            return ag;
//        }

//        return null;

//    }

//    public static String getIATAReadableStatus(String endorsmentCode){

//        if(endorsmentCode == '0')
//            return 'Terminated';
//        if(endorsmentCode == '1')
//            return 'Not accreditated';
//        if(endorsmentCode == '2')
//            return 'New application pending';
//        if(endorsmentCode == '3')
//            return 'Not in operation';
//        if(endorsmentCode == '4')
//            return 'Listed';
//        if(endorsmentCode ==  '5')
//            return 'Cash basis/no commission';
//        if(endorsmentCode == '6')
//            return 'Cash basis/with commission';
//        if(endorsmentCode == '7')
//            return 'Under review';
//        if(endorsmentCode == '8')
//            return 'Changes processed';
//        if(endorsmentCode == '9')
//            return 'Accredited';

//        return null;
//    }

//    public static String getIATANReadableStatus(String endorsmentCode){

//        if(endorsmentCode == '0')
//            return 'Terminated';
//        if(endorsmentCode == '2')
//            return 'New application pending';
//        if(endorsmentCode == '4')
//            return 'Listed';
//        if(endorsmentCode ==  '5')
//            return 'Listed(BSP)';
//        if(endorsmentCode == '6')
//            return 'Under review';
//        if(endorsmentCode == '7')
//            return 'Accredited';

//        return null;
//    }

//    public static Integer getIATANumericStatus(String endorsmentCode){

//        if(endorsmentCode == 'Terminated')
//            return 0;
//        else if(endorsmentCode == 'Not accreditated')
//            return 1;
//        else if(endorsmentCode == 'New application pending')
//            return 2;
//        else if(endorsmentCode == 'Not in operation')
//            return 3;
//        else if(endorsmentCode == 'Listed')
//            return 4;
//        else if(endorsmentCode ==  'Cash basis/no commission')
//            return 5;
//        else if(endorsmentCode == 'Cash basis/with commission')
//            return 6;
//        else if(endorsmentCode == 'Under review')
//            return 7;
//        else if(endorsmentCode == 'Changes processed')
//            return 8;
//        else if(endorsmentCode == 'Accredited')
//            return 9;

//        return null;
//    }

//    public static Integer getIATANNumericStatus(String endorsmentCode){

//        if(endorsmentCode == 'Terminated')
//            return 0;
//        else if(endorsmentCode == 'New application pending')
//            return 2;
//        else if(endorsmentCode == 'Listed')
//            return 4;
//        else if(endorsmentCode ==  'Listed(BSP)')
//            return 5;
//        else if(endorsmentCode == 'Under review')
//            return 6;
//        else if(endorsmentCode == 'Accredited')
//            return 7;

//        return null;
//    }

}

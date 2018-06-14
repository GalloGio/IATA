/****************************************************************************************************
    Created by CGI, Thai 2015-08-24
        Class encapsulates query logic for "Product_Record_Type_Mapping__c"
****************************************************************************************************/

public class Product_Record_Type_Mapping_Sel {


/****************************************************************************************************
    Created by CGI, Thai 2015-08-24
        Find record types for passed record indexes in map format
        Code is covered in test method "test_setRecordType" of class "Product_Svc_Test"
****************************************************************************************************/
public static Map<Integer, Id> getRecordIndex_RecordTypeId(List<Integer> listRecordIndex, List<String> listDivision, List<String> listChannel){
    //*** build map of all record types
    Map<String, Id> mapRecordType_Id = Utility.getRTmapName_Id('Product2', null);
    
    //*** prepare returning map
    Map<Integer, Id> mapIndex_RecordTypeId = new Map<Integer, Id>();
    Map<String, Integer> mapKey_Index = new Map<String, Integer>();
    for (Integer i1 = 0; i1 < listRecordIndex.size(); i1++) {
        mapIndex_RecordTypeId.put(listRecordIndex[i1], mapRecordType_Id.get('Unclassified'));
        mapKey_Index.put(listDivision[i1] + '/' + listChannel[i1], listRecordIndex[i1]);
    }
    
    //*** build and map between profit center and product manager
    for (Product_Record_Type_Mapping__c rt : [select Division__c, Sales_Channel__c, Record_Type_for_Product__c
                                              from Product_Record_Type_Mapping__c
                                              where Record_Type_for_Product__c != null
                                                and (Division__c = null or Division__c in :listDivision)
                                                and (Sales_Channel__c = null or Sales_Channel__c in :listChannel)])
        if (mapKey_Index.containsKey(rt.Division__c + '/' + rt.Sales_Channel__c) && mapRecordType_Id.containsKey(rt.Record_Type_for_Product__c))
            mapIndex_RecordTypeId.put(mapKey_Index.get(rt.Division__c + '/' + rt.Sales_Channel__c), mapRecordType_Id.get(rt.Record_Type_for_Product__c));
        //else if (mapKey_Index.containsKey(rt.Division__c + '/null') && mapRecordType_Id.containsKey(rt.Record_Type_for_Product__c))
        //    mapIndex_RecordTypeId.put(mapKey_Index.get(rt.Division__c + '/null'), mapRecordType_Id.get(rt.Record_Type_for_Product__c));
        //else if (mapKey_Index.containsKey('null/' + rt.Sales_Channel__c) && mapRecordType_Id.containsKey(rt.Record_Type_for_Product__c))
        //    mapIndex_RecordTypeId.put(mapKey_Index.get('null/' + rt.Sales_Channel__c), mapRecordType_Id.get(rt.Record_Type_for_Product__c));
    return mapIndex_RecordTypeId;
} //*** end of "getRecordIndex_RecordTypeId"


} //*** end of class
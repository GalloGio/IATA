/****************************************************************************************************
    Created by CGI, Thai 2015-08-24
        Cover code of class "Utility"
****************************************************************************************************/

@isTest(seeAllData=false)
public class Utility_Test {


/****************************************************************************************************
    Created by CGI, Thai 2015-08-22
        Cover code of method "getRTmapName_Id"
****************************************************************************************************/
static testMethod void test_getRTmapName_Id() {
    List<String> listDevName = new List<String>();
    List<Id> listId = new List<Id>();
    String strObjectName;
    Map<String, Id> mapName_Id;
    
    //*** get an object having record type with its first record type 
    for (RecordType rt : [select Id, SObjectType, DeveloperName from RecordType limit 1]) {
        strObjectName = rt.SObjectType;
        listDevName.add(rt.DeveloperName);
        listId.add(rt.Id);
    }
    
    mapName_Id = Utility.getRTmapName_Id(strObjectName, listDevName);
    system.assert(mapName_Id.size() == 1 && mapName_Id.get(listDevName[0]) == listId[0], 'Incorrect map: ' + mapName_Id);
} //*** end of "test_getRTmapName_Id"

/****************************************************************************************************
    Created by CGI, Kevin 2015-08-25
        Cover code of method "getNewTask"
****************************************************************************************************/
static testMethod void test_getNewTask(){
    User user = TestDataGenerator.generateUser('Standard User',false);
    system.debug('user.Id::'+user);
    Task task = Utility.getNewTask(user.id,'Subject','Description');
    system.assert(task.Subject == 'Subject', 'Incorrect instance of Task');
    
    utility.getNumberOfDays(date.today());
}

/****************************************************************************************************
    Created by CGI, Kevin 2015-09-15
        Cover code of method "getNewTask"
****************************************************************************************************/
static testMethod void test_getDate(){
	Date dt = Utility.getDate('20150211');

    Utility.formatDate(dt);
}

/****************************************************************************************************
    Created by CGI, Kevin 2015-08-25
        Cover code of method "sendEmail"
****************************************************************************************************/
static testMethod void test_sendEmail(){
    List<String> recipients = new list<String>{'test1@test.com','test1@test.com'};
    String emailSubject = 'Subject';
    String body = 'Body';
    
    list<Messaging.EmailFileAttachment> lstAttach = new list<Messaging.EmailFileAttachment>();
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    attach.setContentType('application/pdf');
    attach.setFileName('testPdf.pdf');
    attach.setInline(false);
    attach.Body = Blob.valueOf('Body Text');
    lstAttach.add(attach);
    
    try{
        Utility.sendEmail(recipients,emailSubject,body,true, lstAttach);
        system.assert(recipients.size() == 2, 'Incorrect number of recipients');
    }catch(Exception ex){}
}

/****************************************************************************************************
    Created by CGI, Kevin 2015-08-25
        Cover code of method "getAdminEmails"
****************************************************************************************************/
static testMethod void test_getAdminEmails(){
    //email_notification_Administrator__c ena = new email_notification_Administrator__c();
	Apex_Setting__c ena = new Apex_Setting__c();
	ena.Name = 'Products email notification admin';
	ena.Text_1__c = 'test@test.com';
	insert ena;
    
    Utility.getAdminEmails();
    system.assert(ena.Name == 'Products email notification admin', 'Incorrect Administrator name');
}

/****************************************************************************************************
    Created by CGI, Thai 2015-08-31
        Cover code of method "getPicklistValue_Label"
****************************************************************************************************/
static testMethod void test_getPicklistValue_Label() {
    Map<String, String> mapCheck;
    
    mapCheck = Utility.getPicklistValue_Label('Product2', 'Family2');
    system.assert(mapCheck.size() == 0, 'Have translations for inexistant field: ' + mapCheck);
    mapCheck = Utility.getPicklistValue_Label('Product2', 'Family');
    system.assert(mapCheck.size() != 0, 'DON\'T have translations for existant field: ' + mapCheck);
} //*** end of "test_getPicklistValue_Label"

/****************************************************************************************************
    Created by CGI, Thai 2015-08-31
        Cover code of method "getPicklistLabel"
****************************************************************************************************/
static testMethod void test_getPicklistLabel() {
    String strCheck1, strCheck2;
    
    strCheck2 = null;
    strCheck1 = Utility.getPicklistLabel('Product2', 'Language__c', strCheck2);
    system.assert(strCheck1 == strCheck2, 'Have translation for \"' + strCheck2 + '\": ' + strCheck1);

    //Covert dependency picklist
    Utility.PicklistEntryWrapper picklistEntryWrp = new Utility.PicklistEntryWrapper();
    picklistEntryWrp.active = picklistEntryWrp.defaultValue = '';
    //picklistEntryWrp.defaultValue = '';
    Utility.getDependentOptions('Product2','Mega_Menu__c', 'Display_Ecom_Topic__c');

    //Cover get Order Label by Api Name
    Map<String,String> label_ApiName = Utility.getOrderLabelByApiName(new set<String>{'Type'});
    Utility.getOrderLabelByApiName();
    Utility.getOrderItemLabelByApiName(new set<String>{'Quantity'});
    Utility.getOrderItemLabelByApiName();
    
    //*** get 1 picklist value to get translated -> commented because no translation to implement
    //for (Schema.PicklistEntry p : Product2.Language__c.getDescribe().getPicklistValues()) {
    //    strCheck2 = p.getValue();
    //    break;
    //}
    //strCheck1 = Utility.getPicklistLabel('Product2', 'Language__c', strCheck2);
    //system.assert(strCheck1 != strCheck2, 'DON\'T have translation for \"' + strCheck2 + '\": ' + strCheck1);
} //*** end of "test_getPicklistLabel"

/****************************************************************************************************
    Created by CGI, Thai 2015-09-01
        Cover code of method "getTextSetting"
****************************************************************************************************/
static testMethod void test_getTextSetting() {
    //*** create settings
    List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
    listCS.add(new Apex_Setting__c(Name='setting1', Text_1__c='text 1'));
    insert listCS;
    
    //*** test
    String strCheck1;
    strCheck1 = Utility.getTextSetting('zzz');
    system.assert(strCheck1 == '', 'Have value for not exist setting: ' + strCheck1);
    strCheck1 = Utility.getTextSetting(listCS[0].Name);
    system.assert(strCheck1 == listCS[0].Text_1__c, 'Wrong value for setting: ' + strCheck1);
} //*** end of "test_getTextSetting"

/****************************************************************************************************
    Created by CGI, Thai 2015-09-01
        Cover code of method "getTextSettingToArray"
****************************************************************************************************/
static testMethod void test_getTextSettingToArray() {
    //*** create settings
    List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
    listCS.add(new Apex_Setting__c(Name='setting1', Text_1__c='text 1,text 2'));
    insert listCS;
    
    //*** test
    List<String> listCheck;
    listCheck = Utility.getTextSettingToArray('zzz', ',');
    system.assert(listCheck.size() == 0, 'Have value for not exist setting: ' + listCheck);
    listCheck = Utility.getTextSettingToArray(listCS[0].Name, ',');
    system.assert(listCheck.size() == 2 && listCheck[0] + ',' + listCheck[1] == listCS[0].Text_1__c, 'Wrong value for setting: ' + listCheck);
} //*** end of "test_getTextSettingToArray"

/****************************************************************************************************
    Created by CGI, Thai 2015-09-01
        Cover code of method "getSeqTextSetting"
****************************************************************************************************/
static testMethod void test_getSeqTextSetting() {
    //*** create settings
    List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
    listCS.add(new Apex_Setting__c(Name='setting1', Text_1__c='text 1'));
    listCS.add(new Apex_Setting__c(Name='setting2', Text_1__c='text 2'));
    insert listCS;
    
    //*** test
    String strCheck1;
    strCheck1 = Utility.getSeqTextSetting('zzz', ',');
    system.assert(strCheck1 == '', 'Have value for not exist setting: ' + strCheck1);
    strCheck1 = Utility.getSeqTextSetting('setting', ',');
    system.assert(strCheck1 == listCS[0].Text_1__c + ',' + listCS[1].Text_1__c, 'Wrong value for setting: ' + strCheck1);
} //*** end of "test_getSeqTextSetting"

/****************************************************************************************************
    Created by CGI, Thai 2015-09-01
        Cover code of method "getSeqTextSettingToArray"
****************************************************************************************************/
static testMethod void test_getSeqTextSettingToArray() {
    //*** create settings
    List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
    listCS.add(new Apex_Setting__c(Name='setting1', Text_1__c='text 1'));
    listCS.add(new Apex_Setting__c(Name='setting2', Text_1__c='text 2'));
    insert listCS;
    
    //*** test
    List<String> listCheck;
    /*listCheck = Utility.getSeqTextSettingToArray('zzz');
    system.assert(listCheck.size() == 0, 'Have value for not exist setting: ' + listCheck);*/
    listCheck = Utility.getSeqTextSettingToArray('setting');
    system.assert(listCheck.size() == 2 && listCheck[0] == listCS[0].Text_1__c && listCheck[1] == listCS[1].Text_1__c, 'Wrong value for setting: ' + listCheck);
} //*** end of "test_getSeqTextSettingToArray"

/****************************************************************************************************
    Created by CGI, Thai 2015-11-05
        Cover code of method "findItemInSelectList"
****************************************************************************************************/
static testMethod void test_findItemInSelectList() {
    List<SelectOption> picklist = new List<SelectOption>();
    picklist.add(new SelectOption('', ''));
    picklist.add(new SelectOption('key 1', 'label 1'));
    Integer ixCheck = Utility.findItemInSelectList(picklist, 'key 1', null);
    system.assert(ixCheck == 1, 'Wrong index: ' + ixCheck);
    ixCheck = Utility.findItemInSelectList(picklist, null, 'label 1');
    system.assert(ixCheck == 1, 'Wrong index: ' + ixCheck);
    ixCheck = Utility.findItemInSelectList(picklist, null, null);
    system.assert(ixCheck < 0, 'Wrong index: ' + ixCheck);
} //*** end of "test_findItemInSelectList"

/****************************************************************************************************
    Created by CGI, Thai 2015-11-05
        Cover code of method "buildMapFromString"
****************************************************************************************************/
static testMethod void test_buildMapFromString() {
    Map<String, String> mapKey_Value = Utility.buildMapFromString('key 1++label 1--++label 2--key 3++--++--key 5++label 5', '--', '++');
    system.assert(mapKey_Value.size() == 3, 'Wrong results: ' + mapKey_Value);
    system.assert(mapKey_Value.get('key 1') == 'label 1', 'Wrong results for "key 1": ' + mapKey_Value.get('key 1'));
    system.assert(mapKey_Value.get('key 2') == null, 'Wrong results for "key 2": ' + mapKey_Value.get('key 2'));
    system.assert(mapKey_Value.get('key 3') == '', 'Wrong results for "key 3": ' + mapKey_Value.get('key 3'));
    system.assert(mapKey_Value.get('key 4') == null, 'Wrong results for "key 4": ' + mapKey_Value.get('key 4'));
    system.assert(mapKey_Value.get('key 5') == 'label 5', 'Wrong results for "key 5": ' + mapKey_Value.get('key 5'));
} //*** end of "test_buildMapFromString"

/****************************************************************************************************
    Created by CGI, Thai 2016-03-23
        Cover code of method "removeNewline"
****************************************************************************************************/
static testMethod void test_removeNewline() {
    String text, checkText;
    
    text = null;
    checkText = Utility.removeNewline(text);
    system.assert(checkText == null, 'Wrong results: ' + checkText);
    text = 'a\r\nb';
    checkText = Utility.removeNewline(text);
    system.assert(checkText == 'a, b', 'Wrong results: ' + checkText);
} //*** end of "test_removeNewline"

} //*** end of class
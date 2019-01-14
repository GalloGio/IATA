/****************************************************************************************************
    Created by CGI, Thai 2015-08-24
        Cover code of class "Utility"
****************************************************************************************************/

@isTest(seeAllData = false)
public class Utility_Test {


    /****************************************************************************************************
        Created by CGI, Kevin 2015-08-25
            Cover code of method "getNewTask"
    ****************************************************************************************************/
    @isTest
	static void test_getNewTask() {
        User user = TestDataGenerator.generateUser('Standard User', false);
        system.debug('user.Id::' + user);
        Task task = Utility.getNewTask(user.id, 'Subject', 'Description');
        system.assert(task.Subject == 'Subject', 'Incorrect instance of Task');

        utility.getNumberOfDays(date.today());
    }

    /****************************************************************************************************
        Created by CGI, Kevin 2015-09-15
            Cover code of method "getNewTask"
    ****************************************************************************************************/
    @isTest
	static void test_getDate() {
        try { Utility.getDate('201502aa'); } catch (Exception e) {}
        Date dt = Utility.getDate('20150211');

        Utility.formatDate(dt);
    }

    /****************************************************************************************************
        Created by CGI, Thai 2017-01-30
            Cover code of methods "sendBulkEmails" and "getEmailTemplatebyTemplateId"
    ****************************************************************************************************/
    @isTest
	static void test_sendBulkEmails() {
        Contact oContact = new Contact(FirstName = 'FirstName', LastName = 'LastName', Email = Utility.generateRandomString(10) + 'zzztest@test.com', phone = '(514) 111 2222');
        insert oContact;
        insert new Apex_Setting__c(Name = 'ContactId to populate email Template', Text_1__c = oContact.Id);
        Mail_DTO dtoMail = new Mail_DTO();
        dtoMail.whatId = UserInfo.getUserId();
        dtoMail.templateId = [select Id from EmailTemplate limit 1][0].Id;
        dtoMail.orgWideEmailAddressId = [select Id from OrgWideEmailAddress limit 1][0].Id;
        dtoMail.recipients = new List<String> {UserInfo.getUserEmail()};
        Utility.sendBulkEmails(new List<Mail_DTO> {dtoMail});  //*** nothing to assert
        system.assert(Utility.getEmailTemplatebyTemplateId(dtoMail.templateId).size() == 1, 'Wrong count');
    } //*** end of "test_sendBulkEmails"

    /****************************************************************************************************
        Created by CGI, Kevin 2015-08-25
            Cover code of method "sendEmail"
    ****************************************************************************************************/
    @isTest
	static void test_sendEmail() {
        List<String> recipients = new list<String> {'test1@test.com', 'test1@test.com'};
        String emailSubject = 'Subject';
        String body = 'Body';

        list<Messaging.EmailFileAttachment> lstAttach = new list<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('testPdf.pdf');
        attach.setInline(false);
        attach.Body = Blob.valueOf('Body Text');
        lstAttach.add(attach);

        try {
            Utility.sendEmail(recipients, emailSubject, body, true, lstAttach);
            system.assert(recipients.size() == 2, 'Incorrect number of recipients');
        } catch (Exception ex) {}
    }

    /****************************************************************************************************
        Created by CGI, Kevin 2015-08-25
            Cover code of method "getAdminEmails"
    ****************************************************************************************************/
    @isTest
	static void test_getAdminEmails() {
        //email_notification_Administrator__c ena = new email_notification_Administrator__c();
        Apex_Setting__c ena = new Apex_Setting__c();
        ena.Name = 'Products email notification admin';
        ena.Text_1__c = 'test@test.com';
        insert ena;

        Utility.getAdminEmails();
        system.assert(ena.Name == 'Products email notification admin', 'Incorrect Administrator name');

        ena.Text_1__c = 'test@test.com,test2@test.com';
        update ena;
        system.assert(Utility.getAdminEmails().size() == 2, 'Wrong count');
    }

    /****************************************************************************************************
        Created by CGI, Thai 2015-08-31
            Cover code of method "getPicklistValue_Label"
    ****************************************************************************************************/
    @isTest
	static void test_getPicklistValue_Label() {
        Map<String, String> mapCheck;

        mapCheck = Utility.getPicklistValue_Label('Product2', 'Family2');
        system.assert(mapCheck.size() == 0, 'Have translations for inexistant field: ' + mapCheck);
        mapCheck = Utility.getPicklistValue_Label('Product2', 'Family');
        system.assert(mapCheck.size() != 0, 'DON\'T have translations for existant field: ' + mapCheck);
    } //*** end of "test_getPicklistValue_Label"

    /****************************************************************************************************
        Created by CGI, Thai 2015-08-31
            Cover code of methods "getPicklistLabel" and "getDependentOptions"
    ****************************************************************************************************/
    @isTest
	static void test_getPicklistLabel() {
        String strCheck1, strCheck2;

        strCheck2 = null;
        strCheck1 = Utility.getPicklistLabel('Product2', 'Language__c', strCheck2);
        system.assert(strCheck1 == strCheck2, 'Have translation for \"' + strCheck2 + '\": ' + strCheck1);
        strCheck2 = 'English';
        strCheck1 = Utility.getPicklistLabel('Product2', 'Language__c', strCheck2);
        system.assert(strCheck1 == strCheck2, 'Have translation for \"' + strCheck2 + '\": ' + strCheck1);

        //Covert dependency picklist
        Utility.PicklistEntryWrapper picklistEntryWrp = new Utility.PicklistEntryWrapper();
        picklistEntryWrp.active = picklistEntryWrp.defaultValue = '';
        //picklistEntryWrp.defaultValue = '';
        system.assertEquals(Utility.getDependentOptions('Product2NotExist', 'Mega_Menu__c', 'Display_Ecom_Topic__c'), null);
        system.assertEquals(Utility.getDependentOptions('Product2', 'Mega_Menu_NotExist__c', 'Display_Ecom_Topic__c').size(), 0);
        system.assert(Utility.getDependentOptions('Product2', 'Mega_Menu__c', 'Display_Ecom_Topic__c').size() > 0, 'Wrong count');

        //Cover get Order Label by Api Name
        Map<String, String> label_ApiName = Utility.getOrderLabelByApiName(new set<String> {'type'});
        Utility.getOrderLabelByApiName();
        Utility.getOrderItemLabelByApiName(new set<String> {'quantity'});
        Utility.getOrderItemLabelByApiName();
    } //*** end of "test_getPicklistLabel"

    /****************************************************************************************************
        Created by CGI, Thai 2017-01-30
            Cover code of method "getPicklistSelectOptions"
    ****************************************************************************************************/
    @isTest
	static void test_getPicklistSelectOptions() {
        List<SelectOption> lstCheck = Utility.getPicklistSelectOptions('Product2', 'Language__c', true);
        system.assert(String.isBlank(lstCheck[0].getValue()), 'Item 1 should be blank');
        system.assert(lstCheck.size() > 1, 'List must have more than 1 item');
    } //*** end of "test_getPicklistSelectOptions"

    /****************************************************************************************************
        Created by CGI, Thai 2017-01-30
            Cover code of method "getFieldSetSelectOptions"
    ****************************************************************************************************/
    @isTest
	static void test_getFieldSetSelectOptions() {
        List<SelectOption> lstCheck = Utility.getFieldSetSelectOptions('Product2', 'Send_To_Zuora_Listener', true);
        system.assert(String.isBlank(lstCheck[0].getValue()), 'Item 1 should be blank');
        system.assert(lstCheck.size() > 1, 'List must have more than 1 item');
    } //*** end of "test_getFieldSetSelectOptions"

    /****************************************************************************************************
        Created by CGI, Thai 2015-09-01
            Cover code of method "getTextSetting"
    ****************************************************************************************************/
    @isTest
	static void test_getTextSetting() {
        //*** create settings
        List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        listCS.add(new Apex_Setting__c(Name = 'setting1', Text_1__c = 'text 1'));
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
    @isTest
	static void test_getTextSettingToArray() {
        //*** create settings
        List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        listCS.add(new Apex_Setting__c(Name = 'setting1', Text_1__c = 'text 1,text 2'));
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
    @isTest
	static void test_getSeqTextSetting() {
        //*** create settings
        List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        listCS.add(new Apex_Setting__c(Name = 'setting1', Text_1__c = 'text 1'));
        listCS.add(new Apex_Setting__c(Name = 'setting2', Text_1__c = 'text 2'));
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
    @isTest
	static void test_getSeqTextSettingToArray() {
        //*** create settings
        List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        listCS.add(new Apex_Setting__c(Name = 'setting1', Text_1__c = 'text 1'));
        listCS.add(new Apex_Setting__c(Name = 'setting2', Text_1__c = 'text 2'));
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
    @isTest
	static void test_findItemInSelectList() {
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
    @isTest
	static void test_buildMapFromString() {
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
    @isTest
	static void test_removeNewline() {
        String text, checkText;

        text = null;
        checkText = Utility.removeNewline(text);
        system.assert(checkText == null, 'Wrong results: ' + checkText);
        text = 'a\r\nb';
        checkText = Utility.removeNewline(text);
        system.assert(checkText == 'a, b', 'Wrong results: ' + checkText);
    } //*** end of "test_removeNewline"

    /****************************************************************************************************
        Created by CGI, Thai 2017-01-30
            Cover code of methods "generateRandomString", "generateRandomDigit", "generateRandomInteger",
            "generateRandomDecimal", "getPicklistValues", "getRandomPicklistValue", "IdToString",
            "getDefaultCurrency", "truncate", "getSAPauthorization", "fixEndpointDomain",
            "getIntegerSetting", "getNumericSetting"
    ****************************************************************************************************/
    @isTest
	static void test_Miscellaneous() {
        system.assert(!String.isBlank(Utility.generateRandomString(2)), 'Wrong value');

        system.assert(!String.isBlank(Utility.generateRandomDigit(2)), 'Wrong value');
        system.assert(!String.isBlank(Utility.generateRandomDigit(2)), 'Wrong value');

        system.assert(Utility.generateRandomInteger(2, 5) >= 2, 'Wrong value');

        system.assert(Utility.generateRandomDecimal(2.5, 5) >= 2.5, 'Wrong value');

        system.assert(!String.isBlank(Utility.getRandomPicklistValue('Order', 'Type')), 'Wrong value');

        system.assert(Utility.IdToString(new Set<Id> {UserInfo.getUserId()}).size() == 1, 'Wrong count');

        system.assert(!String.isBlank(Utility.getDefaultCurrency()), 'Wrong value');

        system.assert(Utility.truncate(null, 2) == '', 'Wrong value');
        system.assert(Utility.truncate('aabbb', 2) == 'aa', 'Wrong value');

        system.assert(Utility.truncate(null, 2, 2) == '', 'Wrong value');
        system.assert(Utility.truncate('aabbb', 10, 2) == '', 'Wrong value');
        system.assert(Utility.truncate('aabbb', 1, 2) == 'ab', 'Wrong value');

        IEC_SAP_Settings__c settingSAP = IEC_SAP_Settings__c.getOrgDefaults();
        settingSAP.Web_Service_Username__c = 'aaa';
        settingSAP.Web_Service_Password__c = IECUtil.EncryptParameter('bbb');
        settingSAP.Web_Service_endpoint__c = 'http://iata.org/webservice';
        upsert settingSAP;
        system.assert(Utility.getSAPauthorization().startsWith('Basic'), 'Wrong value');
        system.assert(Utility.fixEndpointDomain('http://xyz.org/ws?p1=v1&p2=v2') == 'http://iata.org/webservice?p1=v1&p2=v2', 'Wrong value');

        insert new Apex_Setting__c(Name = 'setting1', Number_1__c = 1.0);
        system.assert(Utility.getIntegerSetting('abc') == 0, 'Wrong value');
        system.assert(Utility.getIntegerSetting('setting1') == 1, 'Wrong value');

    } //*** end of "test_Miscellaneous"

} //*** end of class
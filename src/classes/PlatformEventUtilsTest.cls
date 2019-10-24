/**
 * Created by LBERB on 22/10/2019.
 */

@IsTest
public with sharing class PlatformEventUtilsTest {

    private static testMethod void testSendFailAndSuccess(){
        String stmp = '';
        while(stmp.length() < 60){
            stmp += 'a';
        }

        PlatformEventUtils.clear();
        PlatformEventUtils.add(new AddressRoleBusinessContext__e(
                EventType__c = stmp,
                RecordType__c = '',
                RecordId__c = null
        ));

        System.assert(!PlatformEventUtils.send());

        PlatformEventUtils.clear();
        PlatformEventUtils.add(new AddressRoleBusinessContext__e(
                EventType__c = '',
                RecordType__c = '',
                RecordId__c = null
        ));

        System.assert(PlatformEventUtils.send());
    }
}
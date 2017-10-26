@isTest
public class ANG_ProgressBar_Test {

	public static testMethod void test1() {
        Portal_Applications__c p1 = new Portal_Applications__c (
            Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
            ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
            ANG_Accredited_Agents_Only__c = false,
            Agency__c = true
        );

        insert p1;

        ANG_ProgressBarSettings__c s1 = new ANG_ProgressBarSettings__c (
        	name = 'bla1',
			Field__c = 'Name',
			Label__c = 'node1',
			Object__c = 'PORTAL_APPLICATIONS__C',
			Order__c = 1,
			RecordType__c = 'test',
			ValueError__c = 'bla',
			ValueOk__c = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED
        );

        //insert s1;

        ANG_ProgressBarSettings__c s2 = new ANG_ProgressBarSettings__c (
        	name = 'bla2',
			Field__c = 'ANG_Restrict_by_Agency_Sector__c',
			Label__c = 'node1',
			Object__c = 'PORTAL_APPLICATIONS__C',
			Order__c = 2,
			RecordType__c = 'test',
			ValueError__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ValueOk__c = 'bla'
        );

        //insert s2;

        ANG_ProgressBarSettings__c s3 = new ANG_ProgressBarSettings__c (
        	name = 'bla3',
			Field__c = 'ANG_Restrict_by_Agency_Sector__c',
			Label__c = 'node1',
			Object__c = 'PORTAL_APPLICATIONS__C',
			Order__c = 3,
			RecordType__c = 'test',
			ValueError__c = '<notin>bla',
			ValueOk__c = '<notin>bla'
        );

        //insert s3;

        ANG_ProgressBarSettings__c s4 = new ANG_ProgressBarSettings__c (
        	name = 'bla4',
			Field__c = 'ANG_Restrict_by_Agency_Sector__c',
			Label__c = 'node1',
			Object__c = 'PORTAL_APPLICATIONS__C',
			Order__c = 4,
			RecordType__c = 'test',
			ValueError__c = 'bla',
			ValueOk__c = 'bla'
        );

        //insert s4;

        ANG_ProgressBarSettings__c s5 = new ANG_ProgressBarSettings__c (
        	name = 'bla5',
			Field__c = 'name',
			Label__c = 'node1',
			Object__c = 'ACCOUNT',
			Order__c = 5,
			RecordType__c = 'test',
			ValueError__c = '<notin>bla',
			ValueOk__c = '<notin>bla'
        );

        //insert s5;
	
        insert new List<ANG_ProgressBarSettings__c>{s1,s2,s3,s4,s5};

        Map<String, String> objectsIds = new Map<String, String>();

        objectsIds.put('PORTAL_APPLICATIONS__C', p1.id);

		ANG_ProgressBarHelper helper = new ANG_ProgressBarHelper('test', objectsIds);

		ANG_ProgressBar pb = new ANG_ProgressBar();
		pb.helper = helper;

	}
}
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
			Label__c = 'node1',
			Order__c = 1,
			RecordType__c = 'test',
			ValueError__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\'',
			ValueProgress__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\'',
			ValueOk__c = 'ANG_Restrict_by_Agency_Sector__c=\'' + ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED + '\''
        );

        ANG_ProgressBarSettings__c s2 = new ANG_ProgressBarSettings__c (
        	name = 'bla2',
			Label__c = 'node1',
			Order__c = 1,
			RecordType__c = 'test',
			ValueError__c = 'ANG_Restrict_by_Agency_Sector__c=\'' + ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT + '\'',
			ValueProgress__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\' AND Agency__c=true',
			ValueOk__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\''
        );

        ANG_ProgressBarSettings__c s3 = new ANG_ProgressBarSettings__c (
        	name = 'bla3',
			Label__c = 'node1',
			Order__c = 1,
			RecordType__c = 'test',
			ValueError__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\'',
			ValueProgress__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\'',
			ValueOk__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\' OR Agency__c=true'
        );

        ANG_ProgressBarSettings__c s4 = new ANG_ProgressBarSettings__c (
        	name = 'bla3',
			Label__c = 'node1',
			Order__c = 1,
			RecordType__c = 'test',
			ValueError__c = 'ANG_Restrict_by_Agency_Sector__c=\'bla\'',
			ValueProgress__c = 'ANG_Restrict_by_Agency_Sector__c=\'' + ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT + '\'',
			ValueOk__c = 'ANG_Restrict_by_Agency_Sector__c!=\'bla\''
        );

	
        insert new List<ANG_ProgressBarSettings__c>{s1,s2,s3};

		ANG_ProgressBarHelper helper = new ANG_ProgressBarHelper('test', p1.Id);

		ANG_ProgressBar pb = new ANG_ProgressBar();
		pb.helper = helper;
	}
}
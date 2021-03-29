public with sharing class AirportISService {
	public static final String FUNCTIONALROLE = 'Airport IS';

	public static void manageUserOnboarding (Set<Contact> contactSet, String accessStatus){
		try {
			PortalServiceAccessService.manageUserOnboarding(contactSet, accessStatus, FUNCTIONALROLE);
		} catch (Exception e) {
			throw new AirportISServiceException('Error onboarding Airport IS User', e);
		}
	}

	public class AirportISServiceException extends Exception {}
}
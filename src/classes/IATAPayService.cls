public with sharing class IATAPayService {
	public static final String FUNCTIONALROLE = 'IATA Pay';

	public static void manageUserOnboarding (Set<Contact> contactSet, String accessStatus){
		try {
			PortalServiceAccessService.manageUserOnboarding(contactSet, accessStatus, FUNCTIONALROLE);
		} catch (Exception e) {
			throw new IATAPayServiceException('Error onboarding IATA Pay User', e);
		}
	}

	public class IATAPayServiceException extends Exception{}
}
public with sharing class IATAPayService {
	public static final String FUNCTIONALROLE = 'IATA Pay';

	public static void manageUserOnboarding (List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList){
		try {
			PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);
		} catch (Exception e) {
			throw new IATAPayServiceException('Error onboarding IATA Pay User' + e.getStackTraceString(), e);
		}
	}

	public class IATAPayServiceException extends Exception{}
}
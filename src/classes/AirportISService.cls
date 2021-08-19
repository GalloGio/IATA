public without sharing class AirportISService {
	public static final String FUNCTIONALROLE = 'Airport IS';

	public static void manageUserOnboarding (List<PortalServiceAccessService.PortalServiceAccess> portalServiceAccessList){
		try {
			PortalServiceAccessService.manageUserOnboarding(portalServiceAccessList);
		} catch (Exception e) {
			throw new AirportISServiceException('Error onboarding Airport IS User' + e.getStackTraceString(), e);
		}
	}

	public class AirportISServiceException extends Exception {}
}
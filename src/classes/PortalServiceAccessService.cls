public with sharing class PortalServiceAccessService {

	//must be called with individual List<PortalServiceAccess> per combination of FunctionalRole AND Access Status
	//e.g. List<PortalServiceAccess> grantAccessToServiceX 
	//do not use a list with different values for FunctionalRole and Access Status
	//these must be the same for each PortaServiceAccess in the list
	@InvocableMethod(label='Portal Service Access' description='Manages Portal Service Access Operations' category='Portal Services Access')
	public static void processPortalServiceAccessService(List<PortalServiceAccess> portalServiceAccessList){
		if(portalServiceAccessList == null || portalServiceAccessList.isEmpty())
			throw new PortalServiceAccessServiceException('Portal Service Access List not specified');
		
		//get the portal service (functional role)
		String functionalRoleName = portalServiceAccessList.get(0).functionalRoleName;
		//get the operation to be performed (e.g. access granted)
		String accessStatus = portalServiceAccessList.get(0).accessStatus;
		//populate set of contacts
		Set<Contact> contactSet = new Set<Contact>();
		for(PortalServiceAccess portalServiceAccess : portalServiceAccessList){
			contactSet.add(portalServiceAccess.contact);
		}

		if(functionalRoleName.equals(AirportISService.FUNCTIONALROLE)){
			try{
				AirportISService.manageUserOnboarding(contactSet, accessStatus);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding for ' + AirportISService.FUNCTIONALROLE, e);
			}
		} else if(functionalRoleName.equals(IATAPayService.FUNCTIONALROLE)){
			try{
				IATAPayService.manageUserOnboarding(contactSet, accessStatus);
			} catch(Exception e){
				throw new PortalServiceAccessServiceException('Error managing user onboarding for ' + IATAPayService.FUNCTIONALROLE, e);
			}	
		}
	}

	// represents a single contact for the functional role and access status specified
	// to bulkify, create seperate lists of PortalServiceAccess 
	// with the same functional role AND access status
	public class PortalServiceAccess {
		@InvocableVariable (label = 'Functional Role' required = true)
		public String functionalRoleName;
		@InvocableVariable (label = 'Access Status' required = true)
		public String accessStatus;
		@InvocableVariable (label = 'Contact' required = true)
		public Contact contact;
	}

	public class PortalServiceAccessServiceException extends Exception {}
}
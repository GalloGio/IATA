public class ANG_ISSP_PortalServiceHelper {

	public static final String IATA_EASYPAY_EDENRED = 'IATA EasyPay (EDENRED)';
	public static final String IATA_EASYPAY_MSTS = 'IATA EasyPay (MSTS)';
	public static final String IATA_EASYPAY_WEX = 'IATA EasyPay (WEX)';
	public static final String IATA_EASYPAY_2C2P = 'IATA EasyPay (2C2P)';
	private static Set<String> IEP_PORTAL_SERVICES_SET = new Set<String> { IATA_EASYPAY_EDENRED, IATA_EASYPAY_MSTS, IATA_EASYPAY_WEX, IATA_EASYPAY_2C2P };
	public static final String TRAVEL_AGENT = 'Travel Agent';
	public static final String CARGO_AGENT = 'Cargo Agent';
	public static final String STATUS_NO_IEP_ACCOUNT = 'No IEP Account';
	public static final String STATUS_OPEN = 'Open';
	public static final String STATUS_IN_PROGRESS = 'In Progress';

	/*
		Checks if the service name is a IEP Portal Service
	*/
	public static Boolean isIepPortalService(String serviceName) {
		return IEP_PORTAL_SERVICES_SET.contains(serviceName);
	}
}

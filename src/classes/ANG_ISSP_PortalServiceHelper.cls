public class ANG_ISSP_PortalServiceHelper {

    private static final String IEP_PORTAL_SERVICES = 'IATA EasyPay (EDENRED),IATA EasyPay (MSTS),IATA EasyPay (WEX)';
    public static final String IATA_EASYPAY_EDENRED = 'IATA EasyPay (EDENRED)';
    public static final String IATA_EASYPAY_MSTS = 'IATA EasyPay (MSTS)';
    public static final String IATA_EASYPAY_WEX = 'IATA EasyPay (WEX)';
    private static set<String> IEP_PORTAL_SERVICES_SET;
    public static final String TRAVEL_AGENT = 'Travel Agent';
    public static final String CARGO_AGENT = 'Cargo Agent';
    public static final String STATUS_NO_IEP_ACCOUNT = 'No IEP Account';
    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    
    /*
        Checks if the service name is a IEP Portal Service
    */
    public static Boolean isIepPortalService(String serviceName) {
        if (IEP_PORTAL_SERVICES_SET == null) {
            List<String> l = IEP_PORTAL_SERVICES.split(',');
            IEP_PORTAL_SERVICES_SET = new Set<String>();
            IEP_PORTAL_SERVICES_SET.addAll(l);
        }

        return IEP_PORTAL_SERVICES_SET.contains(serviceName);
    }
}
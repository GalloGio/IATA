global interface ANG_CalloutHelperInt {

	String fetchEndPoint(String changeCode);
	String serializeData(Object obj);
	void doCallOut(String calloutBody, String endpoint);

}
/**
 *
 */
global class AMS_GDP_Webservice_Integration {

	/**
	 *
	 */
	webservice static String gdpProductsAccountView(String EXTERNALID, String IATACODE, String IATACASS, String LOCATIONTYPE, String LEGALNAME, String DBA, String EMAIL, String WEBADDRESS, String PC, String LEGALTYPE, String SOLICITATION, String QTANAME, String QMPNAME, String TAXID) {

		AMS_GDP_Objects.ProductAccountView pac = new AMS_GDP_Objects.ProductAccountView();
		pac.EXTERNALID = EXTERNALID;
		pac.IATACODE = IATACODE;
		pac.IATACASS = IATACASS;
		pac.LOCATIONTYPE = LOCATIONTYPE;
		pac.LEGALNAME = LEGALNAME;
		pac.DBA = DBA;
		pac.EMAIL = EMAIL;
		pac.WEBADDRESS = WEBADDRESS;
		pac.PC = PC;
		pac.LEGALTYPE = LEGALTYPE;
		pac.SOLICITATION = SOLICITATION;
		pac.QTANAME = QTANAME;
		pac.QMPNAME = QMPNAME;
		pac.TAXID = TAXID;

		return AMS_GDP_Integration_Handler.gdpProductsAccountView(pac);
	}

	/**
	 *
	 */
	webservice static String gdpAddress(String EXTERNALID, String ADDRESS, String ADDRESS2, String SUITE3, String CITY, String STATECODE, String COUNTRY, String ZIP) {

		AMS_GDP_Objects.Address a = new AMS_GDP_Objects.Address();
		a.EXTERNALID = EXTERNALID;
		a.ADDRESS = ADDRESS;
		a.ADDRESS2 = ADDRESS2;
		a.SUITE3 = SUITE3;
		a.CITY = CITY;
		a.STATECODE = STATECODE;
		a.COUNTRY = COUNTRY;
		a.ZIP = ZIP;
		return AMS_GDP_Integration_Handler.gdpAddress(a);
	}

	/**
	 *
	 */
	webservice static String gdpPhone(String EXTERNALID, String COUNTRYCODE, String AREACODE, String PHONENUMBER) {

		AMS_GDP_Objects.Phone p = new AMS_GDP_Objects.Phone();
		p.EXTERNALID = EXTERNALID;
		p.COUNTRYCODE = COUNTRYCODE;
		p.AREACODE = AREACODE;
		p.PHONENUMBER = PHONENUMBER;
		return AMS_GDP_Integration_Handler.gdpPhone(p);
	}

	/**
	 *
	 */
	webservice static String gds(String EXTERNALID, String RESERVATIONSYSTEM, String RESERVATIONSYSTEM2, String RESERVATIONSYSTEM3, String RESERVATIONSYSTEM4) {

		AMS_GDP_Objects.GDS gds = new AMS_GDP_Objects.GDS();
		gds.EXTERNALID = EXTERNALID;
		gds.RESERVATIONSYSTEM = RESERVATIONSYSTEM;
		gds.RESERVATIONSYSTEM2 = RESERVATIONSYSTEM2;
		gds.RESERVATIONSYSTEM3 = RESERVATIONSYSTEM3;
		gds.RESERVATIONSYSTEM4 = RESERVATIONSYSTEM4;
		return AMS_GDP_Integration_Handler.gds(gds);
	}

	/**
	 *
	 */
	webservice static String gdpAgencyProfileSpecialization(String EXTERNALID, String MARKETFOCUSLEISURE, String MARKETFOCUSCOPORATE, String TOTALANNUALSALES, String PERCENTAIR, String PERCENTCRUISE, String PERCENTLAND, String SPECIALITY1, String SPECIALITY2, String SPECIALITY3, String PROFILE, String PRINCIPALACTIVITY) {

		AMS_GDP_Objects.AgencyProfileSpecialization aps = new AMS_GDP_Objects.AgencyProfileSpecialization();
		aps.EXTERNALID = EXTERNALID;
		aps.MARKETFOCUSLEISURE = MARKETFOCUSLEISURE;
		aps.MARKETFOCUSCOPORATE = MARKETFOCUSCOPORATE;
		aps.TOTALANNUALSALES = TOTALANNUALSALES;
		aps.PERCENTAIR = PERCENTAIR;
		aps.PERCENTCRUISE = PERCENTCRUISE;
		aps.PERCENTLAND = PERCENTLAND;
		aps.SPECIALITY1 = SPECIALITY1;
		aps.SPECIALITY2 = SPECIALITY2;
		aps.SPECIALITY3 = SPECIALITY3;
		aps.PROFILE = PROFILE;
		aps.PRINCIPALACTIVITY = PRINCIPALACTIVITY;
		return AMS_GDP_Integration_Handler.gdpAgencyProfileSpecialization(aps);
	}

	/**
	 *
	 */
	webservice static String agencyOwner(String EXTERNALID, String OWNER) {

		AMS_GDP_Objects.AgencyOwner ao = new AMS_GDP_Objects.AgencyOwner();
		ao.EXTERNALID = EXTERNALID;
		ao.OWNER = OWNER;
		return AMS_GDP_Integration_Handler.agencyOwner(ao);
	}

	/**
	 *
	 */
	webservice static String accreditation(String EXTERNALID, String VERIFICATIONDATE, String RC, String ORGABBR, String STATUS, String EFFECTIVEDATE, String ORGCLASS, String LASTMODDATE) {

		AMS_GDP_Objects.Accreditation a = new AMS_GDP_Objects.Accreditation();
		a.EXTERNALID = EXTERNALID;
		a.VERIFICATIONDATE = VERIFICATIONDATE;
		a.RC = RC;
		a.ORGABBR = ORGABBR;
		a.STATUS = STATUS;
		a.EFFECTIVEDATE = EFFECTIVEDATE;
		a.ORGCLASS = ORGCLASS;
		a.LASTMODDATE = LASTMODDATE;
		return AMS_GDP_Integration_Handler.accreditation(a);
	}

	/**
	 *
	 */
	webservice static String accountCategory(String EXTERNALID, String LOCATIONCAT, String LOCATIONCAT2) {

		AMS_GDP_Objects.AccountCategory ac = new AMS_GDP_Objects.AccountCategory();
		ac.LOCATIONCAT = LOCATIONCAT;
		ac.LOCATIONCAT2 = LOCATIONCAT2;
		return AMS_GDP_Integration_Handler.accountCategory(ac);
	}
}

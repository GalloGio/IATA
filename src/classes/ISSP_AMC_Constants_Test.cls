/*
    Class Name: ISSP_AMC_Constants_Test
    Related Classes: ISSP_AMC_Constants

    Copyright @Right IT Services

    Purpose: 

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    07-02-2018              INITIAL DEVELOPMENT
*/
@isTest
public class ISSP_AMC_Constants_Test {

	public static testMethod void testConstats(){
		Test.StartTest();
			ISSP_AMC_Constants controller = new ISSP_AMC_Constants();
			System.assertEquals('STEP1', ISSP_AMC_Constants.AMC_SAVE_STEP1);
			System.assertEquals('STEP2', ISSP_AMC_Constants.AMC_SAVE_STEP2);
			System.assertEquals('STEP3', ISSP_AMC_Constants.AMC_SAVE_STEP3);
			System.assertEquals('STEP4', ISSP_AMC_Constants.AMC_SAVE_STEP4);
			System.assertEquals('STEP5', ISSP_AMC_Constants.AMC_SAVE_STEP5);
			System.assertEquals('SUBMIT', ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT);
			System.assertEquals('ISSP_AMC_AirOperatorCertificate', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIROPERATORCERTIFICATE);
			System.assertEquals('ISSP_AMC_Airline_Issued_AOC', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIRLINE_ISSUED_AOC);
			System.assertEquals('ISSP_AMC_Authorized_Areas_Operation', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZED_AREAS_OPERATION);
			System.assertEquals('ISSP_AMC_AreasOfRoutesAndOperations', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AREASOFROUTESANDOPERATIONS);
			System.assertEquals('ISSP_AMC_PreviousIATACode', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREVIOUSIATACODE);
			System.assertEquals('ISSP_AMC_ICAOCode', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ICAOCODE);
			System.assertEquals('ISSP_AMC_SchedulesPublication', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SCHEDULESPUBLICATION);
			System.assertEquals('ISSP_AMC_FleetInformation', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_FLEETINFORMATION);
			System.assertEquals('ISSP_AMC_PreferenceOfCode', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREFERENCEOFCODE);
			System.assertEquals('ISSP_AMC_TermsAndConditions', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TERMSANDCONDITIONS);
			System.assertEquals('ISSP_AMC_CertificateIncorporationRegistration', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CERTIFICATEINCORPORATIONREGISTRATION);
			System.assertEquals('ISSP_AMC_BreakdownOfShareholders', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_BREAKDOWNOFSHAREHOLDERS);
			System.assertEquals('ISSP_AMC_ULD', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ULD);
			System.assertEquals('ISSP_AMC_Rail_Ferry_Or_Bus', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_RAIL_FERRY_OR_BUS);
			System.assertEquals('ISSP_AMC_CRS', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CRS);
			System.assertEquals('ISSP_AMC_Non_Scheduled', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_NON_SCHEDULED);
			System.assertEquals('ISSP_AMC_Intermodal_Agreement', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_INTERMODAL_AGREEMENT);
			System.assertEquals('ISSP_AMC_Upload_Files', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_UPLOAD_FILES);
			System.assertEquals('ISSP_AMC_BusRailwayFerry', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_BUSRAILWAYFERRY);
			System.assertEquals('ISSP_AMC_Metropolitan_Area', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AREA);
			System.assertEquals('ISSP_AMC_Metropolitan_AirportB', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AIRPORTB);
			System.assertEquals('ISSP_AMC_LocationAirportHeliportForm', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_LOCATIONAIRPORTHELIPORTFORM);
			System.assertEquals('ISSP_AMC_LocationOfflinePoint', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_LOCATIONOFFLINEPOINT);
			System.assertEquals('ISSP_AMC_Authorization_Transportation_Services', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZATION_TRANSPORTATION_SERVICES);
			System.assertEquals('ISSP_AMC_TrafficAgreement_Valid_IATA_Code', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TRAFFIC_AGREEMENT_VALID_IATA_CODE);
			System.assertEquals('ISSP_AMC_Signed_Letter_CRS', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SIGNED_LETTER_CRS);
			System.assertEquals('ISSP_AMC_Passenger', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PASSENGERS);
			System.assertEquals('ISSP_AMC_Cargo', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CARGOS);
			System.assertEquals('ISSP_AMC_CurrentStructureLocation', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CURRENTSTRUCTURELOCATION);
			System.assertEquals('ISSP_AMC_CAALetterOpeningDate', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CAALETTEROPENINGDATE);
			System.assertEquals('ISSP_AMC_CommercialScheduledOperations', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_COMMERCIALSCHEDULEDOPERATIONS);
			System.assertEquals('ISSP_AMC_Account_Settlement_System_CASS', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ACCOUNTSETTLEMENTSYSTEMCASS);
			System.assertEquals('ISSP_AMC_Freight_Forwarder', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_FREIGHTFORWARDER);
			System.assertEquals('ISSP_AMC_LocationAreaData', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_LOCATIONAREADATA);
			System.assertEquals('ISSP_AMC_EntityContactData', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ENTITYCONTACTDATA);
			System.assertEquals('ISSP_AMC_CompanyOperatingCertificate', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_COMPANYOPERATINGCERTIFICATE);
			System.assertEquals('ISSP_AMC_CompanyPreviousIATACode', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_COMPANYPREVIOUSIATACODE);
			System.assertEquals('ISSP_AMC_PreviousNumericIATACode', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREVIOUSNUMERICIATACODE);
			System.assertEquals('ISSP_AMC_DeclarationBaggageTagCodes', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_DECLARATIONBAGGAGETAGCODES);
			System.assertEquals('ISSP_AMC_EntityContactDataForBaggage', ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ENTITYCONTACTDATAFORBAGGAGE);
			System.assertEquals('Scheduled Passenger', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_PASSENGER);
			System.assertEquals('Scheduled Cargo', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_SCHEDULED_CARGO);
			System.assertEquals('Non-Scheduled Passenger', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_PASSENGER);
			System.assertEquals('Non-Scheduled Cargo', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_NON_SCHEDULED_CARGO);
			System.assertEquals('Ferry Company', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_FERRY_COMPANY);
			System.assertEquals('CRS', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_CRS);
			System.assertEquals('ULD', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_ULD);
			System.assertEquals('Bus Company', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_BUS_COMPANY);
			System.assertEquals('Railway Company', ISSP_AMC_Constants.AMC_PAR_TYPEOFOPERATION_RAILWAY_COMPANY);
			System.assertEquals('Airport', ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_AIRPORT);
			System.assertEquals('Heliport', ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_HELIPORT);
			System.assertEquals('Railway Station', ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_RAILWAY_STATION);
			System.assertEquals('Bus Station', ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_BUS_STATION);
			System.assertEquals('Ferry Port', ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_FERRY_PORT);
			System.assertEquals('Off-line Point', ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_OFF_LINE_POINT);
			System.assertEquals('Metropolitan Area', ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_METROPOLITAN_AREA);
			System.assertEquals('Designator Code', ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_DESIGNATOR_CODE);
			System.assertEquals('Accounting or Prefix Code', ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE);
			System.assertEquals('Location Code', ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE);
			System.assertEquals('Baggage Code', ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE);
			System.assertEquals('Application Change company Info', ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_CHANGE_COMPANY_INFO);
			System.assertEquals('Application Code Withdraw', ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_MANAGE_MY_CODES);
			System.assertEquals('Open', ISSP_AMC_Constants.AMC_CASE_STATUS_OPEN);
			System.assertEquals('Submitted', ISSP_AMC_Constants.AMC_CASE_STATUS_SUBMITTED);
			System.assertEquals('Airline Coding Application', ISSP_AMC_Constants.AMC_CASE_CASEAREA_AIRLINE_CODING_APPLICATION);
			System.assertEquals('Airline Coding Application', ISSP_AMC_Constants.AMC_CASE_CASEAREA_ACCOUNTING_OR_PREFIX_CODE);
			System.assertEquals('Location Code', ISSP_AMC_Constants.AMC_CASE_CASEAREA_CODES_LOCATION_CODE);
			System.assertEquals('Airline Coding Application', ISSP_AMC_Constants.AMC_CASE_CASEAREA_BAGGAGE_CODE);
			System.assertEquals('Designator Form', ISSP_AMC_Constants.AMC_CASE_REASON_DESIGNATOR_FORM);
			System.assertEquals('3 Digit Form', ISSP_AMC_Constants.AMC_CASE_REASON_ACCOUNTING_OR_PREFIX_FORM);
			System.assertEquals('Location ID Form', ISSP_AMC_Constants.AMC_CASE_REASON_LOCATION_FORM);
			System.assertEquals('Baggage Tag Identifier Codes', ISSP_AMC_Constants.AMC_CASE_REASON_BAGGAGE_FORM);
			System.assertEquals('Manage Changes / Major', ISSP_AMC_Constants.AMC_CASE_REASON_WITHDRAW_CODE);
			System.assertEquals('Manage Changes / Minor', ISSP_AMC_Constants.AMC_CASE_REASON_COMPANY_INFO);
			System.assertEquals('Airline Designator Code Request', ISSP_AMC_Constants.AMC_CASE_SUBJECT_AIRLINE_CODING_APPLICATION);
			System.assertEquals('Accounting or Prefix Code Request', ISSP_AMC_Constants.AMC_CASE_SUBJECT_ACCOUNTING_OR_PREFIX_CODE);
			System.assertEquals('Location Code Request', ISSP_AMC_Constants.AMC_CASE_SUBJECT_CODES_LOCATION_CODE);
			System.assertEquals('Baggage Code Request', ISSP_AMC_Constants.AMC_CASE_SUBJECT_BAGGAGE_CODE);
			System.assertEquals('Withdraw Code', ISSP_AMC_Constants.AMC_CASE_SUBJECT_CODE_WITHDRAWL);
			System.assertEquals('Portal', ISSP_AMC_Constants.AMC_CASE_ORIGIN_PORTAL);
			System.assertEquals('IATA Codes (not applicable to Agents)', ISSP_AMC_Constants.AMC_CASE_TOPIC_IATA_CODES);
			System.assertEquals('Change Company Info', ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_CHANGE_COMPANY_INFO);
			System.assertEquals('Withdraw Code', ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_WITHDRAW_CODE);
			System.assertEquals('Airline Designator Code', ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_AIRLINE_DESIGNATOR);
			System.assertEquals('Location Identifier', ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_LOCATION_IDENTIFIER);
			System.assertEquals('3 Numeric Accouting & Prefix Code', ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_ACCOUNTING_PREFIX);
			System.assertEquals('Baggage Tag Issuer', ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_BTG_ISSUER);
			System.assertEquals('Normal', ISSP_AMC_Constants.AMC_CASE_PRIORITY_NORMAL);
			System.assertEquals('Withdraw', ISSP_AMC_Constants.AMC_CASE_DESCRIPTION_WITHDRAW);
			System.assertEquals('Application Code Withdraw', ISSP_AMC_Constants.AMC_CASE_SCENARIO_WITHDRAW);
	}
}
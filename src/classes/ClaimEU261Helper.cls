/**
 * Created by mansourim on 29-Jan-18.
 */

public with sharing class ClaimEU261Helper {

	public static final String PREFIX_LIBRARIESNAME = 'EU261';
    public static final String PREFIX_FLOWS = 'Claim EU261';

    public static List<Object> getFlightInformation(String Departure_Airport, String Arrival_Airport) {

        List<Address__c> airports = [SELECT Id, Code__c, Coordinates__c, IATA_ISO_Country__r.Region__c FROM Address__c WHERE Code__c =: Departure_Airport OR Code__c =: Arrival_Airport];

        List<Object> strRes = new Object[3];

        if(airports.isEmpty()) {
            strRes.set(0, 0.0);
            strRes.set(1, 'N');
            strRes.set(2, 'N');
        } else {

            Map<String,Address__c> airportByCode = new Map<String,Address__c>();

            for(Address__c airport : airports) {
                airportByCode.put(airport.Code__c, airport);
            }

            strRes.set(0, Location.getDistance(airportByCode.get(Departure_Airport).Coordinates__c, airportByCode.get(Arrival_Airport).Coordinates__c, 'km'));
            strRes.set(1, airportByCode.get(Departure_Airport).IATA_ISO_Country__r.Region__c == 'Europe' ? 'Y' : 'N');
            strRes.set(2, airportByCode.get(Arrival_Airport).IATA_ISO_Country__r.Region__c == 'Europe' ? 'Y' : 'N');
        }

        System.debug('____ [cls ClaimEU261Helper - getFlightInformation] strRes: ' + strRes);

        return strRes;
    }
    
	public static List<Object> getFinalResult(Map<String,Object> inputs){
        
        String ExtraordinaryCircumstances = '%' + (String)inputs.get('Extraordinary_Circumstances') + '%';
		String DelayFlight = '%' + (String)inputs.get('Delayed_Flight_Time') + '%';
        String isDepartureAirportEU = '%' + (String)inputs.get('isDeparture_Airport_EU') + '%';
        String isConnectingAirportEU = '%' + (String)inputs.get('isConnecting_Airport_EU') + '%';
        String isArrivalAirportEU = '%' + (String)inputs.get('isArrival_Airport_EU') + '%';
        String isCarrierEU = '%' + (String)inputs.get('isCarrier_EU') + '%';
        String claimType = '%' + (String)inputs.get('claimType') + '%';
        String DelayFlightSection = '%' + (String)inputs.get('DelayFlightSection') + '%';
        
        system.debug('##query: SELECT CompensationAmount__c, Description__c FROM ClaimEU261__c where '
                                           	+' ExtraCircun__c like \''+ExtraordinaryCircumstances+'\'  AND '
                                           	+' DelayTime__c like \''+DelayFlight+'\' AND '
                                            +' Max_Distance__c > '+(Decimal)inputs.get('Flight_Distance')+' AND '
                                            +' Min_Distance__c < '+(Decimal)inputs.get('Flight_Distance')+' AND '
                                            +' Is_Departure_Airline_EU__c like \''+isDepartureAirportEU+'\' AND '
                                			+' Is_Connecting_Airport_EU__c like \''+isConnectingAirportEU+'\' AND '
                                            +' Is_Arrival_Airport_EU__c like \''+isArrivalAirportEU+'\' AND '
                                            +' Is_Carrier_from_EU__c like \''+isCarrierEU+'\' AND '
                                            +' claim_type__c like \''+claimType+'\' AND '
                                            +' DelayFlightSection__c like \''+DelayFlightSection+'\'');
                     
        List<Object> Outputs = [SELECT CompensationAmount__c, Description__c FROM ClaimEU261__c where
                                           	ExtraCircun__c like :ExtraordinaryCircumstances AND  
                                           	DelayTime__c like :DelayFlight AND
                                            Max_Distance__c > :(Decimal)inputs.get('Flight_Distance') AND
                                            Min_Distance__c < :(Decimal)inputs.get('Flight_Distance') AND
                                            Is_Departure_Airline_EU__c like :isDepartureAirportEU AND
                                			Is_Connecting_Airport_EU__c like :isConnectingAirportEU AND
                                            Is_Arrival_Airport_EU__c like :isArrivalAirportEU AND
                                            Is_Carrier_from_EU__c like :isCarrierEU AND
                                            claim_type__c like :claimType AND
                                            DelayFlightSection__c like :DelayFlightSection
                                            ];
        return Outputs;
    }

    public static void updateCaseOwner(String caseId){
        
        Case cse = [SELECT id FROM Case WHERE id =: caseId];

        if(cse != null){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            cse.setOptions(dmo);
            update cse;
        }
    }

}
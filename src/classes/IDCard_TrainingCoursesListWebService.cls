/**
 * URI: /services/apexrest/IDCard/v1/coursesList/
 */
@RestResource(urlMapping='/IDCard/v1/coursesList/*')
global with sharing class IDCard_TrainingCoursesListWebService
{
    @HttpGet
    global static void doGet()
    {
        Map<String, String> courses = getItdiCourses();

        IDCard_ServiceResponse response = IDCard_ServiceResponse.makeGenericServiceResponse(makeResponse(courses));
        IDCard_ServiceResponse.setServiceResponse(response);
    }

    private static Map<String, String> getItdiCourses()
    {
        Map<String, String> itdiCourses = new Map<String, String>();

        Schema.DescribeFieldResult fieldResult = ID_Card_Application__c.Package_of_Travel_Professionals_Course_2__c.getDescribe();

        for (Schema.PicklistEntry f : fieldResult.getPicklistValues())
            itdiCourses.put(f.getValue(), f.getLabel());

        return itdiCourses;
    }

    private static Map<String, String> coursesDescriptionMap = new Map<String, String>
    {
        'Travel Agency Fees - EN' => Label.IDCard_Travel_Agency_Fees_Description,
        'Assist Travelers Special Needs - EN' => Label.Assist_Travelers_Special_Needs_Description,
        'Fundamentals Journey Pricing - EN' => Label.IDCard_FundamentalsJourneyPricing_Description,
        'Notions essent\'l en tarif et billet - FR' => Label.Notions_Essentl_Tarif_Billet_Description,
        'Adv. Skills Journey Price&Ticket - EN' => Label.Adv_Skills_Journey_Price_Ticket_Description,
        'Geography in Travel Planning - EN' => Label.IDCard_GeographyinTravelPlanning_Description,
        'Serving the Travel  Customer - EN' => Label.Serving_The_Travel_Customer_Description,
        'Le service au client voyageur - FR' => Label.IDCard_Leserviceauclientvoyageur_Description,
        'Selling Intl Rail Transportation - EN' => Label.IDCard_SellingInternationalRailTransportation_Description,
        'Social Media for Travel Industry - EN' => Label.Social_Media_Travel_Industry_Description,
        'Destination Geography - EN' => Label.IDCard_DestinationGeography_Description,
        'Repricing, Exchange and Reissue - EN' => Label.IDCard_RepricingExchangeReissue_Description,
        'Acc. & Fin. Mgmt for agencies -EN' => Label.Acc_Fin_Mgmt_Agencies_Description,
        'Intro to BSPLink - EN' => Label.IDCard_IntroductiontoBSPLink_Description,
        'BSP Agent Billing Reports & Procedures - EN' => Label.IDCard_BSP_Agent_Billing_Reports_Procedures,
        'BSP Agent Remittance Procedures - EN' => Label.IDCard_BSP_Agent_Remittance_Procedures,
        'BSP Essentials for Travel Agents - EN' => Label.IDCard_BSP_Essentials_for_Travel_Agents,
        'BSP Standard Documents & Procedures - EN' => Label.IDCard_BSP_Standard_Documents_Procedures,
        'Intro to the BSP System & Language - EN' => Label.IDCard_Intro_to_the_BSP_System_Language
    };

    private static String getCourseDescription(String course)
    {
        return coursesDescriptionMap.get(course);
    }

    private static List<Map<String, Object>> makeResponse(Map<String, String> courses)
    {
        List<Map<String, Object>> ret = new List<Map<String, Object>>();

        for (String c : courses.keySet())
        {
            Map<String, Object> m = new Map<String, Object>();
            m.put('title', c);
            m.put('description', getCourseDescription(c));
            ret.add(m);
        }

        return ret;
    }
}
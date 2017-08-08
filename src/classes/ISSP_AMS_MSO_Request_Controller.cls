public with sharing class ISSP_AMS_MSO_Request_Controller {

    public String applyLanguage {get; set;}
    public String countrySelected {get; set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    public String commParamFirst { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}

	
    public ISSP_AMS_MSO_Request_Controller() {
        
    }

    public Pagereference securityCheck() {

        return null;
    }

    public List<SelectOption> countryISOCodeList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            list<IATA_ISO_Country__c> isoList;
            Map<String, String> mapRegionToOtherRegion = new Map<String, String>{'Americas' => 'Americas', 'Europe' => 'Africa & Middle East', 'Africa & Middle East' => 'Europe',
                'Asia & Pacific' => 'China & North Asia', 'China & North Asia' => 'Asia & Pacific'
            };

            if (applyLanguage == 'es') {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                           IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                           IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                           FROM IATA_ISO_Country__c
                           WHERE Case_BSP_Country__c != null
                           AND Case_BSP_Country__c != ''
                           ORDER BY IATA_Country_SP__c];
            } else if (applyLanguage == 'fr') {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                           IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                           IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                           FROM IATA_ISO_Country__c
                           WHERE Case_BSP_Country__c != null
                           AND Case_BSP_Country__c != ''
                           ORDER BY IATA_Country_FR__c];
            } else {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                FROM IATA_ISO_Country__c
                WHERE Case_BSP_Country__c != null
                AND Case_BSP_Country__c != ''
                ORDER BY Name];
            }
            

            options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {
                if (applyLanguage == 'es') {
                    if (iso.IATA_Country_SP__c != null)
                        options.add(new SelectOption(iso.ISO_Code__c , iso.IATA_Country_SP__c));
                    else
                        options.add(new SelectOption(iso.ISO_Code__c , iso.Name));
                } else if (applyLanguage == 'fr') {
                    if (iso.IATA_Country_FR__c != null)
                        options.add(new SelectOption(iso.ISO_Code__c, iso.IATA_Country_FR__c));
                    else
                        options.add(new SelectOption(iso.ISO_Code__c, iso.Name));
                } else {
                    options.add(new SelectOption(iso.ISO_Code__c, iso.Name));
                }
            }

            return options;
        }
        set;
    }
}
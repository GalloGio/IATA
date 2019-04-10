public with sharing class ISSP_CurrencyCenterHomeController {

    public List<Comment__c> newsList {get;set;}
    public List<RegionWrapper> regionsList {get;set;}
    public List<RSSNewsWrapper> NewsFeed;

    public String tdLinkURL { 
        get{
            User u = [SELECT Id,ContactId From User WHERE Id =: UserInfo.getUserId()];
            if(u != null){
                List<Portal_Application_Right__c> par = [SELECT Id FROM Portal_Application_Right__c 
                                                    WHERE Contact__c =: u.ContactId 
                                                    AND Right__c = 'Access Granted'
                                                    AND Contact_User_Portal_Status__c = 'Approved User'
                                                    AND Application_Start_URL__c = '/ISSP_TDNavigation'];
                if(par.size()>0)
                    return '/ISSP_TDNavigation';
            }

            return '/ISSP_AvailableServices?MainNav=Services&subNav=Access';

        } set;}

    public ISSP_CurrencyCenterHomeController() {

        newsList = new List<Comment__c>([SELECT Id, CreatedDate, ICCS_Country_Profile__c, Detail__c, ICCS_Country_Profile__r.Name, ICCS_Country_Profile__r.Country_Name__r.Name 
                                        FROM Comment__c
                                        WHERE RecordType.DeveloperName = 'Country_Profile_News'
                                        ORDER BY CreatedDate DESC
                                        LIMIT 10]);

        regionsList = new List<RegionWrapper>();
        Schema.DescribeFieldResult fieldResult = IATA_ISO_Country__c.Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
           regionsList.add(new RegionWrapper(f.getLabel()));
        }  

    }

    public PageReference checkAccess(){
        //if user has service assigned, continue
        return ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
    }

    public PageReference GoToBlockedFunds() {
        return new PageReference('/ISSP_CurrencyCenterCountriesMap?type=Blocked Funds');
    }

    public PageReference GoToWatchList() {
        return new PageReference('/ISSP_CurrencyCenterCountriesMap?type=Watch List');
    }

    public PageReference GoToAllOthers() {
        return new PageReference('/ISSP_CurrencyCenterCountriesMap?type=All Others');
    }

    public PageReference GoToManageNotifications() {
        return new PageReference('/ISSP_CurrencyCenterManageNotifications');
    }

    public PageReference GoToHeatMap() {
        return new PageReference('/ISSP_CurrencyCenterHeatMap');
    }

	public PageReference GoToReportingActions() {
		return new PageReference('/ISSP_CurrencyCenterReportingActions');
	}

    public class RegionWrapper{
        public String region {get;set;}
        public String encodedRegion {get;set;}
        public String trimmedRegion {get; set;}

        public regionWrapper(String region){
            this.region = region;
            this.encodedRegion = EncodingUtil.urlEncode(region,'UTF-8');
            this.trimmedRegion = region.replaceAll(' ', '').replaceAll('&','');
        }
    }


    public class RSSNewsWrapper{
        public String title {get;set;}
        public String link {get;set;}
        public String description {get; set;}
    }

    // TO BE USED WHEN AN EXTERNAL SERVICE IS SET UP
    /*
    public static String getInfoFromExternalService() {
        HttpRequest req = new HttpRequest();
        
        //String url = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss&q=Air+France';
        String url = Label.CurrencyCenter_RSS_Feed_URL;
        req.setEndpoint(url);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        String xml = res.getBody();

        return xml;
    }*/

    public List<RSSNewsWrapper> getNewsFeed() {

      List<RSSNewsWrapper> tmpList = new List<RSSNewsWrapper>();
      String xml;

      // TO BE USED WHEN AN EXTERNAL SERVICE IS SET UP
      // xml = getInfoFromExternalService();

      if (Test.isRunningTest()) {
        xml = '<?xml version="1.0" encoding="UTF-8" ?><rss version="2.0"><channel><title>IATAd</title><link>https://www.iata.org/</link><description>IATA</description><item><title></title><link></link><description>Overland Airways</description></item></channel></rss>';
      } else {
          StaticResource sr;
          try {
            sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'CurrencyCenterNewsFeed' LIMIT 1];
          } catch (Exception e){
            system.debug('ERROR trying to get the contents of the CurrencyCenterNewsFeed static resource - ' + e.getMessage());
          }

          if (sr == null) return null;

          xml = sr.Body.toString();
      } 
      
      XmlStreamReader xsr = new XmlStreamReader(xml);
        Dom.Document doc = new Dom.Document();
        doc.load(xml);



      Dom.XMLNode rss = doc.getRootElement();
      List<Dom.XMLNode> rssList = new List<Dom.XMLNode>();
      for(Dom.XMLNode child : rss.getChildren()) {
        if(child.getName() == 'channel') {

          for(Dom.XMLNode channel : child.getChildren()) {
            if(channel.getName() == 'item' ) {
              RSSNewsWrapper r = new RSSNewsWrapper();
              r.title = channel.getchildElement('title',null).getText();
              r.link = channel.getchildElement('link',null).getText();
              r.description = channel.getchildElement('description',null).getText().replaceAll('\\<.*?\\>', '');
              tmpList.add(r);
            }
          }
        }

      }
      return tmpList;
    }
}
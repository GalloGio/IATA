public class CW_SocialMediaShareController {
    public String title {get;set;}
    public String imageUrl {get;set;}
    public String stationId {get;set;}
    public CW_SocialMediaShareController(){
        title = ApexPages.currentPage().getParameters().get('title');
        imageUrl = ApexPages.currentPage().getParameters().get('imageUrl');
        stationId = ApexPages.currentPage().getParameters().get('stationId');
    }

    public String getStationDetails(){
        return '<html><head><meta property="og:site_name" content="IATA ONE Source"> <meta property="og:description" content="Find all information about this service provider’s infrastructure and capabilities on IATA ONE Source"> <meta property="og:type" content="website"> <meta property="og:title" content="'+title+'"> <meta property="og:url" content="https://nextlink5-customer-portal-iata.cs128.force.com/csportal/apex/CW_SocialMediaShare?stationid='+stationId+'&title='+title+'&imageUrl='+imageUrl+'"> <meta property="og:image" content="'+imageUrl+'"> </head></html>' ;
    }
}
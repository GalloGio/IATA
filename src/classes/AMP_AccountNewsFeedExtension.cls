public with sharing class AMP_AccountNewsFeedExtension {

  private final Account myAccount {get; set;}
  public String searchTerm {get; set;}
  public String JSONrssData {get; set;}

  public class rssPost {
    @AuraEnabled public String link {get; set;}
    @AuraEnabled public String title {get; set;}
    @AuraEnabled public String description {get; set;}
    @AuraEnabled public String dateString {get; set;}
    @AuraEnabled public Datetime timeStamp {get; set;}
  }

  public List<rssPost> lsPosts {get; set;}

  public AMP_AccountNewsFeedExtension(ApexPages.StandardController stdController) {
    this.myAccount = (Account)stdController.getRecord();

    searchTerm = getAccountName(myAccount.Id);
    lsPosts = new List<rssPost>();
    if (!Test.isRunningTest()) {
      //do something
      lsPosts = getNewsFeed(searchTerm);
      JSONrssData = String.escapeSingleQuotes(JSON.serialize(lsPosts));
    }
  }

  @AuraEnabled
  public static String getAccountName(Id accountId) {
    String accountName = '';
    List<Account> a  = [SELECT Id, Name FROM Account WHERE Id = :accountId];
    if (!a.isEmpty()) accountName = a[0].Name;
    accountName = EncodingUtil.urlEncode('"' + accountName + '" Airline', 'UTF-8');
    system.debug(accountName);
    return accountName;
  }

  @AuraEnabled
  public static List<rssPost> getNewsFeedBaseOnId(Id accountId) {
    String accountName = getAccountName(accountId);
    return getNewsFeed(accountName);
  }

  public static HttpResponse getInfoFromExternalService(String searchTerm) {
    HttpRequest req = new HttpRequest();
    // url that returns the XML in the response body

    //String url = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss&q=' + searchTerm;
    String url = 'https://news.google.com/_/rss/search?cf=all&pz=1&q='+ searchTerm + '&hl=en-US&gl=US&ceid=US:en';
    req.setEndpoint(url);
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    return res;
  }

  @AuraEnabled
  public static  List<rssPost> getNewsFeed(String searchTerm) {
    List<rssPost> tmpList = new List<rssPost>();
    System.debug('res: ' + searchTerm);
    
    HttpResponse res = getInfoFromExternalService(searchTerm);
    Dom.Document doc = res.getBodyDocument();
    String xml = res.getBody();
    System.debug('Enter getNewsFeed');
    //  System.debug(xml);
    XmlStreamReader xsr = new XmlStreamReader(xml);

    Dom.XMLNode rss = doc.getRootElement();
    List<Dom.XMLNode> rssList = new List<Dom.XMLNode>();
    for (Dom.XMLNode child : rss.getChildren()) {
      if (child.getName() == 'channel') {

        for (Dom.XMLNode channel : child.getChildren()) {
          if (channel.getName() == 'item' ) {
            rssPost r = new rssPost();
            r.title = channel.getchildElement('title', null).getText();
            r.link = channel.getchildElement('link', null).getText();
            r.description = channel.getchildElement('description', null).getText().replaceAll('\\<.*?\\>', '');

            //   // trick to cut the title from the description, the title until ' -'
            //   String title = r.title.substring(0,r.title.indexOf(' -'));
            //   // replace the encoded quotes
            //   String description = r.description.replaceAll('&#39;','\'');
            //
            //   Integer length = description.length()-1;
            //   System.debug(description +' ' + length);
            //   // jump to the location of title end
            //   description = description.substring(description.indexOf(title)+title.length(),length);
            //   r.description = description;

            //   r.description = r.description.substring(r.description.indexOf(r.title),100);
            // r.description = String.escapeSingleQuotes(channel.getchildElement('description',null).getText());
            // r.description = channel.getchildElement('description',null).getText().replaceAll('\\<.*?\\>', '').replaceAll('\'', '').replaceAll('\"', '').replaceAll('\\"', '').replaceAll('&#38;', '').left(20);
            r.dateString = channel.getchildElement('pubDate', null).getText();
            r.timeStamp = createDateTimeFromString(r.dateString);
            tmpList.add(r);
          }
        }
      }

    }

    //sort items by timeStamp
    Integer n = tmpList.size();
    rssPost temp = new rssPost();    

    for (Integer i = 0; i < n; i++) {
      for (Integer j = 1; j < (n - i); j++) {
        // Sort by Descending order by ActivityDate. To sort by ascending order, change "<" to ">" in the line below.
        if (tmpList[j - 1].timeStamp < tmpList[j].timeStamp) {
          temp = tmpList[j - 1];
          tmpList[j - 1] = tmpList[j];
          tmpList[j] = temp;
        }
      }
    }
    return tmpList;
  }

  public static DateTime createDateTimeFromString(String dateTimeAsString) {
    String[] dateValues = dateTimeAsString.split(',');
    dateValues = dateValues[1].split(' ');
    String[] timeValues = dateValues[4].split(':');
    Integer yyyy = Integer.valueOf(dateValues[3]);
    Integer mo = Integer.valueOf(monthNameToInteger(dateValues[2]));
    Integer dd = Integer.valueOf(dateValues[1]);
    Integer hh = Integer.valueOf(timeValues[0]);
    Integer mm = Integer.valueOf(timeValues[1]);
    Integer s = Integer.valueOf(timeValues[2]);

    DateTime dt = DateTime.newInstanceGmt(yyyy, mo, dd, hh, mm, s);
    return dt;

  }

  public static Integer monthNameToInteger(String name) {
    Integer n = 1;
    if (name == 'Jan') n = 1;
    if (name == 'Feb') n = 2;
    if (name == 'Mar') n = 3;
    if (name == 'Apr') n = 4;
    if (name == 'May') n = 5;
    if (name == 'Jun') n = 6;
    if (name == 'Jul') n = 7;
    if (name == 'Aug') n = 8;
    if (name == 'Sep') n = 9;
    if (name == 'Oct') n = 10;
    if (name == 'Nov') n = 11;
    if (name == 'Dec') n = 12;
    return n;
  }

}
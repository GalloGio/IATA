public with sharing class AMP_AccountNewsFeedExtension {

    private final Account myAccount {get;set;}
    public String searchTerm {get;set;}
    public String rssData {get;set;}
    public String JSONrssData {get;set;}

    public class rssPost {
        public String link {get;set;}
        public String title {get;set;}
        public String description {get;set;}
        public String dateString {get;set;}
        public Datetime timeStamp {get;set;}

    }

    public List<rssPost> lsPosts {get;set;}

    public AMP_AccountNewsFeedExtension(ApexPages.StandardController stdController) {
        this.myAccount = (Account)stdController.getRecord();
                String accountName = [SELECT Id, Name FROM Account WHERE Id = :myAccount.Id].Name;
                // rssData = getRSSData();
                searchTerm = EncodingUtil.urlEncode(accountName,'UTF-8');
                lsPosts = new List<rssPost>();
                lsPosts = getRSSDataList();
                JSONrssData = String.escapeSingleQuotes(JSON.serialize(lsPosts));
                // getAndParse();

    }

        public void updateSearch() {
            lsPosts = getRSSDataList();
            JSONrssData = String.escapeSingleQuotes(JSON.serialize(lsPosts));

        }

        public List<rssPost> getRSSDataList() {

            List<rssPost> tmpList = new List<rssPost>();
            Http h = new Http();
         HttpRequest req = new HttpRequest();
         // url that returns the XML in the response body

                 String url = 'https://news.google.com/news?cf=all&hl=en&pz=1&ned=us&output=rss&q='+searchTerm;
         req.setEndpoint(url);
         req.setMethod('GET');
         HttpResponse res = h.send(req);
         Dom.Document doc = res.getBodyDocument();
                 String xml = res.getBody();
                //  System.debug(xml);
                 XmlStreamReader xsr = new XmlStreamReader(xml);

         Dom.XMLNode rss = doc.getRootElement();


         List<Dom.XMLNode> rssList = new List<Dom.XMLNode>();
         for(Dom.XMLNode child : rss.getChildren()) {
                     if(child.getName() == 'channel') {

                for(Dom.XMLNode channel : child.getChildren()) {
                    if(channel.getName() == 'item' ) {
                                        rssPost r = new rssPost();
                                        r.title = channel.getchildElement('title',null).getText();
                                        System.debug(r.title);
                                        r.link = channel.getchildElement('link',null).getText();
                                        r.description = channel.getchildElement('description',null).getText().replaceAll('\\<.*?\\>', '');
                                        // r.description = String.escapeSingleQuotes(channel.getchildElement('description',null).getText());
                                        // r.description = channel.getchildElement('description',null).getText().replaceAll('\\<.*?\\>', '').replaceAll('\'', '').replaceAll('\"', '').replaceAll('\\"', '').replaceAll('&#38;', '').left(20);
                                        r.dateString = channel.getchildElement('pubDate',null).getText();
                                        r.timeStamp = createDateTimeFromString(r.dateString);
                                        tmpList.add(r);
                    }
                }
                        }

         }


            return tmpList;
        }

        public DateTime createDateTimeFromString(String dateTimeAsString) {
            String[] dateValues = dateTimeAsString.split(',');
            dateValues = dateValues[1].split(' ');
            // System.debug(dateValues[1]);
            // System.debug(dateValues[2]);
            // System.debug(dateValues[3]);
            // System.debug(dateValues[4]);
            String[] timeValues =dateValues[4].split(':');
            // System.debug(monthNameToInteger(dateValues[2]));
            Integer yyyy = Integer.valueOf(dateValues[3]);
            Integer mo = Integer.valueOf(monthNameToInteger(dateValues[2]));
            Integer dd = Integer.valueOf(dateValues[1]);
            Integer hh = Integer.valueOf(timeValues[0]);
            Integer mm = Integer.valueOf(timeValues[1]);
            Integer s = Integer.valueOf(timeValues[2]);
            // DateTime myDateTime = DateTime.newInstance(2001, 2, 27, 3, 3, 3);

            DateTime dt = DateTime.newInstanceGmt(yyyy,mo,dd,hh,mm,s);
            return dt;

        }

        public Integer monthNameToInteger(String name) {
            Integer n = 1;
            if(name == 'Jan') n = 1;
            if(name == 'Feb') n = 2;
            if(name == 'Mar') n = 3;
            if(name == 'Apr') n = 4;
            if(name == 'May') n = 5;
            if(name == 'Jun') n = 6;
            if(name == 'Jul') n = 7;
            if(name == 'Aug') n = 8;
            if(name == 'Sep') n = 9;
            if(name == 'Oct') n = 10;
            if(name == 'Nov') n = 11;
            if(name == 'Dec') n = 12;
            return n;
        }

        public String getRSSData() {

            String rssData ='';

            Http h = new Http();
         HttpRequest req = new HttpRequest();
         // url that returns the XML in the response body
                 String url = 'https://feeds.feedburner.com/developerforce/developerelations?format=xml';
         req.setEndpoint(url);
         req.setMethod('GET');
         HttpResponse res = h.send(req);
         Dom.Document doc = res.getBodyDocument();


                 String xml = res.getBody();
                 XmlStreamReader xsr = new XmlStreamReader(xml);


                //  System.debug(xsr);
                 System.debug(res.getBody());
                //  System.debug(doc);


                 // Read through the XML
                    while(xsr.hasNext()) {
                            // if(xsr.getLocalName() == 'Description') {
                            //  System.debug(xsr.getText());
                            // }
                            if(xsr.getEventType() == XmlTag.CHARACTERS && xsr.getLocalName() == 'item' ) {
                    String errorText = xsr.getText();
                    errorText = xsr.getAttributeValue(null, 'name');
                    System.debug('nameFound=' + errorText);
                    errorText = xsr.getAttributeValue(null, 'title');
                    System.debug('titleFound=' + errorText);
                    errorText = xsr.getAttributeValue(null, 'link');
                    System.debug('linkFound=' + errorText);
                }


                      xsr.next();
                    }

         Dom.XMLNode rss = doc.getRootElement();
         System.debug('@@' + rss.getName());

         List<Dom.XMLNode> rssList = new List<Dom.XMLNode>();
         for(Dom.XMLNode child : rss.getChildren()) {
                     if(child.getName() == 'channel') {

                for(Dom.XMLNode channel : child.getChildren()) {
                                // System.debug('@@@' + channel);

                    if(channel.getName() == 'item') {
                                        // System.debug('---' + channel.getText());
                                        System.debug(channel.getchildElement('title',null).getText());
                                        System.debug(channel.getchildElement('link',null).getText());
                                        System.debug(channel.getchildElement('description',null).getText());

                         rssList.add(channel);
                    }
                }
                        }
         }

            return rssData;
        }



}
public class vfIECEBC_CampaignTracking extends vfIECEBC_Controller{
    
    // ===========================================================
    // Campaign Information
    // ===========================================================
    
    public EBC_Campaign__c campaign {get; set;}
    
    public vfIECEBC_CampaignTracking(ApexPages.StandardController stdController) {
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
    }
    
    // ===========================================================
    // Campaign Tracking Top Page
    // Campaign Tracking Data Table Analysis
    // ===========================================================
    
    public Map<String, Double> Kpis {
        get{
            EBC_Campaign__c campaign = [SELECT Id, 
                                        NumberofClicks__c, NumberSent__c, NumberofOpens__c,
                                        Clicks24Hours__c, Clicks48Hours__c, Bounced24Hours__c, Bounced48Hours__c, Bounced7Days__c,
                                        Opens24Hours__c, Opens48Hours__c, Sent24Hours__c, Sent48Hours__c,
                                        UniqueOpens24Hours__c, UniqueOpens48Hours__c, UniqueOpens7Days__c,
                                        UniqueClicks24Hours__c, UniqueClicks48Hours__c, UniqueClicks7Days__c,
                                        Delivered24Hours__c, Delivered48Hours__c, Delivered7Days__c,
                                        OpenRate24Hours__c, OpenRate48Hours__c, OpenRate7Days__c,
                                        ClickRate24Hours__c, ClickRate48Hours__c, ClickRate7Days__c
                                        FROM EBC_Campaign__c
                                        WHERE Id = :ApexPages.currentPage().getParameters().get('id')];  
            
            Map<String, Double> Kpis = new Map<String, Double>();
            
            Kpis.put('delivered24Hours', Integer.valueOf(campaign.Delivered24Hours__c));
            Kpis.put('delivered48Hours', Integer.valueOf(campaign.Delivered48Hours__c));
            Kpis.put('delivered7Days', Integer.valueOf(campaign.Delivered7Days__c));
            
            Kpis.put('numberOpens24Hours', Integer.valueOf(campaign.Opens24Hours__c));
            Kpis.put('numberOpens48Hours', Integer.valueOf(campaign.Opens48Hours__c));
            Kpis.put('numberOpens7Days', Integer.valueOf(campaign.NumberofOpens__c));
            
            Kpis.put('numberClicks24Hours', Integer.valueOf(campaign.Clicks24Hours__c));
            Kpis.put('numberClicks48Hours', Integer.valueOf(campaign.Clicks48Hours__c));
            Kpis.put('numberClicks7Days', Integer.valueOf(campaign.NumberofClicks__c));
            
            Kpis.put('uniqueClicks24Hours', Integer.valueOf(campaign.UniqueClicks24Hours__c));
            Kpis.put('uniqueClicks48Hours', Integer.valueOf(campaign.UniqueClicks48Hours__c));
            Kpis.put('uniqueClicks7Days', Integer.valueOf(campaign.UniqueClicks7Days__c));
            
            Kpis.put('uniqueOpens24Hours', Integer.valueOf(campaign.UniqueOpens24Hours__c));
            Kpis.put('uniqueOpens48Hours', Integer.valueOf(campaign.UniqueOpens48Hours__c));
            Kpis.put('uniqueOpens7Days', Integer.valueOf(campaign.UniqueOpens7Days__c));
            
            Kpis.put('bounced24Hours', Integer.valueOf(campaign.Bounced24Hours__c));
            Kpis.put('bounced48Hours', Integer.valueOf(campaign.Bounced48Hours__c));
            Kpis.put('bounced7Days', Integer.valueOf(campaign.Bounced7Days__c));
            
            if(Integer.valueOf(campaign.OpenRate24Hours__c) == null){
                Kpis.put('openRate24Hours', -1);
            }else{
               Kpis.put('openRate24Hours', Double.valueOf(campaign.OpenRate24Hours__c)); 
            }
            
            if(Integer.valueOf(campaign.OpenRate48Hours__c) == null){
                Kpis.put('openRate48Hours', -1);
            }else{
                Kpis.put('openRate48Hours', Double.valueOf(campaign.OpenRate48Hours__c));
            }
            
            if(Integer.valueOf(campaign.OpenRate7Days__c) == null){
                Kpis.put('openRate7Days', -1);
            }else{
                Kpis.put('openRate7Days', Double.valueOf(campaign.OpenRate7Days__c));
            }
            
            if(Integer.valueOf(campaign.ClickRate24Hours__c) == null){
                Kpis.put('clickRate24Hours', -1);
            }else{
                Kpis.put('clickRate24Hours', Double.valueOf(campaign.ClickRate24Hours__c));
            }
                        
            if(Integer.valueOf(campaign.ClickRate48Hours__c) == null){
                Kpis.put('clickRate48Hours', -1);
            }else{
                Kpis.put('clickRate48Hours', Double.valueOf(campaign.ClickRate48Hours__c));
            }
            
            if(Integer.valueOf(campaign.ClickRate7Days__c) == null){
                Kpis.put('clickRate7Days', -1);
            }else{
                Kpis.put('clickRate7Days', Double.valueOf(campaign.ClickRate7Days__c));
            }
           
            return Kpis;
        }
        private set;
    }
    public Integer Adjustments {
        get {
            if (Adjustments == null) {
                List<AggregateResult> rec = [Select Sum(Total_Count__c) cnt                            	
                                             From EBC_Activity__c
                                             Where EBC_Campaign__c = :campaign.Id
                                             And Activity_Type__c = 'Adjustment'
                                            ];
                Adjustments = Integer.valueOf(rec[0].get('cnt'));
            }
            return Adjustments;
        }
        private set;
    }
    
    
    //=======================================================================================
    //    Manage Top Links
    //=======================================================================================

    public Map<String, Map<String, Integer>> campaignLinkStats {
        get {
            if (campaignLinkStats == null) {
                campaignLinkStats = new Map<String, Map<String, Integer>>();
                List<AggregateResult> ars = [Select count(Id) cnt, count_distinct(Subscriber_Key__c) unique_cnt, External_Id__c 
                                             from EBC_Click_Event__c
                                             Where EBC_Campaign__c = :campaign.Id
                                             GROUP BY External_Id__c
                                             ORDER BY count(Id) DESC
                                             LIMIT 6
                                            ];
                
               Integer cnt = 0;
                for(AggregateResult ar : ars) {
                    String extId = (String)ar.get('External_Id__c');
                    EBC_Click_Event__c ece = [Select URL__c From EBC_Click_Event__c Where External_Id__c = :extId LIMIT 1];
                    
                    if (ece.URL__c==null) continue;
                    if (ece.URL__c == 'Unsubscribe') continue;                   
                    if (ece.URL__c.ContainsIgnoreCase('iecebc_optout')) continue;
                    
                    
                    cnt++;
                    
                    campaignLinkStats.put(ece.URL__c, new Map<String, Integer>{
                        'count' => (Integer)ar.get('cnt'),
                        'unique_count' => (Integer)ar.get('unique_cnt')
                    });
                    
                    if (cnt == 5) break;
                }
            }
            
            return campaignLinkStats;
        }
        set;
    }
    
    //==============================================================
    // Graphs
    // ==============================================================
    
    //Version 3 Opens Return String version
    public String First24HOpensV3 {
        get{
        	List<EBC_Campaign_Email_Tracking__c> fst24hOpens = new List<EBC_Campaign_Email_Tracking__c>();
            Map<Integer, Decimal> fst24hOpensMap = generateMap(24);
            //get send time from EBC campaign
            Integer sendHour = [Select Send_Datetime__c from EBC_Campaign__c where ID = :campaign.Id].get(0).Send_Datetime__c.hour();        
            fst24hOpens = [Select NumberofOpens__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c < 24]; 
            
            for (EBC_Campaign_Email_Tracking__c aTracking: fst24hOpens){
                Integer index = aTracking.Name.trim().lastIndexOf('+');
                //get starting hour of chart
                Integer hour = sendHour + Integer.valueOf(aTracking.Name.trim().substring(0,aTracking.Name.trim().length()-1).substring(index+1).trim());
                //system.debug('Hour:'+ hour);
                if(hour < 24){
                    Decimal anOpensTracking = aTracking.NumberofOpens__c;
                    fst24hOpensMap.put(hour, anOpensTracking); 
                }
            }
            Return JSON.serialize(fst24hOpensMap.values());       
        }
        private set;
    }
    
    //Retireve First 24 hours clicks number, test campaign id = a768E000000CuuH
    //Version 3 Clicks Return String version
    public String First24HClicksV3 {
        get{
        	List<EBC_Campaign_Email_Tracking__c> fst24hClicks = new List<EBC_Campaign_Email_Tracking__c>();
            Map<Integer, Decimal> fst24hClicksMap = generateMap(24);
            //get send time from EBC campaign
            Integer sendHour = [Select Send_Datetime__c from EBC_Campaign__c where ID = :campaign.Id].get(0).Send_Datetime__c.hour();        
            fst24hClicks = [Select NumberofClicks__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c < 24]; 
            
            for (EBC_Campaign_Email_Tracking__c aTracking: fst24hClicks){
                Integer index = aTracking.Name.trim().lastIndexOf('+');
                //get starting hour of chart
                Integer hour = sendHour + Integer.valueOf(aTracking.Name.trim().substring(0,aTracking.Name.trim().length()-1).substring(index+1).trim());
                //system.debug('Hour:'+ hour);
                if(hour < 24){
                    Decimal anClicksTracking = aTracking.NumberofClicks__c;
                    fst24hClicksMap.put(hour, anClicksTracking); 
                }
            }
            Return JSON.serialize(fst24hClicksMap.values());       
        }
        private set;
    }
    
    //Retrieve First 48 hours opens number, test campaign id = a768E000000CuuH
    //Version 3 Opens Return String version
   public String getFirst48HOpensV3(){
        List<EBC_Campaign_Email_Tracking__c> fst48hOpens = new List<EBC_Campaign_Email_Tracking__c>();
        Map<Integer, Decimal> fst48hOpensMap = generateMap(48);
        //get send time from EBC campaign
        Integer sendHour = [Select Send_Datetime__c from EBC_Campaign__c where ID = :campaign.Id].get(0).Send_Datetime__c.hour();        
        fst48hOpens = [Select NumberofOpens__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c < 48]; 
        
        for (EBC_Campaign_Email_Tracking__c aTracking: fst48hOpens){
            Integer index = aTracking.Name.trim().lastIndexOf('+');
            //get starting hour of chart
            Integer hour = sendHour + Integer.valueOf(aTracking.Name.trim().substring(0,aTracking.Name.trim().length()-1).substring(index+1).trim());
            //system.debug('Hour:'+ hour);
            if(hour < 48){
                Decimal anOpensTracking = aTracking.NumberofOpens__c;
                fst48hOpensMap.put(hour, anOpensTracking); 
            }
        }
        Return JSON.serialize(fst48hOpensMap.values());   
    }
    
    //Retireve First 48 hours clicks number, test campaign id = a768E000000CuuH
    //Version 3 Clicks Return String version
    public String getFirst48HClicksV3(){
        List<EBC_Campaign_Email_Tracking__c> fst48hClicks = new List<EBC_Campaign_Email_Tracking__c>();
        Map<Integer, Decimal> fst48hClicksMap = generateMap(48);
        //get send time from EBC campaign
        Integer sendHour = [Select Send_Datetime__c from EBC_Campaign__c where ID = :campaign.Id].get(0).Send_Datetime__c.hour();        
        fst48hClicks = [Select NumberofClicks__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c < 48]; 
        
        for (EBC_Campaign_Email_Tracking__c aTracking: fst48hClicks){
            Integer index = aTracking.Name.trim().lastIndexOf('+');
            //get starting hour of chart
            Integer hour = sendHour + Integer.valueOf(aTracking.Name.trim().substring(0,aTracking.Name.trim().length()-1).substring(index+1).trim());
            //system.debug('Hour:'+ hour);
            if(hour < 48){
                Decimal anClicksTracking = aTracking.NumberofClicks__c;
                fst48hClicksMap.put(hour, anClicksTracking); 
            }
        }
        Return JSON.serialize(fst48hClicksMap.values());   
    }
    
    //Retrieve First 7 days opens number, test campaign id = a768E000000CuuH
    //Version Opens Return String version
    public String getFirst7DOpens(){
        List<EBC_Campaign_Email_Tracking__c> fst1dOpens = new List<EBC_Campaign_Email_Tracking__c>();
        List<Decimal> fst7DaysOpens = new List<Decimal>();       
        fst1dOpens = [Select NumberofOpens__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c <= 24];
        Decimal day1Opens = 0;
        Integer counterNullD1 = 0;
        for (EBC_Campaign_Email_Tracking__c aTracking: fst1dOpens){
            if(aTracking.NumberofOpens__c == null){
                aTracking.NumberofOpens__c = 0;
                counterNullD1 += 1;
            }
            day1Opens +=  aTracking.NumberofOpens__c;
        }
        if (day1Opens == 0 && counterNullD1 == 24){
            day1Opens = null;
        }
        fst7DaysOpens.add(day1Opens);
        List<EBC_Campaign_Email_Tracking__c> fst2dOpens = new List<EBC_Campaign_Email_Tracking__c>();        
        fst2dOpens = [Select NumberofOpens__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c <= 48 and Rank__c > 24];
        Decimal day2Opens = 0;
        Integer counterNullD2 = 0;
        for (EBC_Campaign_Email_Tracking__c aTracking: fst2dOpens){
            if(aTracking.NumberofOpens__c == null){
                aTracking.NumberofOpens__c = 0;
                counterNullD2 += 1 ; 
            }
            day2Opens += aTracking.NumberofOpens__c;
        }
        if (day2Opens == 0 && counterNullD2 == 24 ){
            day2Opens = null;
        }

        fst7DaysOpens.add(day2Opens);  
        List<EBC_Campaign_Email_Tracking__c> restof7dOpens = new List<EBC_Campaign_Email_Tracking__c>();
        restof7dOpens = [Select NumberofOpens__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c >= 72];
        For (EBC_Campaign_Email_Tracking__c aTracking: restof7dOpens){
            fst7DaysOpens.add(aTracking.NumberofOpens__c);
        } 
        return  JSON.serialize(fst7DaysOpens);
    }
    
    //Retrieve First 7 days opens number, test campaign id = a768E000000CuuH
    //Version Opens Return String version
    public String getFirst7DClicks(){
        List<EBC_Campaign_Email_Tracking__c> fst1dClicks = new List<EBC_Campaign_Email_Tracking__c>();
        List<Decimal> fst7DaysClicks = new List<Decimal>();       
        fst1dClicks = [Select NumberofClicks__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c <= 24];
        Decimal day1Clicks = 0;
        Integer counterNullD1 = 0;
        for (EBC_Campaign_Email_Tracking__c aTracking: fst1dClicks){
            if(aTracking.NumberofClicks__c == null){
                aTracking.NumberofClicks__c = 0;
                counterNullD1 += 1;
            }
            day1Clicks += aTracking.NumberofClicks__c;
        }
        if (day1Clicks == 0 && counterNullD1 == 24){
            day1Clicks = null;
        }
        fst7DaysClicks.add(day1Clicks);
        List<EBC_Campaign_Email_Tracking__c> fst2dClicks = new List<EBC_Campaign_Email_Tracking__c>();        
        fst2dClicks = [Select NumberofClicks__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c <= 48 and Rank__c > 24];
        Decimal day2Clicks = 0;
        Integer counterNullD2 = 0;
        for (EBC_Campaign_Email_Tracking__c aTracking: fst2dClicks){
            if(aTracking.NumberofClicks__c == null){
                aTracking.NumberofClicks__c = 0;
                counterNullD2 += 1;
            }
            day2Clicks +=  aTracking.NumberofClicks__c;
        }
        if (day2Clicks == 0 && counterNullD2 == 24){
            day2Clicks = null;
        }
        fst7DaysClicks.add(day2Clicks);  
        List<EBC_Campaign_Email_Tracking__c> restof7dClicks = new List<EBC_Campaign_Email_Tracking__c>();
        restof7dClicks = [Select NumberofClicks__c, Name from EBC_Campaign_Email_Tracking__c where EBC_Campaign__c = :campaign.Id and Rank__c >= 72];
        For (EBC_Campaign_Email_Tracking__c aTracking: restof7dClicks){
            fst7DaysClicks.add(aTracking.NumberofClicks__c);
        } 
        return  JSON.serialize(fst7DaysClicks);
    }
    
    public String SentDate {
        get {
            if (SentDate == null) {
                SentDate = 'Sent time ' + [Select Send_Datetime__c from EBC_Campaign__c where ID = :campaign.Id].get(0).Send_Datetime__c.format('M/d/yyyy h:mm a');
            }
            return SentDate;
        }
        set;
    }
    
    //Generation a map <Hour,null> based on hours for retrieve opens/clicks use 
    public static Map<Integer, Decimal> generateMap(Integer numberOfHours){    
        Map<Integer, Decimal> initMap = new Map<Integer, Decimal>();
        for (integer i=1; i<=numberOfHours; i++){
            initMap.put(i,null);
        }       
        return initMap;
    }
    
    //Generation a map <Hour,null> based on hours for retrieve opens/clicks use 
    /*
    public static Map<Integer, String> generateMapString(Integer numberOfHours){    
        Map<Integer, String> initMap = new Map<Integer, String>();
        for (integer i=0; i<numberOfHours; i++){
            initMap.put(i,' ');
        }       
        return initMap;
    }
    */
    
    //X-axis for 7-days chart
    public String getXAxis7d(){
        List<String> days = new List<String>();
        for (Integer i = 0; i <=6; i++){
            Integer day = [Select Send_Datetime__c from EBC_Campaign__c where ID = :campaign.Id].get(0).Send_Datetime__c.addDays(i).day();
            Integer month = [Select Send_Datetime__c from EBC_Campaign__c where ID = :campaign.Id].get(0).Send_Datetime__c.addDays(i).month();
            days.add(month + '/' + day);  
            //days.add('\'' +  month + '/' + day + '\'');  
        }
        return JSON.serialize(days);
    }
    
    //==============================================================
    
    public PageReference save() {       
        //update campaign;
        return null;
    }
}
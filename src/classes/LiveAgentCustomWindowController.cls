public with sharing class LiveAgentCustomWindowController {

    public String language{
        get{
            if (language == null){
                try{
                    // hack to get language - language parameter cannot be retrived by url due to Live Agent limitations
                    String referer = ApexPages.currentPage().getHeaders().get('Referer');
                    String key = referer.substringAfter('csButton=').substringBefore('&');
                    language = getCSetting(key).Language__c;
                }catch (Exception e){
                    try{
                        language = ApexPages.currentPage().getCookies().get('lang').getValue();
                        return language;
                    }catch (Exception exc){
                        return 'en';
                    }
                }
            }
            return language;
        }
        set;
    }
    public LiveAgentButtonSettings__c getCSetting(String key) {
        LiveAgentButtonSettings__c labs = new LiveAgentButtonSettings__c();
        try{
            labs = LiveAgentButtonSettings__c.getAll().get(key);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'{!$Label.LiveAgentCustomSettingNotFound} '+e));
        }
        return labs;
    }

    public LiveAgentCustomWindowController (){

    }
}
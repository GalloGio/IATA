public without sharing  class LiveAgentCustomWindowController {
    public static final String LVA_DEFAULT_CHAT_IMAGE = 'LVA_DEFAULT_CHAT_IMAGE';
    public static final String DEFAULT_IMAGE = '/profilephoto/005/T';

    private Set<String> rtlLanguages = new Set<String>{'ar'};

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

    public boolean isRTL{
        get{
            if(rtlLanguages.contains(language)) {
                return true;
            }
            return false;
        }
        set;
    }

    public String defaultChatImg{
        get{
            String resourceName = vfISSP_FAQ2Case.getLivAgConfig(LVA_DEFAULT_CHAT_IMAGE);
            // Fetching the resource
            List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

            // Checking if the result is returned or not
            if(resourceList.size() == 1){
                // Getting namespace
                String namespace = resourceList[0].NamespacePrefix;
                // Resource URL
                return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName;
            }else{
                return DEFAULT_IMAGE;
            }
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


    @RemoteAction
    public static user getPhoto(String userId)
    {
        try{
            User usr = new user();
            usr = [SELECT SmallPhotoUrl, Name, LVA_Show_photo_on_chat__c, Title, LVA_Language_Skills__c FROM User WHERE Id =: userId];
            return usr;
        }catch(Exception e){
            return null;
        }
    }

    @RemoteAction
    public static Map<String, String> getLanguages(String userId){
        try{
            String userLanguageSkills = [SELECT LVA_Language_Skills__c FROM User WHERE Id =: userId][0].LVA_Language_Skills__c;
            Map<String,String> languageIsoMap = new Map<String,String>();
            if(userLanguageSkills != null){
                String [] splitedUserLanguageSkills = userLanguageSkills.split(';');
                Schema.DescribeFieldResult field = User.LVA_Language_Skills__c.getDescribe();

                for (Schema.PicklistEntry entry : field.getPicklistValues()){
                    for(String languageSkill : splitedUserLanguageSkills){
                        if(entry.getValue() == languageSkill){
                            languageIsoMap.put(entry.getValue(), entry.getLabel());
                        }
                    }
                }
            }

            return languageIsoMap;
        }catch(Exception e){
            return null;
        }
    }
}
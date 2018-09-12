public with sharing class OneIdTermsAndConditions {
    
    public static String ToTranslate(String toTranslate){
    	LabelTranslator translator = new LabelTranslator();
        String translatedString = translator.translate(toTranslate,UserInfo.getLanguage());
        return translatedString;
    }

    @AuraEnabled
    public static List<String> getAppTerms(String selectedapp){
        List<String> appInfo = new List<String>();

        try{
        
            System.debug('selectedapp'+ selectedapp);
            
            List<One_Id_Service_Provider_Config__c> bundles = OneIdProvisioningDAO.getAppInfo(selectedapp);

            if(!bundles.isEmpty()){
            
                //System.debug('bundles '+ bundles);
            
                String confCLabel1 = bundles.get(0).Terms_Custom_Label_1__c;
                String confCLabel2 = bundles.get(0).Terms_Custom_Label_2__c;
                String confCLabel3 = bundles.get(0).Terms_Custom_Label_3__c;
                
                //System.debug('confCLabel1  '+ confCLabel1 );
                
                String terms1 = ToTranslate(confCLabel1);
                String terms2 = ToTranslate(confCLabel2);
                String terms3 = ToTranslate(confCLabel3);
                

                //ystem.debug('translation '+ translatedString);
                appInfo.add(bundles.get(0).Service_Provider_Name__c);
                appInfo.add(terms1);
                appInfo.add(terms2);
                appInfo.add(terms3);
                
                if(bundles.get(0).Additional_Terms_Custom_Labels__c != null){
                    for(String additionalTerm : bundles.get(0).Additional_Terms_Custom_Labels__c.split(',')){
                        String terms = ToTranslate(additionalTerm);
                        System.debug('terms : ' + terms);
                        appInfo.add(terms);
                    }
                }
                
            } else {
                appInfo.add('None Found');
            }
        } 
        catch(Exception error){
            System.debug(error);
        }
        return appInfo;
    }
    
}
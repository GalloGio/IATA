public class RecordTypeSingleton {

    private  static RecordTypeSingleton instance = null;
        public  map<string,map<string,id>> RtIDsPerDeveloperNamePerObj {get;private set;}
    
        private RecordTypeSingleton(){
                    RtIDsPerDeveloperNamePerObj = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string>{'Account','Contact','Case','Opportunity','Contract','ID_Card_Application__c', 'EmailTemplate__c'});
                        
        }
            
      public static RecordTypeSingleton getInstance(){
      
         if(instance == null) instance = new RecordTypeSingleton();
            return instance;
      
      }
     


}
public class AMS_OSCAR_JSON {

	public Process[] processes;

	public class Process{

		public String name{get;set;}
		
		public Flow[] flows{get;set;}

	}

	public class Flow{

		public String name{get;set;}
		
		public Step[] steps{get;set;}

	}

	public class Step{

		public String name{get;set;}
		
		public String label{get;set;}
		
		public String[] required{get;set;}
		
		public Action[] actions{get;set;}
		
		public Automation[] automations{get;set;}
		
		public String[] displayFields{get;set;}
		
		public boolean isDependent{get;set;}

	}

	public class Automation{
		
		public String status{get;set;}
		
		public String className{get;set;}
        
        public ChangeCode changeCode{get;set;}

	}

	public class Action{

		public String functionName{get;set;}

		public String actionLabel{get;set;}
		
		public String[] args{get;set;}
	}
    
    public class ChangeCode{
		
		public String name{get;set;}
		
		public String reasonCode{get;set;}
        
        public String memoText{get;set;}
        
        public String reasonDesc{get;set;}
        
        public String status{get;set;}

        public boolean publishedOnEBulletin{
          get{
            Boolean bRes = true;
            if(publishedOnEBulletin != null){
                bRes = publishedOnEBulletin;
              }
              return bRes;
          	}
        set;}

	}
	 

}
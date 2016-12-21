public class AMS_OSCAR_JSONHelper {

    public AMS_OSCAR_JSON oscarJSONProcess {get;set;}

    public AMS_OSCAR_JSONHelper() {

    }

    /*******************************************************************************************************
    * @description loads a static resource from the database. This resource must be a valid JSON File that contains
    * The Accreditation Process
    * returns true if load is succesfull, false otherwise
    */
    public boolean loadJsonResource(String staticResource){

        if(staticResource == null){
            System.debug('Cannot load JSON from null static resource');
            return false;
        }

        try{
            StaticResource jsonFile = [select Id , Name , Body from StaticResource where Name = :staticResource];

            String jSONContent = convertToString(jsonFile.Body);

            JSONParser parser = JSON.createParser(jSONContent);
            
            parser.nextToken();
            parser.nextToken();
            parser.nextToken();
            
            this.oscarJSONProcess = (AMS_OSCAR_JSON)parser.readValueAs(AMS_OSCAR_JSON.class);

            if(oscarJSONProcess.processes == null){
                System.debug('Could not load the processes into structures, please revise the JSON File submited as ' + staticResource);
                return false;
            }

        }catch(Exception e){
            System.debug('Something went wrong. Cause:' + e.getStackTraceString());
            return false;
        }

      

        return true;
    }

    /*public List<AMS_OSCAR_JSON.Process> getProcesses(){
        
        return oscarJSONProcess.processes;

    }*/

    public AMS_OSCAR_JSON.Process getProcess(String process){
        
        for(AMS_OSCAR_JSON.Process p: oscarJSONProcess.processes){
            if(p.name == process)
                return p;
        }

        return null;

    }

    /*public List<AMS_OSCAR_JSON.Flow> getFlows(){
        
        List<AMS_OSCAR_JSON.Flow> toReturn = new List<AMS_OSCAR_JSON.Flow>();
        
        for(AMS_OSCAR_JSON.Process p: oscarJSONProcess.processes){

            toReturn.addAll(p.flows);
        }

        return toReturn;
    }*/

    public List<AMS_OSCAR_JSON.Flow> getFlows(AMS_OSCAR_JSON.Process p){
                
        List<AMS_OSCAR_JSON.Flow> toReturn = new List<AMS_OSCAR_JSON.Flow>();

        for(AMS_OSCAR_JSON.Flow f: p.flows)
            toReturn.add(f);            

        return toReturn;
    }


    /*public AMS_OSCAR_JSON.Flow getFlow(String flow){
                
        for(AMS_OSCAR_JSON.Process p: oscarJSONProcess.processes){
            for(AMS_OSCAR_JSON.Flow f: p.flows)
                if(f.name == flow)
                    return f;
            
        }

        return null;
    }*/

    /*public List<AMS_OSCAR_JSON.Step> getSteps(){
        
        List<AMS_OSCAR_JSON.Step> toReturn = new List<AMS_OSCAR_JSON.Step>();
        
        for(AMS_OSCAR_JSON.Process p: oscarJSONProcess.processes)
            for(AMS_OSCAR_JSON.Flow f: p.flows)
                toReturn.addAll(f.steps);

        return toReturn;
    }*/

    public List<AMS_OSCAR_JSON.Step> getSteps(List<AMS_OSCAR_JSON.Flow> flist){
        
        List<AMS_OSCAR_JSON.Step> toReturn = new List<AMS_OSCAR_JSON.Step>();
        
        for(AMS_OSCAR_JSON.Flow f: flist)
            toReturn.addAll(f.steps);

        return toReturn;
    }


    /*public AMS_OSCAR_JSON.Step getStep(String step){
                
        for(AMS_OSCAR_JSON.Process p: oscarJSONProcess.processes)
            for(AMS_OSCAR_JSON.Flow f: p.flows)
                for(AMS_OSCAR_JSON.Step s: f.steps)
                    if(s.name == step)
                        return s;

        return null;
    }*/
    
    /*public AMS_OSCAR_JSON.ChangeCode getStepChangeCode(String processName, String step){
        
        AMS_OSCAR_JSON.Process p = getProcess(processName);
        
        
        
    }*/


    public boolean processAutomation(String processName, String stepName, String statusName, AMS_OSCAR__c oscar){

        System.debug('Starting to process  the automation given process ' + processName + ' , the step ' + stepName + ' and the status ' + statusName);

        if(isEmptyOrNull(processName) || isEmptyOrNull(stepName) || isEmptyOrNull(statusName) || oscar == null)
            System.debug('Could not find the automation given process ' + processName + ' , the step ' + stepName + ' and the status ' + statusName + '. Is the AMS_OSCAR__c null?');

        AMS_OSCAR_JSON.Process p = getProcess(processName);

        if(p == null){
            System.debug('Could not find process ' + processName);
            return false;
        }

        List<AMS_OSCAR_JSON.Step> steps = getSteps(getFlows(p));

        for(AMS_OSCAR_JSON.Step s : steps){
            if(s.name == stepName){
                    for(AMS_OSCAR_JSON.Automation a: s.automations){
                        if(a.status == statusName)
                            {
                                AMS_OSCAR_JSON.ChangeCode changeCode = a.changeCode;
                                if(changeCode != null){
                                    //AMS_ChangeCodesHelper.createAAChangeCode(changeCode, oscar, oscar.Account__c);    
                                    Account acct = new Account(Id = oscar.Account__c);
                                    System.debug('Creating Agency Applied changeCode for Account ' + acct.Id);
                                    AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscar}, new List<Account>{acct}, true);
                                    System.debug('Done creating Agency Applied changeCode for Account ' + acct.Id);
                                }
                                AMS_OSCAR_AutomationManager am = new AMS_OSCAR_AutomationManager();
                                return am.newClassInstance(a.className).processWork(null, oscar);
                            }
                    }
            }
        }

        System.debug('Could not find the automation given process ' + processName + ' , the step ' + stepName + ' and the status ' + statusName);
        
        return true;

    }

    //utils
    public static String convertToString(Blob value){
        return EncodingUtil.urlDecode(value.toString(), 'UTF-8');
    }

    public static boolean isEmptyOrNull(String s){
        return s == null || s == '';
    }

}
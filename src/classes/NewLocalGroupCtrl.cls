global  class NewLocalGroupCtrl {

    public List<IATA_ISO_Country__c> countriesNotAllowed;
    public List<Cluster__c> clustersAllowed;
    public LocalGovernance__c lg;
    List<Cluster_to_ISO_Country__c> nton;
    public List<SelectOption> allClusters {get;set;}
    public integer getAllClustersSize(){return allClusters==null ? 0 : allClusters.size();}
    public String theCluster {get;set;}

    public NewLocalGroupCtrl(ApexPages.StandardController stdctrl){
        lg = (LocalGovernance__c)stdctrl.getRecord();
        onChangeGroupType();
        redirect();
    }

    public PageReference redirect(){
        Boolean redirect = false;
        String recordId =  ApexPages.currentPage().getParameters().get('id');
        // 1. if there is already a recordtype set redirect accordingly
        if(RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Reg_Div_Groups') == lg.RecordTypeId){
            redirect = true;
        }else if(RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Local_Groups') == lg.RecordTypeId){
            redirect = false;
        }
        // 2. if the user can only see one recordtype it's null and we check which type the user has access to
        if(!redirect && lg.RecordTypeId == null) {
            for(RecordTypeInfo info: LocalGovernance__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable()) {
                    if( info.getName() == 'Reg/Div Groups') {
                        redirect = true;
                    }
                }
            }
        }

        if(redirect){
        String prURL = '/apex/AMP_NewIATAGroup?';

        if(recordId != null) prUrl +='id='+recordId;
        String recordType =  ApexPages.currentPage().getParameters().get('RecordType');
        if(recordType != null) prUrl +='RecordType='+recordType;
        String retUrl =  ApexPages.currentPage().getParameters().get('retUrl');
        if(retUrl != null) prUrl +='&retURL='+retUrl;
        prUrl +='&save_new=1&sfdc.override=1';
        PageReference pageRef = new PageReference(prURL);
        pageRef.setRedirect(true);
        return pageRef;
      }
      else return null;
    }

    public void onChangeGroupType(){
        // I cannot do that by filtered lookup because it's from parent to child
        nton = [SELECT IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Cluster__c, Cluster__r.Name,
                		Cluster__r.Local_Group_type__c,  Cluster__r.Region__c, Cluster__r.Country_Manager__c, Cluster__r.IATA_Local_Office__c
                FROM Cluster_to_ISO_Country__c
                WHERE Cluster__r.Local_Group_type__c = :lg.Local_Governance_type__c];
       	system.debug(LoggingLevel.ERROR,'###### CERCO PER TYPE = '+lg.Local_Governance_type__c);
        set<Id> displayedClusters = new set<Id>();
        allClusters = new List<SelectOption>();
        allClusters.add(new SelectOption('','-- None --'));
        for(Cluster_to_ISO_Country__c c : nton){
            if(!displayedClusters.contains(c.Cluster__c)){
            	allClusters.add(new SelectOption(c.Cluster__c,c.Cluster__r.Name));
                displayedClusters.add(c.Cluster__c);
                system.debug(LoggingLevel.ERROR,'###### '+c.Cluster__r.Name);
            }
        }
        system.debug(LoggingLevel.ERROR,'###### HO ALLCLUISTERSIZE = '+getAllClustersSize());
    }

    public PageReference MySave(){
        //if(nton==null)
        	onChangeGroupType();
        if(lg.Country__c==null && lg.Cluster__c==null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You must choose a country or a cluster.'));
        	return null;
        }else if(lg.Country__c!=null && lg.Cluster__c!=null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You cannot choose both a country and a cluster.'));
        	return null;

    	}else if(lg.Cluster__c!=null){
        	boolean clusterAllowed = false;
            for(Cluster_to_ISO_Country__c c2c : nton)
                if(c2c.Cluster__c == lg.Cluster__c){
                    clusterAllowed = true;
                    break;
                }

            if(!clusterAllowed){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'This cluster is not allowed for Local Group Type '+lg.Local_Governance_type__c));
        		return null;
            }

        }else if(lg.Country__c!=null){
			boolean countryAllowed = true;
			String clustername = '';
            for(Cluster_to_ISO_Country__c c2c : nton)
                if(c2c.IATA_ISO_Country__c == lg.Country__c){
                    countryAllowed = false;
                    clustername = c2c.Cluster__r.Name;
                    break;
                }

            if(!countryAllowed){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'This country is not allowed for Local Group Type '+lg.Local_Governance_type__c+' because it is part of cluster '+clustername));
        		return null;
            }

        }
        system.debug('----------------  Passo validazioni iniziali --------------------');
        List<LocalGovernance__c> dup = [SELECT Name, Id FROM LocalGovernance__c
                                        WHERE Id <> :lg.Id AND RecordType.DeveloperName='Local_Groups' AND Cluster__c=:lg.Cluster__c AND Country__c=:lg.Country__c
                                                AND Local_Governance_type__c=:lg.Local_Governance_type__c ]; // AND Active__c=true

        if(dup.size()>0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: the local group <a href="/'+dup[0].Id+'">'+dup[0].Name+'</a> exists already.'));
            return null;
        }

        //lg.Active__c = true;
        system.debug('----------------  niente duplicati --------------------');
        database.UpsertResult sr = database.upsert(lg,false);
        if(!sr.isSuccess()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: '+sr.getErrors()[0].getMessage()));
            system.debug('----------------  Error saving local group: '+sr.getErrors()[0].getMessage()+' --------------------');
            return null;
        }
        return new PageReference('/'+sr.getId());

    }

    webService static String deactivateLocalGroup(String localgroupid) {
        List<LocalGovernance__c> lg = [SELECT ID FROM LocalGovernance__c WHERE ID = :localgroupid];
        if(lg.size()==1){
            lg[0].Active__c = false;
            database.SaveResult sr = database.update(lg[0],false);
            if(!sr.isSuccess()){
                return 'Error: '+sr.getErrors()[0].getMessage();
            }
            return '';
        }else
        	return 'Internal error. Please contact administrator';
    }

}

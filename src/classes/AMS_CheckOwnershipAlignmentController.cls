public with sharing class AMS_CheckOwnershipAlignmentController {

    public String email {get;set;}
    public String batchSize {get{
        System.debug('## before get');
        if (batchSize == null || !batchSize.isNumeric()){
            System.debug('## getting');
            return '50';
        }else return batchsize;
    }
    set;}

    public List<SelectOption> getROptions(){

        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Account.iata_iso_country__r.Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple){
              options.add(new SelectOption( f.getValue(),f.getLabel()));
        }
        options.add(new SelectOption('All Countries','All Countries'));
           return options;
    }
    public String qRegion {get; set;}

    public AMS_CheckOwnershipAlignmentController() {

    }

    public void checkowners(){
        Boolean emptyList = false;
        System.debug('## batchsize: '+ batchsize);
        System.debug('## qRegion: '+ qRegion);
        Id batchJobId = Database.executeBatch(new AMS_CheckOwnershipAlignmentBatch(qRegion,email), Integer.valueOf(batchSize));
    }

}

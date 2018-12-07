public with sharing class AMS_VoucherManagerController {

        public boolean batchStatusBool{get;set;}

        public boolean pollerBool{get;set;}

        public String batchAverageStatus{get;set;}

        public String emailNotification{get;set;}

        public List<IATA_ISO_Country__c> countries{get;set;}

        public Id batchCountryAverageId{get;set;}

        public boolean canExecuteBatch;

        public boolean countriesUploaded{get;set;}

        public string region{get; set;}

        public String year{get; set;}
    
		public AMS_Voucher_Region__c regionObject{get;set;}

        public List<String> countriesLst{get; set;}

        public String reportURL{get;set;}

        public String reportPage{get;set;}

        public AMS_Voucher_Process_Run__c process{get;set;}

        public Set<String> notes{
                get{
                                
                                notes = new Set<String>();
                                notes.add('Use Data Loader to reset the amount of sales all the cargo agencies in the region');
                                notes.add('Use Data Loader to set the new sales amount of last year for the agencies in the region.');
                                notes.add('Select a region and a set of countries to start the calculation for that region which will calculate the average for each country in that region and update each agency with the number of vouchers and their unique identifier.');
                                notes.add('If an Agency already has vouchers assigned for a specific Year, it will not generate more vouchers. In this case the agency needs to remove the assigned vouchers to be ready to run again.');

                        return notes;
                }
                set;
        }

        public List<String> noteList{
                get{
                        return new List<String>(notes);
                }
                set;
        }

        public AMS_VoucherManagerController() {
                
                countriesLst = new List<String>();

                countriesUploaded = false;

                countries = new List<IATA_ISO_Country__c>();

                batchStatusBool = false;

                batchAverageStatus = 'Processing vouchers information...';

                batchCountryAverageId = null;   

        }


        public void runCountryAverageBatch(){

                pollerBool = false;

                Set<Id> setCountries = new Set<Id>();

                Set<String> countryList = new  Set<String>();
                countryList.addAll(countriesLst);
                List<IATA_ISO_Country__c> contrTmpLst = IATAIsoCountryDAO.getIsoCountriesByIds(countryList);

                for(IATA_ISO_Country__c country: contrTmpLst){
                        setCountries.add(country.Id);
                }

                process = new AMS_Voucher_Process_Run__c(status__c = 'Started');

                insert process;

            	batchStatusBool = true;
            
                AMS_VoucherProcessManager ams_VPM = new AMS_VoucherProcessManager(process);

                ams_VPM.setCountries(setCountries);

                System.debug('Starting the process for year ' +  year);

                Id batchCountryAverageId = ams_VPM.runVouchersProcess(year);

                String urlCode = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());

                String customReport = '';

                if(!Test.isRunningTest())
                    customReport = buildCustomReport(process.Id);

                reportURL = '/' + urlCode + customReport;

                reportPage = customReport;

                checkBatchStatus();

        }

        private String buildCustomReport(String batchId){
                
                Report rep = [select id, name, developerName, description from report where Name = 'Voucher Batch Report' LIMIT 1];

                return rep.Id + '?pv0=' + batchId;
        }

        public void checkBatchStatus() {

            AMS_Voucher_Process_Run__c processRun = [SELECT Id, Status__c FROM AMS_Voucher_Process_Run__c WHERE Id =: process.Id];
        	
            emailNotification = 'As the vouchers created can take a long time (depending on the amount of agencies envolved), an email will be sent to you after processing.';
            
            if(processRun.Status__c == 'Ended') {
            	batchAverageStatus = 'Completed.';
                pollerBool = false;
				regionObject = [SELECT id, (select id, Name from Attachments)  from AMS_Voucher_Region__c where Name = :region];
            } else {
                pollerBool = true;
            }
        }


    public list<selectoption> getcountryobj(){

                list<selectoption> options= new list<selectoption>();

                list<IATA_ISO_Country__c> contr= IATAIsoCountryDAO.getIsoCountriesByRegion(new Set<String>{region});

                if(contr.isEmpty()){
                    options.add(new selectoption('Select Country', 'Select Country'));
                    countriesLst.clear();
                    
                }
                for(IATA_ISO_Country__c c : contr){

                    if(c.AMS_Vouchers_Benchmark__c != null && c.AMS_Max_Vouchers_Per_Year__c != null && c.AMS_Max_Vouchers_Per_Year__c > 0) {
                        options.add(new selectoption(c.Id,c.name));
                    }
                }

                return options;

        }

    public list<selectoption> getregionobj(){

                list<selectoption> options= new list<selectoption>();

                options.add(new selectoption('Select Region', 'Select Region'));

                options.add(new selectoption('Africa & Middle East','Africa & Middle East'));
                options.add(new selectoption('Americas','Americas'));
                options.add(new selectoption('Asia & Pacific','Asia & Pacific'));
                options.add(new selectoption('China & North Asia','China & North Asia'));
                options.add(new selectoption('Europe','Europe'));

                return options;

        }

    public list<selectoption> getyearobj(){

                list<selectoption> options= new list<selectoption>();

                
                for( Integer i = 1990 ; i <= 2100 ; i++){

                        options.add(new selectoption(String.valueOf(i),String.valueOf(i)));
                }

                return options;

        }

        public boolean getcanExecuteBatch(){

            For(String ctr: countriesLst){
                if(ctr == 'Select Country')
                    return false;
            }
            return countriesUploaded && !countriesLst.isEmpty() && process == null;

        }

}
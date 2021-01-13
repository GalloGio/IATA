Global class BtchAirlinesStatistics implements database.batchable<Sobject>,Database.Stateful
{
		global Map<String, GDP_Airlines_Statistic__c> amap = new Map<String, GDP_Airlines_Statistic__c>();
		global DateTime LastUpdate = System.Now();

		global Database.QueryLocator start(Database.BatchableContext BC)
		{
				string Query = 'Select Country_Name__c';
								Query += ',Location_Type__r.Table__c';
								Query += ',Location_Type__r.Code__c';
								Query += ',State_Province__c';
								Query += ',Related_Accreditation_Class__r.Class__r.Code__c';
								Query += ' From GDP_Products_Account_View__c';
								Query += ' Where Location_Type__r.Table__c=\'LOCTYP\' ';
								Query += ' and Agency_status_code__c>=4 ';
								Query += ' AND Country_Name__c != null';

				return Database.getQueryLocator(Query);
		}


		global void execute(Database.batchableContext BC, List<GDP_Products_Account_View__c> scope)
		{


		 String country='';
		 String state='';
		 String code='';
		 String key='';
		 String kclass='';
		 String nclass='';
		 for(GDP_Products_Account_View__c s:scope) {
				 country='';
				 state='';
				 code='';
				 kclass='';
				 nclass='';
				 if (s.Related_Accreditation_Class__r.Class__r.Code__c!=null ) kclass=s.Related_Accreditation_Class__r.Class__r.Code__c;
				 if (s.Country_Name__c!=null)   country=s.Country_Name__c.ToUpperCase();
				 if (s.State_Province__c!=null) state=s.State_Province__c.ToUpperCase();
				 if (s.Location_Type__r.Code__c!=null) code=s.Location_Type__r.Code__c;
				 if (kclass=='P' || kclass=='D' || kclass=='V') nclass='PAL';
				 if (kclass=='C') nclass='CAL';
				 if (kclass=='M' || kclass=='G' || kclass=='X' || kclass=='K') nclass='ASL';
				 key = nclass + country + state;
				 GDP_Airlines_Statistic__c stats;
				 if (amap.ContainsKey(key)) {
						stats= amap.get(key);
						}
				 else
				 {
						stats   = new GDP_Airlines_Statistic__c();
						stats.Country__c = country;
						stats.State__c = state;
						stats.Class__c = nclass;


						stats.Key__c = key;
						stats.AO__c = 0;
						stats.SA__c = 0;
						stats.HO__c = 0;
						stats.BR__c = 0;
						stats.ES__c = 0;
						stats.EP__c = 0;
						stats.ST__c = 0;

						stats.SE__c = 0;
						stats.SP__c = 0;
						stats.TD__c = 0;
						stats.IC__c = 0;
						stats.AA__c = 0;
						stats.AC__c = 0;
						stats.AW__c = 0;
						stats.EB__c = 0;
						stats.WH__c = 0;
						stats.CS__c = 0;
						amap.put(key, stats);
				 }
				 stats.Last_Update__c=LastUpdate;

				 if (code=='AO') stats.AO__c += 1;
				 if (code=='SA') stats.SA__c += 1;
				 if (code=='HO') stats.HO__c += 1;
				 if (code=='BR') stats.BR__c += 1;
				 if (code=='ES') stats.ES__c += 1;
				 if (code=='EP') stats.EP__c += 1;
				 if (code=='ST') stats.ST__c += 1;

				 if (code=='SE') stats.SE__c += 1;
				 if (code=='SP') stats.SP__c += 1;
				 if (code=='TD') stats.TD__c += 1;
				 if (code=='IC') stats.IC__c += 1;
				 if (code=='AA') stats.AA__c += 1;
				 if (code=='AC') stats.AC__c += 1;
				 if (code=='AW') stats.AW__c += 1;
				 if (code=='EB') stats.EB__c += 1;
				 if (code=='WH') stats.WH__c += 1;
				 if (code=='CS') stats.CS__c += 1;
		 }



		}

		Global void finish(database.batchableContext BC)
		{

		 Schema.SObjectField f = GDP_Airlines_Statistic__c.Fields.Key__c;
		 Database.UpsertResult [] cr = Database.upsert(amap.Values(), f, false);

		 List<GDP_Airlines_Statistic__c> slist = new List<GDP_Airlines_Statistic__c>();

		 slist = [Select Id From GDP_Airlines_Statistic__c Where Last_Update__c!=:LastUpdate];

		 if (slist.Size()>0) delete slist;

		}



}

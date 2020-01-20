public  class AcliParser {

		 public static AcliWrapper AcliParsingNotFound(String acliTxtFile,integer MINLEVEL, integer MAXLEVEL,boolean stateOFF){
										//  throw new transformationException('acliTxtFileString???  '+acliTxtFile +  ' MINLEVEL ' +   MINLEVEL +  '  MAXLEVEL ' + MAXLEVEL);

						return  AcliParsing(acliTxtFile,false,MINLEVEL,MAXLEVEL,stateOFF);

				}
				public static AcliWrapper AcliParsingFound(String acliTxtFile,integer MINLEVEL, integer MAXLEVEL,boolean stateOFF){

						return  AcliParsing(acliTxtFile,true,MINLEVEL,MAXLEVEL,stateOFF);


				}



		 public static AcliWrapper AcliParsing(String acliTxtFile,boolean found,integer MINLEVEL, integer MAXLEVEL,boolean stateOFF){

					 AcliWrapper AcliWrapper;
					 AcliWrapper AcliWrapperMethod =AcliAcctsPerSitePlusStateRETURN(acliTxtFile,found,MAXLEVEL,stateOFF);

						map<String,AcliAccount> AcliAcctsPerSitePlusStateTmp = AcliWrapperMethod.AcliAccount;
						integer numOfLines=AcliWrapperMethod.NumberOfLines;
						map<String,AcliAccount> AcliAcctsPerSitePlusStateRETURN = new map<String,AcliAccount>();

						map<integer,string> sitePerLine =new  map<integer,string>();
						integer index = 0;
						for(string site:AcliAcctsPerSitePlusStateTmp.keySet()){
										sitePerLine.put(index,site);
										index++;
						}

						for(integer i=MINLEVEL;i<MAXLEVEL;i++){
										string key = sitePerLine.get(i);
										if(key <> null)
										AcliAcctsPerSitePlusStateRETURN.put(key,AcliAcctsPerSitePlusStateTmp.get(key));
						}


					 AcliWrapper = new  AcliWrapper(MAXLEVEL,numOfLines,AcliAcctsPerSitePlusStateRETURN);
									//      throw new transformationException(''+AcliWrapper );
					 return AcliWrapper;
				}


				private static AcliWrapper AcliAcctsPerSitePlusStateRETURN(String acliTxtFile,boolean found,integer MAXLEVEL,boolean stateOFF ){
						AcliWrapper returnValue;
						map<String,AcliAccount> AcliAcctsPerSitePlusStateRETURN = new map<String,AcliAccount>();
						map<String,AcliAccount> AcliAcctsPerSitePlusState = new map<String,AcliAccount>();
						map<String,AcliAccount> AcliAcctsPerREALSite = new map<String,AcliAccount>();

						set<string> sites = new set<string>();

									 AcliAccount tmp;
										INTEGER SKIPPED = 0;
										string separator =  acliTxtFile.contains('<br>') ?  '<br>' : '\\n';
										for(String line : acliTxtFile.split(separator)) {

														 tmp = new AcliAccount(line,stateOFF);


												// we exclude some of the airlines cause of some IATA accts that are there and there should not be
														 if(!
																		(    tmp.twoCaracterCOde.trim() =='XD'
																				|| tmp.twoCaracterCOde.trim() =='XB'
																				|| tmp.AirlineName.contains('Settlement Plan')
																				|| tmp.AccountingCode.trim() == '950'
																				|| tmp.AccountingCode.trim() == '952'
																				||(stateOFF && tmp.twoCaracterCOde.trim() =='1I')
																		)
																){

	 //if(tmp.AccountSite.contains('1G 773 GB'))
		 //                               throw new transformationException('-'+tmp.AccountSite+'-');
																 AcliAcctsPerSitePlusState.put(tmp.AccountSite,tmp);
																	AcliAcctsPerREALSite.put(tmp.realSite,tmp);
																 sites.add(tmp.RealSite);
														 }ELSE{


																		 SKIPPED ++;
																}
										system.debug('@@@ skipped lines  ' + skipped );
										}

								integer totalLines =0;
								list<Account> acctOnDb = [SELECT ID, site_index__c, billingState ,ACLI_Status__c,
																								 name, billingCity,billingCountry,billingPostalCode,
																								 billingStreet,Name_on_AOC__c,
																								 site,Airline_designator__c,Account_code_secondary_flag__c,
																								 Accounting_Code__c,Airline_Prefix__c,Field_Head_Office__c,
																								 Industry,Type,IATACode__c,Membership_status__c,
																								 IATA_ISO_Country__c,IATA_ISO_Country__r.ISO_Code__c,
																								 Legal_name__c,Membership_SITA__c,
																								 Memmership_ARINC__c,Memmership_ATA__c,
																								 Type_of__c,LastModifiedDate  //type of operations
																					FROM Account
																					WHERE site_index__c In:sites
																					AND recordtype.developername = 'IATA_Airline'
																					AND Acli_Status__c <> 'Inactive Company'
																					];

						map<string,Account> accountOnDbPerChiave = new map<string,Account>();

						string site;
						for(Account a:acctOnDb){
//throw new transformationException(''+a);
								site ='';
								site = TransformationHelper.buildSiteForAcli(a.IATACode__c, a.Airline_designator__c,a.IATA_ISO_Country__r.ISO_Code__c,null ) ;
										site = site.toUpperCase();
										string realSite = site;
										string bilstate = a.BillingState <> null ? a.BillingState:'';
									if(!stateOFF && bilstate <> '')site +=bilstate.trim();

										accountOnDbPerChiave.put(site,a);


						if(found && AcliAcctsPerSitePlusState.get(site)<> null){

																				AcliAcctsPerSitePlusState.get(site).ExistingInSFDC = true;
																				AcliAcctsPerSitePlusState.get(site).AcctID = accountOnDbPerChiave.get(site).id;
																				AcliAcctsPerSitePlusState.get(site).LastModifiedDate = accountOnDbPerChiave.get(site).LastModifiedDate;
																				AcliAcctsPerSitePlusStateRETURN.put(site,AcliAcctsPerSitePlusState.get(site));
																				AcliAcctsPerSitePlusStateRETURN.get(site).ExistingInSFDC = true;
																				totalLines++;

										}else if(!found && AcliAcctsPerSitePlusState.get(site)== null && AcliAcctsPerREALSite.get(realSite) <> null){

																		AcliAcctsPerSitePlusStateRETURN.put(site,AcliAcctsPerREALSite.get(realSite)); //AcliAcctsPerSitePlusState.get(site)
																		totalLines++;

										}


						}

						if(!found){
										for(string siteKey: AcliAcctsPerSitePlusState.keyset()){
																if(accountOnDbPerChiave.get(siteKey) == null && siteKey <> null) {
																		AcliAcctsPerSitePlusStateRETURN.put(siteKey,AcliAcctsPerSitePlusState.get(siteKey));
																		totalLines++;
																		}
										 }
						}
						returnValue = new  AcliWrapper(MAXLEVEL,totalLines,AcliAcctsPerSitePlusStateRETURN);

						return returnValue;
				}


}

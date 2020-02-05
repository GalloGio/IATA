global Class AMS_GovernorLimitsAnalyser{

	@InvocableMethod(label='Governor Limits Analyser' description='Describe the SOQL limits in a process execution.')
	public static void describeLimits(List<String> paramsToPrint){

		/*for(String param: paramsToPrint){

			System.debug(param);
		}*/

		//Returns the number of SOQL queries that have been issued.

		String alreadyIssuedSOQL = String.valueOf(Limits.getQueries());

		//Returns the total number of SOQL queries that can be issued.

		String remainingSOQL = String.valueOf(Limits.getLimitQueries() - Limits.getQueries());


		System.debug('::Analyser:: ('+paramsToPrint.get(0)+') Number of SOQL queries that have been issued:'+alreadyIssuedSOQL);
		System.debug('::Analyser:: ('+paramsToPrint.get(0)+') Number of SOQL queries that can still be issued:'+remainingSOQL);

	}


	}

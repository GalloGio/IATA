public with sharing class DevsTools {
	 /**
	 *
	 * return information about curernt environment
	 */
	 public static Boolean isRunningInSandbox() {
			String s  =  System.URL.getSalesforceBaseUrl().getHost();
			return (Pattern.matches('(.*\\.)?cs[0-9]*(-api)?\\..*force.com',s));
	}
}

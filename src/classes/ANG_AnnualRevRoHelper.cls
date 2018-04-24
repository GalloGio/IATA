public with sharing class ANG_AnnualRevRoHelper {
	public Account account {get; set;}
	public String bla {get; set;}

	public ANG_AnnualRevRoHelper(Account account) {
		System.debug('alex helper account : ' + account);

		String aid = '0017E00000WGYaS';
		bla = aid;

		this.account = account;
	}
}
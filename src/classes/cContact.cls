public with sharing class cContact {

		public cContact(){}

		public Contact con {get; set;}
		public boolean selected {get; set;}
		public boolean OpenCases { get; set; }
		public Integer totalCases {get; set;}
		public Integer nbrClosedCases {get; set;}
		public String hasClosedCases {get; private set;}
		public string CCG_Participant {get; private set;}

		//This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
		public cContact(Contact c) {
			con = c;
			this.CCG_Participant = 'false';
			if (c.account.CCG_Participant__c)
				this.CCG_Participant = 'true';
			selected = false;
			OpenCases = false;
		}

		public cContact(Contact c, Boolean pHasClosedCases) {
			con = c;
			this.CCG_Participant = 'false';
			if (c.account.CCG_Participant__c)
				this.CCG_Participant = 'true';
			selected = false;
			OpenCases = false;

			//nbrClosedCases = IFAP_BusinessRules.accountNbrClosedCase(c.AccountId, financialYear);
			hasClosedCases = (pHasClosedCases ? 'Yes' : 'No');
		}


}

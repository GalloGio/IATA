[

	{
		"master": "AMS_Agency__c",
		"slaves": [
			{
				"slave": "Account",
				"masterHasRefToSlave": "Y",
				"fieldToQuery": "Account__c",
				"fieldsToGet":
						[
							"Region__c",
							"Location_Type__c",
							"Assessment_Performed_Date__c",
							"Accreditation_date__c",
							"Expiry_Date__c",
							"Financial_Review_Result__c",
							"Financial_Year_End__c",
							"Active_Guarantees__c",
							"Guaranteed_amount__c",
							"Next_Financial_security_Expiry_date__c",
							"AIMS_ID__c",
							"Fin_statements_submission_deadline__c",
							"Is_Branch_Abroad__c"
						]
			}
		]
	},
	{
		"master": "AMS_Employee__c",
		"slaves": [
			{
				"slave": "Contact",
				"masterHasRefToSlave": "Y",
				"fieldToQuery": "Contact__c",
				"fieldsToGet":
					[
						"Agent_Type__c",
						"Financial_Assessment_Contact__c",
						"Salutation",
						"User_Portal_Status__c"
					]
			},
			{
				"slave": "AMS_person__c",
				"masterHasRefToSlave": "Y",
				"fieldToQuery": "Person__c",
				"fieldsToGet":
					[
						"First_Name__c",
						"Language_of_correspondence__c",
						"Lastname__c",
						"DOB__c",
						"Email__c",
						"Region__c",
						"Phone__c",
						"Sex__c"
					]
			}
		]
	}
]
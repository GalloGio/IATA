const sectionsAndFields = {
	sections: [
		{
			sectionName: 'Welcome',
			display: false,
			apiSectionName: 'new-applicant',
			fields:[
				{
					name: 'Company Legal Name',
					apiName: 'companyLegalName',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Country',
					apiName: 'country',
					disabled: false,
					visible: false,
					required: false
				}
			]
			
		},
		{
			sectionName: 'Agency Legal Status',
			display: false,
			apiSectionName: 'agency-legal-status',
			fields:[
				{
					name: 'Trading Name',
					apiName: 'tradingName',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Company Type',
					apiName: 'companyType',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'In Operations Since',
					apiName: 'inOperationsSince',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Tax Id / VAT Number 1',
					apiName: 'taxIdVATNumber1',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Tax Id / VAT Number 2',
					apiName: 'taxIdVATNumber2',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Business Registration / License Number',
					apiName: 'businessRegistration',
					disabled: false,
					visible: false,
					required: false
				}
			]
			
		},
		{
			sectionName: 'Ownership Details',
			display: false,
			apiSectionName: 'shareholder-details',
			fields:[
				{
					name: 'Person > Name',
					apiName: 'person-name',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Person > Percentage',
					apiName: 'person-percentage',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Person > Email',
					apiName: 'person-email',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Company > Name',
					apiName: 'company-name',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Company > Percentage',
					apiName: 'company-percentage',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Company > Email',
					apiName: 'company-email',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Publicly Traded > Name',
					apiName: 'publicly-traded-name',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Publicly Traded > Percentage',
					apiName: 'publicly-traded-percentage',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Publicly Traded > Email',
					apiName: 'publicly-traded-email',
					disabled: false,
					visible: false,
					required: false
				}
			]
			
		},
		{
			sectionName: 'Address',
			display: false,
			apiSectionName: 'address',
			fields:[
				{
					name: 'Country',
					apiName: 'country',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'State / Province',
					apiName: 'state',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Address',
					apiName: 'address',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'City',
					apiName: 'city',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Postal Code',
					apiName: 'postalCode',
					disabled: false,
					visible: false,
					required: false
				}
			]
		},
		{
			sectionName: 'Mailing',
			display: false,
			apiSectionName: 'mailing',
			fields:[
				{
					name: 'Country',
					apiName: 'country',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'State / Province',
					apiName: 'state',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Address',
					apiName: 'mailingAddress',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'City',
					apiName: 'city',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Postal Code',
					apiName: 'postalCode',
					disabled: false,
					visible: false,
					required: false
				}
			]
		},
		{
			sectionName: 'Contact',
			display: false,
			apiSectionName: 'contact',
			fields:[
				{
					name: 'Phone Number',
					apiName: 'phone',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Fax Number',
					apiName: 'fax',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Business Email Address',
					apiName: 'businessEmail',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Website',
					apiName: 'website',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Office Manager - First Name',
					apiName: 'omFirstName',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Office Manager - Last Name',
					apiName: 'omLastName',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Prefered Language of Correspondance',
					apiName: 'preferedLanguage',
					disabled: false,
					visible: false,
					required: false
				}
			]
		},
		{
			sectionName: 'Business Profile',
			display: false,
			apiSectionName: 'business-profile',
			fields:[
				{
					name: 'Number of Employees at the office applying for TIDS',
					apiName: 'numberEmployeesSelected',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Number of Offices your agency has in <country>',
					apiName: 'numberOfficesValue',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Which Global Distribution Systems (GDSs) do you primarily use? (Select up to 4)',
					apiName: 'GDS',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'What is the principal activity of your agency? (Select 1)',
					apiName: 'principalActivities',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Market Focus: Indicate the approximate % of your Leisure and Corporate business.',
					apiName: 'marketFocus',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'Online / Offline Sales Mix',
					apiName: 'salesMix',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'What is the approximate total annual meeting & event / and or Travel industry sales of your entity?',
					apiName: 'travelSales',
					disabled: false,
					visible: false,
					required: false
				}
			]
		},
		{
			sectionName: 'Business Specialization',
			display: false,
			apiSectionName: 'business-specialization',
			fields:[
				{
					name: 'What are the 3 Market Specialties of your entity?',
					apiName: 'marketSpecialties',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'What are the 3 Destination Specialties of your entity?',
					apiName: 'destinationSpecialties',
					disabled: false,
					visible: false,
					required: false
				},
				{
					name: 'What is the approximate % breakdown of your total annual sales for the following?',
					apiName: 'percentageBreakdown',
					disabled: false,
					visible: false,
					required: false
				}
			]
		},
		{
			sectionName: 'Supporting Documents',
			display: false,
			apiSectionName: 'supporting-documents',
			fields:[]
		},
		{
			sectionName: 'Submit Application',
			display: false,
			apiSectionName: 'submit-application',
			fields:[]
		},
		{
			sectionName: 'Application Decision',
			display: false,
			apiSectionName: 'application-decision',
			fields:[]
		}
	]
}

const getSectionsFields = () => {
	return sectionsAndFields;
}

const forms = [
	{
		label: 'New Application Head Office',
		value: 'new-applicant-ho'
	},
	{
		label: 'New Application Branch Office',
		value: 'new-applicant-br'
	},
	{
		label: 'New Application Virtual Branch',
		value: 'new-virtual-branch'
	},
	{
		label: 'Change of Name or Company Details Head Office',
		value: 'chg-name-company-ho'
	},
	{
		label: 'Change of Name or Company Details Branch Office',
		value: 'chg-name-company-br'
	},
	{
		label: 'Change of Address or Contact Details',
		value: 'chg-address-contact'
	},
	{
		label: 'Change of Business Profile or Specialization Head Office',
		value: 'chg-business-profile-specialization-ho'
	},
	{
		label: 'Change of Business Profile or Specialization Branch Office',
		value: 'chg-business-profile-specialization-br'
	}
];

const getForms = () => {
	return forms;
};

const createNewMenu = (props) => {
	let menu = {
		name: props.label,
		apiName: props.value,
		options: {
			client: sectionsAndFields.sections,
			vetting: sectionsAndFields.sections
		}
	}
	return menu;
}

const createSectionsAndFieldsModalValues = () => {
	let sectionsAndFieldsConfiguration = [];
	forms.forEach(form => {
		let menu = createNewMenu(form);
		sectionsAndFieldsConfiguration.push(menu);
	});
	return sectionsAndFieldsConfiguration;
}

export {
	getSectionsFields,
	getForms,
	createNewMenu,
	createSectionsAndFieldsModalValues
}
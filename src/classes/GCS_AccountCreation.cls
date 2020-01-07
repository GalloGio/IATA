public without sharing class GCS_AccountCreation{

    private static Map<String,GCS_CustomerType> customerTypesMap {
    	get{
    		if(customerTypesMap == null){
	    		customerTypesMap = GCS_CustomerType.getCustomerTypesMap();
    		}
    		return customerTypesMap;
    	}
    	private set;
    }

    @AuraEnabled
    public static Map<String,String> getAccountLabels() {
    	return GCS_RegistrationController.getAccountLabels();
    }

	@AuraEnabled
	public static GCS_Customer_Type_For_Registration__mdt getMetadataCustomerType(String customerTypeKey) {
		return customerTypesMap.get(customerTypeKey).metadataCustomerType;
	}

    @AuraEnabled
    public static OneId_RegistrationProcessController.StatesAndAlternateNames getStates(String country){
		return OneId_RegistrationProcessController.getStates(country);
    }

    @AuraEnabled
    public static List<OneId_AddressDoctor.AddressInfo> checkAddress(String info) {
        System.debug(loggingLevel.FINE, '____ [cls OneId_RegistrationProcessController - checkAddress] info - ' + info);
        return OneId_AddressDoctor.validate((OneId_AddressDoctor.AddressInfo)JSON.deserialize(info, OneId_AddressDoctor.AddressInfo.class));
    }

	@AuraEnabled
	public static List<CustomerTypePicklist> getCustomerTypePicklists(String root, String leaf){
		List<CustomerTypePicklist> picklists = new List<CustomerTypePicklist>();

		String selectedItem;

		Boolean keepLooping = true;

		String currentCustomerType = leaf;
		String previousCustomerType = null;

		while(keepLooping){
			GCS_CustomerType customerType = customerTypesMap.get(currentCustomerType);

			if(!customerType.children.isEmpty()){
				CustomerTypePicklist picklist = new CustomerTypePicklist(customerType.subCategorizationLabel);

				picklist.picklistOptions.add(new CustomerTypePicklistOption(customerType.metadataCustomerType.DeveloperName, customerType.subCategorizationPlaceholder, previousCustomerType == null));

				for(GCS_CustomerType child : customerType.children){
					picklist.picklistOptions.add(new CustomerTypePicklistOption(child.metadataCustomerType.DeveloperName, child.label, child.metadataCustomerType.DeveloperName == previousCustomerType));
				}

				picklists.add(picklist);
			}

			if(customerType.parent != null && currentCustomerType != root){
				previousCustomerType = currentCustomerType;
				currentCustomerType = customerType.parent.metadataCustomerType.DeveloperName;
			}
			else{
				keepLooping = false;
			}
		}

		List<CustomerTypePicklist> orderedPicklists = new List<CustomerTypePicklist>();

		for(Integer i = picklists.size()- 1 ; i >= 0; i--){
			orderedPicklists.add(picklists[i]);
		}

		return orderedPicklists;
	}

	public class CustomerTypePicklist{
		@AuraEnabled
		public String picklistLabel { get; private set; }
		
		@AuraEnabled
		public List<CustomerTypePicklistOption> picklistOptions { get; private set; }
		
		public CustomerTypePicklist(String picklistLabel){
			this.picklistLabel = picklistLabel;
			picklistOptions = new List<CustomerTypePicklistOption>();
		}
	}

	public class CustomerTypePicklistOption{
		@AuraEnabled
		public String key { get; private set; }
		
		@AuraEnabled
		public String label { get; private set; }
		
		@AuraEnabled
		public Boolean isSelected { get; private set; }
		
		public CustomerTypePicklistOption(String key, String label, Boolean isSelected){
			this.key = key;
			this.label = label;
			this.isSelected = isSelected;
		}
	}
}
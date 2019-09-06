({
    getCustomerTypes : function(component){
		var action = component.get("c.getCustomerTypesList");
        action.setCallback(this, function(resp) {
            let customerTypes = resp.getReturnValue();
            //console.log(JSON.stringify(customerTypes));
            component.set("v.customerTypes",customerTypes);
        });
        $A.enqueueAction(action);
    },
    
    handleCustomerType : function(c,type,level){
        //console.log('handleCustomerType '+JSON.stringify(type));
        let level1 = c.get("v.customerType1");

        if(type == null){
            //Reset type
            c.set("v.requireCountry",false);
            c.set("v.customerType",null);
            c.set("v.showSearch",false);
            c.set("v.showCreate",false);
            c.set("v.account",{});
            c.set("v.accountSelected", false);
        }else{
            let metadata = type.metadataCustomerType;

            c.set("v.customerType",metadata);

            //COUNTRY
            c.set("v.requireCountry",metadata.Display_Country__c);

            //COUNTRY TITLE
            c.set("v.generalPublicCountryHeader",metadata.Parent__c == 'General_Public_Sector');
            
            //SHOW SEARCH
            if(metadata.Search_Option__c == 'User Search'){
                c.set("v.showSearch",true);
            }

            //SHOW CREATE NEW ACCOUNT
            c.set("v.showCreateNew",metadata.Can_Account_Be_Created__c);
        }
    }
})
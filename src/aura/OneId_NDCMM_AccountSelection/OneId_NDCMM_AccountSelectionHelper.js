({
    isMandatoryFieldsOK: function(component) {
        /*	  var isAllFilled = true;
	  var typeOfCustomerCmp = component.find("typeOfCustomer");
	  if($A.util.isEmpty(typeOfCustomerCmp.get("v.value"))) {
			  typeOfCustomerCmp.set("v.errors", [{message:"Please select a type of user"}]);
		   isAllFilled = false;
	  } else {
			  typeOfCustomerCmp.set("v.errors", null);
	  }*/
        return true;
    },    

	setSector : function (c) {
        var sector = c.get("v.sector");
		c.set("v.category", '');

        if(sector == 'Airline'){
            var categories = ['Passenger only','Passenger and Cargo'];
            c.set("v.categories", categories);
		}
		else if(sector == 'Travel Agent'){
            var categories = ['IATA Passenger Sales Agent','Non-IATA Travel Agent'];
            c.set("v.categories", categories);
		}
		else if(sector == 'Airline Supplier'){
            // Setting a default non-empty value, the categories picklist won't be displayed
            // This value will be used if the user creates a new account
            c.set("v.category", 'Content Aggregator');
		}
        else{
            var categories = [];
            c.set("v.categories", categories);
            c.set("v.category", "");
        }

        var category = c.get("v.category");
        c.set('v.account.Sector__c', sector);
        c.set('v.account.Category__c', category);    
    },
    
	setCategory : function (c) {
        var category = c.get("v.category");
        c.set('v.account.Category__c', category);    
    },
    
    checkIfAccountSet: function(cmp){
        if(cmp.get("v.account").Id != undefined){
            cmp.set("v.accountSelected", true);
        }
    }
})
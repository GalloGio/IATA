({
	contactLabels: function(component) {
        var action = component.get("c.getContactLabels");
        action.setCallback(this, function(a) {
            component.set("v.contactLabels", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    jobFunctionOptions: function(component) {
        var action = component.get("c.getContactJobFunctionValues");
        action.setCallback(this, function(a) {
            component.set("v.jobFunctionOptions", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    placePhoneFlags : function(country){
        $('.phoneFormat').intlTelInput({
            initialCountry: country,                    
            preferredCountries: [country],
            placeholderNumberType : 'FIXED_LINE'
        });

        $(".mobileFormat").intlTelInput({
            initialCountry: country,                    
            preferredCountries: [country],
            placeholderNumberType : 'MOBILE'
        });
    },

    checkRequiredFields :function(component) {
        var isAllFilled = true;

        var salutation = component.find("salutation");
        if($A.util.isEmpty(salutation.get("v.value"))) {
            salutation.set("v.errors", [{message: $A.get("$Label.c.ISSP_Registration_Error_Salutation")}]);
            isAllFilled = false;
        } else {
            salutation.set("v.errors", null);
        } 

        var firstName = component.find("firstName");
        if($A.util.isEmpty(firstName.get("v.value"))) {
            firstName.set("v.errors", [{message: $A.get("$Label.c.ISSP_Registration_Error_FirstName")}]);
            isAllFilled = false;
        } else {
            firstName.set("v.errors", null);
        } 

        var lastName = component.find("lastName");
        if($A.util.isEmpty(lastName.get("v.value"))) {
            lastName.set("v.errors", [{message: $A.get("$Label.c.ISSP_Registration_Error_LastName")}]);
            isAllFilled = false;
        } else {
            lastName.set("v.errors", null);
        }

        var title = component.find("title");
        if($A.util.isEmpty(title.get("v.value"))) {
            title.set("v.errors", [{message: $A.get("$Label.c.ISSP_Registration_Error_JobTitle")}]);
            isAllFilled = false;
        } else {
            title.set("v.errors", null);
        }

        var job = component.find("membershipFunction");
        if($A.util.isEmpty(job.get("v.value"))) {
            job.set("v.errors", [{message: $A.get("$Label.c.ISSP_Registration_Error_JobFunction")}]);
            isAllFilled = false;
            $A.util.addClass(component.find("jobHelp"), "jobHelp");
        } else {
            job.set("v.errors", null);
            $A.util.removeClass(component.find("jobHelp"), "jobHelp");
        }
        
        var serviceName = component.get("v.serviceName");
        
        if(serviceName == "FRED"){
            var phone = component.find("contactMobilePhone");
            var container = component.find("mobilePhoneContainer");
            if($A.util.isEmpty(phone.get("v.value"))) {
                var domPhone = phone.getElement();
                var country = $(domPhone).intlTelInput("getSelectedCountryData").iso2;
    
                phone.set("v.errors", [{message:$A.get("$Label.c.ISSP_Registration_Error_MobilePhone")}]);
                if(!$A.util.hasClass(container, 'slds-has-error')) $A.util.addClass(container, 'slds-has-error');
                isAllFilled = false;
    
                setTimeout(function(){
                    $(domPhone).intlTelInput("setCountry", "");
                    $(domPhone).intlTelInput("setCountry", country);
                }, 100);
            } else {
                $A.util.removeClass(container, 'slds-has-error');
                component.set("v.phoneErrors", '');
            }
        }
        else{
            var phone = component.find("contactPhone");
            var container = component.find("phoneContainer");
            if($A.util.isEmpty(phone.get("v.value"))) {
                var domPhone = phone.getElement();
                var country = $(domPhone).intlTelInput("getSelectedCountryData").iso2;
    
                phone.set("v.errors", [{message:$A.get("$Label.c.ISSP_Registration_Error_BusinessPhone")}]);
                if(!$A.util.hasClass(container, 'slds-has-error')) $A.util.addClass(container, 'slds-has-error');
                isAllFilled = false;
    
                setTimeout(function(){
                    $(domPhone).intlTelInput("setCountry", "");
                    $(domPhone).intlTelInput("setCountry", country);
                }, 100);
            } else {
                $A.util.removeClass(container, 'slds-has-error');
                component.set("v.phoneErrors", '');
            }
        }

        return isAllFilled;
    }
})
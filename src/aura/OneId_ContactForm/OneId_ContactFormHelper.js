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
        var firstName = component.find("firstName");
        var lastName = component.find("lastName");
        var title = component.find("title");
        var job = component.find("membershipFunction");
        var phone = component.find("contactPhone");
        var container = component.find("phoneContainer");

        var isAllFilled = true;
        if($A.util.isEmpty(firstName.get("v.value"))) {
            firstName.set("v.errors", [{message:$A.get("$Label.c.ISSP_Registration_Error_FirstName")}]);
            isAllFilled = false;
        } else {
            firstName.set("v.errors", null);
        } 

        if($A.util.isEmpty(lastName.get("v.value"))) {
            lastName.set("v.errors", [{message:$A.get("$Label.c.ISSP_Registration_Error_LastName")}]);
            isAllFilled = false;
        } else {
            lastName.set("v.errors", null);
        }

        if($A.util.isEmpty(title.get("v.value"))) {
            title.set("v.errors", [{message:$A.get("$Label.c.ISSP_Registration_Error_JobTitle")}]);
            isAllFilled = false;
        } else {
            title.set("v.errors", null);
        }

        if($A.util.isEmpty(job.get("v.value"))) {
            job.set("v.errors", [{message:$A.get("$Label.c.ISSP_Registration_Error_JobFunction")}]);
            isAllFilled = false;
            $A.util.addClass(component.find("jobHelp"), "jobHelp");
        } else {
            job.set("v.errors", null);
            $A.util.removeClass(component.find("jobHelp"), "jobHelp");
        }
        if($A.util.isEmpty(phone.get("v.value"))) {
            var domPhone = phone.getElement();
            var country = $(domPhone).intlTelInput("getSelectedCountryData").iso2;

            component.set("v.phoneErrors", $A.get("$Label.c.ISSP_Registration_BusinessPhone_Msg"));
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

        return isAllFilled;
    }
})
({
    getSalutationOptions: function(component) {
        var salutations = []; // '', 'Mr.', 'Mrs.', 'Ms'
        var action = component.get("c.GetContactSalutationValues");
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            for (var i = 0; i < results.length; i++) {
                salutations.push(results[i]);
            }
            component.set("v.salutationOptions", salutations);
        });
        $A.enqueueAction(action);

    },
    getJobFunctionOptions: function(component) {
        var values = [];
        var action = component.get("c.GetContactJobFunctionValues");
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            for (var i = 0; i < results.length; i++) {
                values.push(results[i]);
            }
            component.set("v.jobFunctionOptions", values);

        });
        $A.enqueueAction(action);

    },
    getSectorOptions: function(component, acctype) {
        console.log("get Sector options");
        var values = [];

        //console.log("Account type: " +acctype);
        var allvalues = component.get("v.rtcategorysector");
        //console.log("allvalues: " +allvalues);
        var prevvalue = '';
        values.push("");
        for (var i = 0; i < allvalues.length; i++) {
            console.log("Row: " + allvalues[i]);
            var val = allvalues[i].split("%%%");
            console.log("val[0]: " + val[0]);
            console.log("val[1]: " + val[1]);
            console.log("val[2]: " + val[2]);
            console.log("accounttype: " + acctype);
            console.log("prevvalue: " + prevvalue);

            if (val[0] == acctype && val[1] != prevvalue) {
                console.log("Add");
                if (acctype == 'Agency') {
                    var cargotravel = component.find("CargoTravel").get("v.value");
                    if (cargotravel == 'Cargo' && val[1] == 'Travel Agent')
                        continue;
                    else if (cargotravel == 'Travel' && val[1] == 'Cargo Agent')
                        continue;
                }
                values.push(val[1]);
                prevvalue = val[1];
            }
        }
        component.set("v.sectorOptions", values);
        console.log("values: " + values);

    },

    //Second Picklist
    FillCategory: function(component, accounttype) {
        console.log("Get cat options");

        var values = [];
        var sectorField = component.find("Sector");
        var sector = sectorField.get("v.value");
        //console.log("Sector: " +sector);
        var allvalues = component.get("v.rtcategorysector");
        values.push("");
        for (var i = 0; i < allvalues.length; i++) {
            var val = allvalues[i].split("%%%");
            console.log("val[0]: " + val[0]);
            console.log("val[1]: " + val[1]);
            console.log("val[2]: " + val[2]);
            console.log("accounttype: " + accounttype);
            console.log("sector: " + sector);
            if (val[0] == accounttype && val[1] && val[1] == sector) {
                console.log("Value found");
                values.push(val[2]);
            }
        }

        component.set("v.categoryOptions", values);



    },

    /*
    //Retrieve all combinations: record type/sector/category
    getallCategorySectorOptions : function(component) {
        var values =  [];
        var action = component.get("c.GetAccountCategoryValues");
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            //alert(results);
            //alert(JSON.stringify(results));
            for(var i = 0; i < results.length; i++) {
                //console.log("res: " +results[i]);
                //console.log("Values RT: " +JSON.stringify(results[i]));
                values.push(results[i]);
            }
            
            component.set("v.rtcategorysector", values);
            //console.log("Values: " +values);
            
        });
        
        $A.enqueueAction(action);
        
    },*/
    getContactLabels: function(component) {
        var labels = [];
        var action = component.get("c.GetContactLabels");
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            component.set("v.contactLabels", results);
        });
        $A.enqueueAction(action);
    },
    getAccountLabels: function(component) {
        var labels = [];
        var action = component.get("c.GetAccountLabels");
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            component.set("v.accountLabels", results);
        });
        $A.enqueueAction(action);

    },
    getCountryOptions: function(component) {
        var action = component.get("c.GetFieldPicklistValuesCountry");
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            component.set("v.countryOptions", results);
        });
        $A.enqueueAction(action);
    },

    validateEmail: function(component) {
        this.showSpinner(component);
        var errors = false;
        //Used also to validate terms and conditions
        // var terms = component.get("v.Terms");
        var emailOK = component.get("v.emailOK");
        // console.log("Terms: " +terms);
        // if (!(terms)) {
        //     console.log("False");
        //     var termsField = component.find("termsaccepted");
        //     console.log(termsField);
        //     termsField.set("v.errors", [{message: $A.get("$Label.c.ISSP_accept_General_Conditions") }]);
        //
        //     errors = true;
        //     	//return;
        // }
        // console.log("terms: " +terms);
        this.validateTerms(component);
        console.log(JSON.stringify(component.get("v.contact")));

        var emailField = component.find("email");
        var email = emailField.get("v.value");
        if (email === undefined || email === "") {
            emailField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_EmailError") }]);
            errors = true;
            component.set("v.Terms", false);
            this.hideSpinner(component);
            return errors;
        }
        //if (!(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email)))  {
            if (!(/^[a-zA-Z0-9.!#$%&*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/.test(email))) {
                emailField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_EmailError") }]);
                errors = true;
                component.set("v.Terms", false);
                this.hideSpinner(component);
                return errors;
            }
            console.log('email: ' + email);
        //Check if user email is already existing
        var checkemail = component.get("c.checkemail");
        checkemail.setParams({ email: email });

        checkemail.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: ' + state);
            if (state === "SUCCESS") {
                console.log('return value: ' + response.getReturnValue());
                // Create new contact and user from that contact
                if (response.getReturnValue() == 'create_contactanduser') {
                    var captchaOK = component.get("v.captchaOK");
                    emailOK = true;
                    if (captchaOK) {
                        component.set("v.emailOK", emailOK);
                        component.set("v.emailLocked", true);
                        console.log('SUCCESS');

                        component.set("v.Page", 2);
                        var page2 = component.find('page-2');
                        $A.util.removeClass(page2, 'page-invisible');
                    } else {
                        this.hideSpinner(component);
                        component.set("v.Terms", false);
                    }

                    // Inform the user if email is already in use 
                } else if (response.getReturnValue() == 'user_exists') {

                    component.set("v.Terms", false);
                    component.set("v.Page", 1);
                    emailField.set("v.errors", [{ message: $A.get("$Label.c.OneId_Registration_UserExist")}]);
                    var page2 = component.find('page-2');
                    $A.util.addClass(page2, 'page-invisible');
                    // alert ("User email already existing in the system");
                    errors = true;

                    // If a contact with the same email exists but it has no related user, create a user from that contact
                } else if (response.getReturnValue() == 'create_user') {
                    var captchaOK = component.get("v.captchaOK");
                    emailOK = true;
                    if (captchaOK) {
                        component.set("v.emailOK", emailOK);
                        component.set("v.emailLocked", true);
                        console.log('Start Create User From Existing Contact');

                        component.helper.createUserFromExistingContact(component, email);
                    } else {
                        this.hideSpinner(component);
                        component.set("v.Terms", false);
                    }
                }

            } else if (state === "ERROR") {
                this.hideSpinner(component);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            console.log('end checkmail');
            this.hideSpinner(component);
        });
        //Comment to block validations
        if (!errors) {
            // if(!emailOK) this.showSpinner(component);
            console.log('no errors');
            $A.enqueueAction(checkemail);
            this.hideSpinner(component);

        }
        return errors;
    },
    createUserFromExistingContact: function(component, email) {
        console.log("Enter Create Existing Contact");

        var createUser = component.get("c.createUserFromExistingContact");
        createUser.setParams({ email: email });
        createUser.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state createuserfromexistingcontact " + state);
            if (state === "SUCCESS") {
                var emailField = component.find("email");
                console.log('User Created: ' + response.getReturnValue());
                //console.log(1);
                component.set("v.Terms", false);
                //console.log(2);
                component.set("v.Page", 1);
                //console.log(3);
                emailField.set("v.errors", [{ message: $A.get("$Label.c.OneId_User_CreatedFromContact")}]);
                //console.log(4);
                var page2 = component.find('page-2');
                //console.log(5);
                $A.util.addClass(page2, 'page-invisible');
                //console.log(6);
                this.hideSpinner(component);
                //console.log(7);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(createUser);
    },
    validateTerms: function(component) {
        var errors = false;
        var termsField = component.find("termsaccepted");
        console.log('tf: ' + termsField);
        var terms = component.get("v.Terms");
        console.log('terms ' + terms);
        if (terms === false) {
            console.log('errors false');
            termsField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_accept_General_Conditions") }]);
            errors = true;
        }
        console.log('errors');
        return errors;

    },
    placeFlags: function(component) {
        //var contactPhone = component.find("contactPhone");
        var contactPhone = $('.contactPhone');
        console.log("contactPhone: " + contactPhone);

        if (contactPhone != null) {
            console.log('contact phone not null');
            contactPhone.intlTelInput({
                autoPlaceholder: true
                    //defaultCountry: 'PT',
                    //snationalMode: true
                    /*preferredCountries: [""],
                    numberType: "FIXED_LINE"*/
                });
        }
    },
    validateContact: function(component) {
        console.log(JSON.stringify(component.get("v.contact")));
        // var checkboxes = component.find("functionBox");
        // var functionString = '';
        // for(var i = 0; i< checkboxes.length; i++) {
        // 	if(checkboxes[i].get("v.value") === true) {
        // 		functionString += checkboxes[i].get("v.label") + ';';
        // 	}
        //
        // }
        // if(functionString[functionString.length-1] === ';') functionString = functionString.substring(0,functionString.length-1);
        var contact = component.get("v.contact");
        console.log("contact: " + contact);
        // contact.Membership_Function__c = functionString;
        // contact.Salutation = component.find("v.Salutation").get("v.value");
        // console.log(component.find("ms").get("v.value"));
        var errors = false;
        var salutation = component.find("Salutation").get("v.value");
        contact.Salutation = salutation;

        console.log("Debug1");
        var firstNameField = component.find("firstName");
        var firstName = firstNameField.get("v.value");

        var lastNameField = component.find("lastName");
        var lastName = lastNameField.get("v.value");

        var titleField = component.find("title");
        var title = titleField.get("v.value");
        console.log("Debug2");

        var membershipFunctionField = component.find("membershipFunction");
        var membershipFunction = membershipFunctionField.get("v.value");
        console.log("membershipFunction " + membershipFunction);

        var businessphoneField = component.find("contactPhone");
        var businessphone = businessphoneField.get("v.value");
        var mobilephone = component.get("v.MobilePhone");
        var businessfax = component.get("v.BusinessFax");
        console.log("Debug3");
        // console.log($A.get("$Label.c.ISSP_Registration_Error_FirstName"));

        if (firstName === undefined) {
            firstNameField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Registration_Error_FirstName") }]);
            errors = true;
        } else { contact.FirstName = firstName; }
        if (lastName === undefined) {
            lastNameField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Registration_Error_LastName") }]);
            errors = true;
        } else { contact.LastName = lastName; }
        if (title === undefined) {
            titleField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Registration_Error_JobTitle") }]);
            errors = true;
        } else { contact.Title = title; }
        if (membershipFunction === undefined || membershipFunction === '') {
            console.log("membershipFunction >" + membershipFunction);
            membershipFunctionField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Registration_Error_JobFunction") }]);
            errors = true;
        } else { contact.Membership_Function__c = membershipFunction; }
        if (businessphone === undefined) {
            console.log('bp');
            businessphoneField.set("v.errors", [{ message: $A.get("$Label.c.OneId_Registration_Error_BusinessPhone") }]);
            errors = true;
        } else { contact.Phone = businessphone; }
        // console.log('c: ' + firstName + ' ' + lastName + ' ' + title + ' ' + businessphone + ' ' + salutation);

        // else {
        //   		var phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
        //     //alert(businessphone);
        //     //if(!(businessphone.match(phoneno))) {
        //     	//alert ("Please insert a valid business phone number");
        //    	//	return;
        //     //}
        //
        // }
        console.log('mf ' + JSON.stringify(contact));
        console.log('errors: ' + errors);
        return errors;

    },
    validateAccount: function(component) {
        console.log("4");
        var errors = false;

        var legalNameField = component.find("legalName");
        var legalName = legalNameField.get("v.value");

        var sectorField = component.find("Sector");
        var sector = sectorField.get("v.value");
        console.log("sectorField: " + sectorField);
        console.log("sector: " + sector);

        console.log("4b");

        var categoryField = component.find("Category");
        console.log("Category field: " + categoryField);
        var category;
        if (categoryField == 'undefined')
            category = '';
        else
            category = categoryField.get("v.value");
        console.log("Category: " + category);

        console.log("4c");

        var tradeNameField = component.find("tradeName");
        var tradeName = tradeNameField.get("v.value");

        var billingStreetField = component.find("billingStreet");
        var billingStreet = billingStreetField.get("v.value");

        var billingCityField = component.find("billingCity");
        var billingCity = billingCityField.get("v.value");

        var billingPostalCodeField = component.find("billingPostalCode");
        var billingPostalCode = billingPostalCodeField.get("v.value");

        var billingStateField = component.find("billingState");
        var billingState = billingStateField.get("v.value");

        var shippingStreetField = component.find("shippingStreet");
        var shippingStreet = shippingStreetField.get("v.value");

        var shippingCityField = component.find("shippingCity");
        var shippingCity = shippingCityField.get("v.value");

        var shippingPostalCodeField = component.find("shippingPostalCode");
        var shippingPostalCode = shippingPostalCodeField.get("v.value");

        var officePhoneField = component.find("officePhone");
        var officePhone = officePhoneField.get("v.value");

        var designatorcode = component.get("v.DesCode");
        if (designatorcode == 'undefined') {
            designatorcode = '';
        }
        console.log("5");
        var iatacode = component.get("v.IataCode");
        //alert(iatacode);
        if (iatacode == 'undefined') {
            iatacode = '';
        }

        console.log("6");

        if (legalName === undefined) {
            legalNameField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        if (sector === undefined) {
            sectorField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        if (category === undefined) {
            categoryField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        console.log("Category: " + category);
        if (category == 'Other') {
            console.log("Other category");
            var categoryotherField = component.find("categoryothervalue");
            var categoryother = categoryotherField.get("v.value");

            console.log("Other category field: " + categoryother);
            if (categoryother == undefined || categoryother == '') {
                categoryotherField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
                errors = true;
            }

        }
        if (billingStreet === undefined) {
            billingStreetField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        if (billingCity === undefined) {
            billingCityField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        console.log("Billing state: " + billingState);
        console.log("billingStateField: " + billingStateField);
        if (billingState === undefined) {
            billingStateField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        if (billingPostalCode === undefined) {
            billingPostalCodeField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        if (officePhone === undefined) {
            officePhoneField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_Address_validation") }]);
            errors = true;
        }
        /*
        if(shippingStreet === undefined) {
			shippingStreetField.set("v.errors", [{message: $A.get("$Label.c.ISSP_Address_validation") }]);
			errors = true;
		}
		if(shippingCity === undefined) {
			shippingCityField.set("v.errors", [{message: $A.get("$Label.c.ISSP_Address_validation") }]);
			errors = true;
		}
		if(shippingPostalCode === undefined) {
			shippingPostalCodeField.set("v.errors", [{message: $A.get("$Label.c.ISSP_Address_validation") }]);
			errors = true;
		}
        */
        //Assign sector and category
        var account = component.get("v.account");
        account.Sector__c = sector;
        account.Category__c = category;
        console.log("7");
        if (iatacode !== '') account.IATACode__c = iatacode;
        if (designatorcode !== '') account.Airline_designator__c = designatorcode;
        console.log("8");


        console.log(JSON.stringify(component.get("v.account")));
        // else {
        //   		var phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
        //     //alert(businessphone);
        //     //if(!(businessphone.match(phoneno))) {
        //     	//alert ("Please insert a valid business phone number");
        //    	//	return;
        //     //}
        //
        // }

        return errors;

    },
    /*showSpinner : function (component, event) {
        console.log('ss');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();
    },
    
    hideSpinner : function (component, event) {
        console.log('hideSpinner');
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();
    },*/
    showSpinner: function(component) {
        var div = component.find("spinner");
        $A.util.removeClass(div, 'slds-hide');
        $A.util.addClass(div, 'slds-show');
    },
    hideSpinner: function(component) {
        var div = component.find("spinner");
        $A.util.removeClass(div, 'slds-show');
        $A.util.addClass(div, 'slds-hide');
    },
    show: function(component, id) {
        var div = component.find(id);
        $A.util.removeClass(div, 'slds-hide');
        $A.util.addClass(div, 'slds-show');
    },
    hide: function(component, id) {
        var div = component.find(id);
        $A.util.removeClass(div, 'slds-show');
        $A.util.addClass(div, 'slds-hide');
    },
    getHostURL: function(component, event) {
        var vfOrigin = component.get("c.getHostURL");
        vfOrigin.setCallback(this, function(response) {
            console.log('response ' + response.getReturnValue());
            component.set("v.vfHost", 'https://' + response.getReturnValue());
        });
        $A.enqueueAction(vfOrigin);

    },
    /*getHostURL: function (component, event) {
        var hostURL = component.get("c.setHostURL");
        component.set("v.vfHost", hostURL);
    }*/
    getUrlParameterByName: function(name, url) {
        if (!url) {
            url = window.location.href;
        }
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

    setLanguage: function(component, event) {
        var lang = this.getUrlParameterByName('language');
        component.set("v.language", lang);

    },
    getCommunityName: function(component, event) {
        var commName = component.get("c.getCommunityName");
        commName.setCallback(this, function(response) {
            console.log('getCommunityName response ' + response.getReturnValue());
            component.set("v.commName", response.getReturnValue());
        });
        $A.enqueueAction(commName);

    },
})
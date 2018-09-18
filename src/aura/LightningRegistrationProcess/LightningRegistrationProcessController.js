({


    //Invoked when Next is clicked
    changepage: function(component, event, helper) {

        var pagenumber = component.get("v.Page");

        if (pagenumber == 1) {
            var email = component.get("v.contact").email;

            helper.validateEmail(component);

        }

        if (pagenumber == 2) {
            var errors = helper.validateContact(component);
            //Comment to block validations
            if (!errors) {
                component.set("v.Page", 3);
                component.set("v.ShowSave", false);
            }

        }

    },

    handleError: function(component, event) {
        alert("error");
        var errorsArr = event.getParam("errors");
        for (var i = 0; i < errorsArr.length; i++) {
            console.log("error " + i + ": " + JSON.stringify(errorsArr[i]));
        }
    },

    emailChanged: function(component, event, helper) {
        component.set("v.ShowPage2", false);
        component.set("v.Terms", false);
        console.log('false');
    },

    // Invoked when user changes the account type on page 3
    changeAccountType: function(component, event, helper) {
        var companyType = component.find("AccountType").get("v.value");
        var acctype = component.find("AccountType").get("v.value");

        //Copy to a temp variable otherwise in some part of the codes (page 4) the picklist is not accessible (probably a bug)
        component.set("v.AccountT", acctype);
        console.log("value copied: " + component.get("v.AccountT"));

        // var account = component.get("v.account");
        // account.Type = companyType;
        // component.set("v.account", account);
        // },
        // ChangeType: function(component,event,helper) {
        component.set("v.isAirline1", false);
        component.set("v.isAirline2", false);
        component.set("v.showCompanyName", false);
        component.set("v.showCountry", false);
        component.set("v.isCargoTravel1", false);
        component.set("v.isCargoTravel2", false);
        component.set("v.ShowSearch", false);
        component.set("v.NoAccounts", "");
        component.set("v.ShowCreateAccount", false);
        component.set("v.isIataCodeCT", false);
        component.set("v.ShowSave", false);
        component.set("v.ShowResults", false);
        component.set("v.NoAccounts", "");
        component.set("v.IataC1", "");
        component.set("v.IataCode", "");
        //alert (acctype);

        component.set("v.showCountry", false);
        // component.set("v.showCompanyName", false);
        if (acctype == "Airline") {
            component.set("v.isAirline1", true);
            component.set("v.isAirline2", false);
            component.set("v.showCompanyName", false);
        } else if (acctype == "GSA") {
            component.set("v.isAirline1", false);
            component.set("v.isAirline2", false);
            component.set("v.showCountry", true);
            component.set("v.showCompanyName", true);
            component.set("v.ShowSearch", true);
            component.set("v.ShowSave", false);
        } else if (acctype == "Agency") {
            component.set("v.isAirline1", false);
            component.set("v.isAirline2", false);
            component.set("v.showCompanyName", false);
            component.set("v.isIataCodeCT", false);
            component.set("v.isCargoTravel1", true);
            component.set("v.showCountry", false);
        } else if (acctype == "Other Company") {
            component.set("v.isIataCodeCT", false);
            component.set("v.ShowSave", false);
            component.set("v.ShowSearch", true);
            component.set("v.showCountry", true);
            component.set("v.showCompanyName", true);
        } else if (acctype == "General Public") {
            component.set("v.ShowSave", false);
            component.set("v.showCountry", true);
            component.set("v.ShowSearch", true);
            component.set("v.showCompanyName", false);
        }



    },

    // Invoked when user has selected 'Airline' and then specifies if he has an Iata code or not
    IataCodeYesNo: function(component, event, helper) {
        component.set("v.ShowCreateAccount", false);
        component.set("v.NoAccounts", "");
        component.set("v.ShowResults", false);
        component.set("v.IataCode", "");
        var iatac = component.find("IataC1").get("v.value");

        //Iata code for agency
        if (iatac == "Yes") {
            component.set("v.isAirline2", true);
            component.set("v.showCountry", true);
            component.set("v.ShowSave", false);
            component.set("v.ShowSearch", true);
            component.set("v.showCompanyName", false);
        } else if (iatac == "No") {
            component.set("v.isAirline2", false);
            component.set("v.showCountry", true);
            component.set("v.showCompanyName", true);
            component.set("v.ShowSearch", true);
            component.set("v.ShowSave", false);
        } else {
            component.set("v.isAirline2", false);
            component.set("v.showCountry", false);
            component.set("v.showCompanyName", false);
            component.set("v.ShowSearch", false);
            component.set("v.ShowSave", false);
            component.set("v.ShowCreateAccount", false);
        }

    },

    // Invoked when user has selected 'Agency' and then specifies if it is a Cargo or an Agency
    CargoTravel: function(component, event, helper) {
        component.set("v.ShowCreateAccount", false);
        component.set("v.NoAccounts", "");
        component.set("v.ShowResults", false);
        var cargotravel = component.find("CargoTravel").get("v.value");
        if (cargotravel == "Cargo" || cargotravel == "Travel") {
            component.set("v.isCargoTravel2", true);
            component.set("v.showCountry", false);

        } else {
            component.set("v.isCargoTravel2", false);
            component.set("v.showCountry", false);
            component.set("v.ShowSearch", false);
        }
        component.set("v.showCompanyName", false);
        component.find("IataCodeCT").set("v.value", "");

    },

    // Invoked when user has selected 'Agency' and then, after selecting Cargo or Agency, specified if he has an Iata code or not
    IataCodeCargoTravel: function(component, event, helper) {
        component.set("v.ShowCreateAccount", false);
        component.set("v.NoAccounts", "");
        component.set("v.ShowResults", false);

        var cargotravel = component.find("IataCodeCT").get("v.value");

        //Cargo/Travel: do you have an IATA code
        if (cargotravel == "Yes") {
            component.set("v.isIataCodeCT", true);
            component.set("v.showCountry", false);
            component.set("v.showCompanyName", false);
            component.set("v.ShowSearch", true);

        } else if (cargotravel == "No") {
            component.set("v.isIataCodeCT", false);
            component.set("v.showCountry", true);
            component.set("v.showCompanyName", true);
            component.set("v.ShowSearch", true);
            component.set("v.ShowSave", false);
        }
        //Value set to blank
        else {
            component.set("v.showCountry", false);
            component.set("v.showCompanyName", false);
            component.set("v.ShowSearch", false);
            component.set("v.ShowSave", false);
            component.set("v.isIataCodeCT", false);
        }

    },
    //Invoked when users change the sector value
    getCategoryOptions: function(component, event, helper) {
        console.log("Get category");
        var accounttype = component.get("v.AccountT");
        console.log("Account type: " + accounttype);
        helper.FillCategory(component, accounttype);

    },

    //Invoked at component initialization
    initialize: function(component, event, helper) {
        component.set("v.ShowSave", true);
        helper.getSalutationOptions(component);
        helper.getJobFunctionOptions(component);
        helper.getContactLabels(component);
        helper.getAccountLabels(component);
        helper.getCountryOptions(component);
        //helper.getallCategorySectorOptions(component);
        helper.hideSpinner(component, event);
        helper.setLanguage(component, event);


    },

    showSpinner: function(component, event, helper) {
        helper.showSpinner(component, event);
    },

    hideSpinner: function(component, event, helper) {
        helper.hideSpinner(component, event);
    },
    // Invoked when user has defined all the filters and searches for an account
    searchAccount: function(component, event, helper) {

        var accounttype = component.get("v.AccountT");
        helper.getSectorOptions(component, accounttype);


        //Check if mandatory fields are filled in
        var errors = false;

        var name = '';
        if (component.get("v.showCompanyName") == true) {
            var nameField = component.find("accountName");
            if (nameField.get("v.value") === undefined || nameField.get("v.value").len < 3) {
                nameField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_CompanyName") + ' ' + $A.get("$Label.c.ISSP_Company_Name_Search_Format") }]);
                errors = true;
            } else {
                name = nameField.get("v.value");
                nameField.set("v.errors", "");
            }

        }
        var showCountry = component.get("v.showCountry");
        var countryField = component.find("countryName");
        var country = '';
        //alert ("Show country: " +showCountry);
        //alert("Country: " +countryField);
        console.log("Country: " + countryField);
        //alert ("countryField: " +countryField.get("v.value"));
        //alert("Go");
        if (showCountry === true && (countryField.get("v.value") === undefined || countryField.get("v.value") === '')) {
            countryField.set("v.errors", [{ message: $A.get("$Label.c.ISSP_CompanyLocation") }]);
            errors = true;
        } else if (showCountry === true) {
            country = countryField.get("v.value");
            countryField.set("v.errors", "");
        }
        // console.log(Country);
        // if (component.get("v.CompanyName") == true) {
        //     if (!(name) || name.length < 3) {
        //         // alert("Please insert at least 3 characters for the Company Name");
        //         return;
        //     }
        // }
        //
        // if (!(country) && component.get("v.showCountry") == true) {
        // 	alert("Please select a country");
        //     return;
        // }
        //
        // var showcodes = component.get("v.isAirline2");
        // if (showcodes == true) {
        //     var iatacode = component.get("v.IataCode");
        //     //alert(iatacode);
        //     if (!(iatacode) && (iatacode.length!=3 || isNaN(iatacode))) {
        //         alert ($A.get("$Label.c.ISSP_IATA_Code_Airline"));
        //     }
        //
        // }
        //
        // var country = component.get("v.DesCode");


        component.set("v.ShowResults", false);
        component.set("v.ShowNoResults", false);
        component.set("v.Results", "");
        console.log("Search");
        var search = component.get("c.SearchCompany");
        //alert("1");
        //search.setParams({ acctype : cmp.get("AccountType").get("v.value"), designatorcode : cmp.get("v.DesCode"), iatacode : cmp.get("v.IataCode"), country : cmp.get("v.Country"), name : cmp.get("v.Name") });
        var accounttype = component.find("AccountType").get("v.value");

        var designatorcode = component.get("v.DesCode");
        if (designatorcode == 'undefined') {
            designatorcode = '';
        }


        var iatacode = component.get("v.IataCode");
        if (iatacode == 'undefined') {
            iatacode = '';
        }

        var iatacodeag = component.get("v.IataCodeCargotravel");
        if (iatacodeag == 'undefined') {
            iatacodeag = '';
        }


        var cargotravel;
        console.log("Debug");
        var showcodes1 = component.get("v.isAirline2");
        var showcodes2 = component.get("v.isIataCodeCT");
        console.log("show codes1: " + showcodes1);
        console.log("show codes2: " + showcodes2);
        if (showcodes1 === true || showcodes2 === true) {
            console.log("If");
            console.log("accounttype: " + accounttype);

            console.log("iatacode: " + iatacode);

            // Validation of iata and designator code
            if (accounttype == 'Airline') {
                var errorfieldiata = component.find("IataCode");
                if (iatacode.length != 3) {
                    console.log("error1a");

                    errorfieldiata.set("v.errors", [{ message: $A.get("$Label.c.ISSP_IATA_Code_Airline") }]);
                    console.log("error1b");
                    errors = true;
                    return;
                } else
                    errorfieldiata.set("v.errors", "");
            } else if (accounttype == 'Agency') {
                var errorfieldagency = component.find("IataCodeCargotravel");
                iatacode = iatacodeag;
                cargotravel = component.find("CargoTravel").get("v.value");
                console.log("cargotravel: " + cargotravel);
                console.log("iatacodeag: " + iatacodeag);
                if (cargotravel == 'Cargo' && iatacodeag.length != 11) {
                    errorfieldagency.set("v.errors", [{ message: $A.get("$Label.c.ISSP_IATA_Code_Agency_Cargo") }]);
                    errors = true;
                    console.log("error2");
                    return;
                } else if (cargotravel == 'Travel' && iatacodeag.length != 8) {
                    errorfieldagency.set("v.errors", [{ message: $A.get("$Label.c.ISSP_IATA_Code_Agency_Travel") }]);
                    errors = true;
                    console.log("error3");
                    return;
                } else
                    errorfieldagency.set("v.errors", "");
            }

        }



        console.log("Account type: " + accounttype);
        console.log("Iata code: " + iatacode);
        search.setParams({ acctype: accounttype, designatorcode: designatorcode, iatacode: iatacode, country: country, name: name, cargotravel: cargotravel });
        search.setCallback(this, function(response) {
            component.set("v.NoAccounts", "");
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // if (result === '') {
                if (result.length === 0) {
                    //alert ("No result has been found.");
                    component.set("v.ShowPage4", true);
                    if (accounttype == 'Airline')
                        component.set("v.NoAccounts", $A.get("$Label.c.ISSP_NoRecordsFoundCreateStandardAirline"));
                    else if (accounttype == 'GSA')
                        component.set("v.NoAccounts", $A.get("$Label.c.ISSP_NoRecordsFoundGSA"));
                    else if (accounttype == 'Agency')
                        component.set("v.NoAccounts", $A.get("$Label.c.ISSP_NoRecordsFoundNext"));
                    else if (accounttype == 'Other Company')
                        component.set("v.NoAccounts", $A.get("$Label.c.ISSP_NoRecordsFoundCreateAgency"));
                    else if (accounttype == 'General Public')
                        component.set("v.NoAccounts", $A.get("$Label.c.ISSP_GeneralPublicNotFound"));

                    component.set("v.ShowNoResults", true);

                    component.set("v.ShowCreateAccount", true);

                    var iatacode = component.get("v.IataCode");
                    if (iatacode == 'undefined') {
                        iatacode = '';
                    }

                    if ((accounttype == 'Agency' || accounttype == 'Airline') && iatacode !== '') {
                        component.set("v.ShowCreateAccount", false);
                        component.set("v.NoAccounts", $A.get("$Label.c.ISSP_NoRecordsFoundGP"));
                        component.set("v.ShowPage4", false);

                    }


                    if (accounttype == 'General Public' || accounttype == 'GSA') {
                        component.set("v.ShowCreateAccount", false);
                        component.set("v.ShowPage4", false);
                    }

                } else {
                    component.set("v.ShowResults", true);
                    component.set("v.ShowCreateAccount", false);
                    component.set("v.Results", response.getReturnValue());
                    component.set("v.ShowPage4", false);

                }
            } else if (state === "ERROR") {
                var errors = response.getError();

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        //Comment to block validations
        if (!errors) $A.enqueueAction(search);


    },

    CategoryChange: function(component, event, helper) {
        var categoryField = component.find("Category");
        var category = categoryField.get("v.value");
        if (category == 'Other')
            component.set("v.ShowCategoryOther", true);
        else
            component.set("v.ShowCategoryOther", false);

    },

    // Invoked when user decides to create a new account-> opens page 4
    createAccount: function(component, event, helper) {
        console.log("Create new account 1");
        component.set("v.Page", 4);

        component.set("v.BillingCountry", component.find("countryName").get("v.value"));
        component.set("v.ShippingCountry", component.find("countryName").get("v.value"));
        console.log("Create new account 2");
        if (component.find("accountName") !== "undefined" && component.find("accountName") !== null) {
            var nameField = component.find("accountName").get("v.value");
            var legalname = component.find("legalName");
            legalname.set("v.value", nameField);
        }
        console.log("Create new account 3");
        component.set("v.ShowCreateAccount", false);
        component.set("v.NoAccounts", "");
        component.set("v.ShowSubmit", true);
        component.set("v.ShowSearch", false);
        console.log("Create new account 4");

    },

    // Invoked when user has filled the account info and click Submit on page 4
    submit: function(component, event, helper) {
        console.log("1");
        //var account = component.get("v.account");
        var contact = JSON.stringify(component.get("v.contact"));
        console.log(contact);
        console.log("2");;
        var vfOrigin = component.get('v.vfHost'); // + '/'+commName+'/OneIdVfCreateAccount';
        console.log('vfOrigin submit: ' + vfOrigin);
        var vfWindow = component.find("vfFrameAccount").getElement().contentWindow;
        console.log("vfWindow:" + vfWindow);
        vfWindow.postMessage(contact, vfOrigin);
        console.log("2.2");

        //var termsError = helper.validateTerms(component);
        //if(termsError) {
        //    console.log('terms error');
        //    component.set("v.Page", 1);
        //} else if (!helper.validateContact(component)) {
        //    component.set("v.Page", 2);
        //} else {

        //if (!helper.validateContact(component)) {
        //    component.set("v.Page", 2);
        //}
        //else {

        var errors = helper.validateAccount(component);
        console.log("3");

        //If new account is created, put designator code and iata code that had been entered by user in his search

        var companyType = component.get("v.AccountT");
        //alert("Company type: " +companyType);

        var action = component.get("c.createContactAndAccount");
        var servName = component.get("v.serviceName");
        action.setParams({ con: contact, acc: account, customerType: companyType, servName: servName });
        action.setCallback(this, function(a) {
            //alert("Saving");
            var state = a.getState();
            //alert(state);
            if (state == "SUCCESS") {
                var result = a.getReturnValue();
                var confirm = $A.get("$Label.c.ISSP_Registration_PleaseCheckYourMail");
                alert(confirm);

                alert("User created successfully: " + result);
                window.location.href = "/" + commName + "/s/login/";
            } else if (state == "ERROR") {
                var errors = a.getError();

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }

            }
            // helper.hideSpinner(component);
        });
        //Comment to block validations
        if (!errors) {
            // helper.showSpinner(component);
            component.set("v.disableButtons", true);
            $A.enqueueAction(action);
        }
        //}



    },

    // Invoked when user has found an account as result of his search and then submits it
    selectAccount: function(component, event, helper) {
        //alert("Select account");
        var contact = component.get("v.contact");
        var accounts = component.find("selectedAccount");
        var results = component.get("v.Results");
        console.log(JSON.stringify(accounts));
        var functionString = '';
        var index = 0;
        for (var i = 0; i < accounts.length; i++) {
            if (accounts[i].get("v.value") === true) {
                index = i;
                break;
            }


        }
        var account = results[index];
        var companyType = component.get("v.AccountT");
        var servName = component.get("v.serviceName");
        var action = component.get("c.createContactAndAccount");
        console.log("Customer type: " + companyType);
        console.log("contact: " + contact);
        console.log("account: " + account);

        action.setParams({ con: contact, acc: account, customerType: companyType, servName: servName });
        action.setCallback(this, function(a) {
            console.log("Execute");
            var state = a.getState();
            //alert("State: " +state);
            if (state == "SUCCESS") {
                var result = a.getReturnValue();
                var confirm = $A.get("$Label.c.ISSP_Registration_PleaseCheckYourMail");
                alert(confirm);

                alert("User created successfully: " + result);
                window.location.href = "/OneIdentity/s/login/";
            } else if (state == "ERROR") {
                var errors = a.getError();

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }

            }
        });
        //alert("Errors: " +errors);
        //if(!errors)
        $A.enqueueAction(action);

    },
    copyBillingAddressToShipping: function(component) {

        if (component.find("copybil").get("v.value") != true) return;
        var account = component.get("v.account");
        component.find("shippingStreet").set("v.value", account.BillingStreet);
        component.find("shippingCity").set("v.value", account.BillingCity);
        component.find("shippingPostalCode").set("v.value", account.BillingPostalCode);
        component.find("shippingState").set("v.value", account.BillingState);
        account.ShippingStreet = account.BillingStreet;
        account.ShippingCity = account.BillingCity;
        account.ShippingPostalCode = account.BillingPostalCode;
        account.ShippingState = account.BillingState;
        component.set("v.account", account);
    },

    back: function(component) {
        var pagenumber = component.get("v.Page");
        pagenumber--;
        component.set("v.Page", pagenumber);
        component.set("v.ShowSubmit", false);
        component.set("v.NoAccounts", "");
        if (pagenumber != 3) {
            component.set("v.ShowSearch", false);
            component.set("v.ShowCreateAccount", false);
            component.set("v.ShowSave", true);

            component.find("AccountType").set("v.value", null);
            component.set("v.isAirline1", false);
            component.set("v.isAirline2", false);
            component.set("v.showCompanyName", false);
            component.set("v.showCountry", false);
            component.set("v.isCargoTravel1", false);
            component.set("v.isCargoTravel2", false);
            component.set("v.isIataCodeCT", false);
            component.set("v.ShowResults", false);
            component.set("v.NoAccounts", "");
        } else if (pagenumber == 3) {
            component.set("v.ShowSearch", true);
        }



    },
    // clickDiv: function(component, event, helper) {
    //     console.log('clickDiv');
    //     var whichOne;
    //     if(event.currentTarget.id !== undefined) {
    //         console.log('ud');
    //         whichOne = event.currentTarget.id; // .getLocalId()
    //     }
    //     console.log('wo: ' + whichOne);
    // },
    // clickSpan: function(component, event, helper) {
    //     console.log('clickSpan');
    //     var whichOne = getSource().getLocalId();
    //
    //     helper.showPage(component, event, 2);
    // },

    showPage: function(component, event, helper) {
        console.log('showPage');
        var whichOne = event.currentTarget.id;
        console.log('wo2: ' + whichOne);
        var emailLocked = component.get("v.emailLocked");
        var ShowPage4 = component.get("v.ShowPage4");
        var page;
        if (whichOne === '1') {
            // page = component.get("v.ShowPage1");
            component.set("v.Page", 1);
            console.log('page 1');
            var page2 = component.find('page-2');
            $A.util.addClass(page2, 'page-invisible');
            var iFrameAccount = component.find("vfFrameAccount");
            $A.util.removeClass(iFrameAccount, 'changeMe');
        } else if (whichOne === '2') {
            console.log('page 2');
            if (emailLocked) {
                component.set("v.Page", 2);
                component.set("v.ShowSubmit", false);

                var page2 = component.find('page-2');
                $A.util.removeClass(page2, 'page-invisible');
                var iFrameAccount = component.find("vfFrameAccount");
                $A.util.removeClass(iFrameAccount, 'changeMe');
            }
        } else if (whichOne === '3') {
            console.log('page 3');
            // page = component.get("v.ShowPage3");
            if (!helper.validateContact(component)) {
                component.set("v.Page", 3);
            }
        } else if (whichOne === '4' && ShowPage4) {
            // page = component.get("v.ShowPage4");
            component.set("v.Page", 4);
            component.set("v.ShowCreateAccount", false);
            component.set("v.NoAccounts", "");
            component.set("v.ShowSubmit", true);
            component.set("v.ShowSearch", false);
        }
    },
    //Manuel Conde
    showPage3: function(component, event, helper) {
        console.log('showPage');
        //    var whichOne = event.getSource().getLocalId();
        var whichOne = event.currentTarget.id;
        console.log('showPage3 wo2: ' + whichOne);
        var emailLocked = component.get("v.emailLocked");
        var ShowPage4 = component.get("v.ShowPage4");
        var page;
        if (whichOne === '1') {
            // page = component.get("v.ShowPage1");
            component.set("v.Page", 1);
            console.log('1');
        } else if (whichOne === '2') {
            // page = component.get("v.ShowPage2");
            //

            //if(!helper.validateEmail(component)) {
            if (emailLocked) {
                component.set("v.Page", 2);
                component.set("v.ShowSubmit", false);
            }
        } else if (whichOne === '3') {
            // page = component.get("v.ShowPage3");
            if (!helper.validateContact(component)) {
                component.set("v.Page", 3);
                var contactRaw = component.get("v.contact");
                //contactRaw.Preferred_Language__c = helper.getUrlParameterByName('language');
                var contact = JSON.stringify(contactRaw);
                console.log("logging contact");
                console.log('mc ' + JSON.stringify(contact));

                var vfOrigin = component.get('v.vfHost'); //+ '/'+commName+'/OneIdVfDSE';
                console.log('vfOrigin submit: ' + vfOrigin);

                var iFrameAccount = component.find("vfFrameAccount");
                $A.util.addClass(iFrameAccount, 'changeMe');
                var page2 = component.find('page-2');
                $A.util.addClass(page2, 'page-invisible');

                var vfWindow = iFrameAccount.getElement().contentWindow;
                console.log("vfWindow:" + vfWindow);
                //vfWindow.postMessage(contact, vfOrigin);
                vfWindow.postMessage({ action: "alohaSendingContact", sendingContact: contact }, vfOrigin);

                document.getElementById('accountManagement').scrollIntoView(true);

            }
        } else if (whichOne === '4' && ShowPage4) {
            // page = component.get("v.ShowPage4");
            component.set("v.Page", 4);
            component.set("v.ShowCreateAccount", false);
            component.set("v.NoAccounts", "");
            component.set("v.ShowSubmit", true);
            component.set("v.ShowSearch", false);
        }
        // component.set(p, true);
    },
    hidePage: function(component, event, helper) {
        component.set("v.Page", 0);
        // var whichOne = event.getSource().getLocalId();
        // var page;
        // if(whichOne === '1') {
        //     page = component.get("v.ShowPage1");
        //     component.set("v.ShowPage1", false);
        // }
        // else if(whichOne === '2') {
        //     page = component.get("v.ShowPage2");
        //     component.set("v.ShowPage2", false);
        // }
        // else if(whichOne === '3') {
        //     page = component.get("v.ShowPage3");
        //     component.set("v.ShowPage3", false);
        // }
        // else if(whichOne === '4') {
        //     page = component.get("v.ShowPage4");
        //     component.set("v.ShowPage4", false);
        // }
        // component.set(p, true);

    },
    doInit: function(component, event, helper) {
        //var vfOrigin = "https://oneidconde-customer-portal-iata.cs83.force.com";
        helper.getHostURL(component, event);
        helper.getCommunityName(component, event);

        window.addEventListener("message", function(event) {
            var vfOrigin = component.get('v.vfHost');
            var commName = component.get("v.commName");
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }

            console.log('event.data: ' + event.data);
            if (event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK') {
                var div = component.find("captchaError");
                $A.util.removeClass(div, 'hide');
            } else if (event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK') {
                component.set("v.captchaOK", true);
                var div = component.find("captchaError");
                $A.util.addClass(div, 'hide');
                var page2 = component.find('page-2');
                $A.util.removeClass(page2, 'page-invisible');
            } else if (event.data.action == 'iframeResize') {
                if (event.data.alohaCallingCreateAccountOK == 'AccountContactAndUserSuccess' ||
                    event.data.alohaCallingCreateAccountOK == 'ReturnToLogin') {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    //if(confirm("my text here")){
                    setTimeout(function() {
                        urlEvent.setParams({
                            //"url": vfOrigin + '/' + commName + '/s/login/'
                            "url": $A.get("$Label.c.OneId_URL_javaScript") + '/s/login/'
                        });
                        urlEvent.fire();
                    }, 15000);
                    //} 
                }
                //var thisWidth = jQuery('.cLightningRegistrationProcess').width();
                //var styl = "width:" + thisWidth + "px; height:" + event.data.height + "px;";
                var styl = "height:" + event.data.height + "px;";
                component.set("v.styl", styl);
                var page2 = component.find('page-2');
                $A.util.addClass(page2, 'page-invisible');
            } else if (event.data.action == 'callIframeResizeCallback') {
                jQuery('.captchaIframe').removeAttr('height');
                var captchaIframeHeight;
                if (event.data.height == null)  {
                    captchaIframeHeight = "height: 0px;";
                }
                if(event.data.height && event.data.height.length>0){ 
                    captchaIframeHeight = "height:" + event.data.height + "px;";
                }
                component.set("v.captchaIframeHeight", captchaIframeHeight); 
            }
        }, false);
    },
    checkTerms: function(component, event, helper) {
        console.log('ct');
        if (!helper.validateEmail(component)) {
            var terms = component.get("v.Terms");

            if (terms) {
                var vfOrigin = component.get('v.vfHost');
                var vfWindow = component.find("vfFrame").getElement().contentWindow;
                vfWindow.postMessage({ action: "alohaCallingCAPTCHA" }, vfOrigin);
                helper.placeFlags(component);
            }
        }
    },
    validateContact: function(component, event, helper) {
        var emailOK = component.get("v.emailOK");

        if (emailOK) {
            console.log('email - ok');
            component.set("v.ShowPage3", true);
        }
        if (!helper.validateContact(component)) {
            component.set("v.ShowPage3", true);
        }
    },
    showToast: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    /*,
    resizeIframe: function(component, event, helper) {
        console.log('----------> resizing');
        var vfFrameAccount = component.get("vfFrameAccount");

        window.addEventListener("height", function(event) {
            console.log('---------> event data height: ' + height);
            var styl = "height:" + height + "px";
            vfFrameAccount.set('v.styl', styl);
        }, false);
    }*/
    /*,
    afterJqueryLoaded: function(component, event, helper) {

    }*/


})
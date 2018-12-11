({
	initialize: function(component, event, helper){
		console.log("initialize");
		
		helper.getUserInfo(component);
		helper.getUserContact(component);
		helper.getCategoryPicklistValues(component);
		helper.getPreferredLanguagePicklistValues(component);
	},
	showEdit : function(component, event, helper) {
		helper.getCategoryPicklistValues(component);
		helper.getPreferredLanguagePicklistValues(component);
		console.log(component.find('functionpicklist').get('v.value'));
		var showTarget = component.find('block-edit');
		var hideTarget = component.find('block-read');
		$A.util.addClass(hideTarget, 'hide');
		$A.util.removeClass(showTarget, 'hide');
	},
	hideEdit : function(component, event, helper){
		var showTarget = component.find('block-read');
		var hideTarget = component.find('block-edit');
		$A.util.addClass(hideTarget,'hide');
		$A.util.removeClass(showTarget, 'hide');
	},
	saveEdit : function(component, event, helper){
		var validupdate = true;

		var firstname = component.find("editfirstname").get("v.value");
		var lastname = component.find("editlastname").get("v.value");
		var phone = component.find("editphone").get("v.value");
		var fax = component.find("editfax").get("v.value");
		var jobtitle = component.find("editjobtitle").get("v.value");
		var functionpick = component.find("functionpicklist").get("v.value");
		var preferredlanguage = component.find("preferredlanguagepicklist").get("v.value");

		var contact = component.get("v.contactinfo");
		console.log(contact.FirstName);
		console.log(firstname);
		if(firstname != contact.FirstName){
			if($A.util.isEmpty(firstname)){
				firstname.set("v.errors", [{message:"Can't be empty"}]);
				validupdate = false;
			}
		}
		if(lastname != contact.LastName){
			if($A.util.isEmpty(lastname)){
				lastname.set("v.errors", [{message:"Can't be empty"}]);
				validupdate = false;
			}
		}
		if(jobtitle != contact.Title){
			if($A.util.isEmpty(jobtitle)){
				jobtitle.set("v.errors", [{message:"Can't be empty"}]);
				validupdate = false;
			}
		}
		if(functionpick != contact.Membership_Function__c){
			if($A.util.isEmpty(functionpick)){
				functionpick.set("v.errors", [{message:"Can't be empty"}]);
				validupdate = false;
			}
		}
		if(preferredlanguage != contact.Preferred_Language__c){
			if($A.util.isEmpty(preferredlanguage)){
				preferredlanguage.set("v.errors", [{message:"Can't be empty"}]);
				validupdate = false;
			}
		}

		var action = component.get("c.saveProfileEdit");
		action.setParams({
			"firstname" : firstname,
			"lastname" : lastname,
			"phone" : phone,
			"fax" : fax,
			"jobtitle" : jobtitle,
			"functionpick" : functionpick,
			"preferredlanguage" : preferredlanguage
		});

		action.setCallback(this,function(response){
			console.log(response);
			console.log(response.getState());
			var showTarget = component.find('block-read');
			var hideTarget = component.find('block-edit');
			$A.util.addClass(hideTarget,'hide');
			$A.util.removeClass(showTarget, 'hide');
			helper.getUserInfo(component);
			helper.getUserContact(component);
		});

		$A.enqueueAction(action);

	},
	goToChangePassword: function(component, event, helper){
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": "../../oneid_changePassword"
		});
		urlEvent.fire();
	},
})
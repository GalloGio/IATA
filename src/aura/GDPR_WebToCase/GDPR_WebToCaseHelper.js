({
	controlFields : function(component) {
		var isAllFilled = true;
        var subject = component.find("subject");
        if(subject == undefined || $A.util.isEmpty(subject.get("v.value"))) {
            subject.set("v.errors", [{message: "This field is required"}]);
            isAllFilled = false;
        } else {
            subject.set("v.errors", null);
        } 
        var description = component.find("description");
        if(description == undefined || $A.util.isEmpty(description.get("v.value"))) {
            description.set("v.errors", [{message: "This field is required"}]);
            isAllFilled = false;
        } else {
            description.set("v.errors", null);
		}
        var dataPrivacy = component.find("dataPrivacy");
        if(dataPrivacy == undefined || $A.util.isEmpty(dataPrivacy.get("v.value"))) {
            dataPrivacy.set("v.errors", [{message: "This field is required"}]);
            isAllFilled = false;
        } else {
            dataPrivacy.set("v.errors", null);
        }
		return isAllFilled;
    },
    
    controlDPOFields : function(component) {
		var isAllFilled = true;
        var passName = component.find("passengerName");
        
        if(passName == undefined || $A.util.isEmpty(passName.get("v.value"))) {
            passName.set("v.errors", [{message: "This field is required"}]);
            isAllFilled = false;
        } else {
            passName.set("v.errors", null);
        } 
        
        var ticket = component.find("ticketNumber");
        if(ticket == undefined || $A.util.isEmpty(ticket.get("v.value"))) {
            ticket.set("v.errors", [{message: "This field is required"}]);
            isAllFilled = false;
        } else {
            ticket.set("v.errors", null);
		}
        
        var dateIssue = component.find("dateIssue");
        if(dateIssue == undefined || $A.util.isEmpty(dateIssue.get("v.value"))) {
            dateIssue.set("v.errors", [{message: "This field is required"}]);
            isAllFilled = false;
        } else {
            // Check format
            var isValidDate = this.isValidDate(new Date(dateIssue.get("v.value")));
            if(isValidDate)
                dateIssue.set("v.errors", null);
            else {
                dateIssue.set("v.errors", [{message: "Invalid date format : mm/dd/yyyy"}]);
                isAllFilled = false;
            }
        }
		return isAllFilled;
    },
    
    isValidDate : function(d) {
        return d instanceof Date && !isNaN(d);
    }
})
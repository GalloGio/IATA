({
    doInit: function(component, event, helper) {        
        var lstIds = [];
        lstIds.push(component.get('v.recordId'));

		var action = component.get('c.updateArticleCategories');
		action.setParams({
			'articleTypeIds': lstIds
		});
		action.setCallback(this, function(response) {
            var state = response.getState();

			if (state === 'SUCCESS') {
                var resp = response.getReturnValue();

                if(resp.isSuccess) {
                    component.set('v.buttonDisabled', false);
                } else {
                    var toast = $A.get('e.force:showToast');
                    toast.setParams({
                        type: 'error',
                        title: $A.get('$Label.c.PKB2_js_error'),
                        message: resp.errorMsg
                    });
                    toast.fire();
                    $A.get('e.force:closeQuickAction').fire();   
                }

            }

        });
		$A.enqueueAction(action);
    },

    closeQuickAction: function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },

    submitAction: function(component, event, helper) {
        component.set('v.buttonDisabled', true);

		var action = component.get('c.submitArticleForApproval');
		action.setParams({
            'approvalNameOrId': 'KnowledgeFAQArticles',
            'recordId': component.get('v.recordId'),
            'userId': $A.get('$SObjectType.CurrentUser.Id'),
            'comments': component.get('v.Comments')
		});
		action.setCallback(this, function(response) {
            var state = response.getState();
            
			if (state === 'SUCCESS') {
                var toast = $A.get('e.force:showToast');
                toast.setParams({
                    type: 'success',
                    title: $A.get('$Label.c.CSP_Success'),
                    message: $A.get('$Label.c.CSP_SubmittedApproval')
                });
                toast.fire();
                $A.get('e.force:closeQuickAction').fire();
			} else {
                var errors = response.getError();
                
                var toast = $A.get('e.force:showToast');
                toast.setParams({
                    type: 'error',
                    title: errors[0].pageErrors[0].statusCode,
                    message: errors[0].pageErrors[0].message
                });
                toast.fire();
                $A.get('e.force:closeQuickAction').fire();                
            }
		});
		$A.enqueueAction(action);        
    }
})

/**
 * Created by ppop on 8/8/2019.
 */
({
    preview:function(component, event, helper){
        $A.get('e.lightning:openFiles').fire({
        		    recordIds: ['0691x000000mEh0AAE']
        		});
    },
    initializeComponent : function(component, event, helper) {




                                let action = component.get('c.getObjects');
                                action.setCallback(this, function(response){
                                    const state = response.getState();
                                    if(state === 'SUCCESS') {
                                        console.log( response.getReturnValue());
                                    component.set("v.objectIds", response.getReturnValue());
                                    component.set("v.initialized", true);
                                }
                                });
                                $A.enqueueAction(action);
         },

})
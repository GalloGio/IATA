({
    loadMessages : function(component, event) {
        var action = component.get('c.getMessages');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var messages = response.getReturnValue();
                if(! $A.util.isEmpty(messages)) {

                    component.set('v.messages', messages);

                }else{
                    console.log('loadMessages - empty list retrieved');
                }
            }else{
                console.log('loadMessages error');
            }
        });
        $A.enqueueAction(action);

    },

})
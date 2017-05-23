({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    handleLogin: function (component, event, helpler) {
        //Get parameters
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var startUrl = component.get("v.startUrl");
        
        if(username==''){
            component.set("v.errorMessage",$A.get("$Label.c.OneId_Username_ErrorBlank"));
            component.set("v.showError",true);
            return;
    	}
        else if (password==''){
            component.set("v.errorMessage",$A.get("$Label.c.OneId_Password_ErrorBlank"));
            component.set("v.showError",true);
            return;
        }
        
        //Configure apex controller action function
        var action = component.get("c.login");
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({username:username, 
                          password:password, 
                          startUrl:startUrl});
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                console.log('handleLogin.Callback rtnValue='+rtnValue);
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
   getClientIpAddressAjax : function (component, event, helpler) { 
       var siteCompleteUrl=component.get('v.siteCompleteUrl');
       var url;
       //url='https://oneidconde-customer-portal-iata.cs83.force.com/oneidentity/services/apexrest/OneIdGetHttpContext';
       url=siteCompleteUrl+'/services/apexrest/OneIdGetHttpContext';
       
       console.log('URL web service REST to get IP Adress: '+url);      
       
       $.ajax({
            url: url,
            type: 'GET',
            async: false,
            //dataType: 'json',
            //crossDomain: true,
            beforeSend: function (request)
            {
            	//request.setRequestHeader("HeaderName", "HeaderValue");
            	console.log('In AJAX beforeSend');
            },
            success : function(result)
            {
                //process the result
                console.log('In AJAX success: '+result);
//$("#clientIpAddressAjax").val(result);
//FAZER SET DE HIDEN PARA DEPOIS IR BUSCAR QUANDO FIZER LOGIN
//component.set("v.clientIpAddress",result);
				$("#clientIpAddressAjax").val(result).trigger('change');
//$("#clientIpAddressAjax").val(result).change();
//$('#clientIpAddressAjax').trigger('onchange');
				//document.getElementById('clientIpAddressAjax').onchange();
                console.log('ajax succes GET after SET component: '+$("#clientIpAddressAjax").val());
            },
            error : function(jqXHR, textStatus, errorThrown) {
                console.log('error');
                console.log('Error: '+jqXHR.status);
                console.log('ErrorThrown: '+errorThrown)
            } 
         });
	},
    
    getSanctionCountry : function (component, event, helpler, clientIpAddress) {
        
        //Configure apex controller action function
        var action = component.get("c.getSanctionCountry");
        
        console.log('getSanctionCountry.Begin - IpAddress to pass: '+clientIpAddress);
        action.setParams({clientIpAddress:clientIpAddress});
        
        action.setCallback(this, function(a){
        	var rtnValue = a.getReturnValue();
            console.log('getSanctionCountry.Calback getSanctionCountry='+JSON.stringify(rtnValue));
            if (rtnValue !== null) {
                component.set('v.sanctionCountry',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getShow90Days : function (component, event, helpler) {
        var action = component.get("c.getShow90Days");
        action.setCallback(this, function(a){
        	var rtnValue = a.getReturnValue();
            console.log('getShow90Days.Callback rtnValue='+JSON.stringify(rtnValue));
            if (rtnValue !== null) {
                component.set('v.show90Days',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
        	var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
        	var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
        	var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
        	var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSiteCompleteUrl : function (component, event, helpler) {
        var action = component.get("c.getSiteCompleteUrl");
        action.setCallback(this, function(a){
        	var rtnValue = a.getReturnValue();
            console.log('getSiteCompleteUrl.Callback rtnValue='+JSON.stringify(rtnValue));
            if (rtnValue !== null) {
                component.set('v.siteCompleteUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    onchangeClientIpAddressAjax: function(cmp, event, helper) {
        alert("Changed field!");
        console.log("Changed field!");
    } 
})
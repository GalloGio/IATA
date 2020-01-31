({
    initTable : function(component) {
        component.set('v.gridColumns',[
            {label: 'IATA Group Name', cssClass: 'th_17'},
            {label: 'IATA Group Owner', cssClass: 'th_12'},
            {label: 'Mission of IATA Group', cssClass: 'th_30'},
            {label: 'Role Within Group', cssClass: 'th_11'},
            {label: 'Salut.', cssClass: 'th_5'},
            {label: 'First Name', cssClass: 'th_8'},
            {label: 'Last Name', cssClass: 'th_8'},
            {label: 'Title', cssClass: 'th_9'}
        ]);
    },
    fetchData : function(component) {
        var action = component.get('c.getParticipants');
        action.setParams({
            'accountId': component.get('v.accountId'),
            'retrieveMainGroupParticipants' : false
        }) 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set('v.gridData', result.groups);
                component.set('v.originalData', result.groups);
                component.set('v.gridExpandedRows', result.expandedRows);
                component.set('v.originalExpRows', result.expandedRows);
                component.set('v.hasRepresentatives', result.hasRepresentatives);
                component.set('v.countries', result.countries);
            }
        });

        $A.enqueueAction(action);
    },
    displayChilds : function(component,rowId) {
        var childs = component.get('v.gridExpandedRows')[rowId];
        var childsOfChilds = component.get('v.originalData');
        
        for(var i=0; i<childs.length; i++) {
            for(var j=0; j<childsOfChilds.length; j++) {
                for(var h=0; h<childsOfChilds[j].childrens.length; h++) {
                    for(var k=0; k<childsOfChilds[j].childrens[h].childrens.length; k++) {
                        let testID = childs[i]+'-'+childsOfChilds[j].childrens[h].childrens[k].rowId;
                        document.getElementById(testID).classList.remove("slds-hide");
                        var childExpandIcon = document.getElementById('expand_'+testID);
                        if(childExpandIcon) {
                            childExpandIcon.classList.remove("slds-hide");
                        }
                    }
                }
            }
        }        
    },
    hideChilds : function(component,rowId) {
        var relationsList = component.get('v.gridExpandedRows');
        var childs = relationsList[rowId];
        var childsOfChilds = component.get('v.originalData');
        for(var i=0; i<childs.length; i++) {
            for(var j=0; j<childsOfChilds.length; j++) {
                for(var h=0; h<childsOfChilds[j].childrens.length; h++) {
                    for(var k=0; k<childsOfChilds[j].childrens[h].childrens.length; k++) {
                        let testID = childs[i]+'-'+childsOfChilds[j].childrens[h].childrens[k].rowId;
                        document.getElementById(testID).classList.add("slds-hide");
                        var expandIcon = document.getElementById('expand_'+testID);
                        var collapseIcon = document.getElementById('collapse_'+testID);

                        if(expandIcon) {
                            expandIcon.classList.add("slds-hide");
                        }
                        if(collapseIcon) {
                            collapseIcon.classList.add("slds-hide");
                        }
                    }
                }
            }
        }
    },
    hanldeCountryFilter : function(component,country) {
        var filteredData = JSON.parse(JSON.stringify(component.get('v.originalData')));
        var filteredExpRows = JSON.parse(JSON.stringify(component.get('v.originalExpRows')));

        var topGroupsToInclude = [];
        for(var i=0; i<filteredData.length; i++) {
            var childrens = filteredData[i].childrens;
            
            var filteredChilds = [];
            var filteredChildsIds = [];
            for(var j=0; j<childrens.length; j++) {
                var child = childrens[j];
                if(child.countryId == country) {
                    filteredChilds.push(child);
                    filteredChildsIds.push(child.rowId);
                } else {
                    delete filteredExpRows[child.rowId];
                }
            }

            if(filteredChilds.length > 0) {
                filteredData[i].childrens = filteredChilds;
                filteredExpRows[filteredData[i].rowId] = filteredChildsIds;
                topGroupsToInclude.push(filteredData[i].rowId);
            } else {                
                delete filteredExpRows[filteredData[i].rowId];
            }
        }

        filteredData = filteredData.filter(row => topGroupsToInclude.includes(row.rowId));

        component.set('v.gridData', filteredData);
        component.set('v.gridExpandedRows', filteredExpRows);
    }        
})
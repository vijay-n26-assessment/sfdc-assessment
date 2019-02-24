({
	fetchProductInformation : function(component, event) {
		var fetchProductInfoAction = component.get("c.getProductInformation");
        fetchProductInfoAction.setParams({
            "caseId": component.get("v.recordId")
        });
        fetchProductInfoAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var productInfoMap = response.getReturnValue();
                var productInformation = [];
                for (var key in productInfoMap) {
                    component.set("v.infoFound", true);
                    productInformation.push({
                        "key": key, "value": productInfoMap[key]
                    });
                }
                component.set("v.productInformation", productInformation);
            } else {
                component.set("v.infoFound", false);
            }
        });
        
        $A.enqueueAction(fetchProductInfoAction, false);
	}
})
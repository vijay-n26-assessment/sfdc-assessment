({
	doInit : function(component, event, helper) {
		//Pass the recordId Apex controller and furnish the product information
		helper.fetchProductInformation(component, event);
	}
})
public class ProductInformationController {
	@AuraEnabled
    public static Map<String, String> getProductInformation(Id caseId) {
        Map<String, String> mapProductInformation = new Map<String, String>();
        
        // Get the case record details for 'caseId'
        if (caseId != null) {
            Case customerCase = [SELECT Id, ContactId, Contact.Home_Country__c, Contact.Product__c 
                                   FROM Case WHERE Id = :caseId LIMIT 1];
            
            // Check if the customer contact has the required fields and proceed
            if (customerCase != null && customerCase.ContactId != null
                && customerCase.Contact.Home_Country__c != null && customerCase.Contact.Product__c != null) {
                // To make the code configurable, used field sets to get the list of fields to be shown in the component
                // In future, to add a new field to this component, just add it to the field set
                List<Schema.FieldSetMember> productInformationFields = SObjectType.Product_Information__c.FieldSets.Product_Information_Fields.getFields();
                
                // Build the SOQL query based on the fields in the field set
                String query = 'SELECT Id, ';
                for (Schema.FieldSetMember field : productInformationFields) {
                    query += field.getFieldPath() + ', ';
                }
                query = query.substringBeforeLast(', ');
                query += ' FROM Product_Information__c'
                	   + ' WHERE Country__c = \'' + customerCase.Contact.Home_Country__c + '\''
                	   + ' AND Product__c = \'' + customerCase.Contact.Product__c  + '\'LIMIT 1';
                
                SObject productInformationRecord = Database.query(query);
                
                // Build a map of field label - field value which can be directly bound in the lightning component
                for (Schema.FieldSetMember field : productInformationFields) {
                    mapProductInformation.put(field.getLabel(), (String)productInformationRecord.get(field.getFieldPath()));
                }
            }
        }
        
        return mapProductInformation;
    }
}
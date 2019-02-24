@isTest
public class ProductInformationControllerTest {
    static Case testCase { get; set; }
    static Case testInvalidCase { get; set; }
    
    static Contact testContact { get; set; }
    static Contact testInvalidContact { get; set; }
    
    // Utility method to create the test contact and case records
    static void createTestCases() {
        testContact = new Contact(FirstName='Vijay', LastName='Prakash', Home_Country__c='DE', Product__c='Metal');
        insert testContact;
        
        testInvalidContact = new Contact(FirstName='Invalid', LastName='Contact', Product__c='Standard');
        insert testInvalidContact;
        
        testCase = new Case(Subject='Test Valid Case', ContactId=testContact.Id, Status='New', Priority='Medium', Origin='Web');
        insert testCase;
        
        testInvalidCase = new Case(Subject='Test Invalid Case', ContactId=testInvalidContact.Id, Status='New', Priority='Medium', Origin='Web');
        insert testInvalidCase;
    }
    
    // Utility method to create product information matrix
    static void createProductInformationData() {
        List<Product_Information__c> lstProductInformations = new List<Product_Information__c>();
        Set<String> setCountries = new Set<String> { 'DE', 'FR' };
        Set<String> setProductTypes = new Set<String> { 'Standard', 'Black', 'Metal' };
            
        for (String country : setCountries) {            
            for (String productType : setProductTypes) {                
                Product_Information__c info = new Product_Information__c(Country__c = country,
                                                                         Product__c = productType,
                                                                         Cost_per_Calendar_Month__c = '€ 9',
                                                                         ATM_Fee_in_other_currencies__c = '1.7%',
                                                                         Card_Replacement_Cost__c = '€ 9'
                                                                        );
                        
                lstProductInformations.add(info);
            }
        }
        
        insert lstProductInformations;
    }
    
    // Method to test the positive scenario
    testMethod static void testPositiveScenario() {
        createProductInformationData();
        createTestCases();
        
        // Not used System.runAs() as role-based is not required
        Test.startTest();
        // Pass the case id with a valid customer
        Map<String, String> mapProdInfo = ProductInformationController.getProductInformation(testCase.Id);
        
        System.assertEquals(false, mapProdInfo.isEmpty());
        System.assertEquals(3, mapProdInfo.size());
        System.assertEquals('€ 9', mapProdInfo.get('Cost per Calendar Month'));
        System.assertEquals('1.7%', mapProdInfo.get('ATM Fee in other currencies'));
        System.assertEquals('€ 9', mapProdInfo.get('Card Replacement Cost'));
        Test.stopTest();
    }
    
    // Method to test the negative scenario
    testMethod static void testNegativeScenario() {
        createProductInformationData();
        createTestCases();
        
        // Not used System.runAs() as role-based is not required
        Test.startTest();
        // Pass the case id with an invalid customer
        Map<String, String> mapProdInfo = ProductInformationController.getProductInformation(testInvalidCase.Id);
        
        System.assertEquals(true, mapProdInfo.isEmpty());
        Test.stopTest();
    }
}
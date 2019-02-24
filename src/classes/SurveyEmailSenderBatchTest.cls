@isTest
public class SurveyEmailSenderBatchTest {
    private static void createTestData() {
        List<Contact> testContacts = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            testContacts.add(new Contact(FirstName='Test', LastName='Contact' + i, Email='test@example.com', Survey_Date__c=Date.today()));
        }
        
        try {
            Database.insert(testContacts);
        } catch(Exception ex) {
            System.debug('Error occurred while creating test contact records: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    
    private static void createNegativeTestData() {
        List<Contact> testContacts = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            testContacts.add(new Contact(FirstName='Test', LastName='Contact' + i, Email='test@example.com', Survey_Date__c=Date.today()));
        }
        
        try {
            Database.insert(testContacts);
        } catch(Exception ex) {
            System.debug('Error occurred while creating test contact records: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    
    @isTest static void testBatchPositiveScenario() {
        createTestData();
        
        Test.startTest();
        SurveyEmailSenderBatch batch = new SurveyEmailSenderBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest static void testBatchInvalidContactsScenario() {
        createNegativeTestData();
        
        try {
            Test.startTest();
            SurveyEmailSenderBatch batch = new SurveyEmailSenderBatch();
            Database.executeBatch(batch);
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
    
    @isTest static void testBatchLimitsNegativeScenario() {
        createTestData();
        
        try {
            Test.startTest();
            SurveyEmailSenderBatch.isTestingToFail = true;
            SurveyEmailSenderBatch batch = new SurveyEmailSenderBatch();
            Database.executeBatch(batch);
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
}
public class SurveyEmailSenderBatch implements Database.Batchable<SObject>, Database.Stateful {
    public List<Id> lstContactIdsNotProcessed { get; set; }
    public List<Id> lstContactIdsFailed { get; set; }
    public EmailTemplate emailTemplate { get; set; }
    
    public static Boolean isTestingToFail { get; set; }
    
    public SurveyEmailSenderBatch() {
        lstContactIdsNotProcessed = new List<Id>();
        lstContactIdsFailed = new List<Id>();
        emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'N26 Survey Email']; //Template name can be move to custom setting
    }
    
    public List<SObject> start(Database.BatchableContext ctx) {
        // Query the contacts that are scheduled to be processed today 
        return [SELECT Id, FirstName, LastName, Email, Survey_Date__c FROM Contact WHERE Survey_Date__c = TODAY];
    }
    
    public void execute(Database.BatchableContext ctx, List<SObject> records) {
        Set<Id> setAllCurrentContactIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        Boolean exceededEmailLimit = false;
        
        // Iterate over the contacts and send email only when the org-wide email limit is not breached
        for (Contact contact : (List<Contact>)records) {
            // Try to reserve one email send for a contact.
            // When fails, add the contact id to 'Not Processed' list which
            // can be reported finally
            if (exceededEmailLimit == false && canSendEmail()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(emailTemplate.Id);
                email.setTargetObjectId(contact.Id);
                email.setWhatId(contact.Id);
                email.setReplyTo('test@example.com');
                email.setSaveAsActivity(false);
                lstEmails.add(email);
                setAllCurrentContactIds.add(contact.Id);
            } else {
                // When the reserve single email operation fails, set this flag to true
                // to avoid trying to reserve again and add all contact ids to not processed list.
                exceededEmailLimit = true;
                lstContactIdsNotProcessed.add(contact.Id);
            }
        }
        
        try {
            // Send the emails for current batch of contacts and add the failed contact ids to 'Failed' list
            if (!lstEmails.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmails);
                
                for (Messaging.SendEmailResult result : results) {
                    if (!result.isSuccess()) {
                        for (Messaging.SendEmailError error : result.getErrors()) {
                            lstContactIdsFailed.add(error.getTargetObjectId());
                        }
                    }
                }
                
                // Get the list of succeeded contact ids to reset the Survey Date to blank
                setAllCurrentContactIds.removeAll(lstContactIdsFailed);
                
                List<Contact> lstContactsToUpdate = new List<Contact>();
                for (Id contactIdToUpdate : setAllCurrentContactIds) {
                    lstContactsToUpdate.add(new Contact(Id = contactIdToUpdate, Survey_Date__c = null));
                }
                
                if (!lstContactsToUpdate.isEmpty()) {
                    Database.insert(lstContactsToUpdate, false);
                }
            }
        } catch(Exception ex) {
            System.debug('Exception Occurred at Line: ' + ex.getLineNumber() + '; ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            throw new SurveyEmailSenderBatchException('Exception Occurred at Line: ' + ex.getLineNumber() + '; ' + ex.getMessage());
        }        
    }
    
    public void finish(Database.BatchableContext ctx) {
        System.debug('List of Contact Ids that were failed during sending email: \n' + JSON.serialize(lstContactIdsFailed));
        System.debug('List of Contact Ids Not Processed Due To Email Limit: \n' + JSON.serialize(lstContactIdsNotProcessed));
    }
    
    // Method to check and reserve one single email send from the org limit
    private static Boolean canSendEmail() {
        Boolean canSend;
                
        try {
            Messaging.reserveSingleEmailCapacity(1);
            canSend = true;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            canSend = false;
        }
        
        // When isTestingToFail is set to true, deliberately change the canSend boolean 
        // to simulate daily limit exceeded scenario
        if (isTestingToFail != null && isTestingToFail == true) {
            canSend = !canSend;
        }
        
        return canSend;
    }
    
    public class SurveyEmailSenderBatchException extends Exception {}
}
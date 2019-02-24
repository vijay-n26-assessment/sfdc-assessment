# SFDC Assessment
Solution 1:
===========
ProductInformationComponent is a configurable lightning component that can reside in the case detail page. A new custom object 
(Product_Information__c) has been created to store the details of each product. This information is being queried based on the
contact fields as per the requirement. The configurability of this component lets users to add/remove any detail (a field) of
the product by just adding the new field to a field set in Product_Information__c object without having to edit the code.

Assumptions and Callouts:
1. The custom fields I have created in Contact are not read-only at the metadata level. I have made them read-only at the page layout level. I haven't included any of the page layouts in the source code.
2. To make the Language__c fallback to 'en', I have made it a required field and set 'en' as default value. No automation is built.

-------------------------------------------------------------------------------------------------------------------------------------

Solution 2:
===========
SurveyEmailSenderBatch allows to send emails in the localized language of each customer. The email limit has been handled with 
the help of Messaging.reserveSingleEmailCapacity() method. An exception will be thrown when the reserve action fails and this lets
us handle what should happen when the daily limit is exceeded. Currently, I am just compiling the list of failed record (errored 
out while sending email) and the not processed records (couldn't send email due to daily limit) and printed the lists finally 
before exiting the execution. 

Assumptions and Callouts:
1. The primary assumption is to send email via Apex code and not via others like workflow rules or process builder.
2. The errored out / not processed contacts will still have a past survey date. Currently, we can use reports to track them and
process them during subsequent runs.
3. I have just printed the list of failed or not processed contacts in the finish method.
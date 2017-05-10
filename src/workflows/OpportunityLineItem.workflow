<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Advertising_Alert_on_Deals</fullName>
        <description>Advertising Alert on Deals</description>
        <protected>false</protected>
        <recipients>
            <recipient>orlikr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>siponenp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>webbj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MarketingPAX/AlertDeals</template>
    </alerts>
    <alerts>
        <fullName>PAX_IS_Has_Reached_Contract_Stage_PM_Check</fullName>
        <ccEmails>siponenp@iata.org</ccEmails>
        <description>PAX IS Has Reached Contract Stage PM Check</description>
        <protected>false</protected>
        <recipients>
            <recipient>siponenp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MarketingPAX/PM_Alert_Contract_Stage_PAX_IS</template>
    </alerts>
    <fieldUpdates>
        <fullName>SP_Area</fullName>
        <field>SP_Area_Summary1__c</field>
        <formula>Product2.SP_Working_Groups__c</formula>
        <name>SP-Area</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SP_Areas</fullName>
        <field>SP_All_Areas__c</field>
        <formula>PricebookEntry.Product2.Name</formula>
        <name>SP-Areas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_RT_to_RCRM_Opportunity</fullName>
        <description>Set the Opportunity record type to &quot;RCRM Opportunity&quot;.</description>
        <field>RecordTypeId</field>
        <lookupValue>RCRM_Opportunity</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Opportunity RT to RCRM Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Advertising - Close Deal Notification</fullName>
        <actions>
            <name>Advertising_Alert_on_Deals</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alerts twhen a deal  has been closed for advertising</description>
        <formula>and(Opportunity.OwnerId = LastModifiedById  ,ispickval(Product2.Line_of_Business__c,  &apos;Advertising&apos;) ,Opportunity.IsWon = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Opportunity RT when RCRM Product added</fullName>
        <actions>
            <name>Set_Opportunity_RT_to_RCRM_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.RCRM_Product__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>RCRM Opportunity</value>
        </criteriaItems>
        <description>When a product from the RCRM project scope is added to an opportunity that has not the RCRM Opportunity record type, the opportunity&apos;s record type is changed to RCRM Opportunity.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ITDI - Close Deal VP Notification</fullName>
        <active>true</active>
        <description>Alerts the VP Human Resources when a deal over 10000 has been closed for ITDI</description>
        <formula>and(Opportunity.OwnerId = LastModifiedById  ,ispickval(Product2.Line_of_Business__c,  &apos;training&apos;) ,Opportunity.Amount &gt;=10000  ,Opportunity.IsWon = TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PAX IS Reaches Contract Stage</fullName>
        <actions>
            <name>PAX_IS_Has_Reached_Contract_Stage_PM_Check</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>and(ispickval(Product2.Family,  &apos;Pax IS&apos;) ,ispickval(Opportunity.StageName,  &apos;6. Contract stage&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SP</fullName>
        <actions>
            <name>SP_Area</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>equals</operation>
            <value>Strategic Partnerships</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

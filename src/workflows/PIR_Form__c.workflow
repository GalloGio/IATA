<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ISSP_PIR_Email_Airline_issuing</fullName>
        <description>&quot;Email Prorate Dept Airline issuing&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline issuing</description>
        <field>Email_Prorate_Dept_Airline_issuing__c</field>
        <formula>Airline_issuing__r.Email_Prorate__c</formula>
        <name>ISSP_PIR_Email_Airline_issuing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ISSP_PIR_Email_Airline_issuing</fullName>
        <actions>
            <name>ISSP_PIR_Email_Airline_issuing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>&quot;Email (Prorate Dept.) Airline issuing&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline issuing</description>
        <formula>NOT(ISBLANK(Airline_issuing__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

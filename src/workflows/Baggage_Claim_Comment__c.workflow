<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ISSP_PIR_New_PIR_Comment_by_issuer</fullName>
        <description>ISSP_PIR_New_PIR_Comment_by_issuer</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Prorate_Dept_Airline_receiving__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_PIR_New_PIR_Comment_by_issuer</template>
    </alerts>
    <alerts>
        <fullName>ISSP_PIR_New_PIR_Comment_by_receiver</fullName>
        <description>ISSP_PIR_New_PIR_Comment_by_receiver</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Prorate_Dept_Airline_issuing__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_PIR_New_PIR_Comment_by_receiver</template>
    </alerts>
    <fieldUpdates>
        <fullName>ISSP_PIR_Comment_Email_Airline_issuing</fullName>
        <description>&quot;Email (Prorate Dept.) Airline issuing&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline issuing
If Comment N° NOT Null</description>
        <field>Email_Prorate_Dept_Airline_issuing__c</field>
        <formula>Baggage_Claim__r.Parent_PIR_Form__r.Airline_issuing__r.Email_Prorate__c</formula>
        <name>ISSP_PIR_Comment_Email_Airline_issuing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_PIR_Comment_Email_Airline_receiving</fullName>
        <description>&quot;Email (Prorate Dept.) Airline receiving&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline receiving 
If Comment N° NOT Null</description>
        <field>Email_Prorate_Dept_Airline_receiving__c</field>
        <formula>Baggage_Claim__r.Airline_receiving__r.Email_Prorate__c</formula>
        <name>ISSP_PIR_Comment_Email_Airline_receiving</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ISSP_PIR_Comment_Email_Airline</fullName>
        <actions>
            <name>ISSP_PIR_Comment_Email_Airline_issuing</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ISSP_PIR_Comment_Email_Airline_receiving</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>&quot;Email (Prorate Dept.) Airline issuing&quot; field is populated with the Email (p) of the Account of the Airline issuing
&quot;Email (Prorate Dept.) Airline receiving&quot; field is populated with the Email (p) of the Account of the Airline receiving
CommentN°&lt;&gt;Null</description>
        <formula>NOT(ISBLANK( Name ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISSP_PIR_New_PIR_Comment_by_issuer</fullName>
        <actions>
            <name>ISSP_PIR_New_PIR_Comment_by_issuer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>(Baggage Proration). A new comment is created by an Airline issuer&apos;s prorate officer.
=&gt; an email is sent to the Airline Receiving</description>
        <formula>CASESAFEID(CreatedBy.Contact.AccountId)= Account_Issuing_Id__c &amp;&amp;  Baggage_Claim__r.Airline_receiving__r.Is_Email_Opt_in_Prorate__c = TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ISSP_PIR_New_PIR_Comment_by_receiver</fullName>
        <actions>
            <name>ISSP_PIR_New_PIR_Comment_by_receiver</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>(Baggage Proration). A new comment is created by an Airline receiver&apos;s prorate officer.
=&gt; an email is sent to the Airline Issuing</description>
        <formula>CASESAFEID(CreatedBy.Contact.AccountId) = Account_Receiving_Id__c &amp;&amp;  Baggage_Claim__r.Parent_PIR_Form__r.Airline_issuing__r.Is_Email_Opt_in_Prorate__c = TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

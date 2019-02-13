<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Change case status to Action Needed</fullName>
        <actions>
            <name>Change_case_status_to_Action_Needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 6 AND 4 AND (5 OR 7) AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>ref:</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>ref:</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated,Pending customer,Escalated Externally,Escalated Internally,In progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Cases - Europe,Complaint (IDFS ISS),Invoicing Collection Cases,FDS Ad-hoc Calendar Change (R&amp;S) Locked,Airline Coding Application</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.CcAddress</field>
            <operation>notEqual</operation>
            <value>info.americas@iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Generic Request Management</value>
        </criteriaItems>
        <description>Change case status to Action Needed when an incoming email is received to a case with status Pending Customer or Escalated Externally. Including extra criteria for info.americas@iata.org in CC.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>First Contact with Client</fullName>
        <actions>
            <name>First_contact_with_Client_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.First_Contact_with_Client__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.CreatedById</field>
            <operation>notEqual</operation>
            <value>IATA System</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Last Email sent</fullName>
        <actions>
            <name>IDFS_Last_Email_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,ACCA Customer Service Request (External),Cases - Africa &amp; Middle East,Cases - Americas,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Cases - Europe,Internal Cases (IDFS ISS),SAAM,SIDRA,SIDRA BR,Complaint (IDFS ISS),Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>notContain</operation>
            <value>iata.org,accelya,acca</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.CreatedById</field>
            <operation>notContain</operation>
            <value>system</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>First Contact with Client</fullName>
        <actions>
            <name>First_contact_with_Client_Now2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CaseComment.IsPublished</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.First_Contact_with_Client__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CaseComment.CreatedById</field>
            <operation>notEqual</operation>
            <value>IATA System</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Change case status to Action Needed</fullName>
        <actions>
            <name>ISSP_Case_Status_Action_Needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( CreatedById &lt;&gt;  Parent.OwnerId ,  not(Parent.IsClosed),  OR( 
Parent.RecordType.Name = &quot;Cases - Global&quot;,  
Parent.RecordType.Name = &quot;Cases - Europe&quot;,  Parent.RecordType.Name = &quot;Cases - Americas&quot;,  Parent.RecordType.Name = &quot;Cases - Africa &amp; Middle East&quot;,  Parent.RecordType.Name = &quot;Cases - Asia &amp; Pacific&quot;,  Parent.RecordType.Name = &quot;Cases - China &amp; North Asia&quot;,  Parent.RecordType.Name = &quot;Cases - SIS Help Desk&quot;,   Parent.RecordType.Name = &quot;Complaint (IDFS ISS)&quot;, Parent.RecordType.Name = &quot;Invoicing Collection Cases&quot;, Parent.RecordType.Name = &quot;Cases - IFG&quot; ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>

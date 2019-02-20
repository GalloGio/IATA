<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CSKC01_Message_with_big_attachment</fullName>
        <field>Attachment_received_possible_POP__c</field>
        <formula>now()</formula>
        <name>CSKC01 Message with (big) attachment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_case_status_to_Action_Needed</fullName>
        <field>Status</field>
        <literalValue>Action Needed</literalValue>
        <name>Case Status = Action Needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Changestatusofcase</fullName>
        <description>Change status of case when incoming email is received on a closed case.</description>
        <field>Status</field>
        <literalValue>Reopen</literalValue>
        <name>Case Status = Reopen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>First_contact_with_Client_Now</fullName>
        <description>Complaint process</description>
        <field>First_Contact_with_Client__c</field>
        <formula>now()</formula>
        <name>First contact with Client = Now()</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICCS_Set_New_Mail_Received</fullName>
        <description>Set the &quot;New Mail Received&quot; checkbox</description>
        <field>New_Mail_Received__c</field>
        <literalValue>1</literalValue>
        <name>ICCS Set New Mail Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_Last_Email_sent</fullName>
        <field>Last_Email_Sent__c</field>
        <formula>now()</formula>
        <name>IDFS Last Email sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Update_case_status_Action_Needed</fullName>
        <field>Status</field>
        <literalValue>Action Needed</literalValue>
        <name>IFAP - Update case status Action Needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_case_action_needed</fullName>
        <description>Change case status to action needed when email is bounced</description>
        <field>Status</field>
        <literalValue>Action Needed</literalValue>
        <name>IFAP case action needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_update_status_to_reopened</fullName>
        <description>Update the case status to Re-open/ed</description>
        <field>Status</field>
        <literalValue>Re-open/ed</literalValue>
        <name>IFAP update status to reopened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_update_to_initial_status</fullName>
        <field>Status</field>
        <literalValue>Agent Notified (Email)</literalValue>
        <name>IFAP update to initial status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invoicing_Mgt_Set_Reason_Debt_Recovery</fullName>
        <description>Set Reason automatically to Debt Recovery when email reaches issrevenue@iata.org</description>
        <field>Reason1__c</field>
        <literalValue>Debt Recovery</literalValue>
        <name>Invoicing Mgt Set Reason Debt Recovery</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invoicing_Mgt_Set_case_area_to_Invoicing</fullName>
        <description>Set case area automatically to Invoicing when email reaches issrevenue@iata.org</description>
        <field>CaseArea__c</field>
        <literalValue>Invoicing</literalValue>
        <name>Invoicing Mgt Set case area to Invoicing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_New_Email2</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Email</literalValue>
        <name>New interaction = New Email2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_New_Email_close2</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Email Closed case</literalValue>
        <name>New interaction = New Email close2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_New_email_comment2</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Email &amp; Comment</literalValue>
        <name>New interaction = New email &amp; comment2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reopencase_d_2</fullName>
        <field>Status</field>
        <literalValue>Re-opened</literalValue>
        <name>Re-open case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reopened_case_count</fullName>
        <description>adds 1 each time the case is reopened</description>
        <field>Reopened_case__c</field>
        <formula>Parent.Reopened_case__c + 1</formula>
        <name>Reopened case count</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_reopen_reason</fullName>
        <field>Reopening_reason__c</field>
        <name>Reset reopen reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SAAM_RPM_approval</fullName>
        <field>RPM_Approval__c</field>
        <formula>now()</formula>
        <name>SAAM RPM approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA</fullName>
        <field>SIDRA_email_content__c</field>
        <formula>IF(find(&quot;----- &quot;,TextBody)&gt; 1, IF(LEN(LEFT(TextBody,find(&quot;----- &quot;,TextBody)))&gt;31000,  &quot;From: &quot;&amp; FromAddress &amp; &quot;Content: &quot;&amp; LEFT(TextBody, 31000)&amp;&quot;*******************************************************email message cut, go to the record to access full content***************************************************&quot;, &quot;From: &quot;&amp; FromAddress &amp; &quot;Content: &quot;&amp; LEFT(TextBody,find(&quot;----- &quot;,TextBody)) ), IF(LEN(TextBody)&gt;31000,  &quot;From: &quot;&amp; FromAddress &amp; &quot; Content: &quot;&amp; LEFT(TextBody, 31000)&amp;&quot;*******************************************************email message cut, go to the record to access full content***************************************************&quot;, &quot;From: &quot;&amp; FromAddress &amp; &quot; Content: &quot;&amp; TextBody) )</formula>
        <name>SIDRA update Email content</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_completed_mail</fullName>
        <field>CS_pending_actions__c</field>
        <literalValue>Completed</literalValue>
        <name>SIDRA CS actions - completed mail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_update_CSemail</fullName>
        <field>CS_pending_actions__c</field>
        <literalValue>Check email received</literalValue>
        <name>SIDRA_update_CS_pending_email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_HD_New_email_action_needed</fullName>
        <field>Status</field>
        <literalValue>Action Needed</literalValue>
        <name>SIS HD - New email action needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Case_Has_Attachments</fullName>
        <field>Has_Attachments__c</field>
        <literalValue>1</literalValue>
        <name>SIS - Update Case Has Attachments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Has_Attachments_Case_field</fullName>
        <field>Has_Attachments__c</field>
        <literalValue>1</literalValue>
        <name>SIS - Update Has Attachments Case field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Approval_rejection_received</fullName>
        <description>Updated the Case Status with Approval/rejection received</description>
        <field>Status</field>
        <literalValue>Approval/rejection received</literalValue>
        <name>Status = Approval/rejection received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_New_Mail_Received</fullName>
        <description>Unchecks the New Mail Received</description>
        <field>New_Mail_Received__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck New Mail Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_New_Mail_Received</fullName>
        <description>Updates the field New Email when a new email arrives and the Case Status is not New or Open</description>
        <field>New_Mail_Received__c</field>
        <literalValue>1</literalValue>
        <name>Update New Mail Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Americas%3A Change case status to Reopen</fullName>
        <actions>
            <name>Changestatusofcase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(((1 AND 4) OR (4 AND 5)) AND (2 OR 3)) And 6</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>contains</operation>
            <value>info.americas@iata.org,bspcanada@iata.org,bomcs@iata.org,helpdeskau@iata.org,daccs@iata.org,jktcs@iata.org,tyocs@iata.org,kulcs@iata.org,bspnp@iata.org,khics@iata.org,mnlcs@iata.org,sincs@iata.org,cmb@iata.org,bkkcs@iata.org,sgncs@iata.org,selcs@iata.org</value>
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
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>contains</operation>
            <value>bsphdakl@iata.org,rssupport@iata.org,agysupport@iata.org,afosupport@iata.org,cussupport@iata.org,dpsupport@iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>cases - americas</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Status field with the value Reopen when an incoming email is received</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CSKC01 Message with %28big%29 attachment</fullName>
        <actions>
            <name>CSKC01_Message_with_big_attachment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.HasAttachment</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>notContain</operation>
            <value>iata,accelya,acca,amadeus</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.MessageSize</field>
            <operation>greaterThan</operation>
            <value>15000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Case_Group__c</field>
            <operation>equals</operation>
            <value>query</value>
        </criteriaItems>
        <description>marks the case as having an attachment in the emails bigger than a certain size (to avoid signatures etc)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
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
        <fullName>HO Invoicing Mgt - ISS revenue case area and reason</fullName>
        <actions>
            <name>Invoicing_Mgt_Set_Reason_Debt_Recovery</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Invoicing_Mgt_Set_case_area_to_Invoicing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - ISS Revenue Systems</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>Overdue invoice</value>
        </criteriaItems>
        <description>Rule created to set automatic case area and reason when query arrives to issrevenue@iata.org</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ICCS Set New Mail Received</fullName>
        <actions>
            <name>ICCS_Set_New_Mail_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Product Management,FDS ICCS CitiDirect User Access Management,FDS ICCS Bank Account Management,FDS ASP Management,FDS ICCS Email-to-Case</value>
        </criteriaItems>
        <description>Set the &quot;New Mail Received&quot; checkbox when a new email message is received on an ICCS case after its closure.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Case Reopening workflow</fullName>
        <actions>
            <name>Reopencase_d_2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reopened_case_count</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>case gets reopened when an email enters the case</description>
        <formula>AND(  OR( Parent.RecordType.DeveloperName == &apos;External_Cases_ACCA&apos;, Parent.RecordType.DeveloperName == &apos;CS_Process_IDFS_ISS&apos;, Parent.RecordType.DeveloperName == &apos;SEDA&apos;, Parent.RecordType.DeveloperName == &apos;Invoicing_Collection_Cases&apos;, Parent.RecordType.DeveloperName == &apos;FDS_ICCS_Email_to_Case&apos;, Parent.RecordType.DeveloperName == &apos;SIDRA&apos;,  AND(OR( Parent.RecordType.DeveloperName == &apos;CasesAmericas&apos;, Parent.RecordType.DeveloperName == &apos;CasesMENA&apos;, Parent.RecordType.DeveloperName == &apos;Cases_China_North_Asia&apos;, Parent.RecordType.DeveloperName == &apos;CasesEurope&apos;, 
Parent.RecordType.DeveloperName == &apos;Cases_Global&apos;, Parent.RecordType.DeveloperName == &apos;ExternalCasesIDFSglobal&apos;, Parent.RecordType.DeveloperName == &apos;ComplaintIDFS&apos;), DATEVALUE(Parent.ClosedDate) &gt; TODAY()-14)),  OR( NOT(CONTAINS(FromAddress,&quot;acca&quot;)), NOT(CONTAINS(FromAddress,&quot;accelya&quot;)) ),  OR( CONTAINS(HtmlBody,&quot;ref:&quot;), CONTAINS(Subject,&quot;ref:&quot;), CONTAINS(TextBody,&quot;ref:&quot;) ),  Incoming=TRUE, Parent.IsClosed=TRUE )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Complaint First contact with client</fullName>
        <actions>
            <name>First_contact_with_Client_Now</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND (6 OR 8) AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Complaint_Opened_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>notContain</operation>
            <value>iata.org</value>
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
        <criteriaItems>
            <field>Case.First_Contact_w_Client_in_Business_Hours__c</field>
            <operation>lessThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>set the first contact with client after complaint logged automatically</description>
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
    <rules>
        <fullName>IDFS_Interactions tracking - New email</fullName>
        <actions>
            <name>New_interaction_New_Email2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( Parent.IsClosed = FALSE, CreatedDate &gt; Parent.CreatedDate , Incoming = TRUE , OR ( AND ( Parent.RecordType.DeveloperName = &quot;SIDRA&quot;, NOT(ISNULL(Parent.Update_AIMS_DEF__c)) ), AND ( Parent.RecordType.DeveloperName = &quot;IATA_Financial_Review&quot;, FromAddress &lt;&gt; &quot;noreply.ifap@iata.org&quot; ), Parent.RecordType.DeveloperName = &quot;ProcessEuropeSCE&quot;, Parent.RecordType.DeveloperName = &quot;SIDRA_Lite&quot;, Parent.RecordType.DeveloperName = &quot;CS_Process_IDFS_ISS&quot;, Parent.RecordType.DeveloperName = &quot;OSCAR_Communication&quot;, Parent.RecordType.DeveloperName = &quot;InternalCasesEuropeSCE&quot;, Parent.RecordType.DeveloperName = &quot;IDFS_Airline_Participation_Process&quot;,Parent.RecordType.DeveloperName = &quot;FDS_ASP_Management&quot;, Parent.RecordType.DeveloperName =&apos;Airline_Coding_Application&apos;, AND ( Parent.RecordType.DeveloperName = &quot;ID_Card_Application&quot;, FromAddress &lt;&gt; &quot;iataglobalidcardprogram@iata.org&quot;, Subject &lt;&gt; &quot;Confirmation IATA/IATAN ID Card Renewal Application&quot;, Subject &lt;&gt; &quot;Confirmation IATA/IATAN ID Card New Application&quot;, Subject &lt;&gt; &quot;Confirmation IATA/IATAN ID Card Replacement Application&quot;, Subject &lt;&gt; &quot;Confirmation IATA/IATAN ID Card Reissue Application&quot; ) ), NOT(ISPICKVAL(Parent.New_interaction__c ,&quot;New Email &amp; Comment&quot;)), NOT(ISPICKVAL(Parent.New_interaction__c ,&quot;New Comment&quot;)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_Interactions tracking - New email closed</fullName>
        <actions>
            <name>New_interaction_New_Email_close2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 3 AND 4 and 2 and 5</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS),SAAM,New Process (IDFS ISS),IDFS Airline Participation Process,IATA Financial Review,ID Card Application,SIDRA Lite,OSCAR Communication,Airline Coding Application</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.New_interaction__c</field>
            <operation>notEqual</operation>
            <value>New Email &amp; Comment,New Comment</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>notEqual</operation>
            <value>noreply.ifap@iata.org</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_Interactions tracking - New email comment</fullName>
        <actions>
            <name>New_interaction_New_email_comment2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 3 AND 4  and (2 or (5 and 6))</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS),SAAM,New Process (IDFS ISS),IDFS Airline Participation Process,SEDA,IATA Financial Review,ID Card Application,SIDRA Lite,OSCAR Communication</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.New_interaction__c</field>
            <operation>equals</operation>
            <value>New Comment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DOP03_New Email in case</fullName>
        <actions>
            <name>SIDRA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_update_CSemail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>notContain</operation>
            <value>qms,accelya,acca,infofax,baissonm</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>notEqual</operation>
            <value>Europe,Africa &amp; Middle East,Asia &amp; Pacific</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DOP03_New Email in case_Europe AME</fullName>
        <actions>
            <name>SIDRA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_update_CSemail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND (5 OR 6 OR 7 OR 8)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>notContain</operation>
            <value>qms,accelya,acca,infoe.es</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>notContain</operation>
            <value>Fax [ref:</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>greaterThan</operation>
            <value>YESTERDAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>cases</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>SIDRA for all regions</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DOP06 Contact customer - CS actions completed</fullName>
        <actions>
            <name>SIDRA_CS_actions_completed_mail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_pending_actions__c</field>
            <operation>equals</operation>
            <value>Provide feedback to agent,Check email received</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>notContain</operation>
            <value>iata,acca,accelya,amadeus</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent,Replied</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>contains</operation>
            <value>CS</value>
        </criteriaItems>
        <description>set the CS actions pending to completed when an email is sent out of iata, dpc etc</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP - Update case status Action Needed for bounced emails</fullName>
        <actions>
            <name>IFAP_Update_case_status_Action_Needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR (5 AND 6)) AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>not be delivered</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>mailer-daemon@salesforce.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>not be delivered</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>notContain</operation>
            <value>full</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Financial Security Requested,Agent Notified (Email)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP change status on initial Reminder</fullName>
        <actions>
            <name>IFAP_update_to_initial_status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND ( 6 OR 7 OR 8) AND 9</booleanFilter>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Submitted_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assessment_Performed_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Deadline_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Agent to be Notified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Agent Notified (Mail)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Agent Notified (Email)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Sanity_Check_Failure_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>change status to &apos;Agent Notified (Email)&apos; if the a manual &apos;	
Request an agent to upload Financial Documents&apos; is sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP invalid email addresses</fullName>
        <actions>
            <name>IFAP_case_action_needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND ((2 AND 3 AND 7) OR (4 AND 5 AND 8)) AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>failed</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>notContain</operation>
            <value>full</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>failed</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>notContain</operation>
            <value>full</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Financial Security Requested,Agent Notified (Email)</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>could not be delivered</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>could not be delivered</value>
        </criteriaItems>
        <description>Bounce email: for invalid email addresses - status should immediately be changed to ACTION NEEDED in case its not a mailbox full bounce</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP_Reopen_closed_case</fullName>
        <actions>
            <name>IFAP_update_status_to_reopened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <description>Reopen a closed case on email reception</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SAAM RPM approval</fullName>
        <actions>
            <name>SAAM_RPM_approval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>startsWith</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SAAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>Accreditation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ACC_Process_Type__c</field>
            <operation>equals</operation>
            <value>Long 50d,Medium 20d</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>equals</operation>
            <value>mulai@iata.org,sanchezc@iata.org,dovgano@iata.org,martinyuks@iata.org</value>
        </criteriaItems>
        <description>KC01</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS - Update Has Attachments Case</fullName>
        <actions>
            <name>SIS_Update_Case_Has_Attachments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HasAttachment</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIS HD - New Email Message</fullName>
        <actions>
            <name>SIS_HD_New_email_action_needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update field when new email arrives</fullName>
        <actions>
            <name>Update_New_Mail_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>New,Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Updates field when new email arrives.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update field when new email is read</fullName>
        <actions>
            <name>Uncheck_New_Mail_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>New,Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>Sent,Read,Forwarded,Replied</value>
        </criteriaItems>
        <description>Updates field when new email is read</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>test anita</fullName>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>contains</operation>
            <value>kaleconsultants.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

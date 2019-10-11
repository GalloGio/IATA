<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ISSP_PIR_D_X_Alert_vs_60Days</fullName>
        <description>ISSP_PIR_D-X_Alert_vs_60Days</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Prorate_Dept_Airline_receiving__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_PIR_XDays_before_60Day_Limit</template>
    </alerts>
    <fieldUpdates>
        <fullName>ISSP_PIR_Claim_Email_Airline_issuing</fullName>
        <description>&quot;Email (Prorate Dept.) Airline issuing&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline issuing
If Baggage Claim N° NOT Null</description>
        <field>Email_Prorate_Dept_Airline_issuing__c</field>
        <formula>Parent_PIR_Form__r.Airline_issuing__r.Email_Prorate__c</formula>
        <name>ISSP_PIR_Claim_Email_Airline_issuing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_PIR_Date_Proceed_Payment</fullName>
        <description>Updates the &quot;Date/Time Proceed to payment&quot; field with the date at which the Prorate Request status is passed to &quot;Proceed to payment&quot;</description>
        <field>Date_Time_Proceed_to_payment__c</field>
        <formula>NOW()</formula>
        <name>ISSP_PIR_Date_Proceed_Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_PIR_Date_Proceed_Payment_Empty</fullName>
        <description>Empties the &quot;Date/Time Proceed to payment&quot; field if the Prorate Request status is NOT equal to &quot;Proceed to payment&quot;</description>
        <field>Date_Time_Proceed_to_payment__c</field>
        <name>ISSP_PIR_Date_Proceed_Payment_Empty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_PIR_Email_Airline_receiving</fullName>
        <description>&quot;Email (Prorate Dept.) Airline receiving&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline receiving 
If Baggage Claim N° NOT Null</description>
        <field>Email_Prorate_Dept_Airline_receiving__c</field>
        <formula>Airline_receiving__r.Email_Prorate__c</formula>
        <name>ISSP_PIR_Email_Airline_receiving</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_PIR_Status_Proceed_to_Payment</fullName>
        <description>In a &quot;Prorate Request&quot;, the Status is automatically passed to &quot;Proceed to payment&quot;</description>
        <field>Status__c</field>
        <literalValue>Proceed to payment</literalValue>
        <name>ISSP_PIR_Status_Proceed_to_Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ISSP_PIR_Alert%2BStatus on ISSUER%27s Comment Date</fullName>
        <active>true</active>
        <description>&quot;Open&quot; ProrateRequests:
Last comment made by: ISSUER (OR only the ISSUER commented and No reply from Receiver)
Emails sent to receiver based on: ISSUER’s last comment Date
Status passed to “Proceed to payment” 60 days after: ISSUER’s last comment Date</description>
        <formula>AND   (     ISPICKVAL(Status__c, &quot;Open&quot;),    Airline_receiving__r.Is_Email_Opt_in_Prorate__c  = TRUE,    OR(       (Tech_Last_Comment_Issuing_Date_Time__c &gt; Tech_Last_Comment_Receiving_Date_Time__c ),        AND(            NOT(ISBLANK(Tech_Last_Comment_Issuing_Date_Time__c)),            ISBLANK(Tech_Last_Comment_Receiving_Date_Time__c)            )       )    )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_D_X_Alert_vs_60Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Issuing_Date_Time__c</offsetFromField>
            <timeLength>53</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_Status_Proceed_to_Payment</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Issuing_Date_Time__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_D_X_Alert_vs_60Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Issuing_Date_Time__c</offsetFromField>
            <timeLength>46</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_D_X_Alert_vs_60Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Issuing_Date_Time__c</offsetFromField>
            <timeLength>57</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ISSP_PIR_Alert%2BStatus on RECEIVER%27s Comment Date</fullName>
        <active>true</active>
        <description>&quot;Open&quot; Prorate Requests:
Last comment made by: Receiver
Emails sent to receiver based on: Receiver’s last comment Date
Email sent if Account Receiver&apos;s Email Opt-in=TRUE
Status passed to “Proceed to payment” 60 days after: Receiver’s last comment Date</description>
        <formula>AND(       ISPICKVAL(Status__c, &quot;Open&quot;),     Airline_receiving__r.Is_Email_Opt_in_Prorate__c = TRUE,     (Tech_Last_Comment_Issuing_Date_Time__c  &lt; Tech_Last_Comment_Receiving_Date_Time__c ),      NOT(ISBLANK(Tech_Last_Comment_Issuing_Date_Time__c)),      NOT(ISBLANK(Tech_Last_Comment_Receiving_Date_Time__c))     )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_D_X_Alert_vs_60Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Receiving_Date_Time__c</offsetFromField>
            <timeLength>57</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_D_X_Alert_vs_60Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Receiving_Date_Time__c</offsetFromField>
            <timeLength>53</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_Status_Proceed_to_Payment</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Receiving_Date_Time__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_PIR_D_X_Alert_vs_60Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Baggage_Claim__c.Tech_Last_Comment_Receiving_Date_Time__c</offsetFromField>
            <timeLength>46</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ISSP_PIR_Date_Proceed_Payment</fullName>
        <actions>
            <name>ISSP_PIR_Date_Proceed_Payment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Baggage_Claim__c.Status__c</field>
            <operation>equals</operation>
            <value>Proceed to payment</value>
        </criteriaItems>
        <description>Updates the &quot;Date/Time Proceed to payment&quot; field with the date at which the Prorate Request status is passed to &quot;Proceed to payment&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP_PIR_Date_Proceed_Payment_Empty</fullName>
        <actions>
            <name>ISSP_PIR_Date_Proceed_Payment_Empty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Baggage_Claim__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Proceed to payment</value>
        </criteriaItems>
        <description>Empties the &quot;Date/Time Proceed to payment&quot; field if the Prorate Request status is NOT equal to &quot;Proceed to payment&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP_PIR_Prorate_Request_Email_Airline</fullName>
        <actions>
            <name>ISSP_PIR_Claim_Email_Airline_issuing</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ISSP_PIR_Email_Airline_receiving</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>&quot;Email (ProrateDept.) Airline issuing&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline issuing
&quot;Email (ProrateDept.) Airline receiving&quot; field is populated with the &quot;Email (p)&quot; of the Account of the Airline receiving
RequestN°&lt;&gt;Null</description>
        <formula>NOT(ISBLANK( Name ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

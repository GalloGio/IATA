<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ALWG_LCAG_C_send_notification_to_meeting_owner_that_Legal_has_signed_off_agenda</fullName>
        <description>ALWG/LCAG-C - send notification to meeting owner that Legal has signed off agenda</description>
        <protected>false</protected>
        <recipients>
            <recipient>reckmannr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_signed_off_ALWG_LCAG_C_Agenda</template>
    </alerts>
    <alerts>
        <fullName>ALWG_LCAG_C_send_notification_to_meeting_owner_that_Legal_has_signed_off_minutes</fullName>
        <description>ALWG/LCAG-C - send notification to meeting owner that Legal has signed off minutes</description>
        <protected>false</protected>
        <recipients>
            <recipient>reckmannr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_signed_off_ALWG_LCAG_C_Minutes</template>
    </alerts>
    <alerts>
        <fullName>ALWG_LCAG_C_send_notification_when_agenda_is_uploaded</fullName>
        <description>ALWG/LCAG-C - send notification when agenda is uploaded</description>
        <protected>false</protected>
        <recipients>
            <recipient>LG_meeting_alerts</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>reckmannr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Notification_of_ALWG_LCAG_C_Agenda_upload</template>
    </alerts>
    <alerts>
        <fullName>ALWG_LCAG_C_send_notification_when_minutes_are_uploaded</fullName>
        <description>ALWG/LCAG-C - send notification when minutes are uploaded</description>
        <protected>false</protected>
        <recipients>
            <recipient>LG_meeting_alerts</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>reckmannr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Notification_of_ALWG_LCAG_C_Minutes_upload</template>
    </alerts>
    <alerts>
        <fullName>ALWG_LCAG_C_send_request_to_Legal_for_them_to_sign_off_agenda</fullName>
        <description>ALWG/LCAG-C - send request to Legal for them to sign off agenda</description>
        <protected>false</protected>
        <recipients>
            <recipient>torneroc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Request_for_Legal_to_sign_off_ALWG_LCAG_C_Agenda</template>
    </alerts>
    <alerts>
        <fullName>ALWG_LCAG_C_send_request_to_Legal_for_them_to_sign_off_minutes</fullName>
        <description>ALWG/LCAG-C - send request to Legal for them to sign off minutes</description>
        <protected>false</protected>
        <recipients>
            <recipient>torneroc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Request_for_Legal_to_sign_off_ALWG_LCAG_C_Minutes</template>
    </alerts>
    <alerts>
        <fullName>ALWG_send_notification_to_meeting_owner_that_Legal_has_rejected_the_agenda</fullName>
        <description>ALWG - send notification to meeting owner that Legal has rejected the agenda</description>
        <protected>false</protected>
        <recipients>
            <recipient>reckmannr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_rejected_the_Agenda</template>
    </alerts>
    <alerts>
        <fullName>ALWG_send_notification_to_meeting_owner_that_Legal_has_rejected_the_minutes</fullName>
        <description>ALWG - send notification to meeting owner that Legal has rejected the minutes</description>
        <protected>false</protected>
        <recipients>
            <recipient>reckmannr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_rejected_the_Minutes</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_notification_to_meeting_owner_that_Legal_has_rejected_the_agenda</fullName>
        <description>APJC - send notification to meeting owner that Legal has rejected the agenda</description>
        <protected>false</protected>
        <recipients>
            <recipient>alvarengam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wana@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_rejected_the_Agenda</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_notification_to_meeting_owner_that_Legal_has_rejected_the_minutes</fullName>
        <description>APJC - send notification to meeting owner that Legal has rejected the minutes</description>
        <protected>false</protected>
        <recipients>
            <recipient>alvarengam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wana@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_rejected_the_Minutes</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_notification_to_meeting_owner_that_Legal_has_signed_off_APJC_agenda</fullName>
        <description>APJC - send notification to meeting owner that Legal has signed off APJC agenda</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_signed_off_APJC_Agenda</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_notification_to_meeting_owner_that_Legal_has_signed_off_APJC_minutes</fullName>
        <description>APJC - send notification to meeting owner that Legal has signed off APJC minutes</description>
        <protected>false</protected>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Legal_has_signed_off_APJC_Minutes</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_notification_when_APJC_agenda_is_uploaded</fullName>
        <description>APJC - send notification when APJC agenda is uploaded</description>
        <protected>false</protected>
        <recipients>
            <recipient>LG_meeting_alerts</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>alvarengam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tan-torrj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wana@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Notification_of_APJC_Agenda_upload</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_notification_when_APJC_minutes_are_uploaded</fullName>
        <description>APJC - send notification when APJC minutes are uploaded</description>
        <protected>false</protected>
        <recipients>
            <recipient>LG_meeting_alerts</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>alvarengam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tan-torrj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wana@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Notification_of_APJC_Minutes_upload</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_request_to_Legal_for_them_to_sign_off_APJC_agenda</fullName>
        <description>APJC - send request to Legal for them to sign off APJC agenda</description>
        <protected>false</protected>
        <recipients>
            <recipient>lugol@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Request_for_Legal_to_sign_off_APJC_Agenda</template>
    </alerts>
    <alerts>
        <fullName>APJC_send_request_to_Legal_for_them_to_sign_off_APJC_minutes</fullName>
        <description>APJC - send request to Legal for them to sign off APJC minutes</description>
        <protected>false</protected>
        <recipients>
            <recipient>lugol@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Meeting_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Local_Governance/Request_for_Legal_to_sign_off_APJC_Minutes</template>
    </alerts>
    <rules>
        <fullName>ALWG - Notification that Agenda have been rejected</fullName>
        <actions>
            <name>ALWG_send_notification_to_meeting_owner_that_Legal_has_rejected_the_agenda</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_REJECTED_the_agenda__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has rejected the Agenda. Used for IDFS ISS.
CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ALWG - Notification that Minutes have been rejected</fullName>
        <actions>
            <name>ALWG_send_notification_to_meeting_owner_that_Legal_has_rejected_the_minutes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_REJECTED_the_minutes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has rejected the minutes. Used for IDFS ISS.
CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ALWG%2FLCAG-C%2FCEC%2FICAP - Notification that Agenda have been signed off</fullName>
        <actions>
            <name>ALWG_LCAG_C_send_notification_to_meeting_owner_that_Legal_has_signed_off_agenda</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_off_Agenda__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has signed off the Agenda. Used for IDFS ISS.
CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ALWG%2FLCAG-C%2FCEC%2FICAP - Notification that Minutes have been signed off</fullName>
        <actions>
            <name>ALWG_LCAG_C_send_notification_to_meeting_owner_that_Legal_has_signed_off_minutes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_Off_the_Minutes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has signed off the Minutes. Used for IDFS ISS.
CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ALWG%2FLCAG-C%2FCEC%2FICAP - Request for Legal to sign off Agenda</fullName>
        <actions>
            <name>ALWG_LCAG_C_send_notification_when_agenda_is_uploaded</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ALWG_LCAG_C_send_request_to_Legal_for_them_to_sign_off_agenda</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Requested_to_Sign_off_Agenda__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</value>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_off_Agenda__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Request for legal to sign off agenda. Used for IDFS ISS.
CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ALWG%2FLCAG-C%2FCEC%2FICAP - Request for Legal to sign off Minutes</fullName>
        <actions>
            <name>ALWG_LCAG_C_send_notification_when_minutes_are_uploaded</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ALWG_LCAG_C_send_request_to_Legal_for_them_to_sign_off_minutes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Requested_to_Sign_Off_Minutes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</value>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_Off_the_Minutes__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Request for legal to sign off minutes. Used for IDFS ISS.
CAPJC,CGA,CEC,ICAP,LCAG-C,CCC</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>APJC - Notification that Agenda have been rejected</fullName>
        <actions>
            <name>APJC_send_notification_to_meeting_owner_that_Legal_has_rejected_the_agenda</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_REJECTED_the_agenda__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>APJC,APJC / FAG,JALWG,LCAG-P,LCAG-P / Credit Card WG</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has rejected the Agenda. Used for IDFS ISS.
APJC, APJC / FAG, JALWG, LCAG-P, LCAG-P / Credit Card WG</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>APJC - Notification that Minutes have been rejected</fullName>
        <actions>
            <name>APJC_send_notification_to_meeting_owner_that_Legal_has_rejected_the_minutes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_REJECTED_the_minutes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>APJC,APJC / FAG,JALWG,LCAG-P,LCAG-P / Credit Card WG</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has rejected the minutes. Used for IDFS ISS.
APJC, APJC / FAG, JALWG, LCAG-P, LCAG-P / Credit Card WG</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>APJC%2FJALWG%2FLCAG-P - Notification that Agenda have been signed off</fullName>
        <actions>
            <name>APJC_send_notification_to_meeting_owner_that_Legal_has_signed_off_APJC_agenda</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_off_Agenda__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>APJC,APJC / FAG,JALWG,LCAG-P,LCAG-P / Credit Card WG</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has signed off the agenda. Used for IDFS ISS.
APJC, APJC / FAG, JALWG, LCAG-P, LCAG-P / Credit Card WG</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>APJC%2FJALWG%2FLCAG-P - Notification that Minutes have been signed off</fullName>
        <actions>
            <name>APJC_send_notification_to_meeting_owner_that_Legal_has_signed_off_APJC_minutes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_Off_the_Minutes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>APJC,APJC / FAG,JALWG,LCAG-P,LCAG-P / Credit Card WG</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Notification that Legal has signed off the Minutes. Used for IDFS ISS.
APJC, APJC / FAG, JALWG, LCAG-P, LCAG-P / Credit Card WG</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>APJC%2FJALWG%2FLCAG-P - Request for Legal to sign off Agenda</fullName>
        <actions>
            <name>APJC_send_notification_when_APJC_agenda_is_uploaded</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>APJC_send_request_to_Legal_for_them_to_sign_off_APJC_agenda</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Requested_to_Sign_off_Agenda__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>APJC,APJC / FAG,JALWG,LCAG-P,LCAG-P / Credit Card WG</value>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_off_Agenda__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Request for legal to sign off APJC agenda. Used for IDFS ISS.
APJC, APJC / FAG, JALWG, LCAG-P, LCAG-P / Credit Card WG</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>APJC%2FJALWG%2FLCAG-P - Request for Legal to sign off Minutes</fullName>
        <actions>
            <name>APJC_send_notification_when_APJC_minutes_are_uploaded</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>APJC_send_request_to_Legal_for_them_to_sign_off_APJC_minutes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Requested_to_Sign_Off_Minutes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.Local_Governance_type__c</field>
            <operation>equals</operation>
            <value>APJC,APJC / FAG,JALWG,LCAG-P,LCAG-P / Credit Card WG</value>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance_Meeting__c.Date_Legal_Signed_Off_the_Minutes__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>notEqual</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <description>Request for legal to sign off APJC, APJC / FAG, JALWG, LCAG-P, LCAG-P / Credit Card WG minutes. Used for IDFS ISS.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

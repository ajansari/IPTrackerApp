namespace DSW.IPTracking;

page 80315 "ipt IP App API"
{
    PageType = API;
    Caption = 'IP App API';
    APIPublisher = 'dsw';
    APIGroup = 'iptIpManagement';
    APIVersion = 'v1.0';
    EntityName = 'iptIPApp';
    EntitySetName = 'iptIPApps';
    SourceTable = "ipt IP App";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(code; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(description; Rec."Description")
                {
                    Caption = 'Description';
                }
                field(licenseType; Rec."License Type")
                {
                    Caption = 'License Type';
                }
                field(other; Rec."Other")
                {
                    Caption = 'Other';
                }
                field(defaultBillingPeriod; Rec."Default Billing Period")
                {
                    Caption = 'Default Billing Period';
                }
                field(defaultEditionCode; Rec."Default Edition Code")
                {
                    Caption = 'Default Edition Code';
                }
                field(editionCount; Rec."Edition Count")
                {
                    Caption = 'Edition Count';
                    Editable = false;
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System Id';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    Editable = false;
                }
            }
        }
    }
}

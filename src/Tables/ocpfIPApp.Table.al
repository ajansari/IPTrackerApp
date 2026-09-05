namespace OnlyCopilotFans.IPTracking;

using Microsoft.Inventory.Item;

table 80303 "ocpf IP App"
{
    Caption = 'IP App';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf IP Apps";
    DrillDownPageId = "ocpf IP Apps";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(3; "License Type"; Enum "ocpf IP License Type")
        {
            Caption = 'License Type';
        }
        field(4; "Other"; Text[80])
        {
            Caption = 'Other';
        }
        field(5; "Default Billing Period"; Enum "ocpf IP Billing Period")
        {
            Caption = 'Default Billing Period';
        }
        field(6; "Default Edition Code"; Code[10])
        {
            Caption = 'Default Edition Code';
            TableRelation = "ocpf IP App Edition"."Edition Code" where("IP App Code" = field("Code"));
        }
        field(10; "Edition Count"; Integer)
        {
            Caption = 'Edition Count';
            FieldClass = FlowField;
            CalcFormula = count("ocpf IP App Edition" where("IP App Code" = field("Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        IPAppEdition: Record "ocpf IP App Edition";
        IPAppPrice: Record "ocpf IP App Price";
        IPEntitlement: Record "ocpf IP Entitlement";
        Item: Record Item;
        CannotDeleteErr: Label 'You cannot delete IP App %1 because related editions, prices, entitlements or items exist.', Comment = '%1 = IP App Code';
    begin
        IPAppEdition.SetRange("IP App Code", Rec."Code");
        IPAppPrice.SetRange("IP App Code", Rec."Code");
        IPEntitlement.SetRange("IP App Code", Rec."Code");
        Item.SetRange("IP App", Rec."Code");
        if not IPAppEdition.IsEmpty() or not IPAppPrice.IsEmpty() or not IPEntitlement.IsEmpty() or not Item.IsEmpty() then
            Error(CannotDeleteErr, Rec."Code");
    end;
}

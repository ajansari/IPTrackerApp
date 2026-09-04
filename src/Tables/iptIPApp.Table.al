namespace DSW.IPTracking;

table 80303 "ipt IP App"
{
    Caption = 'IP App';
    DataClassification = CustomerContent;
    LookupPageId = "ipt IP Apps";
    DrillDownPageId = "ipt IP Apps";

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
        field(3; "License Type"; Enum "ipt IP License Type")
        {
            Caption = 'License Type';
        }
        field(4; "Other"; Text[80])
        {
            Caption = 'Other';
        }
        field(5; "Default Billing Period"; Enum "ipt IP Billing Period")
        {
            Caption = 'Default Billing Period';
        }
        field(6; "Default Edition Code"; Code[10])
        {
            Caption = 'Default Edition Code';
            TableRelation = "ipt IP App Edition"."Edition Code" where("IP App Code" = field("Code"));
        }
        field(10; "Edition Count"; Integer)
        {
            Caption = 'Edition Count';
            FieldClass = FlowField;
            CalcFormula = count("ipt IP App Edition" where("IP App Code" = field("Code")));
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
        IPAppEdition: Record "ipt IP App Edition";
        IPAppPrice: Record "ipt IP App Price";
        IPEntitlement: Record "ipt IP Entitlement";
        CannotDeleteErr: Label 'You cannot delete IP App %1 because related editions, prices or entitlements exist.', Comment = '%1 = IP App Code';
    begin
        IPAppEdition.SetRange("IP App Code", Rec."Code");
        IPAppPrice.SetRange("IP App Code", Rec."Code");
        IPEntitlement.SetRange("IP App Code", Rec."Code");
        if not IPAppEdition.IsEmpty() or not IPAppPrice.IsEmpty() or not IPEntitlement.IsEmpty() then
            Error(CannotDeleteErr, Rec."Code");
    end;
}

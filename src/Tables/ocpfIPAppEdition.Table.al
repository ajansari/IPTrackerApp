namespace OnlyCopilotFans.IPTracking;

table 80304 "ocpf IP App Edition"
{
    Caption = 'IP App Edition';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf IP App Editions";
    DrillDownPageId = "ocpf IP App Editions";

    fields
    {
        field(1; "IP App Code"; Code[10])
        {
            Caption = 'IP App Code';
            NotBlank = true;
            TableRelation = "ocpf IP App"."Code";
        }
        field(2; "Edition Code"; Code[10])
        {
            Caption = 'Edition Code';
            NotBlank = true;
        }
        field(3; "Description"; Text[80])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; "IP App Code", "Edition Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        IPAppPrice: Record "ocpf IP App Price";
        IPEntitlement: Record "ocpf IP Entitlement";
        CannotDeleteErr: Label 'You cannot delete Edition %1 %2 because related prices or entitlements exist.', Comment = '%1 = IP App Code, %2 = Edition Code';
    begin
        IPAppPrice.SetRange("IP App Code", Rec."IP App Code");
        IPAppPrice.SetRange("Edition Code", Rec."Edition Code");
        IPEntitlement.SetRange("IP App Code", Rec."IP App Code");
        IPEntitlement.SetRange("Edition Code", Rec."Edition Code");
        if not IPAppPrice.IsEmpty() or not IPEntitlement.IsEmpty() then
            Error(CannotDeleteErr, Rec."IP App Code", Rec."Edition Code");
    end;
}

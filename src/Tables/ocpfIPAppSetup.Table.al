namespace OnlyCopilotFans.IPTracking;

using Microsoft.Foundation.NoSeries;

table 80319 "ocpf IP App Setup"
{
    Caption = 'IP App Setup';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf IP App Setup";
    DrillDownPageId = "ocpf IP App Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "IP Entitlement Nos."; Code[20])
        {
            Caption = 'IP Entitlement Nos.';
            TableRelation = "No. Series".Code;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        CannotDeleteErr: Label 'You cannot delete the IP App Setup record.';
    begin
        Error(CannotDeleteErr);
    end;
}

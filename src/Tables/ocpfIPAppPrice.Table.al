namespace OnlyCopilotFans.IPTracking;

using Microsoft.Finance.Currency;

table 80305 "ocpf IP App Price"
{
    Caption = 'IP App Price';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf IP App Prices";
    DrillDownPageId = "ocpf IP App Prices";

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
            TableRelation = "ocpf IP App Edition"."Edition Code" where("IP App Code" = field("IP App Code"));
        }
        field(3; "Billing Period"; Enum "ocpf IP Billing Period")
        {
            Caption = 'Billing Period';
        }
        field(4; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency.Code;
        }
        field(5; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "IP App Code", "Edition Code", "Billing Period", "Currency Code")
        {
            Clustered = true;
        }
    }
}

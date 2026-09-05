namespace OnlyCopilotFans.IPTracking;

using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Customer;

table 80306 "ocpf IP Entitlement"
{
    Caption = 'IP Entitlement';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf IP Entitlements";
    DrillDownPageId = "ocpf IP Entitlements";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer."No.";
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(4; "IP App Code"; Code[10])
        {
            Caption = 'IP App Code';
            NotBlank = true;
            TableRelation = "ocpf IP App"."Code";

            trigger OnValidate()
            begin
                Rec.SuggestUnitPrice();
            end;
        }
        field(5; "Edition Code"; Code[10])
        {
            Caption = 'Edition Code';
            NotBlank = true;
            TableRelation = "ocpf IP App Edition"."Edition Code" where("IP App Code" = field("IP App Code"));

            trigger OnValidate()
            begin
                Rec.SuggestUnitPrice();
            end;
        }
        field(6; "Description"; Text[80])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup("ocpf IP App Edition".Description where("IP App Code" = field("IP App Code"), "Edition Code" = field("Edition Code")));
            Editable = false;
        }
        field(7; "Date of Purchase"; Date)
        {
            Caption = 'Date of Purchase';

            trigger OnValidate()
            begin
                Rec.SuggestExpirationDate();
            end;
        }
        field(8; "Status"; Enum "ocpf IP Entitlement Status")
        {
            Caption = 'Status';
            InitValue = Active;
        }
        field(9; "Billing Period"; Enum "ocpf IP Billing Period")
        {
            Caption = 'Billing Period';

            trigger OnValidate()
            begin
                Rec.SuggestExpirationDate();
                Rec.SuggestUnitPrice();
            end;
        }
        field(10; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            MinValue = 0;
            InitValue = 1;
        }
        field(11; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(12; "License Type"; Enum "ocpf IP License Type")
        {
            Caption = 'License Type';
            FieldClass = FlowField;
            CalcFormula = lookup("ocpf IP App"."License Type" where("Code" = field("IP App Code")));
            Editable = false;
        }
        field(13; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            MinValue = 0;
        }
        field(14; "License Key"; Text[80])
        {
            Caption = 'License Key';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Cust; "Customer No.", "IP App Code", "Edition Code")
        {
        }
    }

    trigger OnInsert()
    var
        IPAppSetup: Record "ocpf IP App Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if Rec."No." = '' then begin
            IPAppSetup.Get();
            IPAppSetup.TestField("IP Entitlement Nos.");
            Rec."No." := NoSeries.GetNextNo(IPAppSetup."IP Entitlement Nos.");
        end;
    end;

    /// <summary>
    /// Rule R-1: suggests "Expiration Date" from "Date of Purchase" + the offset for
    /// "Billing Period", once both are known. Never overwrites a user-entered date.
    /// </summary>
    procedure SuggestExpirationDate()
    begin
        if (Rec."Date of Purchase" = 0D) or (Rec."Expiration Date" <> 0D) then
            exit;

        case Rec."Billing Period" of
            Rec."Billing Period"::Monthly:
                Rec."Expiration Date" := CalcDate('<1M>', Rec."Date of Purchase");
            Rec."Billing Period"::Annual:
                Rec."Expiration Date" := CalcDate('<1Y>', Rec."Date of Purchase");
            Rec."Billing Period"::Triennial:
                Rec."Expiration Date" := CalcDate('<3Y>', Rec."Date of Purchase");
        end;
    end;

    /// <summary>
    /// Rule R-4: suggests "Unit Price" by looking up "ocpf IP App Price" on IP App Code +
    /// Edition Code + Billing Period + blank Currency Code (LCY), once all three are known.
    /// A real stored field, not a FlowField, so the user can override it — never overwrites
    /// a non-zero Unit Price. Edge case: a deliberately-entered 0 (e.g. a Gratis entitlement)
    /// is indistinguishable from "not yet suggested" and may be re-suggested if App, Edition
    /// or Billing Period is changed again afterward.
    /// </summary>
    procedure SuggestUnitPrice()
    var
        IPAppPrice: Record "ocpf IP App Price";
    begin
        if Rec."Unit Price" <> 0 then
            exit;

        if IPAppPrice.Get(Rec."IP App Code", Rec."Edition Code", Rec."Billing Period", '') then
            Rec."Unit Price" := IPAppPrice."Unit Price";
    end;
}

namespace OnlyCopilotFans.IPTracking;

page 80329 "ocpf Customer Entitlements"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "ocpf IP Entitlement";
    Caption = 'IP Entitlements';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the customer who holds this entitlement.';
                    Visible = false;
                }
                field("IP App Code"; Rec."IP App Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the IP app the customer is entitled to.';
                }
                field("Edition Code"; Rec."Edition Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the edition the customer is entitled to.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of this entitlement.';
                }
                field("Billing Period"; Rec."Billing Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the billing period of this entitlement.';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity held under this entitlement.';
                }
                field("Date of Purchase"; Rec."Date of Purchase")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the customer purchased this entitlement.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date this entitlement expires. Suggested automatically from the date of purchase and billing period; editable.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price. Suggested automatically from the price list (LCY) once App, Edition and Billing Period are set; editable.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        CustomerNoFilter: Text;
    begin
        CustomerNoFilter := Rec.GetFilter("Customer No.");
        if CustomerNoFilter <> '' then
            Rec.Validate("Customer No.", CopyStr(CustomerNoFilter, 1, MaxStrLen(Rec."Customer No.")));
    end;
}

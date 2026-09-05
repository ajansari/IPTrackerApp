namespace OnlyCopilotFans.IPTracking;

page 80313 "ocpf IP Entitlements"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ocpf IP Entitlement";
    CardPageId = "ocpf IP Entitlement Card";
    Caption = 'IP Entitlements';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the IP Entitlement number.';
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the customer who holds this entitlement.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer who holds this entitlement.';
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
                    ToolTip = 'Specifies the unit price for this app, edition, billing period and currency (LCY).';
                }
            }
        }
    }
}

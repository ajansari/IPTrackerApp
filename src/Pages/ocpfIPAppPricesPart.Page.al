namespace OnlyCopilotFans.IPTracking;

page 80321 "ocpf IP App Prices Part"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "ocpf IP App Price";
    Caption = 'Prices';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Edition Code"; Rec."Edition Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the edition this price applies to.';
                }
                field("Billing Period"; Rec."Billing Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the billing period this price applies to.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency code; blank means the local currency (LCY).';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price for this app, edition, billing period and currency.';
                }
            }
        }
    }
}

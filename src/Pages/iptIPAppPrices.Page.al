namespace DSW.IPTracking;

page 80311 "ipt IP App Prices"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ipt IP App Price";
    CardPageId = "ipt IP App Price Card";
    Caption = 'IP App Prices';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("IP App Code"; Rec."IP App Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the IP app this price applies to.';
                }
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

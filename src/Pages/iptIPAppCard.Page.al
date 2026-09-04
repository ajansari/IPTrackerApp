namespace DSW.IPTracking;

page 80308 "ipt IP App Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "ipt IP App";
    Caption = 'IP App Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the IP app.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the IP app.';
                }
                field("License Type"; Rec."License Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how this IP app is licensed.';
                }
                field("Other"; Rec."Other")
                {
                    ApplicationArea = All;
                    ToolTip = 'Define what Other is, e.g. Salesforce, Ticket, etc.';
                }
                field("Default Billing Period"; Rec."Default Billing Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the billing period proposed on new prices and entitlements for this IP app.';
                }
                field("Default Edition Code"; Rec."Default Edition Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the edition proposed by default for this IP app.';
                }
            }
            part(Editions; "ipt IP App Editions Part")
            {
                ApplicationArea = All;
                Caption = 'Editions';
                SubPageLink = "IP App Code" = field("Code");
            }
            part(Prices; "ipt IP App Prices Part")
            {
                ApplicationArea = All;
                Caption = 'Prices';
                SubPageLink = "IP App Code" = field("Code");
            }
        }
    }
}

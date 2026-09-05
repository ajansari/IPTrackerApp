namespace OnlyCopilotFans.IPTracking;

page 80308 "ocpf IP App Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "ocpf IP App";
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

                    trigger OnValidate()
                    begin
                        UpdateOtherVisible();
                    end;
                }
                field("Other"; Rec."Other")
                {
                    ApplicationArea = All;
                    ToolTip = 'Define what Other is, e.g. Salesforce, Ticket, etc.';
                    Visible = OtherVisible;
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
            part(Editions; "ocpf IP App Editions Part")
            {
                ApplicationArea = All;
                Caption = 'Editions';
                SubPageLink = "IP App Code" = field("Code");
            }
            part(Prices; "ocpf IP App Prices Part")
            {
                ApplicationArea = All;
                Caption = 'Prices';
                SubPageLink = "IP App Code" = field("Code");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Entitlements)
            {
                ApplicationArea = All;
                Caption = 'Entitlements';
                ToolTip = 'View the customers entitled to this IP app.';
                Image = List;
                RunObject = page "ocpf IP Entitlements";
                RunPageLink = "IP App Code" = field(Code);
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateOtherVisible();
    end;

    var
        OtherVisible: Boolean;

    local procedure UpdateOtherVisible()
    begin
        OtherVisible := Rec."License Type" = Rec."License Type"::PerOther;
    end;
}

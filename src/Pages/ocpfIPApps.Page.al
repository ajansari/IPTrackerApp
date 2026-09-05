namespace OnlyCopilotFans.IPTracking;

page 80307 "ocpf IP Apps"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ocpf IP App";
    CardPageId = "ocpf IP App Card";
    Caption = 'IP Apps';

    layout
    {
        area(Content)
        {
            repeater(Group)
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
                field("Edition Count"; Rec."Edition Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many editions exist for this IP app.';
                }
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
}


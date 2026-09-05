namespace OnlyCopilotFans.IPTracking;

page 80309 "ocpf IP App Editions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ocpf IP App Edition";
    CardPageId = "ocpf IP App Edition Card";
    Caption = 'IP App Editions';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("IP App Code"; Rec."IP App Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the IP app this edition belongs to.';
                }
                field("Edition Code"; Rec."Edition Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the edition.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the edition.';
                }
            }
        }
    }
}

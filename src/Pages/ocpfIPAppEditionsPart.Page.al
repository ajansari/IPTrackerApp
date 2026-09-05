namespace OnlyCopilotFans.IPTracking;

page 80320 "ocpf IP App Editions Part"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "ocpf IP App Edition";
    Caption = 'Editions';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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

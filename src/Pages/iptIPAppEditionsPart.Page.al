namespace DSW.IPTracking;

page 80320 "ipt IP App Editions Part"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "ipt IP App Edition";
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
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reference unit price of the edition.';
                }
            }
        }
    }
}

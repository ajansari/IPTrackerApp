namespace DSW.IPTracking;

page 80310 "ipt IP App Edition Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "ipt IP App Edition";
    Caption = 'IP App Edition Card';

    layout
    {
        area(Content)
        {
            group(General)
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
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reference unit price of the edition.';
                }
            }
        }
    }
}

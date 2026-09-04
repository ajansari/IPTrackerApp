namespace DSW.IPTracking;

page 80309 "ipt IP App Editions"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ipt IP App Edition";
    CardPageId = "ipt IP App Edition Card";
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
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reference unit price of the edition.';
                }
            }
        }
    }
}

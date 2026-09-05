namespace OnlyCopilotFans.IPTracking;

page 80322 "ocpf IP App Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ocpf IP App Setup";
    Caption = 'IP App Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("IP Entitlement Nos."; Rec."IP Entitlement Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series used to assign the IP Entitlement No.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

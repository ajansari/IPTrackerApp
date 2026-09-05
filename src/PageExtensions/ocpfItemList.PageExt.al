namespace OnlyCopilotFans.IPTracking;

using Microsoft.Inventory.Item;

pageextension 80325 "ocpf Item List" extends "Item List"
{
    layout
    {
        addlast(Control1)
        {
            field("IP App"; Rec."IP App")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the IP app associated with this item, if any.';
            }
        }
    }
}

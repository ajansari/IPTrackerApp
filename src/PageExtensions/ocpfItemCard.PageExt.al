namespace OnlyCopilotFans.IPTracking;

using Microsoft.Inventory.Item;

pageextension 80324 "ocpf Item Card" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("IP App"; Rec."IP App")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the IP app associated with this item, if any.';
            }
        }
    }
}

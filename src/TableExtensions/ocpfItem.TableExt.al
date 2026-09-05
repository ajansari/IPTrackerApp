namespace OnlyCopilotFans.IPTracking;

using Microsoft.Inventory.Item;

tableextension 80323 "ocpf Item" extends Item
{
    fields
    {
        field(80300; "IP App"; Code[10])
        {
            Caption = 'IP App';
            ToolTip = 'Specifies the IP app associated with this item, if any.';
            TableRelation = "ocpf IP App".Code;
            DataClassification = CustomerContent;
        }
    }
}

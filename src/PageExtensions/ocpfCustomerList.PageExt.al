namespace OnlyCopilotFans.IPTracking;

using Microsoft.Sales.Customer;

pageextension 80327 "ocpf Customer List" extends "Customer List"
{
    actions
    {
        addlast(Navigation)
        {
            action("IP Entitlements")
            {
                ApplicationArea = All;
                Caption = 'IP Entitlements';
                ToolTip = 'View the IP apps this customer is entitled to.';
                Image = List;
                RunObject = page "ocpf IP Entitlements";
                RunPageLink = "Customer No." = field("No.");
            }
        }
    }
}

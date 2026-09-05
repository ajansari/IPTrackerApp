namespace OnlyCopilotFans.IPTracking;

using Microsoft.Sales.Customer;

pageextension 80326 "ocpf Customer Card" extends "Customer Card"
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
                RunObject = page "ocpf Customer Entitlements";
                RunPageLink = "Customer No." = field("No.");
                RunPageView = sorting("Customer No.");
            }
        }
    }
}

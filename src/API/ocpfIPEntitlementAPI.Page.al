namespace OnlyCopilotFans.IPTracking;

page 80318 "ocpf IP Entitlement API"
{
    PageType = API;
    Caption = 'IP Entitlement API';
    APIPublisher = 'ocpf';
    APIGroup = 'ocpfIpManagement';
    APIVersion = 'v1.0';
    EntityName = 'ocpfIPEntitlement';
    EntitySetName = 'ocpfIPEntitlements';
    SourceTable = "ocpf IP Entitlement";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(customerName; Rec."Customer Name")
                {
                    Caption = 'Customer Name';
                    Editable = false;
                }
                field(ipAppCode; Rec."IP App Code")
                {
                    Caption = 'IP App Code';
                }
                field(editionCode; Rec."Edition Code")
                {
                    Caption = 'Edition Code';
                }
                field(description; Rec."Description")
                {
                    Caption = 'Description';
                    Editable = false;
                }
                field(dateOfPurchase; Rec."Date of Purchase")
                {
                    Caption = 'Date of Purchase';
                }
                field(status; Rec."Status")
                {
                    Caption = 'Status';
                }
                field(billingPeriod; Rec."Billing Period")
                {
                    Caption = 'Billing Period';
                }
                field(quantity; Rec."Quantity")
                {
                    Caption = 'Quantity';
                }
                field(expirationDate; Rec."Expiration Date")
                {
                    Caption = 'Expiration Date';
                }
                field(licenseType; Rec."License Type")
                {
                    Caption = 'License Type';
                    Editable = false;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                    Editable = false;
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System Id';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Time';
                    Editable = false;
                }
            }
        }
    }
}

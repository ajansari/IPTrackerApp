namespace OnlyCopilotFans.IPTracking;

page 80317 "ocpf IP App Price API"
{
    PageType = API;
    Caption = 'IP App Price API';
    APIPublisher = 'ocpf';
    APIGroup = 'ocpfIpManagement';
    APIVersion = 'v1.0';
    EntityName = 'ocpfIPAppPrice';
    EntitySetName = 'ocpfIPAppPrices';
    SourceTable = "ocpf IP App Price";
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ipAppCode; Rec."IP App Code")
                {
                    Caption = 'IP App Code';
                }
                field(editionCode; Rec."Edition Code")
                {
                    Caption = 'Edition Code';
                }
                field(billingPeriod; Rec."Billing Period")
                {
                    Caption = 'Billing Period';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
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

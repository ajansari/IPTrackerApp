namespace DSW.IPTracking;

page 80316 "ipt IP App Edition API"
{
    PageType = API;
    Caption = 'IP App Edition API';
    APIPublisher = 'dsw';
    APIGroup = 'iptIpManagement';
    APIVersion = 'v1.0';
    EntityName = 'iptIPAppEdition';
    EntitySetName = 'iptIPAppEditions';
    SourceTable = "ipt IP App Edition";
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
                field(description; Rec."Description")
                {
                    Caption = 'Description';
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

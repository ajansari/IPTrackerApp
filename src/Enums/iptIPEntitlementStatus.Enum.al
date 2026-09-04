namespace DSW.IPTracking;

enum 80302 "ipt IP Entitlement Status"
{
    Extensible = true;

    value(0; Gratis)
    {
        Caption = 'Gratis';
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Demo)
    {
        Caption = 'Demo';
    }
}

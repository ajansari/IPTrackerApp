namespace DSW.IPTracking;

enum 80301 "ipt IP Billing Period"
{
    Extensible = true;

    value(0; Monthly)
    {
        Caption = 'Monthly';
    }
    value(1; Annual)
    {
        Caption = 'Annual';
    }
    value(2; Triennial)
    {
        Caption = 'Triennial';
    }
}

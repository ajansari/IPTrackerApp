namespace OnlyCopilotFans.IPTracking;

enum 80301 "ocpf IP Billing Period"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; Monthly)
    {
        Caption = 'Monthly';
    }
    value(2; Annual)
    {
        Caption = 'Annual';
    }
    value(3; Triennial)
    {
        Caption = 'Triennial';
    }
}

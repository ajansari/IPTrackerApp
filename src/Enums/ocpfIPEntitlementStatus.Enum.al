namespace OnlyCopilotFans.IPTracking;

enum 80302 "ocpf IP Entitlement Status"
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

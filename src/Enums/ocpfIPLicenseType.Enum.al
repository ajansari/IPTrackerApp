namespace OnlyCopilotFans.IPTracking;

enum 80300 "ocpf IP License Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; Perpetual)
    {
        Caption = 'Perpetual';
    }
    value(2; FixedPricePerPeriod)
    {
        Caption = 'Fixed Price per Period';
    }
    value(3; PerUser)
    {
        Caption = 'Per User';
    }
    value(4; PerCompany)
    {
        Caption = 'Per Company';
    }
    value(5; PerEnvironment)
    {
        Caption = 'Per Environment';
    }
    value(6; PerTenant)
    {
        Caption = 'Per Tenant';
    }
    value(7; PerOther)
    {
        Caption = 'Per Other';
    }
    value(8; Free)
    {
        Caption = 'Free';
    }
    value(9; FreeOpenSource)
    {
        Caption = 'Free Open Source';
    }
}

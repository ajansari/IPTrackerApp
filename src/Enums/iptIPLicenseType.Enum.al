namespace DSW.IPTracking;

enum 80300 "ipt IP License Type"
{
    Extensible = true;

    value(0; Perpetual)
    {
        Caption = 'Perpetual';
    }
    value(1; FixedPricePerPeriod)
    {
        Caption = 'Fixed Price per Period';
    }
    value(2; PerUser)
    {
        Caption = 'Per User';
    }
    value(3; PerCompany)
    {
        Caption = 'Per Company';
    }
    value(4; PerEnvironment)
    {
        Caption = 'Per Environment';
    }
    value(5; PerTenant)
    {
        Caption = 'Per Tenant';
    }
    value(6; PerOther)
    {
        Caption = 'Per Other';
    }
}

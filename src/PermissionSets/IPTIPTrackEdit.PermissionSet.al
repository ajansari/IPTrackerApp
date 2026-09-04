namespace DSW.IPTracking;

permissionset 80339 "IPT - IP Track Edit"
{
    Caption = 'IP Tracking - Edit';
    Assignable = true;
    IncludedPermissionSets = "IPT - IP Track Read";

    Permissions =
        tabledata "ipt IP App" = IMD,
        tabledata "ipt IP App Edition" = IMD,
        tabledata "ipt IP App Price" = IMD,
        tabledata "ipt IP Entitlement" = IMD;
}

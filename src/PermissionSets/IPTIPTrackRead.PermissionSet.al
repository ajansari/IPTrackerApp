namespace DSW.IPTracking;

permissionset 80338 "IPT - IP Track Read"
{
    Caption = 'IP Tracking - Read';
    Assignable = true;

    Permissions =
        tabledata "ipt IP App" = R,
        tabledata "ipt IP App Edition" = R,
        tabledata "ipt IP App Price" = R,
        tabledata "ipt IP Entitlement" = R;
}

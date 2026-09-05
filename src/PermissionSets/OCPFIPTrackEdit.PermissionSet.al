namespace OnlyCopilotFans.IPTracking;

permissionset 80339 "OCPF - IP Track Edit"
{
    Caption = 'IP Tracking - Edit';
    Assignable = true;
    IncludedPermissionSets = "OCPF - IP Track Read";

    Permissions =
        tabledata "ocpf IP App" = IMD,
        tabledata "ocpf IP App Edition" = IMD,
        tabledata "ocpf IP App Price" = IMD,
        tabledata "ocpf IP App Setup" = IMD,
        tabledata "ocpf IP Entitlement" = IMD;
}

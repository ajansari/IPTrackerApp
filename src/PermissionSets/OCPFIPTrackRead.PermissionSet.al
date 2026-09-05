namespace OnlyCopilotFans.IPTracking;

permissionset 80338 "OCPF - IP Track Read"
{
    Caption = 'IP Tracking - Read';
    Assignable = true;

    Permissions =
        tabledata "ocpf IP App" = R,
        tabledata "ocpf IP App Edition" = R,
        tabledata "ocpf IP App Price" = R,
        tabledata "ocpf IP App Setup" = R,
        tabledata "ocpf IP Entitlement" = R;
}

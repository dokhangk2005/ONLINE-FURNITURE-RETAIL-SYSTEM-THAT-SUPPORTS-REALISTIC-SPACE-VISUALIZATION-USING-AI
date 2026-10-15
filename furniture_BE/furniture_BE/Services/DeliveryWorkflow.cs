namespace furniture_BE.Services;

public static class DeliveryStatuses
{
    public const string Assigned = "Assigned";
    public const string Accepted = "Accepted";
    public const string PickedUp = "PickedUp";
    public const string Shipping = "Shipping";
    public const string Arrived = "Arrived";
    public const string Rescheduled = "Rescheduled";
    public const string Delivered = "Delivered";
    public const string Cancelled = "Cancelled";

    public static readonly HashSet<string> Active = new(StringComparer.OrdinalIgnoreCase)
    {
        Assigned, Accepted, PickedUp, Shipping, Arrived, Rescheduled
    };

    public static bool CanTransition(string current, string next) =>
        (current, next) switch
        {
            (Assigned, Accepted) => true,
            (Accepted, PickedUp) => true,
            (PickedUp, Shipping) => true,
            (Shipping, Arrived) => true,
            (Rescheduled, Accepted) => true,
            // Backward compatibility for orders assigned before the workflow upgrade.
            (Shipping, Delivered) => true,
            _ => false
        };
}

public static class DeliveryShiftStatuses
{
    public const string Offline = "Offline";
    public const string Available = "Available";
    public const string Delivering = "Delivering";
    public const string Break = "Break";

    public static bool IsValid(string value) =>
        value.Equals(Offline, StringComparison.OrdinalIgnoreCase) ||
        value.Equals(Available, StringComparison.OrdinalIgnoreCase) ||
        value.Equals(Delivering, StringComparison.OrdinalIgnoreCase) ||
        value.Equals(Break, StringComparison.OrdinalIgnoreCase);
}

public static class PaymentHandoverStatuses
{
    public const string NotRequired = "NotRequired";
    public const string Pending = "Pending";
    public const string Submitted = "Submitted";
    public const string Confirmed = "Confirmed";
    public const string Rejected = "Rejected";
}

public static class PaymentReconciliationActions
{
    public const string Collected = "Collected";
    public const string Submitted = "Submitted";
    public const string Confirmed = "Confirmed";
    public const string Rejected = "Rejected";
}

namespace furniture_BE.Hubs;

public static class SupportHubGroups
{
    public const string Admins = "support:admins";

    public static string User(int userId) => $"support:user:{userId}";

    public static string Conversation(int conversationId) =>
        $"support:conversation:{conversationId}";
}

using System.Security.Claims;

namespace furniture_BE.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static int UserId(this ClaimsPrincipal principal) =>
        int.TryParse(principal.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : 0;
}

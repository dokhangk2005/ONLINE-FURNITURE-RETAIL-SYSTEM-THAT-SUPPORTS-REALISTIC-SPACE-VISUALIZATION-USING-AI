using furniture_BE.Backend.Data;
using furniture_BE.Backend.Models;
using furniture_BE.Extensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace furniture_BE.Controllers;

[ApiController, Route("api/[controller]"), Authorize]
public class AddressesController : ControllerBase
{
    private readonly AppDbContext _context;
    public AddressesController(AppDbContext context) => _context = context;

    [HttpGet]
    public async Task<IActionResult> GetMine() => Ok(await _context.UserAddresses
        .Where(a => a.UserId == User.UserId()).OrderByDescending(a => a.IsDefault).ThenByDescending(a => a.AddressId).ToListAsync());

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AddressRequest request)
    {
        if (!Valid(request)) return BadRequest(new { Message = "Thông tin địa chỉ chưa đầy đủ." });
        var userId = User.UserId();
        var isFirst = !await _context.UserAddresses.AnyAsync(a => a.UserId == userId);
        if (request.IsDefault || isFirst) await ClearDefault(userId);
        var address = new UserAddress { UserId = userId, RecipientName = request.RecipientName.Trim(), Phone = request.Phone.Trim(), AddressLine = request.AddressLine.Trim(), Label = request.Label?.Trim(), IsDefault = request.IsDefault || isFirst };
        _context.UserAddresses.Add(address);
        await _context.SaveChangesAsync();
        return Ok(address);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] AddressRequest request)
    {
        if (!Valid(request)) return BadRequest(new { Message = "Thông tin địa chỉ chưa đầy đủ." });
        var address = await _context.UserAddresses.FirstOrDefaultAsync(a => a.AddressId == id && a.UserId == User.UserId());
        if (address == null) return NotFound();
        if (request.IsDefault) await ClearDefault(address.UserId);
        var hasAnotherDefault = request.IsDefault || await _context.UserAddresses
            .AnyAsync(a => a.UserId == address.UserId && a.AddressId != address.AddressId && a.IsDefault);
        address.RecipientName = request.RecipientName.Trim(); address.Phone = request.Phone.Trim(); address.AddressLine = request.AddressLine.Trim();
        address.Label = request.Label?.Trim(); address.IsDefault = request.IsDefault || !hasAnotherDefault; address.UpdatedAt = DateTime.Now;
        await _context.SaveChangesAsync();
        return Ok(address);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var address = await _context.UserAddresses.FirstOrDefaultAsync(a => a.AddressId == id && a.UserId == User.UserId());
        if (address == null) return NotFound();
        var wasDefault = address.IsDefault; _context.UserAddresses.Remove(address); await _context.SaveChangesAsync();
        if (wasDefault)
        {
            var next = await _context.UserAddresses.FirstOrDefaultAsync(a => a.UserId == User.UserId());
            if (next != null) { next.IsDefault = true; await _context.SaveChangesAsync(); }
        }
        return NoContent();
    }

    private Task ClearDefault(int userId) => _context.UserAddresses.Where(a => a.UserId == userId).ExecuteUpdateAsync(s => s.SetProperty(a => a.IsDefault, false));
    private static bool Valid(AddressRequest r) => !string.IsNullOrWhiteSpace(r.RecipientName) && !string.IsNullOrWhiteSpace(r.Phone) && !string.IsNullOrWhiteSpace(r.AddressLine);
    public record AddressRequest(string RecipientName, string Phone, string AddressLine, string? Label, bool IsDefault);
}

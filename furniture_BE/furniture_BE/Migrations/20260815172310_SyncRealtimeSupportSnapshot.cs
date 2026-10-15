using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace furniture_BE.Migrations;

/// <summary>
/// Keeps the generated EF model snapshot aligned after restoring the historical
/// recommendation migration. Schema changes are applied by the two migrations
/// immediately before this one.
/// </summary>
public partial class SyncRealtimeSupportSnapshot : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
    }
}

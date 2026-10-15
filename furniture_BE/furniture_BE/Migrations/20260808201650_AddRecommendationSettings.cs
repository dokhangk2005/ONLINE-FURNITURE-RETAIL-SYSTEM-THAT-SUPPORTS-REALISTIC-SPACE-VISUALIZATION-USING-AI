using System;
using furniture_BE.Backend.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace furniture_BE.Migrations;

[DbContext(typeof(AppDbContext))]
[Migration("20260808201650_AddRecommendationSettings")]
public partial class AddRecommendationSettings : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "RecommendationSettings",
            columns: table => new
            {
                Id = table.Column<int>(type: "int", nullable: false),
                AprioriEnabled = table.Column<bool>(type: "bit", nullable: false),
                ContentBasedEnabled = table.Column<bool>(type: "bit", nullable: false),
                AutoRebuildEnabled = table.Column<bool>(type: "bit", nullable: false),
                MinSupport = table.Column<decimal>(type: "decimal(8,6)", nullable: false),
                MinConfidence = table.Column<decimal>(type: "decimal(8,6)", nullable: false),
                MaxResults = table.Column<int>(type: "int", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_RecommendationSettings", x => x.Id);
            });

        migrationBuilder.Sql(
            """
            INSERT INTO [RecommendationSettings]
                ([Id], [AprioriEnabled], [ContentBasedEnabled], [AutoRebuildEnabled],
                 [MinSupport], [MinConfidence], [MaxResults], [UpdatedAt])
            VALUES
                (1, 1, 1, 1, 0.010000, 0.100000, 5, '2026-08-08T00:00:00');
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "RecommendationSettings");
    }
}

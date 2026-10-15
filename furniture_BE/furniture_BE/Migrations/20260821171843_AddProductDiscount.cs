using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace furniture_BE.Migrations
{
    /// <inheritdoc />
    public partial class AddProductDiscount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DiscountEndAt",
                table: "Products",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "DiscountPercent",
                table: "Products",
                type: "decimal(5,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<DateTime>(
                name: "DiscountStartAt",
                table: "Products",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDiscountActive",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddCheckConstraint(
                name: "CK_Products_DiscountPercent",
                table: "Products",
                sql: "[DiscountPercent] >= 0 AND [DiscountPercent] <= 90");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Products_DiscountPercent",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DiscountEndAt",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DiscountPercent",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "DiscountStartAt",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "IsDiscountActive",
                table: "Products");
        }
    }
}

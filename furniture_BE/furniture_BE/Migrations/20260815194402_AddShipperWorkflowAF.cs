using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace furniture_BE.Migrations
{
    /// <inheritdoc />
    public partial class AddShipperWorkflowAF : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "CanHandleBulkyItems",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "CanProvideAssembly",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryBreakUntil",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeliveryServiceArea",
                table: "Users",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryShiftEndedAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryShiftStartedAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeliveryShiftStatus",
                table: "Users",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "Offline");

            migrationBuilder.AddColumn<string>(
                name: "DeliveryVehiclePlate",
                table: "Users",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeliveryVehicleType",
                table: "Users",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MaxConcurrentDeliveries",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 3);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveredAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryAcceptedAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryArrivedAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryAssignedAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryAssignmentExpiresAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeliveryIssueProofImage",
                table: "Orders",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DeliveryOtpAttempts",
                table: "Orders",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryOtpExpiresAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeliveryOtpHash",
                table: "Orders",
                type: "nvarchar(64)",
                maxLength: 64,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryOtpVerifiedAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeliveryPickedUpAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DeliveryRecipientName",
                table: "Orders",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CanHandleBulkyItems",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "CanProvideAssembly",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveryBreakUntil",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveryServiceArea",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveryShiftEndedAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveryShiftStartedAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveryShiftStatus",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveryVehiclePlate",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveryVehicleType",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "MaxConcurrentDeliveries",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeliveredAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryAcceptedAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryArrivedAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryAssignedAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryAssignmentExpiresAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryIssueProofImage",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryOtpAttempts",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryOtpExpiresAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryOtpHash",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryOtpVerifiedAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryPickedUpAt",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "DeliveryRecipientName",
                table: "Orders");
        }
    }
}

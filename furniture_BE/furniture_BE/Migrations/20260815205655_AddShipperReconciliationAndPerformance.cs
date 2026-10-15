using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace furniture_BE.Migrations
{
    /// <inheritdoc />
    public partial class AddShipperReconciliationAndPerformance : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CollectedAt",
                table: "Payments",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CollectedByShipperId",
                table: "Payments",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CollectionNote",
                table: "Payments",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CollectionProofImage",
                table: "Payments",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "HandoverConfirmedAt",
                table: "Payments",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "HandoverConfirmedByAdminId",
                table: "Payments",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "HandoverStatus",
                table: "Payments",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: false,
                defaultValue: "NotRequired");

            migrationBuilder.AddColumn<DateTime>(
                name: "HandoverSubmittedAt",
                table: "Payments",
                type: "datetime2",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "PaymentReconciliationHistories",
                columns: table => new
                {
                    PaymentReconciliationHistoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PaymentId = table.Column<int>(type: "int", nullable: false),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    ShipperId = table.Column<int>(type: "int", nullable: false),
                    AdminId = table.Column<int>(type: "int", nullable: true),
                    Action = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    ProofImage = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    Note = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PaymentReconciliationHistories", x => x.PaymentReconciliationHistoryId);
                    table.ForeignKey(
                        name: "FK_PaymentReconciliationHistories_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PaymentReconciliationHistories_Payments_PaymentId",
                        column: x => x.PaymentId,
                        principalTable: "Payments",
                        principalColumn: "PaymentId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PaymentReconciliationHistories_Users_AdminId",
                        column: x => x.AdminId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PaymentReconciliationHistories_Users_ShipperId",
                        column: x => x.ShipperId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Payments_CollectedByShipperId",
                table: "Payments",
                column: "CollectedByShipperId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_HandoverConfirmedByAdminId",
                table: "Payments",
                column: "HandoverConfirmedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentReconciliationHistories_AdminId",
                table: "PaymentReconciliationHistories",
                column: "AdminId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentReconciliationHistories_OrderId",
                table: "PaymentReconciliationHistories",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentReconciliationHistories_PaymentId",
                table: "PaymentReconciliationHistories",
                column: "PaymentId");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentReconciliationHistories_ShipperId_CreatedAt",
                table: "PaymentReconciliationHistories",
                columns: new[] { "ShipperId", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_PaymentReconciliationHistories_Status_CreatedAt",
                table: "PaymentReconciliationHistories",
                columns: new[] { "Status", "CreatedAt" });

            migrationBuilder.AddForeignKey(
                name: "FK_Payments_Users_CollectedByShipperId",
                table: "Payments",
                column: "CollectedByShipperId",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Payments_Users_HandoverConfirmedByAdminId",
                table: "Payments",
                column: "HandoverConfirmedByAdminId",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Payments_Users_CollectedByShipperId",
                table: "Payments");

            migrationBuilder.DropForeignKey(
                name: "FK_Payments_Users_HandoverConfirmedByAdminId",
                table: "Payments");

            migrationBuilder.DropTable(
                name: "PaymentReconciliationHistories");

            migrationBuilder.DropIndex(
                name: "IX_Payments_CollectedByShipperId",
                table: "Payments");

            migrationBuilder.DropIndex(
                name: "IX_Payments_HandoverConfirmedByAdminId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "CollectedAt",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "CollectedByShipperId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "CollectionNote",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "CollectionProofImage",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "HandoverConfirmedAt",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "HandoverConfirmedByAdminId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "HandoverStatus",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "HandoverSubmittedAt",
                table: "Payments");
        }
    }
}

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace furniture_BE.Migrations
{
    /// <inheritdoc />
    public partial class AddRoomVisualizer : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "RoomDesigns",
                columns: table => new
                {
                    RoomDesignId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: true),
                    Title = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    RoomImagePath = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    PreviewImagePath = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    AccessTokenHash = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                    SceneJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RoomDesigns", x => x.RoomDesignId);
                    table.ForeignKey(
                        name: "FK_RoomDesigns_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RoomDesigns_ExpiresAt",
                table: "RoomDesigns",
                column: "ExpiresAt");

            migrationBuilder.CreateIndex(
                name: "IX_RoomDesigns_UserId",
                table: "RoomDesigns",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RoomDesigns");
        }
    }
}

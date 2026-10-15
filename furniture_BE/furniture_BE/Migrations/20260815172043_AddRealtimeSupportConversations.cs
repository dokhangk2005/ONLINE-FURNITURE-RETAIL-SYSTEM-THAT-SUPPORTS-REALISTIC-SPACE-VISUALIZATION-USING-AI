using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace furniture_BE.Migrations
{
    /// <inheritdoc />
    public partial class AddRealtimeSupportConversations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SupportConversations",
                columns: table => new
                {
                    ConversationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    AssignedAdminId = table.Column<int>(type: "int", nullable: true),
                    LegacyQuestionId = table.Column<int>(type: "int", nullable: true),
                    Topic = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ClosedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SupportConversations", x => x.ConversationId);
                    table.ForeignKey(
                        name: "FK_SupportConversations_SupportQuestions_LegacyQuestionId",
                        column: x => x.LegacyQuestionId,
                        principalTable: "SupportQuestions",
                        principalColumn: "QuestionId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_SupportConversations_Users_AssignedAdminId",
                        column: x => x.AssignedAdminId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                    table.ForeignKey(
                        name: "FK_SupportConversations_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "SupportMessages",
                columns: table => new
                {
                    MessageId = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ConversationId = table.Column<int>(type: "int", nullable: false),
                    SenderId = table.Column<int>(type: "int", nullable: true),
                    SenderRole = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    MessageType = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    MessageText = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ClientMessageId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    SentAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ReadAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SupportMessages", x => x.MessageId);
                    table.ForeignKey(
                        name: "FK_SupportMessages_SupportConversations_ConversationId",
                        column: x => x.ConversationId,
                        principalTable: "SupportConversations",
                        principalColumn: "ConversationId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SupportMessages_Users_SenderId",
                        column: x => x.SenderId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.NoAction);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SupportConversations_AssignedAdminId_Status",
                table: "SupportConversations",
                columns: new[] { "AssignedAdminId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_SupportConversations_LegacyQuestionId",
                table: "SupportConversations",
                column: "LegacyQuestionId",
                unique: true,
                filter: "[LegacyQuestionId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_SupportConversations_Status_UpdatedAt",
                table: "SupportConversations",
                columns: new[] { "Status", "UpdatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_SupportConversations_UserId_UpdatedAt",
                table: "SupportConversations",
                columns: new[] { "UserId", "UpdatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_SupportMessages_ClientMessageId",
                table: "SupportMessages",
                column: "ClientMessageId",
                unique: true,
                filter: "[ClientMessageId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_SupportMessages_ConversationId_SentAt_MessageId",
                table: "SupportMessages",
                columns: new[] { "ConversationId", "SentAt", "MessageId" });

            migrationBuilder.CreateIndex(
                name: "IX_SupportMessages_SenderId",
                table: "SupportMessages",
                column: "SenderId");

            migrationBuilder.Sql(
                """
                INSERT INTO [SupportConversations]
                    ([UserId], [AssignedAdminId], [LegacyQuestionId], [Topic], [Status], [CreatedAt], [UpdatedAt], [ClosedAt])
                SELECT
                    q.[UserId],
                    NULL,
                    q.[QuestionId],
                    q.[Topic],
                    CASE
                        WHEN q.[Status] = N'Answered' OR q.[AnswerText] IS NOT NULL
                            THEN N'WaitingCustomer'
                        ELSE N'WaitingAdmin'
                    END,
                    q.[CreatedAt],
                    COALESCE(q.[AnsweredAt], q.[CreatedAt]),
                    NULL
                FROM [SupportQuestions] q
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM [SupportConversations] c
                    WHERE c.[LegacyQuestionId] = q.[QuestionId]
                );

                INSERT INTO [SupportMessages]
                    ([ConversationId], [SenderId], [SenderRole], [MessageType], [MessageText], [ClientMessageId], [SentAt], [ReadAt], [IsDeleted])
                SELECT
                    c.[ConversationId],
                    q.[UserId],
                    N'Customer',
                    N'Text',
                    q.[QuestionText],
                    NULL,
                    q.[CreatedAt],
                    CASE WHEN q.[AnswerText] IS NOT NULL THEN q.[AnsweredAt] ELSE NULL END,
                    0
                FROM [SupportQuestions] q
                INNER JOIN [SupportConversations] c ON c.[LegacyQuestionId] = q.[QuestionId]
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM [SupportMessages] m
                    WHERE m.[ConversationId] = c.[ConversationId]
                      AND m.[SenderRole] = N'Customer'
                );

                INSERT INTO [SupportMessages]
                    ([ConversationId], [SenderId], [SenderRole], [MessageType], [MessageText], [ClientMessageId], [SentAt], [ReadAt], [IsDeleted])
                SELECT
                    c.[ConversationId],
                    NULL,
                    N'Admin',
                    N'Text',
                    q.[AnswerText],
                    NULL,
                    COALESCE(q.[AnsweredAt], q.[CreatedAt]),
                    NULL,
                    0
                FROM [SupportQuestions] q
                INNER JOIN [SupportConversations] c ON c.[LegacyQuestionId] = q.[QuestionId]
                WHERE q.[AnswerText] IS NOT NULL
                  AND LTRIM(RTRIM(q.[AnswerText])) <> N''
                  AND NOT EXISTS (
                      SELECT 1
                      FROM [SupportMessages] m
                      WHERE m.[ConversationId] = c.[ConversationId]
                        AND m.[SenderRole] = N'Admin'
                  );
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SupportMessages");

            migrationBuilder.DropTable(
                name: "SupportConversations");
        }
    }
}

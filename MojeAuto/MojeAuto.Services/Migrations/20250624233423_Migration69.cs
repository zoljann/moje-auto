using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Migration69 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "RadniProstor",
                columns: table => new
                {
                    RadniProstorId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Oznaka = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Kapacitet = table.Column<int>(type: "int", nullable: false),
                    Aktivna = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RadniProstor", x => x.RadniProstorId);
                });

            migrationBuilder.CreateTable(
                name: "RezervacijaProstora",
                columns: table => new
                {
                    RezervacijaProstoraId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    RadniProstorId = table.Column<int>(type: "int", nullable: false),
                    DatumPocetka = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Trajanje = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Napomena = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RezervacijaProstora", x => x.RezervacijaProstoraId);
                    table.ForeignKey(
                        name: "FK_RezervacijaProstora_RadniProstor_RadniProstorId",
                        column: x => x.RadniProstorId,
                        principalTable: "RadniProstor",
                        principalColumn: "RadniProstorId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RezervacijaProstora_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RezervacijaProstora_RadniProstorId",
                table: "RezervacijaProstora",
                column: "RadniProstorId");

            migrationBuilder.CreateIndex(
                name: "IX_RezervacijaProstora_UserId",
                table: "RezervacijaProstora",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RezervacijaProstora");

            migrationBuilder.DropTable(
                name: "RadniProstor");
        }
    }
}

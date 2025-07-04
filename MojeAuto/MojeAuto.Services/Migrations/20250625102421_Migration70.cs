using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Migration70 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "FinancijskiLimit25062025",
                columns: table => new
                {
                    FinancijskiLimit25062025Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Limit = table.Column<decimal>(type: "decimal(18,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FinancijskiLimit25062025", x => x.FinancijskiLimit25062025Id);
                    table.ForeignKey(
                        name: "FK_FinancijskiLimit25062025_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "KategorijaTransakcije25062025",
                columns: table => new
                {
                    KategorijaTransakcije25062025Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NazivKategorije = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TipKategorije = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KategorijaTransakcije25062025", x => x.KategorijaTransakcije25062025Id);
                });

            migrationBuilder.CreateTable(
                name: "Transakcija25062025",
                columns: table => new
                {
                    Transakcija25062025Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Datum = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Opis = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    KategorijaTransakcije25062025Id = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Transakcija25062025", x => x.Transakcija25062025Id);
                    table.ForeignKey(
                        name: "FK_Transakcija25062025_KategorijaTransakcije25062025_KategorijaTransakcije25062025Id",
                        column: x => x.KategorijaTransakcije25062025Id,
                        principalTable: "KategorijaTransakcije25062025",
                        principalColumn: "KategorijaTransakcije25062025Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Transakcija25062025_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_FinancijskiLimit25062025_UserId",
                table: "FinancijskiLimit25062025",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Transakcija25062025_KategorijaTransakcije25062025Id",
                table: "Transakcija25062025",
                column: "KategorijaTransakcije25062025Id");

            migrationBuilder.CreateIndex(
                name: "IX_Transakcija25062025_UserId",
                table: "Transakcija25062025",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FinancijskiLimit25062025");

            migrationBuilder.DropTable(
                name: "Transakcija25062025");

            migrationBuilder.DropTable(
                name: "KategorijaTransakcije25062025");
        }
    }
}

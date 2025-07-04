using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Migration79 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "KategorijaTransakcije25062025Id",
                table: "FinancijskiLimit25062025",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Mjesec",
                table: "FinancijskiLimit25062025",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "TransakcijaLog25062025",
                columns: table => new
                {
                    TransakcijaLog25062025Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    StariStatus = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NoviStatus = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    VrijemePromjene = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TransakcijaLog25062025", x => x.TransakcijaLog25062025Id);
                    table.ForeignKey(
                        name: "FK_TransakcijaLog25062025_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_FinancijskiLimit25062025_KategorijaTransakcije25062025Id",
                table: "FinancijskiLimit25062025",
                column: "KategorijaTransakcije25062025Id");

            migrationBuilder.CreateIndex(
                name: "IX_TransakcijaLog25062025_UserId",
                table: "TransakcijaLog25062025",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_FinancijskiLimit25062025_KategorijaTransakcije25062025_KategorijaTransakcije25062025Id",
                table: "FinancijskiLimit25062025",
                column: "KategorijaTransakcije25062025Id",
                principalTable: "KategorijaTransakcije25062025",
                principalColumn: "KategorijaTransakcije25062025Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FinancijskiLimit25062025_KategorijaTransakcije25062025_KategorijaTransakcije25062025Id",
                table: "FinancijskiLimit25062025");

            migrationBuilder.DropTable(
                name: "TransakcijaLog25062025");

            migrationBuilder.DropIndex(
                name: "IX_FinancijskiLimit25062025_KategorijaTransakcije25062025Id",
                table: "FinancijskiLimit25062025");

            migrationBuilder.DropColumn(
                name: "KategorijaTransakcije25062025Id",
                table: "FinancijskiLimit25062025");

            migrationBuilder.DropColumn(
                name: "Mjesec",
                table: "FinancijskiLimit25062025");
        }
    }
}

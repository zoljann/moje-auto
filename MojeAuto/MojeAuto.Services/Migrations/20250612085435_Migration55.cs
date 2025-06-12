using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Migration55 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_PartCars_CarId",
                table: "PartCars");

            migrationBuilder.CreateIndex(
                name: "IX_PartCars_CarId_PartId",
                table: "PartCars",
                columns: new[] { "CarId", "PartId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_PartCars_CarId_PartId",
                table: "PartCars");

            migrationBuilder.CreateIndex(
                name: "IX_PartCars_CarId",
                table: "PartCars",
                column: "CarId",
                unique: true);
        }
    }
}

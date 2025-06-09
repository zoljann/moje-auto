using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Migration51 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PartCars_Cars_CarId1",
                table: "PartCars");

            migrationBuilder.DropIndex(
                name: "IX_PartCars_CarId1",
                table: "PartCars");

            migrationBuilder.DropColumn(
                name: "CarId1",
                table: "PartCars");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CarId1",
                table: "PartCars",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_PartCars_CarId1",
                table: "PartCars",
                column: "CarId1");

            migrationBuilder.AddForeignKey(
                name: "FK_PartCars_Cars_CarId1",
                table: "PartCars",
                column: "CarId1",
                principalTable: "Cars",
                principalColumn: "CarId");
        }
    }
}

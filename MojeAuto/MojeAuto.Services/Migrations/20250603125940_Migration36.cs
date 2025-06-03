using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Migration36 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PartCars_Cars_CarId",
                table: "PartCars");

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
                name: "FK_PartCars_Cars_CarId",
                table: "PartCars",
                column: "CarId",
                principalTable: "Cars",
                principalColumn: "CarId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_PartCars_Cars_CarId1",
                table: "PartCars",
                column: "CarId1",
                principalTable: "Cars",
                principalColumn: "CarId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PartCars_Cars_CarId",
                table: "PartCars");

            migrationBuilder.DropForeignKey(
                name: "FK_PartCars_Cars_CarId1",
                table: "PartCars");

            migrationBuilder.DropIndex(
                name: "IX_PartCars_CarId1",
                table: "PartCars");

            migrationBuilder.DropColumn(
                name: "CarId1",
                table: "PartCars");

            migrationBuilder.AddForeignKey(
                name: "FK_PartCars_Cars_CarId",
                table: "PartCars",
                column: "CarId",
                principalTable: "Cars",
                principalColumn: "CarId",
                onDelete: ReferentialAction.Restrict);
        }
    }
}

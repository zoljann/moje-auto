using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Migration30 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "Engine",
                table: "Cars",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<string>(
                name: "Fuel",
                table: "Cars",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Engine",
                table: "Cars");

            migrationBuilder.DropColumn(
                name: "Fuel",
                table: "Cars");
        }
    }
}

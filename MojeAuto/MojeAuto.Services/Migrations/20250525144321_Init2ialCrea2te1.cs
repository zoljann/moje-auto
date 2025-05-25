using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class Init2ialCrea2te1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderItem_Order_OrderId",
                table: "OrderItem");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderItem_Part_PartId",
                table: "OrderItem");

            migrationBuilder.DropForeignKey(
                name: "FK_Part_Category_CategoryId",
                table: "Part");

            migrationBuilder.DropForeignKey(
                name: "FK_Part_Manufacturer_ManufacturerId",
                table: "Part");

            migrationBuilder.DropForeignKey(
                name: "FK_PartCar_Part_PartId",
                table: "PartCar");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Part",
                table: "Part");

            migrationBuilder.DropPrimaryKey(
                name: "PK_OrderItem",
                table: "OrderItem");

            migrationBuilder.RenameTable(
                name: "Part",
                newName: "Parts");

            migrationBuilder.RenameTable(
                name: "OrderItem",
                newName: "OrderItems");

            migrationBuilder.RenameIndex(
                name: "IX_Part_ManufacturerId",
                table: "Parts",
                newName: "IX_Parts_ManufacturerId");

            migrationBuilder.RenameIndex(
                name: "IX_Part_CategoryId",
                table: "Parts",
                newName: "IX_Parts_CategoryId");

            migrationBuilder.RenameIndex(
                name: "IX_OrderItem_PartId",
                table: "OrderItems",
                newName: "IX_OrderItems_PartId");

            migrationBuilder.RenameIndex(
                name: "IX_OrderItem_OrderId",
                table: "OrderItems",
                newName: "IX_OrderItems_OrderId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Parts",
                table: "Parts",
                column: "PartId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_OrderItems",
                table: "OrderItems",
                column: "OrderItemId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_Order_OrderId",
                table: "OrderItems",
                column: "OrderId",
                principalTable: "Order",
                principalColumn: "OrderId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_Parts_PartId",
                table: "OrderItems",
                column: "PartId",
                principalTable: "Parts",
                principalColumn: "PartId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_PartCar_Parts_PartId",
                table: "PartCar",
                column: "PartId",
                principalTable: "Parts",
                principalColumn: "PartId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Parts_Category_CategoryId",
                table: "Parts",
                column: "CategoryId",
                principalTable: "Category",
                principalColumn: "CategoryId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Parts_Manufacturer_ManufacturerId",
                table: "Parts",
                column: "ManufacturerId",
                principalTable: "Manufacturer",
                principalColumn: "ManufacturerId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_Order_OrderId",
                table: "OrderItems");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_Parts_PartId",
                table: "OrderItems");

            migrationBuilder.DropForeignKey(
                name: "FK_PartCar_Parts_PartId",
                table: "PartCar");

            migrationBuilder.DropForeignKey(
                name: "FK_Parts_Category_CategoryId",
                table: "Parts");

            migrationBuilder.DropForeignKey(
                name: "FK_Parts_Manufacturer_ManufacturerId",
                table: "Parts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Parts",
                table: "Parts");

            migrationBuilder.DropPrimaryKey(
                name: "PK_OrderItems",
                table: "OrderItems");

            migrationBuilder.RenameTable(
                name: "Parts",
                newName: "Part");

            migrationBuilder.RenameTable(
                name: "OrderItems",
                newName: "OrderItem");

            migrationBuilder.RenameIndex(
                name: "IX_Parts_ManufacturerId",
                table: "Part",
                newName: "IX_Part_ManufacturerId");

            migrationBuilder.RenameIndex(
                name: "IX_Parts_CategoryId",
                table: "Part",
                newName: "IX_Part_CategoryId");

            migrationBuilder.RenameIndex(
                name: "IX_OrderItems_PartId",
                table: "OrderItem",
                newName: "IX_OrderItem_PartId");

            migrationBuilder.RenameIndex(
                name: "IX_OrderItems_OrderId",
                table: "OrderItem",
                newName: "IX_OrderItem_OrderId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Part",
                table: "Part",
                column: "PartId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_OrderItem",
                table: "OrderItem",
                column: "OrderItemId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItem_Order_OrderId",
                table: "OrderItem",
                column: "OrderId",
                principalTable: "Order",
                principalColumn: "OrderId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItem_Part_PartId",
                table: "OrderItem",
                column: "PartId",
                principalTable: "Part",
                principalColumn: "PartId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Part_Category_CategoryId",
                table: "Part",
                column: "CategoryId",
                principalTable: "Category",
                principalColumn: "CategoryId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Part_Manufacturer_ManufacturerId",
                table: "Part",
                column: "ManufacturerId",
                principalTable: "Manufacturer",
                principalColumn: "ManufacturerId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_PartCar_Part_PartId",
                table: "PartCar",
                column: "PartId",
                principalTable: "Part",
                principalColumn: "PartId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}

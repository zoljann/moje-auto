using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MojeAuto.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialMigrationa : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Deliveries_DeliveryMethods_DeliveryMethodId",
                table: "Deliveries");

            migrationBuilder.DropForeignKey(
                name: "FK_Deliveries_DeliveryStatuses_DeliveryStatusId",
                table: "Deliveries");

            migrationBuilder.DropForeignKey(
                name: "FK_Manufacturers_Countries_CountryId",
                table: "Manufacturers");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_OrderStatuses_OrderStatusId",
                table: "Orders");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_PaymentMethods_PaymentMethodId",
                table: "Orders");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Countries_CountryId",
                table: "Users");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_UserRoles_UserRoleId",
                table: "Users");

            migrationBuilder.AddForeignKey(
                name: "FK_Deliveries_DeliveryMethods_DeliveryMethodId",
                table: "Deliveries",
                column: "DeliveryMethodId",
                principalTable: "DeliveryMethods",
                principalColumn: "DeliveryMethodId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Deliveries_DeliveryStatuses_DeliveryStatusId",
                table: "Deliveries",
                column: "DeliveryStatusId",
                principalTable: "DeliveryStatuses",
                principalColumn: "DeliveryStatusId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Manufacturers_Countries_CountryId",
                table: "Manufacturers",
                column: "CountryId",
                principalTable: "Countries",
                principalColumn: "CountryId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_OrderStatuses_OrderStatusId",
                table: "Orders",
                column: "OrderStatusId",
                principalTable: "OrderStatuses",
                principalColumn: "OrderStatusId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_PaymentMethods_PaymentMethodId",
                table: "Orders",
                column: "PaymentMethodId",
                principalTable: "PaymentMethods",
                principalColumn: "PaymentMethodId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Countries_CountryId",
                table: "Users",
                column: "CountryId",
                principalTable: "Countries",
                principalColumn: "CountryId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_UserRoles_UserRoleId",
                table: "Users",
                column: "UserRoleId",
                principalTable: "UserRoles",
                principalColumn: "UserRoleId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Deliveries_DeliveryMethods_DeliveryMethodId",
                table: "Deliveries");

            migrationBuilder.DropForeignKey(
                name: "FK_Deliveries_DeliveryStatuses_DeliveryStatusId",
                table: "Deliveries");

            migrationBuilder.DropForeignKey(
                name: "FK_Manufacturers_Countries_CountryId",
                table: "Manufacturers");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_OrderStatuses_OrderStatusId",
                table: "Orders");

            migrationBuilder.DropForeignKey(
                name: "FK_Orders_PaymentMethods_PaymentMethodId",
                table: "Orders");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Countries_CountryId",
                table: "Users");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_UserRoles_UserRoleId",
                table: "Users");

            migrationBuilder.AddForeignKey(
                name: "FK_Deliveries_DeliveryMethods_DeliveryMethodId",
                table: "Deliveries",
                column: "DeliveryMethodId",
                principalTable: "DeliveryMethods",
                principalColumn: "DeliveryMethodId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Deliveries_DeliveryStatuses_DeliveryStatusId",
                table: "Deliveries",
                column: "DeliveryStatusId",
                principalTable: "DeliveryStatuses",
                principalColumn: "DeliveryStatusId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Manufacturers_Countries_CountryId",
                table: "Manufacturers",
                column: "CountryId",
                principalTable: "Countries",
                principalColumn: "CountryId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_OrderStatuses_OrderStatusId",
                table: "Orders",
                column: "OrderStatusId",
                principalTable: "OrderStatuses",
                principalColumn: "OrderStatusId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_PaymentMethods_PaymentMethodId",
                table: "Orders",
                column: "PaymentMethodId",
                principalTable: "PaymentMethods",
                principalColumn: "PaymentMethodId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Countries_CountryId",
                table: "Users",
                column: "CountryId",
                principalTable: "Countries",
                principalColumn: "CountryId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_UserRoles_UserRoleId",
                table: "Users",
                column: "UserRoleId",
                principalTable: "UserRoles",
                principalColumn: "UserRoleId",
                onDelete: ReferentialAction.Restrict);
        }
    }
}

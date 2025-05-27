FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["MojeAuto.API/MojeAuto.API.csproj", "MojeAuto.API/"]
COPY ["MojeAuto.Services/MojeAuto.Services.csproj", "MojeAuto.Services/"]
COPY ["MojeAuto.Model/MojeAuto.Model.csproj", "MojeAuto.Model/"]

RUN dotnet restore "MojeAuto.API/MojeAuto.API.csproj"

COPY . .

RUN dotnet publish "MojeAuto.API/MojeAuto.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
EXPOSE 5269
ENV ASPNETCORE_URLS=http://+:5269

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "MojeAuto.API.dll"]

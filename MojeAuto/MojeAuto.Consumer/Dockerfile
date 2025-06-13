FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

COPY MojeAuto.Consumer/*.csproj MojeAuto.Consumer/
COPY MojeAuto.Model/*.csproj MojeAuto.Model/
COPY MojeAuto.Services/*.csproj MojeAuto.Services/
RUN dotnet restore MojeAuto.Consumer/MojeAuto.Consumer.csproj

COPY MojeAuto.Consumer/ MojeAuto.Consumer/
COPY MojeAuto.Model/ MojeAuto.Model/
COPY MojeAuto.Services/ MojeAuto.Services/

WORKDIR /app/MojeAuto.Consumer
RUN dotnet publish MojeAuto.Consumer.csproj -c Release -o /app/out

FROM mcr.microsoft.com/dotnet/runtime:9.0
WORKDIR /app
COPY --from=build /app/out ./
ENTRYPOINT ["dotnet", "MojeAuto.Consumer.dll"]

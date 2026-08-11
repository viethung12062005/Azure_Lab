# --- STAGE 1: BUILD ---
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
WORKDIR /src

COPY ["Store/Store.csproj", "Store/"]
COPY ["Products/Products.csproj", "Products/"]
COPY ["DataEntities/DataEntities.csproj", "DataEntities/"]
COPY ["CartEntities/CartEntities.csproj", "CartEntities/"]
COPY ["SearchEntities/SearchEntities.csproj", "SearchEntities/"]
COPY ["eShopServiceDefaults/eShopServiceDefaults.csproj", "eShopServiceDefaults/"]
RUN dotnet restore "Store/Store.csproj"

COPY . .
WORKDIR "/src/Store"
RUN dotnet publish "Store.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- STAGE 2: RUN ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine AS final
WORKDIR /app
COPY --from=build /app/publish .

# Copy thẳng thư mục images từ wwwroot của Products sang thư mục wwwroot/images của Store
RUN mkdir -p ./wwwroot/images
COPY --from=build /src/Products/wwwroot/images/. ./wwwroot/images/

# Ép .NET chạy thẳng trực tiếp ở cổng 80 để khớp hoàn toàn với Azure
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "Store.dll"]
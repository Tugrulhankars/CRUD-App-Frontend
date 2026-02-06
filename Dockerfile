FROM node:20-alpine as build

#konteyner içinde çalışacağımız klasörü oluşturuyoruz
WORKDIR /app

#bağımlılıkları yüklemek için package.json ve package-lock.json dosyalarını konteynere kopyalıyoruz
# Sadece bunları kopyalıyoruz ki kod değişse bile kütüphaneler cache'ten gelsin.
COPY package*.json ./

#kütüphaneleri yüklüyoruz
RUN npm install

# Projenin tüm kaynak kodunu konteynerin içine kopyalıyoruz.
COPY  . .

# Uygulamayı üretim (production) modunda derliyoruz.
# Bu komut 'dist/' klasörü altında statik dosyalar oluşturur.
RUN npm run build --configuration=production

# --- 2. AŞAMA: Yayınlama (Serve) ---
# Derlenen dosyaları sunmak için hafif bir web sunucusu olan Nginx kullanıyoruz.
FROM nginx:stable-alpine

# Angular'ın ürettiği dosyaları Nginx'in yayın klasörüne kopyalıyoruz.
# [proje-adin] kısmını angular.json dosyasındaki 'outputPath'e göre düzenlemelisin.
COPY --from=build /app/dist/proje-adin/browser /usr/share/nginx/html

# Nginx için özel bir konfigürasyon gerekirse kopyalayabilirsin (Opsiyonel)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# 80 portunu dış dünyaya açıyoruz.
EXPOSE 80

# Nginx'i başlatıyoruz.
CMD ["nginx", "-g", "daemon off;"]

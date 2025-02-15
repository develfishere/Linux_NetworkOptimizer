# بهینه‌ساز شبکه لینوکس نسخه 0.7

این مخزن شامل یک **اسکریپت Bash** است که برای بهبود خودکار سرعت و عملکرد شبکه در سیستم‌های لینوکس ساخته شده است

این اسکریپت با استفاده از الگوریتم **BBR**، تنظیمات شبکه را **به‌طور هوشمند** بر اساس ویژگی‌های سخت‌افزاری سیستم مانند **پردازنده** و حافظه **رم** بهینه‌سازی می‌کند

در این فرآیند، مناسب‌ترین الگوریتم صف‌بندی از میان **fq_codel** و **cake** به‌طور پویا انتخاب و پیاده‌سازی می‌شود تا بهترین عملکرد و کمترین تاخیر حاصل شود

**اگر ترجیح می‌دهید، می‌توانید به [راهنمای انگلیسی](./README.md) مراجعه کنید**

**همچنین، [فهرست تغییرات](./CHANGELOG_FA.md) در لینک ارائه شده در دسترس است**

## ویژگی‌های کلیدی

1- انتخاب و پیکربندی هوشمند الگوریتم صف‌بندی‌ها (`fq_codel`, `cake`) بر اساس منابع سیستم

2- پیاده‌سازی کنترل ازدحام `BBR` برای دستیابی به پهنای باند بهینه و تأخیر کم

3- تنظیم اندازه بافرهای TCP (`tcp_rmem`, `tcp_wmem`) بر اساس CPU و RAM

4- بهینه‌سازی `netdev_max_backlog` و بافرهای حافظه برای مدیریت حجم بالای اتصالات TCP

5- یافتن بهترین اندازه `MTU` به منظور بهبود عملکرد شبکه

6- ارائه پشتیبان‌گیری خودکار و بازیابی تنظیمات اصلی شبکه

## پیش‌نیازها

### این اسکریپت نیاز به دسترسی روت (Sudo) دارد اگر به عنوان روت وارد سیستم نشده‌اید، از دستور زیر استفاده کنید

```bash
sudo -i
```

## نحوه استفاده

برای به‌روزرسانی سیستم و اجرای اسکریپت از دستور زیر استفاده کنید

```bash
sudo apt-get -o Acquire::ForceIPv4=true update && \
sudo apt-get -o Acquire::ForceIPv4=true install -y sudo curl jq && \
bash <(curl -Ls --ipv4 https://raw.githubusercontent.com/develfishere/Linux_NetworkOptimizer/main/bbr.sh)
```

## پشتیبانی

اگر با مشکلی مواجه شدید یا پیشنهادی دارید، می‌توانید آن را در [بخش مشکلات GitHub](https://github.com/develfishere/Linux_NetworkOptimizer/issues) مطرح کنید

## نکته مهم

این اسکریپت به صورت "همان‌گونه که هست" ارائه شده است و هیچ ضمانتی بابت آن ارائه نمی‌شود. استفاده از آن به عهده خود شماست

## مجوز

این پروژه تحت مجوز MIT ارائه شده است

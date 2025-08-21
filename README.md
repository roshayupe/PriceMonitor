# Price Monitor

Система моніторингу цін конкурентів.

## 📌 Опис розробки

Програма призначена для роботи з Oracle Database і дозволяє:
- завантажувати дані про ціни товарів у конкурентів;
- редагувати ціни (для поточної дати);
- зберігати зміни у базі;
- скасовувати незбережені зміни;
- відображати динаміку цін (зміна порівняно з попереднім моніторингом) за допомогою кольорів:
  - 🔴 червоний — ціна зросла;
  - 🟢 зелений — ціна знизилась;
  - ⚪ без підсвітки — ціна не змінилась.

### Використані технології
- **Delphi 12.3 (Athens)**  
- **DevExpress VCL** (TcxGrid, TcxDateEdit, TcxCheckedComboBox)  
- **ODAC (Devart)** для доступу до Oracle  
- **Oracle Database 19c Client**  

### Основні елементи інтерфейсу
- `TcxCheckedComboBox` — вибір конкурентів (із можливістю "Усі");  
- `TcxDateEdit` — вибір дати моніторингу;  
- `TcxGrid` — відображення товарів та цін у динамічних стовпцях;  
- Кнопки: **Завантажити**, **Зберегти**, **Скасувати**.

---

## ⚙️ Інструкція з розгортання

1. Установіть **Delphi 12.3 (Athens)**  
   👉 [завантажити](https://www.embarcadero.com/ru/products/delphi/start-for-free)  
   (тестувалось також на Delphi 11, попередні версії можуть працювати).

2. Установіть **DevExpress VCL**  
   👉 [завантажити](https://go.devexpress.com/DevExpressDownload_VCLTrial12Athens.aspx)  
   ⚠️ Trial може не містити всіх пакетів — рекомендовано використовувати платну версію.

3. Установіть **ODAC (Devart)**  
   👉 [завантажити](https://www.devart.com/odac/download.html)  

4. Установіть **Oracle Database 19c Client**  
   👉 [завантажити](https://www.oracle.com/database/technologies/oracle19c-windows-downloads.html)  

5. Установіть **Wallet (TLS)**  
   👉 [посилання](https://drive.google.com/drive/folders/1QZu1Ig4LrZCVVWVEv1ALtyH-ttRcO2m8?usp=sharing)  
   Розпакуйте `Wallet_MONITOR.zip` у `network/admin` каталогу клієнта Oracle (наприклад: `C:\Oracle\NT_193000_client_home\network\admin`).

6. Установіть **Git**  
   👉 [завантажити](https://git-scm.com/downloads/win)

7. Укажіть шлях до `git.exe` у Delphi  
   `Tools | Options | Version control | Git page`  
   За замовчуванням: `C:\Program Files\Git\bin\git.exe`.

8. Завантажте проект із Git-репозиторію  
   У Delphi: `File | Open from version control…`  
   - Source: `https://github.com/roshayupe/PriceMonitor.git`  
   - Destination: зручна локальна папка.  

   Після завантаження оберіть файл проекту (`.dproj`).

9. Якщо Ви надаєте перевагу розгортанню бази у власній СУБД, скористайтеся наведеними скриптами за посиланням.  
   Логін та пароль до бази задані безпосередньо у компоненті **OraSession | ConnectString**. Пункти, починаючи з 4-го, тоді не потрібні. 
   👉 [DB scripts](https://drive.google.com/drive/folders/1wCFBa3omB6UZasoKFlyUd9pdv6HMLc6R?usp=sharing)  

---

## 🗂️ Структура БД
- **PRODUCTS** — товари  
- **COMPETITORS** — конкуренти  
- **PRICES** — ціни  
- **PACKAGE PRICE_MONITORING**:  
  - `get_prices(p_monitor_date, p_competitors_csv)` — повертає дані;  
  - `save_prices(p_data_csv)` — зберігає або оновлює дані.

---

## 📄 Ліцензія
Проект внутрішній, використовується для демонстрації.
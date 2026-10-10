Burnout Pulse AI Admin — คู่มือติดตั้งเชื่อม MySQL ผ่าน XAMPP
===========================================================

สิ่งที่เพิ่ม/แก้ในชุดนี้
- เปิดโหมด API จริง ไม่ใช้ข้อมูลจำลอง
- เพิ่ม PHP API สำหรับ Login และ CRUD พนักงาน/ผู้มาเยือน
- หน้า Database อ่านค่าจาก user_logs และแสดง camera_state, hrv, survey_answer
- รีเฟรชข้อมูลจาก Database ทุก 5 วินาที (ใกล้เรียลไทม์)
- มีตาราง visitor_cards รองรับเมนูผู้มาเยือนเดิม
- ใช้ PDO prepared statements และ PHP session login

ก่อนเริ่ม
---------
1. สำรอง Database `my_database` เป็นไฟล์ .sql จาก phpMyAdmin ก่อนเสมอ
2. เปิด XAMPP Control Panel แล้ว Start Apache และ MySQL
3. แตกโฟลเดอร์ Admin_Burnout ไปไว้ที่:
   C:\xampp\htdocs\Admin_Burnout
4. ห้ามเปิด index.html ด้วยการดับเบิลคลิกเป็น file:// เพราะ PHP API จะไม่ทำงาน
   ให้เปิดผ่าน URL: http://localhost/Admin_Burnout/

ขั้นตอน A — ตั้งค่า Database
---------------------------
1. เปิด http://localhost/phpmyadmin/
2. เลือกแท็บ Import แล้วเลือกไฟล์ database_setup.sql จากโฟลเดอร์ Admin_Burnout
   หรือเปิดแท็บ SQL แล้วคัดลอกเนื้อหาในไฟล์ไปรัน
3. ใช้บัญชีที่มีสิทธิ์จัดการ MySQL users เช่น root ของ XAMPP
4. CREATE TABLE IF NOT EXISTS จะไม่ลบตารางหรือข้อมูลที่มีอยู่แล้ว

ตรวจสอบโครงสร้างตารางเดิมใน phpMyAdmin > Structure:
- registered_users ต้องมี: id (AUTO_INCREMENT), rfid_uid, username
- user_logs ต้องมี: recorded_time, rfid_uid, camera_state, hrv, survey_answer
- camera_state: 0 = Normal, 1 = Abnormal/Risk ตามตัวอย่าง Python
- ถ้า registered_users ใช้ชื่อคอลัมน์ ID อย่างอื่นแทน `id` ให้ปรับ SQL ใน api/cards.php ให้ตรง
- หากชื่อตาราง/คอลัมน์จริงไม่ตรงกับรายการนี้ ให้ปรับ API ให้ตรงกับ schema เดิม อย่าลบตารางที่มีข้อมูลทิ้ง

ขั้นตอน B — ตั้งค่าบัญชี Database สำหรับเว็บ
--------------------------------------------
ไฟล์: Admin_Burnout/api/config.php
ค่าตั้งต้นในชุดนี้:
  DB_HOST = 127.0.0.1
  DB_NAME = my_database
  DB_USER = burnout_app
  DB_PASS = ChangeThisDbPassword!2026

ไฟล์ database_setup.sql สร้างบัญชี burnout_app@localhost ด้วยรหัสผ่านตัวอย่างเดียวกัน
หากเปลี่ยน DB_PASS ใน api/config.php ต้องเปลี่ยนรหัสผ่าน MySQL user ให้ตรงกันด้วย
ตัวอย่าง SQL (ตั้งรหัสผ่านใหม่ให้เดายากและใส่ค่าเดียวกันใน config.php):
  ALTER USER 'burnout_app'@'localhost' IDENTIFIED BY 'รหัสผ่านใหม่ที่เดายาก';
  GRANT SELECT, INSERT, UPDATE, DELETE ON my_database.* TO 'burnout_app'@'localhost';

PHP ทำงานบนเครื่องเดียวกับ MySQL จึงใช้ 127.0.0.1 ไม่ใช่ 10.26.1.95
IP 10.26.1.95 ใช้ตอนเครื่องอื่นเปิดหน้าเว็บผ่านเครือข่าย LAN

ขั้นตอน C — เข้าสู่หน้า Admin
----------------------------
เปิด: http://localhost/Admin_Burnout/
ชื่อผู้ใช้เริ่มต้น: admin
รหัสผ่านเริ่มต้น: ChangeThisAdminPassword!2026

เปลี่ยนรหัสผ่านเริ่มต้นก่อนใช้งานจริง โดยสร้าง hash ใหม่ด้วย PHP:
1. สร้างไฟล์ชั่วคราว C:\xampp\htdocs\make_hash.php:
   <?php echo password_hash('รหัสผ่านใหม่ของคุณ', PASSWORD_DEFAULT); ?>
2. เปิด http://localhost/make_hash.php แล้วคัดลอก hash ที่แสดง
3. ลบ make_hash.php ทันทีหลังใช้
4. แทนค่า ADMIN_PASSWORD_HASH ใน api/config.php ด้วย hash ใหม่
5. เปลี่ยน ADMIN_USERNAME ได้ในไฟล์เดียวกัน

ขั้นตอน D — เพิ่ม/แก้ไขพนักงานผ่านเว็บ
------------------------------------
1. Login เข้าเว็บ แล้วเลือกเมนู “พนักงาน”
2. กด “เพิ่มบัตรใหม่” แล้วกรอกชื่อและ RFID
3. กดบันทึก ข้อมูลจะ INSERT ลง registered_users ทันที
4. กด “แก้ไข” เพื่อ UPDATE หรือ “ลบ” เพื่อลบข้อมูลพนักงาน
5. RFID ต้องเป็นเลขฐานสิบหก 8–20 ตัว (ใส่ : หรือ - คั่นได้) เช่น 9A:2C:79:A1
   API จะเก็บเป็นตัวพิมพ์ใหญ่โดยไม่มีตัวคั่น เช่น 9A2C79A1

ขั้นตอน E — ให้หน้า Admin แสดงค่าจาก Python modules
--------------------------------------------------
หน้าเว็บอ่านค่าจากตาราง user_logs ที่โค้ด Python ของคุณเขียนอยู่แล้ว
Python ควร INSERT ลงคอลัมน์:
  recorded_time, rfid_uid, camera_state, hrv, survey_answer

ตัวอย่าง INSERT ทดสอบ (อย่ารันซ้ำถ้าไม่ต้องการข้อมูลทดสอบเพิ่ม):
  INSERT INTO user_logs
    (recorded_time, rfid_uid, camera_state, hrv, survey_answer)
  VALUES
    (NOW(), '9A2C79A1', 0, 52.4, 8.0);

เมื่อ Python บันทึกแถวใหม่ หน้า Database ของ Admin จะดึงข้อมูลใหม่ภายในประมาณ 5 วินาที
การเพิ่ม/แก้ไข/ลบพนักงานจากหน้าจะบันทึกลง MySQL เมื่อกดบันทึกและ API สำเร็จ

ขั้นตอน F — เปิดหน้าเว็บจากเครื่องอื่นใน LAN
--------------------------------------------
1. เครื่องที่รัน XAMPP ต้องเปิด Apache และ MySQL ตลอดเวลาที่ใช้งาน
2. เครื่องเพื่อนเปิด URL: http://10.26.1.95/Admin_Burnout/
3. หากเข้าไม่ได้ ให้ตรวจ Windows Firewall สำหรับ Apache (ปกติ TCP 80) และตรวจว่าเครือข่ายอนุญาตให้อุปกรณ์ติดต่อกัน
4. อย่าเปิดพอร์ต MySQL 3306 ออกสู่อินเทอร์เน็ตโดยตรง และอย่าให้เพื่อนใช้บัญชีผู้ดูแล phpMyAdmin

การแก้ปัญหา
-----------
- API 404: ต้องเข้าผ่าน http://localhost/Admin_Burnout/ และตรวจว่าโฟลเดอร์ api อยู่ใต้ Admin_Burnout
- เชื่อมต่อ Database ไม่ได้: ตรวจ MySQL ใน XAMPP, DB_NAME/DB_USER/DB_PASS และว่ามี burnout_app@localhost
- Unknown column/table: เทียบชื่อคอลัมน์ใน phpMyAdmin > Structure กับรายการในขั้นตอน A
- Login ไม่ผ่าน: ใช้ admin / ChangeThisAdminPassword!2026 ก่อนเปลี่ยน hash
- รายการไม่อัปเดต: ตรวจว่า Python เขียนเข้า my_database.user_logs จริง และมีค่า recorded_time

หมายเหตุความปลอดภัย
-------------------
ชุดนี้เหมาะกับโปรเจกต์ต้นแบบ/เครือข่ายภายใน ควรเปลี่ยนรหัสผ่านตัวอย่างก่อนใช้งานจริง
อย่าใช้รหัสผ่านง่าย เช่น 123456 และอย่าเปิด phpMyAdmin/MySQL สู่ Internet โดยตรง
ข้อมูล HRV/แบบสอบถามเป็นข้อมูลอ่อนไหว ควรจำกัดสิทธิ์ผู้เข้าถึงและเก็บเท่าที่จำเป็น
